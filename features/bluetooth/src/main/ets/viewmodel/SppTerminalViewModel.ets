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
} from 'yo_bluetooth';
import { SppActiveSessionItem } from './SppMainViewModel';

/**
 * SPP terminal ViewModel — focusSessionId + SessionSwitcher + send/recv.
 */
@ObservedV2
export class SppTerminalViewModel {
  @Trace focusSessionId: string = '';
  @Trace displayName: string = '';
  @Trace classicAddress: string = '';
  @Trace uuidShortLabel: string = '';
  @Trace stateLabel: string = '';
  @Trace bytesIn: number = 0;
  @Trace bytesOut: number = 0;
  @Trace logText: string = '';
  @Trace draftText: string = '';
  @Trace sending: boolean = false;
  @Trace disconnecting: boolean = false;
  @Trace sendError: string = '';
  @Trace sessions: SppActiveSessionItem[] = [];

  private readonly observeSessions: ObserveSppSessionsUseCase;
  private readonly listSessions: ListSppSessionsUseCase;
  private readonly sendCommand: SendSppCommandUseCase;
  private readonly disconnectSpp: DisconnectSppUseCase;
  private readonly transportRegistry: TransportSessionRegistry;
  private sessionsSubscription: Subscription | undefined;
  private incomingSubscription: Subscription | undefined;
  private logLineLimit: number = 400;

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

  clearLog(): void {
    this.logText = '';
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
    const result = await this.sendCommand.execute(
      this.focusSessionId,
      payload,
      PayloadEncoding.TEXT,
      LineEndingMode.LF
    );
    this.sending = false;
    if (!result.success) {
      this.sendError = result.error?.message ?? 'send failed';
      return;
    }
    this.appendLogLine(`TX ${payload}`);
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
    this.appendLogLine('SYS disconnected');
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
      this.appendLogLine(`RX ${text}`);
    }, false);
  }

  private unbindIncoming(): void {
    if (this.incomingSubscription !== undefined) {
      this.incomingSubscription.dispose();
      this.incomingSubscription = undefined;
    }
  }

  private appendLogLine(line: string): void {
    if (this.logText.length === 0) {
      this.logText = line;
      return;
    }
    const next = `${this.logText}\n${line}`;
    const lines = next.split('\n');
    if (lines.length > this.logLineLimit) {
      this.logText = lines.slice(lines.length - this.logLineLimit).join('\n');
      return;
    }
    this.logText = next;
  }
}
