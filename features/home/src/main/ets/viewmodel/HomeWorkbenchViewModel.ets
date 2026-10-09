import { Subscription } from 'common_core';
import { LifecycleCoordinator, PermissionStatus } from 'common_platform';
import {
  DebugSessionSummary,
  LoadWorkbenchOverviewUseCase,
  PermissionScenario,
  PermissionScenarioCoordinator,
  SessionState
} from 'debug_core';
import { HomeSessionTarget } from '../domain/HomeSessionTarget';

export class HomeSessionRow {
  readonly id: string;
  readonly title: string;
  readonly protocol: string;
  readonly state: SessionState;
  readonly target: string;

  constructor(id: string, title: string, protocol: string, state: SessionState, target: string) {
    this.id = id;
    this.title = title;
    this.protocol = protocol;
    this.state = state;
    this.target = target;
  }
}

@ObservedV2
export class HomeWorkbenchViewModel {
  @Trace hasLoaded: boolean = false;
  @Trace loadFailed: boolean = false;
  @Trace sessions: HomeSessionRow[] = [];
  @Trace bluetoothGranted: boolean = false;
  @Trace wifiGranted: boolean = false;
  @Trace nearlinkGranted: boolean = false;

  private readonly loadOverview: LoadWorkbenchOverviewUseCase;
  private readonly coordinator: PermissionScenarioCoordinator;
  private sessionSubscription: Subscription | undefined;
  private lifecycleUnsubscribe: (() => void) | undefined;

  constructor(
    loadOverview: LoadWorkbenchOverviewUseCase = new LoadWorkbenchOverviewUseCase(),
    coordinator: PermissionScenarioCoordinator = PermissionScenarioCoordinator.getInstance()
  ) {
    this.loadOverview = loadOverview;
    this.coordinator = coordinator;
  }

  async onPageAppear(): Promise<void> {
    this.sessionSubscription = this.loadOverview.subscribe((summaries: DebugSessionSummary[]) => {
      this.sessions = HomeWorkbenchViewModel.toRows(summaries);
    });
    this.lifecycleUnsubscribe = LifecycleCoordinator.getInstance().addReconcileCallback(async () => {
      await this.refresh();
    });
    await this.refresh();
  }

  onPageDisappear(): void {
    if (this.sessionSubscription !== undefined) {
      this.sessionSubscription.dispose();
      this.sessionSubscription = undefined;
    }
    if (this.lifecycleUnsubscribe !== undefined) {
      this.lifecycleUnsubscribe();
      this.lifecycleUnsubscribe = undefined;
    }
  }

  async refresh(): Promise<void> {
    const loaded = this.loadOverview.execute();
    if (!loaded.success || loaded.value === undefined) {
      this.loadFailed = true;
      this.hasLoaded = true;
      return;
    }
    this.loadFailed = false;
    this.sessions = HomeWorkbenchViewModel.toRows(loaded.value);
    this.bluetoothGranted = await this.isScenarioGranted(PermissionScenario.BLUETOOTH_SCAN_CONNECT);
    this.wifiGranted = await this.isScenarioGranted(PermissionScenario.WIFI_INFO);
    this.nearlinkGranted = await this.isScenarioGranted(PermissionScenario.NEARLINK_ACCESS);
    this.hasLoaded = true;
  }

  private async isScenarioGranted(scenario: PermissionScenario): Promise<boolean> {
    const state = await this.coordinator.buildUiStateForScenario(scenario);
    return HomeWorkbenchViewModel.areGranted(state.statuses);
  }

  private static areGranted(statuses: PermissionStatus[]): boolean {
    if (statuses.length === 0) {
      return false;
    }
    for (let i = 0; i < statuses.length; i++) {
      if (statuses[i] !== PermissionStatus.GRANTED) {
        return false;
      }
    }
    return true;
  }

  private static toRows(summaries: DebugSessionSummary[]): HomeSessionRow[] {
    const rows: HomeSessionRow[] = [];
    for (let i = 0; i < summaries.length; i++) {
      const item = summaries[i];
      rows.push(new HomeSessionRow(
        item.id,
        HomeSessionTarget.visibleTitle(item.displayName),
        item.protocol,
        item.state,
        HomeSessionTarget.resolve(item.module, item.protocol)
      ));
    }
    return rows;
  }
}
