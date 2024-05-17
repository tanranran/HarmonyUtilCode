/**
 * 资源文件工具类
 * @author Tanranran
 * @date 2024/5/15 22:23
 * @description
 */
import { Utils } from './Utils'

export class ResourceUtils {
  /**
   * 资源名称对应的数值。Integer[app.integer.integer_test]对应的是原数值，float不带单位对应的是原数值[$r('app.float.float_test')]；带"vp","fp"单位时对应的是px值。
   * @param resource
   * @returns 返回单位vp
   */
  static getNumber(resource: Resource): number {
    try {
      return Utils.getAbilityContext().resourceManager.getNumber(resource)
    } catch (e) {
      console.error(e)
      return 0
    }
  }
}
