/**
 * Splits UTF-16 strings by approximate UTF-8 byte budget for HiLog 4096 limit.
 */
export class ByteSplitter {
  static splitByByteLimit(str: string, limit: number): string[] {
    const result: string[] = [];
    let start = 0;
    while (start < str.length) {
      let end = start;
      let byteLen = 0;
      while (end < str.length) {
        const code = str.charCodeAt(end);
        let charBytes: number;
        if (code < 0x80) {
          charBytes = 1;
        } else if (code < 0x800) {
          charBytes = 2;
        } else if (code < 0xD800 || code > 0xDFFF) {
          charBytes = 3;
        } else {
          charBytes = 4;
          end++;
        }
        if (byteLen + charBytes > limit) {
          break;
        }
        byteLen += charBytes;
        end++;
      }
      if (end <= start) {
        end = start + 1;
      }
      result.push(str.substring(start, end));
      start = end;
    }
    return result;
  }
}
