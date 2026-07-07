import { EmptyStateModel } from '../model/EmptyStateModel';
import { EmptyStateView } from './EmptyStateView';
import { SectionTitleView } from './SectionTitleView';
import { UiColorToken } from '../theme/UiColorToken';
import { UiLayoutConstants } from '../theme/UiLayoutConstants';
import { UiSpacing } from '../theme/UiSpacing';
/**
 * V2 wide-screen inspector: list left, detail/actions right. Mobile degrades to inline or Sheet.
 */
@ComponentV2
export struct InspectorPanel {
  @Param title: string = '';
  @Param subtitle: string = '';
  @Param emptyMessage: string = '从列表中选择一项以查看详情';
  @Param hasSelection: boolean = false;
  @BuilderParam content: () => void = this.defaultContent;
  @Builder
  defaultContent() {
  }
  build() {
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
