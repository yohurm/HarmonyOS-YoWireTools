import { BluetoothErrorCodes } from './BluetoothErrorCodes';

/**
 * Platform numeric codes classified into domain codes at the call site.
 * This is not a version wrapper.
 */
export class BluetoothPlatformCodes {
  static readonly SERVICE_STOPPED: number = 2900001;
  static readonly ADAPTER_OFF: number = 2900003;
  static readonly PROFILE_BUSY: number = 2900004;
  static readonly NOT_CONNECTED: number = 2900005;
  static readonly TIMEOUT: number = 2900007;
  static readonly RESOURCE: number = 2900009;
  static readonly TOO_FREQUENT: number = 2900011;
  static readonly NOT_PAIRED: number = 2900016;
  static readonly OPERATION_SEQUENCE: number = 2900099;
  static readonly GATT_READ_NOT_PERMITTED: number = 2901000;
  static readonly GATT_WRITE_NOT_PERMITTED: number = 2901001;
  static readonly GATT_NOT_CONNECTED: number = 2901003;
  static readonly GATT_INSUFFICIENT_ENCRYPTION: number = 2901005;
  static readonly GATT_INSUFFICIENT_AUTHENTICATION: number = 2901006;
  static readonly GATT_INSUFFICIENT_AUTHORIZATION: number = 2901007;
  static readonly GATT_SERVICE_NOT_FOUND: number = 2901008;
  static readonly SPP_LINK_IO: number = 2901054;
  static readonly SCAN_FAILED: number = 2902050;
  static readonly ADV_DATA_TOO_LONG: number = 2902054;
  static readonly CAPABILITY_UNSUPPORTED: number = 801;

  static domainCode(platformCode: number): string {
    if (platformCode === BluetoothPlatformCodes.SERVICE_STOPPED) {
      return BluetoothErrorCodes.SERVICE_STOPPED;
    }
    if (platformCode === BluetoothPlatformCodes.ADAPTER_OFF) {
      return BluetoothErrorCodes.ADAPTER_OFF;
    }
    if (platformCode === BluetoothPlatformCodes.NOT_CONNECTED) {
      return BluetoothErrorCodes.NOT_CONNECTED;
    }
    if (platformCode === BluetoothPlatformCodes.TIMEOUT) {
      return BluetoothErrorCodes.GATT_TIMEOUT;
    }
    if (platformCode === BluetoothPlatformCodes.RESOURCE || platformCode === BluetoothPlatformCodes.SCAN_FAILED) {
      return BluetoothErrorCodes.SCAN_RESOURCE_FAILED;
    }
    if (platformCode === BluetoothPlatformCodes.TOO_FREQUENT) {
      return BluetoothErrorCodes.TOO_FREQUENT;
    }
    if (platformCode === BluetoothPlatformCodes.NOT_PAIRED) {
      return BluetoothErrorCodes.NOT_PAIRED;
    }
    if (platformCode === BluetoothPlatformCodes.OPERATION_SEQUENCE) {
      return BluetoothErrorCodes.GATT_SEQUENCE;
    }
    if (platformCode === BluetoothPlatformCodes.GATT_READ_NOT_PERMITTED ||
      platformCode === BluetoothPlatformCodes.GATT_WRITE_NOT_PERMITTED) {
      return BluetoothErrorCodes.GATT_PROPERTY;
    }
    if (platformCode === BluetoothPlatformCodes.GATT_NOT_CONNECTED) {
      return BluetoothErrorCodes.GATT_NOT_CONNECTED;
    }
    if (platformCode === BluetoothPlatformCodes.GATT_INSUFFICIENT_ENCRYPTION) {
      return BluetoothErrorCodes.GATT_INSUFFICIENT_ENCRYPTION;
    }
    if (platformCode === BluetoothPlatformCodes.GATT_INSUFFICIENT_AUTHENTICATION) {
      return BluetoothErrorCodes.GATT_INSUFFICIENT_AUTHENTICATION;
    }
    if (platformCode === BluetoothPlatformCodes.GATT_INSUFFICIENT_AUTHORIZATION) {
      return BluetoothErrorCodes.GATT_INSUFFICIENT_AUTHORIZATION;
    }
    if (platformCode === BluetoothPlatformCodes.GATT_SERVICE_NOT_FOUND) {
      return BluetoothErrorCodes.GATT_SERVICE_MISSING;
    }
    if (platformCode === BluetoothPlatformCodes.ADV_DATA_TOO_LONG) {
      return BluetoothErrorCodes.ADV_TOO_LONG;
    }
    if (platformCode === BluetoothPlatformCodes.CAPABILITY_UNSUPPORTED) {
      return BluetoothErrorCodes.CAPABILITY_UNSUPPORTED;
    }
    if (platformCode === 201) {
      return BluetoothErrorCodes.PERMISSION_DENIED;
    }
    return '';
  }
}
