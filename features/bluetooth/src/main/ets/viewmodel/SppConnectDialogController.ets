import {
  BluetoothConstants,
  BluetoothTransportType,
  ConnectSppUseCase,
  QuerySppConnectEligibilityUseCase,
  ReconnectPolicy,
  SppConnectFailureHints,
  SppConnectParams
} from 'yobluetooth';
import { YoErrorStateModel } from 'youi_kit';

/** UUID 预设档：标准 SPP 只读；Nordic / 自定义可编辑。 */
export enum SppUuidPickMode {
  STANDARD = 0,
  NORDIC = 1,
  CUSTOM = 2
}

/**
 * Observed dialog form state for openCustomDialog + ComponentContent.
 */
@Observed
export class SppConnectDialogParams {
  @Track displayName: string = '';
  @Track classicDeviceId: string = '';
  @Track uuid: string = BluetoothConstants.DEFAULT_SPP_UUID;
  @Track uuidMode: SppUuidPickMode = SppUuidPickMode.STANDARD;
  /** 自定义档草稿；切回自定义时恢复。 */
  @Track customUuidDraft: string = '';
  @Track secure: boolean = false;
  @Track timeoutText: string = `${BluetoothConstants.DEFAULT_SPP_CONNECT_TIMEOUT_MS}`;
  @Track autoReconnect: boolean = false;
  @Track connecting: boolean = false;
  @Track errorMessage: string = '';
  @Track hintLines: string[] = [];
  /** Structured three-layer error model (PRD §9 / architecture §10). */
  errorModel: YoErrorStateModel = new YoErrorStateModel();
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
   * Mutates form connecting / errorMessage / hintLines / errorModel; invokes onConnected on success.
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
      // UI 已对非法超时置灰；此处兜底默认值，避免异常路径传入 NaN。
      timeoutMs = BluetoothConstants.DEFAULT_SPP_CONNECT_TIMEOUT_MS;
    }
    form.errorMessage = '';
    form.hintLines = [];
    form.errorModel = new YoErrorStateModel();
    // Pre-check DUPLICATE/LIMIT (YW-BT-1316/1317) before starting connect UI/work.
    // ConnectSppUseCase remains the final admission authority.
    const eligibility = this.queryEligibility.execute(form.classicDeviceId, uuid);
    if (!eligibility.success) {
      SppConnectDialogController.applyFailure(form, eligibility.error?.code ?? '',
        eligibility.error?.message ?? 'not eligible', eligibility.error?.nativeCode ?? '');
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
      SppConnectDialogController.applyFailure(form, result.error?.code ?? '',
        result.error?.message ?? 'connect failed', result.error?.nativeCode ?? '');
      return;
    }
    form.onConnected(result.value.sessionId);
  }

  private static applyFailure(
    form: SppConnectDialogParams,
    code: string,
    message: string,
    nativeCode: string
  ): void {
    form.errorMessage = message;
    form.hintLines = SppConnectFailureHints.explain(code, message);
    const cause = form.hintLines.length > 0 ? form.hintLines[0] : '';
    const next = form.hintLines.length > 1 ? form.hintLines[1] : '';
    form.errorModel = YoErrorStateModel.fromLayers(
      message,
      cause,
      next,
      true,
      code,
      nativeCode
    );
  }
}
