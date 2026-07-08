import { WindowMetricsRegistry, WindowMetricsState, WindowWidthBreakpointUtil } from 'common_platform';
import { UiSpacing } from '../theme/UiSpacing';
import { UiTypography } from '../theme/UiTypography';
import { UiColorToken } from '../theme/UiColorToken';
import { SegmentChipView } from './SegmentChipView';
import { SessionChipView } from './SessionChipView';
import { StatusPillTone } from './StatusPillView';
/** Filter chip option for scan / log filter bars. */
export class FilterChipOption {
  readonly key: string;
  readonly label: string;
  readonly selected: boolean;
  readonly tone: StatusPillTone;
  constructor(
    key: string,
    label: string,
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
 * Uses SegmentChipView for toggles; active session-style chips when {@link useSessionStyle}.
 */
@ComponentV2
export struct FilterSheetView {
  @Param title: string = '';
  @Param options: FilterChipOption[] = [];
  @Param useSessionStyle: boolean = false;
  @Param showClear: boolean = false;
  @Param clearLabel: string = '清除';
  @Event onOptionSelect: (key: string) => void = () => {
  };
  @Event onClear: () => void = () => {
  };
  @Local private metrics: WindowMetricsState = WindowMetricsRegistry.connect();
  build() {
    Column({ space: UiSpacing.ITEM_GAP }) {
      if (this.title.length > 0 || this.showClear) {
        Row() {
          if (this.title.length > 0) {
            Text(this.title)
              .fontSize(UiTypography.CAPTION_SIZE)
              .fontColor(UiColorToken.TEXT_SECONDARY)
              .layoutWeight(1)
          } else {
            Blank().layoutWeight(1)
          }
          if (this.showClear) {
            Text(this.clearLabel)
              .fontSize(UiTypography.CAPTION_SIZE)
              .fontColor(UiColorToken.PRIMARY)
              .padding({ left: 8, right: 8, top: 8, bottom: 8 })
              .onClick(() => this.onClear())
          }
        }
        .width('100%')
        .alignItems(VerticalAlign.Center)
      }
      Scroll() {
        Row({ space: UiSpacing.ITEM_GAP }) {
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
