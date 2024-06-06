import { DeviceUtils, Lifecycle, LifecycleEvent } from '@android/utilcode';
import CommonItemTitle from '../bean/CommonItemTitle';
import CommonConst from '../const/CommonConst';
import { AppUtils } from '@android/utilcode/src/main/ets/AppUtils';
import { BaseFragmentComp } from '../components/BaseFragmentComp';
import { LifecycleState } from '@android/utilcode/src/main/ets/lifecycle/Lifecycle';

/**
 * @author Tanranran
 * @date 2024/5/15 23:25
 * @description
 */
@Component
@Preview
export struct AppUtilsFragment {
  @Consume(CommonConst.NavPathStack) pageInfos: NavPathStack
  @State listData: Array<CommonItemTitle> = []
  @State title: string = ""
  @LifecycleEvent lifecycle: Lifecycle = new Lifecycle()

  async aboutToAppear(): Promise<void> {
    this.lifecycle.addObserver((state: LifecycleState) => {
      console.log("状态" + state)
    })
  }

  build() {
    BaseFragmentComp({ title: this.title, listData: this.listData })
  }
}
