import { Subscription } from 'common_core';

import { CommandTemplateRecord } from 'common_storage';

import { LanDiscoveryConfig, LanHostResult, PortProbeResult, PortProbeState, PortScanConfig } from '../domain/model/LanDiscoveryModels';

import { DiscoveredNetworkService } from '../domain/model/MqttModels';

import { StartLanDiscoveryUseCase, StartPortScanUseCase } from '../domain/usecase/WifiNetworkUseCases';

import { SaveNetworkTargetUseCase } from '../domain/usecase/WifiNetworkExtendedUseCases';

import {

  ListDiscoveredServicesUseCase,

  StartMdnsDiscoveryUseCase,

  StartSsdpDiscoveryUseCase,

  StopMdnsDiscoveryUseCase,

  StopSsdpDiscoveryUseCase

} from '../domain/usecase/WifiNetworkSessionUseCases';

import { WifiNetworkRepository } from '../data/repository/WifiNetworkRepository';

import { WifiNetworkConstants } from '../constants/WifiNetworkConstants';

import { PrivateNetworkGuard } from '../domain/service/PrivateNetworkGuard';

import { MdnsDataSource } from '../data/datasource/MdnsDataSource';

import { SsdpDiscoveryDataSource } from '../data/datasource/SsdpDiscoveryDataSource';



@ObservedV2

export class LanDiscoveryViewModel {

  @Trace cidr: string = '192.168.1.0/24';

  @Trace scanHost: string = '192.168.1.1';

  @Trace startPort: number = 1;

  @Trace endPort: number = 1024;

  @Trace portScanConcurrency: number = WifiNetworkConstants.DEFAULT_PORT_SCAN_CONCURRENCY;

  @Trace mdnsServiceType: string = WifiNetworkConstants.DEFAULT_MDNS_SERVICE_TYPE;

  @Trace hosts: LanHostResult[] = [];

  @Trace portResults: PortProbeResult[] = [];

  @Trace discoveredServices: DiscoveredNetworkService[] = [];

  @Trace scanning: boolean = false;

  @Trace mdnsSearching: boolean = false;

  @Trace ssdpSearching: boolean = false;

  @Trace showLargeRangeConfirm: boolean = false;

  @Trace statusMessage: string = '';



  private readonly startLan: StartLanDiscoveryUseCase = new StartLanDiscoveryUseCase();

  private readonly startPortScan: StartPortScanUseCase = new StartPortScanUseCase();

  private readonly saveTarget: SaveNetworkTargetUseCase = new SaveNetworkTargetUseCase();

  private readonly startMdns: StartMdnsDiscoveryUseCase = new StartMdnsDiscoveryUseCase();

  private readonly stopMdns: StopMdnsDiscoveryUseCase = new StopMdnsDiscoveryUseCase();

  private readonly startSsdp: StartSsdpDiscoveryUseCase = new StartSsdpDiscoveryUseCase();

  private readonly stopSsdp: StopSsdpDiscoveryUseCase = new StopSsdpDiscoveryUseCase();

  private readonly listDiscovered: ListDiscoveredServicesUseCase = new ListDiscoveredServicesUseCase();

  private readonly repository: WifiNetworkRepository = WifiNetworkRepository.getInstance();

  private mdnsSubscription: Subscription | undefined;

  private ssdpSubscription: Subscription | undefined;

  dispose(): void {

    if (this.mdnsSubscription !== undefined) {

      this.mdnsSubscription.dispose();

    }

    if (this.ssdpSubscription !== undefined) {

      this.ssdpSubscription.dispose();

    }

    void this.stopMdns.execute();

    void this.stopSsdp.execute();

  }



  async startDiscovery(): Promise<void> {

    this.scanning = true;

    this.hosts = [];

    this.statusMessage = 'Discovering hosts...';

    const config = new LanDiscoveryConfig(

      this.cidr,

      WifiNetworkConstants.DEFAULT_LAN_PROBE_PORTS,

      2000,

      WifiNetworkConstants.DEFAULT_PORT_SCAN_CONCURRENCY

    );

    const result = await this.startLan.execute(config, (host: LanHostResult) => {

      this.hosts = this.hosts.concat([host]);

    });

    if (!result.success) {

      this.statusMessage = result.error?.message ?? 'Discovery failed';

    } else {

      this.statusMessage = `Discovery started — ${this.hosts.length} hosts found so far`;

    }

    this.scanning = false;

  }



  cancelDiscovery(): void {

    this.repository.cancelLanDiscovery();

    this.scanning = false;

    this.statusMessage = 'Discovery cancelled';

  }



  async startPortScanAction(): Promise<void> {

    if (!PrivateNetworkGuard.isPrivateIpv4(this.scanHost) &&

      PrivateNetworkGuard.isLargeRange(this.startPort, this.endPort)) {

      this.showLargeRangeConfirm = true;

      return;

    }

    await this.runPortScan();

  }



  confirmLargeRangeScan(): void {

    this.showLargeRangeConfirm = false;

    void this.runPortScan();

  }



  dismissLargeRangeScan(): void {

    this.showLargeRangeConfirm = false;

  }



  async runPortScan(): Promise<void> {

    this.scanning = true;

    this.portResults = [];

    this.statusMessage = 'Port scanning...';

    const config = new PortScanConfig(

      this.scanHost,

      this.startPort,

      this.endPort,

      'tcp',

      2000,

      this.portScanConcurrency

    );

    const result = await this.startPortScan.execute(config, (probe: PortProbeResult) => {

      if (probe.state === PortProbeState.OPEN) {

        this.portResults = this.portResults.concat([probe]);

      }

    });

    if (!result.success) {

      this.statusMessage = result.error?.message ?? 'Port scan failed';

    } else {

      this.statusMessage = `Scan complete — ${this.portResults.length} open ports`;

    }

    this.scanning = false;

  }



  cancelPortScan(): void {

    this.repository.cancelPortScan();

    this.scanning = false;

    this.statusMessage = 'Port scan cancelled';

  }



  async startMdnsDiscovery(): Promise<void> {

    this.mdnsSearching = true;

    const result = await this.startMdns.execute(this.mdnsServiceType);

    if (!result.success) {

      this.statusMessage = result.error?.message ?? 'mDNS start failed';

      this.mdnsSearching = false;

      return;

    }

    const ds = MdnsDataSource.getInstance();

    if (this.mdnsSubscription !== undefined) {

      this.mdnsSubscription.dispose();

    }

    this.mdnsSubscription = ds.observeServices().subscribe((services: DiscoveredNetworkService[]) => {

      this.discoveredServices = services;

    }, true);

    this.statusMessage = 'mDNS discovery started';

  }



  async stopMdnsDiscovery(): Promise<void> {

    await this.stopMdns.execute();

    this.mdnsSearching = false;

    this.discoveredServices = this.listDiscovered.execute();

    this.statusMessage = 'mDNS discovery stopped';

  }



  async startSsdpDiscovery(): Promise<void> {

    this.ssdpSearching = true;

    const result = await this.startSsdp.execute();

    if (!result.success) {

      this.statusMessage = result.error?.message ?? 'SSDP start failed';

      this.ssdpSearching = false;

      return;

    }

    const ds = SsdpDiscoveryDataSource.getInstance();

    if (this.ssdpSubscription !== undefined) {

      this.ssdpSubscription.dispose();

    }

    this.ssdpSubscription = ds.observeServices().subscribe(() => {

      this.discoveredServices = this.listDiscovered.execute();

    }, true);

    this.statusMessage = 'SSDP discovery started';

  }



  async stopSsdpDiscovery(): Promise<void> {

    await this.stopSsdp.execute();

    this.ssdpSearching = false;

    this.discoveredServices = this.listDiscovered.execute();

    this.statusMessage = 'SSDP discovery stopped';

  }



  async saveScanHostTarget(): Promise<void> {

    const result = await this.saveTarget.execute(

      `LAN ${this.scanHost}`,

      this.scanHost,

      this.startPort,

      'tcp'

    );

    this.statusMessage = result.success ? 'Host saved to favorites' : (result.error?.message ?? 'Save failed');

  }



  saveDiscoveredService(service: DiscoveredNetworkService): void {

    void this.saveTarget.execute(service.name, service.host, service.port, service.protocol).then((result) => {

      this.statusMessage = result.success ? `Saved ${service.name}` : (result.error?.message ?? 'Save failed');

    });

  }

}

