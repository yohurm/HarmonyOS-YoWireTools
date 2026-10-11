import { deviceInfo } from '@kit.BasicServicesKit';
import { dataTransfer } from '@kit.NearLinkKit';
import constant from '@hms.nearlink.constant';
import { BusinessError } from '@kit.BasicServicesKit';
import { NearLinkAdvParser } from '../../../domain/service/NearLinkAdvParser';
import { Result, ResultError } from 'common_core';
import { KitEventSubscription } from 'common_platform';
import { NearLinkConstants } from '../../../constants/NearLinkConstants';
import { NearLinkErrorCodes } from '../../../constants/NearLinkErrorCodes';

type ConnectionStateListener = (info: dataTransfer.ConnectionResult) => void;
type ReadDataListener = (info: dataTransfer.DataParams) => void;

export class DataTransferDataSource {
  private connectionHandler: ConnectionStateListener | undefined;
  private readHandler: ReadDataListener | undefined;
  private registeredUuid: string = '';

  createPort(uuid: string): Result<void> {
    if (deviceInfo.sdkApiVersion < NearLinkConstants.API_DATA_TRANSFER) {
      return Result.fail(new ResultError(
        NearLinkErrorCodes.VERSION_UNAVAILABLE,
        `api=createPort;since=${NearLinkConstants.SINCE_DATA_TRANSFER}`
      ));
    }
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

  async connect(
    address: string,
    uuid: string,
    mtu: number = NearLinkConstants.PORT_MTU_DEFAULT,
    reliable: boolean = false
  ): Promise<Result<void>> {
    if (deviceInfo.sdkApiVersion < NearLinkConstants.API_DATA_TRANSFER) {
      return Result.fail(new ResultError(
        NearLinkErrorCodes.VERSION_UNAVAILABLE,
        `api=connect;since=${NearLinkConstants.SINCE_DATA_TRANSFER}`
      ));
    }
    try {
      const mode = reliable ? dataTransfer.TransferMode.RELIABLE : dataTransfer.TransferMode.BASIC;
      await dataTransfer.connect({ address: address, uuid: uuid, mtu: mtu, transferMode: mode });
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
    const handler = listener;
    this.connectionHandler = handler;
    return KitEventSubscription.subscribe(() => {
      dataTransfer.on('connectionStateChanged', handler);
    }, 'dataTransfer.connectionStateChanged');
  }

  offConnectionStateChanged(): void {
    if (this.connectionHandler !== undefined) {
      const handler = this.connectionHandler;
      KitEventSubscription.unsubscribe(() => {
        dataTransfer.off('connectionStateChanged', handler);
      }, 'dataTransfer.connectionStateChanged');
      this.connectionHandler = undefined;
    }
  }

  watchLink(onState: (address: string, uuid: string, mtu: number, state: number) => void): Result<void> {
    return this.onConnectionStateChanged((info: dataTransfer.ConnectionResult) => {
      onState(info.address, info.uuid, info.mtu, DataTransferDataSource.stateCode(info.state));
    });
  }

  watchRead(onRead: (address: string, uuid: string, hex: string, byteLength: number) => void): Result<void> {
    return this.onReadData((info: dataTransfer.DataParams) => {
      const bytes = new Uint8Array(info.data);
      onRead(info.address, info.uuid, NearLinkAdvParser.toHex(bytes), bytes.byteLength);
    });
  }

  private static stateCode(state: dataTransfer.ConnectionState): number {
    if (state === constant.ConnectionState.STATE_CONNECTING) {
      return 0;
    }
    if (state === constant.ConnectionState.STATE_CONNECTED) {
      return 1;
    }
    if (state === constant.ConnectionState.STATE_DISCONNECTING) {
      return 2;
    }
    return 3;
  }

  onReadData(listener: ReadDataListener): Result<void> {
    this.offReadData();
    const handler = listener;
    this.readHandler = handler;
    return KitEventSubscription.subscribe(() => {
      dataTransfer.on('readData', handler);
    }, 'dataTransfer.readData');
  }

  offReadData(): void {
    if (this.readHandler !== undefined) {
      const handler = this.readHandler;
      KitEventSubscription.unsubscribe(() => {
        dataTransfer.off('readData', handler);
      }, 'dataTransfer.readData');
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
