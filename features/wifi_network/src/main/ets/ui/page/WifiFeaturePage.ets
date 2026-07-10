import {
  ButtonToken,
  CardToken,
  ContentStateHost,
  FilterPresetFields,
  FilterSheetBinder,
  FilterSheetSpec,
  InspectorPanel,
  LoadingStateModel,
  PayloadViewerView,
  UiColor,
  UiPageState,
  UiResponsive,
  UiSize,
  UiTypeStyle,
  UiResourceUtil,
  YoNavDestinationKind,
  YoPageShell,
  YoTextField
} from 'common_ui';

@ComponentV2
export struct WifiFeaturePage {
  @Local private isLoading: boolean = true;
  @Local private filterVisible: boolean = false;
  @Local private selectedNetworkId: string = '';
  @Local private ssidFilter: string = '';
  @Local private bssidFilter: string = '';
  @Local private band24: boolean = true;
  @Local private band5: boolean = true;
  @Local private secureOnly: boolean = false;
  @Local private canSaveInspector: boolean = false;
  @Local private showHexPreview: boolean = false;

  aboutToAppear(): void {
    this.isLoading = false;
  }

  @LocalBuilder
  pageContent() {
    ContentStateHost({
      state: this.isLoading ? UiPageState.LOADING : UiPageState.CONTENT,
      loadingModel: new LoadingStateModel($r('app.string.ui_loading_default_message')),
      content: this.pageBody
    })
  }

  @LocalBuilder
  pageBody() {
    FilterSheetBinder({
      isVisible: this.filterVisible,
      title: $r('app.string.ui_filter_title'),
      subtitle: $r('app.string.wifi_filter_subtitle'),
      spec: FilterSheetSpec.WIFI_NETWORK,
      anchor: () => {
        this.scaffoldAnchor();
      },
      content: () => {
        this.filterFields();
      },
      onClose: () => {
        this.filterVisible = false;
      },
      onApply: () => {
        this.filterVisible = false;
      },
      onReset: () => {
        this.ssidFilter = '';
        this.bssidFilter = '';
        this.band24 = true;
        this.band5 = true;
        this.secureOnly = false;
      }
    })
  }

  @Builder
  private listPane() {
    Column({ space: UiResponsive.CONTROL_GAP }) {
      Row({ space: UiResponsive.CONTROL_GAP }) {
        Text($r('app.string.wifi_list_title'))
          .fontSize(UiTypeStyle.SUBTITLE_M.size)
          .fontWeight(UiTypeStyle.SUBTITLE_M.weight)
          .fontColor(UiColor.TEXT_PRIMARY)
          .layoutWeight(1)
        Button($r('app.string.ui_filter_title'), { type: ButtonType.Normal })
          .height(ButtonToken.HEIGHT)
          .fontSize(UiTypeStyle.BODY_S.size)
          .fontColor(UiColor.BRAND_PRIMARY)
          .backgroundColor(Color.Transparent)
          .border({ width: 1, color: UiColor.BORDER_PRIMARY })
          .borderRadius(ButtonToken.RADIUS)
          .onClick(() => {
            this.filterVisible = true;
          })
      }
      .width('100%')
      this.networkRow('wifi-demo-1', $r('app.string.wifi_demo_ssid_lab'), -42)
      this.networkRow('wifi-demo-2', $r('app.string.wifi_demo_ssid_5g'), -58)
    }
    .width('100%')
    .height('100%')
    .padding(UiResponsive.CARD_CONTENT_PADDING)
  }

  @Builder
  private networkRow(id: string, ssid: ResourceStr, rssi: number) {
    Row() {
      Column({ space: UiResponsive.LABEL_STACK_GAP }) {
        Text(ssid)
          .fontSize(UiTypeStyle.BODY_M.size)
          .fontColor(UiColor.TEXT_PRIMARY)
        Text(UiResourceUtil.format($r('app.string.wifi_rssi_value'), rssi))
          .fontSize(UiTypeStyle.BODY_S.size)
          .fontColor(UiColor.TEXT_TERTIARY)
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
    }
    .width('100%')
    .constraintSize({ minHeight: UiSize.LIST_ROW_HEIGHT })
    .padding(UiResponsive.CARD_CONTENT_PADDING)
    .backgroundColor(id === this.selectedNetworkId ? UiColor.SURFACE_SELECTED : UiColor.SURFACE_CARD)
    .borderRadius(CardToken.RADIUS)
    .onClick(() => {
      this.selectedNetworkId = id;
      this.canSaveInspector = true;
    })
  }

  @Builder
  private inspectorPrimary() {
    YoTextField({
      label: $r('app.string.ui_filter_wifi_ssid'),
      value: this.selectedNetworkId.length > 0 ? UiResourceUtil.resolveText($r('app.string.wifi_demo_ssid_lab')) : '',
      isEnabled: false,
      onValueChange: () => {
      }
    })
  }

  @Builder
  private inspectorSecondary() {
    YoTextField({
      label: $r('app.string.ui_filter_wifi_bssid'),
      value: UiResourceUtil.resolveText($r('app.string.wifi_demo_bssid')),
      isEnabled: false,
      onValueChange: () => {
      }
    })
  }

  @Builder
  private inspectorRaw() {
    PayloadViewerView({
      textPayload: UiResourceUtil.resolveText($r('app.string.wifi_demo_payload_text')),
      hexPayload: UiResourceUtil.resolveText($r('app.string.wifi_demo_payload_hex')),
      showHex: this.showHexPreview,
      onToggleHex: (showHex: boolean) => {
        this.showHexPreview = showHex;
      }
    })
  }

  @Builder
  private filterFields() {
    FilterPresetFields({
      spec: FilterSheetSpec.WIFI_NETWORK,
      ssid: this.ssidFilter,
      bssid: this.bssidFilter,
      band24: this.band24,
      band5: this.band5,
      secureOnly: this.secureOnly,
      onSsidChange: (value: string) => {
        this.ssidFilter = value;
      },
      onBssidChange: (value: string) => {
        this.bssidFilter = value;
      },
      onBand24Change: (value: boolean) => {
        this.band24 = value;
      },
      onBand5Change: (value: boolean) => {
        this.band5 = value;
      },
      onSecureOnlyChange: (value: boolean) => {
        this.secureOnly = value;
      }
    })
  }

  @Builder
  private scaffoldAnchor() {
    InspectorPanel({
      title: $r('app.string.wifi_detail_title'),
      hasSelection: this.selectedNetworkId.length > 0,
      canSave: this.canSaveInspector,
      listPane: () => {
        this.listPane();
      },
      primaryFields: () => {
        this.inspectorPrimary();
      },
      secondaryFields: () => {
        this.inspectorSecondary();
      },
      rawPreview: () => {
        this.inspectorRaw();
      }
    })
  }

  build() {
    YoPageShell({
      title: $r('app.string.wifi_title_overview'),
      destinationKind: YoNavDestinationKind.ROOT_TAB,
      scrollable: false,
      content: this.pageContent
    })
  }
}
