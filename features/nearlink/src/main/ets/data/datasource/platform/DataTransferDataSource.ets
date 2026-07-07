import { dataTransfer } from '@kit.NearLinkKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { Result, ResultError } from 'common_core';
import { NearLinkConstants } from '../../../constants/NearLinkConstants';
import { NearLinkErrorCodes } from '../../../constants/NearLinkErrorCodes';
import { NearLinkKitEventBridge } from '../../kit/NearLinkKitEventBridge';

type ConnectionStateListener = (info: dataTransfer.ConnectionResult) => void;
type ReadDataListener = (info: dataTransfer.DataParams) => void;

export class DataTransferDataSource {
  private connectionHandler: ConnectionStateListener | undefined;
  private readHandler: ReadDataListener | undefined;
  private registeredUuid: string = '';

  createPort(uuid: string): Result<void> {
    try {
      dataTransfer.createPort(uuid);
      this.registeredUuid = uuid;
      return Result.ok(undefined);
    } catch (error) {
      const err = error as BusinessError;
      if (err.code === 1009700020) {
        return Result.fail(ResultError.fromError(NearLinkErrorCodes.DT_UUID_REGISTERED, err));
      }
      if (err.code === 1009700021) {
        return Result.fail(ResultError.fromError(NearLinkErrorCodes.DT_PORT_LIMIT, err));
      }
      return Result.fail(ResultError.fromError(NearLinkErrorCodes.DT_GENERIC_FAILED, err));
    }
  }

  destroyPort(uuid: string): Result<void> {
    try {
      dataTransfer.destroyPort(uuid);
      if (this.registeredUuid === uuid) {
        this.registeredUuid = '';
      }
      return Result.ok(undefined);
    } catch (error) {
      const err = error as BusinessError;
      if (err.code === 1009700022) {
        return Result.fail(ResultError.fromError(NearLinkErrorCodes.DT_UUID_NOT_REGISTERED, err));
      }
      return Result.fail(ResultError.fromError(NearLinkErrorCodes.DT_GENERIC_FAILED, err));
    }
  }

  async connect(address: string, uuid: string, mtu: number = NearLinkConstants.DEFAULT_MTU): Promise<Result<void>> {
    try {
      await dataTransfer.connect({ address: address, uuid: uuid, mtu: mtu });
      return Result.ok(undefined);
    } catch (error) {
      const err = error as BusinessError;
      return Result.fail(ResultError.fromError(NearLinkErrorCodes.DT_GENERIC_FAILED, err));
    }
  }

  async disconnect(address: string, uuid: string): Promise<Result<void>> {
    try {
      await dataTransfer.disconnect({ address: address, uuid: uuid });
      return Result.ok(undefined);
    } catch (error) {
      const err = error as BusinessError;
      return Result.fail(ResultError.fromError(NearLinkErrorCodes.DT_GENERIC_FAILED, err));
    }
  }

  async writeData(address: string, uuid: string, data: ArrayBuffer): Promise<Result<void>> {
    try {
      await dataTransfer.writeData({ address: address, uuid: uuid, data: data });
      return Result.ok(undefined);
    } catch (error) {
      const err = error as BusinessError;
      if (err.code === NearLinkConstants.CONGESTION_NATIVE_CODE) {
        return Result.fail(ResultError.fromError(NearLinkErrorCodes.DT_WRITE_CONGESTED, err));
      }
      return Result.fail(ResultError.fromError(NearLinkErrorCodes.DT_GENERIC_FAILED, err));
    }
  }

  getConnectionState(address: string, uuid: string): Result<dataTransfer.ConnectionState> {
    try {
      const state = dataTransfer.getConnectionState({ address: address, uuid: uuid });
      return Result.ok(state);
    } catch (error) {
      const err = error as BusinessError;
      return Result.fail(ResultError.fromError(NearLinkErrorCodes.DT_GENERIC_FAILED, err));
    }
  }

  onConnectionStateChanged(listener: ConnectionStateListener): Result<void> {
    this.offConnectionStateChanged();
    this.connectionHandler = listener;
    return NearLinkKitEventBridge.subscribeDataTransferConnectionState(this.connectionHandler);
  }

  offConnectionStateChanged(): void {
    if (this.connectionHandler !== undefined) {
      NearLinkKitEventBridge.unsubscribeDataTransferConnectionState(this.connectionHandler);
      this.connectionHandler = undefined;
    }
  }

  onReadData(listener: ReadDataListener): Result<void> {
    this.offReadData();
    this.readHandler = listener;
    return NearLinkKitEventBridge.subscribeReadData(this.readHandler);
  }

  offReadData(): void {
    if (this.readHandler !== undefined) {
      NearLinkKitEventBridge.unsubscribeReadData(this.readHandler);
      this.readHandler = undefined;
    }
  }

  release(uuid: string): void {
    this.offConnectionStateChanged();
    this.offReadData();
    if (this.registeredUuid.length === 0 || this.registeredUuid !== uuid) {
      return;
    }
    this.destroyPort(uuid);
  }
}
