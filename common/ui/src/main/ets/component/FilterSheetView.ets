import { WindowMetricsRegistry, WindowMetricsState, WindowWidthBreakpointUtil } from 'common_platform';
import { UiColor } from '../token/semantic/UiColor';
import { UiResponsive } from '../token/semantic/UiResponsive';
import { UiTypeStyle } from '../token/semantic/UiTypeStyle';
import { UiSpace } from '../token/foundation/UiSpace';
import { UiSize } from '../token/foundation/UiSize';
import { UiResourceUtil } from '../util/UiResourceUtil';
import { SegmentChipView } from './SegmentChipView';
import { SessionChipView } from './SessionChipView';
import { StatusPillTone } from './StatusPillView';

/** Filter chip option for scan / log filter bars. */
export class FilterChipOption {
  readonly key: string;
  readonly label: ResourceStr;
  readonly selected: boolean;
  readonly tone: StatusPillTone;

  constructor(
    key: string,
    label: ResourceStr,
    selected: boolean = false,
    tone: StatusPillTone = 'brand'
  ) {
    this.key = key;
    this.label = label;
    this.selected = selected;
    this.tone = tone;
  }
}

/**
 * Horizontal filter chip bar (FilterSheet companion — not a sheet wrapper).
 */
@ComponentV2
export struct FilterSheetView {
  @Param title: ResourceStr = '';
  @Param options: FilterChipOption[] = [];
  @Param useSessionStyle: boolean = false;
  @Param showClear: boolean = false;
  @Param clearLabel: ResourceStr = $r('app.string.ui_clear');
  @Event onOptionSelect: (key: string) => void = () => {
  };
  @Event onClear: () => void = () => {
  };
  @Local private metrics: WindowMetricsState = WindowMetricsRegistry.connect();

  build() {
    Column({ space: UiResponsive.CONTROL_GAP }) {
      if (UiResourceUtil.hasText(this.title) || this.showClear) {
        Row() {
          if (UiResourceUtil.hasText(this.title)) {
            Text(this.title)
              .fontSize(UiTypeStyle.BODY_S.size)
              .fontColor(UiColor.TEXT_SECONDARY)
              .layoutWeight(1)
          } else {
            Blank().layoutWeight(1)
          }
          if (this.showClear) {
            Button(this.clearLabel, { type: ButtonType.Normal })
              .fontSize(UiTypeStyle.BODY_S.size)
              .fontColor(UiColor.BRAND_PRIMARY)
              .backgroundColor(Color.Transparent)
              .constraintSize({ minHeight: UiSize.TOUCH_TARGET_MIN })
              .onClick(() => this.onClear())
          }
        }
        .width('100%')
        .alignItems(VerticalAlign.Center)
      }
      Scroll() {
        Row({ space: UiResponsive.CONTROL_GAP }) {
          ForEach(this.options, (option: FilterChipOption) => {
            if (this.useSessionStyle && option.selected) {
              SessionChipView({
                label: option.label,
                tone: option.tone,
                onTap: () => this.onOptionSelect(option.key)
              })
            } else {
              SegmentChipView({
                label: option.label,
                selected: option.selected,
                onSelect: () => this.onOptionSelect(option.key)
              })
            }
          }, (option: FilterChipOption) => option.key)
        }
        .padding({ right: WindowWidthBreakpointUtil.pagePaddingVp(this.metrics.breakpoint) })
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .width('100%')
    }
    .width('100%')
    .padding({ left: WindowWidthBreakpointUtil.pagePaddingVp(this.metrics.breakpoint) })
  }
}
