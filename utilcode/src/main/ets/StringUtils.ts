/**
 * @author Tanranran
 * @date 2024/5/13 17:57
 * @description
 */
import { CommonAllType } from './const/CommonConst'
import { ObjectUtils } from './ObjectUtils'

export class StringUtils {

  /**
   *  字符串是否为空
   * @param str 被检测的字符串
   * @return 是否为空
   */
  static isEmpty(property?: CommonAllType): Boolean {
    if (ObjectUtils.isNull(property) || property == '') {
      return true
    }
    return ObjectUtils.isEmpty(property)
  }

  static toString(any: any | null | undefined, defaultValue: string = ""): string {
    if (any == null || any == undefined) {
      return defaultValue
    }
    return String(any);
  }
}
