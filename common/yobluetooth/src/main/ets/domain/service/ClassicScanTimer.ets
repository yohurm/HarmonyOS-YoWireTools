import { BluetoothConstants } from '../../constants/BluetoothConstants';

type ScanTimeoutListener = (remainingMs: number) => void;
type ScanTimeoutCallback = () => void;

/**
 * Classic discovery 12-second countdown per WSL and architecture bluetooth/01-§1.4.
 */
export class ClassicScanTimer {
  private timerId: number = -1;
  private startedAtMs: number = 0;
  private listener: ScanTimeoutListener | undefined;
  private onTimeout: ScanTimeoutCallback | undefined;

  start(onTimeout: ScanTimeoutCallback, listener?: ScanTimeoutListener): void {
    this.stop();
    this.onTimeout = onTimeout;
    this.listener = listener;
    this.startedAtMs = Date.now();
    this.timerId = setInterval(() => {
      const elapsed = Date.now() - this.startedAtMs;
      const remaining = BluetoothConstants.CLASSIC_DISCOVERY_TIMEOUT_MS - elapsed;
      if (this.listener !== undefined) {
        this.listener(remaining > 0 ? remaining : 0);
      }
      if (remaining <= 0) {
        this.stop();
        if (this.onTimeout !== undefined) {
          this.onTimeout();
        }
      }
    }, 500);
  }

  stop(): void {
    if (this.timerId >= 0) {
      clearInterval(this.timerId);
      this.timerId = -1;
    }
    this.onTimeout = undefined;
    this.listener = undefined;
  }

  getRemainingMs(): number {
    const elapsed = Date.now() - this.startedAtMs;
    const remaining = BluetoothConstants.CLASSIC_DISCOVERY_TIMEOUT_MS - elapsed;
    return remaining > 0 ? remaining : 0;
  }
}
