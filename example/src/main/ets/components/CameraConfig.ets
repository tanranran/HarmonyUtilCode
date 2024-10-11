/**
 * @author Tanranran
 * @date 2024/7/18 16:57
 * @description
 */
import { camera } from '@kit.CameraKit'
import { CameraConstants } from './CameraConstants'


export class CameraConfig {
  frontCameraDevice?: camera.CameraDevice //前置摄像头
  backCameraDevice?: camera.CameraDevice // 后置摄像头
  cameraDeviceList: Array<camera.CameraDevice> = [] //设备列表
  aspectRatio: number = CameraConstants.AspectRatios[0] //拍摄比例
  sceneMode: camera.SceneMode = camera.SceneMode.NORMAL_PHOTO
  isFrontCamera = false //是否是前置摄像头

  default() {
    this.isFrontCamera = false
  }

  /**
   * 设置拍摄场景【拍照/录像】
   * @param sceneMode
   */
  setSceneMode(sceneMode: camera.SceneMode) {
    this.sceneMode = sceneMode
  }

  /**
   * 切换比例
   * @param sceneMode
   */
  switchAspectRatio() {
    let aspectRatios = CameraConstants.AspectRatios
    let nextIndex = 0
    for (let i = 0; i < aspectRatios.length; i++) {
      if (aspectRatios[i] == this.aspectRatio) {
        nextIndex = i + 1
        if (nextIndex > (aspectRatios.length - 1)) {
          nextIndex = 0
        }
        break
      }
    }
    this.aspectRatio = aspectRatios[nextIndex]
    return this.aspectRatio
  }

  /**
   * 设置前后摄像头
   * @param sceneMode
   */
  switchCamera() {
    this.isFrontCamera = !this.isFrontCamera
  }


  /**
   * 设置支持的摄像头列表
   * @param cameraDeviceList
   */
  setCameraDeviceList(cameraDeviceList: Array<camera.CameraDevice>) {
    this.cameraDeviceList = cameraDeviceList
    if (this.cameraDeviceList.length == 0) {
      return
    }
    for (const cameraDevice of cameraDeviceList) {
      if (cameraDevice.cameraPosition == camera.CameraPosition.CAMERA_POSITION_BACK) { //默认后置摄像头
        this.backCameraDevice = cameraDevice
      } else if (cameraDevice.cameraPosition == camera.CameraPosition.CAMERA_POSITION_FRONT) { //前置摄像头
        this.frontCameraDevice = cameraDevice
      }
    }
    if (!this.backCameraDevice) {
      this.backCameraDevice = cameraDeviceList[0]
    }
  }

  /**
   * 获取当前摄像头
   * @returns
   */
  getCameraDevice(): camera.CameraDevice | undefined {
    if (this.backCameraDevice && this.frontCameraDevice) {
      if (this.isFrontCamera) {
        return this.frontCameraDevice
      } else {
        return this.backCameraDevice
      }
    } else {
      if (this.backCameraDevice) {
        return this.backCameraDevice
      } else {
        return this.frontCameraDevice
      }
    }
    return undefined
  }

  /**
   * 是否支持前置摄像头
   * @returns
   */
  isSupportFront() {
    return this.backCameraDevice && this.frontCameraDevice
  }


  /**
   * 是否支持拍照
   */
  isSupportTakePhoto(cameraManager?: camera.CameraManager) {
    const cameraDevice = this.getCameraDevice()
    if (!cameraDevice || !cameraManager) {
      return false
    }
    return cameraManager.getSupportedSceneModes(cameraDevice).indexOf(camera.SceneMode.NORMAL_PHOTO) >= 0;
  }

  /**
   * 是否支持录像
   */
  isSupportTakeVideo(cameraManager?: camera.CameraManager) {
    const cameraDevice = this.getCameraDevice()
    if (!cameraDevice || !cameraManager) {
      return false
    }
    return cameraManager.getSupportedSceneModes(cameraDevice).indexOf(camera.SceneMode.NORMAL_VIDEO) >= 0;
  }
}