import { DeviceUtils } from '@android/utilcode';
import CommonItemTitle from '../bean/CommonItemTitle';
import CommonConst from '../const/CommonConst';

/**
 * @author Tanranran
 * @date 2024/5/15 23:25
 * @description
 */
@Component
export struct AppUtilsFragment {
  @Consume(CommonConst.NavPathStack) pageInfos: NavPathStack
  @State listData: Array<CommonItemTitle> = []

  async aboutToAppear(): Promise<void> {
    this.listData.push(new CommonItemTitle('getDeviceID', await DeviceUtils.getDeviceId()))
  }

  build() {
    NavDestination() {
      List() {
        ForEach(this.listData, (item: CommonItemTitle) => {
          ListItem() {
            Column() {
              Text(item.title).fontWeight(FontWeight.Bold)
              Text(item.content).margin({ top: 12 })
            }
            .padding(12)
            .alignItems(HorizontalAlign.Start)
            .borderRadius(3)
            .backgroundColor(Color.White)
            .width('100%')
          }
        }, (item: CommonItemTitle) => item.title)
      }
      .divider({ strokeWidth: '1px', color: $r('sys.color.ohos_id_divider_color') })
      .height('100%')
      .width("100%")
      .listDirection(Axis.Vertical)
    }.title('DeviceUtils Demo').backgroundColor('#F5F5F5')
  }
}
