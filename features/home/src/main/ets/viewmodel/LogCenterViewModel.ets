import {
  ClearSessionLogUseCase,
  ExportSessionLogUseCase,
  FeatureModuleId,
  LoadSessionLogPreviewUseCase,
  SessionLogQuery,
  WorkbenchLogLine
} from 'debug_core';

@ObservedV2
export class LogCenterViewModel {
  @Trace lines: WorkbenchLogLine[] = [];
  @Trace moduleFilter: string = '';
  @Trace keyword: string = '';
  @Trace failed: boolean = false;
  @Trace confirmingClear: boolean = false;
  @Trace exported: boolean = false;
  private readonly loadPreview: LoadSessionLogPreviewUseCase;
  private readonly exportLog: ExportSessionLogUseCase;
  private readonly clearLog: ClearSessionLogUseCase;

  constructor(
    loadPreview: LoadSessionLogPreviewUseCase = new LoadSessionLogPreviewUseCase(),
    exportLog: ExportSessionLogUseCase = new ExportSessionLogUseCase(),
    clearLog: ClearSessionLogUseCase = new ClearSessionLogUseCase()
  ) {
    this.loadPreview = loadPreview;
    this.exportLog = exportLog;
    this.clearLog = clearLog;
  }

  moduleValues(): string[] {
    return ['', FeatureModuleId.BLUETOOTH, FeatureModuleId.WIFI, FeatureModuleId.NEARLINK];
  }

  async refresh(): Promise<void> {
    const query = new SessionLogQuery('', 0, 100, '', '', 0, 0, this.moduleFilter, this.keyword.trim());
    const listed = await this.loadPreview.execute(query);
    if (!listed.success || listed.value === undefined) {
      this.failed = true;
      this.lines = [];
      return;
    }
    this.failed = false;
    this.lines = listed.value;
  }

  setModule(module: string): void {
    this.moduleFilter = module;
    void this.refresh();
  }

  setKeyword(keyword: string): void {
    this.keyword = keyword;
    void this.refresh();
  }

  askClear(): void {
    this.confirmingClear = true;
  }

  cancelClear(): void {
    this.confirmingClear = false;
  }

  async confirmClear(): Promise<void> {
    this.confirmingClear = false;
    const clearAll = this.moduleFilter.length === 0 && this.keyword.trim().length === 0;
    const cleared = await this.clearLog.execute(this.lines, clearAll);
    this.failed = !cleared.success;
    if (cleared.success) {
      await this.refresh();
    }
  }

  async exportCurrent(): Promise<void> {
    const exported = await this.exportLog.execute(this.moduleFilter, this.keyword.trim());
    this.failed = !exported.success;
    this.exported = exported.success;
  }
}
