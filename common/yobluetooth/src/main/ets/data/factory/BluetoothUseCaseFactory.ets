import {
  CreateSessionUseCase,
  EnsurePermissionUseCase,
  SendCommandUseCase,
  SessionRuntimeStore,
  StartSessionUseCase,
  StopSessionUseCase,
  TransportSessionRegistry
} from 'debug_core';
import { BluetoothRepository } from '../repository/BluetoothRepository';
import { BluetoothRepositoryContract } from '../../domain/repository/BluetoothRepositoryContract';
import { PairingCoordinator } from '../../domain/service/PairingCoordinator';
import { SppSessionAdmissionPolicy } from '../../domain/service/spp/SppSessionAdmissionPolicy';
import { SppSessionCatalog } from '../../domain/service/spp/SppSessionCatalog';
import { SppSessionLedger } from '../../domain/service/spp/SppSessionLedger';
import { GattOperationQueue } from '../../domain/service/GattOperationQueue';
import { BluetoothOperationGuard } from '../../domain/usecase/shared/BluetoothOperationGuard';
import { BluetoothSessionBootstrap } from '../../domain/usecase/shared/BluetoothSessionBootstrap';
import { EnableBluetoothUseCase, DisableBluetoothUseCase } from '../../domain/usecase/classic/AdapterSwitchUseCases';
import {
  ListSppSessionsUseCase,
  LoadPairedClassicDevicesUseCase,
  ObserveClassicDevicesUseCase,
  ObservePairingEventsUseCase,
  PairBluetoothDeviceUseCase,
  StartClassicScanUseCase,
  StopClassicScanUseCase
} from '../../domain/usecase/classic/ClassicScanUseCases';
import { SendSppCommandUseCase } from '../../domain/usecase/classic/SppCommandUseCases';
import { ConnectSppUseCase, DisconnectSppUseCase } from '../../domain/usecase/classic/SppConnectionUseCases';
import { BridgeBleToClassicPairUseCase, ResolveSppTargetAddressUseCase } from '../../domain/usecase/classic/SppAddressUseCases';
import { SppListenUseCase } from '../../domain/usecase/classic/SppServerUseCases';
import {
  ObserveSppSessionsUseCase,
  QuerySppConnectEligibilityUseCase,
  QuerySppMaxTransmitUseCase
} from '../../domain/usecase/classic/SppSessionQueryUseCases';
import { SppUuidFavoriteUseCases } from '../../domain/usecase/classic/SppUuidFavoriteUseCases';
import { SaveBluetoothFavoriteUseCase } from '../../domain/usecase/device/DeviceFavoriteUseCases';
import {
  LoadBluetoothOverviewSnapshotUseCase
} from '../../domain/usecase/overview/OverviewUseCases';
import {
  ObserveBleDevicesUseCase,
  StartBleScanUseCase,
  StopBleScanUseCase
} from '../../domain/usecase/ble/BleScanUseCases';
import { StartBleAdvertiseUseCase, StopBleAdvertiseUseCase } from '../../domain/usecase/ble/BleAdvertiseUseCases';
import {
  CloseGattServerUseCase,
  NotifyGattServerUseCase,
  OpenGattServerUseCase
} from '../../domain/usecase/ble/GattServerUseCases';
import { ConnectGattUseCase, DisconnectGattUseCase } from '../../domain/usecase/ble/GattConnectionUseCases';
import {
  DiscoverGattServicesUseCase,
  ReadGattCharacteristicUseCase,
  ReadGattDescriptorUseCase,
  ReadGattRssiUseCase,
  RequestBleMtuUseCase,
  SetGattNotificationUseCase,
  UpdateGattConnectionParamUseCase,
  WriteGattCharacteristicUseCase,
  WriteGattDescriptorUseCase
} from '../../domain/usecase/ble/GattOperationUseCases';

/**
 * Composition root. Domain use cases take the repository contract and collaborators
 * as required arguments; this factory is the only place that names the singletons.
 */
export class BluetoothUseCaseFactory {
  static repository(): BluetoothRepositoryContract {
    return BluetoothRepository.getInstance();
  }

  static guard(): BluetoothOperationGuard {
    return new BluetoothOperationGuard(new EnsurePermissionUseCase(), BluetoothUseCaseFactory.repository());
  }

  static bootstrap(): BluetoothSessionBootstrap {
    return new BluetoothSessionBootstrap(new CreateSessionUseCase(), new StartSessionUseCase());
  }

  static catalog(): SppSessionCatalog {
    return new SppSessionCatalog(
      TransportSessionRegistry.getInstance(),
      SessionRuntimeStore.getInstance(),
      SppSessionLedger.getInstance()
    );
  }

  static loadOverviewSnapshot(): LoadBluetoothOverviewSnapshotUseCase {
    return new LoadBluetoothOverviewSnapshotUseCase(
      BluetoothUseCaseFactory.repository(),
      new EnsurePermissionUseCase()
    );
  }

  static enableBluetooth(): EnableBluetoothUseCase {
    return new EnableBluetoothUseCase(BluetoothUseCaseFactory.repository(), BluetoothUseCaseFactory.guard());
  }

  static disableBluetooth(): DisableBluetoothUseCase {
    return new DisableBluetoothUseCase(BluetoothUseCaseFactory.repository(), BluetoothUseCaseFactory.guard());
  }

  static sppListen(): SppListenUseCase {
    return new SppListenUseCase(BluetoothUseCaseFactory.repository(), BluetoothUseCaseFactory.guard());
  }

  static loadPairedClassic(): LoadPairedClassicDevicesUseCase {
    return new LoadPairedClassicDevicesUseCase(BluetoothUseCaseFactory.repository(), BluetoothUseCaseFactory.guard());
  }

  static observeClassicDevices(): ObserveClassicDevicesUseCase {
    return new ObserveClassicDevicesUseCase(BluetoothUseCaseFactory.repository());
  }

  static startClassicScan(): StartClassicScanUseCase {
    return new StartClassicScanUseCase(
      BluetoothUseCaseFactory.repository(),
      BluetoothUseCaseFactory.guard(),
      BluetoothUseCaseFactory.bootstrap()
    );
  }

  static stopClassicScan(): StopClassicScanUseCase {
    return new StopClassicScanUseCase(BluetoothUseCaseFactory.repository(), new StopSessionUseCase());
  }

  static listSppSessions(): ListSppSessionsUseCase {
    return new ListSppSessionsUseCase(BluetoothUseCaseFactory.catalog());
  }

  static observeSppSessions(): ObserveSppSessionsUseCase {
    return new ObserveSppSessionsUseCase(SessionRuntimeStore.getInstance(), BluetoothUseCaseFactory.catalog());
  }

  static disconnectSpp(): DisconnectSppUseCase {
    return new DisconnectSppUseCase();
  }

  static connectSpp(): ConnectSppUseCase {
    const repository = BluetoothUseCaseFactory.repository();
    return new ConnectSppUseCase(
      repository,
      BluetoothUseCaseFactory.guard(),
      BluetoothUseCaseFactory.bootstrap(),
      TransportSessionRegistry.getInstance(),
      new ResolveSppTargetAddressUseCase(repository),
      SppSessionLedger.getInstance()
    );
  }

  static querySppEligibility(): QuerySppConnectEligibilityUseCase {
    return new QuerySppConnectEligibilityUseCase(
      new SppSessionAdmissionPolicy(SppSessionLedger.getInstance())
    );
  }

  static sppUuidFavorites(): SppUuidFavoriteUseCases {
    return new SppUuidFavoriteUseCases(BluetoothUseCaseFactory.repository());
  }

  static pairDevice(): PairBluetoothDeviceUseCase {
    return new PairBluetoothDeviceUseCase(BluetoothUseCaseFactory.repository(), BluetoothUseCaseFactory.guard());
  }

  static observePairing(): ObservePairingEventsUseCase {
    return new ObservePairingEventsUseCase(PairingCoordinator.getInstance());
  }

  static startBleScan(): StartBleScanUseCase {
    return new StartBleScanUseCase(
      BluetoothUseCaseFactory.repository(),
      BluetoothUseCaseFactory.guard(),
      BluetoothUseCaseFactory.bootstrap()
    );
  }

  static stopBleScan(): StopBleScanUseCase {
    return new StopBleScanUseCase(BluetoothUseCaseFactory.repository(), new StopSessionUseCase());
  }

  static observeBleDevices(): ObserveBleDevicesUseCase {
    return new ObserveBleDevicesUseCase(BluetoothUseCaseFactory.repository());
  }

  static saveFavorite(): SaveBluetoothFavoriteUseCase {
    return new SaveBluetoothFavoriteUseCase(BluetoothUseCaseFactory.repository());
  }

  static bridgeBleToClassic(): BridgeBleToClassicPairUseCase {
    const repository = BluetoothUseCaseFactory.repository();
    return new BridgeBleToClassicPairUseCase(
      repository,
      new PairBluetoothDeviceUseCase(repository, BluetoothUseCaseFactory.guard())
    );
  }

  static startBleAdvertise(): StartBleAdvertiseUseCase {
    return new StartBleAdvertiseUseCase(BluetoothUseCaseFactory.repository(), BluetoothUseCaseFactory.guard());
  }

  static stopBleAdvertise(): StopBleAdvertiseUseCase {
    return new StopBleAdvertiseUseCase(BluetoothUseCaseFactory.repository());
  }

  static openGattServer(): OpenGattServerUseCase {
    return new OpenGattServerUseCase(BluetoothUseCaseFactory.repository(), BluetoothUseCaseFactory.guard());
  }

  static closeGattServer(): CloseGattServerUseCase {
    return new CloseGattServerUseCase(BluetoothUseCaseFactory.repository());
  }

  static notifyGattServer(): NotifyGattServerUseCase {
    return new NotifyGattServerUseCase(BluetoothUseCaseFactory.repository());
  }

  static connectGatt(): ConnectGattUseCase {
    return new ConnectGattUseCase(
      BluetoothUseCaseFactory.repository(),
      BluetoothUseCaseFactory.guard(),
      BluetoothUseCaseFactory.bootstrap(),
      TransportSessionRegistry.getInstance()
    );
  }

  static disconnectGatt(): DisconnectGattUseCase {
    return new DisconnectGattUseCase(
      TransportSessionRegistry.getInstance(),
      new StopSessionUseCase(),
      BluetoothUseCaseFactory.repository()
    );
  }

  static discoverGattServices(): DiscoverGattServicesUseCase {
    return new DiscoverGattServicesUseCase(BluetoothUseCaseFactory.repository());
  }

  static readGattCharacteristic(): ReadGattCharacteristicUseCase {
    return new ReadGattCharacteristicUseCase(BluetoothUseCaseFactory.repository(), new GattOperationQueue());
  }

  static writeGattCharacteristic(): WriteGattCharacteristicUseCase {
    return new WriteGattCharacteristicUseCase(BluetoothUseCaseFactory.repository(), new GattOperationQueue());
  }

  static readGattDescriptor(): ReadGattDescriptorUseCase {
    return new ReadGattDescriptorUseCase(BluetoothUseCaseFactory.repository(), new GattOperationQueue());
  }

  static writeGattDescriptor(): WriteGattDescriptorUseCase {
    return new WriteGattDescriptorUseCase(BluetoothUseCaseFactory.repository(), new GattOperationQueue());
  }

  static setGattNotification(): SetGattNotificationUseCase {
    return new SetGattNotificationUseCase(BluetoothUseCaseFactory.repository(), new GattOperationQueue());
  }

  static requestBleMtu(): RequestBleMtuUseCase {
    return new RequestBleMtuUseCase(BluetoothUseCaseFactory.repository(), new GattOperationQueue());
  }

  static readGattRssi(): ReadGattRssiUseCase {
    return new ReadGattRssiUseCase(BluetoothUseCaseFactory.repository());
  }

  static updateGattConnectionParam(): UpdateGattConnectionParamUseCase {
    return new UpdateGattConnectionParamUseCase(BluetoothUseCaseFactory.repository());
  }

  static querySppMaxTransmit(): QuerySppMaxTransmitUseCase {
    return new QuerySppMaxTransmitUseCase(TransportSessionRegistry.getInstance());
  }

  static sendSppCommand(): SendSppCommandUseCase {
    return new SendSppCommandUseCase(new SendCommandUseCase(), TransportSessionRegistry.getInstance());
  }
}
