import { Subscription } from 'common_core';
import { WifiNetworkRepository } from '../../data/repository/WifiNetworkRepository';
import { WifiNetworkRepositoryContract } from '../repository/WifiNetworkRepositoryContract';
import { DiscoveredNetworkService } from '../model/MqttModels';

/**
 * Thin facade for LAN discovery cancellation and service observation.
 */
export class LanDiscoveryFacade {
  private readonly repository: WifiNetworkRepositoryContract;

  constructor(repository: WifiNetworkRepositoryContract = WifiNetworkRepository.getInstance()) {
    this.repository = repository;
  }

  cancelLanDiscovery(): void {
    this.repository.cancelLanDiscovery();
  }

  cancelPortScan(): void {
    this.repository.cancelPortScan();
  }

  observeMdnsServices(onChange: (services: DiscoveredNetworkService[]) => void): Subscription {
    return this.repository.observeMdnsServices(onChange);
  }

  observeSsdpServices(onChange: () => void): Subscription {
    return this.repository.observeSsdpServices(onChange);
  }
}
