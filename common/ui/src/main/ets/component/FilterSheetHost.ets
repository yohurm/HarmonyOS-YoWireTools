import { UiColorToken } from '../theme/UiColorToken';
import { UiLayoutConstants } from '../theme/UiLayoutConstants';
import { UiSpacing } from '../theme/UiSpacing';
import { UiTypography } from '../theme/UiTypography';
/** Standard bindSheet options for filter / config panels (≤480vp, dragBar). */
export interface FilterSheetBindConfig {
  onDisappear?: () => void;
  height?: SheetSize;
}
export function createFilterSheetBindOptions(config: FilterSheetBindConfig = {}): SheetOptions {
  return {
    height: config.height ?? SheetSize.MEDIUM,
    dragBar: true,
    showClose: false,
    onDisappear: config.onDisappear
  };
}
/**
 * Reusable filter sheet panel (≤480vp per UI design 06).
 * Pair with {@link createFilterSheetBindOptions} on the host node:
 * `.bindSheet(!!visible, FilterSheetHost({...}), createFilterSheetBindOptions({ onDisappear }))`
 */
@ComponentV2
export struct FilterSheetHost {
  @Param title: string = '筛选';
  @Param subtitle: string = '';
  @BuilderParam content: () => void = this.defaultContent;
  @Event onClose: () => void = () => {
  };
  @Event onApply: () => void = () => {
  };
  @Event onReset: () => void = () => {
  };
  @Builder
  defaultContent() {
  }
  build() {
    Column({ space: UiSpacing.SECTION_GAP }) {
      Row() {
        Column({ space: 2 }) {
          Text(this.title)
            .fontSize(UiTypography.TITLE_SIZE)
            .fontWeight(UiTypography.TITLE_WEIGHT)
            .fontColor(UiColorToken.TEXT_PRIMARY)
          if (this.subtitle.length > 0) {
            Text(this.subtitle)
              .fontSize(UiTypography.CAPTION_SIZE)
              .fontColor(UiColorToken.TEXT_TERTIARY)
          }
        }
        .layoutWeight(1)
        Button('关闭', { type: ButtonType.Normal })
          .height(UiLayoutConstants.TOUCH_TARGET)
          .fontSize(UiTypography.CAPTION_SIZE)
          .fontColor(UiColorToken.PRIMARY)
          .backgroundColor(Color.Transparent)
          .onClick(() => this.onClose())
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)
      Scroll() {
        Column({ space: UiSpacing.CARD_GAP }) {
          this.content()
        }
        .width('100%')
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      Row({ space: UiSpacing.ITEM_GAP }) {
        Button('重置', { type: ButtonType.Normal })
          .layoutWeight(1)
          .height(UiLayoutConstants.TOUCH_TARGET)
          .fontSize(UiTypography.BODY_SIZE)
          .fontColor(UiColorToken.PRIMARY)
          .backgroundColor(Color.Transparent)
          .border({ width: 1, color: UiColorToken.BORDER })
          .borderRadius(UiSpacing.CORNER_RADIUS)
          .onClick(() => this.onReset())
        Button('应用', { type: ButtonType.Normal })
          .layoutWeight(1)
          .height(UiLayoutConstants.TOUCH_TARGET)
          .fontSize(UiTypography.BODY_SIZE)
          .fontColor(Color.White)
          .backgroundColor(UiColorToken.PRIMARY)
          .borderRadius(UiSpacing.CORNER_RADIUS)
          .onClick(() => {
            this.onApply();
            this.onClose();
          })
      }
      .width('100%')
    }
    .width('100%')
    .constraintSize({ maxWidth: UiLayoutConstants.SHEET_MAX_WIDTH })
    .padding({
      left: UiSpacing.PAGE_PADDING,
      right: UiSpacing.PAGE_PADDING,
      top: UiSpacing.PAGE_PADDING,
      bottom: UiSpacing.PAGE_PADDING
    })
    .backgroundColor(UiColorToken.BACKGROUND)
  }
}
/**
 * Wraps a trigger node with standard filter bindSheet (≤480vp, dragBar, token colors).
 */
@ComponentV2
export struct FilterSheetBinder {
  @Param isVisible: boolean = false;
  @Param title: string = '筛选';
  @Param subtitle: string = '';
  @Param sheetHeight: SheetSize = SheetSize.MEDIUM;
  @BuilderParam anchor: () => void = this.defaultAnchor;
  @BuilderParam content: () => void = this.defaultContent;
  @Event onClose: () => void = () => {
  };
  @Event onApply: () => void = () => {
  };
  @Event onReset: () => void = () => {
  };
  @Builder
  defaultAnchor() {
  }
  @Builder
  defaultContent() {
  }
  @Builder
  private sheetPanel() {
    FilterSheetHost({
      title: this.title,
      subtitle: this.subtitle,
      content: () => {
        this.content();
      },
      onClose: () => {
        this.onClose();
      },
      onApply: () => {
        this.onApply();
      },
      onReset: () => {
        this.onReset();
      }
    })
  }
  build() {
    Row() {
      this.anchor()
    }
    .bindSheet(!!this.isVisible, this.sheetPanel(), createFilterSheetBindOptions({
      height: this.sheetHeight,
      onDisappear: () => {
        this.onClose();
      }
    }))
  }
}
