import { PermissionPresentation } from './PermissionPresentation';
import { PermissionUiState } from './PermissionUiState';
import { PlatformPermission } from './PlatformPermission';

/**
 * Result of ensurePermissions for UseCase boundaries.
 */
export class PermissionDecision {
  readonly granted: boolean;
  readonly scenarioId: string;
  readonly missingPermissions: PlatformPermission[];
  readonly uiState: PermissionUiState;

  constructor(
    granted: boolean,
    scenarioId: string,
    missingPermissions: PlatformPermission[],
    uiState: PermissionUiState
  ) {
    this.granted = granted;
    this.scenarioId = scenarioId;
    this.missingPermissions = missingPermissions;
    this.uiState = uiState;
  }
}
