import { PermissionUtils } from '@android_x/utilcode'
/**
 * @author Tanranran
 * @date 2024/7/31 16:25
 * @description
 */
import CommonItemTitle from '../bean/CommonItemTitle'
import { BaseFragmentComp } from '../components/BaseFragmentComp'
import CommonConst from '../const/CommonConst'
import { IntentUtils } from '@android_x/utilcode/src/main/ets/IntentUtils'
import { componentSnapshot, ImageModifier } from '@kit.ArkUI'
import { image } from '@kit.ImageKit'

@Component
@Preview
export struct ListSortFragment {
  @Consume(CommonConst.NavPathStack) pageInfos: NavPathStack
  @State listData: Array<CommonItemTitle> = []
  @State title: string = ""
  @State dragIndex: number = 0;
  @State myModifier: ImageAttribute = new ImageModifier().scale({x:1.5,y:1.5})

  aboutToAppear() {
    for (let i = 0; i < 100; i++) {
      this.listData.push(new CommonItemTitle(i + '', i + ''))
    }
  }

  build() {
    BaseFragmentComp({ title: this.title }) {
      List() {
        ForEach(this.listData, (item: CommonItemTitle, index) => {
          ListItem() {
            ListSortItem({ item: item })
          }
          // .onPreDrag((status: PreDragStatus) => {
          //   if (status == PreDragStatus.PREVIEW_LIFT_STARTED) {
          //     item.visible = false;
          //   }else if(status == PreDragStatus.PREVIEW_LANDING_FINISHED){
          //     item.visible = true;
          //   }
          // })
          .onDragStart(() => {
            item.visible = false; // 拖拽时，设置子组件原位置图标不可见
          })
          // .dragPreviewOptions({
          //   mode: [DragPreviewMode.ENABLE_DEFAULT_SHADOW],
          // }, { defaultAnimationBeforeLifting: true })
          .dragPreview(this.dragPreviewBuilder)
          .onDragEnd(() => {
            item.visible = true;
          })
          .onTouch((event: TouchEvent) => { // 拖拽释放时，记录目标位置子组件index值
            if (event.type === TouchType.Down) {
              this.dragIndex = index;
            }
          })
        }, (item: CommonItemTitle) => item.title)
      }
      .divider({ strokeWidth: 10, color: Color.Green})
      .height('100%')
      .width("100%")
      .listDirection(Axis.Horizontal)
      .onDrop((event: DragEvent, extraParams: string) => { // TODO：知识点：在List层，通过onDrop实现拖拽结束后的回调行为
        console.log('测试数据' + extraParams)
        // let jsonString: JsonObjType = JSON.parse(extraParams) as JsonObjType; // 通过参数extraParams获取原位置子组件index值
        // this.changeIndex(this.dragIndex, jsonString.insertIndex); // 互换子组件index值
      })
    }
  }

  @Builder
  dragPreviewBuilder() {
    Column() {
      Text("dragPreview")
        .width(80)
        .height(80)
        .fontSize(20)
        .borderRadius(10)
        .textAlign(TextAlign.Center)
        .fontColor(Color.Black)
        .backgroundColor(Color.Pink)
    }
  }
}

@Component
struct ListSortItem {
  @ObjectLink item: CommonItemTitle

  build() {
    Column() {
      Text(this.item.title).fontWeight(FontWeight.Bold)
      Text(this.item.content).margin(12)
    }
    .visibility(this.item.visible ? Visibility.Visible : Visibility.Hidden)
    .onClick(() => {
      if (this.item.callback) {
        this.item.callback()
      }
    })
    .padding(12)
    .constraintSize({
      minHeight: 60
    })
    .alignItems(HorizontalAlign.Start)
    .justifyContent(FlexAlign.Center)
    .borderRadius(3)
    .aspectRatio(1)
    .height(50)
    .backgroundColor(Color.Red)
  }
}

@Builder
export function PageBuilder() {
  ListSortFragment()
}