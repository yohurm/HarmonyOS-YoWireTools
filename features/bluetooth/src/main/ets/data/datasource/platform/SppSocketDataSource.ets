import { socket } from '@kit.ConnectivityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { Result, ResultError } from 'common_core';
import { BluetoothErrorCodes } from '../../../constants/BluetoothErrorCodes';
import { ConnectivityKitEventBridge } from '../../kit/ConnectivityKitEventBridge';

export class SppConnectOptions {
  readonly deviceId: string;
  readonly uuid: string;
  readonly secure: boolean;

  constructor(deviceId: string, uuid: string, secure: boolean) {
    this.deviceId = deviceId;
    this.uuid = uuid;
    this.secure = secure;
  }
}

type SppReadListener = (bytes: Uint8Array) => void;

/**
 * SPP socket platform wrapper per WSL ohos.bluetooth.socket and architecture bluetooth/02.
 */
export class SppSocketDataSource {
  private static instance: SppSocketDataSource | undefined;
  private readHandler: ((data: ArrayBuffer) => void) | undefined;
  private readClientSocket: number = -1;

  private constructor() {
  }

  static getInstance(): SppSocketDataSource {
    if (SppSocketDataSource.instance === undefined) {
      SppSocketDataSource.instance = new SppSocketDataSource();
    }
    return SppSocketDataSource.instance;
  }

  connect(options: SppConnectOptions): Promise<Result<number>> {
    return new Promise((resolve: (value: Result<number>) => void) => {
      try {
        const sppOptions: socket.SppOptions = {
          uuid: options.uuid,
          secure: options.secure,
          type: socket.SppType.SPP_RFCOMM
        };
        socket.sppConnect(options.deviceId, sppOptions, (err: BusinessError, clientSocket: number) => {
          if (err) {
            resolve(Result.fail(SppSocketDataSource.mapConnectError(err)));
            return;
          }
          resolve(Result.ok(clientSocket));
        });
      } catch (error) {
        const err = error as BusinessError;
        resolve(Result.fail(ResultError.fromError(BluetoothErrorCodes.SPP_CONNECT_FAILED, err)));
      }
    });
  }

  async writeAsync(clientSocket: number, bytes: Uint8Array): Promise<Result<number>> {
    try {
      const buffer = bytes.buffer.slice(bytes.byteOffset, bytes.byteOffset + bytes.byteLength);
      await socket.sppWriteAsync(clientSocket, buffer);
      return Result.ok(bytes.length);
    } catch (error) {
      const err = error as BusinessError;
      return Result.fail(SppSocketDataSource.mapIoError(err));
    }
  }

  write(clientSocket: number, bytes: Uint8Array): Result<number> {
    try {
      const buffer = bytes.buffer.slice(bytes.byteOffset, bytes.byteOffset + bytes.byteLength);
      socket.sppWrite(clientSocket, buffer);
      return Result.ok(bytes.length);
    } catch (error) {
      const err = error as BusinessError;
      return Result.fail(SppSocketDataSource.mapIoError(err));
    }
  }

  async readAsync(clientSocket: number): Promise<Result<Uint8Array>> {
    try {
      const buffer = await socket.sppReadAsync(clientSocket);
      if (buffer === undefined || buffer.byteLength === 0) {
        return Result.ok(new Uint8Array(0));
      }
      return Result.ok(new Uint8Array(buffer));
    } catch (error) {
      const err = error as BusinessError;
      return Result.fail(SppSocketDataSource.mapIoError(err));
    }
  }

  onSppRead(clientSocket: number, listener: SppReadListener): Result<void> {
    this.offSppRead();
    this.readClientSocket = clientSocket;
    this.readHandler = (data: ArrayBuffer) => {
      listener(new Uint8Array(data));
    };
    return ConnectivityKitEventBridge.subscribeSppRead(clientSocket, this.readHandler);
  }

  offSppRead(): void {
    if (this.readHandler !== undefined && this.readClientSocket >= 0) {
      ConnectivityKitEventBridge.unsubscribeSppRead(this.readClientSocket, this.readHandler);
    }
    this.readHandler = undefined;
    this.readClientSocket = -1;
  }

  close(clientSocket: number): Result<void> {
    try {
      this.offSppRead();
      socket.sppCloseClientSocket(clientSocket);
      return Result.ok(undefined);
    } catch (error) {
      const err = error as BusinessError;
      return Result.fail(ResultError.fromError(BluetoothErrorCodes.SPP_IO_ERROR, err));
    }
  }

  private static mapConnectError(err: BusinessError): ResultError {
    if (err.code === 201) {
      return new ResultError(BluetoothErrorCodes.PERMISSION_DENIED, err.message, err);
    }
    if (err.code === 401) {
      return new ResultError(BluetoothErrorCodes.SPP_INVALID_PARAMS, err.message, err);
    }
    if (err.code === 801) {
      return new ResultError(BluetoothErrorCodes.SPP_UNSUPPORTED, err.message, err);
    }
    if (err.code === 2900003) {
      return new ResultError(BluetoothErrorCodes.ADAPTER_OFF, err.message, err);
    }
    if (err.code === 2900004) {
      return new ResultError(BluetoothErrorCodes.SPP_PROFILE_UNSUPPORTED, err.message, err);
    }
    return new ResultError(BluetoothErrorCodes.SPP_CONNECT_FAILED, err.message, err);
  }

  private static mapIoError(err: BusinessError): ResultError {
    if (err.code === 2901054) {
      return new ResultError(BluetoothErrorCodes.SPP_IO_ERROR, err.message, err);
    }
    if (err.code === 2900003) {
      return new ResultError(BluetoothErrorCodes.ADAPTER_OFF, err.message, err);
    }
    return new ResultError(BluetoothErrorCodes.DISCONNECTED, err.message, err);
  }
}
