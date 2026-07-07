export enum WifiScanPhase {
  IDLE = 'idle',
  CHECKING_PERMISSION = 'checkingPermission',
  CHECKING_CAPABILITY = 'checkingCapability',
  COOLING_DOWN = 'coolingDown',
  ACTIVE_SCANNING = 'activeScanning',
  READING_CACHE = 'readingCache',
  COMPLETED = 'completed',
  LIMITED = 'limited',
  FAILED = 'failed'
}

export enum WifiScanSource {
  ACTIVE_SCAN = 'activeScan',
  CACHE = 'cache'
}

export enum BssidMaskReason {
  PERMISSION_DENIED = 'permissionDenied',
  UNAVAILABLE = 'unavailable',
  HIDDEN = 'hidden'
}
