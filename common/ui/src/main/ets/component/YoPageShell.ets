import { hdsMaterial, HdsNavigation, HdsNavigationTitleMode, ScrollEffectType } from '@kit.UIDesignKit';
import { YoNavDestinationKind } from '../shell/YoNavDestinationKind';
import { UiColorToken } from '../theme/UiColorToken';
import { UiLayoutConstants } from '../theme/UiLayoutConstants';
import { UiSpacing } from '../theme/UiSpacing';
import { UiTypography } from '../theme/UiTypography';
import { UiResourceUtil } from '../util/UiResourceUtil';
import { YoContextStrip, YoContextStripItem } from './YoContextStrip';
/**
 * V2 four-zone page shell: Header + ContextStrip + WorkArea + ActionDock.
 * Replaces PageScaffold and TopNavigationPageContainer for standard pages.
 * Pass @BuilderParam slots with arrow functions so builder `this` stays on the caller.
 */
@ComponentV2
export struct YoPageShell {
  @Param title: ResourceStr = '';
  @Param subtitle: ResourceStr = '';
  @Param showBack: boolean = false;
  @Param destinationKind: YoNavDestinationKind = YoNavDestinationKind.ROOT_TAB;
  @Param contextItems: YoContextStripItem[] = [];
  @Param contextRiskMessage: ResourceStr = '';
  @Param scrollable: boolean = true;
  @Param bottomPaddingVp: number = -1;
  @BuilderParam content: () => void = this.defaultContent;
  @BuilderParam actionDock: () => void = this.defaultActionDock;
  @Event onBack: () => void = () => {
  };
  private scroller: Scroller = new Scroller();
  @Local materialLevel: hdsMaterial.MaterialLevel = hdsMaterial.MaterialLevel.EXQUISITE;
  aboutToAppear(): void {
    const types = hdsMaterial.getSystemMaterialTypes();
    if (types.indexOf(hdsMaterial.MaterialType.IMMERSIVE) < 0) {
      this.materialLevel = hdsMaterial.MaterialLevel.SMOOTH;
    }
  }
  @Builder
  defaultContent() {
  }
  @Builder
  defaultActionDock() {
  }
  build() {
    Column() {
      HdsNavigation() {
        if (this.scrollable) {
          Scroll(this.scroller) {
            Column({ space: UiSpacing.SECTION_GAP }) {
              if (UiResourceUtil.hasText(this.subtitle)) {
                Text(this.subtitle)
                  .fontSize(UiTypography.CAPTION_SIZE)
                  .fontColor(UiColorToken.TEXT_SECONDARY)
                  .width('100%')
                  .padding({
                    left: UiSpacing.PAGE_PADDING,
                    right: UiSpacing.PAGE_PADDING
                  })
                  .maxLines(2)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
              }
              YoContextStrip({
                items: this.contextItems,
                riskMessage: this.contextRiskMessage
              })
              Column() {
                this.content()
              }
              .width('100%')
            }
            .width('100%')
            .padding({ bottom: this.resolveBottomPadding() })
          }
          .width('100%')
          .height('100%')
          .scrollBar(BarState.Auto)
          .clipContent(ContentClipMode.SAFE_AREA)
        } else {
          Column({ space: UiSpacing.SECTION_GAP }) {
            YoContextStrip({
              items: this.contextItems,
              riskMessage: this.contextRiskMessage
            })
            Column() {
              this.content()
            }
            .width('100%')
            .layoutWeight(1)
          }
          .width('100%')
          .height('100%')
          .padding({ bottom: this.resolveBottomPadding() })
        }
      }
      .titleBar({
        avoidLayoutSafeArea: true,
        enableComponentSafeArea: true,
        style: {
          scrollEffectOpts: {
            enableScrollEffect: this.scrollable,
            scrollEffectType: ScrollEffectType.COMMON_BLUR
          },
          systemMaterialEffect: {
            materialType: hdsMaterial.MaterialType.ADAPTIVE,
            materialLevel: this.materialLevel
          }
        },
        content: {
          title: { mainTitle: this.title },
          backIcon: this.showBack ? { action: (): void => { this.onBack(); } } : undefined
        }
      })
      .bindToScrollable(this.scrollable ? [this.scroller] : [])
      .titleMode(HdsNavigationTitleMode.MINI)
      .hideBackButton(!this.showBack)
      .ignoreLayoutSafeArea([LayoutSafeAreaType.SYSTEM], [LayoutSafeAreaEdge.TOP])
      .width('100%')
      .layoutWeight(1)
      .backgroundColor(UiColorToken.BACKGROUND)
      this.actionDock()
    }
    .width('100%')
    .height('100%')
    .backgroundColor(UiColorToken.BACKGROUND)
  }
  private resolveBottomPadding(): number {
    if (this.bottomPaddingVp >= 0) {
      return this.bottomPaddingVp;
    }
    if (this.destinationKind === YoNavDestinationKind.ROOT_TAB) {
      return UiLayoutConstants.FLOATING_TAB_BOTTOM_PADDING;
    }
    return UiLayoutConstants.NAV_BAR_AVOID + UiSpacing.FORM_GAP;
  }
}
export { YoContextStripItem };
