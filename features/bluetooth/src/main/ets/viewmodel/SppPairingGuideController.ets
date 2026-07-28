import { Subscription } from 'common_core';
import {
  AbilityContextRegistry,
  BluetoothSettingsNavigator
} from 'common_platform';
import { YoResourceUtil } from 'youi_kit';
import {
  BluetoothErrorCodes,
  ObservePairingEventsUseCase,
  PairBluetoothDeviceUseCase,
  PairingEvent,
  PairingState
} from 'yobluetooth';

/**
 * Observed dialog state for openCustomDialog + ComponentContent.
 * App guide only — system pairDevice / PIN UI is never faked here.
 */
@Observed
export class PairingGuideDialogParams {
  @Track displayName: string = '';
  @Track classicDeviceId: string = '';
  @Track pairing: boolean = false;
  @Track hasAttempted: boolean = false;
  @Track errorMessage: string = '';
  onCancel: () => void = () => {
  };
  onOpenSettings: () => void = () => {
  };
  onPair: () => void = () => {
  };
  onPairedSuccess: () => void = () => {
  };
}

/**
 * Dialog-lifetime controller for pairing guide.
 * Owns UseCase calls — Feature Dialog Content must not orchestrate UseCases (06 MVVM).
 *
 * Pairing truth = bondStateChange PAIRED (platform BONDED).
 * pairDevice Promise success only means the system dialog was launched / request accepted.
 */
export class SppPairingGuideController {
  private readonly pairDevice: PairBluetoothDeviceUseCase;
  private readonly observePairing: ObservePairingEventsUseCase;
  private bondSubscription: Subscription | undefined = undefined;
  private completed: boolean = false;
  private onPaired: () => void = () => {
  };

  constructor(
    pairDevice: PairBluetoothDeviceUseCase = new PairBluetoothDeviceUseCase(),
    observePairing: ObservePairingEventsUseCase = new ObservePairingEventsUseCase()
  ) {
    this.pairDevice = pairDevice;
    this.observePairing = observePairing;
  }

  bindPairedCallback(onPaired: () => void): void {
    this.onPaired = onPaired;
  }

  reset(): void {
    this.disposeBondSubscription();
    this.completed = false;
  }

  dispose(): void {
    this.disposeBondSubscription();
    this.completed = true;
  }

  async openBluetoothSettings(): Promise<void> {
    const context = AbilityContextRegistry.getInstance().get();
    if (context !== undefined) {
      await BluetoothSettingsNavigator.openBluetoothSettings(context);
    }
  }

  /**
   * Start system pairDevice. Keep spinner until bond PAIRED (or fail/cancel).
   * Promise resolve ≠ paired.
   */
  async pairFromGuide(form: PairingGuideDialogParams): Promise<void> {
    if (form.pairing || form.classicDeviceId.length === 0 || this.completed) {
      return;
    }
    form.pairing = true;
    form.hasAttempted = true;
    form.errorMessage = '';
    this.ensureBondSubscription(form);
    const result = await this.pairDevice.execute(form.classicDeviceId);
    if (this.completed) {
      return;
    }
    if (!result.success) {
      form.pairing = false;
      const apiMessage = result.error?.message ?? '';
      form.errorMessage = apiMessage.length > 0 ?
        apiMessage :
        this.messageForFailCode(result.error?.code);
      return;
    }
    // Promise success = system dialog launched / request accepted — keep spinner for bond.
  }

  private ensureBondSubscription(form: PairingGuideDialogParams): void {
    if (this.bondSubscription !== undefined) {
      return;
    }
    const targetId = this.normalizeAddress(form.classicDeviceId);
    this.bondSubscription = this.observePairing.execute((event: PairingEvent) => {
      if (this.completed) {
        return;
      }
      if (this.normalizeAddress(event.address) !== targetId) {
        return;
      }
      if (event.state === PairingState.PAIRED) {
        this.finishPaired(form);
        return;
      }
      if (event.state === PairingState.FAILED || event.state === PairingState.CANCELLED) {
        form.pairing = false;
        form.errorMessage = event.state === PairingState.CANCELLED ?
          YoResourceUtil.resolveText($r('app.string.bt_pairing_error_cancelled')) :
          YoResourceUtil.resolveText($r('app.string.bt_pairing_error_failed'));
      }
    });
  }

  private finishPaired(form: PairingGuideDialogParams): void {
    if (this.completed) {
      return;
    }
    this.completed = true;
    form.pairing = false;
    const callback = this.onPaired;
    form.onPairedSuccess();
    callback();
  }

  private messageForFailCode(code: string | undefined): string {
    if (code === BluetoothErrorCodes.PAIRING_CANCELLED) {
      return YoResourceUtil.resolveText($r('app.string.bt_pairing_error_cancelled'));
    }
    return YoResourceUtil.resolveText($r('app.string.bt_pairing_error_failed'));
  }

  private normalizeAddress(address: string): string {
    return address.trim().toUpperCase();
  }

  private disposeBondSubscription(): void {
    if (this.bondSubscription !== undefined) {
      this.bondSubscription.dispose();
      this.bondSubscription = undefined;
    }
  }
}
