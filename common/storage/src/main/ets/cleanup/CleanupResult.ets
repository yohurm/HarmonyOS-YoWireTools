/**
 * Cleanup operation summary.
 */
export class CleanupResult {
  readonly deletedLogs: number;
  readonly deletedFiles: number;
  readonly freedBytes: number;

  constructor(deletedLogs: number, deletedFiles: number, freedBytes: number) {
    this.deletedLogs = deletedLogs;
    this.deletedFiles = deletedFiles;
    this.freedBytes = freedBytes;
  }
}
