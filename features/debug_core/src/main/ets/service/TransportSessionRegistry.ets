import { ITransportSession } from '../transport/TransportContracts';
import { TransportLogBinder } from './TransportLogBinder';

/**
 * Active transport sessions keyed by debug session id.
 * Owns TransportLogBinder lifecycle per architecture §5.4.
 */
export class TransportSessionRegistry {
  private static instance: TransportSessionRegistry | undefined;
  private readonly transports: Map<string, ITransportSession> = new Map();
  private readonly unbindHandlers: Map<string, () => void> = new Map();
  private readonly logBinder: TransportLogBinder;

  private constructor(logBinder: TransportLogBinder = new TransportLogBinder()) {
    this.logBinder = logBinder;
  }

  static getInstance(): TransportSessionRegistry {
    if (TransportSessionRegistry.instance === undefined) {
      TransportSessionRegistry.instance = new TransportSessionRegistry();
    }
    return TransportSessionRegistry.instance;
  }

  register(sessionId: string, transport: ITransportSession): void {
    const existing = this.transports.get(sessionId);
    if (existing !== undefined && existing.id !== transport.id) {
      this.releaseBinding(sessionId);
      existing.destroy();
    }
    this.releaseBinding(sessionId);
    this.transports.set(sessionId, transport);
    this.unbindHandlers.set(sessionId, this.logBinder.bind(sessionId, transport));
  }

  get(sessionId: string): ITransportSession | undefined {
    return this.transports.get(sessionId);
  }

  remove(sessionId: string): void {
    this.releaseBinding(sessionId);
    const transport = this.transports.get(sessionId);
    if (transport !== undefined) {
      transport.destroy();
      this.transports.delete(sessionId);
    }
  }

  clear(): void {
    this.unbindHandlers.forEach((unbind: () => void) => {
      unbind();
    });
    this.unbindHandlers.clear();
    this.transports.forEach((transport: ITransportSession) => {
      transport.destroy();
    });
    this.transports.clear();
  }

  listSessionIds(): string[] {
    const ids: string[] = [];
    this.transports.forEach((_transport: ITransportSession, sessionId: string) => {
      ids.push(sessionId);
    });
    return ids;
  }

  private releaseBinding(sessionId: string): void {
    const unbind = this.unbindHandlers.get(sessionId);
    if (unbind !== undefined) {
      unbind();
      this.unbindHandlers.delete(sessionId);
    }
  }
}
