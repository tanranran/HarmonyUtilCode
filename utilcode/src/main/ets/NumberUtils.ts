/**
 * @author Tanranran
 * @date 2024/5/15 22:22
 * @description
 */
export class NumberUtils {
  /**
   * 判断是否是数值
   * @param value 需要判断的参数
   * @returns
   * @version Egret 2.4
   * @platform Web,Native
   * @language zh_CN
   */
  public static isNumber(value: any): boolean {
    return typeof (value) === "number" && !isNaN(value);
  }


  public static toInt(value: any, defaultValue: number = 0): number {
    try {
      const parsedValue = parseInt(value);
      if (isNaN(parsedValue)) {
        return defaultValue;
      }
      return parsedValue;
    } catch (e) {
      return defaultValue
    }
  }
}
