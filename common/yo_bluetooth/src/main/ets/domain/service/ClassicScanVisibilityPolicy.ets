import { ModuleType, ProtocolType, SessionState } from 'debug_core';
import { BluetoothDevice } from '../model/BluetoothDevice';
import { DiscoverySource } from '../model/DiscoverySource';

/** 活跃 SPP 会话摘要（供可见性策略使用，避免对象字面量类型）。 */
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

/**
 * 经典扫描（CLASSIC_SCAN rail）列表可见性策略。
 *
 * 本策略属于经典 Inquiry 列表，不是 SPP 协议扫描。
 * 当前 SPP 页是唯一 UI 消费者，故用活跃 SPP 会话地址作「保活行」锚点。
 *
 * 扫描轨只展示：
 * 1. 本轮 Inquiry / discoveryResult 真实回调（含 RSSI 或 deviceFind）
 * 2. 正在连接 / 已连接的 SPP 会话目标（即使暂无广播）
 *
 * 不展示：仅存在于 getPairedDevices、周围无广播且未在连接中的静默配对设备。
 */
export class ClassicScanVisibilityPolicy {
  static hasLiveDiscoverySignal(device: BluetoothDevice): boolean {
    return device.discoverySource === DiscoverySource.DISCOVERY_RESULT ||
      device.discoverySource === DiscoverySource.DEVICE_FIND;
  }

  static isActiveSppSessionState(state: SessionState): boolean {
    return state === SessionState.CREATED ||
      state === SessionState.PREPARING ||
      state === SessionState.RUNNING ||
      state === SessionState.SUSPENDED ||
      state === SessionState.STOPPING;
  }

  static matchesDeviceAddress(device: BluetoothDevice, address: string): boolean {
    if (address.length === 0) {
      return false;
    }
    return device.primaryDeviceId === address ||
      device.classicDeviceId === address ||
      device.bleDeviceId === address;
  }

  static isAddressInActiveSession(address: string, activeClassicAddresses: Set<string>): boolean {
    return address.length > 0 && activeClassicAddresses.has(address);
  }

  static isVisibleInScanList(device: BluetoothDevice, activeClassicAddresses: Set<string>): boolean {
    if (ClassicScanVisibilityPolicy.hasLiveDiscoverySignal(device)) {
      return true;
    }
    if (ClassicScanVisibilityPolicy.isAddressInActiveSession(device.primaryDeviceId, activeClassicAddresses)) {
      return true;
    }
    if (ClassicScanVisibilityPolicy.isAddressInActiveSession(device.classicDeviceId, activeClassicAddresses)) {
      return true;
    }
    return false;
  }

  static filterVisible(
    devices: BluetoothDevice[],
    activeClassicAddresses: Set<string>
  ): BluetoothDevice[] {
    const visible: BluetoothDevice[] = [];
    for (let i = 0; i < devices.length; i++) {
      if (ClassicScanVisibilityPolicy.isVisibleInScanList(devices[i], activeClassicAddresses)) {
        visible.push(devices[i]);
      }
    }
    return visible;
  }

  static augmentMissingActiveSessions(
    visible: BluetoothDevice[],
    activeClassicAddresses: Set<string>,
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
    activeClassicAddresses.forEach((address: string) => {
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

  static collectActiveSppClassicAddresses(
    summaries: ActiveSppSessionRef[],
    resolveAddress: (sessionId: string) => string
  ): Set<string> {
    const addresses = new Set<string>();
    for (let i = 0; i < summaries.length; i++) {
      const summary = summaries[i];
      if (summary.module !== ModuleType.BLUETOOTH || summary.protocol !== ProtocolType.SPP) {
        continue;
      }
      if (!ClassicScanVisibilityPolicy.isActiveSppSessionState(summary.state)) {
        continue;
      }
      const address = resolveAddress(summary.id);
      if (address.length > 0) {
        addresses.add(address);
      }
    }
    return addresses;
  }
}
