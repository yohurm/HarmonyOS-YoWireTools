import { Subscription } from 'common_core';

export class BluetoothSubscriptionBundle {
  readonly classicDevices: Subscription;
  readonly bleDevices: Subscription;

  constructor(classicDevices: Subscription, bleDevices: Subscription) {
    this.classicDevices = classicDevices;
    this.bleDevices = bleDevices;
  }

  dispose(): void {
    this.classicDevices.dispose();
    this.bleDevices.dispose();
  }
}
