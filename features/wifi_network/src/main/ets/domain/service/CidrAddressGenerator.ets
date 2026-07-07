/**
 * Generates candidate IPv4 addresses from CIDR notation.
 */
export class CidrAddressGenerator {
  static listHosts(cidr: string, maxHosts: number = 254): string[] {
    const slash = cidr.indexOf('/');
    if (slash < 0) {
      return [cidr];
    }
    const baseIp = cidr.substring(0, slash);
    const prefix = Number(cidr.substring(slash + 1));
    if (prefix < 24 || prefix > 30) {
      return [baseIp];
    }
    const parts = baseIp.split('.');
    if (parts.length !== 4) {
      return [];
    }
    const base = `${parts[0]}.${parts[1]}.${parts[2]}`;
    const hosts: string[] = [];
    for (let i = 1; i <= maxHosts && i < 255; i++) {
      hosts.push(`${base}.${i}`);
    }
    return hosts;
  }
}
