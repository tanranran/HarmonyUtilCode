/**
 * JSON相关工具类
 * @author Tanranran
 * @date 2024/5/15 22:20
 * @description
 */
import { plainToInstance, ClassConstructor, instanceToPlain, Transform } from "class-transformer";
import { CommonAllType } from './const/CommonConst'
import { ObjectUtils } from './ObjectUtils'
import { StringUtils } from './StringUtils'
import { JSON } from '@kit.ArkTS'

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
      return plainToInstance(cls, JSON.parse(jsonStr!), {
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
      } else if (data instanceof Map) {
        let jsonObject: Record<string, Object> = {};
        data.forEach((val: string, key: Object) => {
          if (key !== undefined && val !== undefined) {
            jsonObject[key as string] = JsonUtils.bean2Json(val);
          }
        });
        return JSON.stringify(jsonObject);
      } else if (Array.isArray(data)) {
        return JSON.stringify(instanceToPlain(data))
      } else if (ObjectUtils.isString(data)) {
        return StringUtils.toString(data, '')
      } else if (typeof data === 'number') {
        return new String(data).toString();
      } else if (typeof data === 'boolean') {
        return new String(data).toString();
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

  /**
   * JSON 字符串转JSON Object
   * @param text
   * @returns
   */
  static parse(text: string): Object | null {
    try {
      return JSON.parse(text)
    } catch (e) {
      console.log(`${JsonUtils}_parse`, e)
    }
    return null
  }

  /**
   * Object 转json string
   * @param value
   * @returns
   */
  static stringify(value?: Object): string {
    try {
      if (value == undefined) {
        return ''
      }
      if (value instanceof Map) {
        value = Object.fromEntries(value)
      }
      return JSON.stringify(value)
    } catch (e) {
      console.log(`JSONUtils_parse`, e)
    }
    return ''
  }

  /**
   * JSON字符串转Array<Class>对象
   * @param cls 类名
   * @param jsonStr json 字符串
   * @returns class对象
   */
  static json2Array<T>(cls: ClassConstructor<T>, jsonStr: string | null | undefined): Array<T> | null {
    try {
      return (JSON.parse(jsonStr) as ESObject).map(value => JsonUtils.json2Bean<T>(cls,JsonUtils.stringify(value)))
    } catch (e) {
      return null
    }
  }


  /**
   * 检查ArkTS对象是否包含某种属性，可用于JSON.parse解析JSON字符串之后的相关操作。
   * @param value
   * @returns
   */
  static has(obj: object, property: string): boolean {
    try {
      return JSON.has(obj, property)
    } catch (e) {
      console.log(`${JsonUtils.name}_parse`, e)
    }
    return false
  }

  /**
   * 获取JsonObject 中指定属性的值
   * @param obj
   * @param key
   * @param defaultValue
   * @returns
   */
  static getValue<T>(obj: object | undefined | null, key: string, defaultValue: T): T {
    try {
      if (obj == undefined || obj == null) {
        return defaultValue
      }
      const value = obj[key];
      if (value === undefined || value === null) {
        return defaultValue;
      }
      return value;
    } catch (e) {
      console.error(`${JsonUtils.name}_getValue`, e)
    }
  }
}
