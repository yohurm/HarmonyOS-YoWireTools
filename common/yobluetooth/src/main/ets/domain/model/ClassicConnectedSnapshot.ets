/**
 * Platform Profile-connected classic addresses snapshot.
 * ACL enumeration is unavailable on current SDK (documented capability gap).
 */
export class ClassicConnectedSnapshot {
  readonly addresses: string[];
  readonly profileConnectedCount: number;
  /** Always false until SDK exposes ACL list / onAclStateChange. */
  readonly aclQueryAvailable: boolean;

  constructor(
    addresses: string[],
    profileConnectedCount: number,
    aclQueryAvailable: boolean = false
  ) {
    this.addresses = addresses;
    this.profileConnectedCount = profileConnectedCount;
    this.aclQueryAvailable = aclQueryAvailable;
  }

  static empty(): ClassicConnectedSnapshot {
    return new ClassicConnectedSnapshot([], 0, false);
  }

  contains(classicDeviceId: string): boolean {
    for (let i = 0; i < this.addresses.length; i++) {
      if (this.addresses[i] === classicDeviceId) {
        return true;
      }
    }
    return false;
  }
}

/**
 * Scan keep-alive merge result (profile ∪ app SPP connected/connecting).
 */
export class ClassicKeepAliveSnapshot {
  readonly addresses: Set<string>;
  readonly profileCount: number;
  readonly sppConnectedCount: number;
  readonly sppConnectingCount: number;

  constructor(
    addresses: Set<string>,
    profileCount: number,
    sppConnectedCount: number,
    sppConnectingCount: number
  ) {
    this.addresses = addresses;
    this.profileCount = profileCount;
    this.sppConnectedCount = sppConnectedCount;
    this.sppConnectingCount = sppConnectingCount;
  }

  static empty(): ClassicKeepAliveSnapshot {
    return new ClassicKeepAliveSnapshot(new Set<string>(), 0, 0, 0);
  }
}
