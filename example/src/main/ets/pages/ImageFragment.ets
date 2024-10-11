import {
  ImageCompressOptions,
  ImageMimeType,
  ImageUtils,
  JsonUtils,
  Permission,
  PermissionUtils,
  PickerHelper,
  PickerOptions,
  ResourceUtils,
  ToastUtils
} from '@android_x/utilcode'
import { BaseFragmentComp } from '../components/BaseFragmentComp'
import { AlbumComponent } from '../components/AlbumComponent';
import { CameraComponent } from '../components/CameraComponent';

@Component
@Preview
export struct ImageFragment {
  @State compressedImageSrc: string | Resource | PixelMap = ''; // 压缩后的图片路径
  @State beforeCompressionSize: string = ''; // 压缩前的图片大小,单位kb
  @State afterCompressionSize: string = ''; // 压缩后的图片大小,单位kb
  @State strMaxCompressedImageSize: string = ''; // 指定图片压缩目标大小,string类型
  private maxCompressedImageSize: number = 0; // 指定图片压缩目标大小，单位kb
  private imageUint8Array?: ArrayBuffer

  aboutToAppear(): void {
    ResourceUtils.getRawFileContent('image_compression_before.jpeg').then(fileData => {
      if (fileData) {
        this.imageUint8Array = fileData.buffer.slice(0)
        let imageByteLength = fileData.byteLength;
        this.beforeCompressionSize = (imageByteLength / 1000).toFixed(1);
      }
    })

    PermissionUtils.with().request(Permission.CAMERA).then(res => {
      if (res) {
        ToastUtils.show("申请成功")
      }
    })
  }

  build() {
    BaseFragmentComp() {
      Tabs({ barPosition: BarPosition.End }) {
        this.compressContent()

        TabContent() {
          Column() {
            AlbumComponent()
          }
          .width('100%').height('100%')
        }.tabBar('自定义相册')

        TabContent() {
          Column() {
            CameraComponent()
          }
          .width('100%').height('100%')
        }.tabBar('自定义相机')
      }
    }
  }

  @Builder
  compressContent() {
    TabContent() {
      Scroll() {
        Column() {
          Row() {
            Text('压缩前图片大小(kb):')
              .fontSize(20)
            Text(this.beforeCompressionSize)
              .fontSize(20)
          }

          Image($rawfile('image_compression_before.jpeg'))
            .width('100%')
            .height('30%')

          Row() {
            Text('压缩后图片大小(kb):')
              .fontSize(20)
            Text(this.afterCompressionSize)
              .fontSize(20)
          }

          Image(this.compressedImageSrc)
            .objectFit(ImageFit.ScaleDown)
            .width('100%')
            .height('30%')

          Row() {
            Button('压缩图片').onClick(() => {
              let json =
                '[{"tab_id":"193","show_name":"户外服饰","relation_id":"191,193"},{"tab_id":"197","show_name":"体育项目","relation_id":"191,197"},{"tab_id":"1521","show_name":"户外鞋袜","relation_id":"191,1521"}]'
              console.log('测试数据'+JsonUtils.json2Array<Relation>(Relation,json))
              // return
              // if (this.imageUint8Array) {
              //   let options = new ImageCompressOptions()
              //   options.maxWidth = 400
              //   options.maxHeight = 400
              //   options.format = ImageMimeType.JPG
              //   options.quality = 100
              //   ImageUtils.compressedImageAsync(this.imageUint8Array, options).then(res => {
              //     if (res && res.pixelMap) {
              //       this.compressedImageSrc = res.pixelMap
              //       this.afterCompressionSize = (((res.compressImageInfo?.size ?? 0) / 1000).toFixed(1)) + 'kb';
              //     }
              //   })
              // }
            })
            SaveButton({
              icon: SaveIconStyle.FULL_FILLED,
              text: SaveDescription.SAVE_IMAGE,
              buttonType: ButtonType.Capsule
            })
              .onClick(async (event: ClickEvent, result: SaveButtonOnClickResult) => {
                if (result == SaveButtonOnClickResult.SUCCESS) {
                  let saveResult = await ImageUtils.saveImageToPhotoAlbum(this.imageUint8Array)
                  if (saveResult > 0) {
                    ToastUtils.show("保存成功")
                  }
                } else {
                  ToastUtils.show('未获取到临时写入权限')
                }
              })
            Button('唤起相册').onClick(() => {
              let options = new PickerOptions()
              options.compressOptions = new ImageCompressOptions()
              options.compressOptions.maxSize = 0.01 * 1000 * 1000
              PickerHelper.selectPhoto(options).then(async resList => {
                if (resList && resList.length > 0) {
                  let res = resList[0]
                  if (res.pixelMap) {
                    this.compressedImageSrc = res.pixelMap
                    let imageBase64 = await ImageUtils.pixelMapToBase64Str(res.pixelMap)
                    console.log('图片base64：' + imageBase64)
                    this.afterCompressionSize = (((res.compressImageInfo?.size ?? 0) / 1000).toFixed(1)) + 'kb';
                  }
                }
              })
            })
            Button('唤起相机').onClick(() => {
              let pickerOptions = new PickerOptions()
              pickerOptions.compressOptions = new ImageCompressOptions()
              pickerOptions.compressOptions.maxWidth = 1024
              pickerOptions.compressOptions.maxHeight = 1024
              pickerOptions.compressOptions.maxSize = 1 * 1000 * 1000
              PickerHelper.takePhoto(pickerOptions).then(res => {
                if (res && res.pixelMap) {
                  this.compressedImageSrc = res.pixelMap
                  this.afterCompressionSize = (((res.compressImageInfo?.size ?? 0) / 1000).toFixed(1)) + 'kb';
                }
              })
            })
          }
        }
        .width('100%')
      }
      .width('100%').height('100%')
    }.tabBar('压缩图片')
  }
}

class Relation{
  tab_id?:string
  show_name?:number
  relation_id?:number
}

@Builder
export function PageBuilder() {
  ImageFragment()
}