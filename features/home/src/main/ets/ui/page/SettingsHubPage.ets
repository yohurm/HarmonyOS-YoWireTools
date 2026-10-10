import { AppMode, SettingsSnapshot } from 'debug_core';
import {
  YoActionButton,
  YoActionButtonKind,
  YoColor,
  YoSpace,
  YoTypeStyle
} from 'youi_kit';
import { SettingsViewModel } from '../../viewmodel/SettingsViewModel';

/** Settings groups hosted by the More tab. This page does not request radio permissions. */
@ComponentV2
export struct SettingsHubPage {
  @Local vm: SettingsViewModel = new SettingsViewModel();

  aboutToAppear(): void {
    void this.vm.refresh();
  }

  build() {
    Column({ space: YoSpace.L }) {
      if (this.vm.unread || this.vm.snapshot === undefined) {
        Text($r('app.string.settings_unread'))
          .fontSize(YoTypeStyle.BODY_M.size)
          .fontColor(YoColor.TEXT_SECONDARY)
          .width('100%')
      } else {
        this.groupDisplay()
        this.groupLog()
        this.groupBackground()
        this.groupCommand()
        this.groupBluetooth()
        this.groupWifi()
        this.groupNearLink()
        this.groupSecurity()
      }
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  groupTitle(title: ResourceStr) {
    Text(title)
      .fontSize(YoTypeStyle.SUBTITLE_S.size)
      .fontWeight(YoTypeStyle.SUBTITLE_S.weight)
      .fontColor(YoColor.TEXT_SECONDARY)
      .width('100%')
  }

  @Builder
  settingRow(label: ResourceStr, value: ResourceStr, onTap: () => void) {
    Row() {
      Text(label)
        .fontSize(YoTypeStyle.BODY_M.size)
        .fontColor(YoColor.TEXT_PRIMARY)
        .layoutWeight(1)
      YoActionButton({
        label: value,
        kind: YoActionButtonKind.SECONDARY,
        fullWidth: false,
        compact: true,
        onTap: onTap
      })
    }
    .width('100%')
    .alignItems(VerticalAlign.Center)
  }

  private shown(): SettingsSnapshot {
    if (this.vm.snapshot !== undefined) {
      return this.vm.snapshot;
    }
    return new SettingsSnapshot('system', AppMode.EXPERT, 30, 0, 'mixed', true, false, 'lf', true, 3000, true, false, true, false);
  }

  @Builder
  groupDisplay() {
    Column({ space: YoSpace.S }) {
      this.groupTitle($r('app.string.settings_group_display'))
      this.settingRow($r('app.string.settings_theme'), this.themeLabel(this.shown().themeMode), () => {
        void this.vm.cycleTheme();
      })
      this.settingRow($r('app.string.settings_mode'), this.modeLabel(this.shown().appMode), () => {
        void this.vm.cycleMode();
      })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  groupLog() {
    Column({ space: YoSpace.S }) {
      this.groupTitle($r('app.string.settings_group_log'))
      this.settingRow($r('app.string.settings_retention'), `${this.shown().logRetentionDays}`, () => {
        void this.vm.cycleRetention();
      })
      this.settingRow($r('app.string.settings_display'), this.shown().logDefaultDisplay, () => {
        void this.vm.cycleDisplay();
      })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  groupBackground() {
    Column({ space: YoSpace.S }) {
      this.groupTitle($r('app.string.settings_group_background'))
      this.settingRow($r('app.string.settings_bg_connection'), this.switchLabel(this.shown().allowBackgroundConnection), () => {
        void this.vm.toggleBackgroundConnection();
      })
      this.settingRow($r('app.string.settings_bg_repeat'), this.switchLabel(this.shown().allowRepeatCommand), () => {
        void this.vm.toggleRepeat();
      })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  groupCommand() {
    Column({ space: YoSpace.S }) {
      this.groupTitle($r('app.string.settings_group_command'))
      this.settingRow($r('app.string.settings_line_ending'), this.shown().commandLineEnding, () => {
        void this.vm.cycleLineEnding();
      })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  groupBluetooth() {
    Column({ space: YoSpace.S }) {
      this.groupTitle($r('app.string.settings_group_bluetooth'))
      this.settingRow($r('app.string.settings_bt_autostop'), this.switchLabel(this.shown().bluetoothAutoStopDiscovery), () => {
        void this.vm.toggleBluetooth();
      })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  groupWifi() {
    Column({ space: YoSpace.S }) {
      this.groupTitle($r('app.string.settings_group_wifi'))
      this.settingRow($r('app.string.settings_wifi_cooldown'), `${this.shown().wifiScanCooldownMs}`, () => {
        void this.vm.cycleCooldown();
      })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  groupNearLink() {
    Column({ space: YoSpace.S }) {
      this.groupTitle($r('app.string.settings_group_nearlink'))
      this.settingRow($r('app.string.settings_nl_filter'), this.switchLabel(this.shown().nearlinkRequireFilter), () => {
        void this.vm.toggleNearLink();
      })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  groupSecurity() {
    Column({ space: YoSpace.S }) {
      this.groupTitle($r('app.string.settings_group_security'))
      this.settingRow($r('app.string.settings_mask_address'), this.switchLabel(this.shown().maskAddress), () => {
        void this.vm.toggleMaskAddress();
      })
      this.settingRow($r('app.string.settings_mask_headers'), this.switchLabel(this.shown().maskHeaders), () => {
        void this.vm.toggleMaskHeaders();
      })
      YoActionButton({
        label: $r('app.string.settings_clear'),
        kind: YoActionButtonKind.DANGER,
        onTap: () => {
          this.vm.askClear();
        }
      })
      if (this.vm.confirmingClear) {
        Text($r('app.string.settings_clear_confirm'))
          .fontSize(YoTypeStyle.BODY_M.size)
          .fontColor(YoColor.TEXT_PRIMARY)
          .width('100%')
        Row({ space: YoSpace.M }) {
          YoActionButton({
            label: $r('app.string.log_confirm'),
            kind: YoActionButtonKind.DANGER,
            fullWidth: false,
            onTap: () => {
              void this.vm.confirmClear();
            }
          })
          YoActionButton({
            label: $r('app.string.log_cancel'),
            kind: YoActionButtonKind.SECONDARY,
            fullWidth: false,
            onTap: () => {
              this.vm.cancelClear();
            }
          })
        }
        .width('100%')
      }
      if (this.vm.cleared) {
        Text($r('app.string.settings_cleared'))
          .fontSize(YoTypeStyle.BODY_S.size)
          .fontColor(YoColor.TEXT_SECONDARY)
          .width('100%')
      }
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  private themeLabel(mode: string): ResourceStr {
    if (mode === 'light') {
      return $r('app.string.settings_theme_light');
    }
    if (mode === 'dark') {
      return $r('app.string.settings_theme_dark');
    }
    return $r('app.string.settings_theme_system');
  }

  private modeLabel(mode: string): ResourceStr {
    if (mode === AppMode.LIGHT) {
      return $r('app.string.settings_mode_light');
    }
    return $r('app.string.settings_mode_expert');
  }

  private switchLabel(enabled: boolean): ResourceStr {
    return enabled ? $r('app.string.settings_on') : $r('app.string.settings_off');
  }
}
