/**
 * Title-bar icon menu item for YoPageShell / HdsNavigation.
 */
export class YoTitleBarMenuItem {
  readonly key: string;
  readonly icon: Resource;
  readonly label: ResourceStr;
  readonly enabled: boolean;
  readonly componentId: string;
  readonly action: () => void;

  constructor(
    key: string,
    icon: Resource,
    label: ResourceStr,
    action: () => void = () => {
    },
    enabled: boolean = true,
    componentId: string = ''
  ) {
    this.key = key;
    this.icon = icon;
    this.label = label;
    this.action = action;
    this.enabled = enabled;
    this.componentId = componentId;
  }
}
