import { Result } from 'common_core';
import { CapabilityRegistry } from 'common_platform';
import { CreateSessionInput, DebugSession } from '../domain/model/DebugSession';
import { SessionManager } from '../service/SessionManager';
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

  constructor(coordinator: PermissionScenarioCoordinator = PermissionScenarioCoordinator.getInstance()) {
    this.coordinator = coordinator;
  }

  async execute(scenario: PermissionScenario) {
    return this.coordinator.ensurePermission(scenario);
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
