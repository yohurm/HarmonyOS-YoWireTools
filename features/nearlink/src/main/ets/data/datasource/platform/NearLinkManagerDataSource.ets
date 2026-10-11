import { deviceInfo } from '@kit.BasicServicesKit';
import { manager } from '@kit.NearLinkKit';
import constant from '@hms.nearlink.constant';
import { BusinessError } from '@kit.BasicServicesKit';
import { Observable, Result, ResultError } from 'common_core';
import { KitEventSubscription } from 'common_platform';
import { NearLinkAdapterSnapshot } from '../../../domain/model/NearLinkDevice';
import {
  NearLinkPairingNotice,
  NearLinkRadioCode,
  NearLinkRadioSnapshot,
  NearLinkSupportQuery
} from '../../../domain/model/NearLinkRadio';
import { NearLinkConstants } from '../../../constants/NearLinkConstants';
import { NearLinkErrorCodes } from '../../../constants/NearLinkErrorCodes';

export class NearLinkManagerDataSource {
  private static instance: NearLinkManagerDataSource | undefined;
  private stateHandler: ((state: manager.NearlinkState) => void) | undefined;
  private pairingHandler: ((param: manager.PairingStateParam) => void) | undefined;
  private connectionHandler: ((param: manager.ConnectionStateParam) => void) | undefined;
  private readonly adapterObservable: Observable<NearLinkAdapterSnapshot>;

  private constructor() {
    this.adapterObservable = new Observable<NearLinkAdapterSnapshot>(
      new NearLinkAdapterSnapshot(false, false, NearLinkRadioCode.UNKNOWN, 'Unknown')
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

  querySupported(): Result<NearLinkSupportQuery> {
    const api = deviceInfo.sdkApiVersion;
    if (api < NearLinkConstants.API_SUPPORT_QUERY) {
      return Result.fail(new ResultError(
        NearLinkErrorCodes.VERSION_UNAVAILABLE,
        `api=isNearLinkSupported;since=${NearLinkConstants.SINCE_SUPPORT}`,
        undefined,
        { 'since': NearLinkConstants.SINCE_SUPPORT, 'apiName': 'isNearLinkSupported' },
        ''
      ));
    }
    try {
      const supported = manager.isNearLinkSupported();
      return Result.ok(new NearLinkSupportQuery(supported));
    } catch (error) {
      const err = error as BusinessError;
      if (err.code === NearLinkConstants.NATIVE_CAPABILITY) {
        return Result.fail(ResultError.fromBusinessError(NearLinkErrorCodes.CAPABILITY_UNSUPPORTED, err));
      }
      return Result.fail(ResultError.fromBusinessError(NearLinkErrorCodes.UNSUPPORTED, err));
    }
  }

  readRadio(): Result<NearLinkRadioSnapshot> {
    try {
      const stateCode: manager.NearlinkState = manager.getState();
      const code = NearLinkManagerDataSource.mapState(stateCode);
      const enabled = code === NearLinkRadioCode.ON;
      this.adapterObservable.next(new NearLinkAdapterSnapshot(true, enabled, stateCode, `${code}`));
      return Result.ok(new NearLinkRadioSnapshot(code));
    } catch (error) {
      const err = error as BusinessError;
      if (err.code === NearLinkConstants.NATIVE_CAPABILITY) {
        return Result.fail(ResultError.fromBusinessError(NearLinkErrorCodes.CAPABILITY_UNSUPPORTED, err));
      }
      return Result.fail(ResultError.fromBusinessError(NearLinkErrorCodes.UNSUPPORTED, err));
    }
  }

  readLocalName(): Result<string> {
    try {
      const name = manager.getLocalName();
      const clipped = name.length > NearLinkConstants.NAME_MAX_LENGTH ?
        name.substring(0, NearLinkConstants.NAME_MAX_LENGTH) : name;
      return Result.ok(clipped);
    } catch (error) {
      const err = error as BusinessError;
      return Result.fail(ResultError.fromBusinessError(NearLinkErrorCodes.SWITCH_OFF, err));
    }
  }

  readPairedDevices(): Result<string[]> {
    const api = deviceInfo.sdkApiVersion;
    if (api < NearLinkConstants.API_PAIRED_DEVICES) {
      return Result.fail(new ResultError(
        NearLinkErrorCodes.VERSION_UNAVAILABLE,
        `api=getPairedDevices;since=${NearLinkConstants.SINCE_PAIRED_DEVICES}`,
        undefined,
        { 'since': NearLinkConstants.SINCE_PAIRED_DEVICES, 'apiName': 'getPairedDevices' },
        ''
      ));
    }
    try {
      const devices = manager.getPairedDevices();
      return Result.ok(devices);
    } catch (error) {
      const err = error as BusinessError;
      return Result.fail(ResultError.fromBusinessError(NearLinkErrorCodes.UNSUPPORTED, err));
    }
  }

  isEmulator(): boolean {
    const model = `${deviceInfo.productModel} ${deviceInfo.brand} ${deviceInfo.manufacture}`.toLowerCase();
    return model.includes('emulator');
  }

  currentApiVersion(): number {
    return deviceInfo.sdkApiVersion;
  }

  async getAdapterState(): Promise<Result<NearLinkAdapterSnapshot>> {
    const support = this.querySupported();
    if (!support.success) {
      if (support.error?.code === NearLinkErrorCodes.VERSION_UNAVAILABLE ||
        support.error?.code === NearLinkErrorCodes.CAPABILITY_UNSUPPORTED) {
        return Result.fail(support.error ?? new ResultError(NearLinkErrorCodes.UNSUPPORTED, 'api=isNearLinkSupported'));
      }
      return Result.fail(support.error ?? new ResultError(NearLinkErrorCodes.UNSUPPORTED, 'api=isNearLinkSupported'));
    }
    const supported = support.value !== undefined && support.value.supported;
    if (!supported) {
      const snapshot = new NearLinkAdapterSnapshot(false, false, NearLinkRadioCode.UNKNOWN, 'Unsupported');
      this.adapterObservable.next(snapshot);
      return Result.ok(snapshot);
    }
    const radio = this.readRadio();
    if (!radio.success || radio.value === undefined) {
      return Result.fail(radio.error ?? new ResultError(NearLinkErrorCodes.UNSUPPORTED, 'api=getState'));
    }
    const enabled = radio.value.code === NearLinkRadioCode.ON;
    const snapshot = new NearLinkAdapterSnapshot(true, enabled, radio.value.code, `${radio.value.code}`);
    this.adapterObservable.next(snapshot);
    return Result.ok(snapshot);
  }

  onStateChange(listener: (snapshot: NearLinkRadioSnapshot) => void): Result<void> {
    this.offStateChange();
    const handler = (_state: manager.NearlinkState) => {
      const radio = this.readRadio();
      if (radio.success && radio.value !== undefined) {
        listener(radio.value);
      }
    };
    this.stateHandler = handler;
    return KitEventSubscription.subscribe(() => {
      manager.on('stateChange', handler);
    }, 'manager.stateChange');
  }

  onPairingChange(listener: (notice: NearLinkPairingNotice) => void): Result<void> {
    this.offPairingChange();
    const handler = (param: manager.PairingStateParam) => {
      listener(NearLinkManagerDataSource.toPairingNotice(param));
    };
    this.pairingHandler = handler;
    return KitEventSubscription.subscribe(() => {
      manager.on('pairingStateChange', handler);
    }, 'manager.pairingStateChange');
  }

  offPairingChange(): void {
    if (this.pairingHandler !== undefined) {
      const handler = this.pairingHandler;
      KitEventSubscription.unsubscribe(() => {
        manager.off('pairingStateChange', handler);
      }, 'manager.pairingStateChange');
      this.pairingHandler = undefined;
    }
  }

  onConnectionChange(listener: (notice: NearLinkPairingNotice) => void): Result<void> {
    this.offConnectionChange();
    const handler = (param: manager.ConnectionStateParam) => {
      listener(new NearLinkPairingNotice(
        param.address,
        'connection',
        'connection',
        NearLinkManagerDataSource.connectionReasonMsg(param)
      ));
    };
    this.connectionHandler = handler;
    return KitEventSubscription.subscribe(() => {
      manager.on('connectionStateChange', handler);
    }, 'manager.connectionStateChange');
  }

  offConnectionChange(): void {
    if (this.connectionHandler !== undefined) {
      const handler = this.connectionHandler;
      KitEventSubscription.unsubscribe(() => {
        manager.off('connectionStateChange', handler);
      }, 'manager.connectionStateChange');
      this.connectionHandler = undefined;
    }
  }

  offStateChange(): void {
    if (this.stateHandler !== undefined) {
      const handler = this.stateHandler;
      KitEventSubscription.unsubscribe(() => {
        manager.off('stateChange', handler);
      }, 'manager.stateChange');
      this.stateHandler = undefined;
    }
  }

  private static connectionReasonMsg(param: manager.ConnectionStateParam): string {
    if (deviceInfo.sdkApiVersion >= NearLinkConstants.API_REASON_MSG) {
      const message = param.reasonMsg;
      return message ?? '';
    }
    return '';
  }

  private static pairingReasonMsg(param: manager.PairingStateParam): string {
    if (deviceInfo.sdkApiVersion >= NearLinkConstants.API_REASON_MSG) {
      const message = param.reasonMsg;
      return message ?? '';
    }
    return '';
  }

  private static toPairingNotice(param: manager.PairingStateParam): NearLinkPairingNotice {
    let stateToken = 'none';
    if (param.state === constant.PairingState.PAIRING_STATE_PAIRED) {
      stateToken = 'paired';
    } else if (param.state === constant.PairingState.PAIRING_STATE_PAIRING) {
      stateToken = 'pairing';
    }
    let reasonToken = 'failure';
    if (param.reason === manager.PairingReason.PAIRING_REASON_SUCCESS) {
      reasonToken = 'success';
    } else if (param.reason === manager.PairingReason.PAIRING_REASON_PROFILE_UNSUPPORTED) {
      reasonToken = 'profile_unsupported';
    } else if (param.reason === manager.PairingReason.PAIRING_REASON_EXCEED_ACB_MAX) {
      reasonToken = 'exceed_acb_max';
    } else if (param.reason === manager.PairingReason.PAIRING_REASON_REMOTE_CANCELED) {
      reasonToken = 'remote_canceled';
    } else if (param.reason === manager.PairingReason.PAIRING_REASON_LOCAL_CANCELED) {
      reasonToken = 'local_canceled';
    }
    return new NearLinkPairingNotice(
      param.address,
      stateToken,
      reasonToken,
      NearLinkManagerDataSource.pairingReasonMsg(param)
    );
  }

  private static mapState(state: manager.NearlinkState): NearLinkRadioCode {
    if (state === manager.NearlinkState.STATE_ON) {
      return NearLinkRadioCode.ON;
    }
    if (state === manager.NearlinkState.STATE_OFF) {
      return NearLinkRadioCode.OFF;
    }
    if (state === manager.NearlinkState.STATE_TURNING_ON) {
      return NearLinkRadioCode.TURNING_ON;
    }
    if (state === manager.NearlinkState.STATE_TURNING_OFF) {
      return NearLinkRadioCode.TURNING_OFF;
    }
    return NearLinkRadioCode.UNKNOWN;
  }
}
