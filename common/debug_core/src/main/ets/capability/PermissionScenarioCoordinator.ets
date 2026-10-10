import {
  PermissionDecision,
  PermissionOrchestrator,
  PermissionStatus,
  PermissionUiState
} from 'common_platform';
import { PermissionScenarioCatalog } from './PermissionScenarioCatalog';
import { PermissionScenario } from './PermissionScenario';

/**
 * Business-facing permission coordinator; platform gateway executes requests only.
 */
export class PermissionScenarioCoordinator {
  private static instance: PermissionScenarioCoordinator | undefined;
  private readonly orchestrator: PermissionOrchestrator;

  private constructor(orchestrator: PermissionOrchestrator = PermissionOrchestrator.getInstance()) {
    this.orchestrator = orchestrator;
  }

  static getInstance(): PermissionScenarioCoordinator {
    if (PermissionScenarioCoordinator.instance === undefined) {
      PermissionScenarioCoordinator.instance = new PermissionScenarioCoordinator();
    }
    return PermissionScenarioCoordinator.instance;
  }

  async ensurePermission(scenario: PermissionScenario): Promise<PermissionDecision> {
    const permissions = PermissionScenarioCatalog.permissionsFor(scenario);
    const presentation = PermissionScenarioCatalog.presentationFor(scenario);
    const reason = PermissionScenarioCatalog.reasonFor(scenario);
    return this.orchestrator.ensurePermissions(permissions, reason, presentation);
  }

  /**
   * Read-only check. Does not call requestPermissionsFromUser.
   */
  async checkGranted(scenario: PermissionScenario): Promise<boolean> {
    const permissions = PermissionScenarioCatalog.permissionsFor(scenario);
    for (let i = 0; i < permissions.length; i++) {
      const status = await this.orchestrator.checkPermission(permissions[i]);
      if (status !== PermissionStatus.GRANTED) {
        return false;
      }
    }
    return true;
  }

  async buildUiStateForScenario(scenario: PermissionScenario): Promise<PermissionUiState> {
    const permissions = PermissionScenarioCatalog.permissionsFor(scenario);
    const statuses: PermissionStatus[] = [];
    for (let i = 0; i < permissions.length; i++) {
      statuses.push(await this.orchestrator.checkPermission(permissions[i]));
    }
    const presentation = PermissionScenarioCatalog.presentationFor(scenario);
    const missing = permissions.filter((_p, index) => statuses[index] !== PermissionStatus.GRANTED);
    const shouldGuide = missing.length > 0;
    return this.orchestrator.buildUiState(permissions, statuses, presentation, !shouldGuide, shouldGuide);
  }
}
