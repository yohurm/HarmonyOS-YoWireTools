import { Observable, TimeUtil } from 'common_core';
import { Direction } from 'feature_debug_core';
import { NearLinkAdvParser } from '../../domain/service/NearLinkAdvParser';
import { NearLinkEventLogger } from '../../domain/service/NearLinkEventLogger';
import { SsapPropertyNode, SsapServiceNode, SsapServiceTreeSnapshot } from '../../domain/model/SsapServiceTree';
import { SsapPropertyNotifyPayload } from '../../domain/model/SsapPropertyNotifyPayload';
import { SsapPropertySnapshot } from '../../domain/model/SsapPropertySnapshot';

/**
 * Dispatches SSAP propertyChange events per architecture nearlink/02-§4.3.
 */
export class SsapPropertyChangeDispatcher {
  private readonly notifyObservable: Observable<SsapPropertyNotifyPayload>;

  constructor() {
    this.notifyObservable = new Observable<SsapPropertyNotifyPayload>(
      new SsapPropertyNotifyPayload('', '', '', TimeUtil.nowMs())
    );
  }

  observeNotify(): Observable<SsapPropertyNotifyPayload> {
    return this.notifyObservable;
  }

  handlePropertyChange(sessionId: string, property: SsapPropertySnapshot, tree: SsapServiceTreeSnapshot): void {
    const valueHex = NearLinkAdvParser.toHex(property.valueBytes);
    void NearLinkEventLogger.logSsapPayload(
      sessionId,
      Direction.INBOUND,
      property.serviceUuid,
      property.propertyUuid,
      property.valueBytes
    );
    this.notifyObservable.next(new SsapPropertyNotifyPayload(
      property.serviceUuid,
      property.propertyUuid,
      valueHex,
      TimeUtil.nowMs()
    ));
    SsapPropertyChangeDispatcher.applyPropertyValue(
      tree,
      property.serviceUuid,
      property.propertyUuid,
      valueHex
    );
  }

  private static applyPropertyValue(
    tree: SsapServiceTreeSnapshot,
    serviceUuid: string,
    propertyUuid: string,
    valueHex: string
  ): void {
    for (let i = 0; i < tree.services.length; i++) {
      const service: SsapServiceNode = tree.services[i];
      if (service.serviceUuid !== serviceUuid) {
        continue;
      }
      for (let j = 0; j < service.properties.length; j++) {
        const node: SsapPropertyNode = service.properties[j];
        if (node.propertyUuid === propertyUuid) {
          node.lastValueHex = valueHex;
        }
      }
    }
  }
}
