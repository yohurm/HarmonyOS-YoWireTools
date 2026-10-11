export enum NearLinkRadioCode {
  TURNING_ON = 0,
  ON = 1,
  TURNING_OFF = 2,
  OFF = 3,
  UNKNOWN = -1
}

export class NearLinkSupportQuery {
  readonly supported: boolean;

  constructor(supported: boolean) {
    this.supported = supported;
  }
}

export class NearLinkRadioSnapshot {
  readonly code: NearLinkRadioCode;

  constructor(code: NearLinkRadioCode) {
    this.code = code;
  }
}

export class NearLinkPairingNotice {
  readonly address: string;
  readonly stateToken: string;
  readonly reasonToken: string;
  readonly reasonMsg: string;

  constructor(address: string, stateToken: string, reasonToken: string, reasonMsg: string) {
    this.address = address;
    this.stateToken = stateToken;
    this.reasonToken = reasonToken;
    this.reasonMsg = reasonMsg;
  }
}
