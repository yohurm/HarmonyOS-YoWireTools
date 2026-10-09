import {
  YoActionButton,
  YoActionButtonKind,
  YoColor,
  YoNavDestinationKind,
  YoPageShell,
  YoSpace,
  YoTypeStyle
} from 'youi_kit';
import { ExportBluetoothSessionLogUseCase } from 'yobluetooth';
import { BluetoothObjectNavParams } from '../../navigation/BluetoothObjectNavParams';

@ComponentV2
export struct SessionLogPage {
  @Param params: BluetoothObjectNavParams = new BluetoothObjectNavParams();
  @Event onBack: () => void = () => {
  };
  @Local lines: string[] = [];
  @Local exportPath: string = '';
  @Local exportError: string = '';
  private readonly exportLog: ExportBluetoothSessionLogUseCase = new ExportBluetoothSessionLogUseCase();

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
      if (this.exportPath.length > 0) {
        Text(this.exportPath)
          .fontSize(YoTypeStyle.BODY_S.size)
          .width('100%')
      }
      if (this.exportError.length > 0) {
        Text(this.exportError)
          .fontSize(YoTypeStyle.BODY_S.size)
          .fontColor(YoColor.ERROR)
          .width('100%')
      }
      if (this.lines.length === 0) {
        Text($r('app.string.bt_session_log_empty'))
          .fontSize(YoTypeStyle.BODY_M.size)
          .fontColor(YoColor.TEXT_SECONDARY)
      }
      ForEach(this.lines, (line: string, index: number) => {
        Text(line)
          .fontSize(YoTypeStyle.BODY_S.size)
          .width('100%')
      }, (line: string, index: number) => `${index}-${line}`)
      YoActionButton({
        label: $r('app.string.bt_session_log_export'),
        kind: YoActionButtonKind.PRIMARY,
        onTap: () => {
          void this.exportSession();
        }
      })
      YoActionButton({
        label: $r('app.string.bt_session_log_clear'),
        kind: YoActionButtonKind.SECONDARY,
        onTap: () => {
          this.lines = [];
        }
      })
    }
    .width('100%')
  }

  private async exportSession(): Promise<void> {
    const exported = await this.exportLog.execute(this.params.sessionId);
    if (!exported.success || exported.value === undefined) {
      this.exportError = exported.error?.message ?? '';
      this.exportPath = '';
      return;
    }
    this.exportError = '';
    this.exportPath = exported.value;
  }
}
