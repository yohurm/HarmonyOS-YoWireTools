import { Observable, Subscription } from 'common_core';
import { DebugSessionState, DebugSessionSummary, SessionStatePatch } from './DebugSessionState';
import { SessionState } from '../domain/enums/DomainEnums';
import { DebugSession } from '../domain/model/DebugSession';

/**
 * Single source of truth for session runtime per 00-§8.1.
 */
export class SessionRuntimeStore {
  private static instance: SessionRuntimeStore | undefined;
  private readonly states: Map<string, DebugSessionState> = new Map();
  private readonly sessionObservables: Map<string, Observable<DebugSessionState>> = new Map();
  private readonly activeListObservable: Observable<DebugSessionSummary[]>;

  private constructor() {
    this.activeListObservable = new Observable<DebugSessionSummary[]>([]);
  }

  static getInstance(): SessionRuntimeStore {
    if (SessionRuntimeStore.instance === undefined) {
      SessionRuntimeStore.instance = new SessionRuntimeStore();
    }
    return SessionRuntimeStore.instance;
  }

  register(session: DebugSession): void {
    const state = new DebugSessionState(session);
    this.states.set(session.id, state);
    this.ensureObservable(session.id).next(state);
    this.publishActiveList();
  }

  updateSession(sessionId: string, session: DebugSession): void {
    const current = this.states.get(sessionId);
    if (current === undefined) {
      this.register(session);
      return;
    }
    const next = current.withSession(session);
    this.states.set(sessionId, next);
    this.ensureObservable(sessionId).next(next);
    this.publishActiveList();
  }

  applyPatch(sessionId: string, patch: SessionStatePatch): void {
    const current = this.states.get(sessionId);
    if (current === undefined) {
      return;
    }
    let session = current.session;
    if (patch.state !== undefined) {
      session = session.withState(patch.state);
    }
    const bytesIn = current.bytesIn + (patch.bytesInDelta ?? 0);
    const bytesOut = current.bytesOut + (patch.bytesOutDelta ?? 0);
    const logCount = current.logCount + (patch.logCountDelta ?? 0);
    const summary = patch.lastEventSummary ?? current.lastEventSummary;
    const next = new DebugSessionState(
      session,
      bytesIn,
      bytesOut,
      logCount,
      summary,
      patch.captureState ?? current.captureState,
      patch.transportState ?? current.transportState
    );
    this.states.set(sessionId, next);
    this.ensureObservable(sessionId).next(next);
    this.publishActiveList();
  }

  getState(sessionId: string): DebugSessionState | undefined {
    return this.states.get(sessionId);
  }

  getSession(sessionId: string): DebugSession | undefined {
    return this.states.get(sessionId)?.session;
  }

  observeSession(sessionId: string): Observable<DebugSessionState> {
    return this.ensureObservable(sessionId);
  }

  observeActiveSessions(): Observable<DebugSessionSummary[]> {
    return this.activeListObservable;
  }

  subscribeSession(sessionId: string, observer: (state: DebugSessionState) => void): Subscription {
    return this.ensureObservable(sessionId).subscribe(observer);
  }

  subscribeActiveSessions(observer: (summaries: DebugSessionSummary[]) => void): Subscription {
    return this.activeListObservable.subscribe(observer);
  }

  listActiveSummaries(): DebugSessionSummary[] {
    const summaries: DebugSessionSummary[] = [];
    this.states.forEach((state: DebugSessionState) => {
      if (!SessionRuntimeStore.isActive(state.session.state)) {
        return;
      }
      summaries.push(new DebugSessionSummary(
        state.session.id,
        state.session.displayName,
        state.session.module,
        state.session.protocol,
        state.session.state,
        state.session.startAtMs,
        state.logCount
      ));
    });
    return summaries;
  }

  remove(sessionId: string): void {
    this.states.delete(sessionId);
    this.sessionObservables.delete(sessionId);
    this.publishActiveList();
  }

  clear(): void {
    this.states.clear();
    this.sessionObservables.clear();
    this.activeListObservable.next([]);
  }

  private ensureObservable(sessionId: string): Observable<DebugSessionState> {
    let observable = this.sessionObservables.get(sessionId);
    if (observable !== undefined) {
      return observable;
    }
    const state = this.states.get(sessionId);
    if (state === undefined) {
      throw new Error(`Session not registered: ${sessionId}`);
    }
    observable = new Observable<DebugSessionState>(state);
    this.sessionObservables.set(sessionId, observable);
    return observable;
  }

  private publishActiveList(): void {
    this.activeListObservable.next(this.listActiveSummaries());
  }

  private static isActive(state: SessionState): boolean {
    return state === SessionState.CREATED ||
      state === SessionState.PREPARING ||
      state === SessionState.RUNNING ||
      state === SessionState.SUSPENDED ||
      state === SessionState.STOPPING;
  }
}
