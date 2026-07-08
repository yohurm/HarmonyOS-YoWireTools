import { YoActionButton, YoActionButtonKind } from './YoActionButton';

/**
 * @deprecated Use {@link YoActionButton} with {@link YoActionButtonKind.SECONDARY} instead.
 * Thin wrapper retained for migration; prefer ResourceStr labels via YoActionButton.
 */
@ComponentV2
export struct YoSecondaryButton {
  /** @deprecated Prefer YoActionButton.label (ResourceStr). */
  @Param label: ResourceStr = '';
  @Param isEnabled: boolean = true;
  @Event onTap: () => void = () => {
  };

  build() {
    YoActionButton({
      label: this.label,
      kind: YoActionButtonKind.SECONDARY,
      isEnabled: this.isEnabled,
      onTap: (): void => {
        this.onTap();
      }
    })
  }
}
