import {
  ItemRestriction,
  SegmentButton,
  SegmentButtonOptions,
  SegmentButtonTextItem
} from '@kit.ArkUI';

/**
 * Official SegmentButton (V1) tab — same call pattern as API reference example 1:
 * SegmentButtonOptions.tab + selectedIndexes: $tabSelectedIndexes.
 * Hosted in @Component so @Link / $ binding keeps the system indicator slide.
 */
@Component
export struct SppTabSegmentButton {
  @Prop initialIndex: number = 0;
  onIndexChange: (index: number) => void = (_index: number) => {
  };
  /**
   * Height: design guide has no fixed height; API min is 28vp (content-adaptive).
   * Default text buttonPadding vertical is 4vp; use 8vp for a modest taller control.
   */
  @State private tabOptions: SegmentButtonOptions = SegmentButtonOptions.tab({
    buttons: [
      { text: $r('app.string.bt_spp_segment_scan') },
      { text: $r('app.string.bt_spp_segment_active') }
    ] as ItemRestriction<SegmentButtonTextItem>,
    buttonPadding: { top: 8, right: 8, bottom: 8, left: 8 }
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
