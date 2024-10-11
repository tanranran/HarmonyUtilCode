/**
 * @author Tanranran
 * @date 2024/5/13 22:58
 * @description
 */
import { CommonAllType } from './const/CommonConst'
import { ArrayList, List, HashMap } from '@kit.ArkTS';
import { instanceToInstance } from 'class-transformer';

export class ObjectUtils {
  /**
   * 判断属性是否是string类型类型
   * @param property
   * @returns
   */
  static isString(property: string | Object | ArrayBuffer | undefined | null): Boolean {
    return typeof property === 'string' || property instanceof String
  }

  /**
   * 判断属性是否为空
   * @param property
   * @returns
   */
  static isNull(property: CommonAllType): Boolean {
    return property === null || property === undefined
  }

  /**
   * 判断属性内容是否为空
   * @param property
   * @returns
   */
  static isEmpty(property:CommonAllType): Boolean {
    if (ObjectUtils.isNull(property)) {
      return true
    } else if (Array.isArray(property) || property instanceof Array) {
      return property.length == 0
    } else if (property instanceof List) {
      return property.isEmpty()
    } else if (property instanceof ArrayList) {
      return property.isEmpty()
    } else if (property instanceof HashMap) {
      return property.isEmpty()
    }
    return property == '';
  }

  /**
   * 判断两个传入的数值或者是字符串是否相等
   * @param source
   * @param target
   * @returns
   */
  static equal(source: string | number, target: string | number): boolean {
    return source === target;
  }

  /**
   * 判断两个传入的数值或者是字符串是否不相等
   * @param source
   * @param target
   * @returns
   */
  static notEqual(source: string | number, target: string | number): boolean {
    return false == ObjectUtils.equal(source, target);
  }

  /**
   * 深拷贝对象
   * @param obj
   * @returns
   */
  static deepCopy<T>(obj: object): T {
    return instanceToInstance(obj) as T
  }

  /**
   * 设置Object 中指定属性的值
   * @param obj
   * @param key
   * @param defaultValue
   * @returns
   */
  static setValue(obj: object, key: string, value: CommonAllType) {
    try {
      if (obj) {
        obj[key] = value;
      }
    } catch (e) {
      console.error(`${ObjectUtils.name}_setValue`, e)
    }
  }

  /**
   * 获取Object 中指定属性的值
   * @param obj
   * @param key
   * @param defaultValue
   * @returns
   */
  static getValue<T>(obj: object | undefined | null, key: string, defaultValue: T): T {
    try {
      const value = obj[key];
      if (value === undefined || value === null) {
        return defaultValue;
      }
      return value;
    } catch (e) {
      console.error(`${ObjectUtils.name}_getValue`, e)
    }
  }

  /**
   * obj转class ，解决obj as class 后丢失方法的问题
   * 例子：ObjectUtils.objToClass<SendCommentParam>(SendCommentParam,new Object())
   * @param clazz
   * @param obj
   * @returns
   */
  static objToClass<T>(clazz: new (...args: any[]) => T, obj: any): T {
    const instance = new clazz();
    Object.assign(instance, obj);
    return instance;
  }

  static values<T>(o: { [s: string]: T } | ArrayLike<T>): T[] {
    return Object.values(o)
  }
}
