import { YoActionButton, YoActionButtonKind, YoColor, YoError, YoErrorStateModel, YoSpace, YoTypeStyle } from 'youi_kit';
import { BleScanDutyPreset, BluetoothErrorCodes } from 'yobluetooth';
import { BleDeviceRow, BleMainViewModel } from '../../viewmodel/BleMainViewModel';

@ComponentV2
export struct BleScanContentView {
  @Param @Require vm: BleMainViewModel;
  @Event onOpenIdentity: (row: BleDeviceRow) => void = (_row: BleDeviceRow) => {
  };
  @Event onOpenClient: (row: BleDeviceRow) => void = (_row: BleDeviceRow) => {
  };
  @Event onOpenPeripheral: () => void = () => {
  };
  @Event onOpenLog: () => void = () => {
  };

  build() {
    Column({ space: YoSpace.M }) {
      if (this.vm.errorCode.length > 0) {
        YoError({
          model: new YoErrorStateModel(
            $r('app.string.bt_ble_scan_error_title'),
            this.vm.errorCode,
            $r('app.string.bt_ble_scan_error_next'),
            this.vm.errorCode,
            this.vm.errorCode === BluetoothErrorCodes.ADAPTER_OFF ? '2900003' : ''
          )
        })
      }
      Text($r('app.string.bt_ble_filter_hint'))
        .fontSize(YoTypeStyle.BODY_S.size)
        .fontColor(YoColor.TEXT_SECONDARY)
        .width('100%')
      TextInput({ text: this.vm.exactName, placeholder: $r('app.string.bt_ble_exact_name') })
        .onChange((value: string) => {
          this.vm.setExactName(value);
        })
      TextInput({ text: this.vm.serviceUuid, placeholder: $r('app.string.bt_ble_service_uuid') })
        .onChange((value: string) => {
          this.vm.setServiceUuid(value);
        })
      TextInput({ text: this.vm.serviceUuidMask, placeholder: $r('app.string.bt_ble_service_mask') })
        .onChange((value: string) => {
          this.vm.setServiceUuidMask(value);
        })
      TextInput({ text: this.vm.namePrefix, placeholder: $r('app.string.bt_ble_name_prefix') })
        .onChange((value: string) => {
          this.vm.setNamePrefix(value);
        })
      TextInput({ text: this.vm.manufacturerIdText, placeholder: $r('app.string.bt_ble_manufacturer') })
        .onChange((value: string) => {
          this.vm.setManufacturerIdText(value);
        })
      TextInput({ text: this.vm.rssiThresholdText, placeholder: $r('app.string.bt_ble_rssi_threshold') })
        .onChange((value: string) => {
          this.vm.setRssiThresholdText(value);
        })
      if (!this.vm.rssiThresholdAvailable) {
        Text($r('app.string.bt_ble_rssi_threshold_unavailable'))
          .fontSize(YoTypeStyle.BODY_S.size)
          .fontColor(YoColor.TEXT_SECONDARY)
          .width('100%')
      }
      Row({ space: YoSpace.S }) {
        Button($r('app.string.bt_ble_duty_low'))
          .onClick(() => {
            this.vm.selectDuty(BleScanDutyPreset.LOW_POWER);
          })
        Button($r('app.string.bt_ble_duty_balanced'))
          .onClick(() => {
            this.vm.selectDuty(BleScanDutyPreset.BALANCED);
          })
        Button($r('app.string.bt_ble_duty_low_latency'))
          .onClick(() => {
            this.vm.selectDuty(BleScanDutyPreset.LOW_LATENCY);
          })
      }
      .width('100%')
      YoActionButton({
        label: this.vm.scanning ? $r('app.string.bt_ble_stop_scan') : $r('app.string.bt_ble_start_scan'),
        kind: YoActionButtonKind.PRIMARY,
        onTap: () => {
          if (this.vm.scanning) {
            void this.vm.stopScan();
          } else {
            void this.vm.startScan();
          }
        }
      })
      if (this.vm.parallelAvailable) {
        YoActionButton({
          label: this.vm.extraScanning ? $r('app.string.bt_ble_stop_extra') : $r('app.string.bt_ble_start_extra'),
          kind: YoActionButtonKind.SECONDARY,
          onTap: () => {
            if (this.vm.extraScanning) {
              this.vm.stopExtraScan();
            } else {
              void this.vm.startExtraScan();
            }
          }
        })
      } else {
        Text($r('app.string.bt_ble_parallel_unavailable'))
          .fontSize(YoTypeStyle.BODY_S.size)
          .fontColor(YoColor.TEXT_SECONDARY)
          .width('100%')
      }
      if (this.vm.connectBlockedMessage.length > 0) {
        Text($r('app.string.bt_ble_not_connectable'))
          .fontSize(YoTypeStyle.BODY_S.size)
          .fontColor(YoColor.ERROR)
          .width('100%')
      }
      if (this.vm.rows.length === 0 && this.vm.errorCode.length === 0) {
        Text($r('app.string.bt_ble_empty'))
          .fontSize(YoTypeStyle.BODY_M.size)
          .fontColor(YoColor.TEXT_SECONDARY)
          .width('100%')
      }
      ForEach(this.vm.rows, (row: BleDeviceRow) => {
        Column({ space: YoSpace.XS }) {
          Text(row.name.length > 0 ? row.name : $r('app.string.bt_ble_unnamed'))
            .fontSize(YoTypeStyle.BODY_M.size)
            .fontColor(YoColor.TEXT_PRIMARY)
            .width('100%')
          Text(row.address)
            .fontSize(YoTypeStyle.BODY_S.size)
            .fontColor(YoColor.TEXT_SECONDARY)
            .width('100%')
          Text($r('app.string.bt_address_virtual'))
            .fontSize(YoTypeStyle.BODY_S.size)
            .fontColor(YoColor.TEXT_TERTIARY)
            .width('100%')
          if (row.rssiText.length > 0) {
            Text(row.rssiText)
              .fontSize(YoTypeStyle.BODY_S.size)
              .fontColor(YoColor.TEXT_SECONDARY)
          }
          if (row.rawSummary.length > 0) {
            Text(row.rawSummary)
              .fontSize(YoTypeStyle.BODY_S.size)
              .fontColor(YoColor.TEXT_TERTIARY)
              .width('100%')
          }
          Row({ space: YoSpace.S }) {
            Button($r('app.string.bt_entry_identity'))
              .onClick(() => {
                this.onOpenIdentity(row);
              })
            Button($r('app.string.bt_ble_connect'))
              .enabled(row.connectable)
              .onClick(() => {
                if (this.vm.connectBlocked(row)) {
                  return;
                }
                this.onOpenClient(row);
              })
          }
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
      }, (row: BleDeviceRow) => row.deviceId)
      YoActionButton({
        label: $r('app.string.bt_entry_peripheral'),
        kind: YoActionButtonKind.SECONDARY,
        onTap: () => {
          this.onOpenPeripheral();
        }
      })
      YoActionButton({
        label: $r('app.string.bt_entry_session_log'),
        kind: YoActionButtonKind.TEXT,
        onTap: () => {
          this.onOpenLog();
        }
      })
    }
    .width('100%')
  }
}
