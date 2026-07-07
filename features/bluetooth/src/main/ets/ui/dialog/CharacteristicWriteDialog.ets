import {
  SectionTitleView,
  SegmentChipView,
  UiColorToken,
  UiLayoutConstants,
  UiSpacing,
  UiTypography,
  YoActionButton,
  YoActionButtonKind,
  YoTextField
} from 'common_ui';
import { WritePayloadEncoding } from '../../domain/service/GattWritePayloadCodec';

/** bindSheet content for GATT characteristic write (≤480vp). */
@ComponentV2
export struct CharacteristicWriteDialog {
  @Param serviceUuid: string = '';
  @Param characteristicUuid: string = '';
  @Param onConfirm: (payload: string, encoding: WritePayloadEncoding) => void =
    (_payload: string, _encoding: WritePayloadEncoding) => {
    };
  @Param onDismiss: () => void = () => {
  };

  @Local payload: string = '';
  @Local encoding: WritePayloadEncoding = WritePayloadEncoding.HEX;

  build() {
    Column({ space: UiSpacing.CARD_GAP }) {
      SectionTitleView({
        title: '写入特征值',
        subtitle: `${this.serviceUuid} / ${this.characteristicUuid}`
      })

      Scroll() {
        Row({ space: UiSpacing.ITEM_GAP }) {
          SegmentChipView({
            label: '文本',
            selected: this.encoding === WritePayloadEncoding.TEXT,
            onSelect: () => {
              this.encoding = WritePayloadEncoding.TEXT;
            }
          })
          SegmentChipView({
            label: 'HEX',
            selected: this.encoding === WritePayloadEncoding.HEX,
            onSelect: () => {
              this.encoding = WritePayloadEncoding.HEX;
            }
          })
          SegmentChipView({
            label: 'Base64',
            selected: this.encoding === WritePayloadEncoding.BASE64,
            onSelect: () => {
              this.encoding = WritePayloadEncoding.BASE64;
            }
          })
        }
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .width('100%')

      YoTextField({
        label: 'Payload',
        value: this.payload,
        placeholder: '文本 / HEX / Base64',
        onValueChange: (value: string) => {
          this.payload = value;
        }
      })

      Row({ space: UiSpacing.ITEM_GAP }) {
        YoActionButton({
          label: '写入',
          kind: YoActionButtonKind.PRIMARY,
          onTap: () => {
            this.onConfirm(this.payload, this.encoding);
            this.onDismiss();
          }
        })
          .layoutWeight(1)
        YoActionButton({
          label: '取消',
          kind: YoActionButtonKind.SECONDARY,
          onTap: () => this.onDismiss()
        })
          .layoutWeight(1)
      }
      .width('100%')
    }
    .width('100%')
    .padding(UiSpacing.PAGE_PADDING)
    .backgroundColor(UiColorToken.BACKGROUND)
  }
}
