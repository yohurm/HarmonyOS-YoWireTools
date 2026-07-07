/**
 * Validates scan targets are private network ranges per architecture wifi_network/02-§9.
 */
export class PrivateNetworkGuard {
  static isPrivateIpv4(ip: string): boolean {
    const parts = ip.split('.');
    if (parts.length !== 4) {
      return false;
    }
    const a = Number(parts[0]);
    const b = Number(parts[1]);
    if (a === 10) {
      return true;
    }
    if (a === 172 && b >= 16 && b <= 31) {
      return true;
    }
    if (a === 192 && b === 168) {
      return true;
    }
    if (a === 127) {
      return true;
    }
    return false;
  }

  static isPrivateCidr(cidr: string): boolean {
    const slash = cidr.indexOf('/');
    const ip = slash >= 0 ? cidr.substring(0, slash) : cidr;
    return PrivateNetworkGuard.isPrivateIpv4(ip);
  }

  static portRangeSize(startPort: number, endPort: number): number {
    if (endPort < startPort) {
      return 0;
    }
    return endPort - startPort + 1;
  }

  static isLargeRange(startPort: number, endPort: number, threshold: number = 256): boolean {
    return PrivateNetworkGuard.portRangeSize(startPort, endPort) > threshold;
  }
}
