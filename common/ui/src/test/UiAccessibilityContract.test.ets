import { describe, it, expect } from '@ohos/hypium';
import { ButtonToken } from '../main/ets/token/component/ButtonToken';
import { ChipToken } from '../main/ets/token/component/ChipToken';
import { NavigationToken } from '../main/ets/token/component/NavigationToken';
import { UiSize } from '../main/ets/token/foundation/UiSize';
import { UiColor } from '../main/ets/token/semantic/UiColor';
import { UiResourceUtil } from '../main/ets/util/UiResourceUtil';

export default function uiAccessibilityContractTest() {
  describe('UiAccessibilityContractTest', () => {
    it('UiResourceUtil_hasText_string', 0, () => {
      expect(UiResourceUtil.hasText('')).assertFalse();
      expect(UiResourceUtil.hasText('   ')).assertTrue();
      expect(UiResourceUtil.hasText('label')).assertTrue();
    });

    it('UiResourceUtil_hasText_unresolved_resource', 0, () => {
      expect(UiResourceUtil.resolveText('')).assertEqual('');
      expect(UiResourceUtil.hasText('')).assertFalse();
    });

    it('touch_target_minimums', 0, () => {
      expect(UiSize.TOUCH_TARGET_MIN).assertEqual(48);
      expect(UiSize.BUTTON_HEIGHT >= UiSize.TOUCH_TARGET_MIN).assertTrue();
      expect(ButtonToken.HEIGHT >= UiSize.TOUCH_TARGET_MIN).assertTrue();
      expect(ChipToken.TOUCH_HEIGHT >= UiSize.TOUCH_TARGET_MIN).assertTrue();
    });

    it('split_pane_min_widths', 0, () => {
      expect(NavigationToken.SPLIT_LIST_MIN_WIDTH).assertEqual(280);
      expect(NavigationToken.SPLIT_DETAIL_MIN_WIDTH).assertEqual(280);
    });

    it('semantic_color_emphasize_tertiary', 0, () => {
      expect(UiColor.EMPHASIZE_TERTIARY !== undefined).assertTrue();
    });
  });
}
