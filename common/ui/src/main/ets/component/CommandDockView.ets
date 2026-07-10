import { WindowMetricsRegistry, WindowMetricsState, WindowWidthBreakpointUtil } from 'common_platform';
import { ButtonToken } from '../token/component/ButtonToken';
import { CardToken } from '../token/component/CardToken';
import { InputToken } from '../token/component/InputToken';
import { UiColor } from '../token/semantic/UiColor';
import { UiTypeStyle } from '../token/semantic/UiTypeStyle';
import { CommandDockToken } from '../token/component/CommandDockToken';
import { UiSize } from '../token/foundation/UiSize';
import { UiSpace } from '../token/foundation/UiSpace';
import { UiOpacity } from '../token/foundation/UiOpacity';
import { UiResourceUtil } from '../util/UiResourceUtil';
import { RiskConfirmDialog, RiskConfirmVariant } from './RiskConfirmDialog';

export interface CommandDockActionRisk {
  variant: RiskConfirmVariant;
  title: ResourceStr;
  message: ResourceStr;
  confirmLabel: ResourceStr;
}

export interface CommandDockOverflowMenuItem {
  value: ResourceStr;
  action: () => void;
}

export class CommandDockAction {
  readonly key: string;
  readonly label: ResourceStr;
  readonly risk?: CommandDockActionRisk;

  constructor(key: string, label: ResourceStr, risk?: CommandDockActionRisk) {
    this.key = key;
    this.label = label;
    this.risk = risk;
  }
}

/**
 * Bottom command dock with live navigation-bar avoid inset from WindowMetricsState.
 * Workflow: risk actions open RiskConfirmDialog; submit requires canSubmit && !isLoading.
 */
@ComponentV2
export struct CommandDockView {
  @Param inputValue: string = '';
  @Param placeholder: ResourceStr = '';
  @Param sendLabel: ResourceStr = $r('app.string.ui_send');
  @Param canSubmit: boolean = true;
  @Param isSendEnabled: boolean = true;
  @Param isLoading: boolean = false;
  @Param sendDisabledReason: ResourceStr = '';
  @Param secondaryActions: CommandDockAction[] = [];
  @Param periodicActive: boolean = false;
  @Param periodicLabel: ResourceStr = $r('app.string.ui_periodic_sending');
  @Param avoidNavBar: boolean = true;
  @Param collapsed: boolean = false;
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
    Column({ space: UiSpace.M }) {
      if (this.periodicActive) {
        this.periodicBanner()
      }
      this.inputRow()
      if (!this.submitEnabled && UiResourceUtil.hasText(this.sendDisabledReason)) {
        Text(this.sendDisabledReason)
          .fontSize(UiTypeStyle.BODY_S.size)
          .fontColor(UiColor.TEXT_TERTIARY)
          .width('100%')
      }
      if (!this.collapsed && this.visibleSecondaryActions().length > 0) {
        this.secondaryRow(this.visibleSecondaryActions())
      }
    }
    .width('100%')
    .padding({
      left: WindowWidthBreakpointUtil.pagePaddingVp(this.metrics.breakpoint),
      right: WindowWidthBreakpointUtil.pagePaddingVp(this.metrics.breakpoint),
      top: CommandDockToken.PADDING,
      bottom: this.resolveBottomPadding()
    })
    .backgroundColor(UiColor.SURFACE_CARD)
  }

  private get submitEnabled(): boolean {
    return this.canSubmit && this.isSendEnabled && !this.isLoading;
  }

  @Builder
  private inputRow() {
    Row({ space: UiSpace.M }) {
      TextInput({ text: this.inputValue, placeholder: this.placeholder })
        .layoutWeight(1)
        .height(this.collapsed ? InputToken.HEIGHT_COMPACT : InputToken.HEIGHT)
        .fontSize(UiTypeStyle.MONO_M.size)
        .fontColor(InputToken.FOREGROUND)
        .fontFamily(UiTypeStyle.MONO_M.family)
        .backgroundColor(InputToken.BACKGROUND)
        .borderRadius(InputToken.RADIUS)
        .padding({ left: InputToken.HORIZONTAL_PADDING, right: InputToken.HORIZONTAL_PADDING })
        .onChange((next: string) => this.onInputChange(next))
      Button(
        this.isLoading ? $r('app.string.ui_action_processing') : this.sendLabel,
        { type: ButtonType.Normal }
      )
        .height(this.collapsed ? ButtonToken.HEIGHT_COMPACT : ButtonToken.HEIGHT)
        .constraintSize({ minWidth: UiSize.TOUCH_TARGET_MIN })
        .padding({ left: UiSpace.XL, right: UiSpace.XL })
        .borderRadius(ButtonToken.RADIUS)
        .fontSize(UiTypeStyle.BODY_M.size)
        .fontColor(ButtonToken.PRIMARY_FOREGROUND)
        .backgroundColor(ButtonToken.PRIMARY_BACKGROUND)
        .enabled(this.submitEnabled)
        .opacity(this.submitEnabled ? UiOpacity.ENABLED : UiOpacity.DISABLED_CONTAINER)
        .onClick(() => {
          if (this.submitEnabled && this.inputValue.length > 0) {
            this.onSend(this.inputValue);
          }
        })
      if (this.shouldShowOverflow()) {
        this.overflowTrigger()
      }
    }
    .width('100%')
    .alignItems(VerticalAlign.Center)
  }

  @Builder
  private overflowTrigger() {
    Button($r('app.string.ui_more_actions'), { type: ButtonType.Normal })
      .height(this.collapsed ? ButtonToken.HEIGHT_COMPACT : ButtonToken.HEIGHT)
      .constraintSize({ minWidth: UiSize.TOUCH_TARGET_MIN })
      .fontSize(UiTypeStyle.BODY_S.size)
      .fontColor(UiColor.BRAND_PRIMARY)
      .backgroundColor(Color.Transparent)
      .border({ width: 1, color: UiColor.BORDER_PRIMARY })
      .borderRadius(ButtonToken.RADIUS)
      .bindMenu(this.buildOverflowMenuItems())
      .accessibilityText($r('app.string.ui_more_actions_a11y'))
  }

  private buildOverflowMenuItems(): CommandDockOverflowMenuItem[] {
    const actions = this.collapsed ? this.secondaryActions : this.overflowActions();
    const items: CommandDockOverflowMenuItem[] = [];
    for (let index = 0; index < actions.length; index++) {
      const action = actions[index];
      items.push({
        value: action.label,
        action: () => this.dispatchSecondaryAction(action)
      });
    }
    return items;
  }

  @Builder
  private secondaryRow(actions: CommandDockAction[]) {
    Row({ space: UiSpace.M }) {
      ForEach(actions, (action: CommandDockAction) => {
        Button(action.label, { type: ButtonType.Normal })
          .layoutWeight(1)
          .height(ButtonToken.HEIGHT)
          .fontSize(UiTypeStyle.BODY_S.size)
          .fontColor(UiColor.BRAND_PRIMARY)
          .backgroundColor(Color.Transparent)
          .border({ width: 1, color: UiColor.BORDER_PRIMARY })
          .borderRadius(ButtonToken.RADIUS)
          .onClick(() => this.dispatchSecondaryAction(action))
      }, (action: CommandDockAction) => action.key)
    }
    .width('100%')
  }

  @Builder
  private periodicBanner() {
    Row({ space: UiSpace.M }) {
      Text(this.periodicLabel)
        .fontSize(UiTypeStyle.BODY_S.size)
        .fontColor(UiColor.WARNING)
        .layoutWeight(1)
      Button($r('app.string.ui_stop'), { type: ButtonType.Normal })
        .height(ButtonToken.HEIGHT)
        .constraintSize({ minWidth: UiSize.TOUCH_TARGET_MIN })
        .fontSize(UiTypeStyle.BODY_S.size)
        .fontColor(UiColor.WARNING)
        .backgroundColor(Color.Transparent)
        .border({ width: 1, color: UiColor.WARNING })
        .borderRadius(ButtonToken.RADIUS)
        .onClick(() => this.onStopPeriodic())
    }
    .width('100%')
    .padding(UiSpace.M)
    .backgroundColor(UiColor.WARNING_CONTAINER)
    .borderRadius(CardToken.RADIUS)
  }

  private visibleSecondaryActions(): CommandDockAction[] {
    if (!this.usesTabletOverflow()) {
      return this.secondaryActions;
    }
    return this.secondaryActions.slice(0, CommandDockToken.TABLET_INLINE_SECONDARY_MAX);
  }

  private overflowActions(): CommandDockAction[] {
    if (!this.usesTabletOverflow()) {
      return [];
    }
    if (this.secondaryActions.length <= CommandDockToken.TABLET_INLINE_SECONDARY_MAX) {
      return [];
    }
    return this.secondaryActions.slice(CommandDockToken.TABLET_INLINE_SECONDARY_MAX);
  }

  private shouldShowOverflow(): boolean {
    if (this.collapsed && this.secondaryActions.length > 0) {
      return true;
    }
    return this.overflowActions().length > 0;
  }

  private usesTabletOverflow(): boolean {
    return WindowWidthBreakpointUtil.isSplitCapable(this.metrics.breakpoint);
  }

  private dispatchSecondaryAction(action: CommandDockAction): void {
    if (action.risk !== undefined) {
      RiskConfirmDialog.show({
        title: action.risk.title,
        message: action.risk.message,
        confirmLabel: action.risk.confirmLabel,
        variant: action.risk.variant,
        onConfirm: () => this.onSecondaryAction(action.key)
      });
      return;
    }
    this.onSecondaryAction(action.key);
  }

  private resolveBottomPadding(): number {
    const base = CommandDockToken.PADDING;
    if (this.avoidNavBar) {
      return base + this.metrics.navigationBottomInsetVp;
    }
    return base;
  }
}
