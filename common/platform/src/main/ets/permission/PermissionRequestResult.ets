import { PermissionStatus } from './PermissionStatus';
import { PlatformPermission } from './PlatformPermission';

/**
 * Raw result from system permission request APIs.
 */
export class PermissionRequestResult {
  readonly permissions: PlatformPermission[];
  readonly statuses: PermissionStatus[];
  readonly grantedAll: boolean;
  readonly dialogShown: boolean[];

  constructor(
    permissions: PlatformPermission[],
    statuses: PermissionStatus[],
    grantedAll: boolean,
    dialogShown: boolean[]
  ) {
    this.permissions = permissions;
    this.statuses = statuses;
    this.grantedAll = grantedAll;
    this.dialogShown = dialogShown;
  }
}
