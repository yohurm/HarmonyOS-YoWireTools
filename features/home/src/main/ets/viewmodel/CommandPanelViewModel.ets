import {
  CommandTemplate,
  ExecuteModuleCommandUseCase,
  LineEndingMode,
  ListModuleCommandTemplatesUseCase,
  ReadCommandRepeatPolicyUseCase,
  RepeatModuleCommandUseCase,
  SaveCommandRepeatPolicyUseCase,
  SaveModuleCommandTemplateUseCase,
  ShellCommandCodes
} from 'debug_core';

@ObservedV2
export class CommandPanelViewModel {
  @Trace templates: CommandTemplate[] = [];
  @Trace selectedId: string = '';
  @Trace repeatAllowed: boolean = false;
  @Trace creating: boolean = false;
  @Trace draftName: string = '';
  @Trace draftPayload: string = '';
  @Trace draftLineEnding: string = LineEndingMode.LF;
  @Trace saved: boolean = false;
  @Trace ran: boolean = false;
  @Trace failedCode: string = '';
  @Trace confirmingStop: boolean = false;
  @Trace repeating: boolean = false;
  private readonly listTemplates: ListModuleCommandTemplatesUseCase;
  private readonly saveTemplate: SaveModuleCommandTemplateUseCase;
  private readonly executeOnce: ExecuteModuleCommandUseCase;
  private readonly repeatCommand: RepeatModuleCommandUseCase;
  private readonly readRepeat: ReadCommandRepeatPolicyUseCase;
  private readonly saveRepeat: SaveCommandRepeatPolicyUseCase;

  constructor(
    listTemplates: ListModuleCommandTemplatesUseCase,
    saveTemplate: SaveModuleCommandTemplateUseCase,
    executeOnce: ExecuteModuleCommandUseCase,
    repeatCommand: RepeatModuleCommandUseCase,
    readRepeat: ReadCommandRepeatPolicyUseCase = new ReadCommandRepeatPolicyUseCase(),
    saveRepeat: SaveCommandRepeatPolicyUseCase = new SaveCommandRepeatPolicyUseCase()
  ) {
    this.listTemplates = listTemplates;
    this.saveTemplate = saveTemplate;
    this.executeOnce = executeOnce;
    this.repeatCommand = repeatCommand;
    this.readRepeat = readRepeat;
    this.saveRepeat = saveRepeat;
  }

  async refresh(): Promise<void> {
    const policy = await this.readRepeat.execute();
    this.repeatAllowed = policy.success && policy.value === true;
    const listed = await this.listTemplates.execute();
    if (!listed.success || listed.value === undefined) {
      this.templates = [];
      return;
    }
    this.templates = listed.value.items;
    if (this.selectedId.length > 0) {
      this.repeating = this.repeatCommand.isRunning(this.selectedId);
    }
  }

  favorites(): CommandTemplate[] {
    const items: CommandTemplate[] = [];
    for (let i = 0; i < this.templates.length; i++) {
      if (this.templates[i].favorite) {
        items.push(this.templates[i]);
      }
    }
    return items;
  }

  selectedPayload(): string {
    const template = this.selected();
    return template !== undefined ? template.payload : '';
  }

  selected(): CommandTemplate | undefined {
    for (let i = 0; i < this.templates.length; i++) {
      if (this.templates[i].id === this.selectedId) {
        return this.templates[i];
      }
    }
    return undefined;
  }

  select(id: string): void {
    this.selectedId = id;
    this.ran = false;
    this.failedCode = '';
    this.saved = false;
    this.repeating = this.repeatCommand.isRunning(id);
  }

  startCreate(): void {
    this.creating = true;
    this.saved = false;
  }

  cycleLineEnding(): void {
    const current = this.draftLineEnding;
    if (current === LineEndingMode.LF) {
      this.draftLineEnding = LineEndingMode.CR;
      return;
    }
    if (current === LineEndingMode.CR) {
      this.draftLineEnding = LineEndingMode.CRLF;
      return;
    }
    if (current === LineEndingMode.CRLF) {
      this.draftLineEnding = LineEndingMode.NONE;
      return;
    }
    this.draftLineEnding = LineEndingMode.LF;
  }

  lineEndingMode(): LineEndingMode {
    if (this.draftLineEnding === LineEndingMode.CR) {
      return LineEndingMode.CR;
    }
    if (this.draftLineEnding === LineEndingMode.CRLF) {
      return LineEndingMode.CRLF;
    }
    if (this.draftLineEnding === LineEndingMode.NONE) {
      return LineEndingMode.NONE;
    }
    return LineEndingMode.LF;
  }

  async toggleRepeat(): Promise<void> {
    const saved = await this.saveRepeat.execute(!this.repeatAllowed);
    if (!saved.success) {
      this.failedCode = 'YW-CMD-1003';
      return;
    }
    this.failedCode = '';
    await this.refresh();
  }

  async saveDraft(favorite: boolean): Promise<void> {
    const saved = await this.saveTemplate.execute(this.draftName, this.draftPayload, favorite, this.lineEndingMode());
    if (!saved.success || saved.value === undefined) {
      this.failedCode = 'YW-CMD-1003';
      this.saved = false;
      return;
    }
    this.saved = true;
    this.creating = false;
    this.draftName = '';
    this.draftPayload = '';
    this.draftLineEnding = LineEndingMode.LF;
    this.failedCode = '';
    await this.refresh();
    this.select(saved.value.id);
  }

  async runOnce(): Promise<void> {
    const template = this.selected();
    if (template === undefined) {
      return;
    }
    const sent = await this.executeOnce.execute(template);
    this.ran = sent.success;
    this.failedCode = sent.success ? '' : (sent.error !== undefined ? sent.error.code : ShellCommandCodes.NO_TRANSPORT);
  }

  async startRepeat(): Promise<void> {
    const template = this.selected();
    if (template === undefined || !this.repeatAllowed) {
      this.failedCode = ShellCommandCodes.REPEAT_DISABLED;
      return;
    }
    const started = await this.repeatCommand.start(template, 1000);
    this.repeating = started.success;
    this.failedCode = started.success ? '' : (started.error !== undefined ? started.error.code : ShellCommandCodes.REPEAT_DISABLED);
  }

  askStop(): void {
    this.confirmingStop = true;
  }

  cancelStop(): void {
    this.confirmingStop = false;
  }

  confirmStop(): void {
    this.confirmingStop = false;
    if (this.selectedId.length > 0) {
      this.repeatCommand.stop(this.selectedId);
    }
    this.repeating = false;
  }

  failureText(): ResourceStr {
    if (this.failedCode === ShellCommandCodes.NO_TRANSPORT) {
      return $r('app.string.command_no_session');
    }
    if (this.failedCode === ShellCommandCodes.REPEAT_DISABLED) {
      return $r('app.string.command_repeat_off');
    }
    if (this.failedCode.length > 0) {
      return $r('app.string.command_failed');
    }
    return '';
  }
}
