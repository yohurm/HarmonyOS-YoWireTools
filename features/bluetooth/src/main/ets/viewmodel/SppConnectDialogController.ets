import {
  BluetoothConstants,
  BluetoothTransportType,
  ConnectSppUseCase,
  QuerySppConnectEligibilityUseCase,
  ReconnectPolicy,
  SppConnectFailureHints,
  SppConnectParams,
  SppUuidFavoriteEntry,
  SppUuidFavoriteUseCases
} from 'yobluetooth';
import { YoErrorStateModel } from 'youi_kit';

/** UUID 预设档：标准 SPP / Nordic UART 只读档位；自定义可编辑。HS01 AT 仅作收藏种子。 */
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
  /** 自定义 UUID 收藏列表（Preferences）。 */
  @Track favorites: SppUuidFavoriteEntry[] = [];
  /** 当前输入 UUID 是否已收藏（自定义档标题收藏图标点亮）。 */
  @Track currentUuidFavorited: boolean = false;
  /** Structured three-layer error model (PRD §9 / architecture §10). */
  errorModel: YoErrorStateModel = new YoErrorStateModel();
  transport: BluetoothTransportType = BluetoothTransportType.BR_EDR;
  onCancel: () => void = () => {
  };
  onConnected: (sessionId: string) => void = (_sessionId: string) => {
  };
  onConnect: () => void = () => {
  };
  onToggleFavorite: () => void = () => {
  };
  onSelectFavoriteIndex: (index: number) => void = (_index: number) => {
  };
  onUuidInputChanged: () => void = () => {
  };
  /**
   * Persist favorite from sheet form.
   * @param originalUuid empty = add; non-empty = update that entry
   * @returns 'ok' | 'invalid' | 'limit' | 'duplicate' | 'not_found' | 'failed'
   */
  saveFavorite: (originalUuid: string, uuid: string, label: string) => Promise<string> =
    async (_originalUuid: string, _uuid: string, _label: string): Promise<string> => 'failed';
  /**
   * Remove favorite by uuid.
   * @returns 'ok' | 'not_found' | 'failed'
   */
  removeFavorite: (uuid: string) => Promise<string> =
    async (_uuid: string): Promise<string> => 'failed';
}

/**
 * Dialog-lifetime controller for SPP connect form.
 * Owns UseCase calls — Feature Dialog Content must not orchestrate UseCases (06 MVVM).
 */
export class SppConnectDialogController {
  private readonly connectSpp: ConnectSppUseCase;
  private readonly queryEligibility: QuerySppConnectEligibilityUseCase;
  private readonly uuidFavorites: SppUuidFavoriteUseCases;

  constructor(
    connectSpp: ConnectSppUseCase = new ConnectSppUseCase(),
    queryEligibility: QuerySppConnectEligibilityUseCase = new QuerySppConnectEligibilityUseCase(),
    uuidFavorites: SppUuidFavoriteUseCases = new SppUuidFavoriteUseCases()
  ) {
    this.connectSpp = connectSpp;
    this.queryEligibility = queryEligibility;
    this.uuidFavorites = uuidFavorites;
  }

  async loadFavorites(form: SppConnectDialogParams): Promise<void> {
    form.favorites = await this.uuidFavorites.listFavorites();
    this.refreshFavoriteState(form);
  }

  refreshFavoriteState(form: SppConnectDialogParams): void {
    form.currentUuidFavorited = this.uuidFavorites.isFavorite(form.uuid);
  }

  /**
   * Toggle favorite for current UUID input.
   * @returns 'added' | 'removed' | 'invalid' | 'limit' | 'failed'
   */
  async toggleFavorite(form: SppConnectDialogParams): Promise<string> {
    const uuid = form.uuid.trim();
    if (uuid.length === 0) {
      return 'invalid';
    }
    const result = await this.uuidFavorites.toggleFavorite(uuid, '');
    if (!result.success) {
      return SppConnectDialogController.mapFavoriteError(result.error?.message ?? '');
    }
    form.favorites = await this.uuidFavorites.listFavorites();
    this.refreshFavoriteState(form);
    return result.value === true ? 'added' : 'removed';
  }

  /**
   * @returns 'ok' | 'invalid' | 'limit' | 'duplicate' | 'not_found' | 'failed'
   */
  async saveFavorite(
    form: SppConnectDialogParams,
    originalUuid: string,
    uuid: string,
    label: string
  ): Promise<string> {
    const result = originalUuid.trim().length === 0 ?
      await this.uuidFavorites.addFavorite(uuid, label) :
      await this.uuidFavorites.updateFavorite(originalUuid, uuid, label);
    if (!result.success) {
      return SppConnectDialogController.mapFavoriteError(result.error?.message ?? '');
    }
    form.favorites = await this.uuidFavorites.listFavorites();
    this.refreshFavoriteState(form);
    return 'ok';
  }

  /**
   * @returns 'ok' | 'not_found' | 'failed'
   */
  async removeFavorite(form: SppConnectDialogParams, uuid: string): Promise<string> {
    const result = await this.uuidFavorites.removeFavorite(uuid);
    if (!result.success) {
      return SppConnectDialogController.mapFavoriteError(result.error?.message ?? '');
    }
    form.favorites = await this.uuidFavorites.listFavorites();
    this.refreshFavoriteState(form);
    return 'ok';
  }

  selectFavoriteIndex(form: SppConnectDialogParams, index: number): void {
    if (index < 0 || index >= form.favorites.length) {
      return;
    }
    const entry = form.favorites[index];
    form.uuidMode = SppUuidPickMode.CUSTOM;
    form.uuid = entry.uuid;
    form.customUuidDraft = entry.uuid;
    this.refreshFavoriteState(form);
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

  private static mapFavoriteError(message: string): string {
    if (message.indexOf('limit') >= 0) {
      return 'limit';
    }
    if (message.indexOf('Invalid') >= 0) {
      return 'invalid';
    }
    if (message.indexOf('Duplicate') >= 0) {
      return 'duplicate';
    }
    if (message.indexOf('not found') >= 0) {
      return 'not_found';
    }
    return 'failed';
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
