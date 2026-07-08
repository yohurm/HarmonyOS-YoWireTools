import { YoActionButton, YoActionButtonKind } from './YoActionButton';

/**
 * @deprecated Use {@link YoActionButton} with {@link YoActionButtonKind.PRIMARY} instead.
 * Thin wrapper retained for migration; prefer ResourceStr labels via YoActionButton.
 */
@ComponentV2
export struct YoPrimaryButton {
  /** @deprecated Prefer YoActionButton.label (ResourceStr). */
  @Param label: ResourceStr = '';
  @Param isEnabled: boolean = true;
  @Param loading: boolean = false;
  @Event onTap: () => void = () => {
  };

  build() {
    YoActionButton({
      label: this.label,
      kind: YoActionButtonKind.PRIMARY,
      isEnabled: this.isEnabled,
      loading: this.loading,
      onTap: (): void => {
        this.onTap();
      }
    })
  }
}
