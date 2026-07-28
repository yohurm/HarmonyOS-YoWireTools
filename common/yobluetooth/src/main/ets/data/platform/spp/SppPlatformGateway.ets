import { socket } from '@kit.ConnectivityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { Result, ResultError } from 'common_core';
import { BluetoothErrorCodes } from '../../../constants/BluetoothErrorCodes';
import { ConnectivityKitEventBridge } from '../../kit/ConnectivityKitEventBridge';

/**
 * RFCOMM connect request — maps 1:1 to HarmonyOS socket.SppOptions (SPP_RFCOMM).
 * @see ohos.bluetooth.socket sppConnect(deviceId, options, callback)
 */
export class SppRfcommConnectRequest {
  readonly classicDeviceId: string;
  readonly serviceUuid: string;
  readonly secure: boolean;

  constructor(classicDeviceId: string, serviceUuid: string, secure: boolean = false) {
    this.classicDeviceId = classicDeviceId;
    this.serviceUuid = serviceUuid;
    this.secure = secure;
  }
}

type SppReadHandler = (data: ArrayBuffer) => void;

/**
 * Stateless HarmonyOS socket.* gateway (architecture 02 L1).
 * Holds no session/slot/socket maps — every call takes an explicit clientSocket.
 *
 * Official rules:
 * - sppReadAsync and on('sppRead') must not mix on the same clientSocket
 * - Close order: off('sppRead') first (when event-read was used), then sppCloseClientSocket
 * - 2901054 on sppReadAsync / sppWriteAsync means link IO error / disconnect
 */
export class SppPlatformGateway {
  connect(request: SppRfcommConnectRequest): Promise<Result<number>> {
    return new Promise((resolve: (value: Result<number>) => void) => {
      try {
        const options: socket.SppOptions = {
          uuid: request.serviceUuid,
          secure: request.secure,
          type: socket.SppType.SPP_RFCOMM
        };
        socket.sppConnect(request.classicDeviceId, options, (err: BusinessError, clientSocket: number) => {
          if (err) {
            resolve(Result.fail(SppPlatformGateway.mapConnectError(err)));
            return;
          }
          resolve(Result.ok(clientSocket));
        });
      } catch (error) {
        const err = error as BusinessError;
        resolve(Result.fail(ResultError.fromBusinessError(BluetoothErrorCodes.SPP_CONNECT_FAILED, err)));
      }
    });
  }

  async writeAsync(clientSocket: number, bytes: Uint8Array): Promise<Result<number>> {
    if (clientSocket < 0) {
      return Result.fail(new ResultError(BluetoothErrorCodes.NOT_CONNECTED, 'invalid clientSocket'));
    }
    try {
      const buffer = bytes.buffer.slice(bytes.byteOffset, bytes.byteOffset + bytes.byteLength);
      await socket.sppWriteAsync(clientSocket, buffer);
      return Result.ok(bytes.length);
    } catch (error) {
      const err = error as BusinessError;
      return Result.fail(SppPlatformGateway.mapIoError(err));
    }
  }

  /**
   * Serial sppReadAsync — caller must await before the next read on this socket.
   */
  async readAsync(clientSocket: number): Promise<Result<Uint8Array>> {
    if (clientSocket < 0) {
      return Result.fail(new ResultError(BluetoothErrorCodes.NOT_CONNECTED, 'invalid clientSocket'));
    }
    try {
      const buffer = await socket.sppReadAsync(clientSocket);
      if (buffer === undefined || buffer.byteLength === 0) {
        return Result.ok(new Uint8Array(0));
      }
      return Result.ok(new Uint8Array(buffer));
    } catch (error) {
      const err = error as BusinessError;
      return Result.fail(SppPlatformGateway.mapIoError(err));
    }
  }

  /**
   * Per-socket on('sppRead'). Returns unsubscribe that MUST run before closeClient.
   */
  subscribeRead(clientSocket: number, listener: (bytes: Uint8Array) => void): Result<() => void> {
    if (clientSocket < 0) {
      return Result.fail(new ResultError(BluetoothErrorCodes.NOT_CONNECTED, 'invalid clientSocket'));
    }
    const handler: SppReadHandler = (data: ArrayBuffer) => {
      listener(new Uint8Array(data));
    };
    const subscribed = ConnectivityKitEventBridge.subscribeSppRead(clientSocket, handler);
    if (!subscribed.success) {
      return Result.fail(subscribed.error ?? new ResultError(BluetoothErrorCodes.SPP_IO_ERROR, 'subscribe failed'));
    }
    const unsubscribe = (): void => {
      ConnectivityKitEventBridge.unsubscribeSppRead(clientSocket, handler);
    };
    return Result.ok(unsubscribe);
  }

  /**
   * Close one clientSocket. Order is mandatory when event-read was used:
   * 1) unsubscribeRead → socket.off('sppRead', clientSocket, handler)
   * 2) socket.sppCloseClientSocket(clientSocket)
   */
  closeClient(clientSocket: number, unsubscribeRead?: () => void): Result<void> {
    try {
      if (unsubscribeRead !== undefined) {
        unsubscribeRead();
      }
      if (clientSocket >= 0) {
        socket.sppCloseClientSocket(clientSocket);
      }
      return Result.ok(undefined);
    } catch (error) {
      const err = error as BusinessError;
      return Result.fail(ResultError.fromBusinessError(BluetoothErrorCodes.SPP_IO_ERROR, err));
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

  /** Maps 2901054 → YW-BT-1315 (link IO / disconnect). */
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
