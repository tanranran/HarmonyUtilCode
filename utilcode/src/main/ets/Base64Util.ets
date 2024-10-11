/**
 * Base64Util  base64工具类
 * @author Tanranran
 * @date 2024/6/27 20:00
 * @description
 */
import { util } from '@kit.ArkTS';

export class Base64Util {

  /**
   * 将Uint8Array转化为字符串-异步
   * @param array Uint8Array数组
   * @returns 转码后的字符串
   */
  static encodeToStr(array: Uint8Array, options?: util.Type): Promise<string> {
    let base64 = new util.Base64Helper();
    return base64.encodeToString(array, options);
  }

  /**
   * 将字符串转换为Uint8Array数组-异步
   * @param array 待转换的字符串
   * @returns 转码后的Uint8Array数组
   */
  static decode(str: string, options?: util.Type): Promise<Uint8Array> {
    let base64 = new util.Base64Helper();
    return base64.decode(str, options);
  }

  /**
   * 将Uint8Array转化为字符串-同步
   * @param array Uint8Array数组
   * @returns 转码后的字符串
   */
  static encodeToStrSync(array: Uint8Array, options?: util.Type): string {
    let base64 = new util.Base64Helper();
    let result = base64.encodeToStringSync(array, options);
    return result;
  }
  /**
   * @param str 字符串
   * @returns 转码后的字符串
   */
  static encodeStrToStrSync(str: string, options?: util.Type): string {
    let array = new Uint8Array(str.length);
    for (let i = 0, j = str.length; i < j; i++) {
      array[i] = str.charCodeAt(i);
    }
    let base64 = new util.Base64Helper();
    let result = base64.encodeToStringSync(array, options);
    return result;
  }
  /**
   * 将字符串转换为Uint8Array数组-同步
   * @param string  待转换的字符串
   * @returns 转码后的Uint8Array数组
   */
  static decodeSync(str: string, options?: util.Type): Uint8Array {
    let base64 = new util.Base64Helper();
    let result = base64.decodeSync(str, options);
    return result;
  }
}
