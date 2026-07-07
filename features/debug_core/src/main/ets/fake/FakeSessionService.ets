import { EncodingUtil, Result } from 'common_core';
import {
  AppMode,
  Direction,
  ModuleType,
  ProtocolType,
  SessionType
} from '../domain/enums/DomainEnums';
import { CreateSessionInput } from '../domain/model/DebugSession';
import { FakeTransportSession } from '../transport/FakeTransportSession';
import { SessionManager } from '../service/SessionManager';
import { AppendLogUseCase } from '../usecase/CommandUseCases';

/**
 * Phase 0 helpers: fake session + fake log for skeleton acceptance.
 */
export class FakeSessionService {
  private readonly sessionManager: SessionManager;
  private readonly appendLog: AppendLogUseCase;
  private readonly transports: Map<string, FakeTransportSession> = new Map();

  constructor(
    sessionManager: SessionManager = SessionManager.getInstance(),
    appendLog: AppendLogUseCase = new AppendLogUseCase()
  ) {
    this.sessionManager = sessionManager;
    this.appendLog = appendLog;
  }

  async createFakeConnectionSession(displayName: string = 'Fake SPP Session'): Promise<Result<string>> {
    const input = new CreateSessionInput(
      SessionType.CONNECTION,
      ModuleType.BLUETOOTH,
      ProtocolType.SPP,
      displayName,
      AppMode.EXPERT
    );
    const created = await this.sessionManager.createSession(input);
    if (!created.success || created.value === undefined) {
      return Result.fail(created.error!);
    }
    const started = await this.sessionManager.startSession(created.value.id);
    if (!started.success) {
      return Result.fail(started.error!);
    }
    const transport = new FakeTransportSession(created.value.id, ModuleType.BLUETOOTH, ProtocolType.SPP);
    await transport.connect({});
    this.transports.set(created.value.id, transport);
    return Result.ok(created.value.id);
  }

  async appendFakeInboundLog(sessionId: string, text: string): Promise<Result<void>> {
    const transport = this.transports.get(sessionId);
    const bytes = EncodingUtil.stringToUtf8Bytes(text);
    if (transport !== undefined) {
      transport.emitIncoming(bytes);
    }
    const logged = await this.appendLog.execute(
      sessionId,
      ModuleType.BLUETOOTH,
      ProtocolType.SPP,
      Direction.INBOUND,
      bytes
    );
    if (!logged.success) {
      return Result.fail(logged.error!);
    }
    return Result.ok(undefined);
  }

  getFakeTransport(sessionId: string): FakeTransportSession | undefined {
    return this.transports.get(sessionId);
  }
}
