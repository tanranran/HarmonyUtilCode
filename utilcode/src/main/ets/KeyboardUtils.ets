/**
 * @author Tanranran
 * @date 2024/6/10 17:26
 * @description
 */

import { ArrayList } from '@kit.ArkTS';
import { Lifecycle, LifecycleState } from './lifecycle/Lifecycle';
import { inputMethod, inputMethodEngine } from '@kit.IMEKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { KeyboardAvoidMode } from '@kit.ArkUI';
import { Utils } from './Utils';
import { LogUtils } from './LogUtils';

export  class KeyBoardUtils {

  private static mObserverList: ArrayList<(height: number) => void> | null = new ArrayList();
  private static onKeyboardHeightChange = (height: number) => {
    KeyBoardUtils.dispatchEvent(px2vp(height))
  }

  static init() {
    //设置键盘的避让模式
    Utils.getUIContext()?.setKeyboardAvoidMode(KeyboardAvoidMode.OFFSET);
    Utils.getMainWindow()?.on('keyboardHeightChange', KeyBoardUtils.onKeyboardHeightChange)
  }

  /**
   * 关闭键盘，但是不取消控件焦点
   */
  static hideKeyBoard() {
    inputMethod.getController().hideTextInput()
  }

  /**
   * 显示键盘，配合hideKeyBoard 使用
   */
  static showKeyBoard() {
    inputMethod.getController().showTextInput()
  }

  /**
   * 向所有观察者分发状态
   * @param state
   */
  private static dispatchEvent(height: number) {
    LogUtils.logWrite(`${KeyBoardUtils.name}_dispatchEvent`, '键盘高度' + height)
    KeyBoardUtils.mObserverList?.forEach((callback: (height: number) => void) => {
      callback(height)
    });
  }

  /**
   * 添加观察者
   * @param callback
   */
  static addObserver(callback: (height: number) => void, lifecycle?: Lifecycle) {
    KeyBoardUtils.mObserverList?.add(callback)
    lifecycle?.addObserver((state: LifecycleState) => {
      if (state == LifecycleState.ToDisappear) {
        KeyBoardUtils.removeObserver(callback)
      }
    })
  }

  /**
   * 移除观察者
   * @param callback
   */
  static removeObserver(callback: (height: number) => void) {
    KeyBoardUtils.mObserverList?.remove(callback)
  }

  /**
   * 订阅文本内容变化
   * @param callback 回调函数，返回订阅的文本内容。
   */
  static onInputTextChanged(callback: (text: string) => void) {
    try {
      inputMethodEngine.getKeyboardDelegate().on('textChange', callback);
    } catch (err) {
      let error = err as BusinessError;
      console.error(`KeyboardUtil-onInputTextChanged-异常 ~ code: ${error.code} -·- message: ${error.message}`);
    }
  }


  /**
   * 取消订阅文本内容变化
   */
  static removeInputTextChanged() {
    try {
      inputMethodEngine.getKeyboardDelegate().off('textChange');
    } catch (err) {
      let error = err as BusinessError;
      console.error(`KeyboardUtil-removeInputTextChanged-异常 ~ code: ${error.code} -·- message: ${error.message}`);
    }
  }
}
