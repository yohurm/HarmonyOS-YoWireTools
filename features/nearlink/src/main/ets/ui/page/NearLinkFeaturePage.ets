import {
  YoEmptyStateModel,
  YoEmpty,
  YoResponsive,
  YoNavDestinationKind,
  YoPageShell,
  YoSplitScaffold
} from 'youi_kit';

@Builder
function nearLinkListPane() {
  Column() {
    YoEmpty({
      model: new YoEmptyStateModel(
        $r('app.string.nl_placeholder_list'),
        $r('app.string.nl_placeholder_list_message')
      )
    })
  }
  .width('100%')
  .height('100%')
  .padding(YoResponsive.CARD_CONTENT_PADDING)
  .justifyContent(FlexAlign.Center)
}

@Builder
function nearLinkDetailPane() {
  Column() {
    YoEmpty({
      model: new YoEmptyStateModel(
        $r('app.string.nl_placeholder_detail'),
        $r('app.string.nl_placeholder_detail_message')
      )
    })
  }
  .width('100%')
  .height('100%')
  .padding(YoResponsive.CARD_CONTENT_PADDING)
  .justifyContent(FlexAlign.Center)
}

@Builder
function nearLinkContent() {
  YoSplitScaffold({
    listPane: nearLinkListPane,
    detailPane: nearLinkDetailPane
  })
}

@ComponentV2
export struct NearLinkFeaturePage {
  build() {
    YoPageShell({
      title: $r('app.string.nl_title_overview'),
      destinationKind: YoNavDestinationKind.ROOT_TAB,
      scrollable: false,
      content: nearLinkContent
    })
  }
}
