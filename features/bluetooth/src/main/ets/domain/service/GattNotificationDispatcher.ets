import { IncomingPayload, ITransportSession } from 'feature_debug_core';
import { Observable, Subscription, TimeUtil } from 'common_core';

type NotifyListener = (serviceUuid: string, characteristicUuid: string, payload: IncomingPayload) => void;

/**
 * Dispatches BLE characteristic notifications per architecture bluetooth/03-§6.
 */
export class GattNotificationDispatcher {
  private readonly listeners: Map<string, NotifyListener> = new Map();
  private transportSubscription: Subscription | undefined;

  bindTransport(
    transport: ITransportSession,
    serviceUuid: string,
    characteristicUuid: string,
    listener: NotifyListener
  ): void {
    const key = GattNotificationDispatcher.key(serviceUuid, characteristicUuid);
    this.listeners.set(key, listener);
    if (this.transportSubscription !== undefined) {
      this.transportSubscription.dispose();
    }
    this.transportSubscription = transport.observeIncoming().subscribe((payload: IncomingPayload) => {
      const notifyListener = this.listeners.get(key);
      if (notifyListener !== undefined) {
        notifyListener(serviceUuid, characteristicUuid, payload);
      }
    });
  }

  register(serviceUuid: string, characteristicUuid: string, listener: NotifyListener): void {
    this.listeners.set(GattNotificationDispatcher.key(serviceUuid, characteristicUuid), listener);
  }

  unregister(serviceUuid: string, characteristicUuid: string): void {
    this.listeners.delete(GattNotificationDispatcher.key(serviceUuid, characteristicUuid));
  }

  dispose(): void {
    if (this.transportSubscription !== undefined) {
      this.transportSubscription.dispose();
      this.transportSubscription = undefined;
    }
    this.listeners.clear();
  }

  private static key(serviceUuid: string, characteristicUuid: string): string {
    return `${serviceUuid}:${characteristicUuid}`.toUpperCase();
  }

  static buildKey(serviceUuid: string, characteristicUuid: string): string {
    return GattNotificationDispatcher.key(serviceUuid, characteristicUuid);
  }
}

export class CharacteristicLiveValueStore {
  private readonly values: Map<string, IncomingPayload> = new Map();
  private readonly observable: Observable<IncomingPayload>;

  constructor() {
    this.observable = new Observable<IncomingPayload>(new IncomingPayload(new Uint8Array(0), TimeUtil.nowMs()));
  }

  update(serviceUuid: string, characteristicUuid: string, payload: IncomingPayload): void {
    this.values.set(GattNotificationDispatcher.buildKey(serviceUuid, characteristicUuid), payload);
    this.observable.next(payload);
  }

  observe(): Observable<IncomingPayload> {
    return this.observable;
  }

  get(serviceUuid: string, characteristicUuid: string): IncomingPayload | undefined {
    return this.values.get(GattNotificationDispatcher.buildKey(serviceUuid, characteristicUuid));
  }
}
