export class SsdpParsedEndpoint {
  readonly host: string;
  readonly port: number;

  constructor(host: string, port: number) {
    this.host = host;
    this.port = port;
  }
}

export class SsdpUrlParser {
  static parseUrl(url: string): SsdpParsedEndpoint | undefined {
    const httpIndex = url.indexOf('://');
    if (httpIndex < 0) {
      return undefined;
    }
    const rest = url.substring(httpIndex + 3);
    const slash = rest.indexOf('/');
    const hostPort = slash >= 0 ? rest.substring(0, slash) : rest;
    const colon = hostPort.indexOf(':');
    if (colon >= 0) {
      const port = parseInt(hostPort.substring(colon + 1), 10);
      if (isNaN(port)) {
        return undefined;
      }
      return new SsdpParsedEndpoint(hostPort.substring(0, colon), port);
    }
    return new SsdpParsedEndpoint(hostPort, 80);
  }

  static headerValue(text: string, key: string): string {
    const upper = text.toUpperCase();
    const marker = `${key}:`;
    const index = upper.indexOf(marker);
    if (index < 0) {
      return '';
    }
    const lineEnd = text.indexOf('\r\n', index);
    const raw = lineEnd >= 0 ? text.substring(index + marker.length, lineEnd) : text.substring(index + marker.length);
    return raw.trim();
  }
}
