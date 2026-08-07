import { Result } from 'common_core';
import { SppUuidFavoriteDataSource } from '../../../data/datasource/local/SppUuidFavoriteDataSource';
import { SppUuidFavoriteEntry } from '../../model/SppUuidFavoriteEntry';

/**
 * Load / toggle / CRUD SPP custom UUID favorites.
 */
export class SppUuidFavoriteUseCases {
  private readonly dataSource: SppUuidFavoriteDataSource;

  constructor(dataSource: SppUuidFavoriteDataSource = SppUuidFavoriteDataSource.getInstance()) {
    this.dataSource = dataSource;
  }

  async listFavorites(): Promise<SppUuidFavoriteEntry[]> {
    return this.dataSource.ensureLoaded();
  }

  isFavorite(uuid: string): boolean {
    return this.dataSource.contains(uuid);
  }

  /**
   * @returns Result&lt;boolean&gt; — true if now favorited, false if removed.
   */
  async toggleFavorite(uuid: string, label: string = ''): Promise<Result<boolean>> {
    return this.dataSource.toggle(uuid, label);
  }

  async addFavorite(uuid: string, label: string = ''): Promise<Result<void>> {
    return this.dataSource.add(uuid, label);
  }

  async updateFavorite(uuid: string, nextUuid: string, label: string = ''): Promise<Result<void>> {
    return this.dataSource.update(uuid, nextUuid, label);
  }

  async removeFavorite(uuid: string): Promise<Result<void>> {
    return this.dataSource.remove(uuid);
  }
}
