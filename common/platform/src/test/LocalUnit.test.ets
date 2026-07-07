import { describe, it, expect } from '@ohos/hypium';
import { AppPermission } from '../main/ets/permission/AppPermission';
import { IPermissionGateway } from '../main/ets/permission/IPermissionGateway';
import { PermissionOrchestrator } from '../main/ets/permission/PermissionOrchestrator';
import { PermissionPresentation } from '../main/ets/permission/PermissionPresentation';
import { PermissionRecordStore } from '../main/ets/permission/PermissionRecordStore';
import { PermissionRequestResult } from '../main/ets/permission/PermissionRequestResult';
import { PermissionStatus } from '../main/ets/permission/PermissionStatus';
import { CapabilityRegistry } from '../main/ets/capability/CapabilityRegistry';
import { CapabilityResult } from '../main/ets/capability/CapabilityResult';
import { CapabilityStatus } from '../main/ets/capability/CapabilityStatus';
import { ICapabilityProbe } from '../main/ets/capability/ICapabilityProbe';
import { PlatformModuleType } from '../main/ets/capability/PlatformModuleType';
import { BackgroundPolicyAdvisor, BackgroundSessionAction } from '../main/ets/lifecycle/BackgroundPolicyAdvisor';
import { LifecycleCoordinator } from '../main/ets/lifecycle/LifecycleCoordinator';
import { AppLifecycleState } from '../main/ets/lifecycle/AppLifecycleState';
import { PlatformEventType } from '../main/ets/lifecycle/PlatformEventType';

class MockPermissionGateway implements IPermissionGateway {
  private readonly granted: Set<string> = new Set();

  async checkPermission(permission: string): Promise<PermissionStatus> {
    return this.granted.has(permission) ? PermissionStatus.GRANTED : PermissionStatus.NOT_REQUESTED;
  }

  async requestFromUser(permissions: string[], _reason: string): Promise<PermissionRequestResult> {
    const statuses: PermissionStatus[] = [];
    const dialogShown: boolean[] = [];
    for (let i = 0; i < permissions.length; i++) {
      this.granted.add(permissions[i]);
      statuses.push(PermissionStatus.GRANTED);
      dialogShown.push(true);
    }
    return new PermissionRequestResult(permissions, statuses, true, dialogShown);
  }

  async openSettingGuide(permissions: string[]): Promise<PermissionRequestResult> {
    return this.requestFromUser(permissions, '');
  }
}

class MockCapabilityProbe implements ICapabilityProbe {
  readonly capabilityId: string;
  private readonly status: CapabilityStatus;

  constructor(capabilityId: string, status: CapabilityStatus) {
    this.capabilityId = capabilityId;
    this.status = status;
  }

  async probe(): Promise<CapabilityResult> {
    return new CapabilityResult(this.capabilityId, PlatformModuleType.SYSTEM, this.status, 'mock probe');
  }
}

export default function localUnitTest() {
  describe('CommonPlatformLocalUnitTest', () => {
    it('PermissionOrchestrator_empty_permissions', 0, async () => {
      const orchestrator = PermissionOrchestrator.createForTest(new MockPermissionGateway());
      const presentation = new PermissionPresentation('test', 'Title', 'Message', '');
      const decision = await orchestrator.ensurePermissions([], 'none', presentation);
      expect(decision.granted).assertTrue();
    });

    it('PermissionOrchestrator_request_flow', 0, async () => {
      const orchestrator = PermissionOrchestrator.createForTest(new MockPermissionGateway());
      const presentation = new PermissionPresentation('test', 'Title', 'Message', 'Grant');
      const decision = await orchestrator.ensurePermissions(
        [AppPermission.INTERNET],
        'Need internet',
        presentation
      );
      expect(decision.granted).assertTrue();
    });

    it('CapabilityRegistry_configure_and_probe', 0, async () => {
      const registry = CapabilityRegistry.getInstance();
      registry.configureCatalog(['cap.test']);
      registry.registerProbe(new MockCapabilityProbe('cap.test', CapabilityStatus.AVAILABLE));
      const result = await registry.probe('cap.test');
      expect(result.status).assertEqual(CapabilityStatus.AVAILABLE);
    });

    it('BackgroundPolicyAdvisor_passthrough', 0, () => {
      expect(BackgroundPolicyAdvisor.passthrough(BackgroundSessionAction.PAUSE))
        .assertEqual(BackgroundSessionAction.PAUSE);
    });

    it('LifecycleCoordinator_reconcile', 0, async () => {
      const coordinator = LifecycleCoordinator.getInstance();
      let reconcileCalled = false;
      coordinator.addReconcileCallback(async () => {
        reconcileCalled = true;
      });
      coordinator.onAppForeground('test');
      expect(reconcileCalled).assertTrue();
      expect(coordinator.state).assertEqual(AppLifecycleState.FOREGROUND);
    });

    it('LifecycleCoordinator_platform_switch_event', 0, () => {
      const coordinator = LifecycleCoordinator.getInstance();
      let eventType = PlatformEventType.APP_FOREGROUND;
      coordinator.addListener((event) => {
        eventType = event.type;
      });
      coordinator.onBluetoothSwitchChanged(true);
      expect(eventType).assertEqual(PlatformEventType.BLUETOOTH_SWITCH);
    });
  });
}
