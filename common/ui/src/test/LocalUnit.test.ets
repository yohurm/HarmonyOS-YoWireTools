import { describe, it, expect } from '@ohos/hypium';
import { EmptyStateModel } from '../main/ets/model/EmptyStateModel';
import { ErrorStateModel } from '../main/ets/model/ErrorStateModel';
import { LoadingStateModel } from '../main/ets/model/LoadingStateModel';
import { UiPageState } from '../main/ets/model/UiPageState';
import { UiSpace } from '../main/ets/token/foundation/UiSpace';
import { UiResourceUtil } from '../main/ets/util/UiResourceUtil';

export default function localUnitTest() {
  describe('CommonUiLocalUnitTest', () => {
    it('UiPageState_values', 0, () => {
      expect(UiPageState.CONTENT).assertEqual('content');
      expect(UiPageState.PERMISSION).assertEqual('permission');
    });

    it('EmptyStateModel_requires_business_copy', 0, () => {
      const model = new EmptyStateModel('Title', 'Message', 'Reason', 'Action');
      expect(model.title).assertEqual('Title');
      expect(model.actionLabel).assertEqual('Action');
    });

    it('ErrorStateModel_fromLayers', 0, () => {
      const model = ErrorStateModel.fromLayers(
        'Operation failed',
        'Resource unavailable',
        'Retry later',
        true,
        'YW-001'
      );
      expect(model.userMessage).assertEqual('Operation failed');
      expect(model.retryable).assertTrue();
    });

    it('LoadingStateModel_defaults', 0, () => {
      const model = new LoadingStateModel();
      expect(model.showProgress).assertTrue();
    });

    it('UiSpace_page_padding', 0, () => {
      expect(UiSpace.XL).assertEqual(16);
    });

    it('UiResourceUtil_hasText', 0, () => {
      expect(UiResourceUtil.hasText('')).assertFalse();
      expect(UiResourceUtil.resolveText('')).assertEqual('');
      expect(UiResourceUtil.hasText('label')).assertTrue();
      expect(UiResourceUtil.resolveText('label')).assertEqual('label');
      expect(UiResourceUtil.hasText('   ')).assertTrue();
    });
  });
}
