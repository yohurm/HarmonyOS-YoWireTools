import { Result } from 'common_core';
import { BluetoothRepository } from '../../../data/repository/BluetoothRepository';
import { SppUuidFavoriteEntry } from '../../model/SppUuidFavoriteEntry';

/**
 * Load / toggle / CRUD SPP custom UUID favorites.
 */
export class SppUuidFavoriteUseCases {
  private readonly repository: BluetoothRepository;

  constructor(repository: BluetoothRepository = BluetoothRepository.getInstance()) {
    this.repository = repository;
  }

  async listFavorites(): Promise<SppUuidFavoriteEntry[]> {
    return this.repository.listSppUuidFavorites();
  }

  isFavorite(uuid: string): boolean {
    return this.repository.sppUuidIsFavorite(uuid);
  }

  /**
   * @returns Result&lt;boolean&gt; — true if now favorited, false if removed.
   */
  async toggleFavorite(uuid: string, label: string = ''): Promise<Result<boolean>> {
    return this.repository.toggleSppUuidFavorite(uuid, label);
  }

  async addFavorite(uuid: string, label: string = ''): Promise<Result<void>> {
    return this.repository.addSppUuidFavorite(uuid, label);
  }

  async updateFavorite(uuid: string, nextUuid: string, label: string = ''): Promise<Result<void>> {
    return this.repository.updateSppUuidFavorite(uuid, nextUuid, label);
  }

  async removeFavorite(uuid: string): Promise<Result<void>> {
    return this.repository.removeSppUuidFavorite(uuid);
  }
}
