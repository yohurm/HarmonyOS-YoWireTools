import { common } from '@kit.AbilityKit';
import { YoLog, YoLogTag, LogParams } from 'yolog';
import { IPermissionGateway } from './IPermissionGateway';
import { PermissionDecision } from './PermissionDecision';
import { PermissionPresentation } from './PermissionPresentation';
import { PermissionRecordStore } from './PermissionRecordStore';
import { PermissionRequestResult } from './PermissionRequestResult';
import { PermissionStatus } from './PermissionStatus';
import { PermissionUiState } from './PermissionUiState';
import { PlatformPermission } from './PlatformPermission';
import { SystemPermissionGateway } from './SystemPermissionGateway';

const logger = YoLog.tag(YoLogTag.PERM);

/**
 * Platform permission gateway — executes checks/requests; business layer supplies presentation.
 */
export class PermissionOrchestrator {
  private static instance: PermissionOrchestrator | undefined;
  private readonly gateway: IPermissionGateway;
  private readonly recordStore: PermissionRecordStore;

  private constructor(gateway: IPermissionGateway, recordStore: PermissionRecordStore) {
    this.gateway = gateway;
    this.recordStore = recordStore;
  }

  static getInstance(): PermissionOrchestrator {
    if (PermissionOrchestrator.instance === undefined) {
      PermissionOrchestrator.instance =
        new PermissionOrchestrator(new SystemPermissionGateway(), new PermissionRecordStore());
    }
    return PermissionOrchestrator.instance;
  }

  static createForTest(gateway: IPermissionGateway, recordStore: PermissionRecordStore = new PermissionRecordStore()):
    PermissionOrchestrator {
    return new PermissionOrchestrator(gateway, recordStore);
  }

  bindContext(context: common.UIAbilityContext): void {
    if (this.gateway.bindContext !== undefined) {
      this.gateway.bindContext(context);
    }
  }

  async ensurePermissions(
    permissions: PlatformPermission[],
    reason: string,
    presentation: PermissionPresentation
  ): Promise<PermissionDecision> {
    if (permissions.length === 0) {
      const uiState = this.buildUiState(permissions, [], presentation, true, false);
      return new PermissionDecision(true, presentation.scenarioId, [], uiState);
    }
    const statuses = await this.checkPermissions(permissions);
    const missing = PermissionOrchestrator.collectMissing(permissions, statuses);
    if (missing.length === 0) {
      const uiState = this.buildUiState(permissions, statuses, presentation, true, false);
      logger.params('permission_granted', LogParams.create().put('scenario', presentation.scenarioId));
      return new PermissionDecision(true, presentation.scenarioId, [], uiState);
    }
    const blocked = this.shouldBlockAutoRequest(missing);
    if (blocked) {
      const uiState = this.buildUiState(permissions, statuses, presentation, false, true);
      return new PermissionDecision(false, presentation.scenarioId, missing, uiState);
    }
    const requestResult = await this.requestFromUser(missing, reason);
    const finalStatuses = await this.checkPermissions(permissions);
    const stillMissing = PermissionOrchestrator.collectMissing(permissions, finalStatuses);
    const granted = stillMissing.length === 0;
    const shouldGuide = !granted && requestResult.dialogShown.some((shown: boolean) => shown);
    const uiState = this.buildUiState(
      permissions,
      finalStatuses,
      presentation,
      !shouldGuide && !granted,
      shouldGuide
    );
    logger.params('permission_request_result', LogParams.create()
      .put('scenario', presentation.scenarioId)
      .put('granted', granted ? 1 : 0));
    return new PermissionDecision(granted, presentation.scenarioId, stillMissing, uiState);
  }

  async checkPermission(permission: PlatformPermission): Promise<PermissionStatus> {
    return this.gateway.checkPermission(permission);
  }

  async requestFromUser(permissions: PlatformPermission[], reason: string): Promise<PermissionRequestResult> {
    const result = await this.gateway.requestFromUser(permissions, reason);
    PermissionOrchestrator.persistResults(this.recordStore, result);
    if (!result.grantedAll) {
      const needSetting = result.dialogShown.every((shown: boolean) => !shown);
      if (needSetting) {
        const settingResult = await this.gateway.openSettingGuide(permissions);
        PermissionOrchestrator.persistResults(this.recordStore, settingResult);
        return settingResult;
      }
    }
    return result;
  }

  async openSettingGuide(_permissionGroup: string): Promise<void> {
    logger.info('open_setting_guide requested');
  }

  buildUiState(
    permissions: PlatformPermission[],
    statuses: PermissionStatus[],
    presentation: PermissionPresentation,
    canRequest: boolean,
    shouldShowSettingGuide: boolean
  ): PermissionUiState {
    let title = presentation.title;
    let message = presentation.message;
    let userAction = presentation.userAction;
    if (shouldShowSettingGuide) {
      title = presentation.blockedTitle;
      message = presentation.blockedMessage;
      userAction = presentation.blockedUserAction;
      canRequest = false;
    }
    return new PermissionUiState(
      presentation.scenarioId,
      permissions,
      statuses,
      canRequest,
      shouldShowSettingGuide,
      title,
      message,
      userAction
    );
  }

  private shouldBlockAutoRequest(permissions: PlatformPermission[]): boolean {
    for (let i = 0; i < permissions.length; i++) {
      if (this.recordStore.shouldBlockAutoRequest(permissions[i])) {
        return true;
      }
    }
    return false;
  }

  private async checkPermissions(permissions: PlatformPermission[]): Promise<PermissionStatus[]> {
    const statuses: PermissionStatus[] = [];
    for (let i = 0; i < permissions.length; i++) {
      statuses.push(await this.gateway.checkPermission(permissions[i]));
    }
    return statuses;
  }

  private static collectMissing(
    permissions: PlatformPermission[],
    statuses: PermissionStatus[]
  ): PlatformPermission[] {
    const missing: PlatformPermission[] = [];
    for (let i = 0; i < permissions.length; i++) {
      if (statuses[i] !== PermissionStatus.GRANTED) {
        missing.push(permissions[i]);
      }
    }
    return missing;
  }

  private static persistResults(store: PermissionRecordStore, result: PermissionRequestResult): void {
    for (let i = 0; i < result.permissions.length; i++) {
      store.update(result.permissions[i], result.statuses[i], result.dialogShown[i]);
    }
  }
}
