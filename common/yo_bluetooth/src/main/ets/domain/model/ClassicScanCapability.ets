import { BluetoothListRail } from './BluetoothTransportType';

/**
 * 经典蓝牙扫描能力边界（architecture bluetooth/01）。
 *
 * 词汇约定：
 * - Classic Scan / BR Inquiry = 传输层发现（ProtocolType.CLASSIC_SCAN）
 * - CLASSIC_SCAN rail = 经典设备列表轨（今日消费者：SPP 页扫描段）
 * - SPP = 串口连接协议（ProtocolType.SPP），消费本轨结果，不是扫描本身
 *
 * 负责：
 * 1. Inquiry 启停与 ~12s 倒计时
 * 2. 已配对经典候选缓存（BR_EDR | DUAL；UNKNOWN 可降级）
 * 3. 发现合并 / ClassicScanFilter / 列表可见性
 * 4. 传输类型与 CoD 展示字段
 * 5. Profile UUID 查询（辅助展示，不阻断 SPP）
 *
 * 不负责：
 * 1. SPP socket 连接 / 读写 / 断开
 * 2. BLE GATT 扫描与连接
 * 3. A2DP/HFP/HID 产品级管理（可用 connectAllowedProfiles，但不做入口）
 * 4. 完整 SDP browse / RFCOMM Channel 枚举（平台无公开 API）
 */
export class ClassicScanCapability {
  static readonly LIST_RAIL: BluetoothListRail = BluetoothListRail.CLASSIC_SCAN;
  /** Inquiry 典型时长（秒），与平台 startBluetoothDiscovery 对齐。 */
  static readonly INQUIRY_DURATION_SEC: number = 12;
}
