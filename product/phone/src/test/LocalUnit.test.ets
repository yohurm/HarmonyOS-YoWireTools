import { describe, it, expect } from '@ohos/hypium';
import { AppRoutes } from '../main/ets/navigation/AppRoutes';

export default function localUnitTest() {
  describe('EntryLocalUnitTest', () => {
    it('AppRoutes_five_main_pages', 0, () => {
      expect(AppRoutes.HOME).assertEqual('/home/dashboard');
      expect(AppRoutes.BLUETOOTH).assertEqual('/bluetooth/overview');
      expect(AppRoutes.NEARLINK).assertEqual('/nearlink/overview');
      expect(AppRoutes.WIFI).assertEqual('/wifi/overview');
      expect(AppRoutes.SETTINGS).assertEqual('/settings/app');
      expect(AppRoutes.TAB_INDEX_HOME).assertEqual(0);
      expect(AppRoutes.TAB_INDEX_BLUETOOTH).assertEqual(1);
      expect(AppRoutes.TAB_INDEX_NEARLINK).assertEqual(2);
      expect(AppRoutes.TAB_INDEX_WIFI).assertEqual(3);
      expect(AppRoutes.TAB_INDEX_SETTINGS).assertEqual(4);
    });
  });
}
