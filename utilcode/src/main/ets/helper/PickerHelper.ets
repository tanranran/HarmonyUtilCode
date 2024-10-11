/**
 * @author Tanranran
 * @date 2024/7/16 14:28
 * @description
 */
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { BusinessError } from '@kit.BasicServicesKit';
import picker from '@ohos.multimedia.cameraPicker';
import camera from '@ohos.multimedia.camera';
import { Utils } from '../Utils';
import { LogUtils } from '../LogUtils';
import { FileUtils } from '../FileUtils';
import { ImageUtils } from '../image/ImageUtils';
import { ImageResult } from '../image/ImageResult';
import { StopWatch } from '../StopWatch';
import { ImageCompressOptions } from '../image/ImageCompressOptions';

export class PickerOptions {
  MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE; // 过滤选择媒体文件类型为IMAGE
  maxSelectNumber = 9; // 选择媒体文件的最大数目
  isPhotoTakingSupported = true //是否支持拍照，true表示支持，false表示不支持，默认为true。
  isSearchSupported = true //是否支持搜索，true表示支持，false表示不支持，默认为true。
  isEditSupported = true //是否支持编辑照片，true表示支持，false表示不支持，默认为true。
  // recommendationOptions?: photoAccessHelper.RecommendationOptions;//图片推荐选项(基于图片数据分析结果，依赖设备适配)。
  returnPixelMap: boolean = true
  isCompress: boolean = true
  compressOptions: ImageCompressOptions = new ImageCompressOptions()
}

export class PickerHelper {
  static selectPhoto(options: PickerOptions = new PickerOptions()) {
    return new Promise<Array<ImageResult>>((resolve) => {
      let imageResults = new Array<ImageResult>()
      const photoViewPicker = new photoAccessHelper.PhotoViewPicker();
      photoViewPicker.select(options).then(async (photoSelectResult: photoAccessHelper.PhotoSelectResult) => {
        for (let i = 0; i < photoSelectResult.photoUris.length; i++) {
          const uri = photoSelectResult.photoUris[i]
          let imageResult = new ImageResult()
          imageResult = await PickerHelper.getImageResult(options, uri, imageResult)
          imageResults.push(imageResult)
        }
        resolve(imageResults)
      }).catch((err: BusinessError) => {
        LogUtils.error(PickerHelper.name, `selectPhoto failed, code is ${err.code}, message is ${err.message}`);
        resolve(imageResults)
      })
    })
  }

  /**
   * 拍摄图片
   * @param returnPixelMap 是否返回returnPixelMap
   * @param isCompress 是否压缩图片
   * @returns
   */
  static takePhoto(options: PickerOptions = new PickerOptions()): Promise<ImageResult> {
    return new Promise<ImageResult>((resolve) => {
      let takePhotoPath = FileUtils.getCacheDirPath('takePhoto', 'takePhoto.jpg')
      let file = FileUtils.mkFile(takePhotoPath)
      let takePhotoUri = FileUtils.getUriFromPath(file.path)
      let pickerProfile: picker.PickerProfile = {
        cameraPosition: camera.CameraPosition.CAMERA_POSITION_BACK,
        saveUri: takePhotoUri,
      };
      let mediaTypes = [picker.PickerMediaType.PHOTO]
      let imageResult = new ImageResult()
      picker.pick(Utils.getAbilityContext(), mediaTypes, pickerProfile).then(async result => {
        if (result && result.resultCode == 0) {
          const stopWatch = new StopWatch()
          imageResult = await PickerHelper.getImageResult(options, result.resultUri, imageResult)
          stopWatch.printElapsedTime("takePhoto 处理完毕")
        }
        FileUtils.removeFile(result.resultUri)
        LogUtils.debug(PickerHelper.name, JSON.stringify(result))
        resolve(imageResult)
      }).catch((err: BusinessError) => {
        LogUtils.error(PickerHelper.name, `takePhoto failed, code is ${err.code}, message is ${err.message}`);
      }).finally(() => {
        FileUtils.close(file)
      })
    })
  }

  private static async getImageResult(options: PickerOptions, uri: string, imageResult: ImageResult) {
    if (options.returnPixelMap) {
      imageResult.pixelMap = await ImageUtils.getImagePixelMap(uri)
      if (options.isCompress && imageResult.pixelMap) {
        imageResult = await ImageUtils.compressedImage(imageResult.pixelMap, options.compressOptions)
      }
    } else {
      imageResult.arrayBuffer = await ImageUtils.getImageBufferFromPath(uri)
      if (options.isCompress && imageResult.arrayBuffer) {
        imageResult = await ImageUtils.compressedImage(imageResult.arrayBuffer, options.compressOptions)
      }
    }
    return imageResult
  }
}