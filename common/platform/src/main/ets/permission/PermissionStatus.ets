/**
 * Normalized permission status for ViewModel and orchestrator.
 */
export enum PermissionStatus {
  GRANTED = 'GRANTED',
  DENIED = 'DENIED',
  DENIED_NO_DIALOG = 'DENIED_NO_DIALOG',
  NOT_REQUESTED = 'NOT_REQUESTED',
  NOT_APPLICABLE = 'NOT_APPLICABLE'
}
