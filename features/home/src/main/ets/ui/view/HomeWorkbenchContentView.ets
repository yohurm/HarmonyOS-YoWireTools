import {
  YoCardToken,
  YoColor,
  YoEmpty,
  YoEmptyStateModel,
  YoListToken,
  YoModeEntryCard,
  YoSpace,
  YoTypeStyle
} from 'youi_kit';
import { HomeSessionTarget } from '../../domain/HomeSessionTarget';
import { HomeSessionRow, HomeWorkbenchViewModel } from '../../viewmodel/HomeWorkbenchViewModel';
import { HomeSessionRowView } from '../component/HomeSessionRowView';

@ComponentV2
export struct HomeWorkbenchContentView {
  @Param @Require vm: HomeWorkbenchViewModel;
  @Event onOpenTarget: (target: string) => void = (_target: string) => {
  };

  build() {
    Column({ space: YoSpace.XL }) {
      Text($r('app.string.home_section_modules'))
        .fontSize(YoTypeStyle.SUBTITLE_S.size)
        .fontWeight(YoTypeStyle.SUBTITLE_S.weight)
        .fontColor(YoColor.TEXT_SECONDARY)
        .width('100%')
      YoModeEntryCard({
        title: $r('app.string.home_entry_bluetooth_title'),
        description: $r('app.string.home_entry_bluetooth_desc'),
        statusLabel: this.vm.bluetoothGranted ?
          $r('app.string.home_permission_granted') : $r('app.string.home_permission_missing'),
        statusTone: this.vm.bluetoothGranted ? 'success' : 'warning',
        onTap: () => {
          this.onOpenTarget(HomeSessionTarget.BLUETOOTH);
        }
      })
      YoModeEntryCard({
        title: $r('app.string.home_entry_wifi_title'),
        description: $r('app.string.home_entry_wifi_desc'),
        statusLabel: this.vm.wifiGranted ?
          $r('app.string.home_permission_granted') : $r('app.string.home_permission_missing'),
        statusTone: this.vm.wifiGranted ? 'success' : 'warning',
        onTap: () => {
          this.onOpenTarget(HomeSessionTarget.WIFI);
        }
      })
      YoModeEntryCard({
        title: $r('app.string.home_entry_nearlink_title'),
        description: $r('app.string.home_entry_nearlink_desc'),
        statusLabel: this.vm.nearlinkGranted ?
          $r('app.string.home_permission_granted') : $r('app.string.home_permission_missing'),
        statusTone: this.vm.nearlinkGranted ? 'success' : 'warning',
        onTap: () => {
          this.onOpenTarget(HomeSessionTarget.NEARLINK);
        }
      })
      Text($r('app.string.home_section_sessions'))
        .fontSize(YoTypeStyle.SUBTITLE_S.size)
        .fontWeight(YoTypeStyle.SUBTITLE_S.weight)
        .fontColor(YoColor.TEXT_SECONDARY)
        .width('100%')
      if (this.vm.sessions.length === 0) {
        Column() {
          YoEmpty({
            model: new YoEmptyStateModel(
              $r('app.string.home_session_empty_title'),
              $r('app.string.home_session_empty_message')
            )
          })
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        List({ space: YoListToken.ITEM_GAP }) {
          ForEach(this.vm.sessions, (row: HomeSessionRow, index: number) => {
            ListItem() {
              HomeSessionRowView({
                title: row.title,
                protocol: row.protocol,
                state: row.state,
                showDivider: index < this.vm.sessions.length - 1,
                onTap: () => {
                  if (row.target.length > 0) {
                    this.onOpenTarget(row.target);
                  }
                }
              })
            }
          }, (row: HomeSessionRow) => row.id)
        }
        .width('100%')
        .layoutWeight(1)
        .borderRadius(YoCardToken.RADIUS)
        .clip(true)
        .backgroundColor(YoCardToken.BACKGROUND)
      }
    }
    .width('100%')
    .height('100%')
    .alignItems(HorizontalAlign.Start)
  }
}
