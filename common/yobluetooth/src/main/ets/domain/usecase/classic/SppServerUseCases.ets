import { Result, ResultError } from 'common_core';
import { BluetoothConstants } from '../../../constants/BluetoothConstants';
import { BluetoothErrorCodes } from '../../../constants/BluetoothErrorCodes';
import { SppPlatformGateway } from '../../../data/platform/spp/SppPlatformGateway';
import { SppSocketKind } from '../../model/SppSocketKind';
import { BluetoothOperationGuard } from '../shared/BluetoothOperationGuard';

export class SppListenUseCase {
  private readonly gateway: SppPlatformGateway;
  private readonly guard: BluetoothOperationGuard;

  constructor(
    gateway: SppPlatformGateway = new SppPlatformGateway(),
    guard: BluetoothOperationGuard = new BluetoothOperationGuard()
  ) {
    this.gateway = gateway;
    this.guard = guard;
  }

  async execute(
    name: string,
    uuid: string = BluetoothConstants.DEFAULT_SPP_UUID,
    kind: SppSocketKind = SppSocketKind.RFCOMM,
    psm: number = 0
  ): Promise<Result<number>> {
    const ready = await this.guard.ensureOperational();
    if (!ready.success) {
      return Result.fail(ready.error ?? new ResultError(BluetoothErrorCodes.PERMISSION_DENIED, 'Not ready'));
    }
    if (kind !== SppSocketKind.RFCOMM && psm <= 0) {
      return Result.fail(new ResultError(BluetoothErrorCodes.L2CAP_PSM_REQUIRED, 'L2CAP listen requires a PSM'));
    }
    return this.gateway.listen(name, uuid, false, kind, psm);
  }

  async accept(serverSocket: number): Promise<Result<number>> {
    return this.gateway.accept(serverSocket);
  }

  closeServer(serverSocket: number): Result<void> {
    return this.gateway.closeServer(serverSocket);
  }
}
