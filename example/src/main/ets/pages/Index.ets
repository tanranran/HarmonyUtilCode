import { DeviceFragment } from './DeviceFragment';
import CommonConst from '../const/CommonConst';
import CommonItemTitle from '../bean/CommonItemTitle';
import { ArrayList } from '@kit.ArkTS';
import { AppUtilsFragment } from './AppUtilsFragment';

@Entry
@Component
struct Index {
  @Provide(CommonConst.NavPathStack) pathStack: NavPathStack = new NavPathStack();
  @State listData: Array<CommonItemTitle> = []

  aboutToAppear(): void {
    this.listData = []
    this.listData.push(new CommonItemTitle('DeviceUtils Demo','', DeviceFragment.name))
    this.listData.push(new CommonItemTitle('AppUtils Demo','', AppUtilsFragment.name))
  }

  @Builder
  PagesMap(name: string, param: CommonItemTitle) {
    if (name == DeviceFragment.name) {
      DeviceFragment({ title: param.title })
    } else if (name == AppUtilsFragment.name) {
      AppUtilsFragment({ title: param.title })
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
              name: item.pageName,
              param: item
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