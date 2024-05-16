/**
 * @author Tanranran
 * @date 2024/5/15 22:18
 * @description
 */
import { display } from '@kit.ArkUI';

export class ConvertUtils {
  /**
   * 遇到px2vp不生效时，自己计算
   * @author 鸿洋
   */
  px2vp(val: number) {
    let vpVal = px2vp(val)
    if (vpVal == val) {
      let displayObject = display.getDefaultDisplaySync();
      let screenDensityDPI = displayObject.densityDPI
      return val * (160 / screenDensityDPI)
    }
    return vpVal
  }

  /**
   * 遇到vp2px不生效时，自己计算
   * @author 鸿洋
   */
  vp2px(val: number) {
    let vpVal = vp2px(val)
    if (vpVal == val) {
      let displayObject = display.getDefaultDisplaySync();
      let screenDensityDPI = displayObject.densityDPI
      return val * (screenDensityDPI / 160)
    }
    return vpVal
  }
}
