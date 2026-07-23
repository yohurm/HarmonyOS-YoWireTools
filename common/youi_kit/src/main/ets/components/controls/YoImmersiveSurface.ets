import { deviceInfo } from '@kit.BasicServicesKit';
import { YoCardToken } from '../../token/component/YoCardToken';
import { HdsMaterialPolicy, UI_MATERIAL_MIN_SDK_API } from '../../theme/HdsMaterialPolicy';

/**
 * 官方多版本沉浸表面（WSL 沉浸光感最佳实践）：
 *
 * | 运行时 API | 当前编译 SDK 6.1(23) | 编译 SDK 26+ 之后 |
 * |-------------|----------------------------|------------------------|
 * | < 26        | backgroundBlurStyle        | backgroundBlurStyle    |
 * | >= 26       | backgroundBlurStyle (*)    | uiMaterial.systemMaterial |
 *
 * (*) DevEco 编译 SDK 暴露 uiMaterial 前，WSL MaterialUtil 旧版回退。
 * compatibleSdkVersion 保持 6.1.0(23)；仅编译 SDK 需升级以启用 (*)。
 */
@ComponentV2
export struct YoImmersiveSurface {
  @Param cornerRadius: number = YoCardToken.RADIUS;
  @Param innerPadding: number = YoCardToken.PADDING;
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

  /** WSL MaterialUtil 官方旧路径：BlurStyle.COMPONENT_REGULAR。 */
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
   * API 26+ 路径。编译 SDK 6.1(23) 时回退 legacyBlurSurface。
   * 编译 SDK >= 26 后将实现体替换为 uiMaterial.ImmersiveMaterial + systemMaterial。
   */
  @Builder
  private modernImmersiveSurface() {
    this.legacyBlurSurface()
  }
}
