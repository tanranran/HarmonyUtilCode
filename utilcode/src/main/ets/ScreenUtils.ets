/**
 * @author Tanranran
 * @date 2024/5/15 22:23
 * @description
 */
import { display, window } from '@kit.ArkUI';
import { LogUtils } from './LogUtils';
import { Utils } from './Utils';

export class ScreenUtils {

  /**
   *  获取当前默认的屏幕对象【有些设备有多个屏幕】
   * @returns
   */
  static getDefaultDisplay() {
    return display.getDefaultDisplaySync()
  }

  /**
   * 获取当前主窗口的窗口属性
   * @returns
   */
  static getWindowProperties(): window.WindowProperties | null {
    return Utils.getMainWindow()?.getWindowProperties() ?? null
  }

  /**
   * 获取当前App窗口的宽度
   * @returns
   */
  static getAppScreenWidth(): number {
    try {
      return ScreenUtils.getWindowProperties()?.windowRect.width ?? 0
    } catch (e) {
      LogUtils.error(`${ScreenUtils.name}_getAppScreenWidth`, e)
      return 0
    }
  }

  /**
   * 显示设备的屏幕宽度，单位为px，该参数应为整数。
   * @returns
   */
  static getScreenWidth(): number {
    try {
      return ScreenUtils.getDefaultDisplay().width
    } catch (e) {
      LogUtils.error(`${ScreenUtils.name}_getScreenWidth`, e)
      return 0
    }
  }

  /**
   * 显示设备的屏幕高度，单位为px，该参数应为整数。
   * @returns
   */
  static getScreenHeight(): number {
    try {
      return ScreenUtils.getDefaultDisplay().height
    } catch (e) {
      LogUtils.error(`${ScreenUtils.name}_getScreenHeight`, e)
      return 0
    }
  }

  /**
   * 获取当前App窗口的高度
   * @returns
   */
  static getAppScreenHeight(): number {
    try {
      return ScreenUtils.getWindowProperties()?.windowRect.height ?? 0
    } catch (e) {
      LogUtils.error(`${ScreenUtils.name}_getAppScreenHeight`, e)
      return 0
    }
  }

  static getDpi(){
    let displayObject = display.getDefaultDisplaySync();
    let screenDensityDPI = displayObject.densityDPI
    return screenDensityDPI
  }
}
