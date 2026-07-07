import { EmptyStateModel } from '../model/EmptyStateModel';
import { UiSpacing } from '../theme/UiSpacing';
import { EmptyStateView } from './EmptyStateView';
/**
 * V2-compliant route placeholder while feature page UI is under construction.
 * ViewModel and navigation remain wired; only the work-area body is pending.
 */
@ComponentV2
export struct EmptyPageView {
  @Param title: string = '';
  @Param subtitle: string = '';
  build() {
    EmptyStateView({
      model: new EmptyStateModel(
        this.title.length > 0 ? this.title : '页面建设中',
        this.resolveMessage(),
        '路由与 ViewModel 已就绪',
        '',
        ''
      )
    })
      .width('100%')
      .padding({
        left: UiSpacing.PAGE_PADDING,
        right: UiSpacing.PAGE_PADDING,
        top: UiSpacing.SECTION_GAP_LARGE,
        bottom: UiSpacing.SECTION_GAP_LARGE
      })
  }
  private resolveMessage(): string {
    if (this.subtitle.length > 0) {
      return this.subtitle;
    }
    return '界面按 HarmonyOS V2 规范实现中，请稍后查看更新。';
  }
}
