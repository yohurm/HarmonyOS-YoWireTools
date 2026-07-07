import { PermissionStatus } from './PermissionStatus';
import { PlatformPermission } from './PlatformPermission';

/**
 * ViewModel-friendly permission presentation state.
 */
export class PermissionUiState {
  readonly scenarioId: string;
  readonly permissions: PlatformPermission[];
  readonly statuses: PermissionStatus[];
  readonly canRequest: boolean;
  readonly shouldShowSettingGuide: boolean;
  readonly title: string;
  readonly message: string;
  readonly userAction: string;

  constructor(
    scenarioId: string,
    permissions: PlatformPermission[],
    statuses: PermissionStatus[],
    canRequest: boolean,
    shouldShowSettingGuide: boolean,
    title: string,
    message: string,
    userAction: string
  ) {
    this.scenarioId = scenarioId;
    this.permissions = permissions;
    this.statuses = statuses;
    this.canRequest = canRequest;
    this.shouldShowSettingGuide = shouldShowSettingGuide;
    this.title = title;
    this.message = message;
    this.userAction = userAction;
  }
}
