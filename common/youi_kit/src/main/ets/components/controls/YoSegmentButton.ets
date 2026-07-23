import {
  ItemRestriction,
  SegmentButton,
  SegmentButtonOptions,
  SegmentButtonTextItem
} from '@kit.ArkUI';
import { YoSegmentToken } from '../../token/component/YoSegmentToken';

/**
 * 系统 SegmentButton 门面（Tab 样式）。
 *
 * - 不在 SegmentButton 上链式挂通用属性（官方约束）。
 * - 外层布局负责 width / padding。
 * - 使用 @Component + $selectedIndexes 实现滑动动画（V1 绑定）。
 */
@Component
export struct YoSegmentButton {
  @Prop labels: ResourceStr[] = [];
  @Prop initialIndex: number = 0;
  onSelectedIndexChange: (index: number) => void = (_index: number) => {
  };
  // 类型检查阶段 ItemRestriction 要求 2..N 项；真实标签在 aboutToAppear 中写入。
  @State private tabOptions: SegmentButtonOptions = SegmentButtonOptions.tab({
    buttons: [
      { text: '' },
      { text: '' }
    ] as ItemRestriction<SegmentButtonTextItem>,
    selectedFontColor: YoSegmentToken.SELECTED_FONT_COLOR,
    buttonPadding: {
      top: YoSegmentToken.BUTTON_PADDING_V,
      right: YoSegmentToken.BUTTON_PADDING_H,
      bottom: YoSegmentToken.BUTTON_PADDING_V,
      left: YoSegmentToken.BUTTON_PADDING_H
    }
  });
  @State @Watch('onTabSelectedIndexesChange') private tabSelectedIndexes: number[] = [0];

  aboutToAppear(): void {
    this.rebuildOptions();
    this.tabSelectedIndexes = [this.initialIndex];
  }

  private rebuildOptions(): void {
    const buttons: SegmentButtonTextItem[] = [];
    for (let i = 0; i < this.labels.length; i++) {
      buttons.push({ text: this.labels[i] });
    }
    // SegmentButton Tab 模式至少需要 2 项。
    while (buttons.length < 2) {
      buttons.push({ text: '' });
    }
    this.tabOptions = SegmentButtonOptions.tab({
      buttons: buttons as ItemRestriction<SegmentButtonTextItem>,
      selectedFontColor: YoSegmentToken.SELECTED_FONT_COLOR,
      buttonPadding: {
        top: YoSegmentToken.BUTTON_PADDING_V,
        right: YoSegmentToken.BUTTON_PADDING_H,
        bottom: YoSegmentToken.BUTTON_PADDING_V,
        left: YoSegmentToken.BUTTON_PADDING_H
      }
    });
  }

  private onTabSelectedIndexesChange(): void {
    if (this.tabSelectedIndexes.length === 0) {
      return;
    }
    this.onSelectedIndexChange(this.tabSelectedIndexes[0]);
  }

  build() {
    SegmentButton({
      options: this.tabOptions,
      selectedIndexes: $tabSelectedIndexes
    })
  }
}
