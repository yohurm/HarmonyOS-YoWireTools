import { mdns } from '@kit.NetworkKit';

import { BusinessError } from '@kit.BasicServicesKit';

import { common } from '@kit.AbilityKit';

import { IdGenerator, Observable, Result, ResultError } from 'common_core';

import { WifiNetworkErrorCodes } from '../../constants/WifiNetworkErrorCodes';

import { DiscoveredNetworkService } from '../../domain/model/MqttModels';
import { NetworkKitEventBridge } from '../kit/NetworkKitEventBridge';



type ServiceFoundHandler = (service: mdns.LocalServiceInfo) => void;

type ServiceLostHandler = (service: mdns.LocalServiceInfo) => void;



/**

 * mDNS discovery wrapper per architecture 03-§11 and WSL mdns.createDiscoveryService.

 */

export class MdnsDataSource {

  private static instance: MdnsDataSource | undefined;

  private discoveryService: mdns.DiscoveryService | undefined;

  private context: common.UIAbilityContext | undefined;

  private serviceFoundHandler: ServiceFoundHandler | undefined;

  private serviceLostHandler: ServiceLostHandler | undefined;

  private readonly servicesObservable: Observable<DiscoveredNetworkService[]>;

  private services: DiscoveredNetworkService[] = [];

  private searching: boolean = false;



  private constructor() {

    this.servicesObservable = new Observable<DiscoveredNetworkService[]>([]);

  }



  static getInstance(): MdnsDataSource {

    if (MdnsDataSource.instance === undefined) {

      MdnsDataSource.instance = new MdnsDataSource();

    }

    return MdnsDataSource.instance;

  }



  observeServices(): Observable<DiscoveredNetworkService[]> {

    return this.servicesObservable;

  }



  isSearching(): boolean {

    return this.searching;

  }



  async startDiscovery(context: common.UIAbilityContext, serviceType: string): Promise<Result<void>> {

    await this.stopDiscovery();

    this.context = context;

    try {

      this.discoveryService = mdns.createDiscoveryService(context, serviceType);

      this.registerHandlers(context);

      this.discoveryService.startSearchingMDNS();

      this.searching = true;

      return Result.ok(undefined);

    } catch (error) {

      const err = error as BusinessError;

      return Result.fail(ResultError.fromError(WifiNetworkErrorCodes.SCAN_LIMITED, err));

    }

  }



  async stopDiscovery(): Promise<void> {

    this.unregisterHandlers();

    if (this.discoveryService !== undefined) {

      try {

        this.discoveryService.stopSearchingMDNS();

      } catch (_error) {

      }

      this.discoveryService = undefined;

    }

    this.searching = false;

  }



  getServices(): DiscoveredNetworkService[] {

    return this.services.slice();

  }



  private registerHandlers(context: common.UIAbilityContext): void {

    if (this.discoveryService === undefined) {

      return;

    }

    this.serviceFoundHandler = (data: mdns.LocalServiceInfo) => {

      mdns.resolveLocalService(context, data, (error: BusinessError, resolveData: mdns.LocalServiceInfo) => {

        if (error !== undefined && error.code !== undefined) {

          return;

        }

        this.upsertService(resolveData, 'mdns');

      });

    };

    this.serviceLostHandler = (data: mdns.LocalServiceInfo) => {

      this.removeService(data.serviceName);

    };

    const foundRegistered = NetworkKitEventBridge.subscribeMdnsServiceFound(
      this.discoveryService, this.serviceFoundHandler
    );
    if (!foundRegistered.success) {
      this.serviceFoundHandler = undefined;
      return;
    }
    NetworkKitEventBridge.subscribeMdnsServiceLost(this.discoveryService, this.serviceLostHandler);
  }

  private unregisterHandlers(): void {
    if (this.discoveryService === undefined) {
      return;
    }
    if (this.serviceFoundHandler !== undefined) {
      NetworkKitEventBridge.unsubscribeMdnsServiceFound(this.discoveryService, this.serviceFoundHandler);
    }
    if (this.serviceLostHandler !== undefined) {
      NetworkKitEventBridge.unsubscribeMdnsServiceLost(this.discoveryService, this.serviceLostHandler);
    }

    this.serviceFoundHandler = undefined;

    this.serviceLostHandler = undefined;

  }



  private upsertService(info: mdns.LocalServiceInfo, type: string): void {

    const host = info.host?.address ?? '';

    const port = info.port ?? 0;

    const name = info.serviceName ?? '';

    const id = `${type}:${name}:${host}:${port}`;

    const now = Date.now();

    const next: DiscoveredNetworkService[] = [];

    let found = false;

    for (let i = 0; i < this.services.length; i++) {

      const item = this.services[i];

      if (item.id === id) {

        next.push(new DiscoveredNetworkService(

          item.id, type, name, host, port, 'tcp', JSON.stringify(info.serviceAttribute ?? []),

          item.firstSeenAtMs, now

        ));

        found = true;

      } else {

        next.push(item);

      }

    }

    if (!found) {

      next.push(new DiscoveredNetworkService(

        id, type, name, host, port, 'tcp', JSON.stringify(info.serviceAttribute ?? []), now, now

      ));

    }

    this.services = next;

    this.servicesObservable.next(this.services.slice());

  }



  private removeService(name: string): void {

    const next: DiscoveredNetworkService[] = [];

    for (let i = 0; i < this.services.length; i++) {

      if (this.services[i].name !== name) {

        next.push(this.services[i]);

      }

    }

    this.services = next;

    this.servicesObservable.next(this.services.slice());

  }

}

