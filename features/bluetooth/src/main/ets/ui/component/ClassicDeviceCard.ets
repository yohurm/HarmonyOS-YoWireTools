import {
  CardToken,
  UiColor,
  UiResourceUtil,
  UiSize,
  UiSpace,
  UiTypeStyle,
  YoActionButton,
  YoActionButtonKind
} from 'common_ui';
import { ClassicDeviceSymbolResolver } from '../util/ClassicDeviceSymbolResolver';

/**
 * Classic Bluetooth device row.
 *
 * Layout:
 * [Symbol] | name / MAC | rssi / pair / transport | [Connect]
 * Radius: CardToken.RADIUS_DEVICE_ROW (UiRadius.SMALL / 8vp).
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
    Row({ space: UiSpace.M }) {
      Row({ space: UiSpace.M }) {
        SymbolGlyph(ClassicDeviceSymbolResolver.resolve(this.majorClass, this.majorMinorClass))
          .fontSize(UiSize.ICON_L)
          .fontColor([UiColor.TEXT_SECONDARY])
          .fontWeight(FontWeight.Medium)

        Column({ space: UiSpace.XXS }) {
          Text(this.displayName)
            .fontSize(UiTypeStyle.BODY_M.size)
            .fontWeight(UiTypeStyle.BODY_M.weight)
            .fontColor(UiColor.TEXT_PRIMARY)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .width('100%')
          if (this.address.length > 0) {
            Text(this.address)
              .fontSize(UiTypeStyle.BODY_S.size)
              .fontColor(UiColor.TEXT_SECONDARY)
              .fontFamily(UiTypeStyle.MONO_S.family)
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .width('100%')
          }
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)

        Column({ space: UiSpace.XXS }) {
          if (this.rssiText.length > 0) {
            Text(this.rssiText)
              .fontSize(UiTypeStyle.BODY_S.size)
              .fontColor(UiColor.TEXT_SECONDARY)
              .fontFamily(UiTypeStyle.MONO_S.family)
              .maxLines(1)
          }
          if (UiResourceUtil.hasText(this.statusLabel)) {
            Text(this.statusLabel)
              .fontSize(UiTypeStyle.BODY_S.size)
              .fontColor(UiColor.TEXT_TERTIARY)
              .maxLines(1)
          }
          if (UiResourceUtil.hasText(this.transportLabel)) {
            Text(this.transportLabel)
              .fontSize(UiTypeStyle.BODY_S.size)
              .fontColor(UiColor.TEXT_TERTIARY)
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
    .constraintSize({ minHeight: CardToken.HEIGHT_DEVICE_ROW })
    .padding({
      left: CardToken.PADDING_COMPACT,
      right: CardToken.PADDING_COMPACT,
      top: CardToken.PADDING_ROW_V,
      bottom: CardToken.PADDING_ROW_V
    })
    .backgroundColor(CardToken.BACKGROUND)
    .borderRadius(CardToken.RADIUS_DEVICE_ROW)
    .shadow(CardToken.SHADOW_COMPACT)
    .accessibilityGroup(true)
    .accessibilityText(this.buildAccessibilityLabel())
  }

  private buildAccessibilityLabel(): string {
    let label = UiResourceUtil.resolveText(this.displayName);
    if (this.address.length > 0) {
      label = UiResourceUtil.format($r('app.string.ui_a11y_join_two'), label, this.address);
    }
    if (this.rssiText.length > 0) {
      label = UiResourceUtil.format($r('app.string.ui_a11y_join_two'), label, this.rssiText);
    }
    if (UiResourceUtil.hasText(this.statusLabel)) {
      label = UiResourceUtil.format(
        $r('app.string.ui_a11y_join_two'),
        label,
        UiResourceUtil.resolveText(this.statusLabel)
      );
    }
    if (UiResourceUtil.hasText(this.transportLabel)) {
      label = UiResourceUtil.format(
        $r('app.string.ui_a11y_join_two'),
        label,
        UiResourceUtil.resolveText(this.transportLabel)
      );
    }
    return label;
  }
}
