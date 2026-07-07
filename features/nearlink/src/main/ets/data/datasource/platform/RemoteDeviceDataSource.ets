import { remoteDevice } from '@kit.NearLinkKit';
import constant from '@hms.nearlink.constant';
import { BusinessError } from '@kit.BasicServicesKit';
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
    try {
      if (this.device === undefined) {
        return Result.fail(new ResultError(NearLinkErrorCodes.DT_GENERIC_FAILED, 'Remote device not created'));
      }
      await this.device.startPairing();
      return Result.ok(undefined);
    } catch (error) {
      const err = error as BusinessError;
      return Result.fail(ResultError.fromError(NearLinkErrorCodes.DT_GENERIC_FAILED, err));
    }
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
