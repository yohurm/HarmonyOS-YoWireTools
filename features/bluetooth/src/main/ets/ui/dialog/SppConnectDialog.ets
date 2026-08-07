import {
  ComponentContent,
  ItemRestriction,
  promptAction,
  SegmentButton,
  SegmentButtonOptions,
  SegmentButtonTextItem
} from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { UIContextRegistry } from 'common_platform';
import {
  YoColor,
  YoDialogToken,
  YoErrorStateModel,
  YoRadius,
  YoSize,
  YoSpace,
  YoStroke,
  YoTitleBarActionRow,
  YoTitleBarMenuItem,
  YoToast,
  YoTypeStyle
} from 'youi_kit';
import { BluetoothConstants, SppUuidFavoriteEntry } from 'yobluetooth';
import { ClassicDeviceListItem } from '../../viewmodel/SppMainViewModel';
import {
  SppConnectDialogController,
  SppConnectDialogParams,
  SppUuidPickMode
} from '../../viewmodel/SppConnectDialogController';

/** Sheet 内容态：列表管理 / 添加编辑表单。 */
enum FavoriteSheetMode {
  LIST = 0,
  FORM = 1
}

/**
 * SPP 连接弹窗内容（手绘对齐 AdvancedDialog：标题/内容/TEXTUAL 底栏）。
 *
 * - 自定义档：标题左对齐 + YoTitleBarActionRow（HDS menuStyle 同构）
 * - 收藏列表：bindSheet 半模态（增删改 + 点选回填）
 */
@Component
struct SppConnectDialogContent {
  @ObjectLink params: SppConnectDialogParams;
  @State private uuidSegmentOptions: SegmentButtonOptions = SegmentButtonOptions.capsule({
    buttons: [
      { text: $r('app.string.bt_spp_uuid_preset_spp') },
      { text: $r('app.string.bt_spp_uuid_preset_nus') },
      { text: $r('app.string.bt_spp_uuid_preset_custom') }
    ] as ItemRestriction<SegmentButtonTextItem>,
    multiply: false
  });
  @State @Watch('onUuidSegmentChange') private uuidSelectedIndexes: number[] = [0];
  /** 递增以强制重建 UUID 输入，解决 Segment 切换后 TextArea/TextInput 不刷新。 */
  @State private uuidFieldEpoch: number = 0;
  @State private showFavoriteSheet: boolean = false;
  @State private favoriteSheetMode: FavoriteSheetMode = FavoriteSheetMode.LIST;
  @State private formOriginalUuid: string = '';
  @State private formLabelText: string = '';
  @State private formUuidText: string = '';
  @State private formSaving: boolean = false;

  aboutToAppear(): void {
    this.uuidSelectedIndexes = [this.params.uuidMode as number];
  }

  build() {
    Column() {
      Column() {
        this.buildTitleRow();

        Text(this.deviceLineText())
          .fontSize(YoTypeStyle.BODY_M.size)
          .fontColor(YoColor.TEXT_SECONDARY)
          .textAlign(TextAlign.Center)
          .width('100%')
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .padding({ left: YoSpace.XXL, right: YoSpace.XXL, bottom: YoSpace.L })

        Scroll() {
          Column({ space: YoSpace.L }) {
            this.buildUuidSection();
            this.buildSettingsSection();
            if (this.params.connecting) {
              Row({ space: YoSpace.M }) {
                LoadingProgress()
                  .width(18)
                  .height(18)
                  .color(YoColor.BRAND_PRIMARY)
                Text($r('app.string.bt_spp_connect_connecting'))
                  .fontSize(YoTypeStyle.BODY_S.size)
                  .fontColor(YoColor.TEXT_SECONDARY)
              }
              .width('100%')
            }
            if (this.params.errorMessage.length > 0) {
              Column({ space: YoSpace.XS }) {
                Text(this.params.errorMessage)
                  .fontSize(YoTypeStyle.BODY_S.size)
                  .fontColor(YoColor.ERROR)
                  .width('100%')
                ForEach(this.params.hintLines, (hint: string) => {
                  Text(hint)
                    .fontSize(YoTypeStyle.BODY_S.size)
                    .fontColor(YoColor.TEXT_TERTIARY)
                    .width('100%')
                }, (hint: string, index: number) => `${index}:${hint}`)
              }
              .width('100%')
              .alignItems(HorizontalAlign.Start)
            }
          }
          .width('100%')
          .padding({ left: YoSpace.XXL, right: YoSpace.XXL, bottom: YoSpace.L })
          .alignItems(HorizontalAlign.Start)
        }
        .width('100%')
        .constraintSize({ maxHeight: YoDialogToken.CONTENT_SCROLL_MAX_HEIGHT })
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)

        Divider()
          .color(YoColor.DIVIDER)
          .strokeWidth(0.5)

        Row() {
          Button($r('app.string.bt_spp_action_cancel'), {
            type: ButtonType.Normal,
            buttonStyle: ButtonStyleMode.TEXTUAL,
            role: ButtonRole.NORMAL
          })
            .layoutWeight(1)
            .height(48)
            .fontSize(YoTypeStyle.SUBTITLE_M.size)
            .fontWeight(FontWeight.Medium)
            .enabled(!this.params.connecting)
            .onClick(() => {
              this.params.onCancel();
            })

          Divider()
            .vertical(true)
            .height(24)
            .color(YoColor.DIVIDER)
            .strokeWidth(0.5)

          Button(this.connectLabel(), {
            type: ButtonType.Normal,
            buttonStyle: ButtonStyleMode.TEXTUAL,
            role: ButtonRole.NORMAL
          })
            .layoutWeight(1)
            .height(48)
            .fontSize(YoTypeStyle.SUBTITLE_M.size)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.canConnect() ? YoColor.BRAND_PRIMARY : YoColor.TEXT_DISABLED)
            .enabled(this.canConnect())
            .onClick(() => {
              this.params.onConnect();
            })
        }
        .width('100%')
        .height(56)
        .padding({ bottom: YoSpace.S })
      }
      .width('100%')
      .constraintSize({ maxWidth: YoDialogToken.MAX_WIDTH })
      .borderRadius(YoDialogToken.RADIUS)
      .backgroundBlurStyle(BlurStyle.COMPONENT_ULTRA_THICK)
      .backgroundColor(YoColor.SURFACE_CARD)
      .clip(true)
    }
    .width('100%')
    .padding({ left: YoDialogToken.SIDE_MARGIN, right: YoDialogToken.SIDE_MARGIN })
  }

  @Builder
  buildTitleRow() {
    if (this.params.uuidMode === SppUuidPickMode.CUSTOM) {
      Row({ space: YoSpace.M }) {
        Text($r('app.string.bt_spp_connect_dialog_title'))
          .fontSize(YoTypeStyle.TITLE_S.size)
          .fontWeight(FontWeight.Bold)
          .fontColor(YoColor.TEXT_PRIMARY)
          .layoutWeight(1)
          .textAlign(TextAlign.Start)

        // 一宿主一 sheet：操作图标行作为 bindSheet 宿主
        Row() {
          YoTitleBarActionRow({ items: this.buildTitleMenus() })
        }
        .bindSheet($$this.showFavoriteSheet, this.FavoriteSheetBuilder(), {
          height: SheetSize.MEDIUM,
          dragBar: true,
          title: { title: $r('app.string.bt_spp_uuid_favorites_title') },
          onDisappear: () => {
            this.resetFavoriteSheetState();
          }
        })
      }
      .width('100%')
      .padding({
        left: YoSpace.XXL,
        right: YoSpace.XXL,
        top: YoSpace.XXL,
        bottom: YoSpace.XS
      })
      .alignItems(VerticalAlign.Center)
    } else {
      Text($r('app.string.bt_spp_connect_dialog_title'))
        .fontSize(YoTypeStyle.TITLE_S.size)
        .fontWeight(FontWeight.Bold)
        .fontColor(YoColor.TEXT_PRIMARY)
        .textAlign(TextAlign.Center)
        .width('100%')
        .margin({ top: YoSpace.XXL, bottom: YoSpace.XS })
    }
  }

  @Builder
  FavoriteSheetBuilder() {
    Column() {
      if (this.favoriteSheetMode === FavoriteSheetMode.LIST) {
        this.buildFavoriteListPane();
      } else {
        this.buildFavoriteFormPane();
      }
    }
    .width('100%')
    .height('100%')
    .padding({
      left: YoSpace.XXL,
      right: YoSpace.XXL,
      bottom: YoSpace.XXL
    })
  }

  @Builder
  buildFavoriteListPane() {
    Column({ space: YoSpace.M }) {
      Row() {
        Text($r('app.string.bt_spp_uuid_favorites_hint'))
          .fontSize(YoTypeStyle.BODY_S.size)
          .fontColor(YoColor.TEXT_TERTIARY)
          .layoutWeight(1)
          .maxLines(2)
        Button($r('app.string.bt_spp_uuid_favorite_add'), {
          type: ButtonType.Normal,
          buttonStyle: ButtonStyleMode.TEXTUAL,
          role: ButtonRole.NORMAL
        })
          .fontSize(YoTypeStyle.BODY_M.size)
          .fontColor(YoColor.BRAND_PRIMARY)
          .enabled(!this.params.connecting)
          .onClick(() => {
            this.openFavoriteForm('', '', '');
          })
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)

      if (this.params.favorites.length === 0) {
        Text($r('app.string.bt_spp_uuid_favorites_empty'))
          .fontSize(YoTypeStyle.BODY_M.size)
          .fontColor(YoColor.TEXT_SECONDARY)
          .width('100%')
          .textAlign(TextAlign.Center)
          .margin({ top: YoSpace.XXXL })
      } else {
        List({ space: 0 }) {
          ForEach(this.params.favorites, (entry: SppUuidFavoriteEntry, index: number) => {
            ListItem() {
              Row({ space: YoSpace.M }) {
                Column({ space: YoSpace.XXS }) {
                  Text(entry.displayTitle())
                    .fontSize(YoTypeStyle.BODY_M.size)
                    .fontColor(YoColor.TEXT_PRIMARY)
                    .width('100%')
                    .maxLines(1)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                  Text(entry.uuid)
                    .fontSize(YoTypeStyle.MONO_S.size)
                    .fontFamily('HarmonyOS Sans Mono')
                    .fontColor(YoColor.TEXT_TERTIARY)
                    .width('100%')
                    .maxLines(1)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Start)

                SymbolGlyph($r('sys.symbol.pencil_line'))
                  .fontSize(YoSize.ICON_S)
                  .fontColor([$r('sys.color.icon_secondary')])
                  .width(YoSize.TOUCH_TARGET_MIN)
                  .height(YoSize.TOUCH_TARGET_MIN)
                  .onClick(() => {
                    this.openFavoriteForm(entry.uuid, entry.label, entry.uuid);
                  })
              }
              .width('100%')
              .constraintSize({ minHeight: YoSize.LIST_CARD_HEIGHT })
              .padding({ top: YoSpace.M, bottom: YoSpace.M })
              .onClick(() => {
                this.applyFavoriteIndex(index);
                this.showFavoriteSheet = false;
              })
            }
            .swipeAction({
              end: {
                builder: () => {
                  this.FavoriteDeleteAction(entry.uuid);
                }
              }
            })
          }, (entry: SppUuidFavoriteEntry) => entry.uuid)
        }
        .width('100%')
        .layoutWeight(1)
        .scrollBar(BarState.Auto)
        .edgeEffect(EdgeEffect.Spring)
        .nestedScroll({
          scrollForward: NestedScrollMode.PARENT_FIRST,
          scrollBackward: NestedScrollMode.PARENT_FIRST
        })
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  FavoriteDeleteAction(uuid: string) {
    Button($r('app.string.bt_spp_uuid_favorite_delete'))
      .type(ButtonType.Normal)
      .backgroundColor(YoColor.ERROR)
      .fontColor(Color.White)
      .fontSize(YoTypeStyle.BODY_M.size)
      .width(72)
      .height('100%')
      .onClick(() => {
        void this.handleRemoveFavorite(uuid);
      })
  }

  @Builder
  buildFavoriteFormPane() {
    Column({ space: YoSpace.L }) {
      Text(this.formOriginalUuid.length > 0 ?
        $r('app.string.bt_spp_uuid_favorite_form_edit_title') :
        $r('app.string.bt_spp_uuid_favorite_form_add_title'))
        .fontSize(YoTypeStyle.SUBTITLE_M.size)
        .fontWeight(FontWeight.Medium)
        .fontColor(YoColor.TEXT_PRIMARY)
        .width('100%')

      Column({ space: YoSpace.XS }) {
        Text($r('app.string.bt_spp_uuid_favorite_label'))
          .fontSize(YoTypeStyle.BODY_S.size)
          .fontColor(YoColor.TEXT_SECONDARY)
          .width('100%')
        TextInput({
          text: this.formLabelText,
          placeholder: $r('app.string.bt_spp_uuid_favorite_label_placeholder')
        })
          .width('100%')
          .height(YoSize.BUTTON_HEIGHT_COMPACT)
          .showUnderline(false)
          .backgroundColor(Color.Transparent)
          .fontSize(YoTypeStyle.BODY_M.size)
          .padding({ left: YoSpace.M, right: YoSpace.M })
          .border({
            width: YoStroke.THIN,
            color: YoColor.BORDER_PRIMARY,
            radius: YoRadius.XLARGE
          })
          .onChange((text: string) => {
            this.formLabelText = text;
          })
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)

      Column({ space: YoSpace.XS }) {
        Text($r('app.string.bt_spp_connect_uuid_label'))
          .fontSize(YoTypeStyle.BODY_S.size)
          .fontColor(YoColor.TEXT_SECONDARY)
          .width('100%')
        TextInput({
          text: this.formUuidText,
          placeholder: $r('app.string.bt_spp_connect_uuid_custom_placeholder')
        })
          .width('100%')
          .height(YoSize.BUTTON_HEIGHT_COMPACT)
          .showUnderline(false)
          .backgroundColor(Color.Transparent)
          .fontSize(YoTypeStyle.MONO_S.size)
          .fontFamily('HarmonyOS Sans Mono')
          .padding({ left: YoSpace.M, right: YoSpace.M })
          .border({
            width: YoStroke.THIN,
            color: YoColor.BORDER_PRIMARY,
            radius: YoRadius.XLARGE
          })
          .onChange((text: string) => {
            this.formUuidText = text;
          })
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)

      Blank()

      Row() {
        Button($r('app.string.bt_spp_action_cancel'), {
          type: ButtonType.Normal,
          buttonStyle: ButtonStyleMode.TEXTUAL,
          role: ButtonRole.NORMAL
        })
          .layoutWeight(1)
          .height(YoSize.BUTTON_HEIGHT)
          .enabled(!this.formSaving)
          .onClick(() => {
            this.favoriteSheetMode = FavoriteSheetMode.LIST;
          })

        Button($r('app.string.bt_spp_uuid_favorite_save'), {
          type: ButtonType.Normal,
          buttonStyle: ButtonStyleMode.TEXTUAL,
          role: ButtonRole.NORMAL
        })
          .layoutWeight(1)
          .height(YoSize.BUTTON_HEIGHT)
          .fontColor(YoColor.BRAND_PRIMARY)
          .enabled(!this.formSaving && this.formUuidText.trim().length > 0)
          .onClick(() => {
            void this.handleSaveFavoriteForm();
          })
      }
      .width('100%')
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  buildUuidSection() {
    Column() {
      Text($r('app.string.bt_spp_connect_uuid_label'))
        .fontSize(YoTypeStyle.BODY_S.size)
        .fontColor(YoColor.TEXT_SECONDARY)
        .width('100%')

      SegmentButton({
        options: this.uuidSegmentOptions,
        selectedIndexes: $uuidSelectedIndexes,
        onItemClicked: (index: number) => {
          this.applyUuidMode(index as SppUuidPickMode);
        }
      })
        .margin({ top: YoSpace.M })

      ForEach([this.uuidFieldEpoch], (_epoch: number) => {
        this.buildDataField(
          this.params.uuid,
          this.uuidPlaceholder(),
          true,
          InputType.Normal,
          this.isUuidEditable() && !this.params.connecting,
          YoColor.BORDER_PRIMARY,
          (text: string) => {
            this.params.uuid = text;
            if (this.params.uuidMode === SppUuidPickMode.CUSTOM) {
              this.params.customUuidDraft = text;
            }
            this.params.onUuidInputChanged();
            this.clearError();
          }
        );
      }, (epoch: number) => `spp-uuid-${epoch}`)
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  buildDataField(
    value: string,
    placeholder: ResourceStr,
    mono: boolean,
    inputType: InputType,
    enabled: boolean,
    borderColor: Resource,
    onChange: (text: string) => void
  ) {
    Row() {
      if (!enabled) {
        Text(value.length > 0 ? value : '')
          .width('100%')
          .fontSize(mono ? YoTypeStyle.MONO_S.size : YoTypeStyle.BODY_M.size)
          .fontFamily(mono ? 'HarmonyOS Sans Mono' : 'HarmonyOS Sans')
          .fontColor(YoColor.TEXT_SECONDARY)
          .textAlign(TextAlign.Center)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      } else {
        TextInput({ text: value, placeholder: placeholder })
          .width('100%')
          .height(YoSize.BUTTON_HEIGHT_COMPACT)
          .type(inputType)
          .style(TextInputStyle.Default)
          .showUnderline(false)
          .backgroundColor(Color.Transparent)
          .fontSize(mono ? YoTypeStyle.MONO_S.size : YoTypeStyle.BODY_M.size)
          .fontFamily(mono ? 'HarmonyOS Sans Mono' : 'HarmonyOS Sans')
          .textAlign(TextAlign.Center)
          .padding({ left: YoSpace.S, right: YoSpace.S })
          .onChange((text: string) => {
            onChange(text);
          })
      }
    }
    .width('100%')
    .height(YoSize.BUTTON_HEIGHT_COMPACT)
    .padding({ left: YoSpace.M, right: YoSpace.M })
    .margin({ top: YoSpace.XL })
    .justifyContent(FlexAlign.Center)
    .alignItems(VerticalAlign.Center)
    .border({
      width: YoStroke.THIN,
      color: borderColor,
      radius: YoRadius.XLARGE
    })
    .clip(true)
  }

  @Builder
  buildSettingsSection() {
    Column() {
      this.buildTimeoutRow();
      Divider()
        .color(YoColor.DIVIDER)
        .strokeWidth(0.5)
      this.buildSettingRow(
        $r('app.string.bt_spp_connect_secure_label'),
        $r('app.string.bt_spp_connect_secure_desc'),
        this.params.secure,
        (isOn: boolean) => {
          this.params.secure = isOn;
        },
        false
      );
      Divider()
        .color(YoColor.DIVIDER)
        .strokeWidth(0.5)
      this.buildSettingRow(
        $r('app.string.bt_spp_connect_auto_reconnect_label'),
        $r('app.string.bt_spp_connect_auto_reconnect_desc'),
        this.params.autoReconnect,
        (isOn: boolean) => {
          this.params.autoReconnect = isOn;
        },
        true
      );
    }
    .width('100%')
  }

  @Builder
  buildTimeoutRow() {
    Column({ space: YoSpace.XS }) {
      Row() {
        Column({ space: YoSpace.XXS }) {
          Text($r('app.string.bt_spp_connect_timeout_label'))
            .fontSize(YoTypeStyle.BODY_M.size)
            .fontColor(YoColor.TEXT_PRIMARY)
            .width('100%')
          Text($r('app.string.bt_spp_connect_timeout_unit'))
            .fontSize(YoTypeStyle.BODY_S.size)
            .fontColor(YoColor.TEXT_TERTIARY)
            .width('100%')
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)

        Blank()

        Row() {
          TextInput({ text: this.params.timeoutText })
            .width('100%')
            .height(32)
            .type(InputType.Number)
            .style(TextInputStyle.Default)
            .showUnderline(false)
            .backgroundColor(Color.Transparent)
            .fontSize(YoTypeStyle.BODY_S.size)
            .textAlign(TextAlign.Center)
            .padding(0)
            .enabled(!this.params.connecting)
            .onChange((text: string) => {
              this.params.timeoutText = text;
              this.clearError();
            })
        }
        .width(64)
        .height(32)
        .padding({ left: YoSpace.XS, right: YoSpace.XS })
        .border({
          width: YoStroke.THIN,
          color: this.isTimeoutValid() ? YoColor.BORDER_PRIMARY : YoColor.ERROR,
          radius: YoRadius.XLARGE
        })
        .clip(true)
      }
      .width('100%')
      .constraintSize({ minHeight: YoSize.LIST_ROW_HEIGHT })
      .padding({ top: YoSpace.S, bottom: YoSpace.S })
      .alignItems(VerticalAlign.Center)

      if (!this.isTimeoutValid() && this.params.timeoutText.trim().length > 0) {
        Text($r('app.string.bt_spp_connect_timeout_invalid'))
          .fontSize(YoTypeStyle.BODY_S.size)
          .fontColor(YoColor.ERROR)
          .width('100%')
      }
    }
    .width('100%')
  }

  @Builder
  buildSettingRow(
    title: ResourceStr,
    description: ResourceStr,
    isOn: boolean,
    onChange: (isOn: boolean) => void,
    isLast: boolean
  ) {
    Row() {
      Column({ space: YoSpace.XXS }) {
        Text(title)
          .fontSize(YoTypeStyle.BODY_M.size)
          .fontColor(YoColor.TEXT_PRIMARY)
          .width('100%')
        Text(description)
          .fontSize(YoTypeStyle.BODY_S.size)
          .fontColor(YoColor.TEXT_TERTIARY)
          .width('100%')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      Blank()

      Toggle({ type: ToggleType.Switch, isOn: isOn })
        .selectedColor(YoColor.BRAND_PRIMARY)
        .enabled(!this.params.connecting)
        .onChange((next: boolean) => {
          onChange(next);
        })
    }
    .width('100%')
    .constraintSize({ minHeight: YoSize.LIST_ROW_HEIGHT })
    .padding({ top: YoSpace.S, bottom: isLast ? YoSpace.NONE : YoSpace.S })
    .alignItems(VerticalAlign.Center)
  }

  private buildTitleMenus(): YoTitleBarMenuItem[] {
    const bookmarkIcon = this.params.currentUuidFavorited ?
      $r('sys.symbol.bookmark_fill') :
      $r('sys.symbol.bookmark');
    const bookmarkColor: ResourceColor | undefined = this.params.currentUuidFavorited ?
      YoColor.BRAND_PRIMARY :
      undefined;
    return [
      new YoTitleBarMenuItem(
        'spp_uuid_favorite_list',
        $r('sys.symbol.list_bullet'),
        $r('app.string.bt_spp_uuid_favorites_title'),
        () => {
          this.openFavoriteSheet();
        },
        !this.params.connecting,
        'spp_connect_favorite_list'
      ),
      new YoTitleBarMenuItem(
        'spp_uuid_favorite_bookmark',
        bookmarkIcon,
        $r('app.string.bt_spp_uuid_favorites_title'),
        () => {
          this.params.onToggleFavorite();
        },
        !this.params.connecting,
        'spp_connect_favorite_bookmark',
        bookmarkColor
      )
    ];
  }

  private openFavoriteSheet(): void {
    if (this.params.connecting) {
      return;
    }
    this.favoriteSheetMode = FavoriteSheetMode.LIST;
    this.showFavoriteSheet = true;
  }

  private openFavoriteForm(originalUuid: string, label: string, uuid: string): void {
    this.formOriginalUuid = originalUuid;
    this.formLabelText = label;
    this.formUuidText = uuid;
    this.formSaving = false;
    this.favoriteSheetMode = FavoriteSheetMode.FORM;
  }

  private resetFavoriteSheetState(): void {
    this.showFavoriteSheet = false;
    this.favoriteSheetMode = FavoriteSheetMode.LIST;
    this.formOriginalUuid = '';
    this.formLabelText = '';
    this.formUuidText = '';
    this.formSaving = false;
  }

  private async handleSaveFavoriteForm(): Promise<void> {
    if (this.formSaving) {
      return;
    }
    this.formSaving = true;
    const outcome = await this.params.saveFavorite(
      this.formOriginalUuid,
      this.formUuidText,
      this.formLabelText
    );
    this.formSaving = false;
    if (outcome === 'ok') {
      this.favoriteSheetMode = FavoriteSheetMode.LIST;
      return;
    }
    this.toastFavoriteOutcome(outcome);
  }

  private async handleRemoveFavorite(uuid: string): Promise<void> {
    const outcome = await this.params.removeFavorite(uuid);
    if (outcome === 'ok') {
      YoToast.show($r('app.string.bt_spp_uuid_favorite_deleted'));
      return;
    }
    this.toastFavoriteOutcome(outcome);
  }

  private toastFavoriteOutcome(outcome: string): void {
    if (outcome === 'invalid') {
      YoToast.showWarning($r('app.string.bt_spp_uuid_favorite_invalid'));
      return;
    }
    if (outcome === 'limit') {
      YoToast.showWarning($r('app.string.bt_spp_uuid_favorite_limit'));
      return;
    }
    if (outcome === 'duplicate') {
      YoToast.showWarning($r('app.string.bt_spp_uuid_favorite_duplicate'));
      return;
    }
    YoToast.showError($r('app.string.bt_spp_uuid_favorite_failed'));
  }

  private applyFavoriteIndex(index: number): void {
    this.params.onSelectFavoriteIndex(index);
    this.uuidSelectedIndexes = [SppUuidPickMode.CUSTOM as number];
    this.uuidFieldEpoch = this.uuidFieldEpoch + 1;
    this.clearError();
  }

  private onUuidSegmentChange(): void {
    if (this.uuidSelectedIndexes.length === 0) {
      return;
    }
    this.applyUuidMode(this.uuidSelectedIndexes[0] as SppUuidPickMode);
  }

  private applyUuidMode(mode: SppUuidPickMode): void {
    if (this.params.connecting) {
      return;
    }
    if (this.uuidSelectedIndexes.length === 0 || this.uuidSelectedIndexes[0] !== (mode as number)) {
      this.uuidSelectedIndexes = [mode as number];
    }
    if (this.params.uuidMode === SppUuidPickMode.CUSTOM) {
      this.params.customUuidDraft = this.params.uuid;
    }
    this.params.uuidMode = mode;
    if (mode === SppUuidPickMode.STANDARD) {
      this.params.uuid = BluetoothConstants.DEFAULT_SPP_UUID;
    } else if (mode === SppUuidPickMode.NORDIC) {
      this.params.uuid = BluetoothConstants.NORDIC_UART_SERVICE_UUID;
    } else {
      this.params.uuid = this.params.customUuidDraft;
    }
    this.params.onUuidInputChanged();
    this.uuidFieldEpoch = this.uuidFieldEpoch + 1;
    this.clearError();
  }

  private deviceLineText(): string {
    const name = this.params.displayName.length > 0 ?
      this.params.displayName :
      this.params.classicDeviceId;
    if (this.params.classicDeviceId.length === 0 || name === this.params.classicDeviceId) {
      return name;
    }
    return `${name} · ${this.params.classicDeviceId}`;
  }

  private connectLabel(): ResourceStr {
    return this.params.connecting ?
      $r('app.string.bt_spp_connect_connecting') :
      $r('app.string.bt_spp_action_connect');
  }

  private isUuidEditable(): boolean {
    return this.params.uuidMode === SppUuidPickMode.NORDIC ||
      this.params.uuidMode === SppUuidPickMode.CUSTOM;
  }

  private uuidPlaceholder(): ResourceStr {
    if (this.params.uuidMode === SppUuidPickMode.CUSTOM) {
      return $r('app.string.bt_spp_connect_uuid_custom_placeholder');
    }
    return $r('app.string.bt_spp_connect_uuid_placeholder');
  }

  private isTimeoutValid(): boolean {
    const raw = this.params.timeoutText.trim();
    if (raw.length === 0) {
      return false;
    }
    const value = Number(raw);
    return !Number.isNaN(value) && value > 0;
  }

  private canConnect(): boolean {
    return !this.params.connecting &&
      this.params.classicDeviceId.length > 0 &&
      this.params.uuid.trim().length > 0 &&
      this.isTimeoutValid();
  }

  private clearError(): void {
    if (this.params.errorMessage.length === 0) {
      return;
    }
    this.params.errorMessage = '';
    this.params.hintLines = [];
    this.params.errorModel = new YoErrorStateModel();
  }
}

@Builder
function buildSppConnectDialogContent(params: SppConnectDialogParams) {
  SppConnectDialogContent({ params: params });
}

/**
 * SPP RFCOMM 连接弹窗。
 * 手绘内容 + openCustomDialog；底栏 TEXTUAL 使用系统按压态；失败保留弹窗。
 */
export class SppConnectDialog {
  private static current: SppConnectDialog | undefined = undefined;

  private readonly uiContext: UIContext;
  private readonly params: SppConnectDialogParams = new SppConnectDialogParams();
  private readonly controller: SppConnectDialogController = new SppConnectDialogController();
  private contentNode: ComponentContent<SppConnectDialogParams> | undefined = undefined;
  private showing: boolean = false;

  private constructor(uiContext: UIContext) {
    this.uiContext = uiContext;
  }

  static open(
    item: ClassicDeviceListItem,
    onConnected: (sessionId: string) => void,
    uiContext?: UIContext
  ): void {
    const ctx = uiContext ?? UIContextRegistry.getInstance().get();
    if (ctx === undefined) {
      return;
    }
    if (SppConnectDialog.current !== undefined) {
      SppConnectDialog.current.close();
    }
    const dialog = new SppConnectDialog(ctx);
    dialog.params.classicDeviceId = item.classicDeviceId;
    dialog.params.displayName = item.displayName.length > 0 ? item.displayName : item.address;
    dialog.params.transport = item.transport;
    dialog.params.uuidMode = SppUuidPickMode.STANDARD;
    dialog.params.uuid = BluetoothConstants.DEFAULT_SPP_UUID;
    dialog.params.customUuidDraft = '';
    dialog.params.secure = false;
    dialog.params.timeoutText = `${BluetoothConstants.DEFAULT_SPP_CONNECT_TIMEOUT_MS}`;
    dialog.params.autoReconnect = false;
    dialog.params.connecting = false;
    dialog.params.errorMessage = '';
    dialog.params.hintLines = [];
    dialog.params.favorites = [];
    dialog.params.currentUuidFavorited = false;
    dialog.params.errorModel = new YoErrorStateModel();
    dialog.params.onCancel = () => {
      dialog.close();
    };
    dialog.params.onConnected = (sessionId: string) => {
      onConnected(sessionId);
      dialog.close();
    };
    dialog.params.onConnect = () => {
      void dialog.controller.connectFromDialog(dialog.params);
    };
    dialog.params.onToggleFavorite = () => {
      void dialog.handleToggleFavorite();
    };
    dialog.params.onSelectFavoriteIndex = (index: number) => {
      dialog.controller.selectFavoriteIndex(dialog.params, index);
    };
    dialog.params.onUuidInputChanged = () => {
      dialog.controller.refreshFavoriteState(dialog.params);
    };
    dialog.params.saveFavorite = (originalUuid: string, uuid: string, label: string): Promise<string> => {
      return dialog.controller.saveFavorite(dialog.params, originalUuid, uuid, label);
    };
    dialog.params.removeFavorite = (uuid: string): Promise<string> => {
      return dialog.controller.removeFavorite(dialog.params, uuid);
    };
    SppConnectDialog.current = dialog;
    void dialog.controller.loadFavorites(dialog.params).then(() => {
      dialog.show();
    });
  }

  private async handleToggleFavorite(): Promise<void> {
    const outcome = await this.controller.toggleFavorite(this.params);
    if (outcome === 'invalid') {
      YoToast.showWarning($r('app.string.bt_spp_uuid_favorite_invalid'), this.uiContext);
      return;
    }
    if (outcome === 'limit') {
      YoToast.showWarning($r('app.string.bt_spp_uuid_favorite_limit'), this.uiContext);
      return;
    }
    if (outcome === 'failed' || outcome === 'duplicate' || outcome === 'not_found') {
      YoToast.showError($r('app.string.bt_spp_uuid_favorite_failed'), this.uiContext);
    }
  }

  private show(): void {
    this.contentNode = new ComponentContent(
      this.uiContext,
      wrapBuilder(buildSppConnectDialogContent),
      this.params
    );
    const options: promptAction.BaseDialogOptions = {
      alignment: DialogAlignment.Center,
      isModal: true,
      autoCancel: true,
      showInSubWindow: false,
      onWillDismiss: (dismissDialogAction: DismissDialogAction) => {
        if (this.params.connecting) {
          return;
        }
        dismissDialogAction.dismiss();
        this.clearReferences();
      }
    };
    this.uiContext.getPromptAction().openCustomDialog(this.contentNode, options)
      .then(() => {
        this.showing = true;
      })
      .catch((_error: BusinessError) => {
        this.clearReferences();
      });
  }

  close(): void {
    if (!this.showing || this.contentNode === undefined) {
      this.clearReferences();
      return;
    }
    const node = this.contentNode;
    this.uiContext.getPromptAction().closeCustomDialog(node)
      .then(() => {
        node.dispose();
        this.clearReferences();
      })
      .catch((_error: BusinessError) => {
        try {
          node.dispose();
        } catch (_disposeError) {
          // ignore
        }
        this.clearReferences();
      });
  }

  private clearReferences(): void {
    this.showing = false;
    this.contentNode = undefined;
    if (SppConnectDialog.current === this) {
      SppConnectDialog.current = undefined;
    }
  }
}
