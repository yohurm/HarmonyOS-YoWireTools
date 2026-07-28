/**
 * Minimal MQTT 3.1.1 wire encoding for CONNECT / SUBSCRIBE / PUBLISH.
 */
import { Result, ResultError } from 'common_core';
import { WifiNetworkErrorCodes } from '../../constants/WifiNetworkErrorCodes';
export class MqttWireCodec {
  static buildConnect(clientId: string, username: string = '', password: string = ''): Uint8Array {
    const protocolName = MqttWireCodec.encodeUtf8('MQTT');
    const variable: number[] = [];
    MqttWireCodec.appendBytes(variable, protocolName);
    variable.push(0x04);
    let flags = 0x02;
    if (username.length > 0) {
      flags |= 0x80;
    }
    if (password.length > 0) {
      flags |= 0x40;
    }
    variable.push(flags);
    variable.push(0x00, 0x3c);
    MqttWireCodec.appendBytes(variable, MqttWireCodec.encodeUtf8Field(clientId));
    if (username.length > 0) {
      MqttWireCodec.appendBytes(variable, MqttWireCodec.encodeUtf8Field(username));
    }
    if (password.length > 0) {
      MqttWireCodec.appendBytes(variable, MqttWireCodec.encodeUtf8Field(password));
    }
    return MqttWireCodec.buildPacket(0x10, variable);
  }
  static buildSubscribe(topic: string, packetId: number = 1): Uint8Array {
    const variable: number[] = [(packetId >> 8) & 0xff, packetId & 0xff];
    MqttWireCodec.appendBytes(variable, MqttWireCodec.encodeUtf8Field(topic));
    variable.push(0x00);
    return MqttWireCodec.buildPacket(0x82, variable);
  }
  static buildPublish(topic: string, payload: string): Uint8Array {
    const variable: number[] = [];
    MqttWireCodec.appendBytes(variable, MqttWireCodec.encodeUtf8Field(topic));
    const body = MqttWireCodec.encodeUtf8(payload);
    MqttWireCodec.appendBytes(variable, body);
    return MqttWireCodec.buildPacket(0x30, variable);
  }
  static parseConnAck(data: Uint8Array): Result<void> {
    if (data.length < 4 || data[0] !== 0x20) {
      return Result.fail(new ResultError(WifiNetworkErrorCodes.MQTT_INVALID_CONNACK, 'Invalid CONNACK packet'));
    }
    const returnCode = data[data.length - 1];
    if (returnCode !== 0) {
      return Result.fail(new ResultError(
        WifiNetworkErrorCodes.MQTT_CONN_REJECTED,
        `Broker rejected connection (code ${returnCode})`,
        undefined,
        {},
        `${returnCode}`
      ));
    }
    return Result.ok(undefined);
  }
  static parseSubAck(data: Uint8Array): Result<void> {
    if (data.length < 5 || data[0] !== 0x90) {
      return Result.fail(new ResultError(WifiNetworkErrorCodes.MQTT_INVALID_SUBACK, 'Invalid SUBACK packet'));
    }
    const qos = data[data.length - 1];
    if (qos === 0x80) {
      return Result.fail(new ResultError(WifiNetworkErrorCodes.MQTT_SUBSCRIBE_REJECTED, 'Subscribe rejected by broker'));
    }
    return Result.ok(undefined);
  }
  private static buildPacket(type: number, variable: number[]): Uint8Array {
    const remaining = MqttWireCodec.encodeRemainingLength(variable.length);
    const bytes = new Uint8Array(1 + remaining.length + variable.length);
    bytes[0] = type;
    for (let i = 0; i < remaining.length; i++) {
      bytes[i + 1] = remaining[i];
    }
    for (let i = 0; i < variable.length; i++) {
      bytes[i + 1 + remaining.length] = variable[i];
    }
    return bytes;
  }
  private static encodeRemainingLength(length: number): number[] {
    const encoded: number[] = [];
    let value = length;
    do {
      let digit = value % 128;
      value = Math.floor(value / 128);
      if (value > 0) {
        digit = digit | 0x80;
      }
      encoded.push(digit);
    } while (value > 0);
    return encoded;
  }
  private static encodeUtf8Field(text: string): number[] {
    const encoded = MqttWireCodec.encodeUtf8(text);
    const field: number[] = [(encoded.length >> 8) & 0xff, encoded.length & 0xff];
    MqttWireCodec.appendBytes(field, encoded);
    return field;
  }
  private static encodeUtf8(text: string): number[] {
    const bytes: number[] = [];
    for (let i = 0; i < text.length; i++) {
      bytes.push(text.charCodeAt(i));
    }
    return bytes;
  }
  private static appendBytes(target: number[], source: number[]): void {
    for (let i = 0; i < source.length; i++) {
      target.push(source[i]);
    }
  }
}
