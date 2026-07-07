import { PermissionStatus } from './PermissionStatus';
import { PlatformPermission } from './PlatformPermission';

interface PermissionRecordEntry {
  status: PermissionStatus;
  denyCount: number;
  dialogShown: boolean;
  updatedAtMs: number;
}

/**
 * In-memory permission decision history for "do not re-prompt" policy (PRD-06 §4.2).
 */
export class PermissionRecordStore {
  private readonly records: Map<PlatformPermission, PermissionRecordEntry> = new Map();

  get(permission: PlatformPermission): PermissionRecordEntry | undefined {
    return this.records.get(permission);
  }

  update(permission: PlatformPermission, status: PermissionStatus, dialogShown: boolean): void {
    const existing = this.records.get(permission);
    const denyCount = status === PermissionStatus.GRANTED ? 0 :
      (existing !== undefined ? existing.denyCount + 1 : 1);
    this.records.set(permission, {
      status,
      denyCount,
      dialogShown,
      updatedAtMs: Date.now()
    });
  }

  shouldBlockAutoRequest(permission: PlatformPermission): boolean {
    const entry = this.records.get(permission);
    if (entry === undefined) {
      return false;
    }
    if (entry.status === PermissionStatus.GRANTED) {
      return false;
    }
    return entry.dialogShown || entry.status === PermissionStatus.DENIED_NO_DIALOG;
  }

  clear(): void {
    this.records.clear();
  }
}
