import { NearLinkSecurityState } from './NearLinkSecurityState';

export class ConnectDataTransferResult {
  readonly sessionId: string;
  readonly securityState: NearLinkSecurityState;

  constructor(sessionId: string, securityState: NearLinkSecurityState) {
    this.sessionId = sessionId;
    this.securityState = securityState;
  }
}
