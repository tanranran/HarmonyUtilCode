/**
 * @author Tanranran
 * @date 2024/5/13 17:57
 * @description
 */
import { CharUtils } from './CharUtils';
import { CommonAllType } from './const/CommonConst'
import { ObjectUtils } from './ObjectUtils'

export class StringUtils {
  /**
   *判断字符串是否为空白符(空白符包括空格、制表符、全角空格和不间断空格)true为空，否则false
   * @param str
   * @returns
   */
  static isBlank(str?: string | String | null | undefined): Boolean {
    let length: number;
    if ((str == null) || ((length = str.length) == 0)) {
      return true;
    }
    for (let i = 0; i < length; i++) {
      // 只要有一个非空字符即为非空字符串
      if (false == CharUtils.isBlankChar(str.charCodeAt(i))) {
        return false;
      }
    }

    return true;
  }

  /**
   *判断字符串是否为非空白符(空白符包括空格、制表符、全角空格和不间断空格)true为非空，否则false
   * @param str
   * @returns
   */
  static isNotBlank(str: string | String | null | undefined): Boolean {
    return false == StringUtils.isBlank(str);
  }

  /**
   * 判断字符串是否为空
   * @param str 被检测的字符串
   * @return 是否为空
   */
  static isEmpty(property?: CommonAllType,isCheckUndefinedStr?:boolean): Boolean {
    if (ObjectUtils.isNull(property) || property == '') {
      return true
    }
    if (isCheckUndefinedStr&&property=='undefined') {
      return true
    }
    return ObjectUtils.isEmpty(property)
  }

  /**
   * 字符串转string，主要用于保证空安全
   * @param any
   * @param defaultValue
   * @returns
   */
  static toString(any: any | null | undefined, defaultValue: string = ""): string {
    if (any == null || any == undefined) {
      return defaultValue
    }
    return String(any);
  }

  /**
   * 字符串全部替换为指定字符串
   * @param source 要替换的字符串
   * @param s1 被替换文本
   * @param s2 替换文本
   * @returns
   */
  static replaceAll(source: string, s1, s2) {
    return source.replace(new RegExp(s1, "gm"), s2);
  }
}
