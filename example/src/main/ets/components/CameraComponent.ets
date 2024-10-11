import { CameraManager, CameraViewModel } from './CameraManager';
import { ImageUtils, LogUtils, ScreenUtils, StopWatch } from '@android_x/utilcode';
import { StateConst } from '../const/StateConst';
import { CameraConstants } from './CameraConstants';

/**
 * @author Tanranran
 * @date 2024/7/18 15:55
 * @description
 */
@Component
export struct CameraComponent {
  @StorageProp(StateConst.IS_ON_FOREGROUND) @Watch('onForegroundChange') isForeground: boolean = true
  @State cameraViewModel: CameraViewModel = CameraManager.getInstance().cameraViewModel
  xComponentController: XComponentController = new XComponentController()
  @State pixelMap: PixelMap = ImageUtils.createPixelMap()

  async aboutToAppear(): Promise<void> {
    CameraManager.getInstance().init(this.xComponentController)
    CameraManager.getInstance().setPictureCallback((image) => {
      if (image) {
        this.pixelMap = image
      }
    })

  }

  aboutToDisappear(): void {
    CameraManager.getInstance().releaseCamera();
  }

  //前后台变化回调
  onForegroundChange() {
    if (this.isForeground) { //前台
      CameraManager.getInstance().restart()
    } else { //后台

    }
  }

  build() {
    Column() {
      Stack() {
        RelativeContainer() {
          XComponent({
            id: 'camera_xcomponent',
            type: XComponentType.SURFACE,
            controller: this.xComponentController
          })
            .id('camera_xcomponent')
            .height('100%')
            .width('100%')
            .backgroundColor(Color.Black)
            .onLoad(() => {
              let surfaceId = this.xComponentController.getXComponentSurfaceId()
              if (CameraManager.getInstance().isInitSuccess()) {
                CameraManager.getInstance().openPhoto(surfaceId)
              } else {
                LogUtils.error(CameraComponent.name, '初始化相机失败')
              }
            })

          Text(this.cameraViewModel.blankTopHeight + '')
            .id('blank_top')
            .width('100%')
            .fontColor(Color.White)
            .height(this.cameraViewModel.blankTopHeight)
            .backgroundColor(Color.Black)
            .alignRules({
              top: { 'anchor': 'camera_xcomponent', 'align': VerticalAlign.Top }
            })

          Text(this.cameraViewModel.blankBottomHeight + '')
            .id('blank_bottom')
            .width('100%')
            .fontColor(Color.White)
            .height(this.cameraViewModel.blankBottomHeight)
            .backgroundColor(Color.Black)
            .alignRules({
              bottom: { 'anchor': 'camera_xcomponent', 'align': VerticalAlign.Bottom }
            })
        }
        .backgroundColor(Color.Red)
        .width('100%')
        .height('100%')
        .height(this.cameraViewModel.previewHeight)
      }.width('100%')
      .clip(true)
      .layoutWeight(1)
      .backgroundColor(Color.Green)

      Row() {
        // Button('前后摄像头').onClick(() => {
        //   CameraManager.getInstance().switchCamera()
        // })
        Button('拍照').onClick(() => {
          CameraManager.getInstance().takePicture()
        })
        Button('比例').onClick(() => {
          CameraManager.getInstance().switchAspectRatio()
        })
        // Button('停止').onClick(() => {
        //   CameraManager.getInstance().stop()
        // })
        // Button('重启').onClick(() => {
        //   CameraManager.getInstance().restart()
        // })
        Image(this.pixelMap)
          .width(100)
          .height(100)
          .objectFit(ImageFit.Contain)
      }.height(100)
    }
  }
}