/**
 * JSON相关工具类
 * @author Tanranran
 * @date 2024/5/15 22:20
 * @description
 */
import { ClassConstructor, instanceToPlain, plainToClass } from 'class-transformer'
import { CommonAllType } from './const/CommonConst'
import { ObjectUtils } from './ObjectUtils'
import { StringUtils } from './StringUtils'

export class JsonUtils {
  /**
   * JSON字符串转Class对象
   * @param cls 类名
   * @param jsonStr json 字符串
   * @returns class对象
   */
  static json2Bean<T>(cls: ClassConstructor<T>, jsonStr: string | null | undefined): T | null {
    try {
      if (StringUtils.isEmpty(jsonStr)) {
        return null
      }
      return plainToClass(cls, JSON.parse(jsonStr!), {
        enableImplicitConversion: false, exposeDefaultValues: true
      }) as T
    } catch (e) {
      return null
    }
  }


  /**
   * 对象转字符串
   * @param data
   * @returns 字符串
   */
  static bean2Json(data: CommonAllType): string {
    try {
      if (ObjectUtils.isNull(data)) {
        return ""
      } else if (Array.isArray(data) && data.length == 0) {
        return "[]"
      }
      return JSON.stringify(instanceToPlain(data))
    } catch (e) {
      return ""
    }
  }

  /**
   * JSON转Map
   * @param jsonStr
   * @returns
   */
  static json2Map(jsonStr: string): Map<string, Object> {
    return new Map(Object.entries(JSON.parse(jsonStr)));
  }
}
