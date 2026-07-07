import { UIContextRegistry } from 'common_platform';
import { UiColorToken } from '../theme/UiColorToken';

export interface RiskConfirmOptions {
  title: string;
  message: string;
  confirmLabel: string;
  cancelLabel?: string;
  onConfirm: () => void;
  onCancel?: () => void;
}

/**
 * V2 unified risk confirmation dialog for port scan, broadcast, periodic send, etc.
 * Uses UIContext.showAlertDialog per HarmonyOS API 18+ (AlertDialog.show deprecated).
 */
export class RiskConfirmDialog {
  static show(options: RiskConfirmOptions): void {
    const uiContext = UIContextRegistry.getInstance().get();
    if (uiContext === undefined) {
      return;
    }
    uiContext.showAlertDialog({
      title: options.title,
      message: options.message,
      autoCancel: true,
      alignment: DialogAlignment.Center,
      primaryButton: {
        value: options.confirmLabel,
        fontColor: UiColorToken.ERROR,
        action: () => {
          options.onConfirm();
        }
      },
      secondaryButton: {
        value: options.cancelLabel ?? '取消',
        action: () => {
          if (options.onCancel !== undefined) {
            options.onCancel();
          }
        }
      },
      cancel: () => {
        if (options.onCancel !== undefined) {
          options.onCancel();
        }
      }
    });
  }

  static showInfo(title: string, message: string, onDismiss?: () => void): void {
    const uiContext = UIContextRegistry.getInstance().get();
    if (uiContext === undefined) {
      return;
    }
    uiContext.showAlertDialog({
      title: title,
      message: message,
      autoCancel: true,
      alignment: DialogAlignment.Center,
      confirm: {
        value: '知道了',
        action: () => {
          if (onDismiss !== undefined) {
            onDismiss();
          }
        }
      },
      cancel: () => {
        if (onDismiss !== undefined) {
          onDismiss();
        }
      }
    });
  }
}
