import { socket } from '@kit.ConnectivityKit';
import { BusinessError, deviceInfo } from '@kit.BasicServicesKit';
import { Result, ResultError } from 'common_core';
import { YoLog, YoLogger } from 'yolog';
import { BluetoothConstants } from '../../../constants/BluetoothConstants';
import { BluetoothErrorCodes } from '../../../constants/BluetoothErrorCodes';
import { BluetoothPlatformCodes } from '../../../constants/BluetoothPlatformCodes';
import { SppSocketKind } from '../../../domain/model/SppSocketKind';
import { BtLogTag } from '../../../observability/BtLogTag';
import { ConnectivityKitEventBridge } from '../../kit/ConnectivityKitEventBridge';

const logger: YoLogger = YoLog.tag(BtLogTag.SPP);

/**
 * RFCOMM connect request — maps 1:1 to HarmonyOS socket.SppOptions (SPP_RFCOMM).
 * @see ohos.bluetooth.socket sppConnect(deviceId, options, callback)
 */
export class SppRfcommConnectRequest {
  readonly classicDeviceId: string;
  readonly serviceUuid: string;
  readonly secure: boolean;
  readonly socketKind: SppSocketKind;
  readonly psm: number;

  constructor(
    classicDeviceId: string,
    serviceUuid: string,
    secure: boolean = false,
    socketKind: SppSocketKind = SppSocketKind.RFCOMM,
    psm: number = 0
  ) {
    this.classicDeviceId = classicDeviceId;
    this.serviceUuid = serviceUuid;
    this.secure = secure;
    this.socketKind = socketKind;
    this.psm = psm;
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
        if (request.socketKind !== SppSocketKind.RFCOMM && request.psm <= 0) {
          resolve(Result.fail(new ResultError(
            BluetoothErrorCodes.L2CAP_PSM_REQUIRED,
            'L2CAP connect requires a PSM'
          )));
          return;
        }
        const options: socket.SppOptions = {
          uuid: request.serviceUuid,
          secure: request.secure,
          type: SppPlatformGateway.toSppType(request.socketKind)
        };
        if (request.socketKind !== SppSocketKind.RFCOMM) {
          options.psm = request.psm;
        }
        logger.i(`sppConnect begin device=${request.classicDeviceId} uuid=${request.serviceUuid} secure=${request.secure}`);
        socket.sppConnect(request.classicDeviceId, options, (err: BusinessError, clientSocket: number) => {
          if (err) {
            logger.e(`sppConnect fail code=${err.code} msg=${err.message}`);
            resolve(Result.fail(SppPlatformGateway.mapConnectError(err)));
            return;
          }
          logger.i(`sppConnect ok socket=${clientSocket}`);
          resolve(Result.ok(clientSocket));
        });
      } catch (error) {
        const err = error as BusinessError;
        logger.e(`sppConnect throw code=${err.code} msg=${err.message}`);
        resolve(Result.fail(ResultError.fromBusinessError(BluetoothErrorCodes.SPP_CONNECT_FAILED, err)));
      }
    });
  }

  async writeAsync(clientSocket: number, bytes: Uint8Array): Promise<Result<number>> {
    if (clientSocket < 0) {
      return Result.fail(new ResultError(BluetoothErrorCodes.NOT_CONNECTED, 'invalid clientSocket'));
    }
    if (deviceInfo.sdkApiVersion >= BluetoothConstants.SPP_SOCKET_QUERY_API &&
      !socket.isConnected(clientSocket)) {
      return Result.fail(new ResultError(BluetoothErrorCodes.NOT_CONNECTED, 'socket is not connected'));
    }
    if (bytes.length > BluetoothConstants.SPP_MAX_WRITE_BYTES) {
      return Result.fail(new ResultError(
        BluetoothErrorCodes.SPP_WRITE_TOO_LARGE,
        'Single SPP write exceeds 1024 bytes'
      ));
    }
    try {
      const buffer = bytes.buffer.slice(bytes.byteOffset, bytes.byteOffset + bytes.byteLength);
      await socket.sppWriteAsync(clientSocket, buffer);
      logger.i(`sppWriteAsync ok socket=${clientSocket} len=${bytes.length} hex=${SppPlatformGateway.previewHex(bytes)}`);
      return Result.ok(bytes.length);
    } catch (error) {
      const err = error as BusinessError;
      logger.e(`sppWriteAsync fail socket=${clientSocket} code=${err.code} msg=${err.message}`);
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
        logger.w(`sppReadAsync empty socket=${clientSocket}`);
        return Result.ok(new Uint8Array(0));
      }
      return Result.ok(new Uint8Array(buffer));
    } catch (error) {
      const err = error as BusinessError;
      logger.e(`sppReadAsync fail socket=${clientSocket} code=${err.code} msg=${err.message}`);
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
    const mapped = BluetoothPlatformCodes.domainCode(err.code);
    if (mapped.length > 0) {
      return new ResultError(mapped, err.message, err, {}, `${err.code}`);
    }
    if (err.code === BluetoothPlatformCodes.PROFILE_BUSY) {
      return new ResultError(BluetoothErrorCodes.SPP_PROFILE_UNSUPPORTED, err.message, err, {}, `${err.code}`);
    }
    return new ResultError(BluetoothErrorCodes.SPP_CONNECT_FAILED, err.message, err, {}, `${err.code}`);
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

  listen(
    name: string,
    uuid: string,
    secure: boolean,
    kind: SppSocketKind,
    psm: number
  ): Promise<Result<number>> {
    return new Promise((resolve: (value: Result<number>) => void) => {
      try {
        const options: socket.SppOptions = {
          uuid: uuid,
          secure: secure,
          type: SppPlatformGateway.toSppType(kind)
        };
        if (kind !== SppSocketKind.RFCOMM) {
          options.psm = psm;
        }
        socket.sppListen(name, options, (err: BusinessError, serverSocket: number) => {
          if (err) {
            resolve(Result.fail(SppPlatformGateway.mapConnectError(err)));
            return;
          }
          resolve(Result.ok(serverSocket));
        });
      } catch (error) {
        const err = error as BusinessError;
        resolve(Result.fail(ResultError.fromBusinessError(BluetoothErrorCodes.SPP_CONNECT_FAILED, err)));
      }
    });
  }

  accept(serverSocket: number): Promise<Result<number>> {
    return new Promise((resolve: (value: Result<number>) => void) => {
      try {
        socket.sppAccept(serverSocket, (err: BusinessError, clientSocket: number) => {
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

  closeServer(serverSocket: number): Result<void> {
    try {
      if (serverSocket >= 0) {
        socket.sppCloseServerSocket(serverSocket);
      }
      return Result.ok(undefined);
    } catch (error) {
      const err = error as BusinessError;
      return Result.fail(ResultError.fromBusinessError(BluetoothErrorCodes.SPP_IO_ERROR, err));
    }
  }

  maxTransmitBytes(clientSocket: number): Result<number> {
    if (deviceInfo.sdkApiVersion < BluetoothConstants.SPP_SOCKET_QUERY_API) {
      return Result.fail(new ResultError(
        BluetoothErrorCodes.CAPABILITY_UNSUPPORTED,
        'getMaxTransmitDataSize requires API 22'
      ));
    }
    try {
      return Result.ok(socket.getMaxTransmitDataSize(clientSocket));
    } catch (error) {
      const err = error as BusinessError;
      return Result.fail(ResultError.fromBusinessError(BluetoothErrorCodes.SPP_IO_ERROR, err));
    }
  }

  private static toSppType(kind: SppSocketKind): socket.SppType {
    if (kind === SppSocketKind.L2CAP) {
      return socket.SppType.SPP_L2CAP;
    }
    if (kind === SppSocketKind.L2CAP_BLE) {
      return socket.SppType.SPP_L2CAP_BLE;
    }
    return socket.SppType.SPP_RFCOMM;
  }

  private static previewHex(bytes: Uint8Array): string {
    const limit = bytes.length > 24 ? 24 : bytes.length;
    const parts: string[] = [];
    for (let i = 0; i < limit; i++) {
      const hex = bytes[i].toString(16).toUpperCase();
      parts.push(hex.length === 1 ? `0${hex}` : hex);
    }
    return bytes.length > limit ? `${parts.join(' ')}…` : parts.join(' ');
  }
}
