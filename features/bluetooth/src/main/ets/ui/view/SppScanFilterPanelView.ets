import {
  YoColor,
  YoRadius,
  YoSpace,
  YoTypeStyle
} from 'youi_kit';
import { ClassicDeviceMajorFilter, ClassicScanFilter } from 'yo_bluetooth';
import { SppMainViewModel } from '../../viewmodel/SppMainViewModel';

/**
 * Scan filter panel — 紧凑表单密度（展开于 Segment 下方）。
 *
 * 功能清单与排布：
 * ┌────────────────────────────────────────────┐
 * │ [名称________] [MAC________]      [重置]   │  ← 双列输入，省纵向
 * │ 信号  弱──●──强              ≥ -70 dBm    │  ← 单行 Slider + 读数
 * │ 设备类型                        [全部 ▼]   │  ← 系统 Select，右贴自适应
 * └────────────────────────────────────────────┘
 *
 * 依据：间隔参数控件普通间距 8vp；用 placeholder 代替独立 label 行。
 * Select：走系统默认 API（controlSize / selected / value / onSelect），
 * 不覆盖 width/height/font/背景，由 controlSize 自适应文字宽度。
 */
@ComponentV2
export struct SppScanFilterPanelView {
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
        // 系统 Select 默认下拉按钮：仅设 controlSize，宽高随文字自适应
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
