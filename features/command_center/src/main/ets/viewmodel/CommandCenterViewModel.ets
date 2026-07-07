import { IdGenerator, TimeUtil } from 'common_core';
import { CommandHistoryRecord, CommandRepository, CommandTemplateRecord } from 'common_storage';
import {
  DebugSessionSummary,
  LineEndingMode,
  PayloadEncoding,
  RepeatCommandCoordinator,
  RepeatPolicy,
  SendCommandInput,
  SendCommandUseCase,
  SessionRuntimeStore,
  StartRepeatCommandUseCase,
  StopRepeatCommandUseCase,
  TransportSessionRegistry,
  WriteMode
} from 'feature_debug_core';
import { UiPageState } from 'common_ui';

export class ActiveSessionOption {
  readonly id: string;
  readonly label: string;

  constructor(id: string, label: string) {
    this.id = id;
    this.label = label;
  }
}

/**
 * Command center ViewModel: templates, payload input, send to active session.
 */
@ObservedV2
export class CommandCenterViewModel {
  @Trace pageState: UiPageState = UiPageState.LOADING;
  @Trace templates: CommandTemplateRecord[] = [];
  @Trace history: CommandHistoryRecord[] = [];
  @Trace historyTotalCount: number = 0;
  @Trace activeSessionOptions: ActiveSessionOption[] = [];
  @Trace selectedSessionId: string = '';
  @Trace selectedTemplateId: string = '';
  @Trace payloadText: string = '';
  @Trace templateNameText: string = '';
  @Trace repeatIntervalMsText: string = '1000';
  @Trace repeating: boolean = false;
  @Trace statusMessage: string = '';
  @Trace sending: boolean = false;

  private static readonly REPEAT_JOB_PREFIX: string = 'command-center-repeat-';

  private readonly commandRepository: CommandRepository = CommandRepository.getInstance();
  private readonly sendCommand: SendCommandUseCase = new SendCommandUseCase();
  private readonly startRepeat: StartRepeatCommandUseCase = new StartRepeatCommandUseCase();
  private readonly stopRepeat: StopRepeatCommandUseCase = new StopRepeatCommandUseCase();
  private readonly repeatCoordinator: RepeatCommandCoordinator = RepeatCommandCoordinator.getInstance();
  private readonly transportRegistry: TransportSessionRegistry = TransportSessionRegistry.getInstance();
  private readonly runtimeStore: SessionRuntimeStore = SessionRuntimeStore.getInstance();

  async initialize(): Promise<void> {
    this.pageState = UiPageState.LOADING;
    await this.refresh();
    this.pageState = UiPageState.CONTENT;
  }

  async refresh(): Promise<void> {
    await this.loadTemplates();
    await this.loadHistory();
    this.refreshActiveSessions();
    this.syncRepeatState();
    this.statusMessage =
      `${this.templates.length} 个模板 · ${this.activeSessionOptions.length} 个可发送会话 · ${this.historyTotalCount} 条历史`;
  }

  selectTemplate(templateId: string): void {
    this.selectedTemplateId = templateId;
    for (let i = 0; i < this.templates.length; i++) {
      if (this.templates[i].id === templateId) {
        this.payloadText = this.templates[i].payload;
        break;
      }
    }
  }

  selectSession(sessionId: string): void {
    this.selectedSessionId = sessionId;
    this.syncRepeatState();
    void this.loadHistory();
  }

  applyHistory(history: CommandHistoryRecord): void {
    this.payloadText = history.payload;
    if (history.templateId.length > 0) {
      this.selectedTemplateId = history.templateId;
    }
    this.statusMessage = '已从历史记录填充载荷';
  }

  updatePayload(text: string): void {
    this.payloadText = text;
  }

  updateTemplateName(text: string): void {
    this.templateNameText = text;
  }

  async saveCurrentTemplate(): Promise<void> {
    const name = this.templateNameText.trim();
    if (name.length === 0) {
      this.statusMessage = '请输入模板名称';
      return;
    }
    if (this.payloadText.trim().length === 0) {
      this.statusMessage = '请先输入要保存的载荷内容';
      return;
    }
    const session = this.runtimeStore.getSession(this.selectedSessionId);
    const transport = this.transportRegistry.get(this.selectedSessionId);
    const module = session?.module ?? transport?.module ?? 'system';
    const protocol = session?.protocol ?? transport?.protocol ?? 'none';
    const encoding = CommandCenterViewModel.resolveEncoding(this.selectedTemplateId, this.templates);
    const lineEnding = CommandCenterViewModel.resolveLineEnding(this.selectedTemplateId, this.templates);
    const now = TimeUtil.nowMs();
    const record = new CommandTemplateRecord(
      IdGenerator.next('cmd_tpl'),
      name,
      module,
      protocol,
      encoding,
      this.payloadText,
      lineEnding,
      WriteMode.ONCE,
      '{}',
      0,
      '[]',
      now,
      now
    );
    const saved = await this.commandRepository.saveTemplate(record);
    if (!saved.success) {
      this.statusMessage = saved.error?.message ?? '保存模板失败';
      return;
    }
    this.templateNameText = '';
    await this.loadTemplates();
    this.selectedTemplateId = record.id;
    this.statusMessage = `模板「${name}」已保存`;
  }

  updateRepeatInterval(text: string): void {
    this.repeatIntervalMsText = text;
  }

  async sendToActiveSession(): Promise<void> {
    const input = this.buildSendInput();
    if (input === undefined) {
      return;
    }

    this.sending = true;
    const result = await this.sendCommand.execute(input);
    this.sending = false;

    await this.appendHistoryRecord(result.success, result.error?.message ?? '');
    await this.loadHistory();

    if (!result.success) {
      this.statusMessage = result.error?.message ?? '发送失败';
      return;
    }
    this.statusMessage = '命令已发送';
  }

  async startRepeatSend(): Promise<void> {
    if (this.selectedSessionId.length === 0) {
      this.statusMessage = '请先选择活跃会话';
      return;
    }
    const intervalMs = CommandCenterViewModel.parseIntervalMs(this.repeatIntervalMsText);
    if (intervalMs <= 0) {
      this.statusMessage = '重复间隔须为正整数（毫秒）';
      return;
    }
    const input = this.buildSendInput();
    if (input === undefined) {
      return;
    }
    const policy = new RepeatPolicy(intervalMs, 0, 0, true, false);
    const jobId = CommandCenterViewModel.repeatJobId(this.selectedSessionId);
    const started = await this.startRepeat.execute(jobId, input, policy);
    if (!started.success) {
      this.statusMessage = started.error?.message ?? '启动重复发送失败';
      this.repeating = false;
      return;
    }
    this.repeating = true;
    this.statusMessage = `重复发送已启动，间隔 ${intervalMs} ms`;
  }

  stopRepeatSend(): void {
    if (this.selectedSessionId.length === 0) {
      return;
    }
    const jobId = CommandCenterViewModel.repeatJobId(this.selectedSessionId);
    this.stopRepeat.execute(jobId);
    this.repeating = false;
    this.statusMessage = '重复发送已停止';
  }

  historyResultOk(resultJson: string): boolean {
    return resultJson.includes('"ok":true');
  }

  private buildSendInput(): SendCommandInput | undefined {
    if (this.selectedSessionId.length === 0) {
      this.statusMessage = '请先选择活跃会话';
      return undefined;
    }
    if (this.payloadText.trim().length === 0) {
      this.statusMessage = '请输入要发送的内容';
      return undefined;
    }
    const transport = this.transportRegistry.get(this.selectedSessionId);
    if (transport === undefined) {
      this.statusMessage = '当前会话没有可用传输通道';
      return undefined;
    }
    const encoding = CommandCenterViewModel.resolveEncoding(this.selectedTemplateId, this.templates);
    const lineEnding = CommandCenterViewModel.resolveLineEnding(this.selectedTemplateId, this.templates);
    return new SendCommandInput(
      this.selectedSessionId,
      transport,
      this.payloadText,
      encoding,
      lineEnding
    );
  }

  private async appendHistoryRecord(success: boolean, errorMessage: string): Promise<void> {
    const transport = this.transportRegistry.get(this.selectedSessionId);
    const session = this.runtimeStore.getSession(this.selectedSessionId);
    const history = new CommandHistoryRecord(
      IdGenerator.next('cmd_hist'),
      this.selectedTemplateId,
      this.selectedSessionId,
      session?.module ?? transport?.module ?? '',
      session?.protocol ?? transport?.protocol ?? '',
      this.payloadText,
      CommandCenterViewModel.resolveEncoding(this.selectedTemplateId, this.templates),
      TimeUtil.nowMs(),
      success ? '{"ok":true}' : `{"ok":false,"message":"${errorMessage}"}`
    );
    await this.commandRepository.appendHistory(history);
  }

  private async loadTemplates(): Promise<void> {
    const listed = await this.commandRepository.listTemplates(0, 50);
    if (!listed.success || listed.value === undefined) {
      this.templates = [];
      this.statusMessage = listed.error?.message ?? '加载模板失败';
      return;
    }
    this.templates = listed.value.items;
  }

  private async loadHistory(): Promise<void> {
    const sessionFilter = this.selectedSessionId.length > 0 ? this.selectedSessionId : '';
    const listed = await this.commandRepository.listHistory(0, 30, sessionFilter);
    if (!listed.success || listed.value === undefined) {
      this.history = [];
      this.historyTotalCount = 0;
      return;
    }
    this.history = listed.value.items;
    this.historyTotalCount = listed.value.total;
  }

  private refreshActiveSessions(): void {
    const summaries: DebugSessionSummary[] = this.runtimeStore.listActiveSummaries();
    const options: ActiveSessionOption[] = [];
    for (let i = 0; i < summaries.length; i++) {
      const summary = summaries[i];
      if (this.transportRegistry.get(summary.id) !== undefined) {
        options.push(new ActiveSessionOption(summary.id, `${summary.displayName} (${summary.protocol})`));
      }
    }
    this.activeSessionOptions = options;
    if (this.selectedSessionId.length === 0 && options.length > 0) {
      this.selectedSessionId = options[0].id;
    } else if (this.selectedSessionId.length > 0 &&
      !CommandCenterViewModel.containsOption(options, this.selectedSessionId)) {
      this.selectedSessionId = options.length > 0 ? options[0].id : '';
    }
  }

  private syncRepeatState(): void {
    if (this.selectedSessionId.length === 0) {
      this.repeating = false;
      return;
    }
    this.repeating = this.repeatCoordinator.isRunning(CommandCenterViewModel.repeatJobId(this.selectedSessionId));
  }

  private static repeatJobId(sessionId: string): string {
    return `${CommandCenterViewModel.REPEAT_JOB_PREFIX}${sessionId}`;
  }

  private static parseIntervalMs(text: string): number {
    const parsed = Number.parseInt(text.trim(), 10);
    if (Number.isNaN(parsed)) {
      return 0;
    }
    return parsed;
  }

  private static containsOption(options: ActiveSessionOption[], sessionId: string): boolean {
    for (let i = 0; i < options.length; i++) {
      if (options[i].id === sessionId) {
        return true;
      }
    }
    return false;
  }

  private static resolveEncoding(
    templateId: string,
    templates: CommandTemplateRecord[]
  ): PayloadEncoding {
    for (let i = 0; i < templates.length; i++) {
      if (templates[i].id === templateId) {
        if (templates[i].payloadEncoding === PayloadEncoding.HEX) {
          return PayloadEncoding.HEX;
        }
        if (templates[i].payloadEncoding === PayloadEncoding.BASE64) {
          return PayloadEncoding.BASE64;
        }
        return PayloadEncoding.TEXT;
      }
    }
    return PayloadEncoding.TEXT;
  }

  private static resolveLineEnding(
    templateId: string,
    templates: CommandTemplateRecord[]
  ): LineEndingMode {
    for (let i = 0; i < templates.length; i++) {
      if (templates[i].id === templateId) {
        switch (templates[i].lineEnding) {
          case LineEndingMode.NONE:
            return LineEndingMode.NONE;
          case LineEndingMode.CR:
            return LineEndingMode.CR;
          case LineEndingMode.CRLF:
            return LineEndingMode.CRLF;
          default:
            return LineEndingMode.LF;
        }
      }
    }
    return LineEndingMode.LF;
  }
}
