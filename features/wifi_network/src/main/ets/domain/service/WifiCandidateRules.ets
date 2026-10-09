import { WifiNetworkConstants } from '../../constants/WifiNetworkConstants';
import { WifiCandidateDraft } from '../model/WifiDebugFacts';

export class WifiCandidateRejection {
  readonly message: string;
  readonly nativeCode: string;

  constructor(message: string, nativeCode: string = '') {
    this.message = message;
    this.nativeCode = nativeCode;
  }
}

export class WifiCandidateRules {
  static validate(draft: WifiCandidateDraft): WifiCandidateRejection | undefined {
    if (draft.security === 'WEP') {
      return new WifiCandidateRejection('候选配置不支持 WEP');
    }
    if (draft.security === 'OPEN' && draft.key.length > 0) {
      return new WifiCandidateRejection('开放网络密钥必须为空');
    }
    if (draft.security === 'PSK') {
      const bytes = WifiCandidateRules.utf8Bytes(draft.key);
      if (bytes < WifiNetworkConstants.PSK_MIN_BYTES) {
        return new WifiCandidateRejection('PSK 密钥最短 8 字节');
      }
    }
    if (draft.security === 'SAE' && WifiCandidateRules.utf8Bytes(draft.key) < WifiNetworkConstants.SAE_MIN_BYTES) {
      return new WifiCandidateRejection('SAE 密钥至少 1 字节');
    }
    if (draft.security === 'EAP') {
      if (draft.eapIdentity.length === 0 || draft.eapPassword.length === 0) {
        return new WifiCandidateRejection('身份或密码为空');
      }
    }
    if (draft.useUserAction && draft.networkId < 0) {
      return new WifiCandidateRejection('参数无效', WifiNetworkConstants.NATIVE_PARAM_INVALID);
    }
    return undefined;
  }

  static maskSecret(value: string): string {
    if (value.length === 0) {
      return '';
    }
    return '********';
  }

  private static utf8Bytes(value: string): number {
    let bytes = 0;
    for (let i = 0; i < value.length; i++) {
      const code = value.charCodeAt(i);
      if (code <= 0x7f) {
        bytes += 1;
      } else if (code <= 0x7ff) {
        bytes += 2;
      } else {
        bytes += 3;
      }
    }
    return bytes;
  }
}
