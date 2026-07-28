import {
  YoColor,
  YoRadius,
  YoSpace,
  YoTypeStyle
} from 'youi_kit';
import { ClassicDeviceMajorFilter, ClassicScanFilter } from 'yobluetooth';
import { SppMainViewModel } from '../../viewmodel/SppMainViewModel';

/**
 * 经典蓝牙 Inquiry 列表过滤器面板（≠ SPP 协议过滤）。
 * 绑定 ClassicScanFilter；由 SPP 页扫描段展开使用。
 *
 * 功能清单与排布：
 * ┌────────────────────────────────────────────┐
 * │ [名称________] [MAC________]      [重置]   │
 * │ 信号  弱──●──强              ≥ -70 dBm    │
 * │ 设备类型                        [全部 ▼]   │
 * └────────────────────────────────────────────┘
 */
@ComponentV2
export struct ClassicScanFilterPanelView {
  @Param @Require vm: SppMainViewModel;
  private readonly majorOptions: SelectOption[] = [
    { value: $r('app.string.bt_spp_filter_type_all') },
    { value: $r('app.string.bt_spp_filter_type_audio') },
    { value: $r('app.string.bt_spp_filter_type_phone') },
    { value: $r('app.string.bt_spp_filter_type_computer') },
    { value: $r('app.string.bt_spp_filter_type_peripheral') },
    { value: $r('app.string.bt_spp_filter_type_wearable') },
    { value: $r('app.string.bt_spp_filter_type_imaging') },
    { value: $r('app.string.bt_spp_filter_type_health') },
    { value: $r('app.string.bt_spp_filter_type_other') }
  ];
  private readonly majorValues: ClassicDeviceMajorFilter[] = [
    ClassicDeviceMajorFilter.ALL,
    ClassicDeviceMajorFilter.AUDIO_VIDEO,
    ClassicDeviceMajorFilter.PHONE,
    ClassicDeviceMajorFilter.COMPUTER,
    ClassicDeviceMajorFilter.PERIPHERAL,
    ClassicDeviceMajorFilter.WEARABLE,
    ClassicDeviceMajorFilter.IMAGING,
    ClassicDeviceMajorFilter.HEALTH,
    ClassicDeviceMajorFilter.OTHER
  ];

  build() {
    Column({ space: YoSpace.M }) {
      Row({ space: YoSpace.M }) {
        TextInput({
          text: this.vm.filterName,
          placeholder: $r('app.string.bt_spp_filter_name_placeholder')
        })
          .layoutWeight(1)
          .height(36)
          .fontSize(YoTypeStyle.BODY_S.size)
          .fontColor(YoColor.TEXT_PRIMARY)
          .placeholderColor(YoColor.TEXT_TERTIARY)
          .backgroundColor(YoColor.SURFACE_INPUT)
          .borderRadius(YoRadius.SMALL)
          .padding({ left: YoSpace.M, right: YoSpace.M })
          .onChange((text: string) => {
            this.vm.setFilterName(text);
          })

        TextInput({
          text: this.vm.filterAddress,
          placeholder: $r('app.string.bt_spp_filter_mac_placeholder')
        })
          .layoutWeight(1)
          .height(36)
          .fontSize(YoTypeStyle.BODY_S.size)
          .fontColor(YoColor.TEXT_PRIMARY)
          .placeholderColor(YoColor.TEXT_TERTIARY)
          .backgroundColor(YoColor.SURFACE_INPUT)
          .borderRadius(YoRadius.SMALL)
          .padding({ left: YoSpace.M, right: YoSpace.M })
          .onChange((text: string) => {
            this.vm.setFilterAddress(text);
          })

        Button($r('app.string.bt_spp_filter_reset'), { type: ButtonType.Normal })
          .fontSize(YoTypeStyle.BODY_S.size)
          .fontColor(YoColor.BRAND_PRIMARY)
          .backgroundColor(Color.Transparent)
          .height(36)
          .padding({ left: YoSpace.S, right: YoSpace.S })
          .enabled(this.vm.filterActive)
          .opacity(this.vm.filterActive ? 1 : 0.4)
          .onClick(() => {
            this.vm.resetScanFilter();
          })
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)

      Column({ space: YoSpace.XS }) {
        Row() {
          Text($r('app.string.bt_spp_filter_rssi_label'))
            .fontSize(YoTypeStyle.BODY_S.size)
            .fontColor(YoColor.TEXT_SECONDARY)
          Blank()
          Text(this.rssiValueText())
            .fontSize(YoTypeStyle.BODY_S.size)
            .fontColor(YoColor.TEXT_PRIMARY)
            .fontWeight(FontWeight.Medium)
            .fontFamily(YoTypeStyle.MONO_S.family)
        }
        .width('100%')

        Row({ space: YoSpace.S }) {
          Text($r('app.string.bt_spp_filter_rssi_weak'))
            .fontSize(YoTypeStyle.BODY_S.size)
            .fontColor(YoColor.TEXT_TERTIARY)
          Slider({
            value: this.vm.filterMinRssi,
            min: ClassicScanFilter.RSSI_SLIDER_MIN,
            max: ClassicScanFilter.RSSI_SLIDER_MAX,
            step: 1,
            style: SliderStyle.OutSet
          })
            .layoutWeight(1)
            .selectedColor(YoColor.BRAND_PRIMARY)
            .trackColor(YoColor.BORDER_SECONDARY)
            .blockColor(YoColor.BRAND_PRIMARY)
            .showTips(true)
            .onChange((value: number) => {
              this.vm.setFilterMinRssi(Math.round(value));
            })
          Text($r('app.string.bt_spp_filter_rssi_strong'))
            .fontSize(YoTypeStyle.BODY_S.size)
            .fontColor(YoColor.TEXT_TERTIARY)
        }
        .width('100%')
        .alignItems(VerticalAlign.Center)
      }
      .width('100%')

      Row({ space: YoSpace.M }) {
        Text($r('app.string.bt_spp_filter_type_label'))
          .fontSize(YoTypeStyle.BODY_S.size)
          .fontColor(YoColor.TEXT_SECONDARY)
        Blank()
        Select(this.majorOptions)
          .selected(this.majorIndex())
          .value(this.majorOptions[this.majorIndex()].value)
          .controlSize(ControlSize.SMALL)
          .onSelect((index: number) => {
            if (index >= 0 && index < this.majorValues.length) {
              this.vm.setFilterMajor(this.majorValues[index]);
            }
          })
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)
    }
    .width('100%')
    .padding({
      left: YoSpace.L,
      right: YoSpace.L,
      top: YoSpace.M,
      bottom: YoSpace.M
    })
    .borderRadius(YoRadius.MEDIUM)
    .backgroundColor(YoColor.SURFACE_CARD)
  }

  private majorIndex(): number {
    for (let i = 0; i < this.majorValues.length; i++) {
      if (this.majorValues[i] === this.vm.filterMajor) {
        return i;
      }
    }
    return 0;
  }

  private rssiValueText(): string {
    if (this.vm.filterMinRssi <= ClassicScanFilter.RSSI_SLIDER_MIN) {
      return '≥ -100 dBm';
    }
    return `≥ ${this.vm.filterMinRssi} dBm`;
  }
}
