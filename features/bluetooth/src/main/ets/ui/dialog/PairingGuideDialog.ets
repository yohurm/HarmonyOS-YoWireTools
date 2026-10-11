import { ComponentContent, promptAction } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { UIContextRegistry } from 'common_platform';
import {
  YoColor,
  YoDialogToken,
  YoSpace,
  YoTypeStyle
} from 'youi_kit';
import { ClassicDeviceListItem } from '../../viewmodel/SppMainViewModel';
import {
  PairingGuideDialogParams,
  SppPairingGuideController
} from '../../viewmodel/SppPairingGuideController';

/**
 * 配对引导内容 — 与 SppConnectDialog 同构的系统风格卡片。
 */
@Component
struct PairingGuideDialogContent {
  @ObjectLink params: PairingGuideDialogParams;

  build() {
    Column() {
      Column() {
        Text($r('app.string.bt_pairing_guide_title'))
          .fontSize(YoTypeStyle.TITLE_S.size)
          .fontWeight(FontWeight.Bold)
          .fontColor(YoColor.TEXT_PRIMARY)
          .textAlign(TextAlign.Center)
          .width('100%')
          .margin({ top: YoSpace.XXL, bottom: YoSpace.XS })

        Text(this.params.displayName.length > 0 ? this.params.displayName : this.params.classicDeviceId)
          .fontSize(YoTypeStyle.BODY_M.size)
          .fontColor(YoColor.TEXT_SECONDARY)
          .textAlign(TextAlign.Center)
          .width('100%')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .padding({ left: YoSpace.XXL, right: YoSpace.XXL, bottom: YoSpace.L })

        Column({ space: YoSpace.M }) {
          Text($r('app.string.bt_pairing_guide_body'))
            .fontSize(YoTypeStyle.BODY_M.size)
            .fontColor(YoColor.TEXT_SECONDARY)
            .width('100%')
          Text($r('app.string.bt_pairing_no_system_confirm'))
            .fontSize(YoTypeStyle.BODY_S.size)
            .fontColor(YoColor.TEXT_TERTIARY)
            .width('100%')
          Text($r('app.string.bt_pairing_cannot_unpair'))
            .fontSize(YoTypeStyle.BODY_S.size)
            .fontColor(YoColor.TEXT_TERTIARY)
            .width('100%')
          Text($r('app.string.bt_pairing_hint_pin'))
            .fontSize(YoTypeStyle.BODY_S.size)
            .fontColor(YoColor.TEXT_TERTIARY)
            .width('100%')
          if (this.params.pairing) {
            Row({ space: YoSpace.M }) {
              LoadingProgress()
                .width(18)
                .height(18)
                .color(YoColor.BRAND_PRIMARY)
              Text($r('app.string.bt_pairing_action_pair'))
                .fontSize(YoTypeStyle.BODY_S.size)
                .fontColor(YoColor.TEXT_SECONDARY)
            }
            .width('100%')
          }
          if (this.params.errorMessage.length > 0) {
            Text(this.params.errorMessage)
              .fontSize(YoTypeStyle.BODY_S.size)
              .fontColor(YoColor.ERROR)
              .width('100%')
          }
          Button($r('app.string.bt_pairing_action_open_settings'), {
            type: ButtonType.Normal,
            buttonStyle: ButtonStyleMode.TEXTUAL,
            role: ButtonRole.NORMAL
          })
            .height(40)
            .fontSize(YoTypeStyle.BODY_M.size)
            .enabled(!this.params.pairing)
            .onClick(() => {
              this.params.onOpenSettings();
            })
        }
        .width('100%')
        .padding({ left: YoSpace.XXL, right: YoSpace.XXL, bottom: YoSpace.L })
        .alignItems(HorizontalAlign.Start)

        Divider()
          .color(YoColor.DIVIDER)
          .strokeWidth(0.5)

        Row() {
          Button($r('app.string.bt_spp_action_cancel'), {
            type: ButtonType.Normal,
            buttonStyle: ButtonStyleMode.TEXTUAL,
            role: ButtonRole.NORMAL
          })
            .layoutWeight(1)
            .height(48)
            .fontSize(YoTypeStyle.SUBTITLE_M.size)
            .fontWeight(FontWeight.Medium)
            .enabled(!this.params.pairing)
            .onClick(() => {
              this.params.onCancel();
            })

          Divider()
            .vertical(true)
            .height(24)
            .color(YoColor.DIVIDER)
            .strokeWidth(0.5)

          Button(this.primaryLabel(), {
            type: ButtonType.Normal,
            buttonStyle: ButtonStyleMode.TEXTUAL,
            role: ButtonRole.NORMAL
          })
            .layoutWeight(1)
            .height(48)
            .fontSize(YoTypeStyle.SUBTITLE_M.size)
            .fontWeight(FontWeight.Medium)
            .fontColor(!this.params.pairing && this.params.classicDeviceId.length > 0 ?
              YoColor.BRAND_PRIMARY : YoColor.TEXT_DISABLED)
            .enabled(!this.params.pairing && this.params.classicDeviceId.length > 0)
            .onClick(() => {
              this.params.onPair();
            })
        }
        .width('100%')
        .height(56)
        .padding({ bottom: YoSpace.S })
      }
      .width('100%')
      .constraintSize({ maxWidth: YoDialogToken.MAX_WIDTH })
      .borderRadius(YoDialogToken.RADIUS)
      .backgroundBlurStyle(BlurStyle.COMPONENT_ULTRA_THICK)
      .backgroundColor(YoColor.SURFACE_CARD)
      .clip(true)
    }
    .width('100%')
    .padding({ left: YoDialogToken.SIDE_MARGIN, right: YoDialogToken.SIDE_MARGIN })
  }

  private primaryLabel(): ResourceStr {
    if (this.params.hasAttempted || this.params.errorMessage.length > 0) {
      return $r('app.string.bt_pairing_action_retry');
    }
    return $r('app.string.bt_pairing_action_pair');
  }
}

@Builder
function buildPairingGuideDialogContent(params: PairingGuideDialogParams) {
  PairingGuideDialogContent({ params: params });
}

/**
 * 配对引导弹窗（openCustomDialog）。不伪造系统 PIN。
 */
export class PairingGuideDialog {
  private static current: PairingGuideDialog | undefined = undefined;

  private readonly uiContext: UIContext;
  private readonly params: PairingGuideDialogParams = new PairingGuideDialogParams();
  private readonly controller: SppPairingGuideController = new SppPairingGuideController();
  private contentNode: ComponentContent<PairingGuideDialogParams> | undefined = undefined;
  private showing: boolean = false;

  private constructor(uiContext: UIContext) {
    this.uiContext = uiContext;
  }

  static open(
    item: ClassicDeviceListItem,
    onPaired: () => void,
    uiContext?: UIContext
  ): void {
    const ctx = uiContext ?? UIContextRegistry.getInstance().get();
    if (ctx === undefined) {
      return;
    }
    if (PairingGuideDialog.current !== undefined) {
      PairingGuideDialog.current.close();
    }
    const dialog = new PairingGuideDialog(ctx);
    dialog.controller.reset();
    dialog.controller.bindPairedCallback(onPaired);
    dialog.params.classicDeviceId = item.classicDeviceId;
    dialog.params.displayName = item.displayName.length > 0 ? item.displayName : item.address;
    dialog.params.pairing = false;
    dialog.params.hasAttempted = false;
    dialog.params.errorMessage = '';
    dialog.params.onCancel = () => {
      if (!dialog.params.pairing) {
        dialog.close();
      }
    };
    dialog.params.onOpenSettings = () => {
      void dialog.controller.openBluetoothSettings();
    };
    dialog.params.onPair = () => {
      void dialog.controller.pairFromGuide(dialog.params);
    };
    dialog.params.onPairedSuccess = () => {
      dialog.close();
    };
    PairingGuideDialog.current = dialog;
    dialog.show();
  }

  private show(): void {
    this.contentNode = new ComponentContent(
      this.uiContext,
      wrapBuilder(buildPairingGuideDialogContent),
      this.params
    );
    const options: promptAction.BaseDialogOptions = {
      alignment: DialogAlignment.Center,
      isModal: true,
      autoCancel: true,
      showInSubWindow: false,
      maskColor: YoColor.SCRIM,
      onWillDismiss: (dismissDialogAction: DismissDialogAction) => {
        if (this.params.pairing) {
          return;
        }
        dismissDialogAction.dismiss();
        this.clearReferences();
      }
    };
    this.uiContext.getPromptAction().openCustomDialog(this.contentNode, options)
      .then(() => {
        this.showing = true;
      })
      .catch((_error: BusinessError) => {
        this.clearReferences();
      });
  }

  close(): void {
    this.controller.dispose();
    if (!this.showing || this.contentNode === undefined) {
      this.clearReferences();
      return;
    }
    const node = this.contentNode;
    this.uiContext.getPromptAction().closeCustomDialog(node)
      .then(() => {
        node.dispose();
        this.clearReferences();
      })
      .catch((_error: BusinessError) => {
        try {
          node.dispose();
        } catch (_disposeError) {
          // ignore
        }
        this.clearReferences();
      });
  }

  private clearReferences(): void {
    this.controller.dispose();
    this.showing = false;
    this.contentNode = undefined;
    if (PairingGuideDialog.current === this) {
      PairingGuideDialog.current = undefined;
    }
  }
}
