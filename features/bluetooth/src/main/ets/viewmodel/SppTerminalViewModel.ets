import { EncodingUtil, Subscription } from 'common_core';
import {
  IncomingPayload,
  LineEndingMode,
  PayloadEncoding,
  TransportSessionRegistry
} from 'debug_core';
import {
  DisconnectSppUseCase,
  ListSppSessionsUseCase,
  ObserveSppSessionsUseCase,
  SendSppCommandUseCase,
  SppSessionDescriptor
} from 'yobluetooth';
import { SppActiveSessionItem } from './SppMainViewModel';

/** 接收区显示模式（PRD §6.3：文本 / HEX / 混合）。 */
export enum SppTerminalDisplayMode {
  TEXT = 0,
  HEX = 1,
  MIXED = 2
}

export type SppTerminalLogKind = 'rx' | 'tx' | 'sys';

/**
 * Structured terminal line — UI colors by kind; text/hex kept for display modes.
 */
export class SppTerminalLogEntry {
  readonly id: string;
  readonly kind: SppTerminalLogKind;
  readonly text: string;
  readonly hex: string;

  constructor(id: string, kind: SppTerminalLogKind, text: string, hex: string) {
    this.id = id;
    this.kind = kind;
    this.text = text;
    this.hex = hex;
  }
}

/**
 * SPP terminal ViewModel — focusSessionId + SessionSwitcher + send/recv.
 * Layout contract mirrors Serial Bluetooth Terminal / nRF Serial Terminal:
 * compact status, full-height log, bottom composer with encoding & line ending.
 */
@ObservedV2
export class SppTerminalViewModel {
  @Trace focusSessionId: string = '';
  @Trace displayName: string = '';
  @Trace classicAddress: string = '';
  @Trace serviceUuid: string = '';
  @Trace uuidShortLabel: string = '';
  @Trace stateLabel: string = '';
  @Trace bytesIn: number = 0;
  @Trace bytesOut: number = 0;
  @Trace logEntries: SppTerminalLogEntry[] = [];
  @Trace draftText: string = '';
  @Trace sending: boolean = false;
  @Trace disconnecting: boolean = false;
  @Trace sendError: string = '';
  @Trace sessions: SppActiveSessionItem[] = [];
  /** 产测 AT^ 默认 TEXT/ASCII；HEX 仅用于原始字节调试。 */
  @Trace sendEncoding: PayloadEncoding = PayloadEncoding.TEXT;
  /** HS01 AT 解析只剥末尾一个 \\r/\\n；无参命令请用 LF 或 CR，勿用 CRLF。 */
  @Trace lineEnding: LineEndingMode = LineEndingMode.LF;
  @Trace displayMode: SppTerminalDisplayMode = SppTerminalDisplayMode.TEXT;
  /** Bumped after append so the page can auto-scroll without watching array identity. */
  @Trace logRevision: number = 0;
  /** Page sets this to scroll the log viewport after each append. */
  logAppendListener: () => void = () => {
  };

  private readonly observeSessions: ObserveSppSessionsUseCase;
  private readonly listSessions: ListSppSessionsUseCase;
  private readonly sendCommand: SendSppCommandUseCase;
  private readonly disconnectSpp: DisconnectSppUseCase;
  private readonly transportRegistry: TransportSessionRegistry;
  private sessionsSubscription: Subscription | undefined;
  private incomingSubscription: Subscription | undefined;
  private logLineLimit: number = 400;
  private logSeq: number = 0;

  constructor(
    observeSessions: ObserveSppSessionsUseCase = new ObserveSppSessionsUseCase(),
    listSessions: ListSppSessionsUseCase = new ListSppSessionsUseCase(),
    sendCommand: SendSppCommandUseCase = new SendSppCommandUseCase(),
    disconnectSpp: DisconnectSppUseCase = new DisconnectSppUseCase(),
    transportRegistry: TransportSessionRegistry = TransportSessionRegistry.getInstance()
  ) {
    this.observeSessions = observeSessions;
    this.listSessions = listSessions;
    this.sendCommand = sendCommand;
    this.disconnectSpp = disconnectSpp;
    this.transportRegistry = transportRegistry;
  }

  bindSessionId(sessionId: string): void {
    this.focusSessionId = sessionId;
  }

  onPageAppear(): void {
    this.sessionsSubscription = this.observeSessions.execute((descriptors: SppSessionDescriptor[]) => {
      this.applySessions(descriptors);
    });
    this.bindIncoming(this.focusSessionId);
  }

  onPageDisappear(): void {
    if (this.sessionsSubscription !== undefined) {
      this.sessionsSubscription.dispose();
      this.sessionsSubscription = undefined;
    }
    this.unbindIncoming();
  }

  /**
   * Switch send/log focus only — does not disconnect other sessions.
   */
  setFocusSession(sessionId: string): void {
    if (sessionId.length === 0 || sessionId === this.focusSessionId) {
      return;
    }
    this.focusSessionId = sessionId;
    this.sendError = '';
    this.clearLog();
    this.bindIncoming(sessionId);
    this.applyFocusFromList();
  }

  setDraftText(text: string): void {
    this.draftText = text;
  }

  setSendEncoding(encoding: PayloadEncoding): void {
    if (encoding !== PayloadEncoding.TEXT && encoding !== PayloadEncoding.HEX) {
      return;
    }
    if (this.sendEncoding === encoding) {
      return;
    }
    this.sendEncoding = encoding;
    this.sendError = '';
  }

  setLineEnding(mode: LineEndingMode): void {
    this.lineEnding = mode;
  }

  setDisplayMode(mode: SppTerminalDisplayMode): void {
    this.displayMode = mode;
  }

  clearLog(): void {
    this.logEntries = [];
    this.logRevision += 1;
  }

  formatLogEntry(entry: SppTerminalLogEntry): string {
    const prefix = SppTerminalViewModel.kindPrefix(entry.kind);
    if (entry.kind === 'sys') {
      return `${prefix}${entry.text}`;
    }
    if (this.displayMode === SppTerminalDisplayMode.HEX) {
      return `${prefix}${entry.hex.length > 0 ? entry.hex : '—'}`;
    }
    if (this.displayMode === SppTerminalDisplayMode.MIXED) {
      const hexPart = entry.hex.length > 0 ? entry.hex : '—';
      const textPart = entry.text.length > 0 ? entry.text : '—';
      return `${prefix}${textPart}  ·  ${hexPart}`;
    }
    return `${prefix}${entry.text}`;
  }

  async send(): Promise<void> {
    if (this.sending || this.focusSessionId.length === 0) {
      return;
    }
    const payload = this.draftText;
    if (payload.length === 0) {
      return;
    }
    this.sending = true;
    this.sendError = '';
    const encoding = this.sendEncoding;
    const result = await this.sendCommand.execute(
      this.focusSessionId,
      payload,
      encoding,
      this.lineEnding
    );
    this.sending = false;
    if (!result.success) {
      const code = result.error?.code ?? '';
      if (encoding === PayloadEncoding.HEX && code === 'YW-CMD-1001') {
        this.sendError = 'HEX 格式无效，请输入偶数位十六进制（可含空格）';
      } else {
        this.sendError = result.error?.message ?? '发送失败';
      }
      return;
    }
    // Log wire preview (payload only; line ending appended on wire by SendCommandUseCase).
    const wirePreview = encoding === PayloadEncoding.HEX ?
      EncodingUtil.hexToBytes(payload.replace(/\s+/g, '')) :
      SppTerminalViewModel.textToAsciiBytes(payload);
    const text = encoding === PayloadEncoding.HEX ?
      EncodingUtil.utf8BytesToString(wirePreview) :
      payload;
    this.appendEntry('tx', text, SppTerminalViewModel.formatHexSpaced(wirePreview));
    this.draftText = '';
  }

  /**
   * Disconnect focus session only; other sessions stay alive. Caller should pop.
   */
  async disconnect(): Promise<void> {
    if (this.disconnecting || this.focusSessionId.length === 0) {
      return;
    }
    this.disconnecting = true;
    const sessionId = this.focusSessionId;
    this.unbindIncoming();
    await this.disconnectSpp.execute(sessionId);
    this.disconnecting = false;
    this.appendEntry('sys', '已断开连接', '');
  }

  private applySessions(descriptors: SppSessionDescriptor[]): void {
    const items: SppActiveSessionItem[] = [];
    for (let i = 0; i < descriptors.length; i++) {
      items.push(SppActiveSessionItem.fromDescriptor(descriptors[i]));
    }
    this.sessions = items;
    if (this.focusSessionId.length === 0 && items.length > 0) {
      this.focusSessionId = items[0].sessionId;
      this.bindIncoming(this.focusSessionId);
    }
    const stillFocused = items.some((item: SppActiveSessionItem) => item.sessionId === this.focusSessionId);
    if (!stillFocused && items.length > 0) {
      this.focusSessionId = items[0].sessionId;
      this.sendError = '';
      this.clearLog();
      this.bindIncoming(this.focusSessionId);
    }
    this.applyFocusFromList(descriptors);
  }

  private applyFocusFromList(descriptors?: SppSessionDescriptor[]): void {
    const list = descriptors ?? this.listSessions.execute();
    for (let i = 0; i < list.length; i++) {
      const descriptor = list[i];
      if (descriptor.sessionId === this.focusSessionId) {
        this.displayName = descriptor.displayName;
        this.classicAddress = descriptor.classicAddress;
        this.serviceUuid = descriptor.serviceUuid;
        this.uuidShortLabel = descriptor.uuidShortLabel;
        this.stateLabel = descriptor.stateLabel;
        this.bytesIn = descriptor.bytesIn;
        this.bytesOut = descriptor.bytesOut;
        return;
      }
    }
  }

  private bindIncoming(sessionId: string): void {
    this.unbindIncoming();
    if (sessionId.length === 0) {
      return;
    }
    const transport = this.transportRegistry.get(sessionId);
    if (transport === undefined) {
      return;
    }
    this.incomingSubscription = transport.observeIncoming().subscribe((payload: IncomingPayload) => {
      if (payload.timestampMs <= 0 || payload.bytes.length === 0) {
        return;
      }
      const text = EncodingUtil.utf8BytesToString(payload.bytes);
      const hex = SppTerminalViewModel.formatHexSpaced(payload.bytes);
      this.appendEntry('rx', text, hex);
    }, false);
  }

  private unbindIncoming(): void {
    if (this.incomingSubscription !== undefined) {
      this.incomingSubscription.dispose();
      this.incomingSubscription = undefined;
    }
  }

  private appendEntry(kind: SppTerminalLogKind, text: string, hex: string): void {
    this.logSeq += 1;
    const next: SppTerminalLogEntry[] = [];
    for (let i = 0; i < this.logEntries.length; i++) {
      next.push(this.logEntries[i]);
    }
    next.push(new SppTerminalLogEntry(`L${this.logSeq}`, kind, text, hex));
    if (next.length > this.logLineLimit) {
      this.logEntries = next.slice(next.length - this.logLineLimit);
    } else {
      this.logEntries = next;
    }
    this.logRevision += 1;
    this.logAppendListener();
  }

  private static kindPrefix(kind: SppTerminalLogKind): string {
    if (kind === 'rx') {
      return 'RX ';
    }
    if (kind === 'tx') {
      return 'TX ';
    }
    return 'SYS ';
  }

  private static textToAsciiBytes(text: string): Uint8Array {
    const bytes = new Uint8Array(text.length);
    for (let i = 0; i < text.length; i++) {
      bytes[i] = text.charCodeAt(i) & 0xFF;
    }
    return bytes;
  }

  private static formatHexSpaced(bytes: Uint8Array): string {
    const compact = EncodingUtil.bytesToHex(bytes);
    if (compact.length <= 2) {
      return compact;
    }
    let spaced = '';
    for (let i = 0; i < compact.length; i += 2) {
      if (i > 0) {
        spaced += ' ';
      }
      spaced += compact.substring(i, i + 2);
    }
    return spaced;
  }
}
