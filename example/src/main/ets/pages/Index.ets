import { DeviceFragment } from './DeviceFragment';
import CommonConst from '../const/CommonConst';
import CommonItemTitle from '../bean/CommonItemTitle';
import { AppUtilsFragment } from './AppUtilsFragment';
import { ClipboardFragment } from './ClipboardFragment';
import { LiveDataBusFragment } from './LiveDataBusFragment';
import { ImageFragment } from './ImageFragment';
import { PermissionFragment } from './PermissionFragment';
import { DialogFragment } from './DialogFragment';
import { ListSortFragment } from './ListSortFragment';
import { webview } from '@kit.ArkWeb';

@Entry
@Component
struct Index {
  @Provide(CommonConst.NavPathStack) pathStack: NavPathStack = new NavPathStack();
  @State listData: Array<CommonItemTitle> = []

  aboutToAppear(): void {
    this.listData = []
    this.listData.push(new CommonItemTitle('DeviceUtils Demo','', DeviceFragment.name))
    this.listData.push(new CommonItemTitle('AppUtils Demo','', AppUtilsFragment.name))
    this.listData.push(new CommonItemTitle('Clipboard Demo','', ClipboardFragment.name))
    this.listData.push(new CommonItemTitle('EventBus Demo','', LiveDataBusFragment.name))
    this.listData.push(new CommonItemTitle('Image Demo','', ImageFragment.name))
    this.listData.push(new CommonItemTitle('Permission Demo','', PermissionFragment.name))
    this.listData.push(new CommonItemTitle('Dialog Demo','', DialogFragment.name))
    this.listData.push(new CommonItemTitle('ListSort Demo','', ListSortFragment.name))
  }


  build() {
    Navigation(this.pathStack) {
      Stack(){
        List({ space: 10, initialIndex: 0 }) {
          ForEach(this.listData, (item: CommonItemTitle) => {
            ListItem() {
              Button(item.title).width('100%')
            }.padding({ left: 12, right: 12 })
            .onClick(() => {
              this.pathStack.pushDestinationByName(item.pageName,item)
            })
          }, (item: CommonItemTitle) => item.title)
        }
        .height('100%')
        .width("100%")
        .listDirection(Axis.Vertical)
      }
    }
    .title("主页", {
      backgroundColor: Color.Transparent,
      backgroundBlurStyle: BlurStyle.BACKGROUND_THIN
    })
    .mode(NavigationMode.Stack)
    .titleMode(NavigationTitleMode.Mini)
    .hideBackButton(true)
    .width('100%')
    .height('100%')
  }
}