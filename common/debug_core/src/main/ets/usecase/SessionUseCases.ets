import { IdGenerator, Result, TimeUtil } from 'common_core';
import { CapabilityRegistry, PermissionDecision } from 'common_platform';
import { CreateSessionInput, DebugSession } from '../domain/model/DebugSession';
import { DebugEvent } from '../domain/model/DebugEvent';
import {
  ErrorSeverity,
  LogRecordType,
  ModuleType
} from '../domain/enums/DomainEnums';
import { SessionManager } from '../service/SessionManager';
import { LogCaptureService } from '../service/LogCaptureService';
import { SessionRuntimeStore } from '../runtime/SessionRuntimeStore';
import { PermissionScenario } from '../capability/PermissionScenario';
import { PermissionScenarioCoordinator } from '../capability/PermissionScenarioCoordinator';

export class CreateSessionUseCase {
  private readonly sessionManager: SessionManager;

  constructor(sessionManager: SessionManager = SessionManager.getInstance()) {
    this.sessionManager = sessionManager;
  }

  async execute(input: CreateSessionInput): Promise<Result<DebugSession>> {
    return this.sessionManager.createSession(input);
  }
}

export class StartSessionUseCase {
  private readonly sessionManager: SessionManager;

  constructor(sessionManager: SessionManager = SessionManager.getInstance()) {
    this.sessionManager = sessionManager;
  }

  async execute(sessionId: string): Promise<Result<void>> {
    return this.sessionManager.startSession(sessionId);
  }
}

export class StopSessionUseCase {
  private readonly sessionManager: SessionManager;

  constructor(sessionManager: SessionManager = SessionManager.getInstance()) {
    this.sessionManager = sessionManager;
  }

  async execute(sessionId: string, reason: string = 'user_stop'): Promise<Result<void>> {
    return this.sessionManager.stopSession(sessionId, reason);
  }
}

export class EnsurePermissionUseCase {
  private readonly coordinator: PermissionScenarioCoordinator;
  private readonly logCapture: LogCaptureService;
  private readonly runtimeStore: SessionRuntimeStore;

  constructor(
    coordinator: PermissionScenarioCoordinator = PermissionScenarioCoordinator.getInstance(),
    logCapture: LogCaptureService = LogCaptureService.getInstance(),
    runtimeStore: SessionRuntimeStore = SessionRuntimeStore.getInstance()
  ) {
    this.coordinator = coordinator;
    this.logCapture = logCapture;
    this.runtimeStore = runtimeStore;
  }

  async execute(scenario: PermissionScenario): Promise<PermissionDecision> {
    const decision = await this.coordinator.ensurePermission(scenario);
    await this.capturePermissionResult(scenario, decision);
    return decision;
  }

  /**
   * Bypass: when an active debug session exists, write PERMISSION evidence into session logs.
   * No active session → keep platform YoLog only (no forced session coupling).
   */
  private async capturePermissionResult(
    scenario: PermissionScenario,
    decision: PermissionDecision
  ): Promise<void> {
    const summaries = this.runtimeStore.listActiveSummaries();
    if (summaries.length === 0) {
      return;
    }
    const appCode = decision.granted ? '' : EnsurePermissionUseCase.appCodeFor(scenario);
    const resultLabel = decision.granted ? 'granted' : 'denied';
    const summary = `permission:${scenario} ${resultLabel} appCode=${appCode}`;
    const attrs: Record<string, string | number | boolean> = {};
    attrs['scenario'] = `${scenario}`;
    attrs['granted'] = decision.granted;
    attrs['appCode'] = appCode;
    attrs['missingCount'] = decision.missingPermissions.length;
    const severity = decision.granted ? ErrorSeverity.INFO : ErrorSeverity.WARNING;
    for (let i = 0; i < summaries.length; i++) {
      const session = this.runtimeStore.getSession(summaries[i].id);
      const moduleType = session?.module ?? ModuleType.SYSTEM;
      const event = new DebugEvent(
        IdGenerator.next('evt'),
        summaries[i].id,
        moduleType,
        LogRecordType.PERMISSION,
        'internal',
        TimeUtil.nowMs(),
        severity,
        summary,
        undefined,
        '',
        appCode,
        attrs
      );
      await this.logCapture.captureEvent(event);
    }
  }

  private static appCodeFor(scenario: PermissionScenario): string {
    switch (scenario) {
      case PermissionScenario.BLUETOOTH_SCAN_CONNECT:
        return 'YW-PERM-1001';
      case PermissionScenario.BLUETOOTH_PERSISTENT_MAC:
        return 'YW-PERM-1002';
      case PermissionScenario.BLUETOOTH_BACKGROUND:
        return 'YW-PERM-1003';
      case PermissionScenario.NETWORK_ACCESS:
        return 'YW-PERM-2001';
      case PermissionScenario.WIFI_INFO:
      case PermissionScenario.WIFI_CONTROL:
        return 'YW-PERM-2002';
      case PermissionScenario.WIFI_PEERS_MAC:
        return 'YW-PERM-2003';
      case PermissionScenario.NEARLINK_ACCESS:
        return 'YW-PERM-3001';
      case PermissionScenario.NETWORK_INFO:
        return 'YW-PERM-2001';
      default:
        return '';
    }
  }
}

export class ResolveCapabilityUseCase {
  private readonly registry: CapabilityRegistry;

  constructor(registry: CapabilityRegistry = CapabilityRegistry.getInstance()) {
    this.registry = registry;
  }

  async execute(capabilityId: string) {
    return this.registry.probe(capabilityId);
  }
}
