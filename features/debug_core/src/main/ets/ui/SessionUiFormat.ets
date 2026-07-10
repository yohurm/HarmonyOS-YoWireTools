import { SessionState } from '../domain/enums/DomainEnums';

/** Maps session runtime state to user-facing labels per HarmonyOS 界面用语规范. */
export class SessionUiFormat {
  static stateLabel(state: SessionState): ResourceStr {
    switch (state) {
      case SessionState.RUNNING:
        return $r('app.string.session_state_running');
      case SessionState.PREPARING:
        return $r('app.string.session_state_preparing');
      case SessionState.SUSPENDED:
        return $r('app.string.session_state_suspended');
      case SessionState.FAILED:
        return $r('app.string.session_state_failed');
      case SessionState.COMPLETED:
        return $r('app.string.session_state_completed');
      case SessionState.STOPPING:
        return $r('app.string.session_state_stopping');
      case SessionState.CANCELLED:
        return $r('app.string.session_state_cancelled');
      default:
        return $r('app.string.session_state_created');
    }
  }

  static stateTone(state: SessionState): string {
    switch (state) {
      case SessionState.RUNNING:
        return 'success';
      case SessionState.FAILED:
        return 'error';
      case SessionState.SUSPENDED:
        return 'warning';
      default:
        return 'neutral';
    }
  }
}
