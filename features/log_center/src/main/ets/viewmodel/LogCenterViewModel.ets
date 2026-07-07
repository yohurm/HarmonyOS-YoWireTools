import { EncodingUtil } from 'common_core';
import { common } from '@kit.AbilityKit';
import { AbilityContextRegistry } from 'common_platform';
import {
  ExportFormat,
  LogExportService,
  LogIndexRecord,
  LogQuery,
  LogRepository,
  PreferencesStore
} from 'common_storage';
import { UiPageState } from 'common_ui';
import { LogDirectionFilter } from '../domain/model/LogDirectionFilter';
import { LogCenterFilterUtil } from '../domain/service/LogCenterFilterUtil';

export { LogDirectionFilter } from '../domain/model/LogDirectionFilter';

/**
 * Unified log center ViewModel backed by LogRepository.
 */
@ObservedV2
export class LogCenterViewModel {
  @Trace pageState: UiPageState = UiPageState.LOADING;
  @Trace logs: LogIndexRecord[] = [];
  @Trace selectedSessionId: string = '';
  @Trace sessionOptions: string[] = [];
  @Trace moduleOptions: string[] = [];
  @Trace protocolOptions: string[] = [];
  @Trace selectedModule: string = '';
  @Trace selectedProtocol: string = '';
  @Trace directionFilter: LogDirectionFilter = LogDirectionFilter.ALL;
  @Trace keyword: string = '';
  @Trace expandedLogId: string = '';
  @Trace expandedPayloadText: string = '';
  @Trace expandedPayloadHex: string = '';
  @Trace expandedShowHex: boolean = false;
  @Trace totalCount: number = 0;
  @Trace statusMessage: string = '';
  @Trace exportFormat: ExportFormat = ExportFormat.TXT;
  @Trace exporting: boolean = false;
  @Trace exportStatusMessage: string = '';

  private readonly repository: LogRepository = LogRepository.getInstance();
  private readonly preferencesStore: PreferencesStore = PreferencesStore.getInstance();

  async initialize(): Promise<void> {
    this.pageState = UiPageState.LOADING;
    await this.refresh();
    this.pageState = UiPageState.CONTENT;
  }

  async refresh(): Promise<void> {
    const direction = LogCenterFilterUtil.queryDirection(this.directionFilter);
    const query = new LogQuery(this.selectedSessionId, 0, 100, direction);
    const listed = await this.repository.list(query);
    if (!listed.success || listed.value === undefined) {
      this.statusMessage = listed.error?.message ?? '加载日志失败';
      this.logs = [];
      this.totalCount = 0;
      return;
    }
    this.totalCount = listed.value.total;
    this.logs = LogCenterFilterUtil.applyClientFilters(
      listed.value.items,
      this.selectedModule,
      this.selectedProtocol,
      this.keyword
    );
    this.sessionOptions = LogCenterFilterUtil.collectSessionIds(listed.value.items, this.sessionOptions);
    this.moduleOptions = LogCenterFilterUtil.collectFieldValues(listed.value.items, 'module', this.moduleOptions);
    this.protocolOptions = LogCenterFilterUtil.collectFieldValues(listed.value.items, 'protocol', this.protocolOptions);
    this.statusMessage = LogCenterFilterUtil.buildStatusMessage(this.logs.length, this.totalCount, this.keyword,
      this.selectedModule, this.selectedProtocol);
  }

  async setSessionFilter(sessionId: string): Promise<void> {
    this.selectedSessionId = sessionId;
    this.expandedLogId = '';
    this.pageState = UiPageState.LOADING;
    await this.refresh();
    this.pageState = UiPageState.CONTENT;
  }

  async setDirectionFilter(filter: LogDirectionFilter): Promise<void> {
    this.directionFilter = filter;
    this.expandedLogId = '';
    this.pageState = UiPageState.LOADING;
    await this.refresh();
    this.pageState = UiPageState.CONTENT;
  }

  async setModuleFilter(module: string): Promise<void> {
    this.selectedModule = module;
    this.expandedLogId = '';
    await this.refresh();
  }

  async setProtocolFilter(protocol: string): Promise<void> {
    this.selectedProtocol = protocol;
    this.expandedLogId = '';
    await this.refresh();
  }

  updateKeyword(text: string): void {
    this.keyword = text;
    void this.refresh();
  }

  async toggleLogDetail(logId: string): Promise<void> {
    if (this.expandedLogId === logId) {
      this.expandedLogId = '';
      this.expandedPayloadText = '';
      this.expandedPayloadHex = '';
      this.expandedShowHex = false;
      return;
    }
    this.expandedLogId = logId;
    this.expandedShowHex = false;
    await this.loadExpandedPayload(logId);
  }

  setExpandedShowHex(showHex: boolean): void {
    this.expandedShowHex = showHex;
  }

  isLogExpanded(logId: string): boolean {
    return this.expandedLogId === logId;
  }

  setExportFormat(format: ExportFormat): void {
    this.exportFormat = format;
  }

  async exportLogs(): Promise<void> {
    const context: common.UIAbilityContext | undefined = AbilityContextRegistry.getInstance().get();
    if (context === undefined) {
      this.exportStatusMessage = '应用上下文未就绪，无法导出';
      return;
    }
    this.exporting = true;
    this.exportStatusMessage = '正在导出...';
    const maskAddress = await this.preferencesStore.isExportMaskAddressEnabled();
    const maskHeaders = await this.preferencesStore.isExportMaskHeadersEnabled();
    const options = LogCenterFilterUtil.buildExportOptions(
      this.exportFormat,
      this.selectedSessionId,
      this.directionFilter,
      this.selectedModule,
      this.selectedProtocol,
      this.keyword,
      maskAddress,
      maskHeaders
    );
    const service = new LogExportService(context);
    const result = await service.exportLogs(options);
    this.exporting = false;
    if (!result.success || result.value === undefined) {
      this.exportStatusMessage = result.error?.message ?? '导出失败';
      return;
    }
    this.exportStatusMessage = `已导出至 ${result.value}`;
  }

  sessionLabel(sessionId: string): string {
    return LogCenterFilterUtil.sessionLabel(sessionId);
  }

  directionLabel(filter: LogDirectionFilter): string {
    switch (filter) {
      case LogDirectionFilter.INBOUND:
        return '入站';
      case LogDirectionFilter.OUTBOUND:
        return '出站';
      default:
        return '全部方向';
    }
  }

  exportFormatLabel(format: ExportFormat): string {
    switch (format) {
      case ExportFormat.CSV:
        return 'CSV';
      case ExportFormat.JSON:
        return 'JSON';
      default:
        return 'TXT';
    }
  }

  private async loadExpandedPayload(logId: string): Promise<void> {
    const record = this.findLogById(logId);
    if (record === undefined) {
      this.expandedPayloadText = '';
      this.expandedPayloadHex = '';
      return;
    }
    const fallback = `${record.summary}\n${record.displayHint}`.trim();
    if (record.payloadRef === undefined) {
      this.expandedPayloadText = fallback;
      this.expandedPayloadHex = '';
      return;
    }
    const payloadResult = await this.repository.getPayload(record.payloadRef);
    if (!payloadResult.success || payloadResult.value === undefined) {
      this.expandedPayloadText = fallback.length > 0 ? fallback : '无法加载原始 payload';
      this.expandedPayloadHex = '';
      return;
    }
    this.expandedPayloadHex = EncodingUtil.bytesToHex(payloadResult.value);
    this.expandedPayloadText = EncodingUtil.utf8BytesToString(payloadResult.value);
    if (this.expandedPayloadText.length === 0 && fallback.length > 0) {
      this.expandedPayloadText = fallback;
    }
  }

  private findLogById(logId: string): LogIndexRecord | undefined {
    for (let i = 0; i < this.logs.length; i++) {
      if (this.logs[i].id === logId) {
        return this.logs[i];
      }
    }
    return undefined;
  }
}
