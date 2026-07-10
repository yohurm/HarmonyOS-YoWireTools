import { WindowMetricsRegistry, WindowMetricsState, WindowWidthBreakpointUtil } from 'common_platform';

import { ButtonToken } from '../token/component/ButtonToken';

import { DialogToken } from '../token/component/DialogToken';

import { UiColor } from '../token/semantic/UiColor';

import { UiTypeStyle } from '../token/semantic/UiTypeStyle';

import { UiSize } from '../token/foundation/UiSize';

import { UiSpace } from '../token/foundation/UiSpace';

import { UiResourceUtil } from '../util/UiResourceUtil';

import { YoSwitchRow } from './YoSwitchRow';

import { YoTextField } from './YoTextField';



/** Domain filter presets for workflow sheets (bt_devices / wifi_network). */

export enum FilterSheetSpec {

  CUSTOM = 'custom',

  BT_DEVICES = 'bt_devices',

  WIFI_NETWORK = 'wifi_network'

}



export interface FilterSheetBindConfig {

  onDisappear?: () => void;

  height?: SheetSize;

}



export function createFilterSheetBindOptions(config: FilterSheetBindConfig = {},

  usesCenterSheet: boolean = false): SheetOptions {

  if (usesCenterSheet) {

    return {

      height: DialogToken.SHEET_CENTER_HEIGHT,

      width: DialogToken.SHEET_CENTER_WIDTH,

      dragBar: true,

      showClose: false,

      preferType: SheetType.CENTER,

      onDisappear: config.onDisappear

    };

  }

  return {

    height: config.height ?? SheetSize.MEDIUM,

    dragBar: true,

    showClose: false,

    preferType: SheetType.BOTTOM,

    onDisappear: config.onDisappear

  };

}



/**

 * Preset filter fields for Bluetooth device scan vs Wi-Fi network list workflows.

 */

@ComponentV2

export struct FilterPresetFields {

  @Param spec: FilterSheetSpec = FilterSheetSpec.CUSTOM;

  @Param namePrefix: string = '';

  @Param deviceId: string = '';

  @Param serviceUuid: string = '';

  @Param minRssi: string = '';

  @Param favoritesOnly: boolean = false;

  @Param ssid: string = '';

  @Param bssid: string = '';

  @Param band24: boolean = true;

  @Param band5: boolean = true;

  @Param secureOnly: boolean = false;

  @Event onNamePrefixChange: (value: string) => void = () => {

  };

  @Event onDeviceIdChange: (value: string) => void = () => {

  };

  @Event onServiceUuidChange: (value: string) => void = () => {

  };

  @Event onMinRssiChange: (value: string) => void = () => {

  };

  @Event onFavoritesOnlyChange: (value: boolean) => void = () => {

  };

  @Event onSsidChange: (value: string) => void = () => {

  };

  @Event onBssidChange: (value: string) => void = () => {

  };

  @Event onBand24Change: (value: boolean) => void = () => {

  };

  @Event onBand5Change: (value: boolean) => void = () => {

  };

  @Event onSecureOnlyChange: (value: boolean) => void = () => {

  };



  build() {

    if (this.spec === FilterSheetSpec.BT_DEVICES) {

      this.btDeviceFields()

    } else if (this.spec === FilterSheetSpec.WIFI_NETWORK) {

      this.wifiNetworkFields()

    }

  }



  @Builder

  private btDeviceFields() {

    Column({ space: UiSpace.L }) {

      YoTextField({

        label: $r('app.string.ui_filter_bt_name_prefix'),

        value: this.namePrefix,

        placeholder: $r('app.string.ui_filter_bt_name_prefix_hint'),

        onValueChange: (value: string) => this.onNamePrefixChange(value)

      })

      YoTextField({

        label: $r('app.string.ui_filter_bt_device_id'),

        value: this.deviceId,

        placeholder: $r('app.string.ui_filter_bt_device_id_hint'),

        onValueChange: (value: string) => this.onDeviceIdChange(value)

      })

      YoTextField({

        label: $r('app.string.ui_filter_bt_service_uuid'),

        value: this.serviceUuid,

        placeholder: $r('app.string.ui_filter_bt_service_uuid_hint'),

        onValueChange: (value: string) => this.onServiceUuidChange(value)

      })

      YoTextField({

        label: $r('app.string.ui_filter_bt_min_rssi'),

        value: this.minRssi,

        placeholder: $r('app.string.ui_filter_bt_min_rssi_hint'),

        onValueChange: (value: string) => this.onMinRssiChange(value)

      })

      YoSwitchRow({

        title: $r('app.string.ui_filter_bt_favorites_only'),

        checked: this.favoritesOnly,

        onCheckedChange: (value: boolean) => this.onFavoritesOnlyChange(value)

      })

    }

    .width('100%')

  }



  @Builder

  private wifiNetworkFields() {

    Column({ space: UiSpace.L }) {

      YoTextField({

        label: $r('app.string.ui_filter_wifi_ssid'),

        value: this.ssid,

        placeholder: $r('app.string.ui_filter_wifi_ssid_hint'),

        onValueChange: (value: string) => this.onSsidChange(value)

      })

      YoTextField({

        label: $r('app.string.ui_filter_wifi_bssid'),

        value: this.bssid,

        placeholder: $r('app.string.ui_filter_wifi_bssid_hint'),

        onValueChange: (value: string) => this.onBssidChange(value)

      })

      YoSwitchRow({

        title: $r('app.string.ui_filter_wifi_band_24'),

        checked: this.band24,

        onCheckedChange: (value: boolean) => this.onBand24Change(value)

      })

      YoSwitchRow({

        title: $r('app.string.ui_filter_wifi_band_5'),

        checked: this.band5,

        onCheckedChange: (value: boolean) => this.onBand5Change(value)

      })

      YoSwitchRow({

        title: $r('app.string.ui_filter_wifi_secure_only'),

        checked: this.secureOnly,

        onCheckedChange: (value: boolean) => this.onSecureOnlyChange(value)

      })

    }

    .width('100%')

  }

}



@ComponentV2

export struct FilterSheetHost {

  @Param title: ResourceStr = $r('app.string.ui_filter_title');

  @Param subtitle: ResourceStr = '';

  @BuilderParam content: () => void = this.defaultContent;

  @Event onClose: () => void = () => {

  };

  @Event onApply: () => void = () => {

  };

  @Event onReset: () => void = () => {

  };



  @Builder

  defaultContent() {

  }



  build() {

    Column({ space: UiSpace.XL }) {

      this.headerRow()

      Scroll() {

        Column({ space: UiSpace.L }) {

          this.content()

        }

        .width('100%')

      }

      .layoutWeight(1)

      .scrollBar(BarState.Off)

      this.footerRow()

    }

    .width('100%')

    .height('100%')

    .constraintSize({ maxWidth: DialogToken.SHEET_MAX_WIDTH })

    .padding(DialogToken.CONTENT_PADDING)

    .backgroundColor(UiColor.BACKGROUND_PRIMARY)

    .borderRadius(DialogToken.RADIUS)

  }



  @Builder

  private headerRow() {

    Row() {

      Column({ space: UiSpace.XXS }) {

        Text(this.title)

          .fontSize(UiTypeStyle.TITLE_S.size)

          .fontWeight(UiTypeStyle.TITLE_S.weight)

          .fontColor(UiColor.TEXT_PRIMARY)

        if (UiResourceUtil.hasText(this.subtitle)) {

          Text(this.subtitle)

            .fontSize(UiTypeStyle.BODY_S.size)

            .fontColor(UiColor.TEXT_TERTIARY)

        }

      }

      .layoutWeight(1)

      Button($r('app.string.ui_close'), { type: ButtonType.Normal })

        .height(UiSize.TOUCH_TARGET_MIN)

        .fontSize(UiTypeStyle.BODY_S.size)

        .fontColor(UiColor.BRAND_PRIMARY)

        .backgroundColor(Color.Transparent)

        .onClick(() => this.onClose())

    }

    .width('100%')

    .alignItems(VerticalAlign.Center)

  }



  @Builder

  private footerRow() {

    Row({ space: UiSpace.M }) {

      Button($r('app.string.ui_reset'), { type: ButtonType.Normal })

        .layoutWeight(1)

        .height(ButtonToken.HEIGHT)

        .fontSize(UiTypeStyle.BODY_M.size)

        .fontColor(UiColor.BRAND_PRIMARY)

        .backgroundColor(Color.Transparent)

        .border({ width: 1, color: UiColor.BORDER_PRIMARY })

        .borderRadius(ButtonToken.RADIUS)

        .onClick(() => this.onReset())

      Button($r('app.string.ui_apply'), { type: ButtonType.Normal })

        .layoutWeight(1)

        .height(ButtonToken.HEIGHT)

        .fontSize(UiTypeStyle.BODY_M.size)

        .fontColor(ButtonToken.PRIMARY_FOREGROUND)

        .backgroundColor(ButtonToken.PRIMARY_BACKGROUND)

        .borderRadius(ButtonToken.RADIUS)

        .onClick(() => {

          this.onApply();

          this.onClose();

        })

    }

    .width('100%')

  }

}



@ComponentV2

export struct FilterSheetBinder {

  @Param isVisible: boolean = false;

  @Param title: ResourceStr = $r('app.string.ui_filter_title');

  @Param subtitle: ResourceStr = '';

  @Param sheetHeight: SheetSize = SheetSize.MEDIUM;

  @Param spec: FilterSheetSpec = FilterSheetSpec.CUSTOM;

  @Param preferSidePanel: boolean = true;

  @BuilderParam anchor: () => void = this.defaultAnchor;

  @BuilderParam content: () => void = this.defaultContent;

  @Event onClose: () => void = () => {

  };

  @Event onApply: () => void = () => {

  };

  @Event onReset: () => void = () => {

  };

  @Local private metrics: WindowMetricsState = WindowMetricsRegistry.connect();



  @Builder

  defaultAnchor() {

  }



  @Builder

  defaultContent() {

  }



  @Builder

  private forwardContent() {

    this.content()

  }



  @Builder

  private sheetPanel() {

    FilterSheetHost({

      title: this.title,

      subtitle: this.subtitle,

      content: this.forwardContent,

      onClose: () => {

        this.onClose();

      },

      onApply: () => {

        this.onApply();

      },

      onReset: () => {

        this.onReset();

      }

    })

  }



  build() {

    if (this.usesSidePanelPresentation()) {

      Row({ space: UiSpace.M }) {

        Column() {

          this.anchor()

        }

        .layoutWeight(1)

        .height('100%')

        if (this.isVisible) {

          Column() {

            FilterSheetHost({

              title: this.title,

              subtitle: this.subtitle,

              content: this.forwardContent,

              onClose: () => {

                this.onClose();

              },

              onApply: () => {

                this.onApply();

              },

              onReset: () => {

                this.onReset();

              }

            })

          }

          .width(DialogToken.SHEET_CENTER_WIDTH)

          .height('100%')

          .backgroundColor(UiColor.BACKGROUND_PRIMARY)

          .borderRadius(DialogToken.RADIUS)

          .clip(true)

        }

      }

      .width('100%')

      .height('100%')

    } else {

      Row() {

        this.anchor()

      }

      .bindSheet(!!this.isVisible, this.sheetPanel(), createFilterSheetBindOptions({

        height: this.sheetHeight,

        onDisappear: () => {

          this.onClose();

        }

      }, WindowWidthBreakpointUtil.usesCenterSheet(this.metrics.breakpoint)))

    }

  }



  private usesSidePanelPresentation(): boolean {

    return this.preferSidePanel

      && WindowWidthBreakpointUtil.isSideNavCapable(this.metrics.breakpoint)

      && this.spec !== FilterSheetSpec.CUSTOM;

  }

}


