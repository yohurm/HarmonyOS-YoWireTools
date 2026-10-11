import { Result } from 'common_core';
import { DeviceFavoriteRecord } from 'common_storage';
import { NearLinkDevice, NearLinkAdapterSnapshot, NearLinkOverviewSnapshot } from '../model/NearLinkDevice';
import { NearLinkScanFilter } from '../model/NearLinkScanFilter';
import { NearLinkScanPhase } from '../model/NearLinkScanPhase';
import { NearLinkAdvertisingPacket } from '../model/NearLinkAdvertisingPacket';
import { NearLinkRecentConnection } from '../model/NearLinkRecentConnection';
import { SsapServiceTreeSnapshot } from '../model/SsapServiceTree';
import { Observable } from 'common_core';

export interface NearLinkRepositoryContract {
  observeDevices(): Observable<NearLinkDevice[]>;
  observeScanPhase(): Observable<NearLinkScanPhase>;
  observeAdapterState(): Observable<NearLinkAdapterSnapshot>;
  observeSsapTree(): Observable<SsapServiceTreeSnapshot>;
  getScanPhase(): NearLinkScanPhase;
  getLastScanFailureCode(): string;
  loadAdapterState(): Promise<Result<NearLinkAdapterSnapshot>>;
  loadOverview(permissionGranted: boolean): Promise<NearLinkOverviewSnapshot>;
  startScan(sessionId: string, filter: NearLinkScanFilter): Result<void>;
  stopScan(): Result<void>;
  listDevices(): NearLinkDevice[];
  getAdvertising(address: string): NearLinkAdvertisingPacket | undefined;
  listRecentConnections(): NearLinkRecentConnection[];
  listFavorites(): DeviceFavoriteRecord[];
  saveFavorite(device: NearLinkDevice, alias: string, protocol: string, uuid?: string): Promise<Result<void>>;
}
