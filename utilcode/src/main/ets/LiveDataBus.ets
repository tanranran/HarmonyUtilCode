/**
 * 基于emitter封装的事件消息总线
 * @author Tanranran
 * @date 2024/7/9 14:57
 * @description
 */
import { HashMap } from '@kit.ArkTS'
import { Callback, emitter } from '@kit.BasicServicesKit'
import { Lifecycle, LifecycleState } from './lifecycle/Lifecycle'
import { LogUtils } from './LogUtils'

export class LiveDataBus {
  private dispatch: Dispatch = new Dispatch()

  private static getInstance() {
    const storageKey = 'HUC_EVENT_BUS'
    let liveDataBus: LiveDataBus
    if (!AppStorage.has(storageKey)) {
      AppStorage.setOrCreate(storageKey, new LiveDataBus())
    }
    liveDataBus = AppStorage.get<LiveDataBus>(storageKey)!
    return liveDataBus
  }

  public static observe<T extends Object>(eventName: string, callback: Callback<T>, lifecycle?: Lifecycle) {
    LiveDataBus.getInstance().dispatch.observe(eventName, callback)
    lifecycle?.addObserver((state: LifecycleState) => {
      if (state == LifecycleState.ToDisappear) {
        LiveDataBus.getInstance().dispatch.removeObserve(eventName, callback)
      }
    })
    return callback
  }

  public static removeObserve<T extends Object>(eventName: string, callback?: Callback<T>) {
    if(!callback){
      return
    }
    LiveDataBus.getInstance().dispatch.removeObserve(eventName, callback)
  }

  public static post<T extends Object>(eventName: string, value: T) {
    LiveDataBus.getInstance().dispatch.post(eventName, value)
  }
}

class Dispatch {
  private callbackMap = new HashMap<string, HashMap<Callback<Object>, Callback<emitter.EventData>>>()

  observe<T extends Object>(eventName: string, callback: Callback<T>) {
    if (!this.callbackMap.hasKey(eventName)) {
      this.callbackMap.set(eventName, new HashMap())
    }
    let realCallback: Callback<emitter.EventData> = (eventData) => {
      callback(eventData.data as T)
    }
    this.callbackMap.get(eventName).set(callback as Callback<Object>, realCallback)
    emitter.on(eventName, realCallback);
  }

  removeObserve<T extends Object>(eventName: string, callback: Callback<T>) {
    let realCallback: Callback<emitter.EventData> | null = null
    if (this.callbackMap.hasKey(eventName)) {
      realCallback = this.callbackMap.get(eventName).get(callback as Callback<Object>)
    }
    if (realCallback) {
      emitter.off(eventName, realCallback)
      let callbackList=this.callbackMap.get(eventName)
      LogUtils.debug(LiveDataBus.name,'removeObserve:'+eventName+'移除前大小'+callbackList.length)
      callbackList.remove(callback as Callback<Object>)
      LogUtils.debug(LiveDataBus.name,'removeObserve:'+eventName+'移除后大小'+callbackList.length)
    } else if (realCallback) {
      emitter.off(eventName)
    }
  }

  post<T extends Object>(eventName: string, data: T) {
    if (emitter.getListenerCount(eventName) > 0) {
      let eventData: emitter.EventData = {
        data: data,
      };
      emitter.emit(eventName, eventData);
    }
  }
}