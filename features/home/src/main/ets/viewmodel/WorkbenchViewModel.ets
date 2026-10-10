import {
  CountSessionLogRowsUseCase,
  LoadWorkbenchOverviewUseCase,
  RadioSwitchReading
} from 'debug_core';

/**
 * One dashboard figure the workbench contract already holds.
 * A count is not a session the user can start.
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
 * Workbench home state: capability readings and summary counts.
 * No session list, entry cards, or log/command shortcuts.
 */
@ObservedV2
export class WorkbenchViewModel {
  @Trace bluetoothReading: string = RadioSwitchReading.UNREAD;
  @Trace wlanReading: string = RadioSwitchReading.UNREAD;
  @Trace nearlinkReading: string = RadioSwitchReading.UNREAD;
  @Trace activeSessionCount: string = RadioSwitchReading.UNREAD;
  @Trace sessionLogCount: string = RadioSwitchReading.UNREAD;
  @Trace logIndexCount: string = RadioSwitchReading.UNREAD;

  private readonly loadOverview: LoadWorkbenchOverviewUseCase;
  private readonly countLogRows: CountSessionLogRowsUseCase;

  constructor(
    loadOverview: LoadWorkbenchOverviewUseCase = new LoadWorkbenchOverviewUseCase(),
    countLogRows: CountSessionLogRowsUseCase = new CountSessionLogRowsUseCase()
  ) {
    this.loadOverview = loadOverview;
    this.countLogRows = countLogRows;
  }

  bindCapability(bluetooth: string, wlan: string, nearlink: string): void {
    this.bluetoothReading = bluetooth;
    this.wlanReading = wlan;
    this.nearlinkReading = nearlink;
  }

  async refreshCounts(): Promise<void> {
    const listed = this.loadOverview.execute();
    if (!listed.success || listed.value === undefined) {
      this.activeSessionCount = RadioSwitchReading.UNREAD;
      this.sessionLogCount = RadioSwitchReading.UNREAD;
    } else {
      const summaries = listed.value;
      let logCount = 0;
      for (let i = 0; i < summaries.length; i++) {
        logCount += summaries[i].logCount;
      }
      this.activeSessionCount = `${summaries.length}`;
      this.sessionLogCount = `${logCount}`;
    }
    const indexed = await this.countLogRows.execute();
    if (!indexed.success || indexed.value === undefined) {
      this.logIndexCount = RadioSwitchReading.UNREAD;
      return;
    }
    this.logIndexCount = `${indexed.value}`;
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
      ),
      new WorkbenchDashboardFigure(
        'activeSessionCount',
        this.activeSessionCount,
        'LoadWorkbenchOverviewUseCase',
        'SessionRuntimeStore'
      ),
      new WorkbenchDashboardFigure(
        'sessionLogCount',
        this.sessionLogCount,
        'LoadWorkbenchOverviewUseCase',
        'SessionRuntimeStore'
      ),
      new WorkbenchDashboardFigure(
        'logIndexCount',
        this.logIndexCount,
        'CountSessionLogRowsUseCase',
        'SessionLogRepositoryContract'
      )
    ];
  }
}
