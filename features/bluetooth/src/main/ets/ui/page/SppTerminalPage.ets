import { WindowMetricsRegistry, WindowMetricsState, WindowWidthBreakpointUtil } from 'common_platform';
import { LineEndingMode, PayloadEncoding } from 'debug_core';
import {
  YoActionButton,
  YoActionButtonKind,
  YoChipToken,
  YoColor,
  YoNavDestinationKind,
  YoPageShell,
  YoRadius,
  YoSize,
  YoSpace,
  YoStroke,
  YoTitleBarMenuItem,
  YoTypeStyle
} from 'youi_kit';
import {
  openSppTerminalMoreMenu,
  SPP_TERMINAL_MORE_MENU_ID
} from '../menu/SppTerminalMoreMenu';
import { SppActiveSessionItem } from '../../viewmodel/SppMainViewModel';
import {
  SppTerminalDisplayMode,
  SppTerminalLogEntry,
  SppTerminalLogKind,
  SppTerminalViewModel
} from '../../viewmodel/SppTerminalViewModel';

/** Compact terminal toggle chip (encoding / line ending / display mode). */
@ComponentV2
struct SppTerminalToggleChip {
  @Param label: ResourceStr = '';
  @Param selected: boolean = false;
  @Event onTap: () => void = () => {
  };

  build() {
    Text(this.label)
      .fontSize(YoTypeStyle.BODY_S.size)
      .fontWeight(this.selected ? FontWeight.Medium : FontWeight.Regular)
      .fontColor(this.selected ? YoColor.BRAND_PRIMARY : YoColor.TEXT_SECONDARY)
      .padding({
        left: YoSpace.M,
        right: YoSpace.M,
        top: YoSpace.XS,
        bottom: YoSpace.XS
      })
      .backgroundColor(this.selected ? YoColor.SURFACE_SELECTED : YoColor.BACKGROUND_SECONDARY)
      .borderRadius(YoChipToken.STATUS_RADIUS)
      .onClick(() => {
        this.onTap();
      })
  }
}

/**
 * SPP terminal — industry layout (Serial Bluetooth Terminal / nRF Serial Terminal):
 * compact status strip → session chips → full-height log → bottom composer
 * (encoding + line ending + input + send). Overflow menu: clear / disconnect.
 */
@ComponentV2
export struct SppTerminalPage {
  @Param sessionId: string = '';
  @Event onBack: () => void = () => {
  };
  @Local private vm: SppTerminalViewModel = new SppTerminalViewModel();
  @Local private metrics: WindowMetricsState = WindowMetricsRegistry.connect();
  @Local private logScroller: Scroller = new Scroller();

  aboutToAppear(): void {
    this.vm.bindSessionId(this.sessionId);
    this.vm.logAppendListener = (): void => {
      this.scrollLogToBottom();
    };
    this.vm.onPageAppear();
  }

  aboutToDisappear(): void {
    this.vm.logAppendListener = (): void => {
    };
    this.vm.onPageDisappear();
  }

  private pageHorizontalPadding(): number {
    return WindowWidthBreakpointUtil.pagePaddingVp(this.metrics.breakpoint);
  }

  private bytesSummary(): string {
    return `RX ${this.vm.bytesIn} · TX ${this.vm.bytesOut}`;
  }

  /** 状态条设备名：去掉会话标题里的「SPP 」前缀。 */
  private statusDeviceName(): string {
    let name = this.vm.displayName.trim();
    if (name.length >= 4 && name.substring(0, 4).toUpperCase() === 'SPP ') {
      name = name.substring(4).trim();
    }
    return name;
  }

  /** 第一行：设备名 · MAC */
  private statusTitleLine(): string {
    const name = this.statusDeviceName();
    const mac = this.vm.classicAddress.trim();
    if (name.length > 0 && mac.length > 0) {
      return `${name} · ${mac}`;
    }
    if (name.length > 0) {
      return name;
    }
    return mac;
  }

  /** 第二行：完整服务 UUID */
  private statusUuidLine(): string {
    return this.vm.serviceUuid.trim();
  }

  /** Chip label: name + UUID short so same-device multi-UUID sessions stay distinct. */
  private sessionChipLabel(item: SppActiveSessionItem): string {
    const name = item.displayName.length > 0 ? item.displayName : item.classicAddress;
    if (item.uuidShortLabel.length === 0) {
      return name.length > 0 ? name : item.sessionId;
    }
    if (name.length === 0) {
      return item.uuidShortLabel;
    }
    return `${name} · ${item.uuidShortLabel}`;
  }

  private logLineColor(kind: SppTerminalLogKind): ResourceColor {
    if (kind === 'rx') {
      return YoColor.SUCCESS;
    }
    if (kind === 'tx') {
      return YoColor.BRAND_PRIMARY;
    }
    return YoColor.TEXT_TERTIARY;
  }

  private draftPlaceholder(): ResourceStr {
    if (this.vm.sendEncoding === PayloadEncoding.HEX) {
      return $r('app.string.bt_spp_terminal_hex_placeholder');
    }
    return $r('app.string.bt_command_placeholder');
  }

  private scrollLogToBottom(): void {
    setTimeout((): void => {
      this.logScroller.scrollEdge(Edge.Bottom);
    }, 16);
  }

  private buildTitleMenus(): YoTitleBarMenuItem[] {
    return [
      new YoTitleBarMenuItem(
        'more',
        $r('sys.symbol.more'),
        $r('app.string.youi_more_actions'),
        () => {
          openSppTerminalMoreMenu(
            this.getUIContext(),
            SPP_TERMINAL_MORE_MENU_ID,
            () => {
              this.vm.clearLog();
            },
            () => {
              void this.handleDisconnect();
            },
            !this.vm.disconnecting
          );
        },
        true,
        SPP_TERMINAL_MORE_MENU_ID
      )
    ];
  }

  @LocalBuilder
  pageContent() {
    Column() {
      Row({ space: YoSpace.M }) {
        Column({ space: YoSpace.XXS }) {
          Text(this.statusTitleLine().length > 0 ?
            this.statusTitleLine() :
            $r('app.string.bt_spp_device_unknown_name'))
            .fontSize(YoTypeStyle.BODY_M.size)
            .fontWeight(FontWeight.Medium)
            .fontColor(YoColor.TEXT_PRIMARY)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .width('100%')
          if (this.statusUuidLine().length > 0) {
            Text(this.statusUuidLine())
              .fontSize(YoTypeStyle.BODY_S.size)
              .fontColor(YoColor.TEXT_TERTIARY)
              .fontFamily(YoTypeStyle.MONO_S.family)
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .width('100%')
          }
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)

        Text(this.bytesSummary())
          .fontSize(YoTypeStyle.BODY_S.size)
          .fontColor(YoColor.TEXT_TERTIARY)
          .fontFamily(YoTypeStyle.MONO_S.family)
      }
      .width('100%')
      .padding({
        left: this.pageHorizontalPadding(),
        right: this.pageHorizontalPadding(),
        top: YoSpace.M,
        bottom: YoSpace.S
      })
      .alignItems(VerticalAlign.Center)

      if (this.vm.sessions.length > 1) {
        Scroll() {
          Row({ space: YoSpace.S }) {
            ForEach(this.vm.sessions, (item: SppActiveSessionItem) => {
              Button(this.sessionChipLabel(item), { type: ButtonType.Capsule })
                .fontSize(YoTypeStyle.BODY_S.size)
                .fontColor(item.sessionId === this.vm.focusSessionId ?
                  YoColor.BRAND_PRIMARY :
                  YoColor.TEXT_SECONDARY)
                .backgroundColor(item.sessionId === this.vm.focusSessionId ?
                  YoColor.SURFACE_SELECTED :
                  YoColor.BACKGROUND_SECONDARY)
                .height(32)
                .padding({ left: YoSpace.M, right: YoSpace.M })
                .onClick(() => {
                  this.vm.setFocusSession(item.sessionId);
                })
            }, (item: SppActiveSessionItem) => item.sessionId)
          }
          .padding({
            left: this.pageHorizontalPadding(),
            right: this.pageHorizontalPadding()
          })
        }
        .scrollable(ScrollDirection.Horizontal)
        .scrollBar(BarState.Off)
        .width('100%')
        .padding({ bottom: YoSpace.S })
      }

      Column() {
        Row({ space: YoSpace.S }) {
          SppTerminalToggleChip({
            label: $r('app.string.bt_spp_terminal_display_text'),
            selected: this.vm.displayMode === SppTerminalDisplayMode.TEXT,
            onTap: () => {
              this.vm.setDisplayMode(SppTerminalDisplayMode.TEXT);
            }
          })
          SppTerminalToggleChip({
            label: $r('app.string.bt_spp_terminal_display_hex'),
            selected: this.vm.displayMode === SppTerminalDisplayMode.HEX,
            onTap: () => {
              this.vm.setDisplayMode(SppTerminalDisplayMode.HEX);
            }
          })
          SppTerminalToggleChip({
            label: $r('app.string.bt_spp_terminal_display_mixed'),
            selected: this.vm.displayMode === SppTerminalDisplayMode.MIXED,
            onTap: () => {
              this.vm.setDisplayMode(SppTerminalDisplayMode.MIXED);
            }
          })
          Blank()
          Text($r('app.string.bt_spp_terminal_clear'))
            .fontSize(YoTypeStyle.BODY_S.size)
            .fontColor(YoColor.TEXT_SECONDARY)
            .padding({
              left: YoSpace.M,
              right: YoSpace.M,
              top: YoSpace.XS,
              bottom: YoSpace.XS
            })
            .onClick(() => {
              this.vm.clearLog();
            })
        }
        .width('100%')
        .padding({
          left: YoSpace.M,
          right: YoSpace.M,
          top: YoSpace.S,
          bottom: YoSpace.S
        })

        Divider()
          .color(YoColor.DIVIDER)
          .strokeWidth(YoStroke.THIN)

        if (this.vm.logEntries.length === 0) {
          Column({ space: YoSpace.S }) {
            Text($r('app.string.bt_terminal_empty'))
              .fontSize(YoTypeStyle.BODY_M.size)
              .fontColor(YoColor.TEXT_SECONDARY)
            Text($r('app.string.bt_spp_terminal_empty_hint'))
              .fontSize(YoTypeStyle.BODY_S.size)
              .fontColor(YoColor.TEXT_TERTIARY)
              .textAlign(TextAlign.Center)
          }
          .width('100%')
          .layoutWeight(1)
          .justifyContent(FlexAlign.Center)
          .padding(YoSpace.XL)
        } else {
          Scroll(this.logScroller) {
            Column({ space: YoSpace.XXS }) {
              ForEach(this.vm.logEntries, (entry: SppTerminalLogEntry) => {
                Text(this.vm.formatLogEntry(entry))
                  .fontSize(YoTypeStyle.BODY_S.size)
                  .fontColor(this.logLineColor(entry.kind))
                  .fontFamily(YoTypeStyle.MONO_S.family)
                  .width('100%')
              }, (entry: SppTerminalLogEntry) => entry.id)
            }
            .width('100%')
            .padding(YoSpace.M)
            .alignItems(HorizontalAlign.Start)
          }
          .width('100%')
          .layoutWeight(1)
          .scrollBar(BarState.Auto)
          .align(Alignment.TopStart)
        }
      }
      .width('100%')
      .layoutWeight(1)
      .backgroundColor(YoColor.SURFACE_INPUT)
      .borderRadius(YoRadius.MEDIUM)
      .clip(true)
      .margin({
        left: this.pageHorizontalPadding(),
        right: this.pageHorizontalPadding()
      })

      if (this.vm.sendError.length > 0) {
        Text(this.vm.sendError)
          .fontSize(YoTypeStyle.BODY_S.size)
          .fontColor(YoColor.ERROR)
          .width('100%')
          .padding({
            left: this.pageHorizontalPadding(),
            right: this.pageHorizontalPadding(),
            top: YoSpace.S
          })
      }

      Column({ space: YoSpace.S }) {
        Scroll() {
          Row({ space: YoSpace.S }) {
            SppTerminalToggleChip({
              label: $r('app.string.bt_spp_terminal_encoding_text'),
              selected: this.vm.sendEncoding === PayloadEncoding.TEXT,
              onTap: () => {
                this.vm.setSendEncoding(PayloadEncoding.TEXT);
              }
            })
            SppTerminalToggleChip({
              label: $r('app.string.bt_spp_terminal_encoding_hex'),
              selected: this.vm.sendEncoding === PayloadEncoding.HEX,
              onTap: () => {
                this.vm.setSendEncoding(PayloadEncoding.HEX);
              }
            })
            Divider()
              .vertical(true)
              .height(16)
              .color(YoColor.DIVIDER)
              .margin({ left: YoSpace.XS, right: YoSpace.XS })
            SppTerminalToggleChip({
              label: $r('app.string.bt_spp_terminal_line_none'),
              selected: this.vm.lineEnding === LineEndingMode.NONE,
              onTap: () => {
                this.vm.setLineEnding(LineEndingMode.NONE);
              }
            })
            SppTerminalToggleChip({
              label: $r('app.string.bt_spp_terminal_line_cr'),
              selected: this.vm.lineEnding === LineEndingMode.CR,
              onTap: () => {
                this.vm.setLineEnding(LineEndingMode.CR);
              }
            })
            SppTerminalToggleChip({
              label: $r('app.string.bt_spp_terminal_line_lf'),
              selected: this.vm.lineEnding === LineEndingMode.LF,
              onTap: () => {
                this.vm.setLineEnding(LineEndingMode.LF);
              }
            })
            SppTerminalToggleChip({
              label: $r('app.string.bt_spp_terminal_line_crlf'),
              selected: this.vm.lineEnding === LineEndingMode.CRLF,
              onTap: () => {
                this.vm.setLineEnding(LineEndingMode.CRLF);
              }
            })
          }
        }
        .scrollable(ScrollDirection.Horizontal)
        .scrollBar(BarState.Off)
        .width('100%')

        Row({ space: YoSpace.S }) {
          TextInput({
            text: this.vm.draftText,
            placeholder: this.draftPlaceholder()
          })
            .layoutWeight(1)
            .height(YoSize.BUTTON_HEIGHT_COMPACT)
            .fontSize(YoTypeStyle.BODY_S.size)
            .fontColor(YoColor.TEXT_PRIMARY)
            .fontFamily(YoTypeStyle.MONO_S.family)
            .placeholderColor(YoColor.TEXT_TERTIARY)
            .backgroundColor(YoColor.SURFACE_INPUT)
            .borderRadius(YoRadius.SMALL)
            .padding({ left: YoSpace.M, right: YoSpace.M })
            .onChange((text: string) => {
              this.vm.setDraftText(text);
            })

          YoActionButton({
            label: $r('app.string.bt_spp_action_send'),
            kind: YoActionButtonKind.PRIMARY,
            compact: true,
            fullWidth: false,
            loading: this.vm.sending,
            isEnabled: !this.vm.sending && this.vm.draftText.length > 0,
            onTap: () => {
              void this.vm.send();
            }
          })
        }
        .width('100%')
        .alignItems(VerticalAlign.Center)
      }
      .width('100%')
      .padding({
        left: this.pageHorizontalPadding(),
        right: this.pageHorizontalPadding(),
        top: YoSpace.M,
        bottom: this.metrics.navigationBottomInsetVp + YoSpace.M
      })
    }
    .width('100%')
    .height('100%')
  }

  build() {
    YoPageShell({
      title: $r('app.string.bt_spp_terminal_page_title'),
      showBack: true,
      destinationKind: YoNavDestinationKind.MODULE,
      scrollable: false,
      contentEdgeToEdge: true,
      immersiveTitleBar: true,
      titleBarMenus: this.buildTitleMenus(),
      onBack: this.onBack,
      content: this.pageContent
    })
  }

  private async handleDisconnect(): Promise<void> {
    await this.vm.disconnect();
    this.onBack();
  }
}
