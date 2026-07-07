import {
  UiColorToken,
  UiLayoutConstants,
  UiSpacing,
  UiTypography,
  YoActionButton,
  YoActionButtonKind,
  YoTextField
} from 'common_ui';

@ComponentV2
export struct SocketConnectDialog {
  @Param visible: boolean = false;
  @Param host: string = '';
  @Param port: number = 8080;
  @Param onConfirm: (host: string, port: number) => void = (_host: string, _port: number) => {
  };
  @Param onDismiss: () => void = () => {
  };
  @Local hostInput: string = '';
  @Local portInput: string = '8080';

  build() {
    Column({ space: UiSpacing.ITEM_GAP }) {
      if (this.visible) {
        Text('Socket 连接')
          .fontSize(UiTypography.BODY_SIZE)
          .fontWeight(UiTypography.SUBTITLE_WEIGHT)
          .fontColor(UiColorToken.TEXT_PRIMARY)
        YoTextField({
          label: '主机',
          value: this.hostInput.length > 0 ? this.hostInput : this.host,
          placeholder: '主机地址',
          onValueChange: (value: string) => {
            this.hostInput = value;
          }
        })
        YoTextField({
          label: '端口',
          value: this.portInput.length > 0 ? this.portInput : `${this.port}`,
          placeholder: '端口',
          onValueChange: (value: string) => {
            this.portInput = value;
          }
        })
        Row({ space: UiSpacing.ITEM_GAP }) {
          YoActionButton({
            label: '连接',
            kind: YoActionButtonKind.PRIMARY,
            onTap: () => {
              const host = this.hostInput.length > 0 ? this.hostInput : this.host;
              const port = parseInt(this.portInput, 10);
              this.onConfirm(host, Number.isNaN(port) ? this.port : port);
              this.onDismiss();
            }
          })
            .layoutWeight(1)
          YoActionButton({
            label: '取消',
            kind: YoActionButtonKind.SECONDARY,
            onTap: () => {
              this.onDismiss();
            }
          })
            .layoutWeight(1)
        }
        .width('100%')
      }
    }
    .width('100%')
    .constraintSize({ maxWidth: UiLayoutConstants.DIALOG_MAX_WIDTH })
    .padding(UiSpacing.PAGE_PADDING)
    .backgroundColor(UiColorToken.SURFACE)
    .borderRadius(UiLayoutConstants.CARD_RADIUS)
  }
}
