import { Observable, Subscription } from 'common_core';
import { AppLogger } from '../logging/AppLogger';
import { AppLogTag } from '../logging/AppLogTag';
import { LogParams } from '../logging/LogParams';
import { AppLifecycleState } from './AppLifecycleState';
import { LifecycleListener, ReconcileCallback } from './LifecycleContracts';
import { PlatformEvent } from './PlatformEvent';
import { PlatformEventType } from './PlatformEventType';
const logger = new AppLogger(AppLogTag.LIFE);
/**
 * Coordinates app lifecycle and platform events per architecture §9.1.
 * EntryAbility wires onForeground/onBackground into this coordinator.
 */
export class LifecycleCoordinator {
  private static instance: LifecycleCoordinator | undefined;
  private readonly listeners: Set<LifecycleListener> = new Set();
  private readonly reconcileCallbacks: Set<ReconcileCallback> = new Set();
  private readonly lifecycleObservable: Observable<AppLifecycleState>;
  private currentState: AppLifecycleState = AppLifecycleState.FOREGROUND;
  private backgroundConnectionEnabledValue: boolean = true;
  private backgroundPeriodicEnabledValue: boolean = false;
  private constructor() {
    this.lifecycleObservable = new Observable<AppLifecycleState>(AppLifecycleState.FOREGROUND);
  }
  static getInstance(): LifecycleCoordinator {
    if (LifecycleCoordinator.instance === undefined) {
      LifecycleCoordinator.instance = new LifecycleCoordinator();
    }
    return LifecycleCoordinator.instance;
  }
  get state(): AppLifecycleState {
    return this.currentState;
  }
  observeLifecycle(observer: (state: AppLifecycleState) => void): Subscription {
    return this.lifecycleObservable.subscribe(observer);
  }
  get backgroundConnectionEnabled(): boolean {
    return this.backgroundConnectionEnabledValue;
  }
  get backgroundPeriodicEnabled(): boolean {
    return this.backgroundPeriodicEnabledValue;
  }
  configureBackgroundSettings(connectionEnabled: boolean, periodicEnabled: boolean): void {
    this.backgroundConnectionEnabledValue = connectionEnabled;
    this.backgroundPeriodicEnabledValue = periodicEnabled;
    logger.params('background_settings', LogParams.create()
      .put('connection', connectionEnabled ? 1 : 0)
      .put('periodic', periodicEnabled ? 1 : 0));
  }
  onAppForeground(detail: string = ''): void {
    this.transition(AppLifecycleState.FOREGROUND, PlatformEventType.APP_FOREGROUND, detail);
    this.reconcile();
  }
  onAppBackground(detail: string = ''): void {
    this.transition(AppLifecycleState.BACKGROUND, PlatformEventType.APP_BACKGROUND, detail);
  }
  onWindowStageCreate(detail: string = ''): void {
    this.dispatch(new PlatformEvent(PlatformEventType.WINDOW_STAGE_CREATE, detail));
  }
  onWindowStageDestroy(detail: string = ''): void {
    this.dispatch(new PlatformEvent(PlatformEventType.WINDOW_STAGE_DESTROY, detail));
  }
  onNetworkChanged(detail: string = ''): void {
    this.dispatch(new PlatformEvent(PlatformEventType.NETWORK_CHANGED, detail));
  }
  onBluetoothSwitchChanged(enabled: boolean): void {
    this.dispatch(new PlatformEvent(PlatformEventType.BLUETOOTH_SWITCH, enabled ? 'on' : 'off'));
  }
  onWifiSwitchChanged(enabled: boolean): void {
    this.dispatch(new PlatformEvent(PlatformEventType.WIFI_SWITCH, enabled ? 'on' : 'off'));
  }
  onNearLinkSwitchChanged(enabled: boolean): void {
    this.dispatch(new PlatformEvent(PlatformEventType.NEARLINK_SWITCH, enabled ? 'on' : 'off'));
  }
  addListener(listener: LifecycleListener): () => void {
    this.listeners.add(listener);
    return () => {
      this.listeners.delete(listener);
    };
  }
  addReconcileCallback(callback: ReconcileCallback): () => void {
    this.reconcileCallbacks.add(callback);
    return () => {
      this.reconcileCallbacks.delete(callback);
    };
  }
  async reconcile(): Promise<void> {
    logger.info('lifecycle_reconcile started');
    const callbacks = Array.from(this.reconcileCallbacks);
    for (let i = 0; i < callbacks.length; i++) {
      try {
        await callbacks[i]();
      } catch (_error) {
        logger.error('lifecycle_reconcile callback failed');
      }
    }
    logger.info('lifecycle_reconcile successful');
  }
  private transition(state: AppLifecycleState, eventType: PlatformEventType, detail: string): void {
    const previous = this.currentState;
    this.currentState = state;
    this.lifecycleObservable.next(state);
    logger.stateTransition('app_lifecycle', previous, state, detail);
    this.dispatch(new PlatformEvent(eventType, detail));
  }
  private dispatch(event: PlatformEvent): void {
    this.listeners.forEach((listener: LifecycleListener) => {
      listener(event);
    });
  }
}
