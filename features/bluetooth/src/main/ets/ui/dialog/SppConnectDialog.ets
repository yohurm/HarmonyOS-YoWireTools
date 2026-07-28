import { ComponentContent, promptAction } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { UIContextRegistry } from 'common_platform';
import {
  YoActionButton,
  YoActionButtonKind,
  YoColor,
  YoDialogToken,
  YoErrorStateModel,
  YoRadius,
  YoSpace,
  YoTypeStyle
} from 'youi_kit';
import {
  BluetoothConstants
} from 'yobluetooth';
import { ClassicDeviceListItem } from '../../viewmodel/SppMainViewModel';
import {
  SppConnectDialogController,
  SppConnectDialogParams
} from '../../viewmodel/SppConnectDialogController';

/**
 * Observed form lives on {@link SppConnectDialogParams} (controller module).
 */
@Component
struct SppConnectDialogContent {
  @ObjectLink params: SppConnectDialogParams;

  build() {
    Column() {
      Column({ space: YoSpace.L }) {
        Text($r('app.string.bt_spp_connect_dialog_title'))
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
          Text($r('app.string.bt_spp_connect_uuid_label'))
            .fontSize(YoTypeStyle.BODY_S.size)
            .fontColor(YoColor.TEXT_SECONDARY)
            .width('100%')
          TextInput({
            text: this.params.uuid,
            placeholder: $r('app.string.bt_spp_connect_uuid_placeholder')
          })
            .width('100%')
            .height(40)
            .fontSize(YoTypeStyle.BODY_S.size)
            .fontColor(YoColor.TEXT_PRIMARY)
            .fontFamily(YoTypeStyle.MONO_S.family)
            .placeholderColor(YoColor.TEXT_TERTIARY)
            .backgroundColor(YoColor.SURFACE_INPUT)
            .borderRadius(YoRadius.SMALL)
            .padding({ left: YoSpace.M, right: YoSpace.M })
            .enabled(!this.params.connecting)
            .onChange((text: string) => {
              this.params.uuid = text;
            })
        }
        .width('100%')

        Row() {
          Text($r('app.string.bt_spp_connect_secure_label'))
            .fontSize(YoTypeStyle.BODY_M.size)
            .fontColor(YoColor.TEXT_PRIMARY)
            .layoutWeight(1)
          Toggle({ type: ToggleType.Switch, isOn: this.params.secure })
            .selectedColor(YoColor.BRAND_PRIMARY)
            .enabled(!this.params.connecting)
            .onChange((isOn: boolean) => {
              this.params.secure = isOn;
            })
        }
        .width('100%')
        .alignItems(VerticalAlign.Center)

        Column({ space: YoSpace.XS }) {
          Text($r('app.string.bt_spp_connect_timeout_label'))
            .fontSize(YoTypeStyle.BODY_S.size)
            .fontColor(YoColor.TEXT_SECONDARY)
            .width('100%')
          TextInput({ text: this.params.timeoutText })
            .width('100%')
            .height(40)
            .type(InputType.Number)
            .fontSize(YoTypeStyle.BODY_S.size)
            .fontColor(YoColor.TEXT_PRIMARY)
            .backgroundColor(YoColor.SURFACE_INPUT)
            .borderRadius(YoRadius.SMALL)
            .padding({ left: YoSpace.M, right: YoSpace.M })
            .enabled(!this.params.connecting)
            .onChange((text: string) => {
              this.params.timeoutText = text;
            })
        }
        .width('100%')

        Row() {
          Text($r('app.string.bt_spp_connect_auto_reconnect_label'))
            .fontSize(YoTypeStyle.BODY_M.size)
            .fontColor(YoColor.TEXT_PRIMARY)
            .layoutWeight(1)
          Toggle({ type: ToggleType.Switch, isOn: this.params.autoReconnect })
            .selectedColor(YoColor.BRAND_PRIMARY)
            .enabled(!this.params.connecting)
            .onChange((isOn: boolean) => {
              this.params.autoReconnect = isOn;
            })
        }
        .width('100%')
        .alignItems(VerticalAlign.Center)

        if (this.params.errorMessage.length > 0) {
          Column({ space: YoSpace.XS }) {
            Text(this.params.errorMessage)
              .fontSize(YoTypeStyle.BODY_S.size)
              .fontColor(YoColor.ERROR)
              .width('100%')
            if (this.params.errorModel.appCode.length > 0 || this.params.errorModel.nativeCode.length > 0) {
              Text(this.buildErrorCodeLine())
                .fontSize(YoTypeStyle.BODY_S.size)
                .fontColor(YoColor.TEXT_TERTIARY)
                .width('100%')
            }
            ForEach(this.params.hintLines, (hint: string) => {
              Text(hint)
                .fontSize(YoTypeStyle.BODY_S.size)
                .fontColor(YoColor.TEXT_TERTIARY)
                .width('100%')
            }, (hint: string) => hint)
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)
        }

        Row({ space: YoSpace.M }) {
          YoActionButton({
            label: $r('app.string.bt_spp_action_cancel'),
            kind: YoActionButtonKind.SECONDARY,
            isEnabled: !this.params.connecting,
            onTap: () => {
              this.params.onCancel();
            }
          })
            .layoutWeight(1)
          YoActionButton({
            label: $r('app.string.bt_spp_action_connect'),
            kind: YoActionButtonKind.PRIMARY,
            loading: this.params.connecting,
            isEnabled: !this.params.connecting && this.params.classicDeviceId.length > 0,
            onTap: () => {
              this.params.onConnect();
            }
          })
            .layoutWeight(1)
        }
        .width('100%')
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

  private buildErrorCodeLine(): string {
    const parts: string[] = [];
    if (this.params.errorModel.appCode.length > 0) {
      parts.push(this.params.errorModel.appCode);
    }
    if (this.params.errorModel.nativeCode.length > 0) {
      parts.push(`native=${this.params.errorModel.nativeCode}`);
    }
    return parts.join(' · ');
  }
}

@Builder
function buildSppConnectDialogContent(params: SppConnectDialogParams) {
  SppConnectDialogContent({ params: params });
}

/**
 * App RFCOMM connect dialog (PromptAction.openCustomDialog).
 *
 * Official flow separation:
 * - System dialog: enable BT / pairDevice (connection.pairDevice) — not customizable
 * - App dialog: UUID / secure / timeout before sppConnect
 *
 * UseCase orchestration lives in {@link SppConnectDialogController}.
 */
export class SppConnectDialog {
  private static current: SppConnectDialog | undefined = undefined;

  private readonly uiContext: UIContext;
  private readonly params: SppConnectDialogParams = new SppConnectDialogParams();
  private readonly controller: SppConnectDialogController = new SppConnectDialogController();
  private contentNode: ComponentContent<SppConnectDialogParams> | undefined = undefined;
  private showing: boolean = false;

  private constructor(uiContext: UIContext) {
    this.uiContext = uiContext;
  }

  static open(
    item: ClassicDeviceListItem,
    onConnected: (sessionId: string) => void,
    uiContext?: UIContext
  ): void {
    const ctx = uiContext ?? UIContextRegistry.getInstance().get();
    if (ctx === undefined) {
      return;
    }
    if (SppConnectDialog.current !== undefined) {
      SppConnectDialog.current.close();
    }
    const dialog = new SppConnectDialog(ctx);
    dialog.params.classicDeviceId = item.classicDeviceId;
    dialog.params.displayName = item.displayName.length > 0 ? item.displayName : item.address;
    dialog.params.transport = item.transport;
    dialog.params.uuid = BluetoothConstants.DEFAULT_SPP_UUID;
    dialog.params.secure = false;
    dialog.params.timeoutText = `${BluetoothConstants.DEFAULT_SPP_CONNECT_TIMEOUT_MS}`;
    dialog.params.autoReconnect = false;
    dialog.params.connecting = false;
    dialog.params.errorMessage = '';
    dialog.params.hintLines = [];
    dialog.params.errorModel = new YoErrorStateModel();
    dialog.params.onCancel = () => {
      if (!dialog.params.connecting) {
        dialog.close();
      }
    };
    dialog.params.onConnected = (sessionId: string) => {
      dialog.close();
      onConnected(sessionId);
    };
    dialog.params.onConnect = () => {
      void dialog.controller.connectFromDialog(dialog.params);
    };
    SppConnectDialog.current = dialog;
    dialog.show();
  }

  private show(): void {
    this.contentNode = new ComponentContent(
      this.uiContext,
      wrapBuilder(buildSppConnectDialogContent),
      this.params
    );
    const options: promptAction.BaseDialogOptions = {
      alignment: DialogAlignment.Center,
      isModal: true,
      autoCancel: true,
      showInSubWindow: false,
      maskColor: YoColor.SCRIM,
      onWillDismiss: (dismissDialogAction: DismissDialogAction) => {
        if (this.params.connecting) {
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
    this.showing = false;
    this.contentNode = undefined;
    if (SppConnectDialog.current === this) {
      SppConnectDialog.current = undefined;
    }
  }
}
