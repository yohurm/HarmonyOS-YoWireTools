export enum BleScanPhase {
  IDLE = 'idle',
  CHECKING_PERMISSION = 'checkingPermission',
  SELECTING_API = 'selectingApi',
  CHECKING = 'checking',
  SCANNING = 'scanning',
  STOPPING = 'stopping',
  COMPLETED = 'completed',
  FAILED = 'failed'
}