import { SessionState } from '../domain/enums/DomainEnums';

/** Maps session runtime state to user-facing labels per HarmonyOS 界面用语规范. */
export class SessionUiFormat {
  static stateLabel(state: SessionState): string {
    switch (state) {
      case SessionState.RUNNING:
        return '运行中';
      case SessionState.PREPARING:
        return '准备中';
      case SessionState.SUSPENDED:
        return '已暂停';
      case SessionState.FAILED:
        return '失败';
      case SessionState.COMPLETED:
        return '已结束';
      case SessionState.STOPPING:
        return '停止中';
      case SessionState.CANCELLED:
        return '已取消';
      default:
        return '已创建';
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
