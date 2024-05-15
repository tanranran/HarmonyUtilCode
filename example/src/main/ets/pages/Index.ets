import { DeviceFragment } from './DeviceFragment';
import CommonConst from '../const/CommonConst';
import CommonItemTitle from '../bean/CommonItemTitle';
import { ArrayList } from '@kit.ArkTS';

@Entry
@Component
struct Index {
  @Provide(CommonConst.NavPathStack) pathStack: NavPathStack = new NavPathStack();
  @State listData: Array<CommonItemTitle> = []

  aboutToAppear(): void {
    this.listData.push(new CommonItemTitle('DeviceUtils Demo', 'DeviceFragment'))
  }

  @Builder
  PagesMap(name: string) {
    if (name == 'DeviceFragment') {
      DeviceFragment()
    }
  }

  build() {
    Navigation(this.pathStack) {
      List({ space: 10, initialIndex: 0 }) {
        ForEach(this.listData, (item: CommonItemTitle) => {
          ListItem() {
            Button(item.title).width('100%')
          }.padding({ left: 12, right: 12 })
          .onClick(() => {
            this.pathStack.pushPath({
              name: item.content
            })
          })
        }, (item: CommonItemTitle) => item.title)
      }
      .height('100%')
      .width("100%")
      .listDirection(Axis.Vertical)
    }
    .title("主页", {
      backgroundColor: Color.Transparent,
      backgroundBlurStyle: BlurStyle.BACKGROUND_THIN
    })
    .titleMode(NavigationTitleMode.Mini)
    .hideBackButton(true)
    .width('100%')
    .height('100%')
    .navDestination(this.PagesMap)
  }
}