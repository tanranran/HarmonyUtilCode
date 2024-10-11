import { PermissionUtils, ToastUtils } from '@android_x/utilcode'
/**
 * @author Tanranran
 * @date 2024/7/31 16:25
 * @description
 */
import CommonItemTitle from '../bean/CommonItemTitle'
import { BaseFragmentComp } from '../components/BaseFragmentComp'
import CommonConst from '../const/CommonConst'
import { IntentUtils } from '@android_x/utilcode/src/main/ets/IntentUtils'
import { abilityAccessCtrl, Context, common } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';

@Component
@Preview
export struct PermissionFragment {
  @Consume(CommonConst.NavPathStack) pageInfos: NavPathStack
  @State listData: Array<CommonItemTitle> = []
  @State title: string = ""

  async aboutToAppear(): Promise<void> {
    this.listData.push(new CommonItemTitle('申请定位权限', '', '', () => {
      PermissionUtils.with().request('ohos.permission.LOCATION', 'ohos.permission.APPROXIMATELY_LOCATION').then(res => {
        if (res.allGranted) {
          ToastUtils.show('已授权A')
        }else{
          // IntentUtils.startAppSettings()
          res.requestPermissionOnSetting?.().then(resSetting=>{
            if(resSetting.allGranted){
              ToastUtils.show('已再次授权A')
            }else{
              ToastUtils.show('已拒绝B')
            }
          })
        }
      })
    }))
  }

  build() {
    BaseFragmentComp({ title: this.title, listData: this.listData })
  }
}


@Builder
export function PageBuilder() {
  PermissionFragment()
}