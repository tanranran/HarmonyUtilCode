/**
 * @author Tanranran
 * @date 2024/5/15 22:24
 * @description
 */
import { promptAction } from '@kit.ArkUI';
import { Utils } from './Utils';

export class ToastUtils {
  private static readonly LENGTH_SHORT = 2000;
  private static readonly LENGTH_LONG = 3500;

  static show(message: string | Resource) {
    ToastUtils.finalShow(message, ToastUtils.LENGTH_SHORT)
  }

  static showLong(message: string | Resource) {
    ToastUtils.finalShow(message, ToastUtils.LENGTH_LONG)
  }

  private static finalShow(message: string | Resource, duration: number) {
    let toastOptions: promptAction.ShowToastOptions = {
      message: message, //显示的文本信息。
      duration: duration, //默认值1500ms，取值区间：1500ms-10000ms。若小于1500ms则取默认值，若大于10000ms则取上限值10000ms。
      alignment: Alignment.Center,
      //bottom: "80vp", //设置弹窗边框距离屏幕底部的位置。
      showMode: promptAction.ToastShowMode.DEFAULT//设置弹窗是否显示在应用之上。DEFAULT:应用内，TOP_MOST应用之上
    }
    let mPromptAction = Utils.getUIContext()?.getPromptAction()
    if (mPromptAction) {
      mPromptAction.showToast(toastOptions)
    } else {
      promptAction.showToast(toastOptions)
    }
  }
}
