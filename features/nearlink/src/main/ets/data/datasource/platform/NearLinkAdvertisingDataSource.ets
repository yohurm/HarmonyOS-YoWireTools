import { advertising } from '@kit.NearLinkKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { Result, ResultError } from 'common_core';
import { NearLinkConstants } from '../../../constants/NearLinkConstants';
import { NearLinkErrorCodes } from '../../../constants/NearLinkErrorCodes';
import { NearLinkPayloadRules } from '../../../domain/service/NearLinkScanPolicy';

export class NearLinkAdvertisingDataSource {
  private advertisingId: number = -1;

  getAdvertisingId(): number {
    return this.advertisingId;
  }

  async start(
    interval: number,
    connectable: boolean,
    includeDeviceName: boolean,
    serviceUuids: string[]
  ): Promise<Result<number>> {
    const intervalCheck = NearLinkPayloadRules.validateAdvertisingInterval(interval);
    if (!intervalCheck.success) {
      return Result.fail(intervalCheck.error ?? new ResultError(NearLinkErrorCodes.VALIDATION, 'api=startAdvertising'));
    }
    const data: advertising.AdvertisingData = {
      includeDeviceName: includeDeviceName
    };
    if (serviceUuids.length > 0) {
      data.serviceUuids = serviceUuids;
    }
    const params: advertising.AdvertisingParams = {
      advertisingSettings: {
        interval: interval,
        isConnectable: connectable,
        power: advertising.TxPowerMode.ADV_TX_POWER_LOW
      },
      advertisingData: data
    };
    try {
      const id = await advertising.startAdvertising(params);
      this.advertisingId = id;
      return Result.ok(id);
    } catch (error) {
      const err = error as BusinessError;
      return Result.fail(ResultError.fromBusinessError(NearLinkErrorCodes.SCAN_FAILED, err));
    }
  }

  async stop(advertisingId: number): Promise<Result<void>> {
    try {
      await advertising.stopAdvertising(advertisingId);
      if (this.advertisingId === advertisingId) {
        this.advertisingId = -1;
      }
      return Result.ok(undefined);
    } catch (error) {
      const err = error as BusinessError;
      return Result.fail(ResultError.fromBusinessError(NearLinkErrorCodes.SCAN_FAILED, err));
    }
  }
}
