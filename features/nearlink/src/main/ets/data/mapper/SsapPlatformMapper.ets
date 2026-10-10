import { ssap } from '@kit.NearLinkKit';
import constant from '@hms.nearlink.constant';
import { NearLinkAdvParser } from '../../domain/service/NearLinkAdvParser';
import {
  SsapClientState,
  SsapNotifyState,
  SsapPropertyNode,
  SsapServiceNode,
  SsapServiceTreeSnapshot
} from '../../domain/model/SsapServiceTree';
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

  static toServiceTree(
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
        const operation = props[j].operation ?? 0;
        let hasClientConfig = false;
        const descriptors = props[j].descriptors ?? [];
        for (let k = 0; k < descriptors.length; k++) {
          if (descriptors[k].descriptorType === ssap.PropertyDescriptorType.CLIENT_PROPERTY_CONFIG) {
            hasClientConfig = true;
          }
        }
        const valueBytes = props[j].value === undefined ? new Uint8Array(0) : new Uint8Array(props[j].value);
        properties.push(new SsapPropertyNode(
          service.serviceUuid,
          props[j].propertyUuid,
          SsapNotifyState.DISABLED,
          NearLinkAdvParser.toHex(valueBytes),
          operation,
          hasClientConfig
        ));
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
