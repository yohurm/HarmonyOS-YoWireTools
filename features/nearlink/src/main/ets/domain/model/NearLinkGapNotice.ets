/**
 * A kit boundary the page must show. There is no success flag.
 */
export class NearLinkGapNotice {
  readonly kind: string;
  readonly openSettings: boolean;
  readonly nativeCode: string;

  constructor(kind: string, openSettings: boolean, nativeCode: string = '') {
    this.kind = kind;
    this.openSettings = openSettings;
    this.nativeCode = nativeCode;
  }
}
