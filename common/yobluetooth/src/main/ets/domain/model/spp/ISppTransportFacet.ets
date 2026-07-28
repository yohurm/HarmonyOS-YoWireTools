import { ITransportSession } from 'debug_core';
import { SppReadStrategy } from '../SppRuntimeState';
import { SppSessionKey } from '../SppSessionKey';

/**
 * Domain-facing SPP transport facet (architecture bluetooth/02 §4.3).
 * UseCases/Catalog must depend on this — not concrete SppTransportSession.
 */
export interface ISppTransportFacet {
  /** Brand so domain can type-guard without `instanceof` concrete transport. */
  readonly sppFacetBrand: 'spp';

  getSessionKey(): SppSessionKey | undefined;

  getClientSocketId(): number;

  getReadStrategy(): SppReadStrategy;

  /** Stop in-flight reconnect delay / retries (user disconnect or fail teardown). */
  cancelReconnect(): void;

  /** Transition to FAILED without performing registry/session teardown. */
  notifyFailed(reason: string): void;

  /** Coordinator-bound reopen after link loss (sole reconnect action). */
  reopenForReconnect(): Promise<void>;
}

/**
 * Duck-type guard: registry returns ITransportSession; SPP sessions brand themselves.
 */
export function asSppTransportFacet(
  transport: ITransportSession | Object | undefined
): ISppTransportFacet | undefined {
  if (transport === undefined) {
    return undefined;
  }
  const candidate = transport as ISppTransportFacet;
  if (candidate.sppFacetBrand === 'spp') {
    return candidate;
  }
  return undefined;
}
