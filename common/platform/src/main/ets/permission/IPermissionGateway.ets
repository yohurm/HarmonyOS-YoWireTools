import { PlatformPermission } from './PlatformPermission';
import { PermissionStatus } from './PermissionStatus';
import { PermissionRequestResult } from './PermissionRequestResult';

/**
 * Abstraction over abilityAccessCtrl for testability.
 */
export interface IPermissionGateway {
  checkPermission(permission: PlatformPermission): Promise<PermissionStatus>;
  requestFromUser(permissions: PlatformPermission[], reason: string): Promise<PermissionRequestResult>;
  openSettingGuide(permissions: PlatformPermission[]): Promise<PermissionRequestResult>;
  bindContext?(_context: Object): void;
}
