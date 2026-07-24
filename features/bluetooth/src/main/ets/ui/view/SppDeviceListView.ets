import { LengthMetrics } from '@kit.ArkUI';
import {
  YoEmptyStateModel,
  YoEmpty,
  YoListToken
} from 'youi_kit';
import { ClassicDeviceCard, ClassicDeviceGroupRole } from '../component/ClassicDeviceCard';
import { SppActiveSessionItem, SppDeviceListItem } from '../../viewmodel/SppMainViewModel';

/**
 * SPP device / session list surface.
 *
 * 分组卡片表面：同组内 0 间距 + 内部分割线，避免逐卡阴影/圆角浪费纵向空间。
 * Bottom inset 作为 list footer（沉浸式底栏，无壳层空白带）。
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

  private resolveGroupRole(index: number, total: number): ClassicDeviceGroupRole {
    if (total <= 1) {
      return 'only';
    }
    if (index === 0) {
      return 'first';
    }
    if (index === total - 1) {
      return 'last';
    }
    return 'middle';
  }

  build() {
    if (this.isEmpty()) {
      Column() {
        YoEmpty({
          model: new YoEmptyStateModel(this.emptyTitle, this.emptyMessage)
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
      List({ space: YoListToken.ITEM_GAP, scroller: this.listScroller }) {
        if (this.mode === 'scan') {
          ForEach(this.devices, (item: SppDeviceListItem, index: number) => {
            ListItem() {
              ClassicDeviceCard({
                displayName: item.displayName.length > 0 ?
                  item.displayName :
                  $r('app.string.bt_spp_device_unknown_name'),
                address: item.address,
                rssiText: item.rssiText,
                statusLabel: item.needsBridge ?
                  $r('app.string.bt_spp_status_needs_bridge') : '',
                statusWarning: item.needsBridge,
                isPaired: item.paired && !item.needsBridge,
                transportLabel: item.transportLabel,
                majorClass: item.majorClass,
                majorMinorClass: item.majorMinorClass,
                showConnectButton: true,
                connectEnabled: item.sppConnectable,
                groupRole: this.resolveGroupRole(index, this.devices.length),
                onConnect: () => {
                  this.onDeviceConnect(item);
                },
                onTap: () => {
                  this.onDeviceTap(item);
                }
              })
                .margin({
                  left: this.horizontalPadding,
                  right: this.horizontalPadding
                })
            }
          }, (item: SppDeviceListItem) => item.primaryDeviceId)
        } else {
          ForEach(this.sessions, (item: SppActiveSessionItem, index: number) => {
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
                showDisclosure: true,
                connectEnabled: false,
                groupRole: this.resolveGroupRole(index, this.sessions.length),
                onTap: () => {
                  this.onSessionTap(item);
                }
              })
                .margin({
                  left: this.horizontalPadding,
                  right: this.horizontalPadding
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
      .scrollBarWidth(YoListToken.SCROLLBAR_WIDTH)
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
