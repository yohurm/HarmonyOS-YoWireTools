import { YoColor, YoSpace, YoTypeStyle } from 'youi_kit';
import { WifiDebugViewModel } from '../viewmodel/WifiDebugViewModel';
import { YoTitleBarMenuItem } from 'youi_kit';

@ComponentV2
export struct WifiFactText {
  @Param text: string = '';

  build() {
    Text(this.text)
      .fontSize(YoTypeStyle.BODY_M.size)
      .fontColor(YoColor.TEXT_PRIMARY)
      .width('100%')
  }
}

@ComponentV2
export struct WifiFieldInput {
  @Param label: string = '';
  @Param text: string = '';
  @Event onValue: (value: string) => void = (_value: string) => {
  };

  build() {
    Column({ space: YoSpace.XS }) {
      Text(this.label)
        .fontSize(YoTypeStyle.BODY_S.size)
        .fontColor(YoColor.TEXT_SECONDARY)
      TextInput({ text: this.text, placeholder: this.label })
        .onChange((value: string) => {
          this.onValue(value);
        })
    }
    .width('100%')
  }
}

export function wifiLogMenu(openLog: () => void): YoTitleBarMenuItem[] {
  return [
    new YoTitleBarMenuItem('sessionLog', $r('sys.symbol.more'), '会话日志', openLog)
  ];
}
