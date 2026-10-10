import { abilityAccessCtrl, bundleManager, Permissions } from '@kit.AbilityKit';
import { connection, statistics } from '@kit.NetworkKit';
import { BusinessError, deviceInfo } from '@kit.BasicServicesKit';
import { Observable, Result, ResultError } from 'common_core';
import { YoLog } from 'yolog';
import { WifiNetworkConstants } from '../../constants/WifiNetworkConstants';
import { WifiNetworkErrorCodes } from '../../constants/WifiNetworkErrorCodes';
import {
  DnsLookupFacts,
  HttpProxyFacts,
  NetworkPropertyFacts,
  NetworkRouteFact,
  ProbeFacts,
  TraceHopFact
} from '../../domain/model/NetworkInspectFacts';
import { NetworkStateSnapshot } from '../../domain/model/NetworkStateSnapshot';

export { NetworkStateSnapshot };

const netLog = YoLog.tag('YoWire.Wifi');

type NetworkStateListener = (snapshot: NetworkStateSnapshot) => void;
type NetEventListener = (name: string, detail: string) => void;

interface AddressFamilyCarrier {
  isIPv4LinkValid?: boolean;
  isIPv6LinkValid?: boolean;
}

interface DnsConvertFailureAttributes {
  unicode: string;
  ascii: string;
}

/**
 * Call site for connection, DNS, probe, proxy, self traffic, and gated trace route.
 * queryTraceRoute runs only when API 26 and the restricted permission both allow it.
 */
export class NetworkConnectionDataSource {
  private static instance: NetworkConnectionDataSource | undefined;
  private netListener: NetworkStateListener | undefined;
  private eventListener: NetEventListener | undefined;
  private netConnection: connection.NetConnection | undefined;
  private readonly stateObservable: Observable<NetworkStateSnapshot>;

  private constructor() {
    this.stateObservable = new Observable<NetworkStateSnapshot>(
      new NetworkStateSnapshot(false, 'none', '')
    );
  }

  static getInstance(): NetworkConnectionDataSource {
    if (NetworkConnectionDataSource.instance === undefined) {
      NetworkConnectionDataSource.instance = new NetworkConnectionDataSource();
    }
    return NetworkConnectionDataSource.instance;
  }

  observeNetworkState(): Observable<NetworkStateSnapshot> {
    return this.stateObservable;
  }

  async getDefaultNet(): Promise<Result<NetworkStateSnapshot>> {
    try {
      const netHandle = await connection.getDefaultNet();
      if (netHandle.netId === 0) {
        const missing = new NetworkStateSnapshot(false, '0', '');
        this.stateObservable.next(missing);
        return Result.fail(new ResultError(
          WifiNetworkErrorCodes.NO_INTERNET,
          'netId 为 0',
          undefined,
          {},
          '0'
        ));
      }
      const snapshot = new NetworkStateSnapshot(netHandle.netId > 0, `${netHandle.netId}`, '');
      this.stateObservable.next(snapshot);
      return Result.ok(snapshot);
    } catch (error) {
      const err = error as BusinessError;
      netLog.warn(`getDefaultNet code=${err.code}`);
      return Result.fail(ResultError.fromBusinessError(WifiNetworkErrorCodes.NO_INTERNET, err, '权限被拒绝'));
    }
  }

  async readOnlineStatus(): Promise<Result<string>> {
    try {
      const netHandle = await connection.getDefaultNet();
      if (netHandle.netId === 0) {
        return Result.fail(new ResultError(WifiNetworkErrorCodes.NO_INTERNET, 'netId 为 0', undefined, {}, '0'));
      }
      const caps = await connection.getNetCapabilities(netHandle);
      const sentence = this.describeCaps(caps.networkCap);
      const down = caps.linkDownBandwidthKbps;
      const bandwidth = down === undefined || down === 0 ? '无法评估' : `${down} kbps`;
      return Result.ok(`${sentence}；系统估计 ${bandwidth}`);
    } catch (error) {
      const err = error as BusinessError;
      return Result.fail(ResultError.fromBusinessError(WifiNetworkErrorCodes.NO_INTERNET, err));
    }
  }

  async readConnectionProperties(): Promise<Result<NetworkPropertyFacts>> {
    try {
      const netHandle = await connection.getDefaultNet();
      if (netHandle.netId === 0) {
        return Result.fail(new ResultError(WifiNetworkErrorCodes.NO_INTERNET, 'netId 为 0', undefined, {}, '0'));
      }
      const props = await connection.getConnectionProperties(netHandle);
      const routes: NetworkRouteFact[] = [];
      const routeState = props.routes === undefined || props.routes.length === 0 ?
        WifiNetworkConstants.SYSTEM_NOT_RETURNED : '已返回';
      if (props.routes !== undefined) {
        for (let i = 0; i < props.routes.length; i++) {
          const route = props.routes[i];
          const destination = route.destination !== undefined && route.destination.address !== undefined ?
            `${route.destination.address.address}/${route.destination.prefixLength}` : WifiNetworkConstants.SYSTEM_NOT_RETURNED;
          const gateway = route.gateway !== undefined ? route.gateway.address : WifiNetworkConstants.SYSTEM_NOT_RETURNED;
          routes.push(new NetworkRouteFact(destination, gateway, route.isDefaultRoute === true));
        }
      }
      const linkAddressState = props.linkAddresses === undefined || props.linkAddresses.length === 0 ?
        WifiNetworkConstants.SYSTEM_NOT_RETURNED : `${props.linkAddresses.length}`;
      const dnsState = props.dnses === undefined || props.dnses.length === 0 ?
        WifiNetworkConstants.SYSTEM_NOT_RETURNED : `${props.dnses.length}`;
      let familyLine = '当前系统无此字段';
      if (deviceInfo.sdkApiVersion >= WifiNetworkConstants.ADDRESS_FAMILY_MIN_API) {
        const family = props as AddressFamilyCarrier;
        const ipv4 = NetworkConnectionDataSource.familyWord(family.isIPv4LinkValid);
        const ipv6 = NetworkConnectionDataSource.familyWord(family.isIPv6LinkValid);
        familyLine = `IPv4 ${ipv4}；IPv6 ${ipv6}`;
      }
      const interfaceName = props.interfaceName.length > 0 ? props.interfaceName : WifiNetworkConstants.SYSTEM_NOT_RETURNED;
      const mtu = props.mtu > 0 ? `${props.mtu}` : WifiNetworkConstants.SYSTEM_NOT_RETURNED;
      return Result.ok(new NetworkPropertyFacts(
        interfaceName,
        mtu,
        routes,
        linkAddressState,
        dnsState,
        routeState,
        familyLine
      ));
    } catch (error) {
      const err = error as BusinessError;
      const native = `${err.code}`;
      const message = native === WifiNetworkConstants.NATIVE_PERMISSION_DENIED ? '权限被拒绝' : err.message;
      return Result.fail(ResultError.fromBusinessError(WifiNetworkErrorCodes.NO_INTERNET, err, message));
    }
  }

  async readHttpProxy(): Promise<Result<HttpProxyFacts>> {
    try {
      const proxy = await connection.getDefaultHttpProxy();
      const exclusions = proxy.exclusionList !== undefined ? proxy.exclusionList.join(', ') : '';
      return Result.ok(new HttpProxyFacts(proxy.host, `${proxy.port}`, exclusions));
    } catch (error) {
      const err = error as BusinessError;
      return Result.fail(ResultError.fromBusinessError(WifiNetworkErrorCodes.NO_INTERNET, err));
    }
  }

  async getAddressesByNameWithOptions(host: string, family: number): Promise<Result<DnsLookupFacts>> {
    const trimmed = host.trim();
    if (trimmed.length === 0 || trimmed.indexOf(' ') >= 0) {
      return Result.fail(new ResultError(WifiNetworkErrorCodes.DNS_FAILED, '失败可见，不发起后续端口扫描'));
    }
    try {
      const netHandle = await connection.getDefaultNet();
      if (netHandle.netId === 0) {
        return Result.fail(new ResultError(WifiNetworkErrorCodes.DNS_FAILED, 'netId 为 0', undefined, {}, '0'));
      }
      let asciiHost = trimmed;
      if (deviceInfo.sdkApiVersion >= WifiNetworkConstants.DNS_OPTIONS_MIN_API && this.hasNonAscii(trimmed)) {
        try {
          asciiHost = await connection.getDnsAscii(trimmed);
        } catch (convertError) {
          const convert = convertError as BusinessError;
          const attributes: DnsConvertFailureAttributes = { unicode: trimmed, ascii: '' };
          return Result.fail(new ResultError(
            WifiNetworkErrorCodes.DNS_FAILED,
            `转码失败 ${convert.message}`,
            convert,
            NetworkConnectionDataSource.copyAttributes(attributes),
            `${convert.code}`
          ));
        }
      }
      let addresses: connection.NetAddress[] = [];
      if (deviceInfo.sdkApiVersion >= WifiNetworkConstants.DNS_OPTIONS_MIN_API && family !== 0) {
        const option: connection.QueryOptions = {
          family: family === 2 ? connection.FamilyType.FAMILY_TYPE_IPV6 : connection.FamilyType.FAMILY_TYPE_IPV4
        };
        addresses = await connection.getAddressesByNameWithOptions(asciiHost, option);
      } else {
        addresses = await connection.getAddressesByName(asciiHost);
      }
      const lines: string[] = [];
      let familyLabel = '默认网络';
      for (let i = 0; i < addresses.length; i++) {
        const item = addresses[i];
        lines.push(item.address);
        if (item.family === 1) {
          familyLabel = 'IPv4';
        } else if (item.family === 2) {
          familyLabel = 'IPv6';
        }
      }
      if (lines.length === 0) {
        return Result.fail(new ResultError(WifiNetworkErrorCodes.DNS_FAILED, '解析失败'));
      }
      return Result.ok(new DnsLookupFacts(trimmed, asciiHost, lines, familyLabel));
    } catch (error) {
      const err = error as BusinessError;
      const native = `${err.code}`;
      const message = native === WifiNetworkConstants.NATIVE_PERMISSION_DENIED ? '权限被拒绝' : err.message;
      return Result.fail(ResultError.fromBusinessError(WifiNetworkErrorCodes.DNS_FAILED, err, message));
    }
  }

  async queryTraceRoute(destination: string): Promise<Result<TraceHopFact[]>> {
    const trimmed = destination.trim();
    if (trimmed.length === 0) {
      return Result.fail(new ResultError(WifiNetworkErrorCodes.CONNECT_TIMEOUT, '参数无效'));
    }
    const refusal = this.traceRefusal();
    if (refusal !== undefined) {
      return Result.fail(refusal);
    }
    try {
      const option: connection.TraceRouteOptions = {
        maxJumpNumber: WifiNetworkConstants.TRACE_ROUTE_MAX_HOPS,
        packetsType: connection.PacketsType.NETCONN_PACKETS_ICMP
      };
      const hops = await connection.queryTraceRoute(trimmed, option);
      const facts: TraceHopFact[] = [];
      const limit = hops.length > WifiNetworkConstants.TRACE_ROUTE_MAX_HOPS ?
        WifiNetworkConstants.TRACE_ROUTE_MAX_HOPS : hops.length;
      for (let i = 0; i < limit; i++) {
        const hop = hops[i];
        facts.push(new TraceHopFact(hop.jumpNo, hop.address, NetworkConnectionDataSource.formatRtt(hop.rtt)));
      }
      return Result.ok(facts);
    } catch (error) {
      const err = error as BusinessError;
      const native = `${err.code}`;
      if (native === WifiNetworkConstants.NATIVE_PERMISSION_DENIED) {
        return Result.fail(new ResultError(
          WifiNetworkErrorCodes.NO_INTERNET,
          '失败码 201。未授予 ACCESS_NET_TRACE_INFO，不显示跳数表。',
          err,
          {},
          native
        ));
      }
      return Result.fail(ResultError.fromBusinessError(WifiNetworkErrorCodes.CONNECT_TIMEOUT, err, err.message));
    }
  }

  async queryProbeResult(destination: string): Promise<Result<ProbeFacts>> {
    if (deviceInfo.sdkApiVersion < WifiNetworkConstants.PROBE_MIN_API) {
      return Result.fail(new ResultError(
        WifiNetworkErrorCodes.CONNECT_TIMEOUT,
        '当前系统版本没有该接口'
      ));
    }
    try {
      const info = await connection.queryProbeResult(destination, 3);
      const rtt = info.rtt !== undefined ? info.rtt.join(', ') : WifiNetworkConstants.SYSTEM_NOT_RETURNED;
      return Result.ok(new ProbeFacts(`${info.lossRate}`, rtt, '系统探测'));
    } catch (error) {
      const err = error as BusinessError;
      return Result.fail(ResultError.fromBusinessError(WifiNetworkErrorCodes.CONNECT_TIMEOUT, err, err.message));
    }
  }

  async readSelfWifiTraffic(startMs: number, endMs: number): Promise<Result<string>> {
    if (deviceInfo.sdkApiVersion < WifiNetworkConstants.TRAFFIC_STATS_MIN_API) {
      return Result.fail(new ResultError(WifiNetworkErrorCodes.NO_INTERNET, '当前系统版本没有该接口'));
    }
    try {
      const info: statistics.NetworkInfo = {
        type: connection.NetBearType.BEARER_WIFI,
        startTime: startMs,
        endTime: endMs
      };
      const stats = await statistics.getSelfTrafficStats(info);
      return Result.ok(`收 ${stats.rxBytes} 字节，发 ${stats.txBytes} 字节`);
    } catch (error) {
      const err = error as BusinessError;
      const native = `${err.code}`;
      if (native === '2103019') {
        return Result.fail(new ResultError(
          WifiNetworkErrorCodes.NO_INTERNET,
          '查询起点早于 31 天',
          err,
          {},
          '2103019'
        ));
      }
      return Result.fail(ResultError.fromBusinessError(WifiNetworkErrorCodes.NO_INTERNET, err));
    }
  }

  startListening(listener: NetworkStateListener, events: NetEventListener): void {
    this.stopListening();
    this.netListener = listener;
    this.eventListener = events;
    const conn = connection.createNetConnection();
    this.netConnection = conn;
    conn.on('netAvailable', (handle: connection.NetHandle) => {
      const usable = handle.netId > 0;
      this.publish(new NetworkStateSnapshot(usable, `${handle.netId}`, 'netAvailable'));
      this.emit('netAvailable', `${handle.netId}`);
    });
    conn.on('netUnavailable', () => {
      this.publish(new NetworkStateSnapshot(false, 'none', 'netUnavailable'));
      this.emit('netUnavailable', 'netUnavailable');
    });
    conn.on('netLost', (handle: connection.NetHandle) => {
      this.emit('netLost', `${handle.netId}`);
    });
    conn.on('netCapabilitiesChange', (data: connection.NetCapabilityInfo) => {
      this.emit('netCapabilitiesChange', this.describeCaps(data.netCap.networkCap));
    });
    conn.on('netConnectionPropertiesChange', (_data: connection.NetConnectionPropertyInfo) => {
      this.emit('netConnectionPropertiesChange', '属性变化');
    });
    conn.on('netBlockStatusChange', (data: connection.NetBlockStatusInfo) => {
      this.emit('netBlockStatusChange', data.blocked ? '网络阻塞' : '未阻塞');
    });
    conn.register(() => {
      netLog.info('netConnection registered');
    });
  }

  stopListening(): void {
    if (this.netConnection !== undefined) {
      this.netConnection.unregister(() => {
      });
    }
    this.netConnection = undefined;
    this.netListener = undefined;
    this.eventListener = undefined;
  }

  private publish(snapshot: NetworkStateSnapshot): void {
    this.stateObservable.next(snapshot);
    if (this.netListener !== undefined) {
      this.netListener(snapshot);
    }
  }

  private emit(name: string, detail: string): void {
    netLog.info(`${name} ${detail}`);
    if (this.eventListener !== undefined) {
      this.eventListener(name, detail);
    }
  }

  private describeCaps(caps: connection.NetCap[] | undefined): string {
    if (caps === undefined) {
      return WifiNetworkConstants.SYSTEM_NOT_RETURNED;
    }
    let checking = false;
    let portal = false;
    let internet = false;
    let validated = false;
    for (let i = 0; i < caps.length; i++) {
      const cap = caps[i];
      if (cap === connection.NetCap.NET_CAPABILITY_CHECKING_CONNECTIVITY) {
        checking = true;
      } else if (cap === connection.NetCap.NET_CAPABILITY_PORTAL) {
        portal = true;
      } else if (cap === connection.NetCap.NET_CAPABILITY_INTERNET) {
        internet = true;
      } else if (cap === connection.NetCap.NET_CAPABILITY_VALIDATED) {
        validated = true;
      }
    }
    if (checking) {
      return '检测中';
    }
    if (portal) {
      return '需要门户认证';
    }
    if (internet && !validated) {
      return '网络提供者标记可上网，连通性未验证';
    }
    if (validated) {
      return '已验证';
    }
    return '能力变化';
  }

  private traceRefusal(): ResultError | undefined {
    if (deviceInfo.sdkApiVersion < WifiNetworkConstants.PROBE_MIN_API) {
      return new ResultError(WifiNetworkErrorCodes.CONNECT_TIMEOUT, '当前系统版本没有该接口');
    }
    if (!this.permissionGranted('ohos.permission.ACCESS_NET_TRACE_INFO')) {
      return new ResultError(
        WifiNetworkErrorCodes.NO_INTERNET,
        '失败码 201。未授予 ACCESS_NET_TRACE_INFO，不显示跳数表。',
        undefined,
        {},
        WifiNetworkConstants.NATIVE_PERMISSION_DENIED
      );
    }
    const location = this.permissionGranted('ohos.permission.LOCATION') &&
      this.permissionGranted('ohos.permission.APPROXIMATELY_LOCATION');
    if (!location) {
      return new ResultError(
        WifiNetworkErrorCodes.NO_INTERNET,
        '位置未授权。不显示跳数表。',
        undefined,
        {},
        WifiNetworkConstants.NATIVE_PERMISSION_DENIED
      );
    }
    return undefined;
  }

  private permissionGranted(permission: Permissions): boolean {
    try {
      const bundleInfo = bundleManager.getBundleInfoForSelfSync(
        bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION
      );
      const tokenId = bundleInfo.appInfo.accessTokenId;
      const grant = abilityAccessCtrl.createAtManager().checkAccessTokenSync(tokenId, permission);
      return grant === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED;
    } catch (_error) {
      return false;
    }
  }

  private static familyWord(flag: boolean | undefined): string {
    if (flag === undefined) {
      return WifiNetworkConstants.SYSTEM_NOT_RETURNED;
    }
    return flag ? '可用' : '不可用';
  }

  private static formatRtt(rtt: number[] | undefined): string {
    if (rtt === undefined || rtt.length < 4) {
      return WifiNetworkConstants.SYSTEM_NOT_RETURNED;
    }
    return `${rtt[0]}, ${rtt[1]}, ${rtt[2]}, ${rtt[3]}`;
  }

  private static copyAttributes(source: DnsConvertFailureAttributes): Record<string, string | number | boolean> {
    const attributes: Record<string, string | number | boolean> = {};
    attributes['unicode'] = source.unicode;
    attributes['ascii'] = source.ascii;
    return attributes;
  }

  private hasNonAscii(host: string): boolean {
    for (let i = 0; i < host.length; i++) {
      if (host.charCodeAt(i) > 127) {
        return true;
      }
    }
    return false;
  }
}
