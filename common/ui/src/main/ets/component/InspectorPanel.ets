import { WindowMetricsRegistry, WindowMetricsState, WindowWidthBreakpointUtil } from 'common_platform';
import { ButtonToken } from '../token/component/ButtonToken';
import { CardToken } from '../token/component/CardToken';
import { NavigationToken } from '../token/component/NavigationToken';
import { UiResponsive } from '../token/semantic/UiResponsive';
import { UiColor } from '../token/semantic/UiColor';
import { UiTypeStyle } from '../token/semantic/UiTypeStyle';
import { UiSize } from '../token/foundation/UiSize';
import { UiSpace } from '../token/foundation/UiSpace';
import { UiOpacity } from '../token/foundation/UiOpacity';
import { UiResourceUtil } from '../util/UiResourceUtil';
import { EmptyStateModel } from '../model/EmptyStateModel';
import { EmptyStateView } from './EmptyStateView';
import { SectionTitleView } from './SectionTitleView';

/**
 * Inspector panel: split list/detail at >=600vp, inline on phone.
 * Workflow: primary fields, collapsible secondary, raw preview, sticky Save/Cancel.
 */
@ComponentV2
export struct InspectorPanel {
  @Param title: ResourceStr = '';
  @Param subtitle: ResourceStr = '';
  @Param emptyMessage: ResourceStr = $r('app.string.ui_inspector_empty');
  @Param hasSelection: boolean = false;
  @Param canSave: boolean = false;
  @Param isSaving: boolean = false;
  @Param secondaryExpanded: boolean = false;
  @BuilderParam listPane: () => void = this.defaultContent;
  @BuilderParam primaryFields: () => void = this.defaultContent;
  @BuilderParam secondaryFields: () => void = this.defaultContent;
  @BuilderParam rawPreview: () => void = this.defaultContent;
  @BuilderParam content: () => void = this.defaultContent;
  @Event onSave: () => void = () => {
  };
  @Event onCancel: () => void = () => {
  };
  @Event onSecondaryToggle: (expanded: boolean) => void = () => {
  };
  @Local private metrics: WindowMetricsState = WindowMetricsRegistry.connect();
  @Local private localSecondaryExpanded: boolean = false;

  @Builder
  defaultContent() {
  }

  build() {
    if (WindowWidthBreakpointUtil.isSplitCapable(this.metrics.breakpoint)) {
      Row({ space: UiResponsive.SECTION_GAP }) {
        Column() {
          this.listPane()
        }
        .layoutWeight(NavigationToken.SPLIT_LIST_WEIGHT)
        .height('100%')

        Column() {
          this.detailBody()
        }
        .layoutWeight(NavigationToken.SPLIT_DETAIL_WEIGHT)
        .height('100%')
      }
      .width('100%')
      .height('100%')
    } else {
      Column({ space: UiResponsive.SECTION_GAP }) {
        this.detailBody()
      }
      .width('100%')
      .height('100%')
    }
  }

  @Builder
  private detailBody() {
    Column() {
      Column({ space: UiResponsive.SECTION_GAP }) {
        SectionTitleView({
          title: UiResourceUtil.hasText(this.title) ? this.title : $r('app.string.ui_inspector_detail'),
          subtitle: this.subtitle
        })
        if (!this.hasSelection) {
          EmptyStateView({
            model: new EmptyStateModel($r('app.string.ui_inspector_not_selected'), this.emptyMessage)
          })
        } else {
          Scroll() {
            Column({ space: UiResponsive.CARD_GAP }) {
              Column({ space: UiResponsive.CONTROL_GAP }) {
                Text($r('app.string.ui_inspector_primary_section'))
                  .fontSize(UiTypeStyle.SUBTITLE_S.size)
                  .fontWeight(UiTypeStyle.SUBTITLE_S.weight)
                  .fontColor(UiColor.TEXT_PRIMARY)
                  .width('100%')
                this.primaryFields()
              }
              .width('100%')
              this.secondarySection()
              Column({ space: UiResponsive.CONTROL_GAP }) {
                Text($r('app.string.ui_inspector_raw_section'))
                  .fontSize(UiTypeStyle.SUBTITLE_S.size)
                  .fontWeight(UiTypeStyle.SUBTITLE_S.weight)
                  .fontColor(UiColor.TEXT_PRIMARY)
                  .width('100%')
                this.rawPreview()
              }
              .width('100%')
              this.content()
            }
            .width('100%')
          }
          .layoutWeight(1)
          .scrollBar(BarState.Auto)
        }
      }
      .layoutWeight(1)
      .width('100%')
      if (this.hasSelection) {
        this.stickyFooter()
      }
    }
    .width('100%')
    .height('100%')
    .padding(CardToken.PADDING)
    .backgroundColor(CardToken.BACKGROUND)
    .borderRadius(CardToken.RADIUS)
  }

  @Builder
  private secondarySection() {
    Column({ space: UiResponsive.CONTROL_GAP }) {
      Row() {
        Text($r('app.string.ui_inspector_secondary_section'))
          .fontSize(UiTypeStyle.SUBTITLE_S.size)
          .fontWeight(UiTypeStyle.SUBTITLE_S.weight)
          .fontColor(UiColor.TEXT_PRIMARY)
          .layoutWeight(1)
        Button(
          this.isSecondaryExpanded()
            ? $r('app.string.ui_inspector_collapse')
            : $r('app.string.ui_inspector_expand'),
          { type: ButtonType.Normal }
        )
          .height(UiSize.TOUCH_TARGET_MIN)
          .fontSize(UiTypeStyle.BODY_S.size)
          .fontColor(UiColor.BRAND_PRIMARY)
          .backgroundColor(Color.Transparent)
          .onClick(() => {
            const next = !this.isSecondaryExpanded();
            this.localSecondaryExpanded = next;
            this.onSecondaryToggle(next);
          })
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)
      if (this.isSecondaryExpanded()) {
        Column({ space: UiResponsive.CONTROL_GAP }) {
          this.secondaryFields()
        }
        .width('100%')
      }
    }
    .width('100%')
  }

  @Builder
  private stickyFooter() {
    Row({ space: UiSpace.M }) {
      Button($r('app.string.ui_action_cancel'), { type: ButtonType.Normal })
        .layoutWeight(1)
        .height(ButtonToken.HEIGHT)
        .fontSize(UiTypeStyle.BODY_M.size)
        .fontColor(UiColor.BRAND_PRIMARY)
        .backgroundColor(Color.Transparent)
        .border({ width: 1, color: UiColor.BORDER_PRIMARY })
        .borderRadius(ButtonToken.RADIUS)
        .enabled(!this.isSaving)
        .onClick(() => this.onCancel())
      Button(
        this.isSaving ? $r('app.string.ui_action_processing') : $r('app.string.ui_save'),
        { type: ButtonType.Normal }
      )
        .layoutWeight(1)
        .height(ButtonToken.HEIGHT)
        .fontSize(UiTypeStyle.BODY_M.size)
        .fontColor(ButtonToken.PRIMARY_FOREGROUND)
        .backgroundColor(ButtonToken.PRIMARY_BACKGROUND)
        .borderRadius(ButtonToken.RADIUS)
        .enabled(this.canSave && !this.isSaving)
        .opacity(this.canSave && !this.isSaving ? UiOpacity.ENABLED : UiOpacity.DISABLED_CONTAINER)
        .onClick(() => this.onSave())
    }
    .width('100%')
    .padding({ top: UiSpace.M })
  }

  private isSecondaryExpanded(): boolean {
    return this.secondaryExpanded || this.localSecondaryExpanded;
  }
}
