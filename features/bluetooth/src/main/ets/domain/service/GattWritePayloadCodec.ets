import { EncodingUtil, Result } from 'common_core';
import { PayloadEncoding } from 'feature_debug_core';

export enum WritePayloadEncoding {
  TEXT = 'text',
  HEX = 'hex',
  BASE64 = 'base64'
}

/**
 * Decodes GATT write dialog input to bytes (text / hex / base64).
 */
export class GattWritePayloadCodec {
  static toBytes(payload: string, encoding: WritePayloadEncoding): Result<Uint8Array> {
    if (encoding === WritePayloadEncoding.TEXT) {
      const bytes = new Uint8Array(payload.length);
      for (let i = 0; i < payload.length; i++) {
        bytes[i] = payload.charCodeAt(i);
      }
      return Result.ok(bytes);
    }
    if (encoding === WritePayloadEncoding.HEX) {
      return Result.ok(EncodingUtil.hexToBytes(payload.replace(/\s/g, '')));
    }
    return EncodingUtil.base64ToBytes(payload);
  }

  static fromPayloadEncoding(encoding: WritePayloadEncoding): PayloadEncoding {
    if (encoding === WritePayloadEncoding.HEX) {
      return PayloadEncoding.HEX;
    }
    if (encoding === WritePayloadEncoding.BASE64) {
      return PayloadEncoding.BASE64;
    }
    return PayloadEncoding.TEXT;
  }
}
