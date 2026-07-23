import { ComponentContent, LengthMetrics } from '@kit.ArkUI';
import { MenuToken } from 'common_ui';

export const SPP_TITLE_MORE_MENU_ID: string = 'spp_title_more_menu';

/**
 * System Menu for HdsNavigation more icon (PromptAction.openMenu).
 *
 * Width: intentionally unset. ArkUI Menu docs — forced width makes every
 * MenuItem that width; 224vp was too wide for a single short settings label.
 * Unset → ~2-grid default, content may grow; constraintSize caps compact menus.
 */
@Builder
export function buildSppTitleMoreMenu() {
  Menu() {
    MenuItem({ content: $r('app.string.bt_action_open_settings') })
  }
  .radius(MenuToken.RADIUS)
  .constraintSize({
    minWidth: MenuToken.MIN_WIDTH,
    maxWidth: MenuToken.COMPACT_MAX_WIDTH
  })
  .menuItemDivider({
    strokeWidth: LengthMetrics.vp(1),
    color: $r('sys.color.comp_divider')
  })
}

/**
 * Opens the title-bar more dropdown anchored to HdsNavigation componentId.
 * Official path: HdsNavigationIconOptions.componentId + promptAction.openMenu.
 */
export function openSppTitleMoreMenu(uiContext: UIContext, targetComponentId: string): void {
  const contentNode: ComponentContent<Object> =
    new ComponentContent(uiContext, wrapBuilder(buildSppTitleMoreMenu));
  try {
    void uiContext.getPromptAction().openMenu(
      contentNode,
      { id: targetComponentId },
      { placement: Placement.Bottom }
    );
  } catch (_error) {
    // Anchor missing or API rejected — ignore for stub menu.
  }
}
