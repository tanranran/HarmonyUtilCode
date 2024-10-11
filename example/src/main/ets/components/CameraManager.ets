import { camera } from '@kit.CameraKit';
import { LogUtils, ScreenUtils, Utils } from '@android_x/utilcode';
import { CameraConfig } from './CameraConfig';
import { CameraCreateCore } from './CameraCreateCore';
import { FaultLogger } from '@kit.PerformanceAnalysisKit';
import { CameraConstants } from './CameraConstants';
import { UI } from '@android_x/utilcode/src/main/ets/UIAdapt';
import { FrameCallback } from '@ohos.arkui.UIContext';
import { image } from '@kit.ImageKit';

/**
 * @author Tanranran
 * @date 2024/7/18 16:45
 * @description
 */
export class CameraManager {
  private static instance: CameraManager | undefined = undefined;

  public static getInstance(): CameraManager {
    if (!CameraManager.instance) {
      CameraManager.instance = new CameraManager();
    }
    return CameraManager.instance;
  }

  public cameraViewModel: CameraViewModel
  private xComponentController?: XComponentController
  private cameraConfig: CameraConfig = new CameraConfig()
  private cameraManager?: camera.CameraManager
  private cameraCreateLogic: CameraCreateCore = new CameraCreateCore(this)
  private initStatus = false
  private surfaceId = ''
  private isTakePhoto = true
  private isSwitch = false

  constructor() {
    this.cameraViewModel = new CameraViewModel()
  }

  /**
   * 初始化
   * @param xComponentController
   * @returns
   */
  init(xComponentController: XComponentController): boolean {
    try {
      this.xComponentController = xComponentController
      //初始化相机管理器
      this.cameraManager = camera.getCameraManager(Utils.getAbilityContext());
      if (this.cameraManager.isCameraMuted()) {
        LogUtils.error(CameraManager.name, '相机已被禁用');
        return false
      }
      //监听相机状态变化
      this.cameraCreateLogic.onCameraStatusChange()
      //获取可用的相机
      let cameraArray: Array<camera.CameraDevice> = this.cameraManager.getSupportedCameras();
      if (cameraArray.length == 0) {
        LogUtils.error(CameraManager.name, '未查询到可用的相机');
        return false;
      }
      //设置相机列表
      this.cameraConfig.setCameraDeviceList(cameraArray)
      if (this.cameraConfig.getCameraDevice()) {
        this.initStatus = true
        return true
      }
    } catch (e) {
    }
    return false
  }

  /**
   * 打开拍照
   * @param surfaceId
   * @returns
   */
  async openPhoto(surfaceId: string): Promise<boolean> {
    this.isTakePhoto = true
    this.surfaceId = surfaceId
    //如果不支持拍照，则返回
    if (!this.cameraManager || !this.cameraConfig.isSupportTakePhoto(this.cameraManager)) {
      LogUtils.error(CameraManager.name, '不支持拍照')
      return false
    }
    let cameraDevice = this.cameraConfig.getCameraDevice()
    if (!cameraDevice) {
      LogUtils.error(CameraManager.name, '获取相机无效')
      return false
    }
    let cameraOutputCap2 = this.cameraManager.getSupportedOutputCapability(cameraDevice, camera.SceneMode.NORMAL_VIDEO);
    // LogUtils.debug('预览尺寸', JSON.stringify(cameraOutputCap2.previewProfiles))
    // LogUtils.debug('拍摄尺寸',  JSON.stringify(cameraOutputCap2.photoProfiles))
    // LogUtils.debug('录制尺寸',  JSON.stringify(cameraOutputCap2.videoProfiles))
    let cameraOutputCap = this.cameraManager.getSupportedOutputCapability(cameraDevice, camera.SceneMode.NORMAL_PHOTO);
    let previewProfileObj = this.cameraCreateLogic.getPreviewProfile(cameraOutputCap, camera.SceneMode.NORMAL_PHOTO);
    if (!previewProfileObj) {
      LogUtils.error(CameraManager.name, '获取预览配置无效')
      return false
    }
    //更新Surface大小
    this.updateXComponentSurfaceRect()
    //创建预览输出流，通过surfaceId绑定显示组件XComponent。
    let previewOutput = this.cameraCreateLogic.createPreviewOutput(previewProfileObj, surfaceId);
    if (!previewOutput) {
      LogUtils.error(CameraManager.name, '创建预览输出流失败')
      return false
    }
    // 创建photoOutPut输出对象
    let photoProfile = this.cameraCreateLogic.getPhotoProfile(cameraOutputCap);
    if (!photoProfile) {
      LogUtils.error(CameraManager.name, '获取相机配置无效')
      return false;
    }
    let photoOutput = this.cameraCreateLogic.createPhotoOutput(photoProfile);
    if (!photoOutput) {
      LogUtils.debug(CameraManager.name, '创建相机输出流失败')
      return false;
    }
    let openStatus = await this.starCamera(cameraDevice, camera.SceneMode.NORMAL_PHOTO)
    if (!openStatus) {
      LogUtils.debug(CameraManager.name, '打开相机失败')
      return false;
    }
    return openStatus
  }

  /**
   * 打开视频
   * @param surfaceId
   * @returns
   */
  async openVideo(surfaceId: string): Promise<boolean> {
    this.isTakePhoto = false
    this.surfaceId = surfaceId
    //如果不支持录像，则返回
    if (!this.cameraManager || !this.cameraConfig.isSupportTakeVideo(this.cameraManager)) {
      LogUtils.error(CameraManager.name, '不支持录像')
      return false
    }
    let cameraDevice = this.cameraConfig.getCameraDevice()
    if (!cameraDevice) {
      LogUtils.error(CameraManager.name, '获取相机无效')
      return false
    }
    let cameraOutputCap = this.cameraManager.getSupportedOutputCapability(cameraDevice, camera.SceneMode.NORMAL_VIDEO);
    let previewProfileObj = this.cameraCreateLogic.getPreviewProfile(cameraOutputCap, camera.SceneMode.NORMAL_VIDEO);
    if (!previewProfileObj) {
      LogUtils.error(CameraManager.name, '获取预览配置无效')
      return false
    }
    //更新Surface大小
    this.updateXComponentSurfaceRect()
    //创建预览输出流，通过surfaceId绑定显示组件XComponent。
    let previewOutput = this.cameraCreateLogic.createPreviewOutput(previewProfileObj, surfaceId);
    if (!previewOutput) {
      LogUtils.error(CameraManager.name, '创建预览输出流失败')
      return false
    }

    let videoProfile = this.cameraCreateLogic.getVideoProfile(cameraOutputCap);
    if (!videoProfile) {
      LogUtils.error(CameraManager.name, '获取视频配置无效')
      return false;
    }

    let avRecorder = await this.cameraCreateLogic.createAVRecorder();
    if (!avRecorder) {
      LogUtils.error(CameraManager.name, '获取视频录制配置无效')
      return false;
    }
    await this.cameraCreateLogic.prepareAVRecorder(videoProfile, cameraDevice);
    let videoSurfaceId = await avRecorder.getInputSurface();
    // 创建videoOutPut输出对象
    let videoOutput = this.cameraCreateLogic.createVideoOutput(videoProfile, videoSurfaceId);
    if (!videoOutput) {
      LogUtils.error(CameraManager.name, '创建视频输出流失败')
      return false;
    }
    let openStatus = await this.starCamera(cameraDevice, camera.SceneMode.NORMAL_VIDEO)
    if (!openStatus) {
      LogUtils.debug(CameraManager.name, '打开相机失败')
      return false;
    }
    return openStatus
  }

  /**
   * 开启相机
   * @param cameraDevice
   * @param sceneMode
   * @returns
   */
  async starCamera(cameraDevice: camera.CameraDevice, sceneMode: camera.SceneMode): Promise<boolean> {
    // 创建cameraInput输出对象
    let cameraInput = this.cameraCreateLogic.createCameraInput(cameraDevice);
    if (!cameraInput) {
      LogUtils.error(CameraManager.name, '创建相机输出配置无效')
      return false;
    }
    // 打开相机
    let isOpenSuccess = await this.cameraCreateLogic.cameraInputOpen();
    if (!isOpenSuccess) {
      LogUtils.error(CameraManager.name, '打开相机失败')
      return false;
    }
    return await this.cameraCreateLogic.createCameraSession(sceneMode)
  }

  /**
   * 拍照
   * @returns
   */
  takePicture(): Promise<boolean> {
    return this.cameraCreateLogic.takePicture()
  }

  /**
   * 停止
   * @returns
   */
  stop(){
    return this.cameraCreateLogic.stop()
  }
  /**
   * 重启
   * @returns
   */
  restart(): Promise<boolean> {
    return new Promise<boolean>((resolve) => {
      if (!this.initStatus) {
        resolve(false)
        return
      }
      this.cameraCreateLogic.releaseCamera().finally(async () => {
        if (this.isTakePhoto) {
          resolve(await this.openPhoto(this.surfaceId))
        } else {
          resolve(await this.openVideo(this.surfaceId))
        }
      })
    })
  }

  /**
   *切换前后摄像头
   */
  switchCamera() {
    if (this.isSwitch) {
      return
    }
    this.isSwitch = true
    if (this.initStatus) {
      this.getCameraConfig().switchCamera()
      this.restart().finally(() => {
        this.isSwitch = false
      })
    }
  }

  /**
   *切换拍摄比例
   */
  switchAspectRatio() {
    this.getCameraConfig().switchAspectRatio()
    this.updateXComponentSurfaceRatio()
  }

  /**
   *释放相机
   */
  releaseCamera() {
    this.cameraCreateLogic.releaseCamera()
    this.xComponentController = undefined
  }

  /**
   * 设置拍照结果回调
   * @param callback
   */
  setPictureCallback(callback: (image: PixelMap | null) => void): void {
    this.cameraCreateLogic.setPictureCallback(callback)
  }

  /**
   *是否初始化成功
   * @returns
   */
  isInitSuccess() {
    return this.initStatus
  }

  getCameraManager() {
    return this.cameraManager
  }

  getCameraConfig() {
    return this.cameraConfig
  }

  getCameraViewModel() {
    return this.cameraViewModel
  }

  updateXComponentSurfaceRect() {
    let previewProfile = CameraConstants.previewProfile
    let previewRatio = previewProfile.size.width / previewProfile.size.height
    let width = ScreenUtils.getScreenWidth()
    let height = width * previewRatio
    let surfaceRect: SurfaceRect = {
      surfaceWidth: width,
      surfaceHeight: height
    }
    this.cameraViewModel.previewHeight = px2vp(height)
    // this.xComponentController?.setXComponentSurfaceRect(surfaceRect)
    this.updateXComponentSurfaceRatio()
  }

  updateXComponentSurfaceRatio() {
    let aspectRatio = this.getCameraConfig().aspectRatio
    let width = px2vp(ScreenUtils.getScreenWidth())
    let height = this.cameraViewModel.previewHeight
    let blankHeight = Number(height) - (Number(width) / aspectRatio)
    this.cameraViewModel.blankTopHeight = (blankHeight / 2)
    this.cameraViewModel.blankBottomHeight = (blankHeight / 2)
  }
}

@Observed
export class CameraViewModel {
  previewHeight: Length = '50%'
  blankTopHeight: Length = 0
  blankBottomHeight: Length = 0
}