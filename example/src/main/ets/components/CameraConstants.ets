/**
 * @author Tanranran
 * @date 2024/7/22 17:25
 * @description
 */
import { camera } from '@kit.CameraKit';

export type CameraProfile = camera.Profile | camera.VideoProfile

export class CameraConstants {
  // 推荐拍照分辨率之一
  static photoProfile: camera.Profile = {
    format: camera.CameraFormat.CAMERA_FORMAT_JPEG,
    size: {
      width: 1280,
      height: 720
    }
  };
  // 推荐预览分辨率之一
  static previewProfile: camera.Profile = {
    format: camera.CameraFormat.CAMERA_FORMAT_YUV_420_SP,
    size: {
      width: 1280,
      height: 720
    }
  };
  //预览宽高比
  static previewRatio = CameraConstants.previewProfile.size.width / CameraConstants.previewProfile.size.height
  // 推荐录像分辨率之一
  static videoProfile: camera.VideoProfile = {
    format: camera.CameraFormat.CAMERA_FORMAT_YUV_420_SP,
    size: {
      width: 1280,
      height: 720
    },
    frameRateRange: {
      min: 30,
      max: 60
    }
  };
  //拍摄比例
  static readonly AspectRatios = [0.75, 1, 1.33] //3/4,1/1,4/3
  /**
   * VIDEO_FRAME.
   */
  static readonly MAX_VIDEO_FRAME: number = 60;
  /**
   * AUDIO_BITRATE.
   */
  static readonly AUDIO_BITRATE: number = 48000;
  /**
   * AUDIO_CHANNELS.
   */
  static readonly AUDIO_CHANNELS: number = 2;
  /**
   * AUDIO_SAMPLE_RATE.
   */
  static readonly AUDIO_SAMPLE_RATE: number = 48000;
  /**
   * VIDEO_BITRATE.
   */
  static readonly VIDEO_BITRATE: number = 512000;
}