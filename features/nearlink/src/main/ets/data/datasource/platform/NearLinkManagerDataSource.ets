import { manager } from '@kit.NearLinkKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { Observable, Result, ResultError } from 'common_core';
import { NearLinkAdapterSnapshot } from '../../../domain/model/NearLinkDevice';
import { NearLinkErrorCodes } from '../../../constants/NearLinkErrorCodes';
import { NearLinkKitEventBridge } from '../../kit/NearLinkKitEventBridge';

export class NearLinkManagerDataSource {
  private static instance: NearLinkManagerDataSource | undefined;
  private stateHandler: ((state: manager.NearlinkState) => void) | undefined;
  private readonly adapterObservable: Observable<NearLinkAdapterSnapshot>;

  private constructor() {
    this.adapterObservable = new Observable<NearLinkAdapterSnapshot>(
      new NearLinkAdapterSnapshot(false, false, 0, 'Unknown')
    );
  }

  static getInstance(): NearLinkManagerDataSource {
    if (NearLinkManagerDataSource.instance === undefined) {
      NearLinkManagerDataSource.instance = new NearLinkManagerDataSource();
    }
    return NearLinkManagerDataSource.instance;
  }

  observeAdapterState(): Observable<NearLinkAdapterSnapshot> {
    return this.adapterObservable;
  }

  async getAdapterState(): Promise<Result<NearLinkAdapterSnapshot>> {
    try {
      const supported = manager.isNearLinkSupported();
      if (!supported) {
        return Result.ok(new NearLinkAdapterSnapshot(false, false, 0, 'Unsupported'));
      }
      const stateCode: manager.NearlinkState = manager.getState();
      const enabled = stateCode === manager.NearlinkState.STATE_ON ||
        stateCode === manager.NearlinkState.STATE_TURNING_ON;
      const label = enabled ? 'On' : 'Off';
      const snapshot = new NearLinkAdapterSnapshot(true, enabled, stateCode, label);
      this.adapterObservable.next(snapshot);
      return Result.ok(snapshot);
    } catch (error) {
      const err = error as BusinessError;
      return Result.fail(ResultError.fromError(NearLinkErrorCodes.UNSUPPORTED, err));
    }
  }

  onStateChange(listener: (snapshot: NearLinkAdapterSnapshot) => void): void {
    this.offStateChange();
    this.stateHandler = (_state: manager.NearlinkState) => {
      void this.getAdapterState().then((result: Result<NearLinkAdapterSnapshot>) => {
        if (result.success && result.value !== undefined) {
          listener(result.value);
        }
      });
    };
    NearLinkKitEventBridge.subscribeStateChange(this.stateHandler);
  }

  offStateChange(): void {
    if (this.stateHandler !== undefined) {
      NearLinkKitEventBridge.unsubscribeStateChange(this.stateHandler);
      this.stateHandler = undefined;
    }
  }
}
