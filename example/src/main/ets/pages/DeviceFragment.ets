import { DeviceUtils } from '@ranran/utilcode/Index';
import CommonItemTitle from '../bean/CommonItemTitle';
import CommonConst from '../const/CommonConst';

/**
 * @author Tanranran
 * @date 2024/5/13 22:25
 * @description
 */
@Component
export struct DeviceFragment {
  @Consume(CommonConst.NavPathStack) pageInfos: NavPathStack
  @State listData: Array<CommonItemTitle> = []

  async aboutToAppear(): Promise<void> {
    this.listData.push(new CommonItemTitle('getDeviceID', await DeviceUtils.getDeviceId()))
  }

  build() {
    NavDestination() {
      List({initialIndex: 0 }) {
        ForEach(this.listData, (item: CommonItemTitle) => {
          ListItem() {
            Column() {
              Text(item.title).fontWeight(FontWeight.Bold)
              Text(item.content).margin({top:12})
            }
            .padding(12)
            .alignItems(HorizontalAlign.Start)
            .borderRadius(3)
            .backgroundColor(Color.White).width('100%')
          }
        }, (item: CommonItemTitle) => item.title)
      }
      .divider({ strokeWidth: '1px', color:$r('sys.color.ohos_id_divider_color') })
      .height('100%')
      .width("100%")
      .listDirection(Axis.Vertical)
    }.title('DeviceUtils Demo').backgroundColor('#F5F5F5')
  }
}
