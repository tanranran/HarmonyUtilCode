import {
  ClickType,
  DataType,
  ItemInfo,
  ItemType,
  PhotoBrowserInfo,
  PhotoPickerComponent,
  PickerColorMode,
  PickerController,
  PickerOptions,
  ReminderMode
} from '@ohos.file.PhotoPickerComponent';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { ToastUtils } from '@android_x/utilcode';

/**
 * 自定义相册组件
 * @author Tanranran
 * @date 2024/7/15 18:27
 * @description
 */
@Component
export struct AlbumComponent {
  pickerOptions: PickerOptions = new PickerOptions();
  @State pickerController: PickerController = new PickerController();
  @State selectUris: Array<string> = new Array<string>();

  aboutToAppear(): void {
    this.pickerOptions.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_VIDEO_TYPE;
    this.pickerOptions.checkBoxColor = '#FFFFFF'
    this.pickerOptions.checkboxTextColor='#FF0000'
    this.pickerOptions.backgroundColor = '#b7d332'
    this.pickerOptions.photoBrowserBackgroundColorMode = PickerColorMode.AUTO
    this.pickerOptions.maxSelectedReminderMode = ReminderMode.NONE
    this.pickerOptions.isRepeatSelectSupported = false //是否支持单张图片重复选择。true表示支持。
    this.pickerOptions.isSearchSupported = false; //是否支持搜索
    this.pickerOptions.isPhotoTakingSupported = true; //是否支持拍照

  }

  build() {
    Column() {
      PhotoPickerComponent({
        pickerOptions: this.pickerOptions, //picker参数信息。
        // onSelect: (uri: string): void => this.onSelect(uri), //用户在Picker组件中勾选图片时产生的回调事件，将图片uri报给应用。
        // onDeselect: (uri: string): void => this.onDeselect(uri), //用户在Picker组件中取消勾选图片时产生的回调事件，同时也会将图片uri报给应用。
        onItemClicked: (itemInfo: ItemInfo, clickType: ClickType): boolean => this.onItemClicked(itemInfo,
          clickType), // 该接口可替代上面两个接口[用户在picker组件中点击item产生的回调事件。点击图片（缩略图item）时，返回值为true则勾选此图片，否则不勾选；点击相机item，返回值为true则拉起系统相机，否则应用自行处理。]
        // onEnterPhotoBrowser: (photoBrowserInfo: PhotoBrowserInfo): boolean => this.onEnterPhotoBrowser(photoBrowserInfo), //点击进入大图时产生的回调事件，将大图相关信息报给应用。
        // onExitPhotoBrowser: (photoBrowserInfo: PhotoBrowserInfo): boolean => this.onExitPhotoBrowser(photoBrowserInfo), //退出大图时产生的回调事件，将大图相关信息报给应用。
        // onPickerControllerReady: (): void => this.onPickerControllerReady(), //当pickerController可用时产生的回调事件。
        pickerController: this.pickerController,
      }).layoutWeight(1).width('100%')

      // 这里模拟应用侧底部的选择栏
      Row() {
        Repeat<string>(this.selectUris).each((urlItem: RepeatItem<string>) => {
          Image(urlItem.item)
            .height('100%')
            .autoResize(true)
            .aspectRatio(1)
            .objectFit(ImageFit.Cover)
            .onClick(() => {
              // 点击事件模拟删除操作，通过pickerController向picker组件发送已选择的数据列表，触发picker组件勾选框刷新
              this.selectUris = this.selectUris.filter((item: string) => {
                return item != urlItem.item;
              })
              this.pickerController.setData(DataType.SET_SELECTED_URIS, this.selectUris);
            })
        }).key((item: string) => item)
      }.width('100%').height(100).backgroundColor(Color.Red)
    }.width('100%')
    .height('100%')
  }

  private onItemClicked(itemInfo: ItemInfo, clickType: ClickType): boolean {
    if (!itemInfo) {
      return false;
    }
    let type: ItemType | undefined = itemInfo.itemType;
    if (type === ItemType.CAMERA) {
      // 点击相机item
      return true; // 返回true则拉起系统相机，若应用需要自行处理则返回false。
    } else {
      let uri = itemInfo.uri
      if (clickType === ClickType.SELECTED) {
        if (this.selectUris.length >= 2) {
          ToastUtils.show("已经达到最大数量了")
          return false
        }
        if (uri) {
          this.selectUris.push(uri);
        }
      } else if (clickType === ClickType.DESELECTED) {
        if (uri) {
          this.selectUris = this.selectUris.filter((item: string) => {
            return item != uri;
          })
        }
      }
      console.log('最新数量' + this.selectUris.length)
    }
    return true; // 返回true则勾选，否则则不响应勾选。
  }
}