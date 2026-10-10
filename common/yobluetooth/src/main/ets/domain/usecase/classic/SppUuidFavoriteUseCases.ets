import { Result } from 'common_core';
import { SppUuidFavoriteEntry } from '../../model/SppUuidFavoriteEntry';
import { BluetoothRepositoryContract } from '../../repository/BluetoothRepositoryContract';

/**
 * Load / toggle / CRUD SPP custom UUID favorites.
 */
export class SppUuidFavoriteUseCases {
  private readonly repository: BluetoothRepositoryContract;

  constructor(repository: BluetoothRepositoryContract) {
    this.repository = repository;
  }

  async listFavorites(): Promise<SppUuidFavoriteEntry[]> {
    return this.repository.listSppUuidFavorites();
  }

  isFavorite(uuid: string): boolean {
    return this.repository.isSppUuidFavorite(uuid);
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
