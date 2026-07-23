/**
 * Log payload reference — domain concept for inline or file-backed bytes.
 */
export enum PayloadRefKind {
  INLINE = 'inline',
  FILE = 'file'
}

export class PayloadRef {
  readonly kind: PayloadRefKind;
  readonly inlineBytesBase64: string;
  readonly filePath: string;
  readonly offset: number;
  readonly length: number;
  readonly sha256: string;

  constructor(
    kind: PayloadRefKind,
    length: number,
    inlineBytesBase64: string = '',
    filePath: string = '',
    offset: number = 0,
    sha256: string = ''
  ) {
    this.kind = kind;
    this.length = length;
    this.inlineBytesBase64 = inlineBytesBase64;
    this.filePath = filePath;
    this.offset = offset;
    this.sha256 = sha256;
  }
}
