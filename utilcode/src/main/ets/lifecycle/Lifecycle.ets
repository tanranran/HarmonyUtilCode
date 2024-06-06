import { ArrayList } from '@kit.ArkTS';

/**
 * 生命周期包装类
 * @author Tanranran
 * @date 2024/6/5 23:45
 * @description
 */

export enum LifecycleState {
  ToAppear,
  PageShow,
  PageHide,
  ToDisappear,
}

export class Lifecycle {
  private mObserverList: ArrayList<(state: LifecycleState) => void> | null = new ArrayList();

  /**
   * @Component
   * 组件即将出现时回调该接口，具体时机为在创建自定义组件的新实例后，在执行其build()函数之前执行。
   */
  aboutToAppear() {
    this.dispatchEvent(LifecycleState.ToAppear)
  }

  /**
   * @Entry
   * 页面每次显示时触发一次，包括路由过程、应用进入前台等场景。
   */
  onPageShow() {
    this.dispatchEvent(LifecycleState.PageShow)
  }

  /**
   * @Entry
   * 页面每次隐藏时触发一次，包括路由过程、应用进入后台等场景。
   */
  onPageHide() {
    this.dispatchEvent(LifecycleState.PageHide)
  }

  /**
   * @Component
   * aboutToDisappear函数在自定义组件析构销毁之前执行
   */
  aboutToDisappear() {
    this.dispatchEvent(LifecycleState.ToDisappear)
  }

  /**
   * 向所有观察者分发状态
   * @param state
   */
  private dispatchEvent(state: LifecycleState) {
    this.mObserverList?.forEach((callback: (state: LifecycleState) => void) => {
      callback(state)
    });
  }

  /**
   * 添加观察者
   * @param callback
   */
  addObserver(callback: (state: LifecycleState) => void) {
    this.mObserverList?.add(callback)
  }

  /**
   * 移除观察者
   * @param callback
   */
  removeObserver(callback: (state: LifecycleState) => void) {
    this.mObserverList?.remove(callback)
  }

  /**
   * 释放所有观察者
   */
  release() {
    this.mObserverList?.clear()
    this.mObserverList = null
  }
}
