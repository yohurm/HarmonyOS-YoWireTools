import {
  CommandDockAction,
  CommandDockView,
  ContentStateHost,
  DataTerminalView,
  LoadingStateModel,
  RiskConfirmVariant,
  UiPageState,
  UiResponsive,
  UiResourceUtil,
  YoNavDestinationKind,
  YoPageShell
} from 'common_ui';
import { WindowMetricsRegistry, WindowMetricsState, WindowWidthBreakpointUtil } from 'common_platform';
import { BleMainViewModel } from '../../viewmodel/BleMainViewModel';
import { BtSummaryCard } from '../component/BtSummaryCard';

@ComponentV2
export struct BleMainPage {
  @Event onBack: () => void = () => {
  };
  @Local private vm: BleMainViewModel = new BleMainViewModel();
  @Local private metrics: WindowMetricsState = WindowMetricsRegistry.connect();
  @Local private commandInput: string = '';
  @Local private isSending: boolean = false;
  @Local private periodicActive: boolean = false;
  @Local private terminalLines: string[] = [];

  aboutToAppear(): void {
    void this.vm.onPageAppear();
  }

  @LocalBuilder
  pageContent() {
    ContentStateHost({
      state: this.vm.isLoading ? UiPageState.LOADING : UiPageState.CONTENT,
      loadingModel: new LoadingStateModel($r('app.string.ui_loading_default_message')),
      content: this.pageBody
    })
  }

  @LocalBuilder
  pageBody() {
    Column({ space: UiResponsive.SECTION_GAP }) {
      BtSummaryCard({
        title: $r('app.string.bt_ble_page_title'),
        ready: this.vm.ready,
        primaryMetricLabel: $r('app.string.bt_ble_metric_devices'),
        primaryMetricValue: this.vm.discoveredDeviceCount,
        sessionMetricValue: this.vm.activeSessionCount
      })
      DataTerminalView({
        lines: this.terminalLines,
        emptyHint: $r('app.string.bt_terminal_empty')
      })
        .layoutWeight(1)
      CommandDockView({
        inputValue: this.commandInput,
        placeholder: $r('app.string.bt_command_placeholder'),
        canSubmit: this.vm.ready,
        isSendEnabled: this.vm.ready,
        isLoading: this.isSending,
        sendDisabledReason: this.vm.ready ? '' : $r('app.string.ui_send_disabled_not_connected'),
        collapsed: !WindowWidthBreakpointUtil.isSplitCapable(this.metrics.breakpoint),
        periodicActive: this.periodicActive,
        secondaryActions: this.buildSecondaryActions(),
        onInputChange: (value: string) => {
          this.commandInput = value;
        },
        onSend: (text: string) => {
          void this.handleSend(text);
        },
        onSecondaryAction: (key: string) => {
          this.handleSecondaryAction(key);
        },
        onStopPeriodic: () => {
          this.periodicActive = false;
        }
      })
    }
    .width('100%')
    .height('100%')
  }

  build() {
    YoPageShell({
      title: $r('app.string.bt_ble_page_title'),
      showBack: true,
      destinationKind: YoNavDestinationKind.MODULE,
      scrollable: false,
      immersiveTitleBar: true,
      onBack: this.onBack,
      content: this.pageContent
    })
  }

  private buildSecondaryActions(): CommandDockAction[] {
    return [
      new CommandDockAction('hex', $r('app.string.ui_action_hex')),
      new CommandDockAction('periodic', $r('app.string.ui_action_periodic'), {
        variant: RiskConfirmVariant.WARNING,
        title: $r('app.string.ui_risk_periodic_title'),
        message: $r('app.string.ui_risk_periodic_message'),
        confirmLabel: $r('app.string.ui_risk_periodic_confirm')
      }),
      new CommandDockAction('disconnect', $r('app.string.ui_action_disconnect'), {
        variant: RiskConfirmVariant.DANGER,
        title: $r('app.string.ui_risk_disconnect_title'),
        message: $r('app.string.ui_risk_disconnect_message'),
        confirmLabel: $r('app.string.ui_risk_disconnect_confirm')
      })
    ];
  }

  private async handleSend(text: string): Promise<void> {
    if (!this.vm.ready || text.length === 0) {
      return;
    }
    this.isSending = true;
    this.terminalLines = [...this.terminalLines, UiResourceUtil.format($r('app.string.bt_terminal_tx_line'), text)];
    this.commandInput = '';
    this.isSending = false;
  }

  private handleSecondaryAction(key: string): void {
    if (key === 'periodic') {
      this.periodicActive = true;
      return;
    }
    if (key === 'disconnect') {
      this.periodicActive = false;
      this.terminalLines = [...this.terminalLines, UiResourceUtil.resolveText($r('app.string.bt_terminal_disconnected'))];
    }
  }
}
