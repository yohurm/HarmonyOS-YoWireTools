import { Subscription } from 'common_core';
import { LifecycleCoordinator, PlatformEvent, PlatformEventType } from 'common_platform';
import { BluetoothRepository } from '../../data/repository/BluetoothRepository';
import { PairingState } from '../model/PairingState';
import { ReconnectPolicy } from '../model/ReconnectPolicy';
import { SppReconnectEventLogger } from './SppReconnectEventLogger';
import { SppSessionTeardown } from './spp/SppSessionTeardown';

type ReconnectAction = () => Promise<void>;

class SppReconnectBinding {
  readonly classicDeviceId: string;
  readonly action: ReconnectAction;
  readonly policy: ReconnectPolicy;
  attempt: number = 0;
  inFlight: boolean = false;
  cancelled: boolean = false;
  /** Set on link-loss; cleared after successful reopen. tryAll skips when false. */
  reconnectNeeded: boolean = false;

  constructor(classicDeviceId: string, action: ReconnectAction, policy: ReconnectPolicy) {
    this.classicDeviceId = classicDeviceId;
    this.action = action;
    this.policy = policy;
  }
}

/**
 * Sole SPP reconnect owner (architecture bluetooth/02 §11).
 * Connect binds after promote; Transport link-loss calls requestReconnect (no parallel Transport loop).
 * Pair lost / exhausted → unbind + SppSessionTeardown.failCleanup (full TSR/Runtime stop).
 */
export class SppReconnectCoordinator {
  private static instance: SppReconnectCoordinator | undefined;
  private adapterSub: Subscription | undefined;
  private lifecycleUnsub: (() => void) | undefined;
  private readonly bindings: Map<string, SppReconnectBinding> = new Map();

  static getInstance(): SppReconnectCoordinator {
    if (SppReconnectCoordinator.instance === undefined) {
      SppReconnectCoordinator.instance = new SppReconnectCoordinator();
    }
    return SppReconnectCoordinator.instance;
  }

  bind(
    sessionId: string,
    classicDeviceId: string,
    action: ReconnectAction,
    policy: ReconnectPolicy = ReconnectPolicy.defaultPolicy()
  ): void {
    const existing = this.bindings.get(sessionId);
    if (existing !== undefined) {
      existing.cancelled = true;
    }
    this.bindings.set(sessionId, new SppReconnectBinding(classicDeviceId, action, policy));
    this.ensureGlobalListeners();
  }

  failureCount(): number {
    let total = 0;
    this.bindings.forEach((binding: SppReconnectBinding) => {
      total = total + binding.attempt;
    });
    return total;
  }

  stopAutoReconnect(): void {
    const sessionIds = Array.from(this.bindings.keys());
    for (let i = 0; i < sessionIds.length; i++) {
      this.unbind(sessionIds[i]);
    }
  }

  unbind(sessionId: string): void {
    const binding = this.bindings.get(sessionId);
    if (binding !== undefined) {
      binding.cancelled = true;
      binding.reconnectNeeded = false;
      this.bindings.delete(sessionId);
    }
    if (this.bindings.size === 0) {
      this.disposeGlobalListeners();
    }
  }

  /**
   * Link-loss entry: arm reconnect and run cycle (backoff + action).
   */
  async requestReconnect(sessionId: string, reason: string = 'unexpected_disconnect'): Promise<void> {
    const binding = this.bindings.get(sessionId);
    if (binding === undefined || binding.cancelled) {
      return;
    }
    binding.reconnectNeeded = true;
    await this.tryReconnect(sessionId, reason);
  }

  /**
   * Schedule / run one reconnect cycle with backoff. Recursive on action failure until exhausted.
   * No-ops unless reconnectNeeded (avoids burning attempts while still CONNECTED).
   */
  async tryReconnect(sessionId: string, reason: string = 'unexpected_disconnect'): Promise<void> {
    const binding = this.bindings.get(sessionId);
    if (binding === undefined || binding.classicDeviceId.length === 0 || binding.cancelled) {
      return;
    }
    if (!binding.reconnectNeeded) {
      return;
    }
    if (binding.inFlight) {
      return;
    }
    binding.inFlight = true;
    try {
      await this.runReconnectCycle(sessionId, binding, reason);
    } finally {
      const current = this.bindings.get(sessionId);
      if (current !== undefined) {
        current.inFlight = false;
      }
    }
  }

  /**
   * Abort reconnect and perform full fail teardown (pair lost / exhausted / external fail).
   */
  async abortWithTeardown(sessionId: string, reason: string): Promise<void> {
    this.unbind(sessionId);
    await SppSessionTeardown.failCleanup(sessionId, reason);
  }

  private async runReconnectCycle(
    sessionId: string,
    binding: SppReconnectBinding,
    reason: string
  ): Promise<void> {
    if (binding.cancelled || !binding.reconnectNeeded) {
      return;
    }
    const repository = BluetoothRepository.getInstance();
    await repository.ensureClassicDiscoveryStopped();

    if (binding.policy.stopOnPairLost) {
      const pairState = await repository.getPairState(binding.classicDeviceId);
      if (binding.cancelled || !binding.reconnectNeeded) {
        return;
      }
      if (pairState.success && pairState.value === PairingState.UNPAIRED) {
        await this.abortWithTeardown(sessionId, 'pair lost');
        return;
      }
    }

    if (binding.attempt >= binding.policy.maxAttempts) {
      await this.abortWithTeardown(sessionId, 'reconnect exhausted');
      return;
    }

    const attemptIndex = binding.attempt;
    binding.attempt = attemptIndex + 1;
    const delayMs = binding.policy.computeDelayMs(attemptIndex);
    await SppReconnectEventLogger.logReconnectAttempt(sessionId, binding.attempt, reason);
    await new Promise<void>((resolve: () => void) => {
      setTimeout(() => resolve(), delayMs);
    });
    if (binding.cancelled || this.bindings.get(sessionId) !== binding || !binding.reconnectNeeded) {
      return;
    }

    try {
      await binding.action();
      binding.reconnectNeeded = false;
      binding.attempt = 0;
    } catch (_error) {
      if (binding.cancelled || this.bindings.get(sessionId) !== binding) {
        return;
      }
      if (binding.attempt >= binding.policy.maxAttempts) {
        await this.abortWithTeardown(sessionId, 'reconnect exhausted');
        return;
      }
      await this.runReconnectCycle(sessionId, binding, 'reconnect failed');
    }
  }

  private ensureGlobalListeners(): void {
    if (this.adapterSub !== undefined) {
      return;
    }
    const repository = BluetoothRepository.getInstance();
    this.adapterSub = repository.observeAdapterState().subscribe(() => {
      void this.tryAll('adapter_on');
    });
    this.lifecycleUnsub = LifecycleCoordinator.getInstance().addListener((event: PlatformEvent) => {
      if (event.type === PlatformEventType.APP_FOREGROUND || event.type === PlatformEventType.BLUETOOTH_SWITCH) {
        void this.tryAll('lifecycle');
      }
    });
  }

  private disposeGlobalListeners(): void {
    this.adapterSub?.dispose();
    this.adapterSub = undefined;
    this.lifecycleUnsub?.();
    this.lifecycleUnsub = undefined;
  }

  private async tryAll(reason: string): Promise<void> {
    const sessionIds = Array.from(this.bindings.keys());
    for (let i = 0; i < sessionIds.length; i++) {
      await this.tryReconnect(sessionIds[i], reason);
    }
  }
}
