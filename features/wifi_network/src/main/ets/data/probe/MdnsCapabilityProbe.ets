import { mdns } from '@kit.NetworkKit';

/**
 * mDNS experimental capability probe per architecture 03-§11 and WSL ohos.net.mdns.
 */
export class MdnsCapabilityProbe {
  static probeSupported(): boolean {
    try {
      return typeof mdns.createDiscoveryService === 'function';
    } catch (_error) {
      return false;
    }
  }

  static capabilityMessage(): string {
    return MdnsCapabilityProbe.probeSupported()
      ? 'mDNS discovery API available (experimental entry)'
      : 'mDNS discovery API unavailable on this device';
  }
}
