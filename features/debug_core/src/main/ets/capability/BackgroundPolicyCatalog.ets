import {
  BackgroundPolicyAdvisor,
  PlatformBackgroundSessionKind
} from 'common_platform';

/**
 * Background session categories for YoWire debug sessions.
 */
export enum BackgroundSessionCategory {
  BLUETOOTH_SCAN = 'BLUETOOTH_SCAN',
  BLE_SPP_CONNECTION = 'BLE_SPP_CONNECTION',
  WIFI_SCAN = 'WIFI_SCAN',
  SOCKET_CONNECTION = 'SOCKET_CONNECTION',
  HTTP_EXPORT = 'HTTP_EXPORT',
  NEARLINK_SCAN = 'NEARLINK_SCAN',
  NEARLINK_DATA_TRANSFER = 'NEARLINK_DATA_TRANSFER',
  PERIODIC_COMMAND = 'PERIODIC_COMMAND'
}

/**
 * Recommended background handling per product policy.
 */
export enum BackgroundSessionAction {
  KEEP = 'KEEP',
  PAUSE = 'PAUSE',
  STOP = 'STOP',
  REQUEST_LONG_TASK = 'REQUEST_LONG_TASK'
}

export class BackgroundPolicyCatalog {
  static recommend(
    category: BackgroundSessionCategory,
    backgroundConnectionEnabled: boolean,
    backgroundPeriodicEnabled: boolean
  ): BackgroundSessionAction {
    switch (category) {
      case BackgroundSessionCategory.BLUETOOTH_SCAN:
      case BackgroundSessionCategory.WIFI_SCAN:
      case BackgroundSessionCategory.NEARLINK_SCAN:
        return BackgroundSessionAction.STOP;
      case BackgroundSessionCategory.BLE_SPP_CONNECTION:
      case BackgroundSessionCategory.SOCKET_CONNECTION:
        return backgroundConnectionEnabled ?
          BackgroundSessionAction.REQUEST_LONG_TASK : BackgroundSessionAction.PAUSE;
      case BackgroundSessionCategory.NEARLINK_DATA_TRANSFER:
        return backgroundConnectionEnabled ?
          BackgroundSessionAction.REQUEST_LONG_TASK : BackgroundSessionAction.PAUSE;
      case BackgroundSessionCategory.HTTP_EXPORT:
        return BackgroundSessionAction.KEEP;
      case BackgroundSessionCategory.PERIODIC_COMMAND:
        return backgroundPeriodicEnabled ?
          BackgroundSessionAction.REQUEST_LONG_TASK : BackgroundSessionAction.STOP;
      default:
        return BackgroundSessionAction.PAUSE;
    }
  }

  static platformKind(category: BackgroundSessionCategory): PlatformBackgroundSessionKind {
    switch (category) {
      case BackgroundSessionCategory.BLUETOOTH_SCAN:
      case BackgroundSessionCategory.WIFI_SCAN:
      case BackgroundSessionCategory.NEARLINK_SCAN:
        return PlatformBackgroundSessionKind.SCAN;
      case BackgroundSessionCategory.BLE_SPP_CONNECTION:
      case BackgroundSessionCategory.SOCKET_CONNECTION:
      case BackgroundSessionCategory.NEARLINK_DATA_TRANSFER:
        return PlatformBackgroundSessionKind.CONNECTION;
      case BackgroundSessionCategory.PERIODIC_COMMAND:
        return PlatformBackgroundSessionKind.PERIODIC;
      case BackgroundSessionCategory.HTTP_EXPORT:
        return PlatformBackgroundSessionKind.EXPORT;
      default:
        return PlatformBackgroundSessionKind.CONNECTION;
    }
  }

  static resolve(
    category: BackgroundSessionCategory,
    backgroundConnectionEnabled: boolean,
    backgroundPeriodicEnabled: boolean
  ): BackgroundSessionAction {
    const catalogAction = BackgroundPolicyCatalog.recommend(
      category,
      backgroundConnectionEnabled,
      backgroundPeriodicEnabled
    );
    const platformAction = BackgroundPolicyAdvisor.resolveAction(BackgroundPolicyCatalog.platformKind(category));
    return BackgroundPolicyCatalog.mergeActions(catalogAction, platformAction as BackgroundSessionAction);
  }

  static mergeActions(
    catalogAction: BackgroundSessionAction,
    platformAction: BackgroundSessionAction
  ): BackgroundSessionAction {
    return BackgroundPolicyCatalog.actionRank(catalogAction) >= BackgroundPolicyCatalog.actionRank(platformAction) ?
      catalogAction : platformAction;
  }

  private static actionRank(action: BackgroundSessionAction): number {
    switch (action) {
      case BackgroundSessionAction.STOP:
        return 4;
      case BackgroundSessionAction.PAUSE:
        return 3;
      case BackgroundSessionAction.REQUEST_LONG_TASK:
        return 2;
      case BackgroundSessionAction.KEEP:
        return 1;
      default:
        return 0;
    }
  }
}
