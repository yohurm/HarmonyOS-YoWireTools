import { SppSessionKey } from './SppSessionKey';

/**
 * Read-model for one active SPP RFCOMM session (UI + use case output).
 */
export class SppSessionDescriptor {
  readonly sessionId: string;
  readonly transportId: string;
  readonly sessionKey: SppSessionKey;
  readonly displayName: string;
  readonly classicAddress: string;
  readonly serviceUuid: string;
  readonly uuidShortLabel: string;
  readonly stateLabel: string;
  readonly clientSocket: number;
  readonly bytesIn: number;
  readonly bytesOut: number;

  constructor(
    sessionId: string,
    transportId: string,
    sessionKey: SppSessionKey,
    displayName: string,
    classicAddress: string,
    serviceUuid: string,
    uuidShortLabel: string,
    stateLabel: string,
    clientSocket: number = -1,
    bytesIn: number = 0,
    bytesOut: number = 0
  ) {
    this.sessionId = sessionId;
    this.transportId = transportId;
    this.sessionKey = sessionKey;
    this.displayName = displayName;
    this.classicAddress = classicAddress;
    this.serviceUuid = serviceUuid;
    this.uuidShortLabel = uuidShortLabel;
    this.stateLabel = stateLabel;
    this.clientSocket = clientSocket;
    this.bytesIn = bytesIn;
    this.bytesOut = bytesOut;
  }
}
