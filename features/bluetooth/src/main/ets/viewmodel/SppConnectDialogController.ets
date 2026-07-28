import {
  BluetoothConstants,
  BluetoothTransportType,
  ConnectSppUseCase,
  QuerySppConnectEligibilityUseCase,
  ReconnectPolicy,
  SppConnectFailureHints,
  SppConnectParams
} from 'yobluetooth';

/**
 * Observed dialog form state for openCustomDialog + ComponentContent.
 */
@Observed
export class SppConnectDialogParams {
  @Track displayName: string = '';
  @Track classicDeviceId: string = '';
  @Track uuid: string = BluetoothConstants.DEFAULT_SPP_UUID;
  @Track secure: boolean = false;
  @Track timeoutText: string = `${BluetoothConstants.DEFAULT_SPP_CONNECT_TIMEOUT_MS}`;
  @Track autoReconnect: boolean = false;
  @Track connecting: boolean = false;
  @Track errorMessage: string = '';
  @Track hintLines: string[] = [];
  transport: BluetoothTransportType = BluetoothTransportType.BR_EDR;
  onCancel: () => void = () => {
  };
  onConnected: (sessionId: string) => void = (_sessionId: string) => {
  };
  onConnect: () => void = () => {
  };
}

/**
 * Dialog-lifetime controller for SPP connect form.
 * Owns UseCase calls — Feature Dialog Content must not orchestrate UseCases (06 MVVM).
 */
export class SppConnectDialogController {
  private readonly connectSpp: ConnectSppUseCase;
  private readonly queryEligibility: QuerySppConnectEligibilityUseCase;

  constructor(
    connectSpp: ConnectSppUseCase = new ConnectSppUseCase(),
    queryEligibility: QuerySppConnectEligibilityUseCase = new QuerySppConnectEligibilityUseCase()
  ) {
    this.connectSpp = connectSpp;
    this.queryEligibility = queryEligibility;
  }

  /**
   * Eligibility pre-check then ConnectSppUseCase.
   * Mutates form connecting / errorMessage / hintLines; invokes onConnected on success.
   */
  async connectFromDialog(form: SppConnectDialogParams): Promise<void> {
    if (form.connecting || form.classicDeviceId.length === 0) {
      return;
    }
    const uuid = form.uuid.trim().length > 0 ?
      form.uuid.trim() :
      BluetoothConstants.DEFAULT_SPP_UUID;
    let timeoutMs = Number(form.timeoutText.trim());
    if (Number.isNaN(timeoutMs) || timeoutMs <= 0) {
      timeoutMs = BluetoothConstants.DEFAULT_SPP_CONNECT_TIMEOUT_MS;
    }
    form.errorMessage = '';
    form.hintLines = [];
    // Pre-check DUPLICATE/LIMIT (YW-BT-1316/1317) before starting connect UI/work.
    // ConnectSppUseCase remains the final admission authority.
    const eligibility = this.queryEligibility.execute(form.classicDeviceId, uuid);
    if (!eligibility.success) {
      const code = eligibility.error?.code ?? '';
      form.errorMessage = eligibility.error?.message ?? 'not eligible';
      form.hintLines = SppConnectFailureHints.explain(code, form.errorMessage);
      return;
    }
    form.connecting = true;
    const result = await this.connectSpp.execute(new SppConnectParams(
      form.classicDeviceId,
      form.displayName,
      uuid,
      form.secure,
      Math.floor(timeoutMs),
      form.autoReconnect,
      ReconnectPolicy.defaultPolicy(),
      form.transport
    ));
    form.connecting = false;
    if (!result.success || result.value === undefined) {
      const code = result.error?.code ?? '';
      form.errorMessage = result.error?.message ?? 'connect failed';
      form.hintLines = SppConnectFailureHints.explain(code, form.errorMessage);
      return;
    }
    form.onConnected(result.value.sessionId);
  }
}
