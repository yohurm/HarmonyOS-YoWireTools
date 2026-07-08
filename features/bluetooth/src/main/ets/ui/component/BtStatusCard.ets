import { WindowMetricsRegistry, WindowMetricsState, WindowWidthBreakpointUtil } from 'common_platform';
import {
  StatusPillTone,
  StatusPillView,
  UiColorToken,
  UiSpacing,
  UiTypography,
  YoImmersiveSurface
} from 'common_ui';

export type BtStatusCellKind = 'adapter' | 'permission' | 'classic' | 'ble';

export interface BtStatusCellModel {
  kind: BtStatusCellKind;
  label: ResourceStr;
  value: ResourceStr;
  tone: StatusPillTone;
  actionEnabled: boolean;
}

@ComponentV2
export struct BtStatusCard {
  @Param isLoading: boolean = false;
  @Param adapterEnabled: boolean = false;
  @Param permissionGranted: boolean = false;
  @Param classicReady: boolean = false;
  @Param bleReady: boolean = false;
  @Param classicSupported: boolean = true;
  @Param bleSupported: boolean = true;
  @Event onPermissionAction: () => void = () => {
  };
  @Event onAdapterAction: () => void = () => {
  };
  @Local private metrics: WindowMetricsState = WindowMetricsRegistry.connect();

  build() {
    YoImmersiveSurface({
      content: this.statusRow
    })
  }

  @LocalBuilder
  statusRow() {
    Row({ space: this.resolveCellGap() }) {
      this.statusCell(this.buildAdapterCell())
      this.statusCell(this.buildPermissionCell())
      this.statusCell(this.buildClassicCell())
      this.statusCell(this.buildBleCell())
    }
    .width('100%')
  }

  @Builder
  private statusCell(model: BtStatusCellModel) {
    Column({ space: UiSpacing.INLINE_STACK_GAP }) {
      Text(model.label)
        .fontSize(UiTypography.CAPTION_SIZE)
        .fontColor(UiColorToken.TEXT_TERTIARY)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .width('100%')
      Row({ space: UiSpacing.INLINE_STACK_GAP }) {
        StatusPillView({ label: model.value, tone: model.tone })
        if (model.actionEnabled) {
          Text(this.resolveActionLabel(model))
            .fontSize(UiTypography.CAPTION_SIZE)
            .fontColor(UiColorToken.PRIMARY)
            .onClick(() => this.handleCellAction(model.kind))
        }
      }
      .alignItems(VerticalAlign.Center)
    }
    .width('100%')
    .layoutWeight(1)
    .alignItems(HorizontalAlign.Start)
  }

  private handleCellAction(kind: BtStatusCellKind): void {
    if (kind === 'permission') {
      this.onPermissionAction();
    } else if (kind === 'adapter') {
      this.onAdapterAction();
    }
  }

  private resolveCellGap(): number {
    return WindowWidthBreakpointUtil.isSplitCapable(this.metrics.breakpoint)
      ? UiSpacing.CARD_GAP
      : UiSpacing.ITEM_GAP;
  }

  private buildAdapterCell(): BtStatusCellModel {
    if (this.isLoading) {
      return this.loadingCell('adapter', $r('app.string.bt_status_adapter'));
    }
    return {
      kind: 'adapter',
      label: $r('app.string.bt_status_adapter'),
      value: this.adapterEnabled ? $r('app.string.bt_status_on') : $r('app.string.bt_status_off'),
      tone: this.adapterEnabled ? 'success' : 'warning',
      actionEnabled: !this.adapterEnabled
    };
  }

  private buildPermissionCell(): BtStatusCellModel {
    if (this.isLoading) {
      return this.loadingCell('permission', $r('app.string.bt_status_permission'));
    }
    return {
      kind: 'permission',
      label: $r('app.string.bt_status_permission'),
      value: this.permissionGranted ? $r('app.string.bt_status_granted') : $r('app.string.bt_status_denied'),
      tone: this.permissionGranted ? 'success' : 'error',
      actionEnabled: !this.permissionGranted
    };
  }

  private buildClassicCell(): BtStatusCellModel {
    if (this.isLoading) {
      return this.loadingCell('classic', $r('app.string.bt_status_classic'));
    }
    if (!this.classicSupported) {
      return {
        kind: 'classic',
        label: $r('app.string.bt_status_classic'),
        value: $r('app.string.bt_status_unsupported'),
        tone: 'neutral',
        actionEnabled: false
      };
    }
    return {
      kind: 'classic',
      label: $r('app.string.bt_status_classic'),
      value: this.classicReady ? $r('app.string.bt_status_ready') : $r('app.string.bt_status_unavailable'),
      tone: this.classicReady ? 'success' : 'warning',
      actionEnabled: false
    };
  }

  private buildBleCell(): BtStatusCellModel {
    if (this.isLoading) {
      return this.loadingCell('ble', $r('app.string.bt_status_ble'));
    }
    if (!this.bleSupported) {
      return {
        kind: 'ble',
        label: $r('app.string.bt_status_ble'),
        value: $r('app.string.bt_status_unsupported'),
        tone: 'neutral',
        actionEnabled: false
      };
    }
    return {
      kind: 'ble',
      label: $r('app.string.bt_status_ble'),
      value: this.bleReady ? $r('app.string.bt_status_ready') : $r('app.string.bt_status_unavailable'),
      tone: this.bleReady ? 'success' : 'warning',
      actionEnabled: false
    };
  }

  private loadingCell(kind: BtStatusCellKind, label: ResourceStr): BtStatusCellModel {
    return {
      kind: kind,
      label: label,
      value: $r('app.string.bt_status_loading'),
      tone: 'neutral',
      actionEnabled: false
    };
  }

  private resolveActionLabel(model: BtStatusCellModel): ResourceStr {
    if (model.kind === 'permission') {
      return $r('app.string.bt_action_grant_permission');
    }
    return $r('app.string.bt_action_open_settings');
  }
}
