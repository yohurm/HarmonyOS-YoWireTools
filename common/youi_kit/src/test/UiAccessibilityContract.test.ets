import { describe, it, expect } from '@ohos/hypium';
import { YoButtonToken } from '../main/ets/token/component/YoButtonToken';
import { YoChipToken } from '../main/ets/token/component/YoChipToken';
import { YoNavigationToken } from '../main/ets/token/component/YoNavigationToken';
import { YoSize } from '../main/ets/token/foundation/YoSize';
import { YoColor } from '../main/ets/token/semantic/YoColor';
import { YoResourceUtil } from '../main/ets/util/YoResourceUtil';

export default function uiAccessibilityContractTest() {
  describe('UiAccessibilityContractTest', () => {
    it('YoResourceUtil_hasText_string', 0, () => {
      expect(YoResourceUtil.hasText('')).assertFalse();
      expect(YoResourceUtil.hasText('   ')).assertTrue();
      expect(YoResourceUtil.hasText('label')).assertTrue();
    });

    it('YoResourceUtil_hasText_unresolved_resource', 0, () => {
      expect(YoResourceUtil.resolveText('')).assertEqual('');
      expect(YoResourceUtil.hasText('')).assertFalse();
    });

    it('touch_target_minimums', 0, () => {
      expect(YoSize.TOUCH_TARGET_MIN).assertEqual(48);
      expect(YoSize.BUTTON_HEIGHT >= YoSize.TOUCH_TARGET_MIN).assertTrue();
      expect(YoButtonToken.HEIGHT >= YoSize.TOUCH_TARGET_MIN).assertTrue();
      expect(YoChipToken.TOUCH_HEIGHT >= YoSize.TOUCH_TARGET_MIN).assertTrue();
    });

    it('split_pane_min_widths', 0, () => {
      expect(YoNavigationToken.SPLIT_LIST_MIN_WIDTH).assertEqual(280);
      expect(YoNavigationToken.SPLIT_DETAIL_MIN_WIDTH).assertEqual(280);
    });

    it('semantic_color_emphasize_tertiary', 0, () => {
      expect(YoColor.EMPHASIZE_TERTIARY !== undefined).assertTrue();
    });
  });
}
