import { WindowMetricsRegistry, WindowMetricsState, WindowWidthBreakpointUtil } from 'common_platform';
import { UiColorToken } from '../theme/UiColorToken';
import { UiLayoutConstants } from '../theme/UiLayoutConstants';
import { UiSpacing } from '../theme/UiSpacing';
import { UiTypography } from '../theme/UiTypography';

export class CommandDockAction {
  readonly key: string;
  readonly label: string;

  constructor(key: string, label: string) {
    this.key = key;
    this.label = label;
  }
}

/**
 * Bottom command dock with live navigation-bar avoid inset from WindowMetricsState.
 */
@ComponentV2
export struct CommandDockView {
  @Param inputValue: string = '';
  @Param placeholder: string = '';
  @Param sendLabel: string = '发送';
  @Param isSendEnabled: boolean = true;
  @Param sendDisabledReason: string = '';
  @Param secondaryActions: CommandDockAction[] = [];
  @Param periodicActive: boolean = false;
  @Param periodicLabel: string = '周期发送中';
  @Param avoidNavBar: boolean = true;
  @Event onInputChange: (value: string) => void = () => {
  };
  @Event onSend: (text: string) => void = () => {
  };
  @Event onSecondaryAction: (key: string) => void = () => {
  };
  @Event onStopPeriodic: () => void = () => {
  };
  @Local private metrics: WindowMetricsState = WindowMetricsRegistry.connect();

  build() {
    Column({ space: UiSpacing.ITEM_GAP }) {
      if (this.periodicActive) {
        this.periodicBanner()
      }
      Row({ space: UiSpacing.ITEM_GAP }) {
        TextInput({ text: this.inputValue, placeholder: this.placeholder })
          .layoutWeight(1)
          .height(UiLayoutConstants.TOUCH_TARGET)
          .fontSize(UiTypography.BODY_SIZE)
          .fontColor(UiColorToken.TEXT_PRIMARY)
          .fontFamily(UiTypography.MONO_FONT_FAMILY)
          .backgroundColor(UiColorToken.SURFACE)
          .borderRadius(UiSpacing.CORNER_RADIUS)
          .padding({ left: UiSpacing.ITEM_GAP, right: UiSpacing.ITEM_GAP })
          .onChange((next: string) => this.onInputChange(next))
        Button(this.sendLabel, { type: ButtonType.Normal })
          .height(UiLayoutConstants.TOUCH_TARGET)
          .constraintSize({ minWidth: UiLayoutConstants.TOUCH_TARGET })
          .padding({ left: UiSpacing.FORM_GAP, right: UiSpacing.FORM_GAP })
          .borderRadius(UiSpacing.CORNER_RADIUS)
          .fontSize(UiTypography.BODY_SIZE)
          .fontColor(UiColorToken.TEXT_INVERSE)
          .backgroundColor(UiColorToken.PRIMARY)
          .enabled(this.isSendEnabled)
          .opacity(this.isSendEnabled ? 1 : UiLayoutConstants.DISABLED_ROW_OPACITY)
          .onClick(() => {
            if (this.isSendEnabled && this.inputValue.length > 0) {
              this.onSend(this.inputValue);
            }
          })
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)
      if (!this.isSendEnabled && this.sendDisabledReason.length > 0) {
        Text(this.sendDisabledReason)
          .fontSize(UiTypography.CAPTION_SIZE)
          .fontColor(UiColorToken.TEXT_TERTIARY)
          .width('100%')
      }
      if (this.secondaryActions.length > 0) {
        Row({ space: UiSpacing.ITEM_GAP }) {
          ForEach(this.secondaryActions, (action: CommandDockAction) => {
            Button(action.label, { type: ButtonType.Normal })
              .layoutWeight(1)
              .height(UiLayoutConstants.TOUCH_TARGET)
              .fontSize(UiTypography.CAPTION_SIZE)
              .fontColor(UiColorToken.PRIMARY)
              .backgroundColor(Color.Transparent)
              .border({ width: 1, color: UiColorToken.BORDER })
              .borderRadius(UiSpacing.CORNER_RADIUS)
              .onClick(() => this.onSecondaryAction(action.key))
          }, (action: CommandDockAction) => action.key)
        }
        .width('100%')
      }
    }
    .width('100%')
    .padding({
      left: WindowWidthBreakpointUtil.pagePaddingVp(this.metrics.breakpoint),
      right: WindowWidthBreakpointUtil.pagePaddingVp(this.metrics.breakpoint),
      top: UiLayoutConstants.COMMAND_DOCK_PADDING,
      bottom: this.resolveBottomPadding()
    })
    .backgroundColor(UiColorToken.SURFACE)
  }

  @Builder
  private periodicBanner() {
    Row({ space: UiSpacing.ITEM_GAP }) {
      Text(this.periodicLabel)
        .fontSize(UiTypography.CAPTION_SIZE)
        .fontColor(UiColorToken.WARNING)
        .layoutWeight(1)
      Button('停止', { type: ButtonType.Normal })
        .height(UiLayoutConstants.TOUCH_TARGET)
        .constraintSize({ minWidth: UiLayoutConstants.TOUCH_TARGET })
        .fontSize(UiTypography.CAPTION_SIZE)
        .fontColor(UiColorToken.WARNING)
        .backgroundColor(Color.Transparent)
        .border({ width: 1, color: UiColorToken.WARNING })
        .borderRadius(UiSpacing.CORNER_RADIUS)
        .onClick(() => this.onStopPeriodic())
    }
    .width('100%')
    .padding({
      left: UiSpacing.ITEM_GAP,
      right: UiSpacing.ITEM_GAP,
      top: UiSpacing.ITEM_GAP,
      bottom: UiSpacing.ITEM_GAP
    })
    .backgroundColor($r('app.color.ui_emphasize_tertiary'))
    .borderRadius(UiSpacing.CORNER_RADIUS)
  }

  private resolveBottomPadding(): number {
    const base = UiLayoutConstants.COMMAND_DOCK_PADDING;
    if (this.avoidNavBar) {
      return base + this.metrics.navigationBottomInsetVp;
    }
    return base;
  }
}
