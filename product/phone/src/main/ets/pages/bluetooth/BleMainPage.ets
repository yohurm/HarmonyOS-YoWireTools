import { YoNavDestinationKind, YoPageShell } from 'youi_kit';
import { BleDeviceRow, BleMainViewModel, BleScanContentView } from 'feature_bluetooth';

@ComponentV2
export struct BleMainPage {
  @Event onBack: () => void = () => {
  };
  @Event onOpenIdentity: (row: BleDeviceRow) => void = (_row: BleDeviceRow) => {
  };
  @Event onOpenClient: (row: BleDeviceRow) => void = (_row: BleDeviceRow) => {
  };
  @Event onOpenPeripheral: () => void = () => {
  };
  @Event onOpenLog: () => void = () => {
  };
  @Local private vm: BleMainViewModel = new BleMainViewModel();

  aboutToAppear(): void {
    void this.vm.onPageAppear();
  }

  aboutToDisappear(): void {
    void this.vm.onPageDisappear();
  }

  @LocalBuilder
  pageContent() {
    BleScanContentView({
      vm: this.vm,
      onOpenIdentity: (row: BleDeviceRow) => {
        this.onOpenIdentity(row);
      },
      onOpenClient: (row: BleDeviceRow) => {
        this.onOpenClient(row);
      },
      onOpenPeripheral: () => {
        this.onOpenPeripheral();
      },
      onOpenLog: () => {
        this.onOpenLog();
      }
    })
  }

  build() {
    YoPageShell({
      title: $r('app.string.bt_ble_page_title'),
      showBack: true,
      destinationKind: YoNavDestinationKind.MODULE,
      scrollable: true,
      immersiveTitleBar: true,
      onBack: this.onBack,
      content: this.pageContent
    })
  }
}
