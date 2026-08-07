import { ComponentContent, LengthMetrics } from '@kit.ArkUI';
import { YoMenuToken } from 'youi_kit';

export const SPP_TERMINAL_MORE_MENU_ID: string = 'spp_terminal_more_menu';

export class SppTerminalMoreMenuParams {
  onClear: () => void = () => {
  };
  onDisconnect: () => void = () => {
  };
  disconnectEnabled: boolean = true;
}

@Builder
export function buildSppTerminalMoreMenu(params: SppTerminalMoreMenuParams) {
  Menu() {
    MenuItem({ content: $r('app.string.bt_spp_terminal_clear') })
      .onClick(() => {
        params.onClear();
      })
    MenuItem({ content: $r('app.string.bt_spp_action_disconnect') })
      .enabled(params.disconnectEnabled)
      .onClick(() => {
        params.onDisconnect();
      })
  }
  .radius(YoMenuToken.RADIUS)
  .constraintSize({
    minWidth: YoMenuToken.MIN_WIDTH,
    maxWidth: YoMenuToken.COMPACT_MAX_WIDTH
  })
  .menuItemDivider({
    strokeWidth: LengthMetrics.vp(1),
    color: $r('sys.color.comp_divider')
  })
}

export function openSppTerminalMoreMenu(
  uiContext: UIContext,
  targetComponentId: string,
  onClear: () => void,
  onDisconnect: () => void,
  disconnectEnabled: boolean = true
): void {
  const params = new SppTerminalMoreMenuParams();
  params.onClear = onClear;
  params.onDisconnect = onDisconnect;
  params.disconnectEnabled = disconnectEnabled;
  const contentNode: ComponentContent<SppTerminalMoreMenuParams> =
    new ComponentContent(uiContext, wrapBuilder(buildSppTerminalMoreMenu), params);
  try {
    void uiContext.getPromptAction().openMenu(
      contentNode,
      { id: targetComponentId },
      { placement: Placement.Bottom }
    );
  } catch (_error) {
  }
}
