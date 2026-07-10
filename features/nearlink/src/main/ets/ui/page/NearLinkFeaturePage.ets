import {
  EmptyStateModel,
  EmptyStateView,
  UiResponsive,
  YoNavDestinationKind,
  YoPageShell,
  YoSplitScaffold
} from 'common_ui';

@Builder
function nearLinkListPane() {
  Column() {
    EmptyStateView({
      model: new EmptyStateModel(
        $r('app.string.nl_placeholder_list'),
        $r('app.string.nl_placeholder_list_message')
      )
    })
  }
  .width('100%')
  .height('100%')
  .padding(UiResponsive.CARD_CONTENT_PADDING)
  .justifyContent(FlexAlign.Center)
}

@Builder
function nearLinkDetailPane() {
  Column() {
    EmptyStateView({
      model: new EmptyStateModel(
        $r('app.string.nl_placeholder_detail'),
        $r('app.string.nl_placeholder_detail_message')
      )
    })
  }
  .width('100%')
  .height('100%')
  .padding(UiResponsive.CARD_CONTENT_PADDING)
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
