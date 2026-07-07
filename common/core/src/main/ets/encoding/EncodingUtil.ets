import { Result } from '../result/Result';
import { ResultError } from '../result/ResultError';

const HEX_PATTERN: RegExp = /^[0-9a-fA-F\s]*$/;

/**
 * Byte, hex, base64, and UTF-8 text encoding primitives.
 */
export class EncodingUtil {
  static textToHex(text: string): Result<string> {
    const bytes = EncodingUtil.stringToUtf8Bytes(text);
    return Result.ok(EncodingUtil.bytesToHex(bytes));
  }

  static hexToText(hex: string): Result<string> {
    const normalized = hex.replace(/\s+/g, '');
    if (normalized.length === 0) {
      return Result.ok('');
    }
    if (normalized.length % 2 !== 0 || !HEX_PATTERN.test(hex)) {
      return Result.fail(new ResultError('CORE-ENC-003', 'Invalid hex payload'));
    }
    const bytes = EncodingUtil.hexToBytes(normalized);
    return Result.ok(EncodingUtil.utf8BytesToString(bytes));
  }

  static textToBase64(text: string): Result<string> {
    const bytes = EncodingUtil.stringToUtf8Bytes(text);
    return Result.ok(EncodingUtil.bytesToBase64(bytes));
  }

  static base64ToText(base64: string): Result<string> {
    const bytesResult = EncodingUtil.base64ToBytes(base64);
    if (!bytesResult.success || bytesResult.value === undefined) {
      return Result.fail(bytesResult.error ?? new ResultError('CORE-ENC-004', 'Invalid base64 payload'));
    }
    return Result.ok(EncodingUtil.utf8BytesToString(bytesResult.value));
  }

  static stringToUtf8Bytes(text: string): Uint8Array {
    const bytes: number[] = [];
    for (let i = 0; i < text.length; i++) {
      let codePoint = text.charCodeAt(i);
      if (codePoint >= 0xD800 && codePoint <= 0xDBFF && i + 1 < text.length) {
        const next = text.charCodeAt(i + 1);
        if (next >= 0xDC00 && next <= 0xDFFF) {
          codePoint = 0x10000 + ((codePoint - 0xD800) << 10) + (next - 0xDC00);
          i++;
        }
      }
      if (codePoint <= 0x7F) {
        bytes.push(codePoint);
      } else if (codePoint <= 0x7FF) {
        bytes.push(0xC0 | (codePoint >> 6));
        bytes.push(0x80 | (codePoint & 0x3F));
      } else if (codePoint <= 0xFFFF) {
        bytes.push(0xE0 | (codePoint >> 12));
        bytes.push(0x80 | ((codePoint >> 6) & 0x3F));
        bytes.push(0x80 | (codePoint & 0x3F));
      } else {
        bytes.push(0xF0 | (codePoint >> 18));
        bytes.push(0x80 | ((codePoint >> 12) & 0x3F));
        bytes.push(0x80 | ((codePoint >> 6) & 0x3F));
        bytes.push(0x80 | (codePoint & 0x3F));
      }
    }
    return new Uint8Array(bytes);
  }

  static utf8BytesToString(bytes: Uint8Array): string {
    let result = '';
    let i = 0;
    while (i < bytes.length) {
      const b0 = bytes[i];
      if (b0 <= 0x7F) {
        result += String.fromCharCode(b0);
        i++;
      } else if ((b0 & 0xE0) === 0xC0 && i + 1 < bytes.length) {
        const codePoint = ((b0 & 0x1F) << 6) | (bytes[i + 1] & 0x3F);
        result += String.fromCharCode(codePoint);
        i += 2;
      } else if ((b0 & 0xF0) === 0xE0 && i + 2 < bytes.length) {
        const codePoint = ((b0 & 0x0F) << 12) | ((bytes[i + 1] & 0x3F) << 6) | (bytes[i + 2] & 0x3F);
        result += String.fromCharCode(codePoint);
        i += 3;
      } else if ((b0 & 0xF8) === 0xF0 && i + 3 < bytes.length) {
        const codePoint = ((b0 & 0x07) << 18) | ((bytes[i + 1] & 0x3F) << 12) |
          ((bytes[i + 2] & 0x3F) << 6) | (bytes[i + 3] & 0x3F);
        const adjusted = codePoint - 0x10000;
        result += String.fromCharCode(0xD800 + (adjusted >> 10));
        result += String.fromCharCode(0xDC00 + (adjusted & 0x3FF));
        i += 4;
      } else {
        result += String.fromCharCode(0xFFFD);
        i++;
      }
    }
    return result;
  }

  static bytesToHex(bytes: Uint8Array): string {
    let hex = '';
    for (let i = 0; i < bytes.length; i++) {
      const part = bytes[i].toString(16).padStart(2, '0');
      hex += part;
    }
    return hex.toUpperCase();
  }

  static hexToBytes(hex: string): Uint8Array {
    const bytes = new Uint8Array(hex.length / 2);
    for (let i = 0; i < hex.length; i += 2) {
      bytes[i / 2] = parseInt(hex.substring(i, i + 2), 16);
    }
    return bytes;
  }

  static bytesToBase64(bytes: Uint8Array): string {
    const alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
    let output = '';
    const remainder = bytes.length % 3;
    const mainLength = bytes.length - remainder;
    let i = 0;
    while (i < mainLength) {
      const b0 = bytes[i++];
      const b1 = bytes[i++];
      const b2 = bytes[i++];
      const triple = (b0 << 16) | (b1 << 8) | b2;
      output += alphabet.charAt((triple >> 18) & 0x3F);
      output += alphabet.charAt((triple >> 12) & 0x3F);
      output += alphabet.charAt((triple >> 6) & 0x3F);
      output += alphabet.charAt(triple & 0x3F);
    }
    if (remainder === 1) {
      const b0 = bytes[bytes.length - 1];
      output += alphabet.charAt((b0 >> 2) & 0x3F);
      output += alphabet.charAt((b0 << 4) & 0x3F);
      output += '==';
    } else if (remainder === 2) {
      const b0 = bytes[bytes.length - 2];
      const b1 = bytes[bytes.length - 1];
      output += alphabet.charAt((b0 >> 2) & 0x3F);
      output += alphabet.charAt(((b0 << 4) | (b1 >> 4)) & 0x3F);
      output += alphabet.charAt((b1 << 2) & 0x3F);
      output += '=';
    }
    return output;
  }

  static base64ToBytes(base64: string): Result<Uint8Array> {
    const normalized = base64.replace(/\s+/g, '');
    if (normalized.length === 0) {
      return Result.ok(new Uint8Array(0));
    }
    if (normalized.length % 4 !== 0) {
      return Result.fail(new ResultError('CORE-ENC-005', 'Invalid base64 length'));
    }
    const alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
    const bytes: number[] = [];
    for (let i = 0; i < normalized.length; i += 4) {
      const c0 = alphabet.indexOf(normalized.charAt(i));
      const c1 = alphabet.indexOf(normalized.charAt(i + 1));
      const c2Char = normalized.charAt(i + 2);
      const c3Char = normalized.charAt(i + 3);
      const c2 = c2Char === '=' ? -1 : alphabet.indexOf(c2Char);
      const c3 = c3Char === '=' ? -1 : alphabet.indexOf(c3Char);
      if (c0 < 0 || c1 < 0 || (c2Char !== '=' && c2 < 0) || (c3Char !== '=' && c3 < 0)) {
        return Result.fail(new ResultError('CORE-ENC-006', 'Invalid base64 character'));
      }
      const triple = (c0 << 18) | (c1 << 12) | ((c2 < 0 ? 0 : c2) << 6) | (c3 < 0 ? 0 : c3);
      bytes.push((triple >> 16) & 0xFF);
      if (c2 >= 0) {
        bytes.push((triple >> 8) & 0xFF);
      }
      if (c3 >= 0) {
        bytes.push(triple & 0xFF);
      }
    }
    return Result.ok(new Uint8Array(bytes));
  }
}
