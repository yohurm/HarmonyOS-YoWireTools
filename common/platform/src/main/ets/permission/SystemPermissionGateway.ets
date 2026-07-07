import { abilityAccessCtrl, bundleManager, common } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { IPermissionGateway } from './IPermissionGateway';
import { PermissionRequestResult } from './PermissionRequestResult';
import { PermissionStatus } from './PermissionStatus';
import { PlatformPermission } from './PlatformPermission';
import { AppLogger } from '../logging/AppLogger';
import { AppLogTag } from '../logging/AppLogTag';

const logger = new AppLogger(AppLogTag.PERM);

/**
 * Production permission gateway using HarmonyOS abilityAccessCtrl APIs.
 * Flow: checkAccessTokenSync -> requestPermissionsFromUser -> requestPermissionOnSetting.
 */
export class SystemPermissionGateway implements IPermissionGateway {
  private context: common.UIAbilityContext | undefined;
  private accessTokenId: number = -1;

  bindContext(context: common.UIAbilityContext): void {
    this.context = context;
    this.refreshAccessTokenId();
  }

  async checkPermission(permission: PlatformPermission): Promise<PermissionStatus> {
    const tokenId = this.ensureTokenId();
    if (tokenId < 0) {
      return PermissionStatus.NOT_REQUESTED;
    }
    try {
      const atManager = abilityAccessCtrl.createAtManager();
      const grant = atManager.checkAccessTokenSync(tokenId, permission);
      if (grant === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED) {
        return PermissionStatus.GRANTED;
      }
      return PermissionStatus.NOT_REQUESTED;
    } catch (error) {
      const err = error as BusinessError;
      logger.error(`checkPermission failed, code=${err.code}, message=${err.message}`);
      return PermissionStatus.NOT_REQUESTED;
    }
  }

  async requestFromUser(permissions: PlatformPermission[], _reason: string): Promise<PermissionRequestResult> {
    if (this.context === undefined) {
      return SystemPermissionGateway.buildDeniedResult(permissions, false);
    }
    try {
      const atManager = abilityAccessCtrl.createAtManager();
      const response = await atManager.requestPermissionsFromUser(this.context, permissions);
      return SystemPermissionGateway.mapRequestResult(permissions, response.authResults, response.dialogShownResults);
    } catch (error) {
      const err = error as BusinessError;
      logger.error(`requestFromUser failed, code=${err.code}, message=${err.message}`);
      return SystemPermissionGateway.buildDeniedResult(permissions, false);
    }
  }

  async openSettingGuide(permissions: PlatformPermission[]): Promise<PermissionRequestResult> {
    if (this.context === undefined) {
      return SystemPermissionGateway.buildDeniedResult(permissions, false);
    }
    try {
      const atManager = abilityAccessCtrl.createAtManager();
      const statuses = await atManager.requestPermissionOnSetting(this.context, permissions);
      const authResults: number[] = [];
      for (let i = 0; i < statuses.length; i++) {
        authResults.push(statuses[i] === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED ? 0 : -1);
      }
      const dialogShown = new Array<boolean>(permissions.length);
      for (let i = 0; i < dialogShown.length; i++) {
        dialogShown[i] = true;
      }
      return SystemPermissionGateway.mapRequestResult(permissions, authResults, dialogShown);
    } catch (error) {
      const err = error as BusinessError;
      logger.error(`openSettingGuide failed, code=${err.code}, message=${err.message}`);
      return SystemPermissionGateway.buildDeniedResult(permissions, true);
    }
  }

  private ensureTokenId(): number {
    if (this.accessTokenId >= 0) {
      return this.accessTokenId;
    }
    this.refreshAccessTokenId();
    return this.accessTokenId;
  }

  private refreshAccessTokenId(): void {
    try {
      const bundleInfo = bundleManager.getBundleInfoForSelfSync(bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION);
      this.accessTokenId = bundleInfo.appInfo.accessTokenId;
    } catch (error) {
      const err = error as BusinessError;
      logger.error(`refreshAccessTokenId failed, code=${err.code}, message=${err.message}`);
      this.accessTokenId = -1;
    }
  }

  private static mapRequestResult(
    permissions: PlatformPermission[],
    authResults: Array<number>,
    dialogShownResults?: Array<boolean>
  ): PermissionRequestResult {
    const statuses: PermissionStatus[] = [];
    let grantedAll = true;
    const dialogShown: boolean[] = [];
    for (let i = 0; i < permissions.length; i++) {
      const granted = authResults[i] === 0;
      const shown = dialogShownResults !== undefined ? dialogShownResults[i] : false;
      dialogShown.push(shown);
      if (granted) {
        statuses.push(PermissionStatus.GRANTED);
      } else if (shown) {
        statuses.push(PermissionStatus.DENIED);
        grantedAll = false;
      } else {
        statuses.push(PermissionStatus.DENIED_NO_DIALOG);
        grantedAll = false;
      }
    }
    return new PermissionRequestResult(permissions, statuses, grantedAll, dialogShown);
  }

  private static buildDeniedResult(permissions: PlatformPermission[], dialogShown: boolean): PermissionRequestResult {
    const statuses: PermissionStatus[] = [];
    for (let i = 0; i < permissions.length; i++) {
      statuses.push(dialogShown ? PermissionStatus.DENIED : PermissionStatus.DENIED_NO_DIALOG);
    }
    const dialogFlags = new Array<boolean>(permissions.length);
    for (let i = 0; i < dialogFlags.length; i++) {
      dialogFlags[i] = dialogShown;
    }
    return new PermissionRequestResult(permissions, statuses, false, dialogFlags);
  }
}
