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
}
