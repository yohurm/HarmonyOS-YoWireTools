import { WindowMetricsRegistry, WindowMetricsState, WindowWidthBreakpointUtil } from 'common_platform';

import { TerminalToken } from '../token/component/TerminalToken';

import { UiColor } from '../token/semantic/UiColor';

import { UiTypeStyle } from '../token/semantic/UiTypeStyle';

import { UiResponsive } from '../token/semantic/UiResponsive';

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

  @Param minHeight: number = TerminalToken.MIN_HEIGHT;

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

    .backgroundColor(TerminalToken.BACKGROUND)

    .borderRadius(TerminalToken.RADIUS)

    .clip(true)

  }

  @Builder

  private emptyBody() {

    Column() {

      Text(UiResourceUtil.hasText(this.emptyHint) ? this.emptyHint : $r('app.string.ui_empty_default_title'))

        .fontSize(UiTypeStyle.MONO_S.size)

        .fontColor(UiColor.TEXT_TERTIARY)

        .fontFamily(UiTypeStyle.MONO_S.family)

    }

    .width('100%')

    .layoutWeight(1)

    .justifyContent(FlexAlign.Center)

    .padding(UiResponsive.CARD_CONTENT_PADDING)

  }

  @Builder

  private terminalRow(row: DataTerminalLine) {

    Row({ space: UiResponsive.CONTROL_GAP }) {

      Text(row.direction)

        .fontSize(UiTypeStyle.MONO_S.size)

        .fontWeight(UiTypeStyle.SUBTITLE_S.weight)

        .fontColor(this.resolveDirectionColor(row.direction))

        .fontFamily(UiTypeStyle.MONO_S.family)

        .width(TerminalToken.DIRECTION_WIDTH)

      if (row.timestamp.length > 0) {

        Text(row.timestamp)

          .fontSize(UiTypeStyle.MONO_S.size)

          .fontColor(UiColor.TEXT_TERTIARY)

          .fontFamily(UiTypeStyle.MONO_S.family)

          .maxLines(1)

      }

      Text(row.summary)

        .fontSize(UiTypeStyle.MONO_S.size)

        .fontColor(this.resolveSummaryColor(row.direction))

        .fontFamily(UiTypeStyle.MONO_S.family)

        .layoutWeight(1)

        .maxLines(4)

        .textOverflow({ overflow: TextOverflow.Ellipsis })

      if (row.sizeBytes > 0) {

        Text(UiResourceUtil.format($r('app.string.ui_terminal_bytes_format'), row.sizeBytes))

          .fontSize(UiTypeStyle.MONO_S.size)

          .fontColor(UiColor.TEXT_TERTIARY)

          .fontFamily(UiTypeStyle.MONO_S.family)

      }

    }

    .width('100%')

    .padding({

      left: WindowWidthBreakpointUtil.pagePaddingVp(this.metrics.breakpoint),

      right: WindowWidthBreakpointUtil.pagePaddingVp(this.metrics.breakpoint),

      top: TerminalToken.ROW_PADDING_V,

      bottom: TerminalToken.ROW_PADDING_V

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

      return TerminalToken.OUTBOUND;

    }

    if (direction === 'RX') {

      return TerminalToken.INBOUND;

    }

    return UiColor.TEXT_TERTIARY;

  }

  private resolveSummaryColor(direction: DataTerminalDirection): ResourceColor {

    if (direction === 'SYS') {

      return UiColor.TEXT_TERTIARY;

    }

    return UiColor.TEXT_PRIMARY;

  }

}

