import { ComponentContent, promptAction } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { UIContextRegistry } from 'common_platform';
import {
  YoActionButton,
  YoActionButtonKind,
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
 * Observed form lives on {@link PairingGuideDialogParams} (controller module).
 */
@Component
struct PairingGuideDialogContent {
  @ObjectLink params: PairingGuideDialogParams;

  build() {
    Column() {
      Column({ space: YoSpace.L }) {
        Text($r('app.string.bt_pairing_guide_title'))
          .fontSize(YoTypeStyle.TITLE_S.size)
          .fontWeight(FontWeight.Medium)
          .fontColor(YoColor.TEXT_PRIMARY)
          .width('100%')

        Column({ space: YoSpace.XS }) {
          Text($r('app.string.bt_spp_connect_device_label'))
            .fontSize(YoTypeStyle.BODY_S.size)
            .fontColor(YoColor.TEXT_TERTIARY)
            .width('100%')
          Text(this.params.displayName)
            .fontSize(YoTypeStyle.BODY_M.size)
            .fontWeight(FontWeight.Medium)
            .fontColor(YoColor.TEXT_PRIMARY)
            .width('100%')
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
          Text(this.params.classicDeviceId)
            .fontSize(YoTypeStyle.BODY_S.size)
            .fontColor(YoColor.TEXT_SECONDARY)
            .fontFamily(YoTypeStyle.MONO_S.family)
            .width('100%')
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)

        Column({ space: YoSpace.XS }) {
          Text($r('app.string.bt_pairing_guide_body'))
            .fontSize(YoTypeStyle.BODY_S.size)
            .fontColor(YoColor.TEXT_SECONDARY)
            .width('100%')
          Text($r('app.string.bt_pairing_hint_pin'))
            .fontSize(YoTypeStyle.BODY_S.size)
            .fontColor(YoColor.TEXT_TERTIARY)
            .width('100%')
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)

        if (this.params.errorMessage.length > 0) {
          Text(this.params.errorMessage)
            .fontSize(YoTypeStyle.BODY_S.size)
            .fontColor(YoColor.ERROR)
            .width('100%')
        }

        Row({ space: YoSpace.M }) {
          YoActionButton({
            label: $r('app.string.bt_spp_action_cancel'),
            kind: YoActionButtonKind.SECONDARY,
            isEnabled: !this.params.pairing,
            onTap: () => {
              this.params.onCancel();
            }
          })
            .layoutWeight(1)
          YoActionButton({
            label: this.params.hasAttempted || this.params.errorMessage.length > 0 ?
              $r('app.string.bt_pairing_action_retry') :
              $r('app.string.bt_pairing_action_pair'),
            kind: YoActionButtonKind.PRIMARY,
            loading: this.params.pairing,
            isEnabled: !this.params.pairing && this.params.classicDeviceId.length > 0,
            onTap: () => {
              this.params.onPair();
            }
          })
            .layoutWeight(1)
        }
        .width('100%')

        YoActionButton({
          label: $r('app.string.bt_pairing_action_open_settings'),
          kind: YoActionButtonKind.TEXT,
          isEnabled: !this.params.pairing,
          onTap: () => {
            this.params.onOpenSettings();
          }
        })
      }
      .width('100%')
      .constraintSize({ maxWidth: YoDialogToken.MAX_WIDTH })
      .padding(YoDialogToken.CONTENT_PADDING)
      .borderRadius(YoDialogToken.RADIUS)
      .backgroundColor(YoColor.SURFACE_CARD)
    }
    .width('100%')
    .padding({ left: YoSpace.XXL, right: YoSpace.XXL })
  }
}

@Builder
function buildPairingGuideDialogContent(params: PairingGuideDialogParams) {
  PairingGuideDialogContent({ params: params });
}

/**
 * App pairing guide (PromptAction.openCustomDialog).
 *
 * Official flow separation:
 * - System dialog: pairDevice / PIN — not customizable, never faked here
 * - App dialog: explain + trigger pair / retry / open Bluetooth settings
 *
 * UseCase orchestration + bond truth live in {@link SppPairingGuideController}.
 * Promise success ≠ paired; close + open Connect only after PairingState.PAIRED.
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
