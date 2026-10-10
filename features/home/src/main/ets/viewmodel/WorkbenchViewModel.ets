import { DebugSessionSummary, LoadWorkbenchOverviewUseCase } from 'debug_core';

@ObservedV2
export class WorkbenchViewModel {
  @Trace sessions: DebugSessionSummary[] = [];
  private readonly loadOverview: LoadWorkbenchOverviewUseCase;

  constructor(loadOverview: LoadWorkbenchOverviewUseCase = new LoadWorkbenchOverviewUseCase()) {
    this.loadOverview = loadOverview;
  }

  refresh(): void {
    const listed = this.loadOverview.execute();
    if (!listed.success || listed.value === undefined) {
      this.sessions = [];
      return;
    }
    this.sessions = listed.value;
  }
}
