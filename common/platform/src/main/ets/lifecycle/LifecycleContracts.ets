import { PlatformEvent } from './PlatformEvent';

/**
 * Listener for lifecycle and platform switch events.
 */
export type LifecycleListener = (event: PlatformEvent) => void;

/**
 * Reconcile callback invoked when app returns foreground (architecture §9.1 step 5).
 */
export type ReconcileCallback = () => Promise<void>;
