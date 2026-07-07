import { TimeUtil } from 'common_core';
import { NearLinkDiscoveryPayload } from '../datasource/platform/NearLinkScanDataSource';
import { NearLinkDevice } from '../../domain/model/NearLinkDevice';

export class NearLinkDeviceMapper {
  static fromDiscovery(payload: NearLinkDiscoveryPayload, favorite: boolean = false, alias: string = ''): NearLinkDevice {
    return new NearLinkDevice(
      payload.randomAddress,
      payload.deviceName,
      payload.rssi,
      payload.rssiValid,
      payload.connectable,
      favorite,
      TimeUtil.nowMs(),
      TimeUtil.nowMs(),
      payload.advertising.serviceUuids,
      alias,
      payload.advertising.rawHex
    );
  }
}
