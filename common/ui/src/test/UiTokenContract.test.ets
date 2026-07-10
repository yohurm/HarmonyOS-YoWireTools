import { describe, it, expect } from '@ohos/hypium';
import { WindowWidthBreakpointUtil } from 'common_platform';
import { UiRadius } from '../main/ets/token/foundation/UiRadius';
import { UiSpace } from '../main/ets/token/foundation/UiSpace';
import { UiSize } from '../main/ets/token/foundation/UiSize';
import { UiOpacity } from '../main/ets/token/foundation/UiOpacity';
import { UiMotion } from '../main/ets/token/foundation/UiMotion';
import { UiResponsive } from '../main/ets/token/semantic/UiResponsive';
import { UiColor } from '../main/ets/token/semantic/UiColor';
import { ButtonToken } from '../main/ets/token/component/ButtonToken';
import { CardToken } from '../main/ets/token/component/CardToken';
import { ChipToken } from '../main/ets/token/component/ChipToken';
import { DialogToken } from '../main/ets/token/component/DialogToken';
import { NavigationToken } from '../main/ets/token/component/NavigationToken';
import { CommandDockToken } from '../main/ets/token/component/CommandDockToken';
import { InputToken } from '../main/ets/token/component/InputToken';
import { UiStroke } from '../main/ets/token/foundation/UiStroke';

export default function uiTokenContractTest() {
  describe('UiTokenContractTest', () => {
    it('UiRadius_values', 0, () => {
      expect(UiRadius.NONE).assertEqual(0);
      expect(UiRadius.XS).assertEqual(4);
      expect(UiRadius.SMALL).assertEqual(8);
      expect(UiRadius.MEDIUM).assertEqual(16);
      expect(UiRadius.LARGE).assertEqual(20);
      expect(UiRadius.XLARGE).assertEqual(32);
      expect(UiRadius.FULL).assertEqual(999);
    });

    it('UiSpace_grid', 0, () => {
      expect(UiSpace.XXS).assertEqual(2);
      expect(UiSpace.XS).assertEqual(4);
      expect(UiSpace.M).assertEqual(8);
      expect(UiSpace.XL).assertEqual(16);
      expect(UiSpace.XXXL).assertEqual(32);
    });

    it('UiSize_touch_targets', 0, () => {
      expect(UiSize.TOUCH_TARGET_MIN >= 48).assertTrue();
      expect(UiSize.BUTTON_HEIGHT >= 48).assertTrue();
    });

    it('UiOpacity_range', 0, () => {
      expect(UiOpacity.ENABLED).assertEqual(1.0);
      expect(UiOpacity.DISABLED_CONTENT < 1.0).assertTrue();
      expect(UiOpacity.SCRIM).assertEqual(0.5);
    });

    it('UiMotion_durations', 0, () => {
      expect(UiMotion.DURATION_INSTANT).assertEqual(100);
      expect(UiMotion.DURATION_SHORT).assertEqual(150);
      expect(UiMotion.DURATION_MEDIUM).assertEqual(250);
      expect(UiMotion.DURATION_LONG).assertEqual(300);
    });

    it('component_radius_tokens', 0, () => {
      expect(ButtonToken.RADIUS).assertEqual(UiRadius.LARGE);
      expect(CardToken.RADIUS).assertEqual(UiRadius.MEDIUM);
      expect(ChipToken.RADIUS).assertEqual(UiRadius.LARGE);
      expect(DialogToken.RADIUS).assertEqual(UiRadius.XLARGE);
    });

    it('responsive_breakpoints', 0, () => {
      expect(WindowWidthBreakpointUtil.MEDIUM_MIN_VP).assertEqual(600);
      expect(WindowWidthBreakpointUtil.EXPANDED_MIN_VP).assertEqual(840);
      expect(WindowWidthBreakpointUtil.XL_MIN_VP).assertEqual(1440);
      expect(UiResponsive.CONTENT_MAX_WIDTH).assertEqual(2220);
    });

    it('responsive_form_gap', 0, () => {
      expect(UiResponsive.FORM_GAP).assertEqual(UiSpace.XL);
      expect(UiResponsive.SECTION_GAP).assertEqual(UiSpace.XL);
      expect(UiResponsive.CARD_GAP).assertEqual(UiSpace.L);
      expect(UiResponsive.CONTROL_GAP).assertEqual(UiSpace.M);
    });

    it('semantic_color_emphasize_tertiary', 0, () => {
      expect(UiColor.EMPHASIZE_TERTIARY !== undefined).assertTrue();
    });

    it('navigation_split_weights', 0, () => {
      expect(NavigationToken.SPLIT_LIST_WEIGHT).assertEqual(4);
      expect(NavigationToken.SPLIT_DETAIL_WEIGHT).assertEqual(6);
      expect(NavigationToken.SPLIT_LIST_WEIGHT + NavigationToken.SPLIT_DETAIL_WEIGHT).assertEqual(10);
      expect(NavigationToken.SPLIT_BALANCED_LIST_WEIGHT).assertEqual(5);
      expect(NavigationToken.SPLIT_BALANCED_DETAIL_WEIGHT).assertEqual(5);
      expect(NavigationToken.SPLIT_BALANCED_LIST_WEIGHT + NavigationToken.SPLIT_BALANCED_DETAIL_WEIGHT).assertEqual(10);
      expect(NavigationToken.SPLIT_LIST_HEAVY_LIST_WEIGHT).assertEqual(6);
      expect(NavigationToken.SPLIT_LIST_HEAVY_DETAIL_WEIGHT).assertEqual(4);
      expect(NavigationToken.SPLIT_LIST_HEAVY_LIST_WEIGHT + NavigationToken.SPLIT_LIST_HEAVY_DETAIL_WEIGHT).assertEqual(10);
      expect(NavigationToken.SPLIT_LIST_MIN_WIDTH).assertEqual(280);
      expect(NavigationToken.SPLIT_DETAIL_MIN_WIDTH).assertEqual(280);
    });

    it('command_dock_token', 0, () => {
      expect(CommandDockToken.PADDING).assertEqual(UiSpace.XL);
      expect(CommandDockToken.TABLET_INLINE_SECONDARY_MAX >= 1).assertTrue();
    });

    it('input_token_focus_border', 0, () => {
      expect(InputToken.BORDER_WIDTH).assertEqual(UiStroke.THIN);
      expect(InputToken.BORDER_WIDTH_FOCUSED).assertEqual(UiStroke.FOCUS);
      expect(InputToken.BORDER_FOCUSED !== undefined).assertTrue();
    });
  });
}
