import { Subscription } from 'common_core';
import { MdnsDataSource } from '../../data/datasource/MdnsDataSource';
import { SsdpDiscoveryDataSource } from '../../data/datasource/SsdpDiscoveryDataSource';
import { WifiNetworkRepository } from '../../data/repository/WifiNetworkRepository';
import { DiscoveredNetworkService } from '../model/MqttModels';

/**
 * Thin facade for LAN discovery cancellation and service observation.
 */
export class LanDiscoveryFacade {
  private readonly repository: WifiNetworkRepository;
  private readonly mdnsDataSource: MdnsDataSource;
  private readonly ssdpDataSource: SsdpDiscoveryDataSource;

  constructor(
    repository: WifiNetworkRepository = WifiNetworkRepository.getInstance(),
    mdnsDataSource: MdnsDataSource = MdnsDataSource.getInstance(),
    ssdpDataSource: SsdpDiscoveryDataSource = SsdpDiscoveryDataSource.getInstance()
  ) {
    this.repository = repository;
    this.mdnsDataSource = mdnsDataSource;
    this.ssdpDataSource = ssdpDataSource;
  }

  cancelLanDiscovery(): void {
    this.repository.cancelLanDiscovery();
  }

  cancelPortScan(): void {
    this.repository.cancelPortScan();
  }

  observeMdnsServices(onChange: (services: DiscoveredNetworkService[]) => void): Subscription {
    return this.mdnsDataSource.observeServices().subscribe(onChange, true);
  }

  observeSsdpServices(onChange: () => void): Subscription {
    return this.ssdpDataSource.observeServices().subscribe(onChange, true);
  }
}
