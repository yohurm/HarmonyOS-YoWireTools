/**
 * Minimal contract to break circular dependency between token and source.
 */
export interface ICancellationSource {
  readonly isCancelled: boolean;
  register(listener: () => void): () => void;
}
