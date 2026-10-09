import {
  YoActionButton,
  YoActionButtonKind,
  YoColor,
  YoNavDestinationKind,
  YoPageShell,
  YoSpace,
  YoStatusPill,
  YoTypeStyle
} from 'youi_kit';
import { NearLinkDestination } from '../../domain/model/NearLinkScreenCategory';
import { NearLinkSecurityState } from '../../domain/model/NearLinkSecurityState';
import { NearLinkDebugModel } from '../state/NearLinkDebugModel';

@ComponentV2
export struct NearLinkAdvertisingView {
  @Param @Require vm: NearLinkDebugModel;

  @LocalBuilder
  pageContent() {
    Column({ space: YoSpace.S }) {
      TextInput({ text: this.vm.advInterval, placeholder: $r('app.string.nl_interval') })
        .onChange((value: string) => {
          this.vm.advInterval = value;
        })
      TextInput({ text: this.vm.advServiceUuid, placeholder: $r('app.string.nl_service_uuid') })
        .onChange((value: string) => {
          this.vm.advServiceUuid = value;
        })
      Row({ space: YoSpace.S }) {
        Toggle({ type: ToggleType.Switch, isOn: this.vm.advConnectable })
          .onChange((on: boolean) => {
            this.vm.advConnectable = on;
          })
        Text($r('app.string.nl_connectable'))
          .fontSize(YoTypeStyle.BODY_S.size)
      }
      Row({ space: YoSpace.S }) {
        Toggle({ type: ToggleType.Switch, isOn: this.vm.advIncludeName })
          .onChange((on: boolean) => {
            this.vm.advIncludeName = on;
          })
        Text($r('app.string.nl_include_name'))
          .fontSize(YoTypeStyle.BODY_S.size)
      }
      YoActionButton({
        label: $r('app.string.nl_adv_start'),
        isEnabled: !this.vm.advRunning,
        loading: false,
        onTap: () => {
          void this.vm.beginAdvertising();
        }
      })
      YoActionButton({
        label: $r('app.string.nl_adv_stop'),
        kind: YoActionButtonKind.SECONDARY,
        isEnabled: this.vm.advRunning,
        onTap: () => {
          void this.vm.endAdvertising();
        }
      })
      if (this.vm.actionMessage.length > 0) {
        Text(this.vm.actionLabel())
          .fontSize(YoTypeStyle.BODY_S.size)
          .fontColor(YoColor.ERROR)
      }
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  build() {
    YoPageShell({
      title: $r('app.string.nl_title_advertising'),
      destinationKind: YoNavDestinationKind.MODULE,
      showBack: true,
      content: this.pageContent,
      onBack: () => {
        this.vm.back();
      }
    })
  }
}

@ComponentV2
export struct NearLinkSsapClientView {
  @Param @Require vm: NearLinkDebugModel;

  @LocalBuilder
  pageContent() {
    Column({ space: YoSpace.S }) {
      Text(this.vm.selectedAddress)
        .fontSize(YoTypeStyle.BODY_M.size)
      if (this.vm.ssapReused) {
        Text($r('app.string.nl_client_reused'))
          .fontSize(YoTypeStyle.BODY_S.size)
          .fontColor(YoColor.TEXT_SECONDARY)
      }
      if (this.vm.notifyHint && !this.vm.ssapConnected) {
        Text($r('app.string.nl_notify_off'))
          .fontSize(YoTypeStyle.BODY_S.size)
          .fontColor(YoColor.WARNING)
      }
      TextInput({ text: this.vm.ssapServiceUuid, placeholder: $r('app.string.nl_service_uuid') })
        .onChange((value: string) => {
          this.vm.ssapServiceUuid = value;
        })
      TextInput({ text: this.vm.ssapPropertyUuid, placeholder: $r('app.string.nl_property') })
        .onChange((value: string) => {
          this.vm.ssapPropertyUuid = value;
        })
      TextInput({ text: this.vm.ssapOperation, placeholder: $r('app.string.nl_operation') })
        .onChange((value: string) => {
          this.vm.ssapOperation = value;
        })
      TextInput({ text: this.vm.ssapHex, placeholder: $r('app.string.nl_payload') })
        .onChange((value: string) => {
          this.vm.ssapHex = value;
        })
      TextInput({ text: this.vm.ssapMtuText, placeholder: $r('app.string.nl_mtu') })
        .onChange((value: string) => {
          this.vm.ssapMtuText = value;
        })
      Row({ space: YoSpace.S }) {
        Toggle({ type: ToggleType.Switch, isOn: this.vm.ssapWithResponse })
          .onChange((on: boolean) => {
            this.vm.ssapWithResponse = on;
          })
        Text($r('app.string.nl_with_response'))
          .fontSize(YoTypeStyle.BODY_S.size)
      }
      YoActionButton({
        label: $r('app.string.nl_connect'),
        onTap: () => {
          void this.vm.connectSsap();
        }
      })
      YoActionButton({
        label: $r('app.string.nl_disconnect'),
        kind: YoActionButtonKind.SECONDARY,
        onTap: () => {
          void this.vm.disconnectSsap();
        }
      })
      YoActionButton({
        label: $r('app.string.nl_read'),
        kind: YoActionButtonKind.SECONDARY,
        onTap: () => {
          void this.vm.readSsap();
        }
      })
      YoActionButton({
        label: $r('app.string.nl_write'),
        kind: YoActionButtonKind.SECONDARY,
        onTap: () => {
          void this.vm.writeSsap(false);
        }
      })
      if (this.vm.sliceRequired) {
        Text($r('app.string.nl_slice_prompt'))
          .fontSize(YoTypeStyle.BODY_S.size)
          .fontColor(YoColor.WARNING)
        YoActionButton({
          label: $r('app.string.nl_slice_confirm'),
          onTap: () => {
            void this.vm.writeSsap(true);
          }
        })
      }
      YoActionButton({
        label: $r('app.string.nl_notify'),
        kind: YoActionButtonKind.SECONDARY,
        onTap: () => {
          void this.vm.toggleNotify();
        }
      })
      YoActionButton({
        label: $r('app.string.nl_mtu'),
        kind: YoActionButtonKind.SECONDARY,
        onTap: () => {
          void this.vm.requestMtu();
        }
      })
      if (this.vm.actionMessage.length > 0) {
        Text(this.vm.actionLabel())
          .fontSize(YoTypeStyle.BODY_S.size)
          .fontColor(YoColor.ERROR)
      }
      if (this.vm.nativeCode.length > 0) {
        Text(this.vm.nativeCode)
          .fontSize(YoTypeStyle.BODY_S.size)
          .fontColor(YoColor.ERROR)
      }
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  build() {
    YoPageShell({
      title: $r('app.string.nl_title_ssap_client'),
      destinationKind: YoNavDestinationKind.OBJECT,
      showBack: true,
      content: this.pageContent,
      onBack: () => {
        this.vm.back();
      }
    })
  }
}

@ComponentV2
export struct NearLinkSsapServerView {
  @Param @Require vm: NearLinkDebugModel;

  @LocalBuilder
  pageContent() {
    Column({ space: YoSpace.S }) {
      Text($r('app.string.nl_server_no_rsp'))
        .fontSize(YoTypeStyle.BODY_S.size)
        .fontColor(YoColor.TEXT_SECONDARY)
      TextInput({ text: this.vm.ssapServiceUuid, placeholder: $r('app.string.nl_service_uuid') })
        .onChange((value: string) => {
          this.vm.ssapServiceUuid = value;
        })
      TextInput({ text: this.vm.ssapPropertyUuid, placeholder: $r('app.string.nl_property') })
        .onChange((value: string) => {
          this.vm.ssapPropertyUuid = value;
        })
      TextInput({ text: this.vm.ssapOperation, placeholder: $r('app.string.nl_operation') })
        .onChange((value: string) => {
          this.vm.ssapOperation = value;
        })
      YoActionButton({
        label: $r('app.string.nl_open_server'),
        onTap: () => {
          this.vm.openServer();
        }
      })
      YoActionButton({
        label: $r('app.string.nl_add_service'),
        kind: YoActionButtonKind.SECONDARY,
        onTap: () => {
          this.vm.addServerService();
        }
      })
      YoActionButton({
        label: $r('app.string.nl_remove_service'),
        kind: YoActionButtonKind.SECONDARY,
        onTap: () => {
          this.vm.removeServerService();
        }
      })
      YoActionButton({
        label: $r('app.string.nl_close_server'),
        kind: YoActionButtonKind.DANGER,
        onTap: () => {
          this.vm.closeServer();
        }
      })
      ForEach(this.vm.serverLines, (line: string, index: number) => {
        Text(line)
          .fontSize(YoTypeStyle.BODY_S.size)
          .width('100%')
      }, (line: string, index: number) => `${index}-${line}`)
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  build() {
    YoPageShell({
      title: $r('app.string.nl_title_ssap_server'),
      destinationKind: YoNavDestinationKind.MODULE,
      showBack: true,
      content: this.pageContent,
      onBack: () => {
        this.vm.back();
      }
    })
  }
}

@ComponentV2
export struct NearLinkPortView {
  @Param @Require vm: NearLinkDebugModel;
  @Local confirmDestroy: boolean = false;

  @LocalBuilder
  pageContent() {
    Column({ space: YoSpace.S }) {
      YoStatusPill({ label: $r('app.string.nl_role_peer'), tone: 'neutral' })
      YoStatusPill({ label: this.encryptLabel(), tone: this.encryptTone() })
      Text($r('app.string.nl_app_layer'))
        .fontSize(YoTypeStyle.BODY_S.size)
      Text(`${this.vm.appTx} / ${this.vm.appRx}`)
        .fontSize(YoTypeStyle.BODY_M.size)
      TextInput({ text: this.vm.portUuid, placeholder: $r('app.string.nl_service_uuid') })
        .onChange((value: string) => {
          this.vm.portUuid = value;
        })
      TextInput({ text: this.vm.portMtu, placeholder: $r('app.string.nl_mtu') })
        .onChange((value: string) => {
          this.vm.portMtu = value;
        })
      TextInput({ text: this.vm.ssapHex, placeholder: $r('app.string.nl_payload') })
        .onChange((value: string) => {
          this.vm.ssapHex = value;
        })
      Row({ space: YoSpace.S }) {
        Toggle({ type: ToggleType.Switch, isOn: this.vm.portReliable })
          .onChange((on: boolean) => {
            this.vm.portReliable = on;
          })
        Text(this.vm.portReliable ? $r('app.string.nl_port_reliable') : $r('app.string.nl_port_basic'))
          .fontSize(YoTypeStyle.BODY_S.size)
      }
      Row({ space: YoSpace.S }) {
        Toggle({ type: ToggleType.Switch, isOn: this.vm.blockUnencrypted })
          .onChange((on: boolean) => {
            this.vm.blockUnencrypted = on;
          })
        Text($r('app.string.nl_block_send'))
          .fontSize(YoTypeStyle.BODY_S.size)
      }
      YoActionButton({
        label: $r('app.string.nl_create_port'),
        onTap: () => {
          this.vm.createPort();
        }
      })
      YoActionButton({
        label: $r('app.string.nl_connect'),
        kind: YoActionButtonKind.SECONDARY,
        onTap: () => {
          void this.vm.connectPort();
        }
      })
      YoActionButton({
        label: $r('app.string.nl_send'),
        kind: YoActionButtonKind.SECONDARY,
        onTap: () => {
          void this.vm.sendPort();
        }
      })
      YoActionButton({
        label: $r('app.string.nl_entry_pair'),
        kind: YoActionButtonKind.TEXT,
        onTap: () => {
          void this.vm.refreshEncryption();
          this.vm.open(NearLinkDestination.PAIRING);
        }
      })
      if (!this.confirmDestroy) {
        YoActionButton({
          label: $r('app.string.nl_destroy_port'),
          kind: YoActionButtonKind.DANGER,
          onTap: () => {
            this.confirmDestroy = true;
          }
        })
      } else {
        Text($r('app.string.nl_destroy_confirm'))
          .fontSize(YoTypeStyle.BODY_S.size)
        YoActionButton({
          label: $r('app.string.nl_destroy_confirm'),
          kind: YoActionButtonKind.DANGER,
          onTap: () => {
            this.vm.destroyPort();
            this.confirmDestroy = false;
          }
        })
      }
      if (this.vm.versionSince.length > 0 && this.vm.actionMessage.length > 0) {
        Text($r('app.string.nl_version_unavailable'))
          .fontSize(YoTypeStyle.BODY_S.size)
          .fontColor(YoColor.WARNING)
        Text(this.vm.versionSince)
          .fontSize(YoTypeStyle.BODY_S.size)
      }
      if (this.vm.nativeCode.length > 0) {
        Text(this.vm.nativeCode)
          .fontSize(YoTypeStyle.BODY_S.size)
          .fontColor(YoColor.ERROR)
      }
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  build() {
    YoPageShell({
      title: $r('app.string.nl_title_port'),
      destinationKind: YoNavDestinationKind.TERMINAL,
      showBack: true,
      content: this.pageContent,
      onBack: () => {
        this.vm.back();
      }
    })
  }

  private encryptLabel(): ResourceStr {
    if (this.vm.security === NearLinkSecurityState.ENCRYPTED) {
      return $r('app.string.nl_encrypt_on');
    }
    if (this.vm.security === NearLinkSecurityState.NOT_ENCRYPTED) {
      return $r('app.string.nl_encrypt_off');
    }
    return $r('app.string.nl_encrypt_unknown');
  }

  private encryptTone(): 'success' | 'warning' | 'neutral' {
    if (this.vm.security === NearLinkSecurityState.ENCRYPTED) {
      return 'success';
    }
    if (this.vm.security === NearLinkSecurityState.NOT_ENCRYPTED) {
      return 'warning';
    }
    return 'neutral';
  }
}

@ComponentV2
export struct NearLinkPairingView {
  @Param @Require vm: NearLinkDebugModel;

  @LocalBuilder
  pageContent() {
    Column({ space: YoSpace.S }) {
      Text($r('app.string.nl_no_pin'))
        .fontSize(YoTypeStyle.BODY_S.size)
        .fontColor(YoColor.TEXT_SECONDARY)
      YoStatusPill({ label: this.pairLabel(), tone: this.pairTone() })
      YoStatusPill({ label: this.encryptLabel(), tone: 'neutral' })
      Text(this.reasonLabel())
        .fontSize(YoTypeStyle.BODY_S.size)
        .fontColor(YoColor.TEXT_SECONDARY)
      YoActionButton({
        label: $r('app.string.nl_pair'),
        isEnabled: this.vm.selectedAddress.length > 0,
        disabledReason: $r('app.string.nl_pick_device'),
        onTap: () => {
          void this.vm.pair();
        }
      })
      YoStatusPill({ label: $r('app.string.nl_unpair_gap'), tone: 'warning' })
      Text($r('app.string.nl_unpair_settings'))
        .fontSize(YoTypeStyle.BODY_S.size)
        .fontColor(YoColor.TEXT_SECONDARY)
      if (this.vm.versionSince.length > 0) {
        Text($r('app.string.nl_version_unavailable'))
          .fontSize(YoTypeStyle.BODY_S.size)
          .fontColor(YoColor.WARNING)
        Text(this.vm.versionSince)
          .fontSize(YoTypeStyle.BODY_S.size)
      }
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  build() {
    YoPageShell({
      title: $r('app.string.nl_title_pairing'),
      destinationKind: YoNavDestinationKind.MODULE,
      showBack: true,
      content: this.pageContent,
      onBack: () => {
        this.vm.back();
      }
    })
  }

  private pairLabel(): ResourceStr {
    if (this.vm.pairingToken === 'paired' || this.vm.pairingReason === 'already_paired') {
      return $r('app.string.nl_already_paired');
    }
    if (this.vm.pairingToken === 'pairing') {
      return $r('app.string.nl_pairing');
    }
    return $r('app.string.nl_entry_pair');
  }

  private pairTone(): 'success' | 'info' | 'neutral' | 'warning' {
    if (this.vm.pairingToken === 'paired') {
      return 'success';
    }
    if (this.vm.pairingToken === 'pairing') {
      return 'info';
    }
    if (this.vm.pairingReason.length > 0 && this.vm.pairingReason !== 'success' && this.vm.pairingReason !== 'already_paired') {
      return 'warning';
    }
    return 'neutral';
  }

  private encryptLabel(): ResourceStr {
    if (this.vm.security === NearLinkSecurityState.ENCRYPTED) {
      return $r('app.string.nl_encrypt_on');
    }
    if (this.vm.security === NearLinkSecurityState.NOT_ENCRYPTED) {
      return $r('app.string.nl_encrypt_off');
    }
    return $r('app.string.nl_encrypt_unknown');
  }

  private reasonLabel(): ResourceStr {
    if (this.vm.pairingReason === 'profile_unsupported') {
      return $r('app.string.nl_reason_profile');
    }
    if (this.vm.pairingReason === 'exceed_acb_max') {
      return $r('app.string.nl_reason_acb');
    }
    if (this.vm.pairingReason === 'remote_canceled') {
      return $r('app.string.nl_reason_remote');
    }
    if (this.vm.pairingReason === 'local_canceled') {
      return $r('app.string.nl_reason_local');
    }
    if (this.vm.pairingReason === 'failure') {
      return $r('app.string.nl_reason_fail');
    }
    return $r('app.string.nl_no_pin');
  }
}
