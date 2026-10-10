import { AbilityContextRegistry, BluetoothSettingsNavigator } from 'common_platform';
import {
  BluetoothDevice,
  BluetoothDeviceDraft,
  BluetoothUseCaseFactory,
  BridgeBleToClassicPairUseCase,
  SaveBluetoothFavoriteUseCase
} from 'yobluetooth';

@ObservedV2
export class DeviceIdentityViewModel {
  @Trace message: string = '';

  private readonly favorite: SaveBluetoothFavoriteUseCase = BluetoothUseCaseFactory.saveFavorite();
  private readonly bridgePair: BridgeBleToClassicPairUseCase = BluetoothUseCaseFactory.bridgeBleToClassic();

  async saveBookmark(deviceId: string, displayName: string, addressText: string): Promise<void> {
    const draft = new BluetoothDeviceDraft();
    draft.bleDeviceId = deviceId;
    draft.displayName = displayName;
    draft.primaryDeviceId = deviceId.length > 0 ? deviceId : addressText;
    const saved = await this.favorite.execute(new BluetoothDevice(draft), displayName, 'ble');
    this.message = saved.success ? '' : (saved.error?.message ?? '');
  }

  async pairFromBle(deviceId: string, displayName: string): Promise<void> {
    const paired = await this.bridgePair.execute(deviceId, displayName);
    this.message = paired.success ? '' : (paired.error?.message ?? '');
  }

  async openSettings(): Promise<void> {
    const context = AbilityContextRegistry.getInstance().get();
    if (context !== undefined) {
      await BluetoothSettingsNavigator.openBluetoothSettings(context);
    }
  }
}
