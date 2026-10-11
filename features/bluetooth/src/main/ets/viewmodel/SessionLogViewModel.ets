import { ExportBluetoothSessionLogUseCase } from 'yobluetooth';

@ObservedV2
export class SessionLogViewModel {
  @Trace lines: string[] = [];
  @Trace exportPath: string = '';
  @Trace exportError: string = '';

  private readonly exportLog: ExportBluetoothSessionLogUseCase = new ExportBluetoothSessionLogUseCase();

  async exportSession(sessionId: string): Promise<void> {
    const exported = await this.exportLog.execute(sessionId);
    if (!exported.success || exported.value === undefined) {
      this.exportError = exported.error?.message ?? '';
      this.exportPath = '';
      return;
    }
    this.exportError = '';
    this.exportPath = exported.value;
  }

  clear(): void {
    this.lines = [];
  }
}
