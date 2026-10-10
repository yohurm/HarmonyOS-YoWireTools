import { Result } from 'common_core';
import { RadioSwitchReading } from 'debug_core';
import { ReadNearLinkSwitchUseCase } from 'feature_nearlink';
import { ReadWifiSwitchUseCase } from 'feature_wifi_network';
import { ReadBluetoothSwitchUseCase } from 'yobluetooth';

@ObservedV2
export class WorkbenchRadioState {
  @Trace bluetooth: string = RadioSwitchReading.UNREAD;
  @Trace wlan: string = RadioSwitchReading.UNREAD;
  @Trace nearlink: string = RadioSwitchReading.UNREAD;

  private readonly readBluetooth: ReadBluetoothSwitchUseCase;
  private readonly readWifi: ReadWifiSwitchUseCase;
  private readonly readNearLink: ReadNearLinkSwitchUseCase;

  constructor(
    readBluetooth: ReadBluetoothSwitchUseCase = new ReadBluetoothSwitchUseCase(),
    readWifi: ReadWifiSwitchUseCase = new ReadWifiSwitchUseCase(),
    readNearLink: ReadNearLinkSwitchUseCase = new ReadNearLinkSwitchUseCase()
  ) {
    this.readBluetooth = readBluetooth;
    this.readWifi = readWifi;
    this.readNearLink = readNearLink;
  }

  refresh(): void {
    void this.load();
  }

  private async load(): Promise<void> {
    this.bluetooth = await this.readOne(() => this.readBluetooth.execute());
    this.wlan = await this.readOne(() => this.readWifi.execute());
    this.nearlink = await this.readOne(() => this.readNearLink.execute());
  }

  private async readOne(run: () => Promise<Result<string>>): Promise<string> {
    try {
      const listed = await run();
      if (!listed.success || listed.value === undefined) {
        return RadioSwitchReading.UNREAD;
      }
      return listed.value;
    } catch (_error) {
      return RadioSwitchReading.UNREAD;
    }
  }
}
