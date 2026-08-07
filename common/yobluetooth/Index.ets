export { BluetoothRepository } from './src/main/ets/data/repository/BluetoothRepository';
// L1–L3 SPP concretes (SppPlatformGateway / SppRfcommClient / SppTransportSession) stay module-internal.
export { GattTransportSession } from './src/main/ets/data/transport/GattTransportSession';
export {
  StartClassicScanUseCase,
  StopClassicScanUseCase,
  PairBluetoothDeviceUseCase,
  ObservePairingEventsUseCase,
  LoadPairedClassicDevicesUseCase,
  ObserveClassicDevicesUseCase,
  ListSppSessionsUseCase
} from './src/main/ets/domain/usecase/classic/ClassicScanUseCases';
export {
  ConnectSppUseCase,
  DisconnectSppUseCase
} from './src/main/ets/domain/usecase/classic/SppConnectionUseCases';
export {
  QuerySppConnectEligibilityUseCase,
  ObserveSppSessionsUseCase
} from './src/main/ets/domain/usecase/classic/SppSessionQueryUseCases';
export {
  ResolveSppTargetAddressUseCase,
  BridgeBleToClassicPairUseCase,
  ResolveGattTargetAddressUseCase
} from './src/main/ets/domain/usecase/classic/SppAddressUseCases';
export { SendSppCommandUseCase } from './src/main/ets/domain/usecase/classic/SppCommandUseCases';
export {
  StartBleScanUseCase,
  StopBleScanUseCase,
  StartBleScanWithFilterUseCase,
  LoadPairedBleDevicesUseCase,
  ObserveBleDevicesUseCase
} from './src/main/ets/domain/usecase/ble/BleScanUseCases';
export {
  ConnectUartUseCase,
  DisconnectUartUseCase
} from './src/main/ets/domain/usecase/uart/UartConnectionUseCases';
export { SerialProfileMatcher } from './src/main/ets/domain/service/uart/SerialProfileMatcher';
export { CommandWriteQueue } from './src/main/ets/domain/service/queue/CommandWriteQueue';
export { SppSessionAdmissionPolicy } from './src/main/ets/domain/service/spp/SppSessionAdmissionPolicy';
export { SppSessionLedger, SppLedgerEntry } from './src/main/ets/domain/service/spp/SppSessionLedger';
export { SppSessionCatalog } from './src/main/ets/domain/service/spp/SppSessionCatalog';
export { SppUuidLabel } from './src/main/ets/domain/service/spp/SppUuidLabel';
export { SppLedgerPhase } from './src/main/ets/domain/model/spp/SppLedgerPhase';
export {
  ISppTransportFacet,
  asSppTransportFacet
} from './src/main/ets/domain/model/spp/ISppTransportFacet';
export { SppSessionTeardown } from './src/main/ets/domain/service/spp/SppSessionTeardown';
export { SppReconnectCoordinator } from './src/main/ets/domain/service/SppReconnectCoordinator';
export {
  ClassicBluetoothRepositoryFacet,
  SppBluetoothRepositoryFacet,
  BleScanRepositoryFacet,
  GattBluetoothRepositoryFacet
} from './src/main/ets/domain/repository/BluetoothRepositoryFacets';
export {
  BluetoothSessionKind,
  SessionLifecycle,
  BluetoothSessionSummary
} from './src/main/ets/domain/model/session/BluetoothSessionKind';
export {
  UartConnectPhase,
  SerialProfileId,
  ProfileMatchResult
} from './src/main/ets/domain/model/uart/UartConnectPhase';
export {
  ConnectGattUseCase,
  DisconnectGattUseCase
} from './src/main/ets/domain/usecase/ble/GattConnectionUseCases';
export {
  DiscoverGattServicesUseCase,
  ReadGattCharacteristicUseCase,
  WriteGattCharacteristicUseCase,
  SetGattNotificationUseCase,
  RequestBleMtuUseCase
} from './src/main/ets/domain/usecase/ble/GattOperationUseCases';
export { ConnectGattBrowserUseCase } from './src/main/ets/domain/usecase/ble/GattBrowserUseCases';
export {
  LoadBluetoothOverviewUseCase,
  LoadBluetoothOverviewSnapshotUseCase,
  ResolveBluetoothCapabilityUseCase,
  ObserveBluetoothDevicesUseCase
} from './src/main/ets/domain/usecase/overview/OverviewUseCases';
export {
  SaveBluetoothFavoriteUseCase,
  LoadRemoteProfileUuidsUseCase
} from './src/main/ets/domain/usecase/device/DeviceFavoriteUseCases';
export { BluetoothSubscriptionBundle } from './src/main/ets/domain/usecase/shared/BluetoothSubscriptionBundle';
export {
  BluetoothDevice,
  BluetoothDeviceDraft,
  BluetoothOverviewSnapshot,
  BluetoothAdapterSnapshot,
  BluetoothCapabilitySnapshot
} from './src/main/ets/domain/model/BluetoothDevice';
export {
  BluetoothTransportType,
  BluetoothListRail,
  AddressPrivacyKind,
  BluetoothRawAddrKind,
  BluetoothTransportPolicy
} from './src/main/ets/domain/model/BluetoothTransportType';
export { DeviceIdentity, IdentityStability } from './src/main/ets/domain/model/DeviceIdentity';
export { PairingState, PairingEvent } from './src/main/ets/domain/model/PairingState';
export { SppConnectParams } from './src/main/ets/domain/model/SppConnectParams';
export { SppUuidPreset } from './src/main/ets/domain/model/SppUuidPreset';
export { SppUuidFavoriteEntry } from './src/main/ets/domain/model/SppUuidFavoriteEntry';
export { SppUuidFavoriteUseCases } from './src/main/ets/domain/usecase/classic/SppUuidFavoriteUseCases';
export { SppSessionKey } from './src/main/ets/domain/model/SppSessionKey';
export { SppSessionDescriptor } from './src/main/ets/domain/model/SppSessionDescriptor';
export { GattConnectParams } from './src/main/ets/domain/model/GattConnectParams';
export { BleScanFilter } from './src/main/ets/domain/model/BleScanFilter';
export { ClassicScanFilter, ClassicDeviceMajorFilter } from './src/main/ets/domain/model/ClassicScanFilter';
export { ClassicScanCapability } from './src/main/ets/domain/model/ClassicScanCapability';
export { ClassicProfileCapability } from './src/main/ets/domain/service/ClassicProfileCapability';
export { BleAdvertisingPacket, DeviceNameSource } from './src/main/ets/domain/model/BleAdvertisingPacket';
export { GattServiceTreeSnapshot } from './src/main/ets/domain/model/GattServiceTree';
export { ReconnectPolicy } from './src/main/ets/domain/model/ReconnectPolicy';
export { BleSerialEndpoints } from './src/main/ets/domain/model/BleSerialPreset';
export { GattCharacteristicRef, GattDescriptorRef, GattCharacteristicChangeEvent } from './src/main/ets/domain/model/GattCharacteristicRef';
export { BluetoothErrorCodes } from './src/main/ets/constants/BluetoothErrorCodes';
export { BluetoothConstants } from './src/main/ets/constants/BluetoothConstants';
export { BluetoothRepositoryContract } from './src/main/ets/domain/repository/BluetoothRepositoryContract';
export { BluetoothDeviceVerificationChecklist } from './src/main/ets/data/verification/BluetoothDeviceVerificationChecklist';
export { ScanResultMergeQueue } from './src/main/ets/domain/service/ScanResultMergeQueue';
export { ClassicScanPhase } from './src/main/ets/domain/model/ClassicScanPhase';
export { BleScanPhase } from './src/main/ets/domain/model/BleScanPhase';
export {
  SppTerminalStatusKind,
  ClassicScanStatusKind,
  BleScanStatusKind
} from './src/main/ets/domain/model/BluetoothStatusKind';
export { SppConnectFailureHints } from './src/main/ets/domain/service/SppConnectFailureHints';
