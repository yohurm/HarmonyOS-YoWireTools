import { ComponentContent, promptAction } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { UIContextRegistry } from 'common_platform';
import { YoColor } from '../../token/semantic/YoColor';
import { YoTypeStyle } from '../../token/semantic/YoTypeStyle';
import { YoToastToken } from '../../token/component/YoToastToken';

/** 显示时长。 */
export enum YoToastDuration {
  SHORT = 0,
  LONG = 1
}

/** 显示位置。默认 CENTER（居中弹出）。 */
export enum YoToastPosition {
  TOP = 0,
  CENTER = 1,
  BOTTOM = 2
}

/**
 * Toast 内容参数（供 ComponentContent / @Builder 传递）。
 */
export class YoToastParams {
  text: ResourceStr = '';
  icon: Resource | undefined = undefined;
  backgroundColor: ResourceColor = YoColor.TOAST_BACKGROUND;
  textColor: ResourceColor = YoColor.TOAST_TEXT;
  iconColor: ResourceColor = YoColor.TOAST_TEXT;

  constructor(text: ResourceStr = '') {
    this.text = text;
  }
}

@Component
struct YoToastContent {
  @Prop toastText: ResourceStr = '';
  @Prop toastIcon: Resource | undefined = undefined;
  @Prop toastBackgroundColor: ResourceColor = YoColor.TOAST_BACKGROUND;
  @Prop toastTextColor: ResourceColor = YoColor.TOAST_TEXT;
  @Prop toastIconColor: ResourceColor = YoColor.TOAST_TEXT;

  build() {
    Row({ space: YoToastToken.ICON_TEXT_SPACING }) {
      if (this.toastIcon !== undefined) {
        Image(this.toastIcon)
          .width(YoToastToken.ICON_SIZE)
          .height(YoToastToken.ICON_SIZE)
          .fillColor(this.toastIconColor)
          .objectFit(ImageFit.Contain)
      }
      Text(this.toastText)
        .fontSize(YoTypeStyle.BODY_M.size)
        .fontWeight(YoTypeStyle.BODY_M.weight)
        .fontColor(this.toastTextColor)
        .maxLines(YoToastToken.MAX_LINES)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .textAlign(TextAlign.Start)
    }
    .constraintSize({
      minWidth: YoToastToken.MIN_WIDTH,
      maxWidth: YoToastToken.MAX_WIDTH
    })
    .padding({
      left: YoToastToken.PADDING_HORIZONTAL,
      right: YoToastToken.PADDING_HORIZONTAL,
      top: YoToastToken.PADDING_VERTICAL,
      bottom: YoToastToken.PADDING_VERTICAL
    })
    .borderRadius(YoToastToken.CORNER_RADIUS)
    .backgroundColor(this.toastBackgroundColor)
    .justifyContent(FlexAlign.Center)
    .alignItems(VerticalAlign.Center)
    .margin({
      left: YoToastToken.HORIZONTAL_MARGIN,
      right: YoToastToken.HORIZONTAL_MARGIN
    })
  }
}

@Builder
function buildYoToastContent(params: YoToastParams) {
  YoToastContent({
    toastText: params.text,
    toastIcon: params.icon,
    toastBackgroundColor: params.backgroundColor,
    toastTextColor: params.textColor,
    toastIconColor: params.iconColor
  });
}

/**
 * 轻提示 — 命令式 API。
 *
 * 依据官方 FAQ：系统 Toast 样式受限时，用 openCustomDialog + ComponentContent
 * 实现自定义样式；默认居中、非模态、深色半透明背板（对齐 Android YoToast）。
 *
 * UIContext：优先入参，否则取 UIContextRegistry（Entry 已 bind）。
 */
export class YoToast {
  private static current: YoToast | undefined = undefined;

  private readonly uiContext: UIContext;
  private params: YoToastParams = new YoToastParams();
  private duration: YoToastDuration = YoToastDuration.SHORT;
  private position: YoToastPosition = YoToastPosition.CENTER;
  private contentNode: ComponentContent<YoToastParams> | undefined = undefined;
  private dismissTimer: number = -1;
  private generation: number = 0;
  private showing: boolean = false;

  private constructor(uiContext: UIContext) {
    this.uiContext = uiContext;
  }

  // ==================== 静态快捷方法 ====================

  static show(text: ResourceStr, uiContext?: UIContext): void {
    YoToast.create(uiContext).setText(text).show();
  }

  static showLong(text: ResourceStr, uiContext?: UIContext): void {
    YoToast.create(uiContext).setText(text).setDuration(YoToastDuration.LONG).show();
  }

  static showSuccess(text: ResourceStr, uiContext?: UIContext): void {
    YoToast.create(uiContext)
      .setText(text)
      .setBackgroundColor(YoColor.SUCCESS)
      .show();
  }

  static showError(text: ResourceStr, uiContext?: UIContext): void {
    YoToast.create(uiContext)
      .setText(text)
      .setBackgroundColor(YoColor.ERROR)
      .show();
  }

  static showWarning(text: ResourceStr, uiContext?: UIContext): void {
    YoToast.create(uiContext)
      .setText(text)
      .setBackgroundColor(YoColor.WARNING)
      .show();
  }

  static create(uiContext?: UIContext): YoToast {
    const ctx: UIContext | undefined = uiContext ?? UIContextRegistry.getInstance().get();
    if (ctx === undefined) {
      throw new Error('YoToast: UIContext unavailable. Pass uiContext or bind UIContextRegistry first.');
    }
    return new YoToast(ctx);
  }

  // ==================== 配置 ====================

  setText(text: ResourceStr): YoToast {
    this.params.text = text;
    return this;
  }

  setIcon(icon: Resource | undefined): YoToast {
    this.params.icon = icon;
    return this;
  }

  setDuration(duration: YoToastDuration): YoToast {
    this.duration = duration;
    return this;
  }

  setPosition(position: YoToastPosition): YoToast {
    this.position = position;
    return this;
  }

  setBackgroundColor(color: ResourceColor): YoToast {
    this.params.backgroundColor = color;
    return this;
  }

  setTextColor(color: ResourceColor): YoToast {
    this.params.textColor = color;
    return this;
  }

  setIconColor(color: ResourceColor): YoToast {
    this.params.iconColor = color;
    return this;
  }

  // ==================== 控制 ====================

  show(): void {
    const previous: YoToast | undefined = YoToast.current;
    if (previous !== undefined && previous !== this) {
      previous.removeImmediately();
    }
    YoToast.current = this;
    const showGeneration: number = ++this.generation;

    this.contentNode = new ComponentContent(this.uiContext, wrapBuilder(buildYoToastContent), this.params);
    const options: promptAction.BaseDialogOptions = {
      alignment: this.resolveAlignment(),
      offset: this.resolveOffset(),
      isModal: false,
      autoCancel: false,
      showInSubWindow: false,
      maskColor: Color.Transparent,
      focusable: false,
      dialogTransition: TransitionEffect.opacity(0)
        .animation({ duration: YoToastToken.ANIMATION_MS, curve: Curve.EaseOut })
    };

    this.uiContext.getPromptAction().openCustomDialog(this.contentNode, options)
      .then(() => {
        if (showGeneration !== this.generation) {
          return;
        }
        this.showing = true;
        this.dismissTimer = setTimeout((): void => {
          this.dismissInternal(showGeneration);
        }, this.resolveDurationMs());
      })
      .catch((_error: BusinessError) => {
        this.clearReferences(showGeneration);
      });
  }

  cancel(): void {
    this.removeImmediately();
  }

  isShowing(): boolean {
    return this.showing;
  }

  private dismissInternal(expectedGeneration: number): void {
    if (expectedGeneration !== this.generation) {
      return;
    }
    if (!this.showing || this.contentNode === undefined) {
      return;
    }
    const node: ComponentContent<YoToastParams> = this.contentNode;
    this.uiContext.getPromptAction().closeCustomDialog(node)
      .then(() => {
        node.dispose();
        this.clearReferences(expectedGeneration);
      })
      .catch((_error: BusinessError) => {
        try {
          node.dispose();
        } catch (_disposeError) {
          // ignore
        }
        this.clearReferences(expectedGeneration);
      });
  }

  private removeImmediately(): void {
    this.generation++;
    if (this.dismissTimer >= 0) {
      clearTimeout(this.dismissTimer);
      this.dismissTimer = -1;
    }
    const node: ComponentContent<YoToastParams> | undefined = this.contentNode;
    if (node !== undefined) {
      this.uiContext.getPromptAction().closeCustomDialog(node)
        .then(() => {
          node.dispose();
        })
        .catch((_error: BusinessError) => {
          try {
            node.dispose();
          } catch (_disposeError) {
            // ignore
          }
        });
    }
    this.showing = false;
    this.contentNode = undefined;
    if (YoToast.current === this) {
      YoToast.current = undefined;
    }
  }

  private clearReferences(expectedGeneration: number): void {
    if (expectedGeneration !== this.generation) {
      return;
    }
    this.dismissTimer = -1;
    this.contentNode = undefined;
    this.showing = false;
    if (YoToast.current === this) {
      YoToast.current = undefined;
    }
  }

  private resolveDurationMs(): number {
    return this.duration === YoToastDuration.LONG
      ? YoToastToken.DURATION_LONG_MS
      : YoToastToken.DURATION_SHORT_MS;
  }

  private resolveAlignment(): DialogAlignment {
    if (this.position === YoToastPosition.TOP) {
      return DialogAlignment.Top;
    }
    if (this.position === YoToastPosition.BOTTOM) {
      return DialogAlignment.Bottom;
    }
    return DialogAlignment.Center;
  }

  private resolveOffset(): Offset {
    if (this.position === YoToastPosition.TOP) {
      return { dx: 0, dy: YoToastToken.EDGE_MARGIN };
    }
    if (this.position === YoToastPosition.BOTTOM) {
      return { dx: 0, dy: -YoToastToken.EDGE_MARGIN };
    }
    return { dx: 0, dy: 0 };
  }
}
