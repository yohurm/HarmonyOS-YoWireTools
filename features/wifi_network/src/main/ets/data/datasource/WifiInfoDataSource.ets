import { wifiManager } from '@kit.ConnectivityKit';
import { BusinessError, deviceInfo } from '@kit.BasicServicesKit';
import { IdGenerator, Observable, Result, ResultError } from 'common_core';
import { YoLog } from 'yolog';
import { WifiNetworkConstants } from '../../constants/WifiNetworkConstants';
import { WifiNetworkErrorCodes } from '../../constants/WifiNetworkErrorCodes';
import { WifiAccessPointSnapshot } from '../../domain/model/WifiAccessPointSnapshot';
import {
  WifiCandidateDraft,
  WifiFeatureFact,
  WifiIpv4Facts,
  WifiIpv6Facts,
  WifiScanBatch
} from '../../domain/model/WifiDebugFacts';
import { WifiLinkedInfoSnapshot } from '../../domain/model/WifiLinkedInfoSnapshot';
import { BssidMaskReason, WifiScanSource } from '../../domain/model/WifiScanState';
import { WifiChannelCalculator } from '../../domain/service/WifiChannelCalculator';
import { WifiFieldLabels } from '../../domain/service/WifiFieldLabels';
import { NetworkKitEventBridge } from '../kit/NetworkKitEventBridge';

const wifiLog = YoLog.tag('YoWire.Wifi');

type WifiStateListener = (active: boolean) => void;
type WifiPowerListener = (state: number) => void;
type WifiConnectionListener = () => void;
type WifiConnectionStateListener = (state: number) => void;
type WifiRssiListener = (rssi: number) => void;

/**
 * wifiManager call site. Version checks and BusinessError classification stay here.
 */
export class WifiInfoDataSource {
  private static instance: WifiInfoDataSource | undefined;
  private wifiStateHandler: ((state: number) => void) | undefined;
  private wifiPowerHandler: ((state: number) => void) | undefined;
  private wifiConnectionHandler: (() => void) | undefined;
  private wifiConnectionStateHandler: ((state: number) => void) | undefined;
  private wifiRssiHandler: ((rssi: number) => void) | undefined;
  private scanStateHandler: ((state: number) => void) | undefined;
  private wifiStateListener: WifiStateListener | undefined;
  private wifiPowerListener: WifiPowerListener | undefined;
  private wifiConnectionListener: WifiConnectionListener | undefined;
  private wifiConnectionStateListener: WifiConnectionStateListener | undefined;
  private wifiRssiListener: WifiRssiListener | undefined;
  private readonly wifiActiveObservable: Observable<boolean>;
  private scanWait: ((state: number) => void) | undefined;
  private scanWaitTimer: number = -1;

  private constructor() {
    this.wifiActiveObservable = new Observable<boolean>(false);
  }

  static getInstance(): WifiInfoDataSource {
    if (WifiInfoDataSource.instance === undefined) {
      WifiInfoDataSource.instance = new WifiInfoDataSource();
    }
    return WifiInfoDataSource.instance;
  }

  static isEmulatorRuntime(): boolean {
    const model = `${deviceInfo.productModel}`.toLowerCase();
    const brand = `${deviceInfo.brand}`.toLowerCase();
    return model.indexOf('emulator') >= 0 || model.indexOf('simulator') >= 0 || brand.indexOf('emulator') >= 0;
  }

  sdkApiVersion(): number {
    return deviceInfo.sdkApiVersion;
  }

  async isWifiActive(): Promise<Result<boolean>> {
    try {
      const active = wifiManager.isWifiActive();
      this.wifiActiveObservable.next(active);
      return Result.ok(active);
    } catch (error) {
      return Result.fail(this.asError(error));
    }
  }

  async isStaConnected(): Promise<Result<boolean>> {
    try {
      return Result.ok(wifiManager.isConnected());
    } catch (error) {
      return Result.fail(this.asError(error));
    }
  }

  async isHotspotActive(): Promise<Result<boolean>> {
    if (deviceInfo.sdkApiVersion < 15) {
      return Result.fail(new ResultError(
        WifiNetworkErrorCodes.NO_WIFI_INFO,
        '当前系统版本没有该接口',
        undefined,
        {},
        ''
      ));
    }
    try {
      return Result.ok(wifiManager.isHotspotActive());
    } catch (error) {
      return Result.fail(this.asError(error));
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

  onWifiPowerState(listener: WifiPowerListener): Result<void> {
    this.offWifiPowerState();
    this.wifiPowerListener = listener;
    this.wifiPowerHandler = (state: number) => {
      this.wifiActiveObservable.next(state === 1);
      wifiLog.info(`wifiStateChange state=${state} label=${WifiFieldLabels.wifiPowerState(state)}`);
      if (this.wifiPowerListener !== undefined) {
        this.wifiPowerListener(state);
      }
    };
    return NetworkKitEventBridge.subscribeWifiStateChange(this.wifiPowerHandler);
  }

  offWifiPowerState(): void {
    if (this.wifiPowerHandler !== undefined) {
      NetworkKitEventBridge.unsubscribeWifiStateChange(this.wifiPowerHandler);
      this.wifiPowerHandler = undefined;
    }
    this.wifiPowerListener = undefined;
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

  onWifiConnectionState(listener: WifiConnectionStateListener): Result<void> {
    this.offWifiConnectionState();
    this.wifiConnectionStateListener = listener;
    this.wifiConnectionStateHandler = (state: number) => {
      wifiLog.info(`wifiConnectionChange state=${state} label=${WifiFieldLabels.connState(state)}`);
      if (this.wifiConnectionStateListener !== undefined) {
        this.wifiConnectionStateListener(state);
      }
    };
    return NetworkKitEventBridge.subscribeWifiConnectionState(this.wifiConnectionStateHandler);
  }

  offWifiConnectionState(): void {
    if (this.wifiConnectionStateHandler !== undefined) {
      NetworkKitEventBridge.unsubscribeWifiConnectionState(this.wifiConnectionStateHandler);
      this.wifiConnectionStateHandler = undefined;
    }
    this.wifiConnectionStateListener = undefined;
  }

  onWifiRssiChange(listener: WifiRssiListener): Result<void> {
    this.offWifiRssiChange();
    this.wifiRssiListener = listener;
    this.wifiRssiHandler = (rssi: number) => {
      if (this.wifiRssiListener !== undefined) {
        this.wifiRssiListener(rssi);
      }
    };
    return NetworkKitEventBridge.subscribeWifiRssiChange(this.wifiRssiHandler);
  }

  offWifiRssiChange(): void {
    if (this.wifiRssiHandler !== undefined) {
      NetworkKitEventBridge.unsubscribeWifiRssiChange(this.wifiRssiHandler);
      this.wifiRssiHandler = undefined;
    }
    this.wifiRssiListener = undefined;
  }

  async readFeatureSupport(): Promise<Result<WifiFeatureFact[]>> {
    const specs: WifiFeatureFact[] = [
      new WifiFeatureFact('基础结构', false),
      new WifiFeatureFact('5 GHz', false),
      new WifiFeatureFact('Wi-Fi Direct', false),
      new WifiFeatureFact('Soft AP', false),
      new WifiFeatureFact('SAE', false),
      new WifiFeatureFact('增强开放', false)
    ];
    const ids: number[] = [
      WifiNetworkConstants.FEATURE_INFRA,
      WifiNetworkConstants.FEATURE_INFRA_5G,
      WifiNetworkConstants.FEATURE_P2P,
      WifiNetworkConstants.FEATURE_SOFT_AP,
      WifiNetworkConstants.FEATURE_SAE,
      WifiNetworkConstants.FEATURE_OWE
    ];
    const rows: WifiFeatureFact[] = [];
    for (let i = 0; i < ids.length; i++) {
      try {
        const supported = wifiManager.isFeatureSupported(ids[i]);
        rows.push(new WifiFeatureFact(specs[i].name, supported, ''));
      } catch (error) {
        const err = error as BusinessError;
        const native = `${err.code}`;
        wifiLog.error(`isFeatureSupported id=${ids[i]} code=${native}`);
        rows.push(new WifiFeatureFact(specs[i].name, false, native));
      }
    }
    return Result.ok(rows);
  }

  async getLinkedInfo(bssidVisible: boolean): Promise<Result<WifiLinkedInfoSnapshot>> {
    try {
      const activeResult = await this.isWifiActive();
      const wifiActive = activeResult.success && activeResult.value === true;
      const info = await this.readLinkedInfo();
      return Result.ok(this.mapLinked(info, wifiActive, bssidVisible, ''));
    } catch (error) {
      return Result.fail(this.asError(error));
    }
  }

  async readIpv4(): Promise<Result<WifiIpv4Facts>> {
    try {
      const info = wifiManager.getIpInfo();
      return Result.ok(new WifiIpv4Facts(
        this.formatIpv4(info.ipAddress),
        this.formatIpv4(info.gateway),
        this.formatIpv4(info.netmask),
        this.formatIpv4(info.primaryDns),
        this.formatIpv4(info.secondDns),
        this.formatIpv4(info.serverIp),
        info.leaseDuration === 0 ? WifiNetworkConstants.NOT_OBTAINED : `${info.leaseDuration}`
      ));
    } catch (error) {
      return Result.fail(this.asError(error));
    }
  }

  async readIpv6(): Promise<Result<WifiIpv6Facts>> {
    try {
      const info = wifiManager.getIpv6Info();
      const dns = info.primaryDNS.length > 0 ? info.primaryDNS : WifiNetworkConstants.NOT_OBTAINED;
      return Result.ok(new WifiIpv6Facts(
        this.presentText(info.linkIpv6Address),
        this.presentText(info.globalIpv6Address),
        this.presentText(info.gateway),
        dns,
        WifiNetworkConstants.NOT_PROVIDED
      ));
    } catch (error) {
      return Result.fail(this.asError(error));
    }
  }

  async startScan(): Promise<Result<void>> {
    return this.invokeStartScan();
  }

  async runActiveScan(bssidVisible: boolean): Promise<Result<WifiScanBatch>> {
    if (deviceInfo.sdkApiVersion < WifiNetworkConstants.START_SCAN_MIN_API) {
      return Result.fail(new ResultError(
        WifiNetworkErrorCodes.SCAN_LIMITED,
        '当前系统版本没有该接口',
        undefined,
        {},
        ''
      ));
    }
    const stateResult = await this.awaitScanState();
    if (!stateResult.success || stateResult.value === undefined) {
      return Result.fail(stateResult.error ?? new ResultError(WifiNetworkErrorCodes.SCAN_LIMITED, '扫描失败'));
    }
    if (stateResult.value !== 1) {
      return Result.fail(new ResultError(
        WifiNetworkErrorCodes.SCAN_LIMITED,
        '扫描失败',
        undefined,
        {},
        ''
      ));
    }
    return this.readScanList(bssidVisible, WifiScanSource.ACTIVE_SCAN, 1);
  }

  async getScanResults(bssidVisible: boolean, source: WifiScanSource): Promise<Result<WifiAccessPointSnapshot[]>> {
    const batch = await this.readScanList(bssidVisible, source, source === WifiScanSource.ACTIVE_SCAN ? 1 : -1);
    if (!batch.success || batch.value === undefined) {
      return Result.fail(batch.error ?? new ResultError(WifiNetworkErrorCodes.NO_WIFI_INFO, '扫描缓存不可用'));
    }
    return Result.ok(batch.value.rows);
  }

  async readScanCache(bssidVisible: boolean): Promise<Result<WifiScanBatch>> {
    return this.readScanList(bssidVisible, WifiScanSource.CACHE, -1);
  }

  async addCandidate(draft: WifiCandidateDraft): Promise<Result<number>> {
    try {
      const config: wifiManager.WifiDeviceConfig = {
        ssid: draft.ssid,
        preSharedKey: draft.key,
        securityType: WifiFieldLabels.securityCode(draft.security),
        isHiddenSsid: draft.hidden
      };
      if (draft.security === 'EAP') {
        config.eapConfig = {
          eapMethod: wifiManager.EapMethod.EAP_PEAP,
          phase2Method: wifiManager.Phase2Method.PHASE2_MSCHAPV2,
          identity: draft.eapIdentity,
          anonymousIdentity: '',
          password: draft.eapPassword,
          caCertAlias: '',
          caPath: '',
          clientCertAlias: '',
          certEntry: new Uint8Array(),
          certPassword: '',
          altSubjectMatch: '',
          domainSuffixMatch: '',
          realm: '',
          plmn: '',
          eapSubId: 0
        };
      }
      const networkId = await wifiManager.addCandidateConfig(config);
      wifiLog.info(`addCandidateConfig networkId=${networkId}`);
      return Result.ok(networkId);
    } catch (error) {
      return Result.fail(this.asError(error));
    }
  }

  connectCandidate(networkId: number): Result<void> {
    try {
      wifiManager.connectToCandidateConfig(networkId);
      return Result.ok(undefined);
    } catch (error) {
      return Result.fail(this.asError(error));
    }
  }

  async connectCandidateWithUserAction(networkId: number): Promise<Result<void>> {
    if (deviceInfo.sdkApiVersion < WifiNetworkConstants.USER_ACTION_CONNECT_MIN_API) {
      return Result.fail(new ResultError(
        WifiNetworkErrorCodes.SCAN_LIMITED,
        '当前系统版本没有该接口',
        undefined,
        {},
        ''
      ));
    }
    if (networkId < 0) {
      return Result.fail(new ResultError(
        WifiNetworkErrorCodes.SCAN_LIMITED,
        '参数无效',
        undefined,
        {},
        WifiNetworkConstants.NATIVE_PARAM_INVALID
      ));
    }
    try {
      await wifiManager.connectToCandidateConfigWithUserAction(networkId);
      return Result.ok(undefined);
    } catch (error) {
      return Result.fail(this.asError(error));
    }
  }

  async removeCandidate(networkId: number): Promise<Result<void>> {
    try {
      await wifiManager.removeCandidateConfig(networkId);
      return Result.ok(undefined);
    } catch (error) {
      return Result.fail(this.asError(error));
    }
  }

  async listCandidateSsids(): Promise<Result<string[]>> {
    try {
      const configs = await wifiManager.getCandidateConfigs();
      const names: string[] = [];
      for (let i = 0; i < configs.length; i++) {
        names.push(configs[i].ssid);
      }
      return Result.ok(names);
    } catch (error) {
      return Result.fail(this.asError(error));
    }
  }

  private awaitScanState(): Promise<Result<number>> {
    return new Promise<Result<number>>((resolve) => {
      let settled = false;
      const finish = (result: Result<number>) => {
        if (settled) {
          return;
        }
        settled = true;
        if (this.scanWaitTimer >= 0) {
          clearTimeout(this.scanWaitTimer);
          this.scanWaitTimer = -1;
        }
        this.clearScanWait();
        resolve(result);
      };
      this.scanStateHandler = (state: number) => {
        wifiLog.info(`wifiScanStateChange state=${state}`);
        finish(Result.ok(state));
      };
      const subscribed = NetworkKitEventBridge.subscribeWifiScanStateChange(this.scanStateHandler);
      if (!subscribed.success) {
        finish(Result.fail(subscribed.error ?? new ResultError(WifiNetworkErrorCodes.SCAN_LIMITED, '扫描失败')));
        return;
      }
      const started = this.invokeStartScan();
      if (!started.success) {
        finish(Result.fail(started.error ?? new ResultError(WifiNetworkErrorCodes.SCAN_LIMITED, '扫描失败')));
        return;
      }
      this.scanWaitTimer = setTimeout(() => {
        finish(Result.fail(new ResultError(WifiNetworkErrorCodes.SCAN_LIMITED, '扫描失败')));
      }, WifiNetworkConstants.SCAN_STATE_WAIT_MS);
    });
  }

  private invokeStartScan(): Result<void> {
    if (deviceInfo.sdkApiVersion < WifiNetworkConstants.START_SCAN_MIN_API) {
      return Result.fail(new ResultError(
        WifiNetworkErrorCodes.SCAN_LIMITED,
        '当前系统版本没有该接口',
        undefined,
        {},
        ''
      ));
    }
    try {
      wifiManager.startScan();
      wifiLog.info('startScan');
      return Result.ok(undefined);
    } catch (error) {
      const err = error as BusinessError;
      wifiLog.error(`startScan code=${err.code} message=${err.message}`);
      return Result.fail(this.asError(error));
    }
  }

  private clearScanWait(): void {
    if (this.scanStateHandler !== undefined) {
      NetworkKitEventBridge.unsubscribeWifiScanStateChange(this.scanStateHandler);
      this.scanStateHandler = undefined;
    }
    this.scanWait = undefined;
  }

  private readScanList(bssidVisible: boolean, source: WifiScanSource, scanState: number): Result<WifiScanBatch> {
    try {
      const list = wifiManager.getScanInfoList();
      const now = Date.now();
      const results: WifiAccessPointSnapshot[] = [];
      for (let i = 0; i < list.length; i++) {
        const item = list[i];
        const rawBssid = item.bssid ?? '';
        let signalLevel = 0;
        try {
          signalLevel = wifiManager.getSignalLevel(item.rssi, item.band);
        } catch (levelError) {
          const err = levelError as BusinessError;
          wifiLog.error(`getSignalLevel code=${err.code}`);
          signalLevel = 0;
        }
        const channel = WifiChannelCalculator.fromFrequency(item.frequency);
        const addressKind = WifiFieldLabels.addressKind(item.bssidType, bssidVisible);
        results.push(new WifiAccessPointSnapshot(
          IdGenerator.next('ap'),
          item.ssid ?? '',
          rawBssid,
          bssidVisible && item.bssidType === 1,
          bssidVisible ? '' : BssidMaskReason.PERMISSION_DENIED,
          item.rssi,
          signalLevel,
          item.band,
          item.frequency,
          channel,
          WifiFieldLabels.security(item.securityType),
          source,
          now,
          WifiFieldLabels.channelWidth(item.channelWidth),
          addressKind
        ));
      }
      return Result.ok(new WifiScanBatch(results, now, source, scanState));
    } catch (error) {
      return Result.fail(this.asError(error));
    }
  }

  private async readLinkedInfo(): Promise<wifiManager.WifiLinkedInfo> {
    if (deviceInfo.sdkApiVersion >= WifiNetworkConstants.LINK_TYPE_MIN_API) {
      return wifiManager.getLinkedInfoSync();
    }
    return wifiManager.getLinkedInfo();
  }

  private mapLinked(
    info: wifiManager.WifiLinkedInfo,
    wifiActive: boolean,
    bssidVisible: boolean,
    nativeCode: string
  ): WifiLinkedInfoSnapshot {
    const conn = WifiFieldLabels.connState(info.connState);
    const connected = info.connState === 4;
    let ssid = '';
    let bssid = '';
    if (connected) {
      ssid = info.ssid ?? '';
      bssid = info.bssid ?? '';
    }
    let signalLevel = 0;
    try {
      signalLevel = wifiManager.getSignalLevel(info.rssi, info.band);
    } catch (_e) {
      signalLevel = 0;
    }
    let linkTypeLabel = '当前系统无此字段';
    if (deviceInfo.sdkApiVersion >= WifiNetworkConstants.LINK_TYPE_MIN_API && info.wifiLinkType !== undefined) {
      linkTypeLabel = WifiFieldLabels.linkType(info.wifiLinkType);
    }
    const mac = info.macAddress ?? '';
    return new WifiLinkedInfoSnapshot(
      Date.now(),
      wifiActive,
      connected,
      ssid,
      bssid,
      bssidVisible,
      info.rssi,
      signalLevel,
      info.band,
      info.frequency,
      info.linkSpeed,
      '',
      '',
      [],
      info.linkSpeed,
      info.rxLinkSpeed,
      info.maxSupportedTxLinkSpeed,
      info.maxSupportedRxLinkSpeed,
      WifiFieldLabels.channelWidth(info.channelWidth),
      WifiFieldLabels.wifiStandard(info.wifiStandard),
      conn,
      info.isHidden ? '是' : '否',
      info.isRestricted ? '数据量受限' : '否',
      linkTypeLabel,
      mac,
      WifiFieldLabels.addressKind(0, bssidVisible),
      nativeCode
    );
  }

  private formatIpv4(value: number): string {
    return WifiFieldLabels.ipv4Text(value);
  }

  private presentText(value: string): string {
    if (value.length === 0) {
      return WifiNetworkConstants.NOT_OBTAINED;
    }
    return value;
  }

  private asError(error: Object): ResultError {
    const err = error as BusinessError;
    wifiLog.error(`wifi call code=${err.code} message=${err.message}`);
    const native = `${err.code}`;
    let message = err.message ?? '操作失败';
    if (message.indexOf('moving freeze') >= 0) {
      message = '静止管控';
    }
    return new ResultError(WifiNetworkErrorCodes.NO_WIFI_INFO, message, err, {}, native);
  }
}
