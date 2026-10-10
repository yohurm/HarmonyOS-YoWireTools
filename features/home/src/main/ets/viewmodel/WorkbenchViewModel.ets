import { RadioSwitchReading } from 'debug_core';

/**
 * One dashboard figure the workbench contract already holds.
 * Readings come from the shell switch use cases. This type does not call Kit.
 */
export class WorkbenchDashboardFigure {
  readonly id: string;
  readonly reading: string;
  readonly useCaseName: string;
  readonly repositoryContractName: string;

  constructor(
    id: string,
    reading: string,
    useCaseName: string,
    repositoryContractName: string
  ) {
    this.id = id;
    this.reading = reading;
    this.useCaseName = useCaseName;
    this.repositoryContractName = repositoryContractName;
  }
}

/**
 * Workbench home state: capability readings only.
 * Session lists, entry cards, and log or command shortcuts are not on this contract.
 */
@ObservedV2
export class WorkbenchViewModel {
  @Trace bluetoothReading: string = RadioSwitchReading.UNREAD;
  @Trace wlanReading: string = RadioSwitchReading.UNREAD;
  @Trace nearlinkReading: string = RadioSwitchReading.UNREAD;

  bindCapability(bluetooth: string, wlan: string, nearlink: string): void {
    this.bluetoothReading = bluetooth;
    this.wlanReading = wlan;
    this.nearlinkReading = nearlink;
  }

  figures(): WorkbenchDashboardFigure[] {
    return [
      new WorkbenchDashboardFigure(
        'bluetoothSwitch',
        this.bluetoothReading,
        'ReadBluetoothSwitchUseCase',
        'BluetoothRepositoryContract'
      ),
      new WorkbenchDashboardFigure(
        'wlanSwitch',
        this.wlanReading,
        'ReadWifiSwitchUseCase',
        'WifiNetworkRepositoryContract'
      ),
      new WorkbenchDashboardFigure(
        'nearlinkSwitch',
        this.nearlinkReading,
        'ReadNearLinkSwitchUseCase',
        'NearLinkRepositoryContract'
      )
    ];
  }
}
