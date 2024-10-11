import { DeviceUtils, Lifecycle, LifecycleEvent, LifecycleState, LogUtils } from '@android_x/utilcode';
import CommonItemTitle from '../bean/CommonItemTitle';
import CommonConst from '../const/CommonConst';
import { AppUtils } from '@android_x/utilcode/src/main/ets/AppUtils';
import { BaseFragmentComp } from '../components/BaseFragmentComp';
import { SourceType } from '@kit.InputKit';
import { taskpool } from '@kit.ArkTS';
import { BusinessError } from '@kit.BasicServicesKit';
import { LiveDataBus } from '@android_x/utilcode/src/main/ets/LiveDataBus';

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
    this.listData.push(new CommonItemTitle('isAppDebug', AppUtils.isAppDebug() ? 'true' : 'false'))
    this.listData.push(new CommonItemTitle('packageName', AppUtils.getPackageName()))
    this.listData.push(new CommonItemTitle('AppName', AppUtils.getAppName()))
    this.listData.push(new CommonItemTitle('AppVersionName', AppUtils.getAppVersionName()))
    this.listData.push(new CommonItemTitle('AppVersionCode', `${AppUtils.getAppVersionCode()}`))
    this.lifecycle.addObserver((state: LifecycleState) => {
      console.log("状态" + state)
    })
  }

  build() {
    BaseFragmentComp({ title: this.title, listData: this.listData })
  }

  aboutToDisappear(): void {
    LiveDataBus.removeObserve("test")
  }
}


@Builder
export function PageBuilder() {
  AppUtilsFragment()
}
