/**
 * @author Tanranran
 * @date 2024/7/10 11:07
 * @description
 */
import CommonItemTitle from '../bean/CommonItemTitle'
import { BaseFragmentComp } from '../components/BaseFragmentComp'
import { emitter } from '@kit.BasicServicesKit'
import { LiveDataBus, Lifecycle, LifecycleEvent } from '@android_x/utilcode'

@Component
@Preview
export struct LiveDataBusFragment {
  @State listData: Array<CommonItemTitle> = []
  @LifecycleEvent lifecycle: Lifecycle = new Lifecycle()
  private eventCallback: (data: string) => void = (data: string) => {
    console.log("收到了事件A" + data)
  }

  aboutToAppear() {
    this.listData.push(new CommonItemTitle('发送Event事件', '', '', () => {
      LiveDataBus.post<string>("test", "我是事件消息")
    }))
    LiveDataBus.observe<string>("test", this.eventCallback, this.lifecycle)
    LiveDataBus.observe<string>("test", (data: string) => {
      console.log("收到了推送B" + data)
    }, this.lifecycle)
  }

  build() {
    BaseFragmentComp({ listData: this.listData })
  }
}

@Builder
export function PageBuilder() {
  LiveDataBusFragment()
}