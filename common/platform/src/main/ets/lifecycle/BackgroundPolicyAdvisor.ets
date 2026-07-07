import { AppLifecycleState } from './AppLifecycleState';
import { LifecycleCoordinator } from './LifecycleCoordinator';

/**
 * Generic background action recommendation for lifecycle coordinator.
 */
export enum BackgroundSessionAction {
  KEEP = 'KEEP',
  PAUSE = 'PAUSE',
  STOP = 'STOP',
  REQUEST_LONG_TASK = 'REQUEST_LONG_TASK'
}

export enum PlatformBackgroundSessionKind {
  SCAN = 'scan',
  CONNECTION = 'connection',
  PERIODIC = 'periodic',
  EXPORT = 'export'
}

/**
 * Runtime background policy advisor — queries lifecycle coordinator and user settings.
 */
export class BackgroundPolicyAdvisor {
  static resolveAction(kind: PlatformBackgroundSessionKind): BackgroundSessionAction {
    const lifecycle = LifecycleCoordinator.getInstance();
    if (lifecycle.state === AppLifecycleState.FOREGROUND) {
      return BackgroundSessionAction.KEEP;
    }
    switch (kind) {
      case PlatformBackgroundSessionKind.SCAN:
        return BackgroundSessionAction.STOP;
      case PlatformBackgroundSessionKind.CONNECTION:
        return lifecycle.backgroundConnectionEnabled ?
          BackgroundSessionAction.REQUEST_LONG_TASK : BackgroundSessionAction.PAUSE;
      case PlatformBackgroundSessionKind.PERIODIC:
        return lifecycle.backgroundPeriodicEnabled ?
          BackgroundSessionAction.REQUEST_LONG_TASK : BackgroundSessionAction.STOP;
      case PlatformBackgroundSessionKind.EXPORT:
        return BackgroundSessionAction.KEEP;
      default:
        return BackgroundSessionAction.PAUSE;
    }
  }

  static shouldPausePolling(): boolean {
    return LifecycleCoordinator.getInstance().state === AppLifecycleState.BACKGROUND;
  }

  static passthrough(action: BackgroundSessionAction): BackgroundSessionAction {
    return action;
  }
}
