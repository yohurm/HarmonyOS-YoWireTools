/**
 * YoPageShell / HdsNavigation 标题栏图标菜单项。
 * 亦可被 {@link YoTitleBarActionRow} 消费（Dialog 等同构表面）。
 */
export class YoTitleBarMenuItem {
  readonly key: string;
  readonly icon: Resource;
  readonly label: ResourceStr;
  readonly enabled: boolean;
  readonly componentId: string;
  readonly action: () => void;
  /** 可选覆盖色；未设时 ActionRow 用 sys.color.icon_primary，HdsNavigation 走 menuStyle。 */
  readonly iconColor: ResourceColor | undefined;

  constructor(
    key: string,
    icon: Resource,
    label: ResourceStr,
    action: () => void = () => {
    },
    enabled: boolean = true,
    componentId: string = '',
    iconColor?: ResourceColor
  ) {
    this.key = key;
    this.icon = icon;
    this.label = label;
    this.action = action;
    this.enabled = enabled;
    this.componentId = componentId;
    this.iconColor = iconColor;
  }
}
