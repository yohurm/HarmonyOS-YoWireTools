import { deviceInfo } from '@kit.BasicServicesKit';
import { remoteDevice } from '@kit.NearLinkKit';
import constant from '@hms.nearlink.constant';
import { BusinessError } from '@kit.BasicServicesKit';
import { NearLinkConstants } from '../../../constants/NearLinkConstants';
import { Result, ResultError } from 'common_core';
import { NearLinkErrorCodes } from '../../../constants/NearLinkErrorCodes';
import { NearLinkSecurityState } from '../../../domain/model/NearLinkSecurityState';

export class RemoteDeviceDataSource {
  private device: remoteDevice.RemoteDevice | undefined;

  createRemoteDevice(address: string): Result<void> {
    try {
      this.device = remoteDevice.createRemoteDevice(address);
      return Result.ok(undefined);
    } catch (error) {
      const err = error as BusinessError;
      return Result.fail(ResultError.fromError(NearLinkErrorCodes.DT_GENERIC_FAILED, err));
    }
  }

  async startPairing(): Promise<Result<void>> {
    if (deviceInfo.sdkApiVersion < NearLinkConstants.API_PAIRING) {
      return Result.fail(new ResultError(
        NearLinkErrorCodes.VERSION_UNAVAILABLE,
        `api=startPairing;since=${NearLinkConstants.SINCE_PAIRING}`,
        undefined,
        { 'since': NearLinkConstants.SINCE_PAIRING, 'apiName': 'startPairing' },
        ''
      ));
    }
    try {
      if (this.device === undefined) {
        return Result.fail(new ResultError(NearLinkErrorCodes.DT_GENERIC_FAILED, 'Remote device not created'));
      }
      await this.device.startPairing();
      return Result.ok(undefined);
    } catch (error) {
      const err = error as BusinessError;
      if (err.code === NearLinkConstants.NATIVE_OPERATION_FAILED) {
        return Result.fail(ResultError.fromError(NearLinkErrorCodes.ALREADY_PAIRED, err));
      }
      return Result.fail(ResultError.fromError(NearLinkErrorCodes.DT_GENERIC_FAILED, err));
    }
  }

  isPaired(): Result<boolean> {
    const state = this.getPairingState();
    if (!state.success || state.value === undefined) {
      return Result.fail(state.error ?? new ResultError(NearLinkErrorCodes.DT_GENERIC_FAILED, 'api=getPairingState'));
    }
    return Result.ok(state.value === constant.PairingState.PAIRING_STATE_PAIRED);
  }

  getPairingState(): Result<remoteDevice.PairingState> {
    try {
      if (this.device === undefined) {
        return Result.fail(new ResultError(NearLinkErrorCodes.DT_GENERIC_FAILED, 'Remote device not created'));
      }
      return Result.ok(this.device.getPairingState());
    } catch (error) {
      const err = error as BusinessError;
      return Result.fail(ResultError.fromError(NearLinkErrorCodes.DT_GENERIC_FAILED, err));
    }
  }

  getAcbState(): Result<remoteDevice.AcbState> {
    if (deviceInfo.sdkApiVersion < NearLinkConstants.API_PAIRING) {
      return Result.fail(new ResultError(
        NearLinkErrorCodes.VERSION_UNAVAILABLE,
        `api=getAcbState;since=${NearLinkConstants.SINCE_DATA_TRANSFER}`
      ));
    }
    try {
      if (this.device === undefined) {
        return Result.fail(new ResultError(NearLinkErrorCodes.DT_GENERIC_FAILED, 'Remote device not created'));
      }
      return Result.ok(this.device.getAcbState());
    } catch (error) {
      const err = error as BusinessError;
      return Result.fail(ResultError.fromError(NearLinkErrorCodes.DT_GENERIC_FAILED, err));
    }
  }

  resolveSecurityState(acbState: remoteDevice.AcbState): NearLinkSecurityState {
    if (acbState === constant.AcbState.ENCRYPTED) {
      return NearLinkSecurityState.ENCRYPTED;
    }
    if (acbState === constant.AcbState.CONNECTED) {
      return NearLinkSecurityState.NOT_ENCRYPTED;
    }
    return NearLinkSecurityState.UNKNOWN;
  }
}
