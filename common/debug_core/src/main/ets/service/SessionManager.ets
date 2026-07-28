import { IdGenerator, Observable, Result, ResultError, TimeUtil } from 'common_core';
import { SessionRepository } from 'common_storage';
import {
  BackgroundPolicyAdvisor,
  LifecycleCoordinator,
  PlatformBackgroundSessionKind,
  PlatformEvent,
  PlatformEventType
} from 'common_platform';
import { YoLog, YoLogTag, LogParams } from 'yolog';
import {
  BackgroundPolicyCatalog,
  BackgroundSessionAction,
  BackgroundSessionCategory
} from '../capability/BackgroundPolicyCatalog';
import {
  SessionState,
  SessionType
} from '../domain/enums/DomainEnums';
import { CreateSessionInput, DebugSession } from '../domain/model/DebugSession';
import { DebugError } from '../domain/model/DebugError';
import { DebugEvent } from '../domain/model/DebugEvent';
import { SessionResult } from '../domain/model/SessionResult';
import { SessionMapper } from '../mapper/SessionMapper';
import { DebugSessionState, DebugSessionSummary, SessionStatePatch } from '../runtime/DebugSessionState';
import { SessionRuntimeStore } from '../runtime/SessionRuntimeStore';
import { SessionStateMachine } from '../runtime/SessionStateMachine';
import { LogCaptureService } from './LogCaptureService';

const logger = YoLog.tag(YoLogTag.SESSION);

/**
 * Session lifecycle orchestrator per architecture §3.4.
 */
export class SessionManager {
  private static instance: SessionManager | undefined;
  private readonly runtimeStore: SessionRuntimeStore;
  private readonly sessionRepository: SessionRepository;
  private readonly logCapture: LogCaptureService;
  private lifecycleUnsubscribe: (() => void) | undefined;

  private constructor(
    runtimeStore: SessionRuntimeStore = SessionRuntimeStore.getInstance(),
    sessionRepository: SessionRepository = SessionRepository.getInstance(),
    logCapture: LogCaptureService = LogCaptureService.getInstance()
  ) {
    this.runtimeStore = runtimeStore;
    this.sessionRepository = sessionRepository;
    this.logCapture = logCapture;
  }

  static getInstance(): SessionManager {
    if (SessionManager.instance === undefined) {
      SessionManager.instance = new SessionManager();
    }
    return SessionManager.instance;
  }

  bindLifecycle(): void {
    if (this.lifecycleUnsubscribe !== undefined) {
      return;
    }
    this.lifecycleUnsubscribe = LifecycleCoordinator.getInstance().addListener((event: PlatformEvent) => {
      this.onPlatformEvent(event);
    });
  }

  async createSession(input: CreateSessionInput): Promise<Result<DebugSession>> {
    const session = new DebugSession(
      IdGenerator.next('sess'),
      input.type,
      input.module,
      input.protocol,
      input.displayName,
      input.mode,
      SessionState.CREATED,
      TimeUtil.nowMs(),
      0,
      input.target,
      undefined,
      undefined,
      input.tags,
      input.attributes
    );
    const saved = await this.sessionRepository.create(SessionMapper.toRecord(session));
    if (!saved.success) {
      return Result.fail(saved.error ?? new ResultError('YW-SESSION-1001', 'Failed to persist session'));
    }
    this.runtimeStore.register(session);
    logger.params('session_created', LogParams.create()
      .put('id', session.id)
      .put('type', `${session.type}`));
    return Result.ok(session);
  }

  async startSession(sessionId: string): Promise<Result<void>> {
    const session = this.runtimeStore.getSession(sessionId);
    if (session === undefined) {
      return Result.fail(new ResultError('YW-SESSION-1002', 'Session not found'));
    }
    try {
      SessionStateMachine.assertTransition(session.state, SessionState.PREPARING);
      let current = session.withState(SessionState.PREPARING);
      this.persistAndPublish(current);
      SessionStateMachine.assertTransition(current.state, SessionState.RUNNING);
      current = current.withState(SessionState.RUNNING);
      this.persistAndPublish(current);
      logger.stateTransition('session', SessionState.PREPARING, SessionState.RUNNING, 'start');
      return Result.ok(undefined);
    } catch (error) {
      const err = error as Error;
      const resultError = new ResultError('YW-SESSION-1003', err.message, err);
      const failed = session.withError(DebugError.fromResultError(resultError));
      this.persistAndPublish(failed);
      return Result.fail(resultError);
    }
  }

  async stopSession(sessionId: string, reason: string = 'user_stop'): Promise<Result<void>> {
    const session = this.runtimeStore.getSession(sessionId);
    if (session === undefined) {
      return Result.fail(new ResultError('YW-SESSION-1002', 'Session not found'));
    }
    if (SessionStateMachine.isTerminal(session.state)) {
      return Result.ok(undefined);
    }
    let current = session.withState(SessionState.STOPPING);
    this.persistAndPublish(current);
    const completed = new DebugSession(
      current.id,
      current.type,
      current.module,
      current.protocol,
      current.displayName,
      current.mode,
      SessionState.COMPLETED,
      current.startAtMs,
      TimeUtil.nowMs(),
      current.target,
      new SessionResult(true, reason),
      undefined,
      current.tags,
      current.attributes
    );
    await this.sessionRepository.close(sessionId, JSON.stringify({ success: true, summary: reason }));
    this.persistAndPublish(completed);
    logger.stateTransition('session', SessionState.STOPPING, SessionState.COMPLETED, reason);
    return Result.ok(undefined);
  }

  updateState(sessionId: string, patch: SessionStatePatch): void {
    this.runtimeStore.applyPatch(sessionId, patch);
    const session = this.runtimeStore.getSession(sessionId);
    if (session !== undefined && patch.state !== undefined) {
      const updated = session.withState(patch.state);
      this.persistAndPublish(updated);
    }
  }

  async appendEvent(event: DebugEvent, payload?: Uint8Array): Promise<Result<void>> {
    const captured = await this.logCapture.captureEvent(event, payload);
    if (!captured.success) {
      return Result.fail(captured.error ?? new ResultError('YW-LOG-1001', 'Log capture failed'));
    }
    return Result.ok(undefined);
  }

  getSession(sessionId: string): DebugSession | undefined {
    return this.runtimeStore.getSession(sessionId);
  }

  observeSession(sessionId: string): Observable<DebugSessionState> {
    return this.runtimeStore.observeSession(sessionId);
  }

  observeActiveSessions(): Observable<DebugSessionSummary[]> {
    return this.runtimeStore.observeActiveSessions();
  }

  private persistAndPublish(session: DebugSession): void {
    this.sessionRepository.update(SessionMapper.toRecord(session));
    this.runtimeStore.updateSession(session.id, session);
  }

  private onPlatformEvent(event: PlatformEvent): void {
    if (event.type === PlatformEventType.APP_BACKGROUND) {
      this.handleBackground();
    }
    if (event.type === PlatformEventType.APP_FOREGROUND) {
      LifecycleCoordinator.getInstance().reconcile();
    }
  }

  private handleBackground(): void {
    const coordinator = LifecycleCoordinator.getInstance();
    const summaries = this.runtimeStore.listActiveSummaries();
    for (let i = 0; i < summaries.length; i++) {
      const session = this.runtimeStore.getSession(summaries[i].id);
      if (session === undefined) {
        continue;
      }
      const category = SessionManager.backgroundCategory(session.type);
      const platformKind = SessionManager.platformSessionKind(session.type);
      const catalogAction = BackgroundPolicyCatalog.recommend(
        category,
        coordinator.backgroundConnectionEnabled,
        coordinator.backgroundPeriodicEnabled
      );
      const platformAction = BackgroundPolicyAdvisor.resolveAction(platformKind);
      const action = BackgroundPolicyCatalog.mergeActions(
        catalogAction,
        platformAction as BackgroundSessionAction
      );
      logger.params('background_policy', LogParams.create()
        .put('sessionId', session.id)
        .put('category', `${category}`)
        .put('platformKind', `${platformKind}`)
        .put('catalogAction', `${catalogAction}`)
        .put('platformAction', `${platformAction}`)
        .put('action', `${action}`));
      if (action === BackgroundSessionAction.STOP) {
        this.stopSession(session.id, 'background_policy_stop');
      } else if (action === BackgroundSessionAction.PAUSE) {
        this.updateState(session.id, new SessionStatePatch(SessionState.SUSPENDED));
      }
    }
  }

  private static backgroundCategory(type: SessionType): BackgroundSessionCategory {
    switch (type) {
      case SessionType.SCAN:
        return BackgroundSessionCategory.BLUETOOTH_SCAN;
      case SessionType.CONNECTION:
        return BackgroundSessionCategory.BLE_SPP_CONNECTION;
      case SessionType.EXPORT:
        return BackgroundSessionCategory.HTTP_EXPORT;
      case SessionType.COMMAND:
        return BackgroundSessionCategory.PERIODIC_COMMAND;
      default:
        return BackgroundSessionCategory.SOCKET_CONNECTION;
    }
  }

  private static platformSessionKind(type: SessionType): PlatformBackgroundSessionKind {
    switch (type) {
      case SessionType.SCAN:
        return PlatformBackgroundSessionKind.SCAN;
      case SessionType.CONNECTION:
        return PlatformBackgroundSessionKind.CONNECTION;
      case SessionType.COMMAND:
        return PlatformBackgroundSessionKind.PERIODIC;
      case SessionType.EXPORT:
        return PlatformBackgroundSessionKind.EXPORT;
      default:
        return PlatformBackgroundSessionKind.CONNECTION;
    }
  }
}
