import { LengthMetrics } from '@kit.ArkUI';
import {
  EmptyStateModel,
  EmptyStateView,
  ListToken
} from 'common_ui';
import { ClassicDeviceCard } from '../component/ClassicDeviceCard';
import { SppActiveSessionItem, SppDeviceListItem } from '../../viewmodel/SppMainViewModel';

/**
 * SPP device / session list surface.
 * Owns edge-to-edge List clipping so items never paint over the title bar.
 * Bottom inset is applied as a list footer (immersive edge-to-edge, no shell blank band).
 */
@ComponentV2
export struct SppDeviceListView {
  @Param devices: SppDeviceListItem[] = [];
  @Param sessions: SppActiveSessionItem[] = [];
  @Param mode: 'scan' | 'active' = 'scan';
  @Param emptyTitle: ResourceStr = '';
  @Param emptyMessage: ResourceStr = '';
  @Param horizontalPadding: number = 16;
  @Param bottomInsetVp: number = 0;
  @Param listScroller: Scroller = new Scroller();
  @Event onDeviceConnect: (item: SppDeviceListItem) => void = (_item: SppDeviceListItem) => {
  };
  @Event onDeviceTap: (item: SppDeviceListItem) => void = (_item: SppDeviceListItem) => {
  };
  @Event onSessionTap: (item: SppActiveSessionItem) => void = (_item: SppActiveSessionItem) => {
  };

  private isEmpty(): boolean {
    if (this.mode === 'active') {
      return this.sessions.length === 0;
    }
    return this.devices.length === 0;
  }

  build() {
    if (this.isEmpty()) {
      Column() {
        EmptyStateView({
          model: new EmptyStateModel(this.emptyTitle, this.emptyMessage)
        })
      }
      .width('100%')
      .height('100%')
      .padding({
        left: this.horizontalPadding,
        right: this.horizontalPadding,
        bottom: this.bottomInsetVp
      })
      .justifyContent(FlexAlign.Center)
    } else {
      List({ space: ListToken.ITEM_GAP, scroller: this.listScroller }) {
        if (this.mode === 'scan') {
          ForEach(this.devices, (item: SppDeviceListItem) => {
            ListItem() {
              ClassicDeviceCard({
                displayName: item.displayName.length > 0 ?
                  item.displayName :
                  $r('app.string.bt_spp_device_unknown_name'),
                address: item.address,
                rssiText: item.rssiText,
                statusLabel: item.needsBridge ?
                  $r('app.string.bt_spp_status_needs_bridge') :
                  (item.paired ? $r('app.string.bt_spp_status_paired') : ''),
                transportLabel: item.transportLabel,
                majorClass: item.majorClass,
                majorMinorClass: item.majorMinorClass,
                showConnectButton: true,
                connectEnabled: item.sppConnectable,
                onConnect: () => {
                  this.onDeviceConnect(item);
                },
                onTap: () => {
                  this.onDeviceTap(item);
                }
              })
                .margin({
                  left: this.horizontalPadding,
                  right: this.horizontalPadding,
                  top: ListToken.ITEM_SHADOW_BLEED,
                  bottom: ListToken.ITEM_SHADOW_BLEED
                })
            }
          }, (item: SppDeviceListItem) => item.primaryDeviceId)
        } else {
          ForEach(this.sessions, (item: SppActiveSessionItem) => {
            ListItem() {
              ClassicDeviceCard({
                displayName: item.displayName,
                address: '',
                rssiText: '',
                statusLabel: item.stateLabel,
                transportLabel: '',
                majorClass: 0,
                majorMinorClass: 0,
                showConnectButton: false,
                connectEnabled: false,
                onTap: () => {
                  this.onSessionTap(item);
                }
              })
                .margin({
                  left: this.horizontalPadding,
                  right: this.horizontalPadding,
                  top: ListToken.ITEM_SHADOW_BLEED,
                  bottom: ListToken.ITEM_SHADOW_BLEED
                })
            }
          }, (item: SppActiveSessionItem) => item.sessionId)
        }
        if (this.bottomInsetVp > 0) {
          ListItem() {
            Column()
              .width('100%')
              .height(this.bottomInsetVp)
          }
        }
      }
      .width('100%')
      .height('100%')
      .scrollBar(BarState.Auto)
      .scrollBarWidth(ListToken.SCROLLBAR_WIDTH)
      .scrollBarMargin({
        start: LengthMetrics.vp(0),
        end: LengthMetrics.vp(0)
      })
      .edgeEffect(EdgeEffect.Spring)
      .clip(true)
      .clipContent(ContentClipMode.CONTENT_ONLY)
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
    }
  }
}
