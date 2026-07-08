import { WindowMetricsRegistry, WindowMetricsState, WindowWidthBreakpointUtil } from 'common_platform';
import { UiColorToken } from '../theme/UiColorToken';
import { UiLayoutConstants } from '../theme/UiLayoutConstants';
import { UiSpacing } from '../theme/UiSpacing';
import { UiTypography } from '../theme/UiTypography';
import { UiResourceUtil } from '../util/UiResourceUtil';

export type DataTerminalDirection = 'TX' | 'RX' | 'SYS';
/** Structured terminal log row aligned with DataTerminal spec. */
export class DataTerminalLine {
  readonly direction: DataTerminalDirection;
  readonly timestamp: string;
  readonly summary: string;
  readonly sizeBytes: number;
  constructor(
    direction: DataTerminalDirection,
    timestamp: string,
    summary: string,
    sizeBytes: number = 0
  ) {
    this.direction = direction;
    this.timestamp = timestamp;
    this.summary = summary;
    this.sizeBytes = sizeBytes;
  }
  static fromPlain(text: string): DataTerminalLine {
    return new DataTerminalLine('SYS', '', text, 0);
  }
  static fromDirectionSummary(
    direction: DataTerminalDirection,
    summary: string,
    sizeBytes: number = 0,
    timestamp: string = ''
  ): DataTerminalLine {
    return new DataTerminalLine(direction, timestamp, summary, sizeBytes);
  }
}
/**
 * Scrollable log / terminal output area (DataTerminal).
 * Supports plain string lines or structured {@link DataTerminalLine} entries.
 */
@ComponentV2
export struct DataTerminalView {
  @Param lines: string[] = [];
  @Param entries: DataTerminalLine[] = [];
  @Param minHeight: number = UiLayoutConstants.TERMINAL_MIN_HEIGHT;
  @Param emptyHint: ResourceStr = '';
  @Local private metrics: WindowMetricsState = WindowMetricsRegistry.connect();
  build() {
    Column() {
      if (this.resolveRows().length === 0) {
        this.emptyBody()
      } else {
        List({ space: 0 }) {
          ForEach(this.resolveRows(), (row: DataTerminalLine, index: number) => {
            ListItem() {
              this.terminalRow(row)
            }
          }, (row: DataTerminalLine, index: number) => `${index}-${row.direction}-${row.summary}`)
        }
        .width('100%')
        .layoutWeight(1)
        .scrollBar(BarState.Auto)
        .edgeEffect(EdgeEffect.Spring)
      }
    }
    .width('100%')
    .constraintSize({ minHeight: this.minHeight })
    .layoutWeight(1)
    .backgroundColor(UiColorToken.TERMINAL_BACKGROUND)
    .borderRadius(UiLayoutConstants.CARD_RADIUS)
    .clip(true)
  }
  @Builder
  private emptyBody() {
    Column() {
      Text(UiResourceUtil.hasText(this.emptyHint) ? this.emptyHint : $r('app.string.ui_empty_default_title'))
        .fontSize(UiTypography.CAPTION_SIZE)
        .fontColor(UiColorToken.TEXT_TERTIARY)
        .fontFamily(UiTypography.MONO_FONT_FAMILY)
    }
    .width('100%')
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
    .padding(UiSpacing.PAGE_PADDING)
  }
  @Builder
  private terminalRow(row: DataTerminalLine) {
    Row({ space: UiSpacing.ITEM_GAP }) {
      Text(row.direction)
        .fontSize(UiTypography.CAPTION_SIZE)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.resolveDirectionColor(row.direction))
        .fontFamily(UiTypography.MONO_FONT_FAMILY)
        .width(UiLayoutConstants.TERMINAL_DIRECTION_WIDTH)
      if (row.timestamp.length > 0) {
        Text(row.timestamp)
          .fontSize(UiTypography.CAPTION_SIZE)
          .fontColor(UiColorToken.TEXT_TERTIARY)
          .fontFamily(UiTypography.MONO_FONT_FAMILY)
          .maxLines(1)
      }
      Text(row.summary)
        .fontSize(UiTypography.CAPTION_SIZE)
        .fontColor(this.resolveSummaryColor(row.direction))
        .fontFamily(UiTypography.MONO_FONT_FAMILY)
        .layoutWeight(1)
        .maxLines(4)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
      if (row.sizeBytes > 0) {
        Text(`${row.sizeBytes}B`)
          .fontSize(UiTypography.CAPTION_SIZE)
          .fontColor(UiColorToken.TEXT_TERTIARY)
          .fontFamily(UiTypography.MONO_FONT_FAMILY)
      }
    }
    .width('100%')
    .padding({
      left: WindowWidthBreakpointUtil.pagePaddingVp(this.metrics.breakpoint),
      right: WindowWidthBreakpointUtil.pagePaddingVp(this.metrics.breakpoint),
      top: UiSpacing.TERMINAL_ROW_PADDING_V,
      bottom: UiSpacing.TERMINAL_ROW_PADDING_V
    })
  }
  private resolveRows(): DataTerminalLine[] {
    if (this.entries.length > 0) {
      return this.entries;
    }
    const rows: DataTerminalLine[] = [];
    for (let i = 0; i < this.lines.length; i++) {
      rows.push(DataTerminalLine.fromPlain(this.lines[i]));
    }
    return rows;
  }
  private resolveDirectionColor(direction: DataTerminalDirection): ResourceColor {
    if (direction === 'TX') {
      return UiColorToken.PRIMARY;
    }
    if (direction === 'RX') {
      return UiColorToken.SUCCESS;
    }
    return UiColorToken.TEXT_TERTIARY;
  }
  private resolveSummaryColor(direction: DataTerminalDirection): ResourceColor {
    if (direction === 'SYS') {
      return UiColorToken.TEXT_TERTIARY;
    }
    return UiColorToken.TEXT_PRIMARY;
  }
}
