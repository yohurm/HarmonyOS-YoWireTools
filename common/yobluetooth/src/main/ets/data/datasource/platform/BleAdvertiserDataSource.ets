import { ble } from '@kit.ConnectivityKit';
import { BusinessError, deviceInfo } from '@kit.BasicServicesKit';
import { Result, ResultError } from 'common_core';
import { BluetoothErrorCodes } from '../../../constants/BluetoothErrorCodes';
import { BluetoothPlatformCodes } from '../../../constants/BluetoothPlatformCodes';
import { AdvertisingRequest, AdvertisingRequestPolicy } from '../../../domain/model/AdvertisingRequest';

/**
 * BLE advertiser call site. Extended fields are submitted only at API 26+.
 * There is no custom AD Type argument.
 */
export class BleAdvertiserDataSource {
  private advertising: boolean = false;

  isAdvertising(): boolean {
    return this.advertising;
  }

  async start(request: AdvertisingRequest): Promise<Result<void>> {
    const policy = AdvertisingRequestPolicy.validate(request);
    if (!policy.success) {
      this.advertising = false;
      return policy;
    }
    if (request.extended && deviceInfo.sdkApiVersion < 26) {
      this.advertising = false;
      return Result.fail(new ResultError(
        BluetoothErrorCodes.CAPABILITY_UNSUPPORTED,
        'Extended advertising is not available on this API level'
      ));
    }
    try {
      const setting: ble.AdvertiseSetting = {
        interval: 160,
        connectable: request.connectable
      };
      if (request.extended && deviceInfo.sdkApiVersion >= 26) {
        setting.isExtended = true;
      }
      const data = BleAdvertiserDataSource.toAdvertiseData(request);
      const response = request.scanResponseHex.trim().length > 0
        ? BleAdvertiserDataSource.responseData(request.scanResponseHex)
        : undefined;
      if (request.durationMs > 0 && deviceInfo.sdkApiVersion >= 26) {
        const params: ble.AdvertisingParams = {
          advertisingSettings: setting,
          advertisingData: data,
          advertisingResponse: response,
          duration: request.durationMs
        };
        await ble.startAdvertising(params);
      } else if (response !== undefined) {
        await ble.startAdvertising(setting, data, response);
      } else {
        await ble.startAdvertising(setting, data);
      }
      this.advertising = true;
      return Result.ok(undefined);
    } catch (error) {
      this.advertising = false;
      const err = error as BusinessError;
      const mapped = BluetoothPlatformCodes.domainCode(err.code);
      const code = mapped.length > 0 ? mapped : BluetoothErrorCodes.ADV_REJECTED;
      return Result.fail(ResultError.fromBusinessError(code, err));
    }
  }

  async stop(): Promise<Result<void>> {
    try {
      await ble.stopAdvertising();
      this.advertising = false;
      return Result.ok(undefined);
    } catch (error) {
      this.advertising = false;
      const err = error as BusinessError;
      const mapped = BluetoothPlatformCodes.domainCode(err.code);
      const code = mapped.length > 0 ? mapped : BluetoothErrorCodes.ADV_REJECTED;
      return Result.fail(ResultError.fromBusinessError(code, err));
    }
  }

  private static toAdvertiseData(request: AdvertisingRequest): ble.AdvertiseData {
    const serviceUuids: Array<string> = [];
    for (let i = 0; i < request.serviceUuids.length; i++) {
      serviceUuids.push(request.serviceUuids[i]);
    }
    const serviceData: Array<ble.ServiceData> = [];
    if (request.serviceDataUuid.length > 0 && request.serviceDataHex.length > 0) {
      const unit: ble.ServiceData = {
        serviceUuid: request.serviceDataUuid,
        serviceValue: BleAdvertiserDataSource.hexToBuffer(request.serviceDataHex)
      };
      serviceData.push(unit);
    }
    const manufactureData: Array<ble.ManufactureData> = [];
    if (request.manufacturerId >= 0 && request.manufacturerHex.length > 0) {
      const unit: ble.ManufactureData = {
        manufactureId: request.manufacturerId,
        manufactureValue: BleAdvertiserDataSource.hexToBuffer(request.manufacturerHex)
      };
      manufactureData.push(unit);
    }
    const data: ble.AdvertiseData = {
      serviceUuids: serviceUuids,
      manufactureData: manufactureData,
      serviceData: serviceData,
      includeDeviceName: request.includeDeviceName
    };
    return data;
  }

  private static responseData(hex: string): ble.AdvertiseData {
    const serviceUuids: Array<string> = [];
    const manufactureData: Array<ble.ManufactureData> = [];
    const serviceData: Array<ble.ServiceData> = [];
    const unit: ble.ServiceData = {
      serviceUuid: '0000',
      serviceValue: BleAdvertiserDataSource.hexToBuffer(hex)
    };
    serviceData.push(unit);
    const data: ble.AdvertiseData = {
      serviceUuids: serviceUuids,
      manufactureData: manufactureData,
      serviceData: serviceData
    };
    return data;
  }

  private static hexToBuffer(hex: string): ArrayBuffer {
    const normalized = hex.replace(/\s/g, '');
    const length = Math.floor(normalized.length / 2);
    const buffer = new ArrayBuffer(length);
    const view = new Uint8Array(buffer);
    for (let i = 0; i < length; i++) {
      view[i] = parseInt(normalized.substring(i * 2, i * 2 + 2), 16);
    }
    return buffer;
  }
}
