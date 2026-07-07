import {
  SectionTitleView,
  UiColorToken,
  UiLayoutConstants,
  UiSpacing,
  UiTypography,
  YoActionButton,
  YoActionButtonKind
} from 'common_ui';
import { SppUuidPreset } from '../../domain/model/SppUuidPreset';

/** bindSheet content for SPP UUID preset picker (≤480vp). */
@ComponentV2
export struct UuidSelectDialog {
  @Param onSelect: (uuid: string) => void = (_uuid: string) => {
  };
  @Param onDismiss: () => void = () => {
  };

  build() {
    Column({ space: UiSpacing.CARD_GAP }) {
      SectionTitleView({
        title: 'UUID 预设',
        subtitle: '标准 RFCOMM 服务 UUID'
      })

      ForEach(SppUuidPreset.listDefaults(), (preset: SppUuidPreset) => {
        Row({ space: UiSpacing.ITEM_GAP }) {
          Column({ space: 2 }) {
            Text(preset.label)
              .fontSize(UiTypography.BODY_SIZE)
              .fontColor(UiColorToken.TEXT_PRIMARY)
              .width('100%')
            Text(preset.uuid)
              .fontSize(UiTypography.CAPTION_SIZE)
              .fontColor(UiColorToken.TEXT_SECONDARY)
              .width('100%')
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start)
        }
        .width('100%')
        .padding({
          left: UiSpacing.PAGE_PADDING,
          right: UiSpacing.PAGE_PADDING,
          top: UiSpacing.ITEM_GAP,
          bottom: UiSpacing.ITEM_GAP
        })
        .backgroundColor(UiColorToken.SURFACE)
        .borderRadius(UiLayoutConstants.CARD_RADIUS)
        .onClick(() => {
          this.onSelect(preset.uuid);
          this.onDismiss();
        })
      }, (preset: SppUuidPreset) => preset.uuid)

      YoActionButton({
        label: '取消',
        kind: YoActionButtonKind.SECONDARY,
        onTap: () => this.onDismiss()
      })
    }
    .width('100%')
    .padding(UiSpacing.PAGE_PADDING)
    .backgroundColor(UiColorToken.BACKGROUND)
  }
}
