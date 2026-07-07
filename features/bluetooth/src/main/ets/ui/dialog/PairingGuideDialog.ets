import {
  SectionTitleView,
  StatusPillView,
  UiColorToken,
  UiLayoutConstants,
  UiSpacing,
  UiTypography,
  YoActionButton,
  YoActionButtonKind
} from 'common_ui';
import { PairingState } from '../../domain/model/PairingState';
@ComponentV2
export struct PairingGuideDialog {
  @Param pairState: PairingState = PairingState.UNKNOWN;
  @Param onStartPair: () => void = () => {
  };
  @Param onDismiss: () => void = () => {
  };

  build() {
    Column({ space: UiSpacing.CARD_GAP }) {
      SectionTitleView({
        title: '需要配对',
        subtitle: '设备尚未完成系统配对'
      })

      Text('HarmonyOS 将在您开始配对时显示系统配对对话框（PIN 或确认）。')
        .fontSize(UiTypography.BODY_SIZE)
        .fontColor(UiColorToken.TEXT_SECONDARY)
        .width('100%')

      StatusPillView({
        label: `当前状态：${PairingGuideDialog.pairStateLabel(this.pairState)}`,
        tone: 'warning'
      })

      YoActionButton({
        label: '开始系统配对',
        kind: YoActionButtonKind.PRIMARY,
        onTap: () => {
          this.onStartPair();
          this.onDismiss();
        }
      })

      YoActionButton({
        label: '取消',
        kind: YoActionButtonKind.SECONDARY,
        onTap: () => this.onDismiss()
      })
    }
    .width('100%')
    .constraintSize({ maxWidth: UiLayoutConstants.DIALOG_MAX_WIDTH })
    .padding(UiSpacing.PAGE_PADDING)
    .backgroundColor(UiColorToken.BACKGROUND)
    .borderRadius(UiLayoutConstants.CARD_RADIUS)
  }

  private static pairStateLabel(state: PairingState): string {
    switch (state) {
      case PairingState.PAIRED:
        return '已配对';
      case PairingState.PAIRING:
        return '配对中';
      case PairingState.FAILED:
        return '配对失败';
      case PairingState.CANCELLED:
        return '已取消';
      case PairingState.UNPAIRED:
        return '未配对';
      default:
        return '未知';
    }
  }
}
