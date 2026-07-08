import { WindowMetricsRegistry, WindowMetricsState, WindowWidthBreakpointUtil } from 'common_platform';
import { EmptyStateModel } from '../model/EmptyStateModel';
import { EmptyStateView } from './EmptyStateView';
import { SectionTitleView } from './SectionTitleView';
import { UiColorToken } from '../theme/UiColorToken';
import { UiLayoutConstants } from '../theme/UiLayoutConstants';
import { UiSpacing } from '../theme/UiSpacing';

/**
 * Inspector panel: split list/detail at >=600vp, inline on phone.
 */
@ComponentV2
export struct InspectorPanel {
  @Param title: string = '';
  @Param subtitle: string = '';
  @Param emptyMessage: string = '从列表中选择一项以查看详情';
  @Param hasSelection: boolean = false;
  @BuilderParam listPane: () => void = this.defaultContent;
  @BuilderParam content: () => void = this.defaultContent;
  @Local private metrics: WindowMetricsState = WindowMetricsRegistry.connect();

  @Builder
  defaultContent() {
  }

  build() {
    if (WindowWidthBreakpointUtil.isSplitCapable(this.metrics.breakpoint)) {
      Row({ space: UiSpacing.SECTION_GAP }) {
        Column() {
          this.listPane()
        }
        .layoutWeight(UiLayoutConstants.SPLIT_LIST_WEIGHT)
        .height('100%')

        Column() {
          this.detailBody()
        }
        .layoutWeight(UiLayoutConstants.SPLIT_DETAIL_WEIGHT)
        .height('100%')
      }
      .width('100%')
      .height('100%')
    } else {
      Column({ space: UiSpacing.SECTION_GAP }) {
        this.detailBody()
      }
      .width('100%')
      .height('100%')
    }
  }

  @Builder
  private detailBody() {
    Column({ space: UiSpacing.SECTION_GAP }) {
      SectionTitleView({
        title: this.title.length > 0 ? this.title : '详情',
        subtitle: this.subtitle
      })
      if (!this.hasSelection) {
        EmptyStateView({
          model: new EmptyStateModel('未选择', this.emptyMessage)
        })
      } else {
        Column({ space: UiSpacing.CARD_GAP }) {
          this.content()
        }
        .width('100%')
      }
    }
    .width('100%')
    .height('100%')
    .padding(UiSpacing.CARD_INNER_PADDING)
    .backgroundColor(UiColorToken.SURFACE)
    .borderRadius(UiLayoutConstants.CARD_RADIUS_SMALL)
  }
}
