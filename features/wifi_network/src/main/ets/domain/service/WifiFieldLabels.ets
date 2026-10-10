import { WifiNetworkConstants } from '../../constants/WifiNetworkConstants';

export class WifiFieldLabels {
  static security(type: number): string {
    switch (type) {
      case 1:
        return 'OPEN';
      case 2:
        return 'WEP';
      case 3:
        return 'PSK';
      case 4:
        return 'SAE';
      case 5:
        return 'EAP';
      case 6:
        return 'EAP_SUITE_B';
      case 7:
        return 'OWE';
      case 8:
        return 'WAPI_CERT';
      case 9:
        return 'WAPI_PSK';
      default:
        return 'INVALID';
    }
  }

  static securityCode(label: string): number {
    if (label === 'OPEN') {
      return 1;
    }
    if (label === 'WEP') {
      return 2;
    }
    if (label === 'PSK') {
      return 3;
    }
    if (label === 'SAE') {
      return 4;
    }
    if (label === 'EAP') {
      return 5;
    }
    return 0;
  }

  static channelWidth(width: number): string {
    switch (width) {
      case 0:
        return '20 MHz';
      case 1:
        return '40 MHz';
      case 2:
        return '80 MHz';
      case 3:
        return '160 MHz';
      case 4:
        return '80 MHz+';
      default:
        return '无效带宽';
    }
  }

  static wifiStandard(standard: number): string {
    switch (standard) {
      case 1:
        return '802.11a';
      case 2:
        return '802.11b';
      case 3:
        return '802.11g';
      case 4:
        return '802.11n';
      case 5:
        return '802.11ac';
      case 6:
        return '802.11ax';
      case 7:
        return '802.11ad';
      default:
        return '未定义';
    }
  }

  static connState(state: number): string {
    switch (state) {
      case 0:
        return 'SCANNING';
      case 1:
        return 'CONNECTING';
      case 2:
        return 'AUTHENTICATING';
      case 3:
        return 'OBTAINING_IPADDR';
      case 4:
        return 'CONNECTED';
      case 5:
        return 'DISCONNECTING';
      case 6:
        return 'DISCONNECTED';
      default:
        return 'UNKNOWN';
    }
  }

  static wifiPowerState(state: number): string {
    switch (state) {
      case 0:
        return 'DISABLED';
      case 1:
        return 'ENABLED';
      case 2:
        return 'ENABLING';
      case 3:
        return 'DISABLING';
      default:
        return 'UNKNOWN';
    }
  }

  static linkType(linkType: number): string {
    switch (linkType) {
      case 0:
        return '默认';
      case 1:
        return 'Wi-Fi 7 单链路';
      case 2:
        return 'MLSR';
      case 3:
        return 'EMLSR';
      case 4:
        return 'STR';
      default:
        return '未知链路';
    }
  }

  static addressKind(bssidType: number, peersMacGranted: boolean): string {
    if (!peersMacGranted || bssidType === 0) {
      return '随机地址';
    }
    return '真实地址';
  }

  static ipv4Text(value: number): string {
    if (value === 0) {
      return WifiNetworkConstants.NOT_OBTAINED;
    }
    const a = value & 0xff;
    const b = (value >> 8) & 0xff;
    const c = (value >> 16) & 0xff;
    const d = (value >> 24) & 0xff;
    return `${a}.${b}.${c}.${d}`;
  }

  static errorSentence(nativeCode: string, message: string): string {
    if (message.indexOf('moving freeze') >= 0) {
      return '静止管控';
    }
    if (nativeCode === '2501000') {
      return '操作失败';
    }
    if (nativeCode === '2501001') {
      return 'STA 未打开';
    }
    if (nativeCode === '2501005') {
      return '用户未响应';
    }
    if (nativeCode === '2501006') {
      return '用户拒绝';
    }
    if (nativeCode === '2501007') {
      return '参数无效';
    }
    if (nativeCode === '801') {
      return '本机不支持';
    }
    if (nativeCode === '201') {
      return '权限被拒绝';
    }
    return message;
  }
}
