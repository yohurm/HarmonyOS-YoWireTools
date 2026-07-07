import { describe, it, expect } from '@ohos/hypium';
import { EmptyStateModel } from '../main/ets/model/EmptyStateModel';
import { ErrorStateModel } from '../main/ets/model/ErrorStateModel';
import { LoadingStateModel } from '../main/ets/model/LoadingStateModel';
import { UiPageState } from '../main/ets/model/UiPageState';
import { UiSpacing } from '../main/ets/theme/UiSpacing';

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

    it('UiSpacing_tokens', 0, () => {
      expect(UiSpacing.PAGE_PADDING).assertEqual(16);
    });
  });
}
