import { BusinessError } from '@kit.BasicServicesKit';
import { ComponentContent, promptAction, wrapBuilder } from '@kit.ArkUI';
import { UIContextRegistry } from 'common_platform';
import { ButtonToken } from '../token/component/ButtonToken';
import { DialogToken } from '../token/component/DialogToken';
import { UiColor } from '../token/semantic/UiColor';
import { UiTypeStyle } from '../token/semantic/UiTypeStyle';
import { UiSpace } from '../token/foundation/UiSpace';
import { UiOpacity } from '../token/foundation/UiOpacity';
import { UiResourceUtil } from '../util/UiResourceUtil';

export enum RiskConfirmVariant {
  DANGER = 0,
  WARNING = 1
}

export interface RiskConfirmOptions {
  title: ResourceStr;
  message: ResourceStr;
  confirmLabel: ResourceStr;
  cancelLabel?: ResourceStr;
  variant?: RiskConfirmVariant;
  onConfirm: () => void;
  onCancel?: () => void;
}

enum RiskConfirmDialogMode {
  CONFIRM = 0,
  INFO = 1
}

class RiskConfirmDialogSession {
  contentNode: ComponentContent<Object> | undefined;
}

class RiskConfirmDialogContentParams {
  title: ResourceStr;
  message: ResourceStr;
  confirmLabel: ResourceStr;
  cancelLabel: ResourceStr;
  variant: RiskConfirmVariant;
  mode: RiskConfirmDialogMode;
  onConfirm: () => void;
  onCancel: () => void;

  constructor(
    title: ResourceStr,
    message: ResourceStr,
    confirmLabel: ResourceStr,
    cancelLabel: ResourceStr,
    variant: RiskConfirmVariant,
    mode: RiskConfirmDialogMode,
    onConfirm: () => void,
    onCancel: () => void
  ) {
    this.title = title;
    this.message = message;
    this.confirmLabel = confirmLabel;
    this.cancelLabel = cancelLabel;
    this.variant = variant;
    this.mode = mode;
    this.onConfirm = onConfirm;
    this.onCancel = onCancel;
  }
}

@Builder
function buildRiskConfirmDialogContent(params: RiskConfirmDialogContentParams) {
  Column({ space: UiSpace.L }) {
    Text(params.title)
      .fontSize(UiTypeStyle.TITLE_S.size)
      .fontWeight(UiTypeStyle.TITLE_S.weight)
      .fontColor(UiColor.TEXT_PRIMARY)
      .width('100%')
    if (UiResourceUtil.hasText(params.message)) {
      Text(params.message)
        .fontSize(UiTypeStyle.BODY_M.size)
        .fontColor(UiColor.TEXT_SECONDARY)
        .width('100%')
    }
    if (params.mode === RiskConfirmDialogMode.INFO) {
      Button(params.confirmLabel, { type: ButtonType.Normal })
        .width('100%')
        .height(ButtonToken.HEIGHT)
        .fontSize(UiTypeStyle.BODY_M.size)
        .fontColor(ButtonToken.PRIMARY_FOREGROUND)
        .backgroundColor(ButtonToken.PRIMARY_BACKGROUND)
        .borderRadius(ButtonToken.RADIUS)
        .onClick(() => params.onConfirm())
    } else {
      Row({ space: UiSpace.M }) {
        Button(params.cancelLabel, { type: ButtonType.Normal })
          .layoutWeight(1)
          .height(ButtonToken.HEIGHT)
          .fontSize(UiTypeStyle.BODY_M.size)
          .fontColor(UiColor.BRAND_PRIMARY)
          .backgroundColor(Color.Transparent)
          .border({ width: 1, color: UiColor.BORDER_PRIMARY })
          .borderRadius(ButtonToken.RADIUS)
          .onClick(() => params.onCancel())
        Button(params.confirmLabel, { type: ButtonType.Normal })
          .layoutWeight(1)
          .height(ButtonToken.HEIGHT)
          .fontSize(UiTypeStyle.BODY_M.size)
          .fontColor(ButtonToken.DANGER_FOREGROUND)
          .backgroundColor(
            params.variant === RiskConfirmVariant.WARNING
              ? UiColor.WARNING
              : ButtonToken.DANGER_BACKGROUND
          )
          .borderRadius(ButtonToken.RADIUS)
          .onClick(() => params.onConfirm())
      }
      .width('100%')
    }
  }
  .width('100%')
  .constraintSize({ maxWidth: DialogToken.MAX_WIDTH })
  .padding(DialogToken.CONTENT_PADDING)
  .backgroundColor(UiColor.SURFACE_CARD)
  .borderRadius(DialogToken.RADIUS)
  .margin({ left: UiSpace.XL, right: UiSpace.XL })
}

/**
 * V2 unified risk confirmation dialog for port scan, broadcast, periodic send, etc.
 * Uses UIContext.getPromptAction().openCustomDialog() with DialogToken 32vp container.
 * For async confirm with loading state, use {@link RiskConfirmOverlay}.
 */
export class RiskConfirmDialog {
  static show(options: RiskConfirmOptions): void {
    const variant = options.variant ?? RiskConfirmVariant.DANGER;
    RiskConfirmDialog.openDialog(
      options.title,
      options.message,
      options.confirmLabel,
      options.cancelLabel ?? $r('app.string.ui_action_cancel'),
      variant,
      RiskConfirmDialogMode.CONFIRM,
      () => {
        options.onConfirm();
      },
      () => {
        if (options.onCancel !== undefined) {
          options.onCancel();
        }
      }
    );
  }

  static showDanger(
    title: ResourceStr,
    message: ResourceStr,
    confirmLabel: ResourceStr,
    onConfirm: () => void,
    onCancel?: () => void
  ): void {
    RiskConfirmDialog.show({
      title,
      message,
      confirmLabel,
      variant: RiskConfirmVariant.DANGER,
      onConfirm,
      onCancel
    });
  }

  static showWarning(
    title: ResourceStr,
    message: ResourceStr,
    confirmLabel: ResourceStr,
    onConfirm: () => void,
    onCancel?: () => void
  ): void {
    RiskConfirmDialog.show({
      title,
      message,
      confirmLabel,
      variant: RiskConfirmVariant.WARNING,
      onConfirm,
      onCancel
    });
  }

  static showInfo(title: ResourceStr, message: ResourceStr, onDismiss?: () => void): void {
    RiskConfirmDialog.openDialog(
      title,
      message,
      $r('app.string.ui_got_it'),
      $r('app.string.ui_action_cancel'),
      RiskConfirmVariant.DANGER,
      RiskConfirmDialogMode.INFO,
      () => {
        if (onDismiss !== undefined) {
          onDismiss();
        }
      },
      () => {
        if (onDismiss !== undefined) {
          onDismiss();
        }
      }
    );
  }

  static resolveConfirmColor(variant: RiskConfirmVariant): ResourceColor {
    return variant === RiskConfirmVariant.WARNING ? UiColor.WARNING : UiColor.ERROR;
  }

  private static openDialog(
    title: ResourceStr,
    message: ResourceStr,
    confirmLabel: ResourceStr,
    cancelLabel: ResourceStr,
    variant: RiskConfirmVariant,
    mode: RiskConfirmDialogMode,
    onConfirm: () => void,
    onCancel: () => void
  ): void {
    const uiContext = UIContextRegistry.getInstance().get();
    if (uiContext === undefined) {
      return;
    }
    const session = new RiskConfirmDialogSession();
    let dismissed = false;
    const dismiss = (): void => {
      if (dismissed) {
        return;
      }
      dismissed = true;
      RiskConfirmDialog.closeSession(uiContext, session);
    };
    const params = new RiskConfirmDialogContentParams(
      title,
      message,
      confirmLabel,
      cancelLabel,
      variant,
      mode,
      () => {
        dismiss();
        onConfirm();
      },
      () => {
        dismiss();
        onCancel();
      }
    );
    session.contentNode = new ComponentContent(
      uiContext,
      wrapBuilder(buildRiskConfirmDialogContent),
      params
    );
    const dialogOptions: promptAction.BaseDialogOptions = {
      alignment: DialogAlignment.Center,
      autoCancel: true,
      maskColor: UiColor.SCRIM,
      onWillDismiss: () => {
        if (!dismissed) {
          dismissed = true;
          RiskConfirmDialog.disposeSession(session);
          onCancel();
        }
      }
    };
    uiContext.getPromptAction().openCustomDialog(session.contentNode, dialogOptions)
      .catch((error: BusinessError) => {
        console.error(`RiskConfirmDialog.open error ${error.code}: ${error.message}`);
        RiskConfirmDialog.disposeSession(session);
      });
  }

  private static closeSession(uiContext: UIContext, session: RiskConfirmDialogSession): void {
    if (session.contentNode === undefined) {
      return;
    }
    uiContext.getPromptAction().closeCustomDialog(session.contentNode)
      .then(() => {
        RiskConfirmDialog.disposeSession(session);
      })
      .catch((error: BusinessError) => {
        console.error(`RiskConfirmDialog.close error ${error.code}: ${error.message}`);
        RiskConfirmDialog.disposeSession(session);
      });
  }

  private static disposeSession(session: RiskConfirmDialogSession): void {
    if (session.contentNode !== undefined) {
      session.contentNode.dispose();
      session.contentNode = undefined;
    }
  }
}

/**
 * In-tree risk dialog with confirm loading state (workflow guide: destructive actions).
 */
@ComponentV2
export struct RiskConfirmOverlay {
  @Param visible: boolean = false;
  @Param title: ResourceStr = '';
  @Param message: ResourceStr = '';
  @Param confirmLabel: ResourceStr = '';
  @Param cancelLabel: ResourceStr = $r('app.string.ui_action_cancel');
  @Param variant: RiskConfirmVariant = RiskConfirmVariant.DANGER;
  @Param isConfirmLoading: boolean = false;
  @Event onConfirm: () => void = () => {
  };
  @Event onCancel: () => void = () => {
  };

  build() {
    if (!this.visible) {
      Blank()
    } else {
      Stack({ alignContent: Alignment.Center }) {
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor(UiColor.SCRIM)
          .onClick(() => {
            if (!this.isConfirmLoading) {
              this.onCancel();
            }
          })
        Column({ space: UiSpace.L }) {
          Text(this.title)
            .fontSize(UiTypeStyle.TITLE_S.size)
            .fontWeight(UiTypeStyle.TITLE_S.weight)
            .fontColor(UiColor.TEXT_PRIMARY)
            .width('100%')
          if (UiResourceUtil.hasText(this.message)) {
            Text(this.message)
              .fontSize(UiTypeStyle.BODY_M.size)
              .fontColor(UiColor.TEXT_SECONDARY)
              .width('100%')
          }
          Row({ space: UiSpace.M }) {
            Button(this.cancelLabel, { type: ButtonType.Normal })
              .layoutWeight(1)
              .height(ButtonToken.HEIGHT)
              .fontSize(UiTypeStyle.BODY_M.size)
              .fontColor(UiColor.BRAND_PRIMARY)
              .backgroundColor(Color.Transparent)
              .border({ width: 1, color: UiColor.BORDER_PRIMARY })
              .borderRadius(ButtonToken.RADIUS)
              .enabled(!this.isConfirmLoading)
              .onClick(() => this.onCancel())
            Button(
              this.isConfirmLoading ? $r('app.string.ui_action_processing') : this.confirmLabel,
              { type: ButtonType.Normal }
            )
              .layoutWeight(1)
              .height(ButtonToken.HEIGHT)
              .fontSize(UiTypeStyle.BODY_M.size)
              .fontColor(ButtonToken.DANGER_FOREGROUND)
              .backgroundColor(
                this.variant === RiskConfirmVariant.WARNING
                  ? UiColor.WARNING
                  : ButtonToken.DANGER_BACKGROUND
              )
              .borderRadius(ButtonToken.RADIUS)
              .enabled(!this.isConfirmLoading)
              .opacity(this.isConfirmLoading ? UiOpacity.DISABLED_CONTENT : UiOpacity.ENABLED)
              .onClick(() => this.onConfirm())
          }
          .width('100%')
        }
        .width('100%')
        .constraintSize({ maxWidth: DialogToken.MAX_WIDTH })
        .padding(DialogToken.CONTENT_PADDING)
        .backgroundColor(UiColor.SURFACE_CARD)
        .borderRadius(DialogToken.RADIUS)
        .margin({ left: UiSpace.XL, right: UiSpace.XL })
      }
      .width('100%')
      .height('100%')
    }
  }
}
