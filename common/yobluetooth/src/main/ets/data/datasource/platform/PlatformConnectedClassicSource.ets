import { a2dp, baseProfile, hfp, hid } from '@kit.ConnectivityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { Result } from 'common_core';
import { YoLog, YoLogger } from 'yolog';
import { ClassicConnectedSnapshot } from '../../../domain/model/ClassicConnectedSnapshot';
import { SppSessionKey } from '../../../domain/model/SppSessionKey';
import { BtLogTag } from '../../../observability/BtLogTag';
import { ConnectivityKitEventBridge } from '../../kit/ConnectivityKitEventBridge';

const logger: YoLogger = YoLog.tag(BtLogTag.CONN);

/**
 * Platform Connected classic source (architecture bluetooth/01).
 *
 * Official: BaseProfile.getConnectedDevices for A2DP / HFP / HID.
 * Capability gap: no ACL list / onAclStateChange on current SDK — logged once, never faked.
 */
export class PlatformConnectedClassicSource {
  private static instance: PlatformConnectedClassicSource | undefined;
  private static aclGapLogged: boolean = false;

  private onChanged: (() => void) | undefined;
  private watching: boolean = false;

  private a2dpProfile: a2dp.A2dpSourceProfile | undefined;
  private hfpProfile: hfp.HandsFreeAudioGatewayProfile | undefined;
  private hidProfile: hid.HidHostProfile | undefined;

  private a2dpHandler: ((param: baseProfile.StateChangeParam) => void) | undefined;
  private hfpHandler: ((param: baseProfile.StateChangeParam) => void) | undefined;
  private hidHandler: ((param: baseProfile.StateChangeParam) => void) | undefined;

  static getInstance(): PlatformConnectedClassicSource {
    if (PlatformConnectedClassicSource.instance === undefined) {
      PlatformConnectedClassicSource.instance = new PlatformConnectedClassicSource();
    }
    return PlatformConnectedClassicSource.instance;
  }

  setOnChanged(listener: (() => void) | undefined): void {
    this.onChanged = listener;
  }

  watch(): Result<void> {
    if (this.watching) {
      return Result.ok(undefined);
    }
    this.logAclCapabilityGapOnce();

    this.a2dpHandler = (_param: baseProfile.StateChangeParam): void => {
      this.notifyChanged();
    };
    this.hfpHandler = (_param: baseProfile.StateChangeParam): void => {
      this.notifyChanged();
    };
    this.hidHandler = (_param: baseProfile.StateChangeParam): void => {
      this.notifyChanged();
    };

    try {
      this.a2dpProfile = a2dp.createA2dpSrcProfile();
      const a2dpSub = ConnectivityKitEventBridge.subscribeProfileConnectionStateChange(
        this.a2dpProfile,
        this.a2dpHandler
      );
      if (!a2dpSub.success) {
        logger.warn('profile_watch_failed profile=a2dp');
      }
    } catch (error) {
      const err = error as BusinessError;
      logger.warn(`profile_create_failed profile=a2dp code=${err.code}`);
    }

    try {
      this.hfpProfile = hfp.createHfpAgProfile();
      const hfpSub = ConnectivityKitEventBridge.subscribeProfileConnectionStateChange(
        this.hfpProfile,
        this.hfpHandler
      );
      if (!hfpSub.success) {
        logger.warn('profile_watch_failed profile=hfp');
      }
    } catch (error) {
      const err = error as BusinessError;
      logger.warn(`profile_create_failed profile=hfp code=${err.code}`);
    }

    try {
      this.hidProfile = hid.createHidHostProfile();
      const hidSub = ConnectivityKitEventBridge.subscribeProfileConnectionStateChange(
        this.hidProfile,
        this.hidHandler
      );
      if (!hidSub.success) {
        logger.warn('profile_watch_failed profile=hid');
      }
    } catch (error) {
      const err = error as BusinessError;
      logger.warn(`profile_create_failed profile=hid code=${err.code}`);
    }

    this.watching = true;
    logger.info('platform_connected_watch_started profiles=a2dp,hfp,hid');
    return Result.ok(undefined);
  }

  stopWatch(): void {
    if (this.a2dpProfile !== undefined) {
      ConnectivityKitEventBridge.unsubscribeProfileConnectionStateChange(
        this.a2dpProfile,
        this.a2dpHandler
      );
    }
    if (this.hfpProfile !== undefined) {
      ConnectivityKitEventBridge.unsubscribeProfileConnectionStateChange(
        this.hfpProfile,
        this.hfpHandler
      );
    }
    if (this.hidProfile !== undefined) {
      ConnectivityKitEventBridge.unsubscribeProfileConnectionStateChange(
        this.hidProfile,
        this.hidHandler
      );
    }
    this.a2dpProfile = undefined;
    this.hfpProfile = undefined;
    this.hidProfile = undefined;
    this.a2dpHandler = undefined;
    this.hfpHandler = undefined;
    this.hidHandler = undefined;
    this.watching = false;
  }

  listConnectedClassicAddresses(): ClassicConnectedSnapshot {
    this.watch();
    const addresses = new Set<string>();
    this.addProfileConnected(addresses, 'a2dp', () => {
      const profile = this.a2dpProfile ?? a2dp.createA2dpSrcProfile();
      this.a2dpProfile = profile;
      return profile.getConnectedDevices();
    });
    this.addProfileConnected(addresses, 'hfp', () => {
      const profile = this.hfpProfile ?? hfp.createHfpAgProfile();
      this.hfpProfile = profile;
      return profile.getConnectedDevices();
    });
    this.addProfileConnected(addresses, 'hid', () => {
      const profile = this.hidProfile ?? hid.createHidHostProfile();
      this.hidProfile = profile;
      return profile.getConnectedDevices();
    });
    const list: string[] = [];
    addresses.forEach((id: string) => {
      list.push(id);
    });
    return new ClassicConnectedSnapshot(list, list.length, false);
  }

  isConnected(classicDeviceId: string): boolean {
    const normalized = SppSessionKey.normalizeClassicId(classicDeviceId);
    if (normalized.length === 0) {
      return false;
    }
    return this.listConnectedClassicAddresses().contains(normalized);
  }

  private addProfileConnected(
    target: Set<string>,
    profileName: string,
    fetch: () => Array<string>
  ): void {
    try {
      const devices = fetch();
      for (let i = 0; i < devices.length; i++) {
        const id = SppSessionKey.normalizeClassicId(devices[i]);
        if (id.length > 0) {
          target.add(id);
        }
      }
      if (devices.length > 0) {
        logger.info(`profile_connected profile=${profileName} count=${devices.length}`);
      }
    } catch (error) {
      const err = error as BusinessError;
      logger.warn(`profile_connected_failed profile=${profileName} code=${err.code}`);
    }
  }

  private notifyChanged(): void {
    if (this.onChanged !== undefined) {
      this.onChanged();
    }
  }

  private logAclCapabilityGapOnce(): void {
    if (PlatformConnectedClassicSource.aclGapLogged) {
      return;
    }
    PlatformConnectedClassicSource.aclGapLogged = true;
    logger.info('connected_source_unavailable reason=no_acl_api');
  }
}
