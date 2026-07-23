import {
  ItemRestriction,
  SegmentButton,
  SegmentButtonOptions,
  SegmentButtonTextItem
} from '@kit.ArkUI';

/**
 * SegmentButton tab — official call pattern + dark-safe selected text.
 *
 * Evidence (docs + GitCode + device screenshot):
 * - Design guide: 页签类选中为「白色背板」.
 * - Docs default selectedFontColor = ohos_id_color_text_primary, which becomes light in dark mode.
 * - GitCode segmentbutton.ets maps segment_button_checked_text_color → font_primary (same light-in-dark).
 * - SDK resources: dark font_primary = #e5ffffff on white/light board → unreadable selected label.
 * - Light-theme / seaxiang static default for selected text is #ff182431 (dark on white board).
 */
@Component
export struct SppTabSegmentButton {
  @Prop initialIndex: number = 0;
  onIndexChange: (index: number) => void = (_index: number) => {
  };
  @State private tabOptions: SegmentButtonOptions = SegmentButtonOptions.tab({
    buttons: [
      { text: $r('app.string.bt_spp_segment_scan') },
      { text: $r('app.string.bt_spp_segment_active') }
    ] as ItemRestriction<SegmentButtonTextItem>,
    // Keep dark ink on the white selected board in both color modes.
    selectedFontColor: '#ff182431'
  });
  @State @Watch('onTabSelectedIndexesChange') private tabSelectedIndexes: number[] = [0];

  aboutToAppear(): void {
    this.tabSelectedIndexes = [this.initialIndex];
  }

  private onTabSelectedIndexesChange(): void {
    if (this.tabSelectedIndexes.length === 0) {
      return;
    }
    this.onIndexChange(this.tabSelectedIndexes[0]);
  }

  build() {
    SegmentButton({
      options: this.tabOptions,
      selectedIndexes: $tabSelectedIndexes
    })
  }
}
