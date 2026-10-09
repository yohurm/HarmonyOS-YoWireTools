import { SessionState, SessionUiFormat } from 'debug_core';
import {
  YoCardToken,
  YoColor,
  YoListToken,
  YoSpace,
  YoStatusPill,
  YoStatusPillTone,
  YoTypeStyle
} from 'youi_kit';
import { HomeSessionCopy } from '../copy/HomeSessionCopy';

@ComponentV2
export struct HomeSessionRowView {
  @Param title: string = '';
  @Param protocol: string = '';
  @Param state: SessionState = SessionState.CREATED;
  @Param showDivider: boolean = false;
  @Event onTap: () => void = () => {
  };

  build() {
    Column() {
      Row({ space: YoSpace.M }) {
        Column({ space: YoSpace.XS }) {
          if (this.title.length > 0) {
            Text(this.title)
              .fontSize(YoTypeStyle.SUBTITLE_S.size)
              .fontWeight(YoTypeStyle.SUBTITLE_S.weight)
              .fontColor(YoColor.TEXT_PRIMARY)
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .width('100%')
            Text(HomeSessionCopy.protocolLabel(this.protocol))
              .fontSize(YoTypeStyle.BODY_S.size)
              .fontColor(YoColor.TEXT_SECONDARY)
              .maxLines(1)
              .width('100%')
          } else {
            Text(HomeSessionCopy.protocolLabel(this.protocol))
              .fontSize(YoTypeStyle.SUBTITLE_S.size)
              .fontWeight(YoTypeStyle.SUBTITLE_S.weight)
              .fontColor(YoColor.TEXT_PRIMARY)
              .maxLines(1)
              .width('100%')
          }
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
        YoStatusPill({
          label: SessionUiFormat.stateLabel(this.state),
          tone: this.resolveTone()
        })
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
      .onClick(() => {
        this.onTap();
      })
      if (this.showDivider) {
        Divider()
          .strokeWidth(YoListToken.DIVIDER_STROKE)
          .color(YoColor.BORDER_PRIMARY)
          .margin({ left: YoCardToken.PADDING_COMPACT })
      }
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  private resolveTone(): YoStatusPillTone {
    const tone = SessionUiFormat.stateTone(this.state);
    if (tone === 'success') {
      return 'success';
    }
    if (tone === 'error') {
      return 'error';
    }
    if (tone === 'warning') {
      return 'warning';
    }
    return 'neutral';
  }
}
