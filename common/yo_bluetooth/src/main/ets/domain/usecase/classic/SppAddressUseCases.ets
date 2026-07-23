import { Result, ResultError } from 'common_core';
import { BluetoothErrorCodes } from '../../../constants/BluetoothErrorCodes';
import { BluetoothRepository } from '../../../data/repository/BluetoothRepository';
import { BluetoothDevice } from '../../model/BluetoothDevice';
import {
  BluetoothTransportPolicy,
  BluetoothTransportType
} from '../../model/BluetoothTransportType';
import { DeviceIdentity } from '../../model/DeviceIdentity';
import { PairingState } from '../../model/PairingState';
import { PairBluetoothDeviceUseCase } from './ClassicScanUseCases';

/**
 * Ensures a classic address for sppConnect. Rejects BLE-only / BLE address misuse.
 */
export class ResolveSppTargetAddressUseCase {
  private readonly repository: BluetoothRepository;

  constructor(repository: BluetoothRepository = BluetoothRepository.getInstance()) {
    this.repository = repository;
  }

  execute(device: BluetoothDevice): Result<string> {
    return this.repository.resolveClassicIdForSpp(device);
  }

  executeFromAddress(deviceId: string, transportHint: BluetoothTransportType = BluetoothTransportType.UNKNOWN): Result<string> {
    if (deviceId.length === 0) {
      return Result.fail(new ResultError(BluetoothErrorCodes.SPP_INVALID_PARAMS, 'empty device id'));
    }
    let transport = transportHint;
    if (transport === BluetoothTransportType.UNKNOWN) {
      const queried = this.repository.getRemoteDeviceTransport(deviceId);
      if (queried.success && queried.value !== undefined) {
        transport = queried.value;
      }
    }
    if (transport === BluetoothTransportType.LE) {
      return Result.fail(new ResultError(
        BluetoothErrorCodes.SPP_TARGET_LE_ONLY,
        'LE-only device cannot use SPP'
      ));
    }
    if (BluetoothTransportPolicy.isClassicCandidate(transport) ||
      transport === BluetoothTransportType.UNKNOWN) {
      return Result.ok(deviceId);
    }
    return Result.fail(new ResultError(
      BluetoothErrorCodes.SPP_BLE_ADDRESS_REJECTED,
      'Address not eligible for SPP'
    ));
  }
}

/**
 * Official BLE → Classic dual-mode bridge:
 * pair via BLE MAC → paired list gains classic MAC → name match → link identity.
 */
export class BridgeBleToClassicPairUseCase {
  private readonly repository: BluetoothRepository;
  private readonly pairDevice: PairBluetoothDeviceUseCase;

  constructor(
    repository: BluetoothRepository = BluetoothRepository.getInstance(),
    pairDevice: PairBluetoothDeviceUseCase = new PairBluetoothDeviceUseCase()
  ) {
    this.repository = repository;
    this.pairDevice = pairDevice;
  }

  async execute(bleDeviceId: string, displayNameHint: string = ''): Promise<Result<DeviceIdentity>> {
    if (bleDeviceId.length === 0) {
      return Result.fail(new ResultError(BluetoothErrorCodes.SPP_INVALID_PARAMS, 'empty ble id'));
    }
    const paired = await this.pairDevice.execute(bleDeviceId);
    if (!paired.success) {
      return Result.fail(paired.error ?? new ResultError(BluetoothErrorCodes.PAIRING_CANCELLED, 'pair failed'));
    }
    const classic = await this.repository.loadPairedClassicCandidates();
    if (!classic.success || classic.value === undefined) {
      return Result.fail(classic.error ?? new ResultError(BluetoothErrorCodes.CLASSIC_UNAVAILABLE, 'reload paired failed'));
    }
    const hint = displayNameHint.trim().toLowerCase();
    const candidates: BluetoothDevice[] = [];
    for (let i = 0; i < classic.value.length; i++) {
      const device = classic.value[i];
      if (device.classicDeviceId.length === 0) {
        continue;
      }
      if (device.classicDeviceId === bleDeviceId || device.primaryDeviceId === bleDeviceId) {
        continue;
      }
      if (hint.length > 0) {
        if (device.effectiveName.trim().toLowerCase() === hint) {
          candidates.push(device);
        }
        continue;
      }
      candidates.push(device);
    }
    if (hint.length === 0 && candidates.length !== 1) {
      return Result.fail(new ResultError(
        BluetoothErrorCodes.DUAL_BRIDGE_NAME_MISMATCH,
        'Need unique display name to resolve classic MAC after BLE pairing'
      ));
    }
    if (candidates.length !== 1 || candidates[0].classicDeviceId.length === 0) {
      return Result.fail(new ResultError(
        BluetoothErrorCodes.DUAL_BRIDGE_NAME_MISMATCH,
        'Could not resolve classic MAC after BLE pairing'
      ));
    }
    const matched = candidates[0];
    const identity = this.repository.linkDualModeIdentity(
      matched.classicDeviceId,
      bleDeviceId,
      matched.effectiveName
    );
    return Result.ok(identity);
  }
}

export class ResolveGattTargetAddressUseCase {
  execute(device: BluetoothDevice): Result<string> {
    if (device.bleDeviceId.length > 0) {
      return Result.ok(device.bleDeviceId);
    }
    if (device.transport === BluetoothTransportType.BR_EDR) {
      return Result.fail(new ResultError(
        BluetoothErrorCodes.GATT_CLASSIC_ADDRESS_REJECTED,
        'Classic-only address cannot create GATT client'
      ));
    }
    if (device.primaryDeviceId.length > 0) {
      return Result.ok(device.primaryDeviceId);
    }
    return Result.fail(new ResultError(
      BluetoothErrorCodes.GATT_CLASSIC_ADDRESS_REJECTED,
      'No BLE address resolved for GATT'
    ));
  }
}
