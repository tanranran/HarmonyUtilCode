/**
 * @author Tanranran
 * @date 2024/7/18 18:46
 * @description
 */
import { camera } from '@kit.CameraKit';
import { CameraManager } from './CameraManager';
import { AsyncCallback, BusinessError } from '@kit.BasicServicesKit';
import { JSON } from '@kit.ArkTS';
import { media } from '@kit.MediaKit';
import { AppUtils, ImageUtils, JsonUtils, LogUtils } from '@android_x/utilcode';
import { fileIo } from '@kit.CoreFileKit';
import { CameraConstants, CameraProfile } from './CameraConstants';
import { image } from '@kit.ImageKit';
import { FileUtils } from '@android_x/utilcode';
import { photoAccessHelper } from '@kit.MediaLibraryKit';

export class CameraCreateCore {
  private cameraManager: CameraManager
  private cameraInput?: camera.CameraInput
  private previewOutput?: camera.PreviewOutput
  private photoOutput?: camera.PhotoOutput;
  private videoOutput?: camera.VideoOutput;
  private avRecorder?: media.AVRecorder;
  session?: camera.PhotoSession | camera.VideoSession;
  private pictureCallback: (image: PixelMap | null) => void = () => {

  };
  private callbackMap = new Map<string, AsyncCallback<void>>()
  private photoFile?: fileIo.File
  private videoFile?: fileIo.File

  constructor(cameraManager: CameraManager) {
    this.cameraManager = cameraManager
  }

  initPath() {
    let filesDir = getContext().filesDir;
    let photoPath = filesDir + `/custom_photo.jpg`;
    let videoPath = filesDir + `/custom_video.mp4`;
    this.photoFile = fileIo.openSync(photoPath, fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE);
    this.videoFile = fileIo.openSync(videoPath, fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE);
  }

  getPreviewProfile(cameraOutputCapability: camera.CameraOutputCapability,
    mode: camera.SceneMode): CameraProfile | undefined {
    let previewProfiles = cameraOutputCapability.previewProfiles;
    if (previewProfiles.length < 1) {
      return undefined;
    }
    let profile: CameraProfile | undefined
    //取交集
    if (mode == camera.SceneMode.NORMAL_PHOTO) {
      let photoProfiles = cameraOutputCapability.photoProfiles;
      profile = this.findSuitableProfile(photoProfiles, previewProfiles, CameraConstants.photoProfile)
    } else if (mode == camera.SceneMode.NORMAL_VIDEO) {
      let videoProfiles = cameraOutputCapability.videoProfiles;
      profile = this.findSuitableProfile(videoProfiles, previewProfiles, CameraConstants.videoProfile)
    }
    if (profile) {
      CameraConstants.previewProfile = profile
    }
    return profile;
  }

  getPhotoProfile(cameraOutputCapability: camera.CameraOutputCapability): camera.Profile | null {
    let photoProfiles = cameraOutputCapability.photoProfiles;
    if (photoProfiles.length < 1) {
      return null;
    }
    let index = photoProfiles.findIndex((photoProfile: camera.Profile) => {
      return photoProfile.size.width === CameraConstants.photoProfile.size.width &&
        photoProfile.size.height === CameraConstants.photoProfile.size.height &&
        photoProfile.format === CameraConstants.photoProfile.format;
    });
    if (index === -1) {
      return null;
    }
    return photoProfiles[index];
  }

  getVideoProfile(cameraOutputCapability: camera.CameraOutputCapability): camera.VideoProfile | null {
    let videoProfiles = cameraOutputCapability.videoProfiles;
    if (videoProfiles.length < 1) {
      return null;
    }
    let index = videoProfiles.findIndex((videoProfile: camera.VideoProfile) => {
      return videoProfile.size.width === CameraConstants.videoProfile.size.width &&
        videoProfile.size.height === CameraConstants.videoProfile.size.height &&
        videoProfile.format === CameraConstants.videoProfile.format &&
        videoProfile.frameRateRange.min <= CameraConstants.MAX_VIDEO_FRAME &&
        videoProfile.frameRateRange.max <= CameraConstants.MAX_VIDEO_FRAME;
    });
    if (index === -1) {
      return null;
    }
    return videoProfiles[index];
  }

  /**
   * 创建previewOutput输出对象
   * @param previewProfilesArray
   * @param surfaceId
   * @returns
   */
  createPreviewOutput(previewProfile: camera.Profile, surfaceId: string) {
    try {
      let cameraManager = this.cameraManager.getCameraManager()
      this.previewOutput = cameraManager?.createPreviewOutput(previewProfile,surfaceId);
      this.previewOutput?.setPreviewRotation(camera.ImageRotation.ROTATION_180,true)
      //监听预览事件
      this.onPreviewOutputCallBack()
      LogUtils.debug('createPreviewOutput', `createPreviewOutput success`);
    } catch (error) {
      let err = error as BusinessError;
      LogUtils.error('createPreviewOutput', `createPreviewOutput failed: ${JSON.stringify(err)}`);
    }
    return this.previewOutput;
  }

  /**
   * 创建photoOutPut输出对象
   * @param photoProfile
   * @returns
   */
  createPhotoOutput(photoProfile: camera.Profile) {
    try {
      let cameraManager = this.cameraManager.getCameraManager()
      this.photoOutput = cameraManager?.createPhotoOutput(photoProfile);
      LogUtils.debug('createPhotoOutput', `createPhotoOutput success`);
    } catch (error) {
      let err = error as BusinessError;
      LogUtils.error('createPhotoOutput', `createPhotoOutput failed: ${JSON.stringify(err)}`);
    }
    return this.photoOutput;
  }

  /**
   * 创建VideoOutput输出对象
   * @param videoProfile
   * @returns
   */
  createVideoOutput(videoProfile: camera.VideoProfile, surfaceId: string) {
    try {
      let cameraManager = this.cameraManager.getCameraManager()
      this.videoOutput = cameraManager?.createVideoOutput(videoProfile, surfaceId);
      LogUtils.debug('createVideoOutput', `createVideoOutput success: ${this.previewOutput}`);
    } catch (error) {
      let err = error as BusinessError;
      LogUtils.error('createVideoOutput', `createVideoOutput failed: ${JSON.stringify(err)}`);
    }
    return this.videoOutput;
  }

  /**
   * 创建cameraInput输出对象
   */
  createCameraInput(cameraDevice: camera.CameraDevice): camera.CameraInput | undefined {
    try {
      let cameraManager = this.cameraManager.getCameraManager()
      this.cameraInput = cameraManager?.createCameraInput(cameraDevice);
      //监听CameraInput的错误事件
      this.cameraInput?.on('error', cameraDevice, this.getCallback('CameraInput_Error'));
      LogUtils.debug('createCameraInput', `createCameraInput success: ${this.cameraInput}`);
    } catch (error) {
      let err = error as BusinessError;
      LogUtils.error('createCameraInput', `createCameraInput failed: ${JSON.stringify(err)}`);
    }
    return this.cameraInput;
  }

  /**
   * 打开相机
   */
  async cameraInputOpen(): Promise<boolean> {
    let isOpenSuccess = false;
    try {
      await this.cameraInput?.open();
      isOpenSuccess = true;
      LogUtils.debug(CameraCreateCore.name, `cameraInputOpen success`);
    } catch (error) {
      let err = error as BusinessError;
      LogUtils.error(CameraCreateCore.name, `cameraInputOpen failed : ${JSON.stringify(err)}`);
    }
    return isOpenSuccess;
  }

  /**
   * 创建相机会话
   */
  async createCameraSession(sceneMode: camera.SceneMode): Promise<boolean> {
    try {
      let cameraManager = this.cameraManager.getCameraManager()
      if (!cameraManager) {
        LogUtils.error(CameraManager.name, 'createCameraSession cameraManager fail')
        return false
      }
      this.session?.stop()
      // 创建CaptureSession实例
      if (sceneMode === camera.SceneMode.NORMAL_PHOTO) {
        this.session = cameraManager.createSession(sceneMode) as camera.PhotoSession;
      } else if (sceneMode === camera.SceneMode.NORMAL_VIDEO) {
        this.session = cameraManager.createSession(sceneMode) as camera.VideoSession;
      }
      this.session?.preconfig(camera.PreconfigType.PRECONFIG_1080P, camera.PreconfigRatio.PRECONFIG_RATIO_1_1);
      if (!this.session) {
        LogUtils.error(CameraManager.name, 'createSession  fail')
        return false;
      }
      //监听捕获会话错误变化
      this.session.on('error', (captureSessionError: BusinessError): void => {
        LogUtils.error(CameraManager.name,
          'onCaptureSessionErrorChange captureSession fail: ' + JSON.stringify(captureSessionError.code));
      });
      // 开始配置会话
      this.session.beginConfig();
      // 把CameraInput加入到会话
      if (this.session.canAddInput(this.cameraInput)) {
        this.session.addInput(this.cameraInput);
      }
      // 把previewOutput加入到会话
      if (this.session.canAddOutput(this.previewOutput)) {
        this.session.addOutput(this.previewOutput);
      }
      if (sceneMode === camera.SceneMode.NORMAL_PHOTO) {
        if (!this.photoOutput) {
          LogUtils.error(CameraManager.name, 'add photoOutput  fail')
          return false;
        }
        // 拍照监听事件
        this.onPhotoOutputCallBack();
        // 把photoOutPut加入到会话
        if (this.session.canAddOutput(this.photoOutput)) {
          this.session.addOutput(this.photoOutput);
        }
      } else if (sceneMode === camera.SceneMode.NORMAL_VIDEO) {
        if (!this.videoOutput) {
          LogUtils.error(CameraManager.name, 'add videoOutput  fail')
          return false;
        }
        // 把videoOutput加入到会话
        if (this.session.canAddOutput(this.videoOutput)) {
          this.session.addOutput(this.videoOutput);
        }
      }
      // 提交配置信息
      await this.session.commitConfig();
      if (sceneMode === camera.SceneMode.NORMAL_VIDEO) {
        //设置视频防抖
        this.setVideoStabilizationFn(this.session as camera.VideoSession, camera.VideoStabilizationMode.AUTO);
      }
      //设置自动对焦
      this.setFocusMode(camera.FocusMode.FOCUS_MODE_AUTO);
      //设置曝光模式
      this.setExposureMode(camera.ExposureMode.EXPOSURE_MODE_AUTO)
      // 开始会话工作
      await this.session.start();
      LogUtils.debug(CameraManager.name, 'sessionFlowFn success');
      return true
    } catch (error) {
      let err = error as BusinessError;
      LogUtils.error(CameraManager.name, `sessionFlowFn fail : ${JSON.stringify(err)}`);
    }
    return false
  }

  /**
   * 设置视频防抖模式
   * @param session
   * @param videoStabilizationMode
   */
  setVideoStabilizationFn(session: camera.VideoSession, videoStabilizationMode: camera.VideoStabilizationMode): void {
    try {
      // 查询是否支持指定的视频防抖模式
      let isVideoStabilizationModeSupported: boolean =
        session.isVideoStabilizationModeSupported(videoStabilizationMode);
      if (isVideoStabilizationModeSupported) {
        session.setVideoStabilizationMode(videoStabilizationMode);
      }
      LogUtils.debug(CameraManager.name, 'setVideoStabilizationFn success');
    } catch (error) {
      // 失败返回错误码error.code并处理
      let err = error as BusinessError;
      LogUtils.error(CameraManager.name, `The setVideoStabilizationMode call failed. error code: ${err.code}`);
    }
  }

  /**
   * 对焦模式
   */
  setFocusMode(focusMode: camera.FocusMode): void {
    try {
      // 检测对焦模式是否支持
      let isSupported = this.session?.isFocusModeSupported(focusMode);
      LogUtils.debug(CameraManager.name, `setFocusMode isSupported: ${isSupported}`);
      // 设置对焦模式
      if (!isSupported) {
        return;
      }
      this.session?.setFocusMode(focusMode);
    } catch (error) {
      // 失败返回错误码error.code并处理
      let err = error as BusinessError;
      LogUtils.error(CameraManager.name, `The setFocusMode call failed. error code: ${err.code}`);
    }
  }

  /**
   * 设置曝光模式
   */
  setExposureMode(aeMode: camera.ExposureMode) {
    try {
      // 检测曝光模式是否支持
      let isSupported = this.session?.isExposureModeSupported(aeMode);
      LogUtils.debug(CameraManager.name, `setExposureMode isSupported: ${isSupported}`);
      // 设置曝光模式
      if (!isSupported) {
        return;
      }
      this.session?.setExposureMode(aeMode);
    } catch (error) {
      // 失败返回错误码error.code并处理
      let err = error as BusinessError;
      LogUtils.error(CameraManager.name, `The setExposureMode call failed. error code: ${err.code}`);
    }
  }

  /**
   * 创建视频录制
   * @returns
   */
  async createAVRecorder(): Promise<media.AVRecorder | undefined> {
    try {
      this.avRecorder = await media.createAVRecorder();
    } catch (error) {
      LogUtils.error(CameraCreateCore.name, `createAVRecorder error: ${error}`);
    }
    return this.avRecorder;
  }

  /**
   * 预创建视频录制
   * @param videoProfile
   * @param cameraDevice
   * @returns
   */
  async prepareAVRecorder(videoProfile: camera.VideoProfile, cameraDevice: camera.CameraDevice): Promise<void> {
    let fd = this.videoFile?.fd
    if (!fd) {
      return
    }
    let videoConfig: media.AVRecorderConfig = {
      audioSourceType: media.AudioSourceType.AUDIO_SOURCE_TYPE_MIC,
      videoSourceType: media.VideoSourceType.VIDEO_SOURCE_TYPE_SURFACE_YUV,
      profile: {
        audioBitrate: CameraConstants.AUDIO_BITRATE,
        audioChannels: CameraConstants.AUDIO_CHANNELS,
        audioCodec: media.CodecMimeType.AUDIO_AAC,
        audioSampleRate: CameraConstants.AUDIO_SAMPLE_RATE,
        fileFormat: media.ContainerFormatType.CFT_MPEG_4,
        videoBitrate: CameraConstants.VIDEO_BITRATE,
        videoCodec: media.CodecMimeType.VIDEO_AVC,
        videoFrameWidth: videoProfile.size.width,
        videoFrameHeight: videoProfile.size.height,
        videoFrameRate: videoProfile.frameRateRange.max
      },
      url: `fd://${fd.toString()}`,
      rotation: cameraDevice.cameraOrientation
    };
    LogUtils.debug(CameraCreateCore.name, `prepareAVRecorder videoConfig: ${JSON.stringify(videoConfig)}`);
    await this.avRecorder?.prepare(videoConfig).catch((err: BusinessError): void => {
      LogUtils.error(CameraCreateCore.name, `prepareAVRecorder prepare err: ${JSON.stringify(err)}`);
    });
  }

  /**
   * 拍照
   * @returns
   */
  takePicture(): Promise<boolean> {
    return new Promise<boolean>((resolve) => {
      let photoSettings: camera.PhotoCaptureSetting = {
        quality: camera.QualityLevel.QUALITY_LEVEL_HIGH
      };
      return this.photoOutput?.capture(photoSettings).then(() => {
        resolve(true)
      }).catch((err: BusinessError) => {
        LogUtils.error(CameraCreateCore.name, `takePicture error, code is ${err.code}, message is ${err.message}`);
        resolve(false)
      });
    })
  }

  setPictureCallback(callback: (image: PixelMap | null) => void): void {
    this.pictureCallback = callback;
  }

  async releaseCamera(): Promise<void> {
    try {
      await this.previewOutput?.release();
    } catch (error) {
      let err = error as BusinessError;
      LogUtils.error(CameraCreateCore.name, `previewOutput release fail: error: ${JSON.stringify(err)}`);
    } finally {
      this.previewOutput = undefined;
    }
    try {
      await this.photoOutput?.release();
    } catch (error) {
      let err = error as BusinessError;
      LogUtils.error(CameraCreateCore.name, `photoOutput release fail: error: ${JSON.stringify(err)}`);
    } finally {
      this.photoOutput = undefined;
    }
    try {
      await this.avRecorder?.release();
    } catch (error) {
      let err = error as BusinessError;
      LogUtils.error(CameraCreateCore.name, `avRecorder release fail: error: ${JSON.stringify(err)}`);
    } finally {
      this.avRecorder = undefined;
    }

    try {
      await this.videoOutput?.release();
    } catch (error) {
      let err = error as BusinessError;
      LogUtils.error(CameraCreateCore.name, `videoOutput release fail: error: ${JSON.stringify(err)}`);
    } finally {
      this.videoOutput = undefined;
    }
    try {
      await this.session?.release();
    } catch (error) {
      let err = error as BusinessError;
      LogUtils.error(CameraCreateCore.name, `captureSession release fail: error: ${JSON.stringify(err)}`);
    } finally {
      this.session = undefined;
    }
    try {
      await this.cameraInput?.close();
    } catch (error) {
      let err = error as BusinessError;
      LogUtils.error(CameraCreateCore.name, `cameraInput close fail: error: ${JSON.stringify(err)}`);
    } finally {
      this.cameraInput = undefined;
    }
    try {
      FileUtils.close(this.videoFile)
    } catch (error) {
      let err = error as BusinessError;
      LogUtils.error(CameraCreateCore.name, `close videoFile: error: ${JSON.stringify(err)}`);
    }
    this.offCameraStatusChange();
    LogUtils.debug(CameraCreateCore.name, 'releaseCamera success');
  }

  async stop(): Promise<void> {
    try {
      await this.session?.stop();
    } catch (error) {
      let err = error as BusinessError;
      LogUtils.error(CameraCreateCore.name, `captureSession stop fail: error: ${JSON.stringify(err)}`);
    } finally {
      this.session = undefined;
    }
    LogUtils.debug(CameraCreateCore.name, 'stop success');
  }

  /**
   * 拍照监听事件
   */
  onPhotoOutputCallBack() {
    try {
      // 监听拍照开始
      this.photoOutput?.on('captureStartWithInfo',
        (err: BusinessError, captureStartInfo: camera.CaptureStartInfo): void => {
          LogUtils.error(CameraManager.name,
            `photoOutputCallBack captureStartWithInfo success: ${JSON.stringify(captureStartInfo)}`);
        });
      // 监听拍照帧输出捕获
      this.photoOutput?.on('frameShutter', (err: BusinessError, frameShutterInfo: camera.FrameShutterInfo): void => {
        LogUtils.debug(CameraManager.name, `photoOutputCallBack frameShutter captureId:
          ${frameShutterInfo.captureId}, timestamp: ${frameShutterInfo.timestamp}`);
      });
      // 监听拍照结束
      this.photoOutput?.on('captureEnd', (err: BusinessError, captureEndInfo: camera.CaptureEndInfo): void => {
        LogUtils.debug(CameraManager.name, `photoOutputCallBack captureEnd captureId:
          ${captureEndInfo.captureId}, frameCount: ${captureEndInfo.frameCount}`);
      });
      // 监听拍照异常
      this.photoOutput?.on('error', (data: BusinessError): void => {
        LogUtils.debug(CameraManager.name, `photoOutPut data: ${JSON.stringify(data)}`);
      });
      //设置回调之后，调用photoOutput的capture方法，就会将拍照的buffer回传到回调中
      this.photoOutput?.on('photoAvailable', (err?: BusinessError, photo?: camera.Photo): void => {
        LogUtils.debug(CameraManager.name, 'getPhoto start');
        if (err) {
          LogUtils.error(CameraManager.name, `getPhoto failed failed: ${JSON.stringify(err)}`);
          return;
        }
        if (!photo) {
          LogUtils.error(CameraManager.name, `getPhoto failed failed photo 是空`);
          return;
        }
        let imageObj = photo.main;
        let imageType = image.ComponentType.JPEG
        imageObj.getComponent(imageType, (errCode?: BusinessError, component?: image.Component): void => {
          photo.release()
          LogUtils.debug(CameraManager.name, 'getComponent start');
          if (errCode) {
            LogUtils.error(CameraManager.name, `getComponent failed failed: ${JSON.stringify(errCode)}`);
            return;
          }
          if (!component) {
            LogUtils.error(CameraManager.name, `getComponent failed failed photo 是空`);
            return;
          }
          if (component.byteBuffer) {
            let aspectRatio = this.cameraManager.getCameraConfig().aspectRatio
            ImageUtils.getImagePixelMap(component.byteBuffer, aspectRatio).then(res => {
              this.pictureCallback(res)
            })
          } else {
            this.pictureCallback(null)
            LogUtils.error(CameraManager.name, `getComponent byteBuffer 是空`);
            return;
          }
        });
      });
      //注意photoAvailable和photoAvailable 不可共存，它俩的区别是photoAvailable 返回的是流，photoAssetAvailable是uri，图片会存储到相册里
      this.photoOutput?.on('photoAssetAvailable', (err: BusinessError, photoAsset: photoAccessHelper.PhotoAsset) => {
        LogUtils.error(CameraManager.name, 'photoAssetAvailable begin');
        if (photoAsset === undefined) {
          LogUtils.error(CameraManager.name, 'photoAsset is undefined');
          return;
        }
        // 请求图片资源数据
        let requestOptions: photoAccessHelper.RequestOptions = {
          deliveryMode: photoAccessHelper.DeliveryMode.HIGH_QUALITY_MODE,
        }
        photoAccessHelper.MediaAssetManager.requestImageData(getContext(), photoAsset, requestOptions, new MediaDataHandler());
        console.info('requestImageData successfully');
        // this.handlePhotoAssetCb(photoAsset);
      });
    } catch (err) {
      LogUtils.error(CameraManager.name, 'photoOutputCallBack error');
    }
  }


  /**
   * 监听预览事件
   */
  onPreviewOutputCallBack(): void {
    LogUtils.debug(CameraManager.name, 'previewOutputCallBack is called');
    try {
      this.previewOutput?.on('frameStart', (): void => {
        LogUtils.debug(CameraManager.name, 'Preview frame started');
      });
      this.previewOutput?.on('frameEnd', (): void => {
        LogUtils.error(CameraManager.name, 'Preview frame ended');
      });
      this.previewOutput?.on('error', (previewOutputError: BusinessError): void => {
        LogUtils.error(CameraManager.name, `Preview output previewOutputError: ${JSON.stringify(previewOutputError)}`);
      });
    } catch (err) {
      LogUtils.error(CameraManager.name, 'previewOutputCallBack error');
    }
  }

  /**
   * 监听相机状态变化
   * @param cameraManager - 相机管理器对象
   * @returns 无返回值
   */
  onCameraStatusChange(): void {
    try {
      this.cameraManager.getCameraManager()?.on('cameraStatus', this.getCameraStatusChange);
    } catch (error) {
      LogUtils.error(CameraManager.name, 'onCameraStatusChange error');
    }
  }

  /**
   * 停止监听相机状态变化
   * @returns 无返回值
   */
  offCameraStatusChange(): void {
    this.cameraManager.getCameraManager()?.off('cameraStatus', this.getCameraStatusChange);
  }


  /**
   * 获取缓存的回调函数
   * @param key
   * @returns
   */
  getCallback(key: string): AsyncCallback<void> {
    if (this.callbackMap.has(key)) {
      return this.callbackMap.get(key) as AsyncCallback<void>
    }
    let callback = (err: BusinessError) => {
      LogUtils.debug(CameraCreateCore.name, key + JSON.stringify(err));
    }
    this.callbackMap.set(key, callback)
    return callback
  }

  /**
   * 注册相机状态变化的回调函数
   * @param err - 错误信息（如果有）
   * @param cameraStatusInfo - 相机状态信息
   * @returns 无返回值
   */
  getCameraStatusChange(err: BusinessError, cameraStatusInfo: camera.CameraStatusInfo): void {
    LogUtils.debug(CameraCreateCore.name,
      `CameraStatusChange: err:${err},cameraId: ${cameraStatusInfo.camera.cameraId},status: ${cameraStatusInfo.status}`);
  }

  /**
   * 找到合适的配置文件
   * @param previewProfiles
   * @param cameraProfiles
   * @param minProfile
   * @returns
   */
  findSuitableProfile(previewProfiles: Array<CameraProfile>,
    cameraProfiles: Array<CameraProfile>, minProfile: CameraProfile): CameraProfile | undefined {
    let suitableProfiles = [...cameraProfiles].filter(x => [...previewProfiles]
      .some(y => y.size.width == x.size.width && y.size.height == x.size.height));

    let suitableProfile = suitableProfiles.find(profiles => profiles.size.width >= minProfile.size.width &&
      profiles.size.height >= minProfile.size.height)

    return suitableProfile
  }
}

class MediaDataHandler implements photoAccessHelper.MediaAssetDataHandler<ArrayBuffer> {
  onDataPrepared(data: ArrayBuffer) {
    if (data === undefined) {
      console.error('Error occurred when preparing data');
      return;
    }
    console.info('on image data prepared');
    // 应用自定义对资源数据的处理逻辑
  }
}