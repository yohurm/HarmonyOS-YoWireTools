import { describe, it, expect } from '@ohos/hypium';
import { AppRoutes } from '../main/ets/navigation/AppRoutes';

export default function localUnitTest() {
  describe('EntryLocalUnitTest', () => {
    it('AppRoutes_workbench', 0, () => {
      expect(AppRoutes.WORKBENCH).assertEqual('/home/workbench');
    });

    it('AppRoutes_primary_tabs', 0, () => {
      expect(AppRoutes.BLUETOOTH).assertEqual('/bluetooth/overview');
      expect(AppRoutes.WIFI).assertEqual('/wifi/overview');
      expect(AppRoutes.LOG).assertEqual('/log/list');
      expect(AppRoutes.SETTINGS).assertEqual('/settings/index');
    });
  });
}
