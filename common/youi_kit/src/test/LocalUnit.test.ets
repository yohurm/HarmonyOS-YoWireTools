import { describe, it, expect } from '@ohos/hypium';
import { YoEmptyStateModel } from '../main/ets/model/YoEmptyStateModel';
import { YoErrorStateModel } from '../main/ets/model/YoErrorStateModel';
import { YoLoadingStateModel } from '../main/ets/model/YoLoadingStateModel';
import { YoPageState } from '../main/ets/model/YoPageState';
import { YoSpace } from '../main/ets/token/foundation/YoSpace';
import { YoResourceUtil } from '../main/ets/util/YoResourceUtil';

export default function localUnitTest() {
  describe('CommonUiLocalUnitTest', () => {
    it('YoPageState_values', 0, () => {
      expect(YoPageState.CONTENT).assertEqual('content');
      expect(YoPageState.PERMISSION).assertEqual('permission');
    });

    it('YoEmptyStateModel_requires_business_copy', 0, () => {
      const model = new YoEmptyStateModel('Title', 'Message', 'Reason', 'Action');
      expect(model.title).assertEqual('Title');
      expect(model.actionLabel).assertEqual('Action');
    });

    it('YoErrorStateModel_fromLayers', 0, () => {
      const model = YoErrorStateModel.fromLayers(
        'Operation failed',
        'Resource unavailable',
        'Retry later',
        true,
        'YW-001'
      );
      expect(model.userMessage).assertEqual('Operation failed');
      expect(model.retryable).assertTrue();
    });

    it('YoLoadingStateModel_defaults', 0, () => {
      const model = new YoLoadingStateModel();
      expect(model.showProgress).assertTrue();
    });

    it('YoSpace_page_padding', 0, () => {
      expect(YoSpace.XL).assertEqual(16);
    });

    it('YoResourceUtil_hasText', 0, () => {
      expect(YoResourceUtil.hasText('')).assertFalse();
      expect(YoResourceUtil.resolveText('')).assertEqual('');
      expect(YoResourceUtil.hasText('label')).assertTrue();
      expect(YoResourceUtil.resolveText('label')).assertEqual('label');
      expect(YoResourceUtil.hasText('   ')).assertTrue();
    });
  });
}
