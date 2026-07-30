import { BluetoothDevice } from '../model/BluetoothDevice';
import { DiscoverySource } from '../model/DiscoverySource';
import { SessionState } from 'debug_core';
import { SppLedgerPhase } from '../model/spp/SppLedgerPhase';

/** 活跃 SPP 会话摘要（供 KeepAliveCollector 使用）。 */
export class ActiveSppSessionRef {
  readonly module: string;
  readonly protocol: string;
  readonly state: SessionState;
  readonly id: string;

  constructor(module: string, protocol: string, state: SessionState, id: string) {
    this.module = module;
    this.protocol = protocol;
    this.state = state;
    this.id = id;
  }
}

/** Ledger 行摘要。 */
export class ConnectedSppLedgerRef {
  readonly classicDeviceId: string;
  readonly phase: SppLedgerPhase;

  constructor(classicDeviceId: string, phase: SppLedgerPhase) {
    this.classicDeviceId = classicDeviceId;
    this.phase = phase;
  }
}

/**
 * 经典扫描列表可见性策略（纯函数，不依赖 Kit / yolog）。
 *
 * 平台 Inquiry 无法配置 includeBonded/includeConnected。
 * 扫描轨展示：
 * 1. 本轮 Inquiry / discoveryResult / deviceFind
 * 2. keepAlive 地址（由 ClassicScanKeepAliveCollector 提供）
 * 静默仅配对默认不展示。
 */
export class ClassicScanVisibilityPolicy {
  static hasLiveDiscoverySignal(device: BluetoothDevice): boolean {
    return device.discoverySource === DiscoverySource.DISCOVERY_RESULT ||
      device.discoverySource === DiscoverySource.DEVICE_FIND;
  }

  /** @deprecated Prefer ClassicScanKeepAliveCollector.isConnectedSessionState. */
  static isConnectedKeepAliveSessionState(state: SessionState): boolean {
    return state === SessionState.RUNNING ||
      state === SessionState.SUSPENDED ||
      state === SessionState.STOPPING;
  }

  /** @deprecated Prefer ClassicScanKeepAliveCollector session helpers. */
  static isActiveSppSessionState(state: SessionState): boolean {
    return state === SessionState.CREATED ||
      state === SessionState.PREPARING ||
      ClassicScanVisibilityPolicy.isConnectedKeepAliveSessionState(state);
  }

  /** @deprecated Prefer ClassicScanKeepAliveCollector.isConnectedLedgerPhase. */
  static isConnectedLedgerPhase(phase: SppLedgerPhase): boolean {
    return phase === SppLedgerPhase.CONNECTED;
  }

  static matchesDeviceAddress(device: BluetoothDevice, address: string): boolean {
    if (address.length === 0) {
      return false;
    }
    return device.primaryDeviceId === address ||
      device.classicDeviceId === address ||
      device.bleDeviceId === address;
  }

  static isAddressInKeepAlive(address: string, keepAliveAddresses: Set<string>): boolean {
    return address.length > 0 && keepAliveAddresses.has(address);
  }

  /** @deprecated Prefer isAddressInKeepAlive. */
  static isAddressInActiveSession(address: string, keepAliveAddresses: Set<string>): boolean {
    return ClassicScanVisibilityPolicy.isAddressInKeepAlive(address, keepAliveAddresses);
  }

  static isVisibleInScanList(device: BluetoothDevice, keepAliveAddresses: Set<string>): boolean {
    if (ClassicScanVisibilityPolicy.hasLiveDiscoverySignal(device)) {
      return true;
    }
    if (ClassicScanVisibilityPolicy.isAddressInKeepAlive(device.primaryDeviceId, keepAliveAddresses)) {
      return true;
    }
    if (ClassicScanVisibilityPolicy.isAddressInKeepAlive(device.classicDeviceId, keepAliveAddresses)) {
      return true;
    }
    return false;
  }

  static filterVisible(
    devices: BluetoothDevice[],
    keepAliveAddresses: Set<string>
  ): BluetoothDevice[] {
    const visible: BluetoothDevice[] = [];
    for (let i = 0; i < devices.length; i++) {
      if (ClassicScanVisibilityPolicy.isVisibleInScanList(devices[i], keepAliveAddresses)) {
        visible.push(devices[i]);
      }
    }
    return visible;
  }

  static augmentMissingActiveSessions(
    visible: BluetoothDevice[],
    keepAliveAddresses: Set<string>,
    pairedCache: Map<string, BluetoothDevice>,
    fallbackByAddress: Map<string, BluetoothDevice>
  ): BluetoothDevice[] {
    const present = new Set<string>();
    for (let i = 0; i < visible.length; i++) {
      const device = visible[i];
      present.add(device.primaryDeviceId);
      if (device.classicDeviceId.length > 0) {
        present.add(device.classicDeviceId);
      }
    }

    const augmented = visible.slice();
    keepAliveAddresses.forEach((address: string) => {
      if (present.has(address)) {
        return;
      }
      const cached = pairedCache.get(address) ?? fallbackByAddress.get(address);
      if (cached !== undefined) {
        augmented.push(cached);
        present.add(address);
      }
    });
    return augmented;
  }

  /**
   * 扫描列表排序：已连接保活置顶 → 收藏 → 已配对 → RSSI → 名称 → lastSeen。
   */
  static sortScanList(
    devices: BluetoothDevice[],
    keepAliveAddresses: Set<string>
  ): BluetoothDevice[] {
    const items = devices.slice();
    items.sort((a: BluetoothDevice, b: BluetoothDevice) => {
      const aKeep = ClassicScanVisibilityPolicy.isDeviceInKeepAlive(a, keepAliveAddresses);
      const bKeep = ClassicScanVisibilityPolicy.isDeviceInKeepAlive(b, keepAliveAddresses);
      if (aKeep !== bKeep) {
        return aKeep ? -1 : 1;
      }
      if (a.favorite !== b.favorite) {
        return a.favorite ? -1 : 1;
      }
      if (a.paired !== b.paired) {
        return a.paired ? -1 : 1;
      }
      if (a.rssi !== b.rssi) {
        return b.rssi - a.rssi;
      }
      if (a.effectiveName !== b.effectiveName) {
        return a.effectiveName.localeCompare(b.effectiveName);
      }
      return b.lastSeenMs - a.lastSeenMs;
    });
    return items;
  }

  static isDeviceInKeepAlive(device: BluetoothDevice, keepAliveAddresses: Set<string>): boolean {
    return ClassicScanVisibilityPolicy.isAddressInKeepAlive(device.primaryDeviceId, keepAliveAddresses) ||
      ClassicScanVisibilityPolicy.isAddressInKeepAlive(device.classicDeviceId, keepAliveAddresses);
  }
}
