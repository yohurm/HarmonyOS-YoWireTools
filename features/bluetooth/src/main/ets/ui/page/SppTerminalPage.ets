import { WindowMetricsRegistry, WindowMetricsState, WindowWidthBreakpointUtil } from 'common_platform';
import {
  YoActionButton,
  YoActionButtonKind,
  YoColor,
  YoNavDestinationKind,
  YoPageShell,
  YoRadius,
  YoSpace,
  YoTypeStyle
} from 'youi_kit';
import { SppActiveSessionItem } from '../../viewmodel/SppMainViewModel';
import { SppTerminalViewModel } from '../../viewmodel/SppTerminalViewModel';

/**
 * SPP terminal page — focusSessionId, SessionSwitcher, send/recv TextArea.
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
    this.vm.onPageAppear();
  }

  aboutToDisappear(): void {
    this.vm.onPageDisappear();
  }

  private pageHorizontalPadding(): number {
    return WindowWidthBreakpointUtil.pagePaddingVp(this.metrics.breakpoint);
  }

  private bytesSummary(): string {
    return `RX ${this.vm.bytesIn} · TX ${this.vm.bytesOut}`;
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

  @LocalBuilder
  pageContent() {
    Column({ space: YoSpace.M }) {
      Column({ space: YoSpace.XS }) {
        Text(this.vm.displayName.length > 0 ?
          this.vm.displayName :
          $r('app.string.bt_spp_device_unknown_name'))
          .fontSize(YoTypeStyle.BODY_M.size)
          .fontWeight(FontWeight.Medium)
          .fontColor(YoColor.TEXT_PRIMARY)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')
        Text(this.vm.classicAddress)
          .fontSize(YoTypeStyle.BODY_S.size)
          .fontColor(YoColor.TEXT_SECONDARY)
          .fontFamily(YoTypeStyle.MONO_S.family)
          .width('100%')
        Row({ space: YoSpace.S }) {
          if (this.vm.uuidShortLabel.length > 0) {
            Text(this.vm.uuidShortLabel)
              .fontSize(YoTypeStyle.BODY_S.size)
              .fontColor(YoColor.TEXT_TERTIARY)
          }
          Text(this.vm.stateLabel)
            .fontSize(YoTypeStyle.BODY_S.size)
            .fontColor(YoColor.TEXT_TERTIARY)
          Blank()
          Text(this.bytesSummary())
            .fontSize(YoTypeStyle.BODY_S.size)
            .fontColor(YoColor.TEXT_TERTIARY)
            .fontFamily(YoTypeStyle.MONO_S.family)
        }
        .width('100%')
        .alignItems(VerticalAlign.Center)
      }
      .width('100%')
      .padding({
        left: this.pageHorizontalPadding(),
        right: this.pageHorizontalPadding()
      })

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
      }

      Column() {
        if (this.vm.logText.length === 0) {
          Text($r('app.string.bt_terminal_empty'))
            .fontSize(YoTypeStyle.BODY_S.size)
            .fontColor(YoColor.TEXT_TERTIARY)
            .width('100%')
            .padding(YoSpace.M)
        } else {
          Scroll(this.logScroller) {
            Text(this.vm.logText)
              .fontSize(YoTypeStyle.BODY_S.size)
              .fontColor(YoColor.TEXT_PRIMARY)
              .fontFamily(YoTypeStyle.MONO_S.family)
              .width('100%')
              .padding(YoSpace.M)
          }
          .width('100%')
          .height('100%')
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
            right: this.pageHorizontalPadding()
          })
      }

      Row({ space: YoSpace.S }) {
        TextInput({
          text: this.vm.draftText,
          placeholder: $r('app.string.bt_command_placeholder')
        })
          .layoutWeight(1)
          .height(40)
          .fontSize(YoTypeStyle.BODY_S.size)
          .fontColor(YoColor.TEXT_PRIMARY)
          .placeholderColor(YoColor.TEXT_TERTIARY)
          .backgroundColor(YoColor.SURFACE_INPUT)
          .borderRadius(YoRadius.SMALL)
          .padding({ left: YoSpace.M, right: YoSpace.M })
          .onChange((text: string) => {
            this.vm.setDraftText(text);
          })

        Button($r('app.string.bt_spp_action_send'), { type: ButtonType.Capsule })
          .fontSize(YoTypeStyle.BODY_S.size)
          .fontWeight(FontWeight.Medium)
          .fontColor(YoColor.BRAND_PRIMARY)
          .backgroundColor(YoColor.SURFACE_SELECTED)
          .height(40)
          .padding({ left: YoSpace.L, right: YoSpace.L })
          .enabled(!this.vm.sending && this.vm.draftText.length > 0)
          .onClick(() => {
            void this.vm.send();
          })
      }
      .width('100%')
      .padding({
        left: this.pageHorizontalPadding(),
        right: this.pageHorizontalPadding()
      })

      Row({ space: YoSpace.M }) {
        YoActionButton({
          label: $r('app.string.bt_spp_terminal_clear'),
          kind: YoActionButtonKind.SECONDARY,
          compact: true,
          onTap: () => {
            this.vm.clearLog();
          }
        })
          .layoutWeight(1)
        YoActionButton({
          label: $r('app.string.bt_spp_action_disconnect'),
          kind: YoActionButtonKind.DANGER,
          compact: true,
          loading: this.vm.disconnecting,
          isEnabled: !this.vm.disconnecting,
          onTap: () => {
            void this.handleDisconnect();
          }
        })
          .layoutWeight(1)
      }
      .width('100%')
      .padding({
        left: this.pageHorizontalPadding(),
        right: this.pageHorizontalPadding(),
        bottom: this.metrics.navigationBottomInsetVp + YoSpace.M
      })
    }
    .width('100%')
    .height('100%')
    .padding({ top: YoSpace.M })
  }

  build() {
    YoPageShell({
      title: $r('app.string.bt_spp_terminal_page_title'),
      showBack: true,
      destinationKind: YoNavDestinationKind.MODULE,
      scrollable: false,
      immersiveTitleBar: true,
      onBack: this.onBack,
      content: this.pageContent
    })
  }

  private async handleDisconnect(): Promise<void> {
    await this.vm.disconnect();
    this.onBack();
  }
}
