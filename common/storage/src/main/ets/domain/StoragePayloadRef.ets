/**
 * Storage-layer payload reference (RDB / file metadata).
 */

export enum StoragePayloadKind {
  INLINE = 'inline',
  FILE = 'file'
}

export class StoragePayloadRef {
  readonly storageType: StoragePayloadKind;
  readonly inlineBytesBase64: string;
  readonly filePath: string;
  readonly offset: number;
  readonly length: number;
  readonly sha256: string;
  constructor(
    storageType: StoragePayloadKind,
    length: number,
    inlineBytesBase64: string = '',
    filePath: string = '',
    offset: number = 0,
    sha256: string = ''
  ) {
    this.storageType = storageType;
    this.length = length;
    this.inlineBytesBase64 = inlineBytesBase64;
    this.filePath = filePath;
    this.offset = offset;
    this.sha256 = sha256;
  }
}
