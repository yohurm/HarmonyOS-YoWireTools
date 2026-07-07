import { wifiManager } from '@kit.ConnectivityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { Observable, Result, ResultError } from 'common_core';
import { WifiNetworkErrorCodes } from '../../constants/WifiNetworkErrorCodes';
import { WifiAccessPointSnapshot } from '../../domain/model/WifiAccessPointSnapshot';
import { WifiLinkedInfoSnapshot } from '../../domain/model/WifiLinkedInfoSnapshot';
import { BssidMaskReason, WifiScanSource } from '../../domain/model/WifiScanState';
import { WifiChannelCalculator } from '../../domain/service/WifiChannelCalculator';
import { NetworkKitEventBridge } from '../kit/NetworkKitEventBridge';
import { IdGenerator } from 'common_core';

type WifiStateListener = (active: boolean) => void;
type WifiConnectionListener = () => void;

/**
 * Platform wrapper for wifiManager APIs per architecture wifi_network/01.
 */
export class WifiInfoDataSource {
  private static instance: WifiInfoDataSource | undefined;
  private wifiStateHandler: ((state: number) => void) | undefined;
  private wifiConnectionHandler: (() => void) | undefined;
  private wifiStateListener: WifiStateListener | undefined;
  private wifiConnectionListener: WifiConnectionListener | undefined;
  private readonly wifiActiveObservable: Observable<boolean>;

  private constructor() {
    this.wifiActiveObservable = new Observable<boolean>(false);
  }

  static getInstance(): WifiInfoDataSource {
    if (WifiInfoDataSource.instance === undefined) {
      WifiInfoDataSource.instance = new WifiInfoDataSource();
    }
    return WifiInfoDataSource.instance;
  }

  async isWifiActive(): Promise<Result<boolean>> {
    try {
      const active = wifiManager.isWifiActive();
      this.wifiActiveObservable.next(active);
      return Result.ok(active);
    } catch (error) {
      const err = error as BusinessError;
      return Result.fail(ResultError.fromError(WifiNetworkErrorCodes.NO_WIFI_INFO, err));
    }
  }

  observeWifiActive(): Observable<boolean> {
    return this.wifiActiveObservable;
  }

  onWifiStateChange(listener: WifiStateListener): Result<void> {
    this.offWifiStateChange();
    this.wifiStateListener = listener;
    this.wifiStateHandler = (state: number) => {
      const active = state === 1;
      this.wifiActiveObservable.next(active);
      if (this.wifiStateListener !== undefined) {
        this.wifiStateListener(active);
      }
    };
    return NetworkKitEventBridge.subscribeWifiStateChange(this.wifiStateHandler);
  }

  offWifiStateChange(): void {
    if (this.wifiStateHandler !== undefined) {
      NetworkKitEventBridge.unsubscribeWifiStateChange(this.wifiStateHandler);
      this.wifiStateHandler = undefined;
    }
    this.wifiStateListener = undefined;
  }

  onWifiConnectionChange(listener: WifiConnectionListener): Result<void> {
    this.offWifiConnectionChange();
    this.wifiConnectionListener = listener;
    this.wifiConnectionHandler = () => {
      if (this.wifiConnectionListener !== undefined) {
        this.wifiConnectionListener();
      }
    };
    return NetworkKitEventBridge.subscribeWifiConnectionChange(this.wifiConnectionHandler);
  }

  offWifiConnectionChange(): void {
    if (this.wifiConnectionHandler !== undefined) {
      NetworkKitEventBridge.unsubscribeWifiConnectionChange(this.wifiConnectionHandler);
      this.wifiConnectionHandler = undefined;
    }
    this.wifiConnectionListener = undefined;
  }

  async getLinkedInfo(bssidVisible: boolean): Promise<Result<WifiLinkedInfoSnapshot>> {
    try {
      const activeResult = await this.isWifiActive();
      const wifiActive = activeResult.success && activeResult.value === true;
      const info = await wifiManager.getLinkedInfo();
      const connected = info.connState === 4;
      let ssid = '';
      let bssid = '';
      if (connected) {
        ssid = info.ssid ?? '';
        bssid = bssidVisible ? (info.bssid ?? '') : WifiAccessPointSnapshot.maskedBssid(
          info.bssid ?? '',
          false,
          BssidMaskReason.PERMISSION_DENIED
        );
      }
      let signalLevel = 0;
      try {
        signalLevel = wifiManager.getSignalLevel(info.rssi, info.band);
      } catch (_e) {
        signalLevel = 0;
      }
      return Result.ok(new WifiLinkedInfoSnapshot(
        Date.now(),
        wifiActive,
        connected,
        ssid,
        bssid,
        bssidVisible && bssid.length > 0,
        info.rssi,
        signalLevel,
        info.band,
        info.frequency,
        info.linkSpeed,
        '',
        '',
        []
      ));
    } catch (error) {
      const err = error as BusinessError;
      return Result.fail(ResultError.fromError(WifiNetworkErrorCodes.NO_WIFI_INFO, err));
    }
  }

  async startScan(): Promise<Result<void>> {
    try {
      await wifiManager.startScan();
      return Result.ok(undefined);
    } catch (error) {
      const err = error as BusinessError;
      return Result.fail(ResultError.fromError(WifiNetworkErrorCodes.SCAN_LIMITED, err));
    }
  }

  async getScanResults(bssidVisible: boolean, source: WifiScanSource): Promise<Result<WifiAccessPointSnapshot[]>> {
    try {
      const list: wifiManager.WifiScanInfo[] = await wifiManager.getScanInfoList();
      const now = Date.now();
      const results: WifiAccessPointSnapshot[] = [];
      for (let i = 0; i < list.length; i++) {
        const item: wifiManager.WifiScanInfo = list[i];
        const rawBssid = item.bssid ?? '';
        const maskReason = bssidVisible ? BssidMaskReason.HIDDEN : BssidMaskReason.PERMISSION_DENIED;
        const displayBssid = bssidVisible ? rawBssid :
          WifiAccessPointSnapshot.maskedBssid(rawBssid, false, maskReason);
        let signalLevel = 0;
        try {
          signalLevel = wifiManager.getSignalLevel(item.rssi, item.band);
        } catch (_e) {
          signalLevel = 0;
        }
        const channel = WifiChannelCalculator.fromFrequency(item.frequency);
        results.push(new WifiAccessPointSnapshot(
          IdGenerator.next('ap'),
          item.ssid ?? '',
          displayBssid,
          bssidVisible && rawBssid.length > 0,
          bssidVisible ? '' : maskReason,
          item.rssi,
          signalLevel,
          item.band,
          item.frequency,
          channel,
          `${item.securityType ?? ''}`,
          source,
          now
        ));
      }
      return Result.ok(results);
    } catch (error) {
      const err = error as BusinessError;
      return Result.fail(ResultError.fromError(WifiNetworkErrorCodes.NO_WIFI_INFO, err));
    }
  }
}
