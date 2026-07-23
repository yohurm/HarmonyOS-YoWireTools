import { YoSpace } from '../foundation/YoSpace';

/**
 * 特性列表表面的列表 / 滚动条装饰 Token。
 */
export class YoListToken {
  /** 列表项之间的垂直间距（高密度设备列表）。 */
  static readonly ITEM_GAP: number = YoSpace.XXS;
  /** 每项垂直外边距，避免卡片阴影被裁切，同时不拉大视觉间距。 */
  static readonly ITEM_SHADOW_BLEED: number = YoSpace.XXS;
  /**
   * 滚动条轨道宽度（vp）。
   * 较原先 6vp 略细，适配更紧凑的设备列表。
   */
  static readonly SCROLLBAR_WIDTH: number = 4;
}
