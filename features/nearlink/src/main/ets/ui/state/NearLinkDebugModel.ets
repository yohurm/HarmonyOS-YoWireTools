import { Subscription } from 'common_core';
import {
  AbilityContextRegistry,
  AppLifecycleState,
  BluetoothSettingsNavigator,
  LifecycleCoordinator,
  PermissionUiState
} from 'common_platform';
import { EnsurePermissionUseCase, PermissionScenario } from 'debug_core';
import {
  YoEmptyStateModel,
  YoErrorStateModel,
  YoLoadingStateModel,
  YoPageState
} from 'youi_kit';
import { NearLinkConstants } from '../../constants/NearLinkConstants';
import { NearLinkErrorCodes } from '../../constants/NearLinkErrorCodes';
import { NearLinkRepository } from '../../data/repository/NearLinkRepository';
import { NearLinkDevice } from '../../domain/model/NearLinkDevice';
import { NearLinkLogEntry } from '../../domain/model/NearLinkLogEntry';
import { NearLinkScanFilter } from '../../domain/model/NearLinkScanFilter';
import { NearLinkSecurityState } from '../../domain/model/NearLinkSecurityState';
import {
  NearLinkDestination,
  NearLinkGap,
  NearLinkRadioCategory,
  NearLinkScanUiPhase,
  NearLinkSupportCategory
} from '../../domain/model/NearLinkScreenCategory';
import { SsapServiceNode } from '../../domain/model/SsapServiceTree';
import {
  NearLinkEntryPolicy,
  NearLinkLogBook,
  NearLinkPairedPresentation,
  NearLinkReasonPolicy
} from '../../domain/service/NearLinkDebugRules';
import { NearLinkPayloadRules } from '../../domain/service/NearLinkScanPolicy';
import { NearLinkScreenRules } from '../../domain/service/NearLinkScreenRules';
import { NearLinkScanForm } from '../../domain/service/NearLinkScanForm';
import { StartNearLinkScanUseCase, StopNearLinkScanUseCase } from '../../domain/usecase/NearLinkUseCases';
import { NearLinkSessionUseCases } from '../../domain/usecase/NearLinkSessionUseCases';

@ObservedV2
export class NearLinkDebugModel {
  @Trace supportCategory: string = NearLinkSupportCategory.LOADING;
  @Trace radioCategory: string = NearLinkRadioCategory.UNKNOWN;
  @Trace localName: string = '';
  @Trace localNameFailed: boolean = false;
  @Trace nativeCode: string = '';
  @Trace versionSince: string = '';
  @Trace permissionAsked: boolean = false;
  @Trace permissionGranted: boolean = false;
  @Trace permissionUi: PermissionUiState | undefined = undefined;
  @Trace destination: string = NearLinkDestination.ROOT;
  @Trace scanPhase: string = NearLinkScanUiPhase.IDLE;
  @Trace scanBusy: boolean = false;
  @Trace devices: NearLinkDevice[] = [];
  @Trace selectedAddress: string = '';
  @Trace detailHex: string = '';
  @Trace detailEmpty: boolean = false;
  @Trace detailCompleteName: string = '';
  @Trace detailShortName: string = '';
  @Trace detailReportedName: string = '';
  @Trace detailWarnings: string = '';
  @Trace detailServiceText: string = '';
  @Trace detailManufacturerText: string = '';
  @Trace detailUnknownText: string = '';
  @Trace detailNameBytes: number = -1;
  @Trace filterAddress: string = '';
  @Trace filterName: string = '';
  @Trace filterManufacturerId: string = '';
  @Trace filterManufacturerData: string = '';
  @Trace filterManufacturerMask: string = '';
  @Trace filterRssi: string = '';
  @Trace filterDuration: string = '';
  @Trace filterUuid: string = '';
  @Trace filterUuidEnabled: boolean = false;
  @Trace filterAddressB: string = '';
  @Trace filterNameB: string = '';
  @Trace filterScanAll: boolean = false;
  @Trace scanModeIndex: number = 0;
  @Trace filterMessage: string = '';
  @Trace rssiFilterMode: string = 'none';
  @Trace pairedVersionUnavailable: boolean = false;
  @Trace pairedAddresses: string[] = [];
  @Trace favoriteNote: string = '';
  @Trace advInterval: string = `${NearLinkConstants.ADV_INTERVAL_DEFAULT}`;
  @Trace advConnectable: boolean = true;
  @Trace advIncludeName: boolean = true;
  @Trace advServiceUuid: string = '';
  @Trace advRunning: boolean = false;
  @Trace actionMessage: string = '';
  @Trace ssapServiceUuid: string = '';
  @Trace ssapPropertyUuid: string = '';
  @Trace ssapOperation: string = '1';
  @Trace ssapHex: string = '';
  @Trace ssapWithResponse: boolean = true;
  @Trace ssapMtuText: string = `${NearLinkConstants.DEFAULT_MTU}`;
  @Trace ssapConnected: boolean = false;
  @Trace ssapConnecting: boolean = false;
  @Trace waitedSec: number = 0;
  @Trace ssapReused: boolean = false;
  @Trace notifyHint: boolean = false;
  @Trace sliceRequired: boolean = false;
  @Trace services: SsapServiceNode[] = [];
  @Trace serverOpen: boolean = false;
  @Trace serverClosed: boolean = false;
  @Trace lastReadRequestId: number = -1;
  @Trace lastReadAddress: string = '';
  @Trace lastClientAddress: string = '';
  @Trace serverLines: string[] = [];
  @Trace portUuid: string = '';
  @Trace portMtu: string = '';
  @Trace portReliable: boolean = false;
  @Trace portOpen: boolean = false;
  @Trace portConnected: boolean = false;
  @Trace portNegotiatedMtu: number = 0;
  @Trace portPacketsTx: number = 0;
  @Trace portPacketsRx: number = 0;
  @Trace portHeld: boolean = false;
  @Trace portText: string = '';
  @Trace portSliceRequired: boolean = false;
  @Trace savedFavoriteAddress: string = '';
  @Trace mtuNearLink: boolean = false;
  @Trace blockUnencrypted: boolean = true;
  @Trace security: string = NearLinkSecurityState.UNKNOWN;
  @Trace appTx: number = 0;
  @Trace appRx: number = 0;
  @Trace pairingToken: string = 'none';
  @Trace pairingReason: string = '';
  @Trace logs: NearLinkLogEntry[] = [];
  @Trace logFilter: number = 0;
  @Trace selectedLogId: string = '';
  @Trace exportFailed: boolean = false;
  @Trace pageState: YoPageState = YoPageState.LOADING;

  private readonly repository: NearLinkRepository = NearLinkRepository.getInstance();
  private readonly session: NearLinkSessionUseCases = new NearLinkSessionUseCases();
  private readonly startScanUseCase: StartNearLinkScanUseCase = new StartNearLinkScanUseCase();
  private readonly stopScanUseCase: StopNearLinkScanUseCase = new StopNearLinkScanUseCase();
  private readonly ensurePermission: EnsurePermissionUseCase = new EnsurePermissionUseCase();
  private readonly trail: string[] = [NearLinkDestination.ROOT];
  private deviceSub: Subscription | undefined = undefined;
  private treeSub: Subscription | undefined = undefined;
  private lifeSub: Subscription | undefined = undefined;
  private scanSessionId: string = '';
  private logSerial: number = 0;
  private durationTimer: number = -1;
  private waitTimer: number = -1;
  private connectStartedMs: number = 0;
  private readonly loggedHex: string[] = [];

  async onAppear(): Promise<void> {
    this.deviceSub = this.repository.observeDevices().subscribe((devices: NearLinkDevice[]) => {
      this.noteScanHex(devices);
      this.devices = devices;
      if (this.selectedAddress.length > 0) {
        this.refreshDetail();
      }
    });
    this.treeSub = this.repository.observeSsapTree().subscribe((tree) => {
      this.services = tree.services;
      this.ssapConnected = tree.state === 'connected' || tree.state === 'ready';
    });
    this.lifeSub = LifecycleCoordinator.getInstance().observeLifecycle((state: AppLifecycleState) => {
      if (state === AppLifecycleState.BACKGROUND) {
        void this.stopScanFromBackground();
      }
    });
    this.session.onRadio((code: number) => {
      this.applyRadio(code);
    });
    this.session.onPairing((address: string, stateToken: string, reasonToken: string, reasonMsg: string) => {
      this.pairingToken = stateToken;
      this.pairingReason = NearLinkReasonPolicy.pairingCategory(reasonToken, reasonMsg);
      this.pushLog('internal', 'pairingStateChange', '', address, reasonMsg, '');
    });
    this.session.onConnection((address: string, reasonMsg: string) => {
      this.pushLog('internal', 'connectionStateChange', '', address, reasonMsg, '');
    });
    this.session.watchServer((record) => {
      this.lastClientAddress = record.address;
      const line = record.responded ?
        `${record.requestId} WRITE ${record.valueHex}` :
        `${record.requestId} WRITE_NO_RESPONSE ${record.valueHex}`;
      this.pushServerLine(line);
      this.pushLog('in', 'propertyWrite', '', line, '', record.valueHex);
    }, (requestId: number, address: string, propertyUuid: string) => {
      this.lastReadRequestId = requestId;
      this.lastReadAddress = address;
      this.lastClientAddress = address;
      this.pushServerLine(`${requestId} READ ${address} ${propertyUuid}`);
    });
    this.session.watchPort((address: string, uuid: string, mtu: number, state: number) => {
      const connected = NearLinkScreenRules.portIsConnected(state);
      this.portConnected = connected;
      this.session.notePortLink(mtu, connected);
      this.portNegotiatedMtu = connected ? mtu : 0;
      this.pushLog('internal', 'connectionStateChanged', '', `${address} ${uuid} mtu=${mtu} state=${state}`, '', '');
    }, (address: string, uuid: string, hex: string, byteLength: number) => {
      this.session.notePortRead(byteLength);
      this.portPacketsRx = this.session.appRxPackets();
      this.appRx = this.session.appRx();
      this.pushLog('in', 'readData', '', `${address} ${uuid}`, '', hex);
    });
    await this.refreshSupport();
  }

  async onDisappear(): Promise<void> {
    this.clearWait();
    await this.stopScanIfNeeded();
    this.session.offRadio();
    this.session.offPairing();
    this.session.offConnection();
    if (this.deviceSub !== undefined) {
      this.deviceSub.dispose();
      this.deviceSub = undefined;
    }
    if (this.treeSub !== undefined) {
      this.treeSub.dispose();
      this.treeSub = undefined;
    }
    if (this.lifeSub !== undefined) {
      this.lifeSub.dispose();
      this.lifeSub = undefined;
    }
  }

  open(next: string): void {
    if (this.leavesScan(next)) {
      void this.stopScanIfNeeded();
    }
    this.trail.push(next);
    this.destination = next;
    this.actionMessage = '';
    if (next === NearLinkDestination.SCAN || next === NearLinkDestination.DETAIL) {
      void this.loadPaired();
    }
  }

  back(): void {
    if (this.trail.length <= 1) {
      return;
    }
    this.trail.pop();
    const next = this.trail[this.trail.length - 1];
    if (this.leavesScan(next)) {
      void this.stopScanIfNeeded();
    }
    this.destination = next;
  }

  modesEnabled(): boolean {
    return NearLinkEntryPolicy.modesEnabled(this.supportCategory, this.radioCategory, false) &&
      this.supportCategory !== NearLinkSupportCategory.EMULATOR;
  }

  scanEntryEnabled(): boolean {
    return this.modesEnabled() &&
      this.radioCategory !== NearLinkRadioCategory.TURNING_ON &&
      this.radioCategory !== NearLinkRadioCategory.TURNING_OFF;
  }

  async refreshSupport(): Promise<void> {
    this.pageState = YoPageState.LOADING;
    this.supportCategory = NearLinkSupportCategory.LOADING;
    const support = this.session.querySupport();
    if (!support.success) {
      if (support.error?.code === NearLinkErrorCodes.VERSION_UNAVAILABLE) {
        this.supportCategory = NearLinkSupportCategory.VERSION;
        this.versionSince = NearLinkConstants.SINCE_SUPPORT;
        this.nativeCode = '';
      } else if (support.error?.code === NearLinkErrorCodes.CAPABILITY_UNSUPPORTED) {
        this.supportCategory = NearLinkSupportCategory.CAPABILITY;
        this.nativeCode = `${NearLinkConstants.NATIVE_CAPABILITY}`;
        this.radioCategory = NearLinkRadioCategory.UNKNOWN;
      } else {
        this.supportCategory = NearLinkSupportCategory.UNSUPPORTED;
      }
      this.pageState = YoPageState.CONTENT;
      return;
    }
    if (this.session.isEmulator()) {
      this.supportCategory = NearLinkSupportCategory.EMULATOR;
      this.pageState = YoPageState.CONTENT;
      return;
    }
    if (support.value === undefined || !support.value.supported) {
      this.supportCategory = NearLinkSupportCategory.UNSUPPORTED;
      this.pageState = YoPageState.CONTENT;
      return;
    }
    this.supportCategory = NearLinkSupportCategory.SUPPORTED;
    const radio = this.session.readRadio();
    if (radio.success && radio.value !== undefined) {
      this.applyRadio(radio.value.code);
    }
    this.pageState = YoPageState.CONTENT;
    await this.refreshLocalName();
  }

  async refreshLocalName(): Promise<void> {
    if (this.radioCategory === NearLinkRadioCategory.OFF) {
      this.localName = '';
      this.localNameFailed = true;
      this.nativeCode = NearLinkScreenRules.localNameCodeWhenOff(true);
      this.pushLog('internal', 'getLocalName', this.nativeCode, 'radio off', '', '');
      if (this.permissionGranted) {
        this.session.readLocalName();
      }
      return;
    }
    if (!this.permissionGranted) {
      this.localName = '';
      this.localNameFailed = false;
      return;
    }
    const named = this.session.readLocalName();
    if (!named.success) {
      this.localName = '';
      this.localNameFailed = true;
      const native = named.error?.nativeCode ?? '';
      this.nativeCode = native.length > 0 ? native : `${NearLinkConstants.NATIVE_RADIO_OFF}`;
      this.pushLog('internal', 'getLocalName', this.nativeCode, 'local name failed', '', '');
      return;
    }
    this.localNameFailed = false;
    this.localName = named.value ?? '';
  }

  async startScan(): Promise<void> {
    if (this.scanPhase === NearLinkScanUiPhase.SCANNING || this.scanBusy) {
      return;
    }
    if (this.supportCategory === NearLinkSupportCategory.EMULATOR) {
      this.scanPhase = NearLinkScanUiPhase.FAILED;
      this.filterMessage = NearLinkErrorCodes.EMULATOR_UNAVAILABLE;
      return;
    }
    if (!this.scanEntryEnabled()) {
      this.filterMessage = NearLinkErrorCodes.SWITCH_OFF;
      return;
    }
    const decision = await this.ensurePermission.execute(PermissionScenario.NEARLINK_ACCESS);
    this.permissionAsked = true;
    this.permissionGranted = decision.granted;
    this.permissionUi = decision.uiState;
    this.pushLog('internal', 'requestPermissionsFromUser', decision.granted ? '' : `${NearLinkConstants.NATIVE_PERMISSION}`,
      'ACCESS_NEARLINK', '', '');
    if (!decision.granted) {
      return;
    }
    await this.refreshLocalName();
    const filter = this.currentFilter();
    const validated = filter.validate();
    if (!validated.success) {
      this.filterMessage = validated.error?.code ?? NearLinkErrorCodes.EMPTY_FILTER;
      this.nativeCode = validated.error?.nativeCode ?? '';
      this.scanPhase = NearLinkScanUiPhase.FAILED;
      this.pushLog('internal', 'startScan', this.nativeCode, validated.error?.message ?? '', '', '');
      return;
    }
    this.scanBusy = true;
    const started = await this.startScanUseCase.execute(filter);
    this.scanBusy = false;
    if (!started.success) {
      this.scanPhase = NearLinkScanUiPhase.FAILED;
      this.filterMessage = started.error?.code ?? NearLinkErrorCodes.SCAN_FAILED;
      this.nativeCode = started.error?.nativeCode ?? '';
      this.versionSince = this.readSince(started.error?.message ?? '');
      this.pushLog('internal', 'startScan', this.nativeCode, started.error?.message ?? '', '', '');
      return;
    }
    this.scanSessionId = started.value ?? '';
    this.scanPhase = NearLinkScanUiPhase.SCANNING;
    this.armDuration(filter.durationSec);
    this.filterMessage = '';
    this.rssiFilterMode = this.session.systemRssiAvailable() && this.filterRssi.trim().length > 0 ? 'system' : (
      this.filterRssi.trim().length > 0 ? 'local' : 'none'
    );
    this.pushLog('internal', 'startScan', '', `mode=${this.scanModeIndex}`, '', '');
  }

  async stopScan(): Promise<void> {
    await this.stopScanIfNeeded();
    this.scanPhase = NearLinkScanUiPhase.STOPPED;
  }

  async confirmFilter(): Promise<void> {
    if (this.scanPhase === NearLinkScanUiPhase.SCANNING) {
      await this.stopScan();
    }
    await this.startScan();
  }

  selectDevice(address: string): void {
    this.selectedAddress = address;
    this.refreshDetail();
    void this.loadPaired();
  }

  async saveFavorite(): Promise<void> {
    const device = this.selectedDevice();
    if (device === undefined) {
      return;
    }
    const saved = await this.repository.saveFavorite(device, device.effectiveName, 'nearlink');
    this.favoriteNote = saved.success ? 'saved' : (saved.error?.code ?? '');
    if (saved.success) {
      this.savedFavoriteAddress = device.randomAddress;
    }
    this.pushLog('internal', 'saveFavorite', saved.success ? '' : (saved.error?.nativeCode ?? ''), device.randomAddress, '', '');
  }

  async beginAdvertising(): Promise<void> {
    if (!await this.ensureAccess()) {
      return;
    }
    const interval = parseInt(this.advInterval, 10);
    const uuids: string[] = [];
    if (this.advServiceUuid.trim().length > 0) {
      uuids.push(this.advServiceUuid.trim());
    }
    const started = await this.session.startAdvertising(
      Number.isNaN(interval) ? -1 : interval,
      this.advConnectable,
      this.advIncludeName,
      uuids
    );
    this.advRunning = started.success;
    this.actionMessage = started.success ? '' : (started.error?.code ?? '');
    this.pushLog('out', 'startAdvertising', started.error?.nativeCode ?? '', this.actionMessage, '', '');
  }

  async endAdvertising(): Promise<void> {
    const stopped = await this.session.stopAdvertising();
    this.advRunning = !stopped.success && this.advRunning;
    if (stopped.success) {
      this.advRunning = false;
    }
    this.pushLog('internal', 'stopAdvertising', stopped.error?.nativeCode ?? '', '', '', '');
  }

  addressStale(): boolean {
    return NearLinkScreenRules.addressDiffers(this.savedFavoriteAddress, this.selectedAddress);
  }

  readEnabled(): boolean {
    return NearLinkScreenRules.readEnabled(this.operationBits());
  }

  ssapMtuLive(): number {
    return this.session.mtu();
  }

  async connectSsap(): Promise<void> {
    if (!await this.ensureAccess() || this.selectedAddress.length === 0) {
      return;
    }
    this.ssapConnecting = true;
    this.ssapConnected = false;
    this.connectStartedMs = Date.now();
    this.waitedSec = 0;
    this.armWait();
    const connected = await this.session.connectSsap(this.selectedAddress);
    this.ssapConnecting = false;
    this.clearWait();
    this.ssapConnected = connected.success;
    this.ssapReused = connected.success && connected.value === 'reused';
    this.actionMessage = connected.success ? '' : (connected.error?.code ?? '');
    this.nativeCode = connected.error?.nativeCode ?? '';
    if (connected.success) {
      await this.session.discoverSsap();
    }
    this.pushLog('out', 'connect', this.nativeCode, this.actionMessage, '', '');
  }

  async disconnectSsap(): Promise<void> {
    await this.session.disconnectSsap();
    this.ssapConnected = false;
    this.notifyHint = true;
    this.pushLog('internal', 'disconnect', '', 'notify invalidated', '', '');
  }

  async discoverSsap(): Promise<void> {
    if (!NearLinkScreenRules.discoverAllowed(this.ssapConnected)) {
      this.actionMessage = NearLinkErrorCodes.NOT_CONNECTED;
      this.pushLog('internal', 'getServices', '', 'not connected', '', '');
      return;
    }
    const found = await this.session.discoverSsap();
    this.actionMessage = found.success ? '' : (found.error?.code ?? '');
    this.pushLog('internal', 'getServices', found.error?.nativeCode ?? '', this.actionMessage, '', '');
  }

  async readSsap(): Promise<void> {
    if (!this.readEnabled()) {
      this.actionMessage = NearLinkErrorCodes.SSAP_READ_FAILED;
      this.pushLog('internal', 'readProperty', '', 'not readable', '', '');
      return;
    }
    const result = await this.session.readProperty(this.ssapServiceUuid, this.ssapPropertyUuid, this.operationBits());
    this.actionMessage = result.success ? (result.value ?? '') : (result.error?.code ?? '');
    this.pushLog('in', 'readProperty', result.error?.nativeCode ?? '', this.actionMessage, '', result.value ?? '');
  }

  async writeSsap(sliceConfirmed: boolean): Promise<void> {
    const result = await this.session.writeProperty(
      this.ssapServiceUuid,
      this.ssapPropertyUuid,
      this.ssapHex,
      this.operationBits(),
      this.ssapWithResponse,
      sliceConfirmed
    );
    this.sliceRequired = !result.success && (result.error?.message ?? '').indexOf('slice=required') >= 0;
    this.actionMessage = result.success ? `${result.value ?? 0}` : (result.error?.code ?? '');
    if (result.success) {
      this.sliceRequired = false;
    }
    this.pushLog('out', 'writeProperty', result.error?.nativeCode ?? '', this.actionMessage, '', this.ssapHex);
  }

  async toggleNotify(): Promise<void> {
    const enable = !this.session.notifyArmed();
    const result = await this.session.setNotify(
      this.ssapServiceUuid,
      this.ssapPropertyUuid,
      enable,
      this.operationBits(),
      this.hasClientConfig()
    );
    this.actionMessage = result.success ? '' : (result.error?.code ?? '');
    this.pushLog('out', 'setPropertyNotification', result.error?.nativeCode ?? '', this.actionMessage, '', '');
  }

  async requestMtu(): Promise<void> {
    const mtu = parseInt(this.ssapMtuText, 10);
    const result = await this.session.requestMtu(Number.isNaN(mtu) ? -1 : mtu);
    const rawCode = result.error?.nativeCode ?? '';
    this.mtuNearLink = rawCode === '2900099' || rawCode === `${NearLinkConstants.NATIVE_OPERATION_FAILED}`;
    const native = NearLinkScreenRules.rejectBluetoothMtu(rawCode);
    this.actionMessage = result.success ? `${result.value ?? ''}` : (result.error?.code ?? '');
    if (native === `${NearLinkConstants.NATIVE_OPERATION_FAILED}`) {
      this.nativeCode = native;
    }
    this.pushLog('out', 'requestMtuSize', native, this.actionMessage, '', '');
  }

  openServer(): void {
    const opened = this.session.openServer();
    this.serverOpen = opened.success;
    this.actionMessage = opened.success ? '' : (opened.error?.code ?? '');
  }

  addServerService(): void {
    const added = this.session.addServerService(this.ssapServiceUuid, this.ssapPropertyUuid, this.operationBits());
    this.actionMessage = added.success ? '' : (added.error?.code ?? '');
    this.serverLines = this.session.serverServices();
  }

  closeServer(): void {
    const closed = this.session.closeServer();
    this.serverOpen = false;
    this.serverClosed = closed.success;
    this.pushLog('internal', 'close', closed.error?.nativeCode ?? '', 'server close', '', '');
  }

  async respondServerRead(): Promise<void> {
    if (this.lastReadRequestId < 0) {
      this.actionMessage = NearLinkErrorCodes.NOT_CONNECTED;
      return;
    }
    const responded = await this.session.respondServerRead(this.lastReadRequestId, this.lastReadAddress, this.ssapHex);
    this.actionMessage = responded.success ? `${this.lastReadRequestId}` : (responded.error?.code ?? '');
    this.pushLog('out', 'sendResponse', responded.error?.nativeCode ?? '', `${this.lastReadRequestId} ${this.lastReadAddress}`, '', this.ssapHex);
  }

  async notifyServer(): Promise<void> {
    const notified = await this.session.notifyServer(
      this.lastClientAddress,
      this.ssapServiceUuid,
      this.ssapPropertyUuid,
      this.operationBits(),
      this.ssapHex
    );
    this.actionMessage = notified.success ? '' : (notified.error?.code ?? '');
    this.pushLog('out', 'notifyPropertyChanged', notified.error?.nativeCode ?? '',
      `${this.lastClientAddress} ${this.ssapPropertyUuid}`, '', this.ssapHex);
  }

  removeServerService(): void {
    const removed = this.session.removeServerService(this.ssapServiceUuid);
    this.actionMessage = removed.success ? '' : (removed.error?.code ?? '');
    this.serverLines = this.session.serverServices();
  }

  createPort(): void {
    const created = this.session.createPort(this.portUuid);
    this.portOpen = created.success;
    this.actionMessage = created.success ? '' : (created.error?.code ?? '');
    this.nativeCode = created.error?.nativeCode ?? '';
    this.versionSince = this.readSince(created.error?.message ?? '');
    this.pushLog('internal', 'createPort', this.nativeCode, this.actionMessage, '', '');
  }

  async connectPort(): Promise<void> {
    if (!await this.ensureAccess()) {
      return;
    }
    const connected = await this.session.connectPort(this.selectedAddress, this.portMtu, this.portReliable);
    this.actionMessage = connected.success ? '' : (connected.error?.code ?? '');
    this.nativeCode = connected.error?.nativeCode ?? '';
    this.versionSince = this.readSince(connected.error?.message ?? '');
    this.pushLog('out', 'connect', this.nativeCode, this.actionMessage, '', '');
  }

  async sendPort(): Promise<void> {
    const written = await this.session.writePort(this.ssapHex, this.blockUnencrypted, false);
    this.portSliceRequired = !written.success && (written.error?.message ?? '').indexOf('slice=required') >= 0;
    this.appTx = this.session.appTx();
    this.appRx = this.session.appRx();
    this.actionMessage = written.success ? '' : (written.error?.code ?? '');
    this.nativeCode = written.error?.nativeCode ?? '';
    this.portPacketsTx = this.session.appTxPackets();
    this.pushLog('out', 'writeData', this.nativeCode, `HEX ${this.actionMessage}`, '', written.success ? this.ssapHex : '');
  }

  async sendPortText(sliceConfirmed: boolean = false): Promise<void> {
    const written = await this.session.writePortText(this.portText, this.blockUnencrypted, sliceConfirmed);
    this.portSliceRequired = !written.success && (written.error?.message ?? '').indexOf('slice=required') >= 0;
    this.appTx = this.session.appTx();
    this.appRx = this.session.appRx();
    this.actionMessage = written.success ? '' : (written.error?.code ?? '');
    this.nativeCode = written.error?.nativeCode ?? '';
    this.portPacketsTx = this.session.appTxPackets();
    this.pushLog('out', 'writeData', this.nativeCode, `text bytes`, '', '');
  }

  async confirmPortSlice(): Promise<void> {
    if (this.portText.length > 0) {
      await this.sendPortText(true);
      return;
    }
    const written = await this.session.writePort(this.ssapHex, this.blockUnencrypted, true);
    this.portSliceRequired = !written.success && (written.error?.message ?? '').indexOf('slice=required') >= 0;
    this.appTx = this.session.appTx();
    this.actionMessage = written.success ? '' : (written.error?.code ?? '');
    this.portPacketsTx = this.session.appTxPackets();
    this.pushLog('out', 'writeData', written.error?.nativeCode ?? '', 'HEX slice', '', this.ssapHex);
  }

  async disconnectPort(): Promise<void> {
    await this.session.disconnectPort();
    this.portConnected = false;
    this.portNegotiatedMtu = 0;
    this.pushLog('internal', 'disconnect', '', 'port read off', '', '');
  }

  keepPort(): void {
    this.portHeld = true;
    this.pushLog('internal', 'createPort', '', `held ${this.portUuid}`, '', '');
  }

  destroyPort(): void {
    const destroyed = this.session.destroyPort();
    this.portOpen = !destroyed.success && this.portOpen;
    if (destroyed.success) {
      this.portOpen = false;
    }
    this.pushLog('internal', 'destroyPort', destroyed.error?.nativeCode ?? '', '', '', '');
  }

  async refreshEncryption(): Promise<void> {
    const state = await this.session.refreshEncryption(this.selectedAddress);
    if (!state.success) {
      this.versionSince = this.readSince(state.error?.message ?? '');
      this.actionMessage = state.error?.code ?? '';
      this.security = NearLinkSecurityState.UNKNOWN;
      return;
    }
    this.security = state.value ?? NearLinkSecurityState.UNKNOWN;
  }

  async pair(): Promise<void> {
    if (!await this.ensureAccess() || this.selectedAddress.length === 0) {
      return;
    }
    const paired = await this.session.startPairing(this.selectedAddress);
    if (paired.success && paired.value === 'already_paired') {
      this.pairingToken = 'paired';
      this.pairingReason = 'already_paired';
      this.pushLog('internal', 'startPairing', `${NearLinkConstants.NATIVE_OPERATION_FAILED}`, 'already paired', '', '');
      return;
    }
    this.actionMessage = paired.success ? '' : (paired.error?.code ?? '');
    this.versionSince = this.readSince(paired.error?.message ?? '');
    this.pushLog('out', 'startPairing', paired.error?.nativeCode ?? '', this.actionMessage, '', '');
  }

  async exportLogs(): Promise<void> {
    const text = NearLinkLogBook.format(this.visibleLogs());
    if (text.length === 0) {
      this.exportFailed = true;
      this.actionMessage = '';
      return;
    }
    const exported = await this.session.exportLog(text);
    this.exportFailed = !exported.success;
    this.logs = NearLinkLogBook.retainOnFailure(this.logs);
    this.actionMessage = exported.success ? 'exported' : (exported.error?.code ?? '');
  }

  visibleLogs(): NearLinkLogEntry[] {
    const next: NearLinkLogEntry[] = [];
    for (let i = 0; i < this.logs.length; i++) {
      const entry = this.logs[i];
      if (this.logFilter === 1 && entry.nativeCode.length === 0) {
        continue;
      }
      if (this.logFilter === 2 && entry.apiName !== 'requestPermissionsFromUser') {
        continue;
      }
      if (this.logFilter === 3 && entry.direction === 'internal') {
        continue;
      }
      next.push(entry);
    }
    return next;
  }

  selectedLog(): NearLinkLogEntry | undefined {
    for (let i = 0; i < this.logs.length; i++) {
      if (this.logs[i].id === this.selectedLogId) {
        return this.logs[i];
      }
    }
    return undefined;
  }

  selectedDevice(): NearLinkDevice | undefined {
    for (let i = 0; i < this.devices.length; i++) {
      if (this.devices[i].randomAddress === this.selectedAddress) {
        return this.devices[i];
      }
    }
    return undefined;
  }

  pairedMatch(): boolean {
    if (this.pairedVersionUnavailable) {
      return false;
    }
    for (let i = 0; i < this.pairedAddresses.length; i++) {
      if (this.pairedAddresses[i] === this.selectedAddress) {
        return true;
      }
    }
    return false;
  }

  showPairedEmpty(): boolean {
    return NearLinkPairedPresentation.showEmptyAsNone(this.pairedVersionUnavailable, this.pairedAddresses.length);
  }

  loadingModel(): YoLoadingStateModel {
    return new YoLoadingStateModel($r('app.string.nl_support_query'), true);
  }

  supportError(): YoErrorStateModel {
    return new YoErrorStateModel(
      this.supportErrorTitle(),
      this.versionSince.length > 0 ? this.versionSince : '',
      $r('app.string.nl_settings_path_a'),
      '',
      this.nativeCode,
      false,
      ''
    );
  }

  scanEmpty(): YoEmptyStateModel {
    const title = this.scanPhase === NearLinkScanUiPhase.IDLE ?
      $r('app.string.nl_scan_idle') : $r('app.string.nl_scan_empty');
    return new YoEmptyStateModel(title, '', '', '', '');
  }

  async openAppSettings(): Promise<void> {
    const context = AbilityContextRegistry.getInstance().get();
    if (context !== undefined) {
      await BluetoothSettingsNavigator.openAppPermissionSettings(context);
    }
  }

  actionLabel(): ResourceStr {
    return this.labelFor(this.actionMessage);
  }

  filterLabel(): ResourceStr {
    return this.labelFor(this.filterMessage);
  }

  supportLabel(): ResourceStr {
    if (this.supportCategory === NearLinkSupportCategory.SUPPORTED) {
      return $r('app.string.nl_support_yes');
    }
    if (this.supportCategory === NearLinkSupportCategory.UNSUPPORTED ||
      this.supportCategory === NearLinkSupportCategory.CAPABILITY) {
      return $r('app.string.nl_support_no');
    }
    if (this.supportCategory === NearLinkSupportCategory.VERSION) {
      return $r('app.string.nl_version_unavailable');
    }
    if (this.supportCategory === NearLinkSupportCategory.EMULATOR) {
      return $r('app.string.nl_need_device');
    }
    return $r('app.string.nl_support_query');
  }

  radioLabel(): ResourceStr {
    if (this.radioCategory === NearLinkRadioCategory.ON) {
      return $r('app.string.nl_radio_on');
    }
    if (this.radioCategory === NearLinkRadioCategory.OFF) {
      return $r('app.string.nl_radio_off');
    }
    if (this.radioCategory === NearLinkRadioCategory.TURNING_ON) {
      return $r('app.string.nl_radio_turning_on');
    }
    if (this.radioCategory === NearLinkRadioCategory.TURNING_OFF) {
      return $r('app.string.nl_radio_turning_off');
    }
    return $r('app.string.nl_local_unread');
  }

  private labelFor(code: string): ResourceStr {
    if (code === NearLinkErrorCodes.VERSION_UNAVAILABLE) {
      return $r('app.string.nl_version_unavailable');
    }
    if (code === NearLinkErrorCodes.HEX_INVALID) {
      return $r('app.string.nl_hex_invalid');
    }
    if (code === NearLinkErrorCodes.WRITE_TYPE_UNSUPPORTED) {
      return $r('app.string.nl_write_type');
    }
    if (code === NearLinkErrorCodes.SSAP_MTU_RANGE) {
      return $r('app.string.nl_mtu_range');
    }
    if (code === NearLinkErrorCodes.DT_INVALID_PARAMS) {
      return $r('app.string.nl_port_mtu_range');
    }
    if (code === NearLinkErrorCodes.DT_WRITE_CONGESTED) {
      return $r('app.string.nl_congest');
    }
    if (code === NearLinkErrorCodes.NOT_CONNECTED) {
      return $r('app.string.nl_not_connected');
    }
    if (code === NearLinkErrorCodes.BLOCKED_UNENCRYPTED) {
      return $r('app.string.nl_block_send');
    }
    if (code === NearLinkErrorCodes.NOTIFY_UNSUPPORTED) {
      return $r('app.string.nl_notify_undeclared');
    }
    if (code === NearLinkErrorCodes.SSAP_READ_FAILED) {
      return $r('app.string.nl_read_unsupported');
    }
    if (code === NearLinkErrorCodes.EMULATOR_UNAVAILABLE) {
      return $r('app.string.nl_need_device');
    }
    if (code === NearLinkErrorCodes.SWITCH_OFF) {
      return $r('app.string.nl_radio_off');
    }
    if (code === NearLinkErrorCodes.EMPTY_FILTER) {
      return $r('app.string.nl_need_filter');
    }
    if (code === NearLinkErrorCodes.DURATION_RANGE) {
      return $r('app.string.nl_duration_range');
    }
    if (code === NearLinkErrorCodes.NAME_LENGTH) {
      return $r('app.string.nl_name_length');
    }
    if (code === NearLinkErrorCodes.MANUFACTURER_DATA_NEEDS_ID) {
      return $r('app.string.nl_mfg_need_id');
    }
    if (code === NearLinkErrorCodes.MASK_LENGTH_MISMATCH) {
      return $r('app.string.nl_mask_len');
    }
    if (code === NearLinkErrorCodes.MANUFACTURER_ID_RANGE) {
      return $r('app.string.nl_mfg_id_range');
    }
    if (code === NearLinkErrorCodes.ADV_INTERVAL_RANGE) {
      return $r('app.string.nl_adv_interval_range');
    }
    if (code === NearLinkErrorCodes.DT_UUID_REGISTERED) {
      return $r('app.string.nl_port_registered');
    }
    if (code === NearLinkErrorCodes.DT_PORT_LIMIT) {
      return $r('app.string.nl_port_limit');
    }
    if (code === NearLinkErrorCodes.DT_UUID_NOT_REGISTERED) {
      return $r('app.string.nl_port_missing');
    }
    if (code === NearLinkErrorCodes.VALIDATION) {
      return $r('app.string.nl_field_invalid');
    }
    if (code === 'exported') {
      return $r('app.string.nl_export_copied');
    }
    return code;
  }

  private supportErrorTitle(): ResourceStr {
    if (this.supportCategory === NearLinkSupportCategory.VERSION) {
      return $r('app.string.nl_version_unavailable');
    }
    if (this.supportCategory === NearLinkSupportCategory.EMULATOR) {
      return $r('app.string.nl_need_device');
    }
    if (this.supportCategory === NearLinkSupportCategory.CAPABILITY) {
      return $r('app.string.nl_not_radio_off');
    }
    return $r('app.string.nl_support_no');
  }

  private async ensureAccess(): Promise<boolean> {
    const decision = await this.ensurePermission.execute(PermissionScenario.NEARLINK_ACCESS);
    this.permissionAsked = true;
    this.permissionGranted = decision.granted;
    this.permissionUi = decision.uiState;
    this.pushLog('internal', 'requestPermissionsFromUser', decision.granted ? '' : `${NearLinkConstants.NATIVE_PERMISSION}`,
      'ACCESS_NEARLINK', '', '');
    return decision.granted;
  }

  private currentFilter(): NearLinkScanFilter {
    return NearLinkScanForm.toFilter(
      this.filterAddress,
      this.filterName,
      this.filterManufacturerId,
      this.filterManufacturerData,
      this.filterManufacturerMask,
      this.filterRssi,
      this.session.systemRssiAvailable(),
      NearLinkScanForm.modeFromIndex(this.scanModeIndex),
      this.filterDuration,
      this.filterScanAll,
      this.filterUuid,
      this.filterUuidEnabled,
      this.filterAddressB,
      this.filterNameB
    );
  }

  private async loadPaired(): Promise<void> {
    const paired = this.session.readPaired();
    if (!paired.success || paired.value === undefined) {
      return;
    }
    this.pairedVersionUnavailable = paired.value.versionUnavailable;
    this.pairedAddresses = paired.value.addresses;
    if (paired.value.versionUnavailable) {
      this.versionSince = paired.value.since;
    }
  }

  private refreshDetail(): void {
    const packet = this.repository.getAdvertising(this.selectedAddress);
    if (packet === undefined || packet.isEmpty) {
      this.detailEmpty = true;
      this.detailHex = '';
      this.detailCompleteName = '';
      this.detailShortName = '';
      this.detailReportedName = packet === undefined ? '' : packet.reportedDeviceName;
      this.detailWarnings = '';
      this.detailServiceText = '';
      this.detailManufacturerText = '';
      this.detailUnknownText = '';
      this.detailNameBytes = -1;
      return;
    }
    this.detailEmpty = false;
    this.detailHex = packet.rawHex;
    this.detailCompleteName = packet.completeLocalName;
    this.detailShortName = packet.shortLocalName;
    this.detailReportedName = packet.reportedDeviceName;
    this.detailNameBytes = packet.deviceInfoNameByteLength;
    this.detailWarnings = packet.parseWarnings.join(' ');
    const services: string[] = [];
    for (let i = 0; i < packet.serviceData.length; i++) {
      services.push(`${packet.serviceData[i].serviceUuid} ${packet.serviceData[i].dataHex}`);
    }
    for (let i = 0; i < packet.serviceUuids.length; i++) {
      services.push(packet.serviceUuids[i]);
    }
    this.detailServiceText = services.join('\n');
    const makers: string[] = [];
    for (let i = 0; i < packet.manufacturerData.length; i++) {
      makers.push(`${packet.manufacturerData[i].manufacturerId} ${packet.manufacturerData[i].dataHex}`);
    }
    this.detailManufacturerText = makers.join('\n');
    const unknown: string[] = [];
    for (let i = 0; i < packet.unknownTlvs.length; i++) {
      unknown.push(`${packet.unknownTlvs[i].typeCode} ${packet.unknownTlvs[i].valueHex}`);
    }
    this.detailUnknownText = unknown.join('\n');
  }

  private applyRadio(code: number): void {
    if (code === 1) {
      this.radioCategory = NearLinkRadioCategory.ON;
    } else if (code === 3) {
      this.radioCategory = NearLinkRadioCategory.OFF;
    } else if (code === 0) {
      this.radioCategory = NearLinkRadioCategory.TURNING_ON;
    } else if (code === 2) {
      this.radioCategory = NearLinkRadioCategory.TURNING_OFF;
    } else {
      this.radioCategory = NearLinkRadioCategory.UNKNOWN;
    }
    void this.refreshLocalName();
  }

  private async stopScanFromBackground(): Promise<void> {
    if (this.scanPhase !== NearLinkScanUiPhase.SCANNING) {
      return;
    }
    await this.stopScanIfNeeded();
    this.scanPhase = NearLinkScanUiPhase.STOPPED;
  }

  private async stopScanIfNeeded(): Promise<void> {
    this.clearDuration();
    if (this.scanPhase !== NearLinkScanUiPhase.SCANNING && this.scanSessionId.length === 0) {
      return;
    }
    await this.stopScanUseCase.execute(this.scanSessionId);
    this.scanSessionId = '';
    this.pushLog('internal', 'stopScan', '', 'deviceFound off', '', '');
  }

  private armDuration(seconds: number): void {
    this.clearDuration();
    if (!NearLinkScreenRules.durationElapsed(seconds, seconds)) {
      return;
    }
    this.durationTimer = setTimeout(() => {
      this.durationTimer = -1;
      void this.finishTimedScan(seconds);
    }, seconds * 1000);
  }

  private async finishTimedScan(seconds: number): Promise<void> {
    if (this.scanPhase !== NearLinkScanUiPhase.SCANNING) {
      return;
    }
    await this.stopScanIfNeeded();
    this.scanPhase = NearLinkScanUiPhase.STOPPED;
    this.pushLog('internal', 'stopScan', '', `duration=${seconds}`, '', '');
  }

  private clearDuration(): void {
    if (this.durationTimer >= 0) {
      clearTimeout(this.durationTimer);
      this.durationTimer = -1;
    }
  }

  private armWait(): void {
    this.clearWait();
    this.waitTimer = setInterval(() => {
      if (!this.ssapConnecting) {
        this.clearWait();
        return;
      }
      this.waitedSec = Math.floor((Date.now() - this.connectStartedMs) / 1000);
    }, 1000);
  }

  private clearWait(): void {
    if (this.waitTimer >= 0) {
      clearInterval(this.waitTimer);
      this.waitTimer = -1;
    }
  }

  private noteScanHex(devices: NearLinkDevice[]): void {
    for (let i = 0; i < devices.length; i++) {
      const device = devices[i];
      if (device.rawHex.length === 0) {
        continue;
      }
      const key = `${device.randomAddress}|${device.rawHex}`;
      if (this.loggedHex.indexOf(key) >= 0) {
        continue;
      }
      this.loggedHex.push(key);
      this.pushLog('in', 'deviceFound', '', device.randomAddress, '', device.rawHex);
    }
  }

  notifyArmed(): boolean {
    return this.session.notifyArmed();
  }

  private leavesScan(next: string): boolean {
    const onScan = this.destination === NearLinkDestination.SCAN || this.destination === NearLinkDestination.DETAIL;
    const stays = next === NearLinkDestination.SCAN || next === NearLinkDestination.DETAIL;
    return onScan && !stays;
  }

  private operationBits(): number {
    const parsed = parseInt(this.ssapOperation, 10);
    return Number.isNaN(parsed) ? 0 : parsed;
  }

  private hasClientConfig(): boolean {
    for (let i = 0; i < this.services.length; i++) {
      const properties = this.services[i].properties;
      for (let j = 0; j < properties.length; j++) {
        if (properties[j].propertyUuid === this.ssapPropertyUuid) {
          return properties[j].hasClientConfig;
        }
      }
    }
    return false;
  }

  private pushServerLine(line: string): void {
    const next: string[] = [];
    for (let i = 0; i < this.serverLines.length; i++) {
      next.push(this.serverLines[i]);
    }
    next.push(line);
    this.serverLines = next;
  }

  private pushLog(
    direction: string,
    apiName: string,
    nativeCode: string,
    summary: string,
    reasonMsg: string,
    hex: string
  ): void {
    this.logSerial += 1;
    const entry = new NearLinkLogEntry(
      `${this.logSerial}`,
      Date.now(),
      direction,
      apiName,
      nativeCode,
      summary,
      reasonMsg,
      hex,
      false
    );
    const next: NearLinkLogEntry[] = [];
    for (let i = 0; i < this.logs.length; i++) {
      next.push(this.logs[i]);
    }
    next.push(entry);
    this.logs = next;
  }

  private readSince(message: string): string {
    const marker = 'since=';
    const index = message.indexOf(marker);
    if (index < 0) {
      return this.versionSince;
    }
    return message.substring(index + marker.length);
  }
}

export class NearLinkGapPage {
  static cdsmId(): string {
    return NearLinkGap.CDSM;
  }
}
