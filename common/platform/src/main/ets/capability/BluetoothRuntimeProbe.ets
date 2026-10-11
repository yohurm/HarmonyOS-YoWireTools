import { deviceInfo } from '@kit.BasicServicesKit';
import { TimeUtil } from 'common_core';
import { YoLog, YoLogTag, LogParams } from 'yolog';
import { CapabilityResult } from './CapabilityResult';
import { CapabilityStatus } from './CapabilityStatus';
import { ICapabilityProbe } from './ICapabilityProbe';
import { PlatformModuleType } from './PlatformModuleType';

const logger = YoLog.tag(YoLogTag.CAP);

/**
 * Bluetooth is unavailable on the emulator. This probe does not call Connectivity Kit
 * and does not invent devices.
 */
export class BluetoothRuntimeProbe implements ICapabilityProbe {
  readonly capabilityId: string;

  constructor(capabilityId: string) {
    this.capabilityId = capabilityId;
  }

  async probe(): Promise<CapabilityResult> {
    const emulator = BluetoothRuntimeProbe.isEmulator();
    const result = new CapabilityResult(
      this.capabilityId,
      PlatformModuleType.BLUETOOTH,
      emulator ? CapabilityStatus.UNAVAILABLE : CapabilityStatus.AVAILABLE,
      emulator ? 'emulator' : '',
      '',
      `${deviceInfo.sdkApiVersion}`,
      '',
      TimeUtil.nowMs(),
      deviceInfo.productModel
    );
    logger.params('capability_probe', LogParams.create()
      .put('module', 'bluetooth')
      .put('available', emulator ? 0 : 1)
      .put('reason', emulator ? 'emulator' : ''));
    return result;
  }

  static isEmulator(): boolean {
    const model = `${deviceInfo.productModel}`.toLowerCase();
    const market = `${deviceInfo.marketName}`.toLowerCase();
    const hardware = `${deviceInfo.hardwareModel}`.toLowerCase();
    return model.includes('emulator') || market.includes('emulator') || hardware.includes('emulator');
  }
}
