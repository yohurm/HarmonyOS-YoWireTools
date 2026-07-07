export enum ClassicScanPhase {
  IDLE = 'idle',
  CHECKING_PERMISSION = 'checkingPermission',
  CHECKING_ADAPTER = 'checkingAdapter',
  CHECKING = 'checking',
  BLOCKED = 'blocked',
  SCANNING = 'scanning',
  STOPPING = 'stopping',
  COMPLETED = 'completed',
  FAILED = 'failed'
}