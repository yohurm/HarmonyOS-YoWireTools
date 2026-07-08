import {
  StatusPillView,
  UiColorToken,
  UiLayoutConstants,
  UiSpacing,
  UiTypography,
  YoNavDestinationKind,
  YoPageShell
} from 'common_ui';
import { BtStatusCard } from '../component/BtStatusCard';
import { BtOverviewViewModel } from '../../viewmodel/BtOverviewViewModel';

@ComponentV2
export struct BluetoothFeaturePage {
  @Event onOpenSpp: () => void = () => {
  };
  @Event onOpenBle: () => void = () => {
  };
  @Local private vm: BtOverviewViewModel = new BtOverviewViewModel();

  aboutToAppear(): void {
    void this.vm.onPageAppear();
  }

  aboutToDisappear(): void {
    this.vm.onPageDisappear();
  }

  @LocalBuilder
  pageContent() {
    Column({ space: UiSpacing.SECTION_GAP }) {
      BtStatusCard({
        isLoading: this.vm.isLoading,
        adapterEnabled: this.vm.adapterEnabled,
        permissionGranted: this.vm.permissionGranted,
        classicReady: this.vm.isClassicReady(),
        bleReady: this.vm.isBleReady(),
        classicSupported: this.vm.classicSupported,
        bleSupported: this.vm.bleSupported,
        onPermissionAction: () => {
          void this.vm.requestPermission();
        },
        onAdapterAction: () => {
          void this.vm.openBluetoothSettings();
        }
      })
      this.bluetoothEntryOverview()
    }
    .width('100%')
    .height('100%')
  }

  build() {
    YoPageShell({
      title: $r('app.string.bt_title_overview'),
      destinationKind: YoNavDestinationKind.ROOT_TAB,
      scrollable: false,
      immersiveTitleBar: true,
      content: this.pageContent
    })
  }

  @LocalBuilder
  bluetoothEntryOverview() {
    Column({ space: UiSpacing.ITEM_GAP }) {
      Text($r('app.string.bt_entry_section_title'))
        .fontSize(UiTypography.SUBTITLE_SIZE)
        .fontWeight(FontWeight.Medium)
        .fontColor(UiColorToken.TEXT_PRIMARY)
        .width('100%')
      this.entryCard(
        $r('app.string.bt_entry_spp_title'),
        $r('app.string.bt_entry_spp_subtitle'),
        this.vm.isClassicReady(),
        () => {
          this.onOpenSpp();
        }
      )
      this.entryCard(
        $r('app.string.bt_entry_ble_title'),
        $r('app.string.bt_entry_ble_subtitle'),
        this.vm.isBleReady(),
        () => {
          this.onOpenBle();
        }
      )
    }
    .width('100%')
  }

  @Builder
  private entryCard(title: ResourceStr, subtitle: ResourceStr, ready: boolean, onTap: () => void) {
    Row({ space: UiSpacing.ITEM_GAP }) {
      Column({ space: UiSpacing.LABEL_STACK_GAP }) {
        Text(title)
          .fontSize(UiTypography.SUBTITLE_SIZE)
          .fontWeight(FontWeight.Medium)
          .fontColor(UiColorToken.TEXT_PRIMARY)
          .width('100%')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
        Text(subtitle)
          .fontSize(UiTypography.CAPTION_SIZE)
          .fontColor(UiColorToken.TEXT_TERTIARY)
          .width('100%')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      StatusPillView({
        label: ready ? $r('app.string.bt_entry_status_ready') : $r('app.string.bt_entry_status_blocked'),
        tone: ready ? 'success' : 'warning'
      })
    }
    .width('100%')
    .padding(UiSpacing.CARD_INNER_PADDING)
    .backgroundColor(UiColorToken.SURFACE)
    .borderRadius(UiLayoutConstants.CARD_RADIUS_SMALL)
    .alignItems(VerticalAlign.Center)
    .onClick(() => onTap())
  }
}
