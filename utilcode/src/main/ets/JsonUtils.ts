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

      let obj = JSON.parse(jsonStr)


      if (obj instanceof Array) {

        let doubled = obj.map(function(item) {
          try {
            let itemJson=JsonUtils.stringify(item)
            let data =JsonUtils.json2Bean<T>(cls,itemJson)

            console.log('每一行的数据A'+data);
            console.log('每一行的数据B'+JSON.stringify(data));
          } catch (e) {
            console.error(e)
          }


          return item * 2;
        });

        console.log('转换后的数据'+JSON.stringify(doubled));

        return obj.map(value => plainToInstance(cls, value, {
          enableCircularCheck: true,
          enableImplicitConversion: true,
          exposeDefaultValues: true
        }))
      }
      return null
    } catch (e) {
      return null
    }
  }
}
