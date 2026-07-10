import { deviceInfo } from '@kit.BasicServicesKit';
import { CardToken } from '../token/component/CardToken';
import { HdsMaterialPolicy, UI_MATERIAL_MIN_SDK_API } from '../theme/HdsMaterialPolicy';

/**
 * Official multi-version immersive surface (WSL 沉浸光感 best-practice):
 *
 * | Runtime API | Compile SDK 6.1(23) today | After compile SDK 26+ |
 * |-------------|----------------------------|------------------------|
 * | < 26        | backgroundBlurStyle        | backgroundBlurStyle    |
 * | >= 26       | backgroundBlurStyle (*)    | uiMaterial.systemMaterial |
 *
 * (*) WSL MaterialUtil legacy fallback until DevEco compile SDK exposes uiMaterial.
 * compatibleSdkVersion stays 6.1.0(23); only the compile SDK needs upgrading for (*).
 */
@ComponentV2
export struct YoImmersiveSurface {
  @Param cornerRadius: number = CardToken.RADIUS;
  @Param innerPadding: number = CardToken.PADDING;
  @BuilderParam content: () => void = this.defaultContent;

  @Builder
  defaultContent() {
  }

  build() {
    if (deviceInfo.sdkApiVersion >= UI_MATERIAL_MIN_SDK_API) {
      if (HdsMaterialPolicy.supportsImmersiveMaterial()) {
        this.modernImmersiveSurface()
      } else {
        this.legacyBlurSurface()
      }
    } else {
      this.legacyBlurSurface()
    }
  }

  /** WSL MaterialUtil official legacy path: BlurStyle.COMPONENT_REGULAR. */
  @Builder
  private legacyBlurSurface() {
    Column() {
      this.content()
    }
    .width('100%')
    .padding(this.innerPadding)
    .borderRadius(this.cornerRadius)
    .backgroundColor(Color.Transparent)
    .backgroundBlurStyle(BlurStyle.COMPONENT_REGULAR)
  }

  /**
   * API 26+ path. With compile SDK 6.1(23), falls back to legacyBlurSurface.
   * Replace body with uiMaterial.ImmersiveMaterial + systemMaterial when compile SDK >= 26.
   */
  @Builder
  private modernImmersiveSurface() {
    this.legacyBlurSurface()
  }
}
