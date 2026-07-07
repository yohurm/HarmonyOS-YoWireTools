import { ssap } from '@kit.NearLinkKit';
import constant from '@hms.nearlink.constant';
import { SsapClientState } from '../../domain/model/SsapServiceTree';
import { SsapPropertySnapshot } from '../../domain/model/SsapPropertySnapshot';

/**
 * Maps NearLinkKit SSAP types to domain models.
 */
export class SsapPlatformMapper {
  static toPropertySnapshot(property: ssap.Property): SsapPropertySnapshot | undefined {
    if (property.value === undefined) {
      return undefined;
    }
    return new SsapPropertySnapshot(
      property.serviceUuid,
      property.propertyUuid,
      new Uint8Array(property.value)
    );
  }

  static mapConnectionState(state: number): SsapClientState {
    if (state === constant.ConnectionState.STATE_CONNECTED) {
      return SsapClientState.CONNECTED;
    }
    if (state === constant.ConnectionState.STATE_CONNECTING) {
      return SsapClientState.CONNECTING;
    }
    if (state === constant.ConnectionState.STATE_DISCONNECTED) {
      return SsapClientState.CLOSED;
    }
    return SsapClientState.FAILED;
  }
}
