import { common } from '@kit.AbilityKit';
import { window } from '@kit.ArkUI'
import {AppUtils} from './AppUtils';

/**
 * @author Tanranran
 * @date 2024/5/15 22:25
 * @description
 */
export class Utils {
  private constructor() {
  }

  private static instance: Utils;
  //每个UIAbility中都包含了一个Context属性，提供操作应用组件、获取应用组件的配置信息等能力。
  private static sAbilityContext: common.UIAbilityContext;
  private static sUiContext?: UIContext | null
  private static mainWindow?: window.Window | null

  public static getInstance(): Utils {
    if (!Utils.instance) {
      Utils.instance = new Utils();
    }
    return Utils.instance;
  }

  /**
   * 初始化工具类，
   * 1、涉及到需要context的位置都可以用Utils来获取
   * 2、涉及到需要初始化的工具类，可以放到此处初始化
   * @param entryContext
   */
  public static init(entryContext: common.UIAbilityContext) {
    Utils.sAbilityContext = entryContext
  }


  /**
   * 设置主窗口window
   * @returns
   */
  public static setMainWindow(mainWindow?: window.Window) {
    try {
      Utils.mainWindow = mainWindow
      if (mainWindow) {
        Utils.sUiContext = mainWindow.getUIContext()
      }
    } catch (e) {
      console.error(e)
    }
  }


  /**
   * 获取应用级别的Context
   * @returns
   */
  public static getApplicationContext() {
    return Utils.getAbilityContext().getApplicationContext()
  }

  /**
   * 获取UIAbility级别的Context
   * @returns
   */
  public static getAbilityContext() {
    return Utils.sAbilityContext  ?? getContext() as common.UIAbilityContext;
  }

  /**
   * 获取MainWindow
   * @returns
   */
  public static getMainWindow() {
    return Utils.mainWindow
  }

  /**
   * 获取MainWindow 对应的uiContext
   * @returns
   */
  public static getUIContext() {
    return Utils.sUiContext
  }
}
