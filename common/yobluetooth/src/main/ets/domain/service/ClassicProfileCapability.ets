/**
 * Classic BR/EDR Profile UUID → 短标签（architecture bluetooth/01 §2.1 / §6.1）。
 *
 * 数据来源：connection.getRemoteProfileUuids（建议仅对已配对设备）。
 * 非完整 SDP：自定义 SPP UUID / RFCOMM Channel 不在此能力内。
 */
export class ClassicProfileCapability {
  static readonly LABEL_SPP: string = 'SPP';
  static readonly LABEL_A2DP: string = 'A2DP';
  static readonly LABEL_HFP: string = 'HFP';
  static readonly LABEL_HSP: string = 'HSP';
  static readonly LABEL_AVRCP: string = 'AVRCP';
  static readonly LABEL_HID: string = 'HID';
  static readonly LABEL_HOGP: string = 'HOGP';

  /**
   * 是否含可推断为经典侧能力的 UUID（UNKNOWN 配对准入旁证）。
   */
  static hasClassicHint(uuids: string[]): boolean {
    return ClassicProfileCapability.labelsFromUuids(uuids).length > 0;
  }

  /**
   * 去重后的展示标签，顺序：SPP → A2DP → HFP → HSP → AVRCP → HID → HOGP。
   */
  static labelsFromUuids(uuids: string[]): string[] {
    let hasSpp = false;
    let hasA2dp = false;
    let hasHfp = false;
    let hasHsp = false;
    let hasAvrcp = false;
    let hasHid = false;
    let hasHogp = false;
    for (let i = 0; i < uuids.length; i++) {
      const uuid = uuids[i].toLowerCase();
      if (uuid.indexOf('1101') >= 0) {
        hasSpp = true;
      } else if (uuid.indexOf('110a') >= 0 || uuid.indexOf('110b') >= 0) {
        hasA2dp = true;
      } else if (uuid.indexOf('111e') >= 0 || uuid.indexOf('111f') >= 0) {
        hasHfp = true;
      } else if (uuid.indexOf('1108') >= 0 || uuid.indexOf('1112') >= 0) {
        hasHsp = true;
      } else if (uuid.indexOf('110c') >= 0 || uuid.indexOf('110e') >= 0) {
        hasAvrcp = true;
      } else if (uuid.indexOf('1124') >= 0) {
        hasHid = true;
      } else if (uuid.indexOf('1812') >= 0) {
        hasHogp = true;
      }
    }
    const labels: string[] = [];
    if (hasSpp) {
      labels.push(ClassicProfileCapability.LABEL_SPP);
    }
    if (hasA2dp) {
      labels.push(ClassicProfileCapability.LABEL_A2DP);
    }
    if (hasHfp) {
      labels.push(ClassicProfileCapability.LABEL_HFP);
    }
    if (hasHsp) {
      labels.push(ClassicProfileCapability.LABEL_HSP);
    }
    if (hasAvrcp) {
      labels.push(ClassicProfileCapability.LABEL_AVRCP);
    }
    if (hasHid) {
      labels.push(ClassicProfileCapability.LABEL_HID);
    }
    if (hasHogp) {
      labels.push(ClassicProfileCapability.LABEL_HOGP);
    }
    return labels;
  }

  /** UI 一行文案，如 `SPP · A2DP · HFP`；无能力时返回空串。 */
  static formatDisplayText(uuids: string[]): string {
    const labels = ClassicProfileCapability.labelsFromUuids(uuids);
    if (labels.length === 0) {
      return '';
    }
    return labels.join(' · ');
  }
}
