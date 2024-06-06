/**
 * @author Tanranran
 * @date 2024/5/15 23:32
 * @description
 */
import CommonItemTitle from '../bean/CommonItemTitle'
import observer from '@ohos.arkui.observer';

@Component
export struct BaseFragmentComp {
  @BuilderParam content: () => void
  @Prop title: string = ''
  @Prop listData: Array<CommonItemTitle> = []

  build() {
    NavDestination() {
      List() {
        ForEach(this.listData, (item: CommonItemTitle) => {
          ListItem() {
            Column() {
              Text(item.title).fontWeight(FontWeight.Bold)
              Text(item.content).margin({ top: 12 }).onClick(()=>{
                console.log('get navDestinationInfo: ' + JSON.stringify(this.queryNavDestinationInfo()))
              })
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
    }.title(this.title).backgroundColor('#F5F5F5')
  }
}