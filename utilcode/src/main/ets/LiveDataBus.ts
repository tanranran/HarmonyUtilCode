/**
 * 基于emitter封装的事件消息总线
 * @author Tanranran
 * @date 2024/7/9 14:57
 * @description
 */
import { HashMap } from '@kit.ArkTS'
import { Callback, emitter } from '@kit.BasicServicesKit'
import { Lifecycle, LifecycleState } from './lifecycle/Lifecycle'

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

  public static observe<T>(eventName: string, callback: (T?) => void, lifecycle?: Lifecycle) {
    LiveDataBus.getInstance().dispatch.observe(eventName, callback)
    lifecycle?.addObserver((state: LifecycleState) => {
      if (state == LifecycleState.ToDisappear) {
        LiveDataBus.getInstance().dispatch.removeObserve(eventName, callback)
      }
    })
    return callback
  }

  public static removeObserve<T>(eventId: string, callback?: (T?) => void) {
    LiveDataBus.getInstance().dispatch.removeObserve(eventId, callback)
  }

  public static post<T>(eventName: string, value: T) {
    LiveDataBus.getInstance().dispatch.post(eventName, value)
  }
}

class Dispatch {
  private callbackMap = new HashMap<string, HashMap<(T?) => void, Callback<emitter.EventData>>>()

  observe<T>(eventName: string, callback: (T?) => void) {
    if (!this.callbackMap.hasKey(eventName)) {
      this.callbackMap.set(eventName, new HashMap())
    }
    let realCallback: Callback<emitter.EventData> = (eventData) => {
      callback(eventData.data)
    }
    this.callbackMap.get(eventName).set(callback, realCallback)
    emitter.on(eventName, realCallback);
  }

  removeObserve(eventName: string, callback: () => void) {
    let realCallback: Callback<emitter.EventData>
    if (this.callbackMap.hasKey(eventName)) {
      realCallback = this.callbackMap.get(eventName).get(callback)
    }
    if (!this.callbackMap.hasKey(eventName) || this.callbackMap.get(eventName).length == 0) {
      emitter.off(eventName)
    } else {
      emitter.off(eventName, realCallback)
      this.callbackMap.get(eventName).remove(callback)
    }
  }

  post<T>(eventName: string, data: T) {
    if (emitter.getListenerCount(eventName) > 0) {
      let eventData: emitter.EventData = {
        data: data,
      };
      emitter.emit(eventName, eventData);
    }
  }
}