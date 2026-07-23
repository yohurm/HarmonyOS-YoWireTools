import { SessionState } from '../domain/enums/DomainEnums';

/**
 * Session lifecycle state machine per architecture §3.3.
 */
export class SessionStateMachine {
  static canTransition(from: SessionState, to: SessionState): boolean {
    if (from === to) {
      return true;
    }
    switch (from) {
      case SessionState.CREATED:
        return to === SessionState.PREPARING || to === SessionState.CANCELLED;
      case SessionState.PREPARING:
        return to === SessionState.RUNNING || to === SessionState.FAILED || to === SessionState.CANCELLED;
      case SessionState.RUNNING:
        return to === SessionState.SUSPENDED || to === SessionState.STOPPING || to === SessionState.FAILED;
      case SessionState.SUSPENDED:
        return to === SessionState.RUNNING || to === SessionState.STOPPING || to === SessionState.FAILED;
      case SessionState.STOPPING:
        return to === SessionState.COMPLETED || to === SessionState.CANCELLED || to === SessionState.FAILED;
      case SessionState.COMPLETED:
      case SessionState.FAILED:
      case SessionState.CANCELLED:
        return false;
      default:
        return false;
    }
  }

  static assertTransition(from: SessionState, to: SessionState): void {
    if (!SessionStateMachine.canTransition(from, to)) {
      throw new Error(`Invalid session transition: ${from} -> ${to}`);
    }
  }

  static isTerminal(state: SessionState): boolean {
    return state === SessionState.COMPLETED ||
      state === SessionState.FAILED ||
      state === SessionState.CANCELLED;
  }
}
