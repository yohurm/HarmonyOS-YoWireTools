import {
  YoCardToken,
  YoColor,
  YoListToken,
  YoResourceUtil,
  YoSize,
  YoSpace,
  YoTypeStyle,
  YoStatusPill
} from 'youi_kit';
import { ClassicDeviceSymbolResolver } from '../util/ClassicDeviceSymbolResolver';

/**
 * 设备行在分组列表中的位置。
 * - standalone：独立浮卡（兼容旧用法）
 * - only / first / middle / last：同一表面内的效率型分组行
 */
export type ClassicDeviceGroupRole = 'standalone' | 'only' | 'first' | 'middle' | 'last';

/**
 * Classic Bluetooth device row — HarmonyOS 效率型列表密度。
 *
 * 自底而上功能排布（扫描模式）：
 * ┌────────────────────────────────────────────────────────────┐
 * │ [Symbol]  设备名                         -62 dBm / --  [连接] │
 * │           MAC                            已配对  经典/双模    │
 * │           Profile: SPP · A2DP · HFP                          │
 * └────────────────────────────────────────────────────────────┘
 * 尾区信号栈：上 RSSI（无值显示 --）；下「已配对」在传输类型左侧。
 * Profile 行属经典扫描展示能力，不是 SPP socket 状态。
 */
@ComponentV2
export struct ClassicDeviceCard {
  @Param displayName: ResourceStr = '';
  @Param address: string = '';
  @Param rssiText: string = '';
  @Param statusLabel: ResourceStr = '';
  @Param transportLabel: ResourceStr = '';
  /** Profile 能力短文案；空则不占行。 */
  @Param profileCapabilitiesText: string = '';
  @Param majorClass: number = 0;
  @Param majorMinorClass: number = 0;
  @Param showConnectButton: boolean = true;
  @Param connectEnabled: boolean = false;
  /** 覆盖连接按钮文案；默认「连接」。 */
  @Param connectButtonLabel: ResourceStr = $r('app.string.bt_spp_action_connect');
  /** 已配对：显示在尾区传输类型左侧，不贴 MAC。 */
  @Param isPaired: boolean = false;
  /** 状态是否为需强调的警告（如需桥接）。 */
  @Param statusWarning: boolean = false;
  /** 无连接按钮时显示右箭头，提示可进入会话。 */
  @Param showDisclosure: boolean = false;
  @Param groupRole: ClassicDeviceGroupRole = 'standalone';
  @Event onConnect: () => void = () => {
  };
  @Event onTap: () => void = () => {
  };

  build() {
    Column() {
      Row({ space: YoCardToken.TRAILING_GAP }) {
        SymbolGlyph(ClassicDeviceSymbolResolver.resolve(this.majorClass, this.majorMinorClass))
          .fontSize(YoSize.ICON_M)
          .fontColor([YoColor.ICON_SECONDARY])
          .fontWeight(FontWeight.Medium)
          .width(YoSize.ICON_M)
          .height(YoSize.ICON_M)

        Column({ space: YoSpace.XXS }) {
          Text(this.displayName)
            .fontSize(YoTypeStyle.BODY_M.size)
            .fontWeight(FontWeight.Medium)
            .fontColor(YoColor.TEXT_PRIMARY)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .width('100%')

          Row({ space: YoSpace.XS }) {
            if (this.address.length > 0) {
              Text($r('app.string.bt_address_virtual'))
                .fontSize(YoTypeStyle.BODY_S.size)
                .fontColor(YoColor.TEXT_TERTIARY)
              Text(this.address)
                .fontSize(YoTypeStyle.BODY_S.size)
                .fontColor(YoColor.TEXT_SECONDARY)
                .fontFamily(YoTypeStyle.MONO_S.family)
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .layoutWeight(1)
            }
            if (YoResourceUtil.hasText(this.statusLabel) && this.statusWarning) {
              YoStatusPill({
                label: this.statusLabel,
                tone: 'warning'
              })
            } else if (!this.showConnectButton && YoResourceUtil.hasText(this.statusLabel)) {
              Text(this.statusLabel)
                .fontSize(YoTypeStyle.BODY_S.size)
                .fontColor(YoColor.TEXT_TERTIARY)
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
            }
          }
          .width('100%')
          .alignItems(VerticalAlign.Center)
          .clip(true)

          if (this.profileCapabilitiesText.length > 0) {
            Text(this.profileCapabilitiesText)
              .fontSize(YoTypeStyle.BODY_S.size)
              .fontColor(YoColor.TEXT_TERTIARY)
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .width('100%')
          }
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
        .onClick(() => this.onTap())

        Row({ space: YoSpace.M }) {
          if (this.shouldShowSignalStack()) {
            Column({ space: YoSpace.XXS }) {
              Text(this.resolveRssiText())
                .fontSize(YoTypeStyle.BODY_S.size)
                .fontColor(YoColor.TEXT_SECONDARY)
                .fontFamily(YoTypeStyle.MONO_S.family)
                .maxLines(1)

              if (this.shouldShowBottomMetaRow()) {
                Row({ space: YoSpace.XS }) {
                  if (this.isPaired) {
                    Text($r('app.string.bt_spp_status_paired'))
                      .fontSize(YoTypeStyle.BODY_S.size)
                      .fontColor(YoColor.TEXT_TERTIARY)
                      .maxLines(1)
                  }
                  if (this.isPaired && YoResourceUtil.hasText(this.transportLabel)) {
                    Text('·')
                      .fontSize(YoTypeStyle.BODY_S.size)
                      .fontColor(YoColor.TEXT_TERTIARY)
                  }
                  if (YoResourceUtil.hasText(this.transportLabel)) {
                    Text(this.transportLabel)
                      .fontSize(YoTypeStyle.BODY_S.size)
                      .fontColor(YoColor.TEXT_TERTIARY)
                      .maxLines(1)
                  }
                }
                .justifyContent(FlexAlign.End)
                .alignItems(VerticalAlign.Center)
              }
            }
            .alignItems(HorizontalAlign.End)
          }

          if (this.showConnectButton) {
            Button(this.connectButtonLabel, { type: ButtonType.Capsule })
              .fontSize(YoTypeStyle.BODY_S.size)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.connectEnabled ? YoColor.BRAND_PRIMARY : YoColor.TEXT_DISABLED)
              .backgroundColor(this.connectEnabled ? YoColor.SURFACE_SELECTED : YoColor.BACKGROUND_SECONDARY)
              .height(32)
              .padding({ left: YoSpace.L, right: YoSpace.L })
              .constraintSize({ minWidth: YoSize.TOUCH_TARGET_MIN, minHeight: YoSize.TOUCH_TARGET_MIN })
              .enabled(this.connectEnabled)
              .onClick(() => {
                if (this.connectEnabled) {
                  this.onConnect();
                }
              })
          } else if (this.showDisclosure) {
            SymbolGlyph($r('sys.symbol.chevron_right'))
              .fontSize(YoSize.ICON_S)
              .fontColor([YoColor.ICON_TERTIARY])
              .width(YoSize.ICON_S)
              .height(YoSize.ICON_S)
          }
        }
        .alignItems(VerticalAlign.Center)
      }
      .width('100%')
      .constraintSize({ minHeight: YoCardToken.HEIGHT_DEVICE_ROW })
      .padding({
        left: YoCardToken.PADDING_COMPACT,
        right: YoCardToken.PADDING_COMPACT,
        top: YoCardToken.PADDING_ROW_V,
        bottom: YoCardToken.PADDING_ROW_V
      })
      .alignItems(VerticalAlign.Center)

      if (this.shouldShowDivider()) {
        Divider()
          .color(YoColor.DIVIDER)
          .strokeWidth(YoListToken.DIVIDER_STROKE)
          .margin({ left: YoListToken.DIVIDER_INSET_LEADING })
      }
    }
    .width('100%')
    .backgroundColor(YoCardToken.BACKGROUND)
    .borderRadius(this.resolveBorderRadius())
    .clip(true)
    .accessibilityGroup(true)
    .accessibilityText(this.buildAccessibilityLabel())
  }

  /** 扫描行始终展示 RSSI 栈；活动会话无 RSSI/传输/配对时不占位。 */
  private shouldShowSignalStack(): boolean {
    return this.showConnectButton ||
      this.rssiText.length > 0 ||
      this.shouldShowBottomMetaRow();
  }

  /** 尾区第二行：已配对在传输类型左侧。 */
  private shouldShowBottomMetaRow(): boolean {
    return this.isPaired || YoResourceUtil.hasText(this.transportLabel);
  }

  private resolveRssiText(): string {
    if (this.rssiText.length > 0) {
      return this.rssiText;
    }
    return '--';
  }

  private shouldShowDivider(): boolean {
    return this.groupRole === 'first' || this.groupRole === 'middle';
  }

  private resolveBorderRadius(): BorderRadiuses | number {
    const r = YoCardToken.RADIUS;
    if (this.groupRole === 'standalone' || this.groupRole === 'only') {
      return r;
    }
    if (this.groupRole === 'first') {
      return { topLeft: r, topRight: r, bottomLeft: 0, bottomRight: 0 };
    }
    if (this.groupRole === 'last') {
      return { topLeft: 0, topRight: 0, bottomLeft: r, bottomRight: r };
    }
    return 0;
  }

  private buildAccessibilityLabel(): string {
    let label = YoResourceUtil.resolveText(this.displayName);
    if (this.address.length > 0) {
      label = YoResourceUtil.format($r('app.string.youi_a11y_join_two'), label, this.address);
    }
    label = YoResourceUtil.format($r('app.string.youi_a11y_join_two'), label, this.resolveRssiText());
    if (this.isPaired) {
      label = YoResourceUtil.format(
        $r('app.string.youi_a11y_join_two'),
        label,
        YoResourceUtil.resolveText($r('app.string.bt_spp_status_paired'))
      );
    }
    if (YoResourceUtil.hasText(this.transportLabel)) {
      label = YoResourceUtil.format(
        $r('app.string.youi_a11y_join_two'),
        label,
        YoResourceUtil.resolveText(this.transportLabel)
      );
    }
    if (this.profileCapabilitiesText.length > 0) {
      label = YoResourceUtil.format(
        $r('app.string.youi_a11y_join_two'),
        label,
        this.profileCapabilitiesText
      );
    }
    if (YoResourceUtil.hasText(this.statusLabel) && this.statusWarning) {
      label = YoResourceUtil.format(
        $r('app.string.youi_a11y_join_two'),
        label,
        YoResourceUtil.resolveText(this.statusLabel)
      );
    }
    return label;
  }
}
