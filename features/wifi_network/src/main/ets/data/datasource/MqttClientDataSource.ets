import { socket } from '@kit.NetworkKit';
import { Result, ResultError } from 'common_core';
import { WifiNetworkErrorCodes } from '../../constants/WifiNetworkErrorCodes';
import { MqttConnectConfig } from '../../domain/model/MqttModels';
import { MqttWireCodec } from '../../domain/service/MqttWireCodec';
import { TcpSocketDataSource } from './TcpSocketDataSource';
import { NetworkKitEventBridge } from '../kit/NetworkKitEventBridge';

/**
 * Lightweight MQTT client over TCP per architecture 03-§9.
 * Waits for CONNACK/SUBACK before reporting connected.
 */
export class MqttClientDataSource {
  private static instance: MqttClientDataSource | undefined;
  private tcpSocket: socket.TCPSocket | undefined;
  private messageHandler: ((value: socket.SocketMessageInfo) => void) | undefined;

  static getInstance(): MqttClientDataSource {
    if (MqttClientDataSource.instance === undefined) {
      MqttClientDataSource.instance = new MqttClientDataSource();
    }
    return MqttClientDataSource.instance;
  }

  async connect(config: MqttConnectConfig): Promise<Result<void>> {
    const tcp = TcpSocketDataSource.getInstance();
    const connected = await tcp.connectWithTimeout(config.brokerHost, config.brokerPort, 10000);
    if (!connected.success || connected.value === undefined) {
      return Result.fail(connected.error ?? new ResultError(WifiNetworkErrorCodes.CONNECT_TIMEOUT, 'MQTT TCP failed'));
    }
    this.tcpSocket = connected.value;
    try {
      const packet = MqttWireCodec.buildConnect(config.clientId, config.username, config.password);
      await this.tcpSocket.send({ data: packet.buffer });
      const connAck = await this.awaitPacket(0x20, 8000);
      if (!connAck.success || connAck.value === undefined) {
        await this.disconnect();
        return Result.fail(connAck.error ?? new ResultError(WifiNetworkErrorCodes.CONNECT_TIMEOUT, 'CONNACK timeout'));
      }
      const connAckParsed = MqttWireCodec.parseConnAck(connAck.value);
      if (!connAckParsed.success) {
        await this.disconnect();
        return Result.fail(connAckParsed.error ?? new ResultError(WifiNetworkErrorCodes.CONNECT_TIMEOUT, 'CONNACK failed'));
      }
      const sub = MqttWireCodec.buildSubscribe(config.topic);
      await this.tcpSocket.send({ data: sub.buffer });
      const subAck = await this.awaitPacket(0x90, 8000);
      if (!subAck.success || subAck.value === undefined) {
        await this.disconnect();
        return Result.fail(subAck.error ?? new ResultError(WifiNetworkErrorCodes.CONNECT_TIMEOUT, 'SUBACK timeout'));
      }
      const subAckParsed = MqttWireCodec.parseSubAck(subAck.value);
      if (!subAckParsed.success) {
        await this.disconnect();
        return Result.fail(subAckParsed.error ?? new ResultError(WifiNetworkErrorCodes.CONNECT_TIMEOUT, 'SUBACK failed'));
      }
      return Result.ok(undefined);
    } catch (error) {
      const err = error as Error;
      await this.disconnect();
      return Result.fail(new ResultError(WifiNetworkErrorCodes.CONNECT_TIMEOUT, err.message, err));
    }
  }

  async publish(topic: string, payload: string): Promise<Result<void>> {
    if (this.tcpSocket === undefined) {
      return Result.fail(new ResultError(WifiNetworkErrorCodes.NOT_CONNECTED, 'MQTT not connected'));
    }
    try {
      const packet = MqttWireCodec.buildPublish(topic, payload);
      await this.tcpSocket.send({ data: packet.buffer });
      return Result.ok(undefined);
    } catch (error) {
      const err = error as Error;
      return Result.fail(new ResultError(WifiNetworkErrorCodes.CONNECT_TIMEOUT, err.message, err));
    }
  }

  onMessage(listener: (payload: string) => void): Result<void> {
    this.offMessage();
    if (this.tcpSocket === undefined) {
      return Result.fail(new ResultError(WifiNetworkErrorCodes.NOT_CONNECTED, 'MQTT not connected'));
    }
    this.messageHandler = (value: socket.SocketMessageInfo) => {
      if (typeof value.message === 'string') {
        listener(value.message);
        return;
      }
      if (value.message instanceof ArrayBuffer) {
        const bytes = new Uint8Array(value.message);
        if (bytes.length > 0 && (bytes[0] & 0xF0) === 0x30) {
          listener(MqttClientDataSource.decodePublishPayload(bytes));
        }
      }
    };
    return NetworkKitEventBridge.subscribeTcpMessage(this.tcpSocket, this.messageHandler);
  }

  offMessage(): void {
    if (this.tcpSocket !== undefined && this.messageHandler !== undefined) {
      NetworkKitEventBridge.unsubscribeTcpMessage(this.tcpSocket, this.messageHandler);
    }
    this.messageHandler = undefined;
  }

  async disconnect(): Promise<void> {
    this.offMessage();
    if (this.tcpSocket !== undefined) {
      try {
        await this.tcpSocket.close();
      } catch (_error) {
      }
      this.tcpSocket = undefined;
    }
  }

  private async awaitPacket(expectedType: number, timeoutMs: number): Promise<Result<Uint8Array>> {
    if (this.tcpSocket === undefined) {
      return Result.fail<Uint8Array>(new ResultError(WifiNetworkErrorCodes.NOT_CONNECTED, 'MQTT socket missing'));
    }
    const tcp = this.tcpSocket;
    return new Promise<Result<Uint8Array>>((resolve) => {
      let settled = false;
      const handler = (value: socket.SocketMessageInfo) => {
        if (settled) {
          return;
        }
        const bytes = MqttClientDataSource.toBytes(value.message);
        if (bytes.length === 0 || bytes[0] !== expectedType) {
          return;
        }
        settled = true;
        clearTimeout(timerId);
        NetworkKitEventBridge.unsubscribeTcpMessage(tcp, handler);
        resolve(Result.ok(bytes));
      };
      const subscribed = NetworkKitEventBridge.subscribeTcpMessage(tcp, handler);
      if (!subscribed.success) {
        resolve(Result.fail(subscribed.error ?? new ResultError(WifiNetworkErrorCodes.CONNECT_TIMEOUT, 'TCP subscribe failed')));
        return;
      }
      const timerId = setTimeout(() => {
        if (settled) {
          return;
        }
        settled = true;
        NetworkKitEventBridge.unsubscribeTcpMessage(tcp, handler);
        resolve(Result.fail(new ResultError(WifiNetworkErrorCodes.CONNECT_TIMEOUT, 'MQTT broker response timeout')));
      }, timeoutMs);
    });
  }

  private static toBytes(message: string | ArrayBuffer): Uint8Array {
    if (message instanceof ArrayBuffer) {
      return new Uint8Array(message);
    }
    const bytes = new Uint8Array(message.length);
    for (let i = 0; i < message.length; i++) {
      bytes[i] = message.charCodeAt(i);
    }
    return bytes;
  }

  private static decodePublishPayload(data: Uint8Array): string {
    let index = 1;
    while (index < data.length && (data[index] & 0x80) !== 0) {
      index++;
    }
    index++;
    if (index + 1 >= data.length) {
      return '';
    }
    const topicLength = (data[index] << 8) | data[index + 1];
    index = index + 2 + topicLength;
    if (index >= data.length) {
      return '';
    }
    const payloadBytes = data.slice(index);
    let text = '';
    for (let i = 0; i < payloadBytes.length; i++) {
      text += String.fromCharCode(payloadBytes[i]);
    }
    return text;
  }
}
