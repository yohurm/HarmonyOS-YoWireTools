import {
  YoCardToken,
  YoColor,
  YoResourceUtil,
  YoSize,
  YoSpace,
  YoTypeStyle,
  YoActionButton,
  YoActionButtonKind
} from 'youi_kit';
import { ClassicDeviceSymbolResolver } from '../util/ClassicDeviceSymbolResolver';

/**
 * Classic Bluetooth device row.
 *
 * Layout:
 * [Symbol] | name / MAC | rssi / pair / transport | [Connect]
 * Radius: YoCardToken.RADIUS (YoRadius.MEDIUM / 16vp).
 */
@ComponentV2
export struct ClassicDeviceCard {
  @Param displayName: ResourceStr = '';
  @Param address: string = '';
  @Param rssiText: string = '';
  @Param statusLabel: ResourceStr = '';
  @Param transportLabel: ResourceStr = '';
  @Param majorClass: number = 0;
  @Param majorMinorClass: number = 0;
  @Param showConnectButton: boolean = true;
  @Param connectEnabled: boolean = false;
  @Event onConnect: () => void = () => {
  };
  @Event onTap: () => void = () => {
  };

  build() {
    Row({ space: YoSpace.M }) {
      Row({ space: YoSpace.M }) {
        SymbolGlyph(ClassicDeviceSymbolResolver.resolve(this.majorClass, this.majorMinorClass))
          .fontSize(YoSize.ICON_L)
          .fontColor([YoColor.TEXT_SECONDARY])
          .fontWeight(FontWeight.Medium)

        Column({ space: YoSpace.XXS }) {
          Text(this.displayName)
            .fontSize(YoTypeStyle.BODY_M.size)
            .fontWeight(YoTypeStyle.BODY_M.weight)
            .fontColor(YoColor.TEXT_PRIMARY)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .width('100%')
          if (this.address.length > 0) {
            Text(this.address)
              .fontSize(YoTypeStyle.BODY_S.size)
              .fontColor(YoColor.TEXT_SECONDARY)
              .fontFamily(YoTypeStyle.MONO_S.family)
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .width('100%')
          }
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)

        Column({ space: YoSpace.XXS }) {
          if (this.rssiText.length > 0) {
            Text(this.rssiText)
              .fontSize(YoTypeStyle.BODY_S.size)
              .fontColor(YoColor.TEXT_SECONDARY)
              .fontFamily(YoTypeStyle.MONO_S.family)
              .maxLines(1)
          }
          if (YoResourceUtil.hasText(this.statusLabel)) {
            Text(this.statusLabel)
              .fontSize(YoTypeStyle.BODY_S.size)
              .fontColor(YoColor.TEXT_TERTIARY)
              .maxLines(1)
          }
          if (YoResourceUtil.hasText(this.transportLabel)) {
            Text(this.transportLabel)
              .fontSize(YoTypeStyle.BODY_S.size)
              .fontColor(YoColor.TEXT_TERTIARY)
              .maxLines(1)
          }
        }
        .alignItems(HorizontalAlign.End)
        .constraintSize({ minWidth: 48 })
      }
      .layoutWeight(1)
      .alignItems(VerticalAlign.Center)
      .onClick(() => this.onTap())

      if (this.showConnectButton) {
        YoActionButton({
          label: $r('app.string.bt_spp_action_connect'),
          kind: YoActionButtonKind.SECONDARY,
          compact: true,
          fullWidth: false,
          isEnabled: this.connectEnabled,
          onTap: () => {
            if (this.connectEnabled) {
              this.onConnect();
            }
          }
        })
      }
    }
    .width('100%')
    .constraintSize({ minHeight: YoCardToken.HEIGHT_DEVICE_ROW })
    .padding({
      left: YoCardToken.PADDING_COMPACT,
      right: YoCardToken.PADDING_COMPACT,
      top: YoCardToken.PADDING_ROW_V,
      bottom: YoCardToken.PADDING_ROW_V
    })
    .backgroundColor(YoCardToken.BACKGROUND)
    .borderRadius(YoCardToken.RADIUS)
    .shadow(YoCardToken.SHADOW_COMPACT)
    .accessibilityGroup(true)
    .accessibilityText(this.buildAccessibilityLabel())
  }

  private buildAccessibilityLabel(): string {
    let label = YoResourceUtil.resolveText(this.displayName);
    if (this.address.length > 0) {
      label = YoResourceUtil.format($r('app.string.youi_a11y_join_two'), label, this.address);
    }
    if (this.rssiText.length > 0) {
      label = YoResourceUtil.format($r('app.string.youi_a11y_join_two'), label, this.rssiText);
    }
    if (YoResourceUtil.hasText(this.statusLabel)) {
      label = YoResourceUtil.format(
        $r('app.string.youi_a11y_join_two'),
        label,
        YoResourceUtil.resolveText(this.statusLabel)
      );
    }
    if (YoResourceUtil.hasText(this.transportLabel)) {
      label = YoResourceUtil.format(
        $r('app.string.youi_a11y_join_two'),
        label,
        YoResourceUtil.resolveText(this.transportLabel)
      );
    }
    return label;
  }
}
