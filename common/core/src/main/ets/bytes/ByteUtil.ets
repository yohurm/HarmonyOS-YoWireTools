/**
 * Byte-level helpers for transport payloads and checksums.
 */
export class ByteUtil {
  static concat(chunks: Uint8Array[]): Uint8Array {
    let total = 0;
    for (let i = 0; i < chunks.length; i++) {
      total += chunks[i].length;
    }
    const merged = new Uint8Array(total);
    let offset = 0;
    for (let i = 0; i < chunks.length; i++) {
      merged.set(chunks[i], offset);
      offset += chunks[i].length;
    }
    return merged;
  }

  static slice(bytes: Uint8Array, start: number, end?: number): Uint8Array {
    return bytes.slice(start, end);
  }

  static equals(left: Uint8Array, right: Uint8Array): boolean {
    if (left.length !== right.length) {
      return false;
    }
    for (let i = 0; i < left.length; i++) {
      if (left[i] !== right[i]) {
        return false;
      }
    }
    return true;
  }

  static toNumberArray(bytes: Uint8Array): number[] {
    const values: number[] = [];
    for (let i = 0; i < bytes.length; i++) {
      values.push(bytes[i]);
    }
    return values;
  }

  static fromNumberArray(values: number[]): Uint8Array {
    return new Uint8Array(values);
  }
}
