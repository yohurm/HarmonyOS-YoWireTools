import { describe, it, expect } from '@ohos/hypium';
import { WindowWidthBreakpointUtil } from 'common_platform';
import { YoRadius } from '../main/ets/token/foundation/YoRadius';
import { YoSpace } from '../main/ets/token/foundation/YoSpace';
import { YoSize } from '../main/ets/token/foundation/YoSize';
import { YoOpacity } from '../main/ets/token/foundation/YoOpacity';
import { YoMotion } from '../main/ets/token/foundation/YoMotion';
import { YoResponsive } from '../main/ets/token/semantic/YoResponsive';
import { YoColor } from '../main/ets/token/semantic/YoColor';
import { YoButtonToken } from '../main/ets/token/component/YoButtonToken';
import { YoCardToken } from '../main/ets/token/component/YoCardToken';
import { YoChipToken } from '../main/ets/token/component/YoChipToken';
import { YoDialogToken } from '../main/ets/token/component/YoDialogToken';
import { YoListToken } from '../main/ets/token/component/YoListToken';
import { YoMenuToken } from '../main/ets/token/component/YoMenuToken';
import { YoNavigationToken } from '../main/ets/token/component/YoNavigationToken';
import { YoSegmentToken } from '../main/ets/token/component/YoSegmentToken';
import { YoToastToken } from '../main/ets/token/component/YoToastToken';
import { YoStroke } from '../main/ets/token/foundation/YoStroke';

export default function uiTokenContractTest() {
  describe('YoTokenContractTest', () => {
    it('YoRadius_values', 0, () => {
      expect(YoRadius.NONE).assertEqual(0);
      expect(YoRadius.XS).assertEqual(4);
      expect(YoRadius.SMALL).assertEqual(8);
      expect(YoRadius.MEDIUM).assertEqual(16);
      expect(YoRadius.LARGE).assertEqual(20);
      expect(YoRadius.XLARGE).assertEqual(32);
      expect(YoRadius.FULL).assertEqual(999);
    });

    it('YoSpace_grid', 0, () => {
      expect(YoSpace.XXS).assertEqual(2);
      expect(YoSpace.XS).assertEqual(4);
      expect(YoSpace.M).assertEqual(8);
      expect(YoSpace.XL).assertEqual(16);
      expect(YoSpace.XXXL).assertEqual(32);
    });

    it('YoSize_touch_targets', 0, () => {
      expect(YoSize.TOUCH_TARGET_MIN >= 48).assertTrue();
      expect(YoSize.BUTTON_HEIGHT >= 48).assertTrue();
    });

    it('YoOpacity_range', 0, () => {
      expect(YoOpacity.ENABLED).assertEqual(1.0);
      expect(YoOpacity.DISABLED_CONTENT < 1.0).assertTrue();
      expect(YoOpacity.SCRIM).assertEqual(0.5);
    });

    it('YoMotion_durations', 0, () => {
      expect(YoMotion.DURATION_INSTANT).assertEqual(100);
      expect(YoMotion.DURATION_SHORT).assertEqual(150);
      expect(YoMotion.DURATION_MEDIUM).assertEqual(250);
      expect(YoMotion.DURATION_LONG).assertEqual(300);
    });

    it('component_radius_tokens', 0, () => {
      expect(YoButtonToken.RADIUS).assertEqual(YoRadius.LARGE);
      expect(YoCardToken.RADIUS).assertEqual(YoRadius.MEDIUM);
      expect(YoChipToken.RADIUS).assertEqual(YoRadius.LARGE);
      expect(YoDialogToken.RADIUS).assertEqual(YoRadius.XLARGE);
      expect(YoMenuToken.RADIUS).assertEqual(YoRadius.LARGE);
      expect(YoToastToken.CORNER_RADIUS).assertEqual(12);
      expect(YoToastToken.DURATION_SHORT_MS).assertEqual(2000);
      expect(YoToastToken.DURATION_LONG_MS).assertEqual(3500);
      expect(YoToastToken.MAX_WIDTH).assertEqual(280);
    });

    it('list_and_menu_layout_tokens', 0, () => {
      expect(YoListToken.SCROLLBAR_WIDTH).assertEqual(4);
      expect(YoListToken.ITEM_GAP).assertEqual(YoSpace.NONE);
      expect(YoListToken.ITEM_SHADOW_BLEED).assertEqual(YoSpace.XXS);
      expect(YoListToken.DIVIDER_STROKE).assertEqual(0.5);
      expect(YoListToken.DIVIDER_INSET_LEADING).assertEqual(YoSpace.L + YoSize.ICON_M + YoSpace.L);
      expect(YoMenuToken.MIN_WIDTH).assertEqual(64);
      expect(YoMenuToken.COMPACT_MAX_WIDTH < 224).assertTrue();
      expect(YoResponsive.SECTION_GAP).assertEqual(YoSpace.XL);
      expect(YoResponsive.CARD_GAP).assertEqual(YoSpace.L);
    });

    it('responsive_breakpoints', 0, () => {
      expect(WindowWidthBreakpointUtil.MEDIUM_MIN_VP).assertEqual(600);
      expect(WindowWidthBreakpointUtil.EXPANDED_MIN_VP).assertEqual(840);
      expect(WindowWidthBreakpointUtil.XL_MIN_VP).assertEqual(1440);
      expect(YoResponsive.CONTENT_MAX_WIDTH).assertEqual(2220);
    });

    it('responsive_form_gap', 0, () => {
      expect(YoResponsive.FORM_GAP).assertEqual(YoSpace.XL);
      expect(YoResponsive.SECTION_GAP).assertEqual(YoSpace.XL);
      expect(YoResponsive.CARD_GAP).assertEqual(YoSpace.L);
      expect(YoResponsive.CONTROL_GAP).assertEqual(YoSpace.M);
    });

    it('semantic_color_emphasize_tertiary', 0, () => {
      expect(YoColor.EMPHASIZE_TERTIARY !== undefined).assertTrue();
    });

    it('navigation_split_weights', 0, () => {
      expect(YoNavigationToken.SPLIT_LIST_WEIGHT).assertEqual(4);
      expect(YoNavigationToken.SPLIT_DETAIL_WEIGHT).assertEqual(6);
      expect(YoNavigationToken.SPLIT_LIST_WEIGHT + YoNavigationToken.SPLIT_DETAIL_WEIGHT).assertEqual(10);
      expect(YoNavigationToken.SPLIT_BALANCED_LIST_WEIGHT).assertEqual(5);
      expect(YoNavigationToken.SPLIT_BALANCED_DETAIL_WEIGHT).assertEqual(5);
      expect(YoNavigationToken.SPLIT_LIST_HEAVY_LIST_WEIGHT).assertEqual(6);
      expect(YoNavigationToken.SPLIT_LIST_HEAVY_DETAIL_WEIGHT).assertEqual(4);
      expect(YoNavigationToken.SPLIT_LIST_MIN_WIDTH).assertEqual(280);
      expect(YoNavigationToken.SPLIT_DETAIL_MIN_WIDTH).assertEqual(280);
    });

    it('segment_token_selected_font', 0, () => {
      expect(YoSegmentToken.SELECTED_FONT_COLOR.length > 0).assertTrue();
      expect(YoStroke.THIN > 0).assertTrue();
    });
  });
}
