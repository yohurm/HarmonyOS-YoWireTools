import { Subscription } from 'common_core';
import { DiscoveredNetworkService } from '../model/MqttModels';
import { WifiNetworkRepositoryContract } from '../repository/WifiNetworkRepositoryContract';

/**
 * Thin facade for LAN discovery cancellation and service observation.
 */
export class LanDiscoveryFacade {
  private readonly repository: WifiNetworkRepositoryContract;

  constructor(repository: WifiNetworkRepositoryContract) {
    this.repository = repository;
  }

  cancelLanDiscovery(): void {
    this.repository.cancelLanDiscovery();
  }

  cancelPortScan(): void {
    this.repository.cancelPortScan();
  }

  observeMdnsServices(onChange: (services: DiscoveredNetworkService[]) => void): Subscription {
    return this.repository.observeMdnsServices().subscribe(onChange, true);
  }

  observeSsdpServices(onChange: () => void): Subscription {
    return this.repository.observeSsdpServices().subscribe(onChange, true);
  }
}
