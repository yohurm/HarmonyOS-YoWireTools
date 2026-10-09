import { Result, ResultError } from 'common_core';
import { EnsurePermissionUseCase, PermissionScenario } from 'debug_core';
import { WifiNetworkConstants } from '../../constants/WifiNetworkConstants';
import { WifiNetworkErrorCodes } from '../../constants/WifiNetworkErrorCodes';
import { WifiCandidateDraft, WifiScanBatch } from '../model/WifiDebugFacts';
import { WifiNetworkRepositoryContract } from '../repository/WifiNetworkRepositoryContract';
import { WifiCandidateRejection, WifiCandidateRules } from '../service/WifiCandidateRules';
import { WifiScanLogger } from '../service/WifiScanLogger';

export class WifiDebugUseCases {
  private readonly repository: WifiNetworkRepositoryContract;
  private readonly ensurePermission: EnsurePermissionUseCase;

  constructor(
    repository: WifiNetworkRepositoryContract,
    ensurePermission: EnsurePermissionUseCase = new EnsurePermissionUseCase()
  ) {
    this.repository = repository;
    this.ensurePermission = ensurePermission;
  }

  repositoryContract(): WifiNetworkRepositoryContract {
    return this.repository;
  }

  async openPage(): Promise<Result<void>> {
    const info = await this.ensurePermission.execute(PermissionScenario.WIFI_INFO);
    const control = await this.ensurePermission.execute(PermissionScenario.WIFI_CONTROL);
    const network = await this.ensurePermission.execute(PermissionScenario.NETWORK_INFO);
    const access = await this.ensurePermission.execute(PermissionScenario.NETWORK_ACCESS);
    if (!info.granted || !control.granted || !network.granted || !access.granted) {
      await WifiScanLogger.log('', 'action=openWifiDebug result=declarationMismatch');
      return Result.fail(new ResultError(
        WifiNetworkErrorCodes.NO_WIFI_INFO,
        '权限被拒绝',
        undefined,
        {},
        WifiNetworkConstants.NATIVE_PERMISSION_DENIED
      ));
    }
    await WifiScanLogger.log('', 'action=openWifiDebug result=noRuntimeDialog');
    return Result.ok(undefined);
  }

  async startScan(peersMacGranted: boolean, foreground: boolean, paused: boolean): Promise<Result<WifiScanBatch>> {
    if (paused) {
      await WifiScanLogger.log('', 'action=pauseScan result=paused');
      return Result.fail(new ResultError(WifiNetworkErrorCodes.SCAN_COOLDOWN, '已暂停'));
    }
    const control = await this.ensurePermission.execute(PermissionScenario.WIFI_CONTROL);
    if (!control.granted) {
      await WifiScanLogger.log('', 'action=startScan result=permissionDenied');
      return Result.fail(new ResultError(
        WifiNetworkErrorCodes.NO_WIFI_INFO,
        '权限被拒绝',
        undefined,
        {},
        WifiNetworkConstants.NATIVE_PERMISSION_DENIED
      ));
    }
    const scan = await this.repository.runForegroundScan(peersMacGranted, foreground);
    const resultName = scan.success ? 'success' : (scan.error !== undefined ? scan.error.message : 'failed');
    await WifiScanLogger.log('', `action=startScan result=${resultName}`, scan.error !== undefined ? scan.error.nativeCode : '');
    return scan;
  }

  async refreshCache(peersMacGranted: boolean): Promise<Result<WifiScanBatch>> {
    const info = await this.ensurePermission.execute(PermissionScenario.WIFI_INFO);
    if (!info.granted) {
      return Result.fail(new ResultError(
        WifiNetworkErrorCodes.NO_WIFI_INFO,
        '权限被拒绝',
        undefined,
        {},
        WifiNetworkConstants.NATIVE_PERMISSION_DENIED
      ));
    }
    const cache = await this.repository.refreshScanCache(peersMacGranted);
    await WifiScanLogger.log('', 'action=refreshCache result=cache');
    return cache;
  }

  async connectCandidate(draft: WifiCandidateDraft): Promise<Result<string>> {
    const rejected: WifiCandidateRejection | undefined = WifiCandidateRules.validate(draft);
    if (rejected !== undefined) {
      await WifiScanLogger.log('', `action=connectCandidate result=rejected`, rejected.nativeCode);
      return Result.fail(new ResultError(
        WifiNetworkErrorCodes.SCAN_LIMITED,
        rejected.message,
        undefined,
        {},
        rejected.nativeCode
      ));
    }
    const control = await this.ensurePermission.execute(PermissionScenario.WIFI_CONTROL);
    if (!control.granted) {
      return Result.fail(new ResultError(
        WifiNetworkErrorCodes.NO_WIFI_INFO,
        '权限被拒绝',
        undefined,
        {},
        WifiNetworkConstants.NATIVE_PERMISSION_DENIED
      ));
    }
    let networkId = draft.networkId;
    if (networkId < 0) {
      const added = await this.repository.addCandidate(draft);
      if (!added.success || added.value === undefined) {
        return Result.fail(added.error ?? new ResultError(WifiNetworkErrorCodes.SCAN_LIMITED, '添加失败'));
      }
      networkId = added.value;
    }
    if (draft.useUserAction) {
      const connected = await this.repository.connectCandidateWithUserAction(networkId);
      if (!connected.success) {
        return Result.fail(connected.error ?? new ResultError(WifiNetworkErrorCodes.SCAN_LIMITED, '连接失败'));
      }
      await WifiScanLogger.log('', 'action=connectCandidate result=userActionStarted');
      return Result.ok(`${networkId}`);
    }
    const connected = this.repository.connectCandidate(networkId);
    if (!connected.success) {
      return Result.fail(connected.error ?? new ResultError(WifiNetworkErrorCodes.SCAN_LIMITED, '连接失败'));
    }
    await WifiScanLogger.log('', 'action=connectCandidate result=started');
    return Result.ok(`${networkId}`);
  }

  async removeCandidate(networkId: number): Promise<Result<void>> {
    return this.repository.removeCandidate(networkId);
  }
}
