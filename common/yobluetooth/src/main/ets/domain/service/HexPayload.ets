import { Result, ResultError } from 'common_core';
import { BluetoothErrorCodes } from '../../constants/BluetoothErrorCodes';

/**
 * Rejects odd length and non-hex characters before any write call.
 */
export class HexPayload {
  static parse(text: string): Result<Uint8Array> {
    const normalized = text.replace(/\s+/g, '');
    if (normalized.length === 0 || normalized.length % 2 !== 0) {
      return Result.fail(new ResultError(BluetoothErrorCodes.SPP_INVALID_PARAMS, 'Invalid hex'));
    }
    const bytes = new Uint8Array(normalized.length / 2);
    for (let i = 0; i < bytes.length; i++) {
      const pair = normalized.substring(i * 2, i * 2 + 2);
      if (!HexPayload.isHexPair(pair)) {
        return Result.fail(new ResultError(BluetoothErrorCodes.SPP_INVALID_PARAMS, 'Invalid hex'));
      }
      bytes[i] = parseInt(pair, 16);
    }
    return Result.ok(bytes);
  }

  private static isHexPair(pair: string): boolean {
    for (let i = 0; i < pair.length; i++) {
      const ch = pair.charAt(i);
      const digit = ch >= '0' && ch <= '9';
      const lower = ch >= 'a' && ch <= 'f';
      const upper = ch >= 'A' && ch <= 'F';
      if (!digit && !lower && !upper) {
        return false;
      }
    }
    return true;
  }
}
