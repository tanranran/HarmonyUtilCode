/**
 * @author Tanranran
 * @date 2024/5/15 23:32
 * @description
 */
import CommonItemTitle from '../bean/CommonItemTitle'
import observer from '@ohos.arkui.observer';
import { JsonUtils, ObjectUtils } from '@android_x/utilcode';

@Component
export struct BaseFragmentComp {
  @Prop title: string = ''
  @Prop listData: Array<CommonItemTitle> = []
  @BuilderParam contentComponent?: () => void
  build() {
    NavDestination() {
      if (this.listData.length > 0) {
        List() {
          ForEach(this.listData, (item: CommonItemTitle) => {
            ListItem() {
              Column() {
                Text(item.title).fontWeight(FontWeight.Bold)
                Text(item.content).margin({ top: item.content && item.title ? 12 : 0 }).onClick(() => {
                  console.log('get navDestinationInfo: ' + JSON.stringify(this.queryNavDestinationInfo()))
                })
              }
              .onClick(() => {
                if (item.callback) {
                  item.callback()
                }
              })
              .padding(12)
              .constraintSize({
                minHeight: 60
              })
              .alignItems(HorizontalAlign.Start)
              .justifyContent(FlexAlign.Center)
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
      } else {
        this.contentComponent?.()
      }
    }
    .title(this.title)
    .onReady((context: NavDestinationContext) => {
      let params = context.pathInfo.param as object
      if (params) {
        if (params instanceof CommonItemTitle) {
          this.title = params.title
        }
      }
    })
    .backgroundColor('#F5F5F5')
  }

  onRead() {
    return this
  }
}