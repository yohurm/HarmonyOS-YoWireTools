const SENSITIVE_HEADERS: string[] = [
  'authorization',
  'cookie',
  'set-cookie',
  'proxy-authorization'
];

export class HttpHeaderSanitizer {
  static sanitize(headers: Record<string, string>): Record<string, string> {
    const result: Record<string, string> = {};
    const keys = Object.keys(headers);
    for (let i = 0; i < keys.length; i++) {
      const key = keys[i];
      const lower = key.toLowerCase();
      let masked = false;
      for (let j = 0; j < SENSITIVE_HEADERS.length; j++) {
        if (lower === SENSITIVE_HEADERS[j]) {
          masked = true;
          break;
        }
      }
      result[key] = masked ? '***' : headers[key];
    }
    return result;
  }
}
