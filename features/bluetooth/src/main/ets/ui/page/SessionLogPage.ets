import {
  YoActionButton,
  YoActionButtonKind,
  YoColor,
  YoNavDestinationKind,
  YoPageShell,
  YoSpace,
  YoTypeStyle
} from 'youi_kit';
import { BluetoothObjectNavParams } from '../../navigation/BluetoothObjectNavParams';
import { SessionLogViewModel } from '../../viewmodel/SessionLogViewModel';

@ComponentV2
export struct SessionLogPage {
  @Param params: BluetoothObjectNavParams = new BluetoothObjectNavParams();
  @Event onBack: () => void = () => {
  };
  @Local private vm: SessionLogViewModel = new SessionLogViewModel();

  build() {
    YoPageShell({
      title: $r('app.string.bt_session_log_title'),
      showBack: true,
      destinationKind: YoNavDestinationKind.TERMINAL,
      onBack: this.onBack,
      content: this.body
    })
  }

  @LocalBuilder
  body() {
    Column({ space: YoSpace.M }) {
      Text($r('app.string.bt_session_log_no_hci'))
        .fontSize(YoTypeStyle.BODY_S.size)
        .fontColor(YoColor.TEXT_SECONDARY)
        .width('100%')
      Text($r('app.string.bt_session_log_clear_hint'))
        .fontSize(YoTypeStyle.BODY_S.size)
        .fontColor(YoColor.TEXT_TERTIARY)
        .width('100%')
      if (this.vm.exportPath.length > 0) {
        Text(this.vm.exportPath)
          .fontSize(YoTypeStyle.BODY_S.size)
          .width('100%')
      }
      if (this.vm.exportError.length > 0) {
        Text(this.vm.exportError)
          .fontSize(YoTypeStyle.BODY_S.size)
          .fontColor(YoColor.ERROR)
          .width('100%')
      }
      if (this.vm.lines.length === 0) {
        Text($r('app.string.bt_session_log_empty'))
          .fontSize(YoTypeStyle.BODY_M.size)
          .fontColor(YoColor.TEXT_SECONDARY)
      }
      ForEach(this.vm.lines, (line: string, index: number) => {
        Text(line)
          .fontSize(YoTypeStyle.BODY_S.size)
          .width('100%')
      }, (line: string, index: number) => `${index}-${line}`)
      YoActionButton({
        label: $r('app.string.bt_session_log_export'),
        kind: YoActionButtonKind.PRIMARY,
        onTap: () => {
          void this.vm.exportSession(this.params.sessionId);
        }
      })
      YoActionButton({
        label: $r('app.string.bt_session_log_clear'),
        kind: YoActionButtonKind.SECONDARY,
        onTap: () => {
          this.vm.clear();
        }
      })
    }
    .width('100%')
  }
}
