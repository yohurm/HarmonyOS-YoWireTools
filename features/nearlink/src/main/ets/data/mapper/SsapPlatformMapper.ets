import { ssap } from '@kit.NearLinkKit';
import constant from '@hms.nearlink.constant';
import { SsapClientState, SsapPropertyNode, SsapServiceNode, SsapServiceTreeSnapshot } from '../../domain/model/SsapServiceTree';
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

  static buildTree(
    sessionId: string,
    address: string,
    services: ssap.Service[],
    mtu: number,
    state: SsapClientState
  ): SsapServiceTreeSnapshot {
    const nodes: SsapServiceNode[] = [];
    for (let i = 0; i < services.length; i++) {
      const service = services[i];
      const properties: SsapPropertyNode[] = [];
      const props = service.properties ?? [];
      for (let j = 0; j < props.length; j++) {
        properties.push(new SsapPropertyNode(service.serviceUuid, props[j].propertyUuid));
      }
      nodes.push(new SsapServiceNode(service.serviceUuid, properties));
    }
    return new SsapServiceTreeSnapshot(sessionId, address, mtu, nodes, state);
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
