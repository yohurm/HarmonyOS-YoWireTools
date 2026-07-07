export enum NearLinkSecurityState {
  NOT_REQUIRED = 'not_required',
  UNKNOWN = 'unknown',
  PAIRING = 'pairing',
  PAIRED = 'paired',
  ENCRYPTED = 'encrypted',
  NOT_ENCRYPTED = 'not_encrypted',
  FAILED = 'failed'
}

export enum NearLinkEncryptionLabel {
  UNVERIFIED = 'encryption unverified',
  ENCRYPTED = 'encrypted',
  NOT_REQUIRED = 'encryption not required'
}
