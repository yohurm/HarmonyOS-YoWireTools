import { EncodingUtil, Result, ResultError } from 'common_core';
import { LineEndingMode, PayloadEncoding } from '../domain/enums/DomainEnums';

/**
 * Debug payload text encoding and line-ending helpers (command / log display).
 */
export class PayloadTextCodec {
  static encodeText(text: string, encoding: PayloadEncoding): Result<string> {
    switch (encoding) {
      case PayloadEncoding.TEXT:
        return Result.ok(text);
      case PayloadEncoding.HEX:
        return EncodingUtil.textToHex(text);
      case PayloadEncoding.BASE64:
        return EncodingUtil.textToBase64(text);
      default:
        return Result.fail(new ResultError('YW-CMD-1100', `Unsupported payload encoding: ${encoding}`));
    }
  }

  static decodeText(encoded: string, encoding: PayloadEncoding): Result<string> {
    switch (encoding) {
      case PayloadEncoding.TEXT:
        return Result.ok(encoded);
      case PayloadEncoding.HEX:
        return EncodingUtil.hexToText(encoded);
      case PayloadEncoding.BASE64:
        return EncodingUtil.base64ToText(encoded);
      default:
        return Result.fail(new ResultError('YW-CMD-1101', `Unsupported payload encoding: ${encoding}`));
    }
  }

  static toLineSequence(mode: LineEndingMode): string {
    switch (mode) {
      case LineEndingMode.CRLF:
        return '\r\n';
      case LineEndingMode.CR:
        return '\r';
      case LineEndingMode.LF:
      default:
        return '\n';
    }
  }

  static normalizeLineEndings(text: string, target: LineEndingMode = LineEndingMode.LF): string {
    const normalized = text.replace(/\r\n/g, '\n').replace(/\r/g, '\n');
    if (target === LineEndingMode.LF) {
      return normalized;
    }
    return normalized.replace(/\n/g, PayloadTextCodec.toLineSequence(target));
  }

  static appendLineEnding(text: string, mode: LineEndingMode = LineEndingMode.LF): string {
    if (mode === LineEndingMode.NONE) {
      return text;
    }
    return `${text}${PayloadTextCodec.toLineSequence(mode)}`;
  }
}
