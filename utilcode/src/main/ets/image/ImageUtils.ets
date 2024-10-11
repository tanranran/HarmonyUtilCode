import { image } from '@kit.ImageKit';
import { resourceManager } from '@kit.LocalizationKit';
import { Base64Util } from '../Base64Util';
import { BusinessError } from '@kit.BasicServicesKit';
import fs from '@ohos.file.fs';
import { FileUtils } from '../FileUtils';
import { StringUtils } from '../StringUtils';
import { ImageCompressOptions } from './ImageCompressOptions';
import { taskpool } from '@kit.ArkTS';
import { compressedImageAsync } from './ImageTask';
import { MD5Utils } from '../MD5Utils';
import { LogUtils } from '../LogUtils';
import { Utils } from '../Utils';
import { StopWatch } from '../StopWatch';
import { ImageResult } from './ImageResult';
import { NumberUtils } from '../NumberUtils';
import { ScreenUtils } from '../ScreenUtils';
import { dataSharePredicates } from '@kit.ArkData';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { ImageInfo } from './ImageInfo';
import fileIo from '@ohos.file.fs';

/**
 * 图片相关工具类
 * @author Tanranran
 * @date 2024/3/17 16:19
 * @description
 */
export class ImageUtils {
  private constructor() {
  }

  /**
   * 获取图片UID，用于对比两个PixelMap内容是否一致
   * @param pixelMap
   * @returns
   */
  static getImageUid(pixelMap?: PixelMap): string {
    try {
      if (pixelMap) {
        const buffer = new ArrayBuffer(pixelMap.getPixelBytesNumber());
        pixelMap.readPixelsToBufferSync(buffer);
        let md5 = MD5Utils.md5(buffer)
        return md5
      }
    } catch (e) {
      LogUtils.error(`${ImageUtils.name}_getImageUid`, e)
    }
    return ''
  }


  static getImagePixelMap(src?: string | Uint8Array | ArrayBuffer | number, cropRatio?: number) {
    return new Promise<PixelMap | null>(async (resolve) => {
      try {
        if (StringUtils.isEmpty(src)) {
          resolve(null)
          return
        }
        const stopWatch = new StopWatch()
        let imageSource: image.ImageSource
        if (src instanceof Uint8Array) {
          imageSource = ImageUtils.createImageSource(src.buffer);
        } else if (src instanceof ArrayBuffer) {
          imageSource = ImageUtils.createImageSource(src);
        } else if (NumberUtils.isNumber(src)) {
          imageSource = ImageUtils.createImageSource(src as number);
        } else {
          let path = src as string
          let fileExtention = FileUtils.getFileExtention(path)
          let uri = path
          if (FileUtils.isFile(path)) {
            uri = FileUtils.getUriFromPath(path ?? "")
          }
          let file = FileUtils.openSync(uri, fs.OpenMode.READ_ONLY)
          let sourceOptions: image.SourceOptions = {
            sourcePixelFormat: image.PixelMapFormat.RGBA_8888,
            sourceDensity: ScreenUtils.getDpi()
          };
          stopWatch.printElapsedTime(`getImagePixelMap_openSync`, true)
          if (fileExtention == 'jpg' || fileExtention == 'jpeg') {
            sourceOptions.sourcePixelFormat = image.PixelMapFormat.RGB_565
          }
          imageSource = ImageUtils.createImageSource(file.fd, sourceOptions);
          FileUtils.close(file)
        }
        stopWatch.printElapsedTime(`getImagePixelMap_createImageSource`, true)
        if (!imageSource) {
          resolve(null)
          return
        }
        let imageInfo = imageSource.getImageInfoSync()
        let imageSize = imageInfo.size
        let desiredPixelFormat = image.PixelMapFormat.RGBA_8888
        if (imageInfo && imageInfo.mimeType == ImageMimeType.JPG) {
          desiredPixelFormat = image.PixelMapFormat.RGB_565
        }
        console.log('图片原始宽高' + JSON.stringify(imageInfo.size))

        let desiredRegion: image.Region | undefined
        if (cropRatio) {
          desiredRegion =
            { x: 0, y: 0, size: { height: imageSize.width / cropRatio, width: imageSize.width } };
          desiredRegion.y = (imageSize.height - desiredRegion.size.height) / 2
          console.log('图片裁剪后宽高' + JSON.stringify(desiredRegion))
        }
        imageSource.createPixelMap({
          editable: true,
          desiredPixelFormat: desiredPixelFormat,
          desiredRegion: desiredRegion
        }).then((mPixelMap) => {
          resolve(mPixelMap);
        }).catch(() => {
          resolve(null)
        }).finally(() => {
          stopWatch.printElapsedTime(`getImagePixelMap_createPixelMap`)
        });
      } catch (e) {
        LogUtils.error(`${ImageUtils.name}_getImagePixelMap`, e)
        resolve(null)
      }
    });
  }

  static async getImageInfo(uri: string): Promise<ImageInfo> {
    const stopWatch = new StopWatch()
    let phAccessHelper = photoAccessHelper.getPhotoAccessHelper(Utils.getAbilityContext());
    let predicates = new dataSharePredicates.DataSharePredicates();
    predicates.equalTo('uri', uri);
    let fetchOption: photoAccessHelper.FetchOptions = {
      fetchColumns: [
        photoAccessHelper.PhotoKeys.WIDTH, photoAccessHelper.PhotoKeys.HEIGHT,
        photoAccessHelper.PhotoKeys.DISPLAY_NAME, photoAccessHelper.PhotoKeys.SIZE],
      predicates: predicates
    };
    let fetchResult = await phAccessHelper.getAssets(fetchOption);
    // 得到uri对应的PhotoAsset对象，读取文件的部分信息
    const asset: photoAccessHelper.PhotoAsset = await fetchResult.getFirstObject();
    const imageInfo = new ImageInfo()
    imageInfo.title = asset.displayName
    imageInfo.width = NumberUtils.toInt(asset.get(photoAccessHelper.PhotoKeys.WIDTH))
    imageInfo.height = NumberUtils.toInt(asset.get(photoAccessHelper.PhotoKeys.HEIGHT))
    stopWatch.printElapsedTime(`getImagePixelMap_getThumbnail`, true)
    return imageInfo
  }

  /**
   * 图片base64字符串转PixelMap
   * @param base64 图片base64字符串
   * @returns
   */
  static base64ToPixelMap(base64: string): Promise<image.PixelMap> {
    //将原始图片base64字符串转变为通过base64字符串
    const reg = new RegExp('data:image/\\w+;base64,');
    const base64Str = base64.replace(reg, '');
    //将通用base64字符串转变为arrayBuffer
    let arrayBuffer = Base64Util.decodeSync(base64Str).buffer;
    //将arrayBuffer转变为pixelMap
    let imageSource = image.createImageSource(arrayBuffer);
    let opts: image.DecodingOptions = { editable: false }
    //注意：这里return的是Promise，因此使用时需要在业务侧拿到最终的PixelMap
    return imageSource.createPixelMap(opts);
  }

  /**
   * 根据path或者uri获取文件Buffer
   * @param pathOrUri
   */
  static async getImageBufferFromPath(pathUri: string,
    format: string = 'image/jpeg'): Promise<ArrayBuffer | undefined> {
    return new Promise<ArrayBuffer | undefined>((resolve) => {
      try {
        const tag = '根据路径读取Buffer'
        const stopWatch = new StopWatch()
        let imageSource = ImageUtils.createImageSource(FileUtils.getFilePath(pathUri))
        stopWatch.printElapsedTime(`${tag}_createImageSource`, true)
        let packOpts: image.PackingOption = { format: format, quality: 95 }
        ImageUtils.packingFromImageSource(imageSource, packOpts).then(res => {
          stopWatch.printElapsedTime(`${tag}_packingFromImageSource`, true)
          resolve(res)
        }).catch((err: BusinessError) => {
          LogUtils.error(ImageUtils.name,
            `getImageBufferFromPath error, code is ${err.code}, message is ${err.message}`);
          resolve(undefined)
        }).finally(() => {
          imageSource.release()
          stopWatch.printElapsedTime(`${tag}_readSync`, true)
        })
      } catch (e) {
        LogUtils.error(FileUtils.name, e)
        resolve(undefined)
      }
    })
  }


  /**
   * PixelMap转图片base64字符串
   * @param pixelMap
   * @param format 目标格式,默认png,当前只支持jpg、webp和png。当传入的格式与文件格式不匹配，可能会导致生成错误的Base64字符串。
   * @returns
   */
  static async pixelMapToBase64Str(pixelMap: image.PixelMap): Promise<string> {
    try {
      let format = pixelMap.getImageInfoSync().mimeType
      let packOpts: image.PackingOption = { format: format, quality: 100 }
      const arrayBuffer = await ImageUtils.packingFromPixelMap(pixelMap, packOpts);
      let base64Str: string = Base64Util.encodeToStrSync(new Uint8Array(arrayBuffer));
      let headStr = `data:${format};base64,`;
      if (!base64Str.startsWith(headStr)) {
        base64Str = headStr + base64Str
      }
      return base64Str;
    } catch (err) {
      let error = err as BusinessError;
      LogUtils.error(ImageUtils.name,
        `ImageUtil-pixelMapToBase64Str-异常 ~ code: ${error.code} -·- message: ${error.message}`);
      return '';
    }
  }


  /**
   * 保存pixelMap到本地
   * @param pixelMap PixelMap
   * @param path 文件夹路径
   * @param name 文件名
   * @param format 目标格式。默认png。当前只支持jpg（image/jpeg）、webp和png（image/png）。
   * @returns
   */
  static async savePixelMap(pixelMap: image.PixelMap, path: string, name: string,
    format: string = 'image/png'): Promise<string> {
    try {
      if (!FileUtils.accessSync(path)) {
        FileUtils.mkdirSync(path) //如果文件夹不存在就创建
      }
      let filePath = path + FileUtils.separator + name;
      let file = FileUtils.openSync(filePath)
      let packOpts: image.PackingOption = { format: format, quality: 100 }
      await ImageUtils.packToFileFromPixelMap(pixelMap, file.fd, packOpts)
      FileUtils.closeSync(file.fd) //关闭文件
      return filePath;
    } catch (err) {
      let error = err as BusinessError;
      LogUtils.error(ImageUtils.name,
        `ImageUtil-savePixelMap-异常 ~ code: ${error.code} -·- message: ${error.message}`);
      return '';
    }
  }


  /**
   * 保存ImageSource到本地
   * @param pixelMap PixelMap
   * @param path 文件夹路径
   * @param name 文件名
   * @param format 目标格式。默认png。当前只支持jpg（image/jpeg）、webp和png（image/png）。
   * @returns
   */
  static async saveImageSource(source: image.ImageSource, path: string, name: string,
    format: string = 'image/png'): Promise<string> {
    try {
      if (!FileUtils.accessSync(path)) {
        FileUtils.mkdirSync(path) //如果文件夹不存在就创建
      }
      let filePath = path + FileUtils.separator + name;
      let file = FileUtils.openSync(filePath)
      let packOpts: image.PackingOption = { format: format, quality: 100 }
      await ImageUtils.packToFileFromImageSource(source, file.fd, packOpts)
      FileUtils.closeSync(file.fd) //关闭文件
      return filePath;
    } catch (err) {
      let error = err as BusinessError;
      LogUtils.error(ImageUtils.name,
        `ImageUtil-saveImageSource-异常 ~ code: ${error.code} -·- message: ${error.message}`);
      return '';
    }
  }

  /**
   * 保存图片到相册
   */
  static async saveImageToPhotoAlbum(buffer?: ArrayBuffer): Promise<number> {
    if (!buffer) {
      return -1
    }
    let helper = photoAccessHelper.getPhotoAccessHelper(Utils.getAbilityContext());
    // onClick触发后10秒内通过createAsset接口创建图片文件，10秒后createAsset权限收回。
    let photoType: photoAccessHelper.PhotoType = photoAccessHelper.PhotoType.IMAGE;
    let extension:string = 'jpg';
    let options: photoAccessHelper.CreateOptions = {
      // title: 'testPhoto'
    }
    let uri = await helper.createAsset(photoType, extension, options);
    return FileUtils.writeEasy(uri, buffer, false)
  }

  /**
   * 创建图片源实例
   * @param src（联合类型: string、number、ArrayBuffer、resourceManager.RawFileDescriptor）
   *   path string 图片路径，当前仅支持应用沙箱路径。当前支持格式有：.jpg .png .gif .bmp .webp RAW SVG10+ .ico11+。
   *   fd  number 文件描述符fd。
   *   buf  ArrayBuffer  图像缓冲区数组。
   *   rawfile resourceManager.RawFileDescriptor 图像资源文件的RawFileDescriptor。
   * options SourceOptions  图片属性，包括图片像素密度、像素格式和图片尺寸。
   *   sourceDensity  number ImageSource的密度。
   *   sourcePixelFormat  PixelMapFormat 图片像素格式。
   *   sourceSize  Size 图像像素大小。
   * @returns
   */
  static createImageSource(src: string | number | ArrayBuffer | resourceManager.RawFileDescriptor,
    options?: image.SourceOptions): image.ImageSource {
    if (typeof src === 'string') {
      if (options) {
        return image.createImageSource(src, options);
      } else {
        return image.createImageSource(src);
      }
    } else if (typeof src === 'number') {
      if (options) {
        return image.createImageSource(src, options);
      } else {
        return image.createImageSource(src);
      }
    } else if (src instanceof ArrayBuffer) {
      if (options) {
        return image.createImageSource(src, options);
      } else {
        return image.createImageSource(src);
      }
    } else {
      if (options) {
        return image.createImageSource(src, options);
      } else {
        return image.createImageSource(src);
      }
    }
  }


  /**
   * 图片压缩或重新打包，使用Promise形式返回结果。
   * @param source PixelMap-打包的PixelMap资源。
   * @param options 设置打包参数:
   *   format 目标格式。当前只支持jpg（image/jpeg）、webp 和 png（image/png）。
   *   quality JPEG编码中设定输出图片质量的参数，取值范围为0-100。
   *   bufferSize 接收编码数据的缓冲区大小，单位为Byte。默认为10MB。bufferSize需大于编码后图片大小。
   * @returns
   */
  static packingFromPixelMap(source: image.PixelMap, options?: image.PackingOption): Promise<ArrayBuffer> {
    const imagePacker: image.ImagePacker = image.createImagePacker();
    let _options: image.PackingOption
    if (options) {
      _options = options
    } else {
      _options = { format: source.getImageInfoSync().mimeType, quality: 100 }
    }
    _options.bufferSize = 50 * 1000 * 1000
    return imagePacker.packing(source, _options).finally(() => {
      imagePacker.release(); //释放
    });
  }


  /**
   * 图片压缩或重新打包，使用Promise形式返回结果。
   * @param source ImageSource-打包的图片源。
   * @param options 设置打包参数:
   *   format 目标格式。当前只支持jpg（image/jpeg）、webp 和 png（image/png）。
   *   quality JPEG编码中设定输出图片质量的参数，取值范围为0-100。
   *   bufferSize 接收编码数据的缓冲区大小，单位为Byte。默认为10MB。bufferSize需大于编码后图片大小。
   * @returns
   */
  static packingFromImageSource(source: image.ImageSource, options: image.PackingOption): Promise<ArrayBuffer> {
    const imagePacker: image.ImagePacker = image.createImagePacker();
    options.bufferSize = 50 * 1000 * 1000
    return imagePacker.packing(source as image.ImageSource, options).finally(() => {
      imagePacker.release(); //释放
    });
  }


  /**
   * 将PixelMap图片源编码后直接打包进文件。
   * @param source PixelMap-打包的PixelMap资源。
   * @param fd 文件描述符。
   * @param option 设置打包参数:
   *   format 目标格式。当前只支持jpg（image/jpeg）、webp 和 png（image/png）。
   *   quality JPEG编码中设定输出图片质量的参数，取值范围为0-100。
   *   bufferSize 接收编码数据的缓冲区大小，单位为Byte。默认为10MB。bufferSize需大于编码后图片大小。
   * @returns
   */
  static packToFileFromPixelMap(source: image.PixelMap, fd: number, options: image.PackingOption): Promise<void> {
    const imagePacker: image.ImagePacker = image.createImagePacker();
    options.bufferSize = 50 * 1000 * 1000
    return imagePacker.packToFile(source, fd, options).finally(() => {
      imagePacker.release(); //释放
    });
  }


  /**
   * 将ImageSource图片源编码后直接打包进文件。
   * @param source ImageSource-打包的图片源。
   * @param fd 文件描述符。
   * @param option 设置打包参数:
   *   format 目标格式。当前只支持jpg（image/jpeg）、webp 和 png（image/png）。
   *   quality JPEG编码中设定输出图片质量的参数，取值范围为0-100。
   *   bufferSize 接收编码数据的缓冲区大小，单位为Byte。默认为10MB。bufferSize需大于编码后图片大小。
   * @returns
   */
  static packToFileFromImageSource(source: image.ImageSource, fd: number, options: image.PackingOption): Promise<void> {
    const imagePacker: image.ImagePacker = image.createImagePacker();
    options.bufferSize = 50 * 1000 * 1000
    return imagePacker.packToFile(source, fd, options).finally(() => {
      imagePacker.release(); //释放
    });
  }


  /**
   * 用户获取resource目录下的media中的图片PixelMap
   * @param resource 例如：$r("app.media.icon"
   * @returns
   */
  static async getPixelMapFromMedia(resource: Resource): Promise<image.PixelMap> {
    let resourceManager = Utils.getAbilityContext().resourceManager;
    let uint8Array = resourceManager.getMediaContentSync(resource);
    return await ImageUtils.createImageSource(uint8Array.buffer).createPixelMap();
  }

  /**
   * 拷贝pixelMap
   * @param pm
   * @returns
   */
  static async copyPixelMap(pm: PixelMap): Promise<PixelMap> {
    const imageInfo: image.ImageInfo = await pm.getImageInfo();
    const buffer: ArrayBuffer = new ArrayBuffer(pm.getPixelBytesNumber());
    await pm.readPixelsToBuffer(buffer);
    const opts: image.InitializationOptions = {
      editable: true,
      pixelFormat: image.PixelMapFormat.RGBA_8888,
      size: { height: imageInfo.size.height, width: imageInfo.size.width }
    };
    return image.createPixelMap(buffer, opts);
  }

  // PixelMap 转ArrayBuffer
  static pixelMapToArrayBuffer(pixel: PixelMap) {
    try {
      let buf = new ArrayBuffer(pixel.getPixelBytesNumber())
      pixel.readPixelsToBufferSync(buf)
    } catch (error) {
      let code = (error as BusinessError).code;
      let message = (error as BusinessError).message;
      LogUtils.error(ImageUtils.name,
        `pixelMapToArrayBuffer failed, error code: ${code}, message: ${message}.`);
    }
  }

  /**
   * 压缩图片
   * @param sourcePixelMap：原始待压缩图片
   * @param opt：图片压缩参数
   * @returns compressedImageData：返回压缩后的图片流数据
   */
  static async compressedImage(source: image.PixelMap | ArrayBuffer,
    opt: ImageCompressOptions): Promise<ImageResult> {
    let imageResult = new ImageResult()
    try {
      const stopWatch = new StopWatch()
      let sourcePixelMap: image.PixelMap | null
      let compressedImageData: ArrayBuffer | undefined = undefined
      if (source instanceof ArrayBuffer) {
        compressedImageData = source
        sourcePixelMap = await ImageUtils.getImagePixelMap(compressedImageData)
      } else {
        sourcePixelMap = source
        compressedImageData = await ImageUtils.packingFromPixelMap(sourcePixelMap, opt);
      }
      if (!sourcePixelMap) {
        return imageResult
      }
      imageResult.imageInfo!.size = compressedImageData?.byteLength
      stopWatch.printElapsedTime("1_图片解码", true)
      let imageInfo = sourcePixelMap.getImageInfoSync()
      let imageWidth = imageInfo.size.width;
      let imageHeight = imageInfo.size.height;
      const maxWidth = opt.maxWidth ?? 4000
      const maxHeight = opt.maxHeight ?? 4000
      imageResult.imageInfo!.width = imageWidth
      imageResult.imageInfo!.height = imageHeight
      stopWatch.printElapsedTime(`2_图片信息读取_${imageWidth}_${imageHeight} 大小${compressedImageData?.byteLength}`,
        true)

      const maxCompressedImageByte = opt.maxSize;

      //① 压缩到指定宽高
      if (imageWidth > maxWidth || imageHeight > maxHeight) {
        let scale = 0;
        if (imageWidth > imageHeight) {
          scale = maxWidth / imageWidth;
        } else {
          scale = maxHeight / imageHeight;
        }
        sourcePixelMap.scaleSync(scale, scale)
        stopWatch.printElapsedTime(`3_图片压缩指定宽高前_${imageWidth}_${imageHeight} 大小${compressedImageData?.byteLength}`,
          true)
        imageInfo = sourcePixelMap.getImageInfoSync()
        imageWidth = imageInfo.size.width;
        imageHeight = imageInfo.size.height;
        compressedImageData = await ImageUtils.packingFromPixelMap(sourcePixelMap, opt);
        stopWatch.printElapsedTime(`3_图片压缩指定宽高后_${imageWidth}_${imageHeight} 大小${compressedImageData?.byteLength}`,
          true)
      }

      //② 图片数据读取
      if (!compressedImageData) {
        compressedImageData = await ImageUtils.packingFromPixelMap(sourcePixelMap, opt);
        stopWatch.printElapsedTime(`2.2_图片信息读取_${imageWidth}_${imageHeight} 大小${compressedImageData?.byteLength}`,
          true)
      }

      //③ 压缩到指定大小
      stopWatch.reset()
      if (compressedImageData && compressedImageData.byteLength > maxCompressedImageByte) {
        // 图片质量参数范围为0-100，这里以10为最小二分单位创建用于packing二分图片质量参数的数组。
        const packingArray: number[] = [];
        const DICHOTOMY_ACCURACY = 10;
        const packingOption: image.PackingOption = { format: opt.format, quality: opt.quality }
        // 性能知识点: 如果对图片压缩质量要求不高，建议调高最小二分单位dichotomyAccuracy，减少循环，提升packing压缩性能。
        for (let i = 0; i <= 100; i += DICHOTOMY_ACCURACY) {
          packingArray.push(i);
        }
        let left = 0; // 定义二分搜索范围的左边界
        let right = packingArray.length - 1; // 定义二分搜索范围的右边界
        // 二分压缩图片
        while (left <= right) {
          const mid = Math.floor((left + right) / 2); // 定义二分搜索范围的中间位置
          packingOption.quality = packingArray[mid]; // 获取二分中间位置的图片质量值
          // 根据传入的图片质量参数进行packing压缩，返回压缩后的图片文件流数据。
          compressedImageData =
            await ImageUtils.packingFromPixelMap(sourcePixelMap, packingOption);
          // 判断查找一个尽可能接近但不超过压缩目标的压缩大小
          if (compressedImageData.byteLength <= maxCompressedImageByte) {
            // 二分目标值在右半边，继续在更高的图片质量参数（即mid + 1）中搜索
            left = mid + 1;
            // 判断mid是否已经二分到最后，如果二分完了，退出
            if (mid === packingArray.length - 1) {
              break;
            }
            packingOption.quality = packingArray[mid + 1]
            // 获取下一次二分的图片质量参数（mid+1）压缩的图片文件流数据
            compressedImageData = await ImageUtils.packingFromPixelMap(sourcePixelMap, packingOption);

            // 判断用下一次图片质量参数（mid+1）压缩的图片大小是否大于指定图片的压缩目标大小。如果大于，说明当前图片质量参数（mid）压缩出来的
            // 图片大小最接近指定图片的压缩目标大小。传入当前图片质量参数mid，得到最终目标图片压缩数据。
            if (compressedImageData.byteLength > maxCompressedImageByte) {
              packingOption.quality = packingArray[mid]
              compressedImageData = await ImageUtils.packingFromPixelMap(sourcePixelMap, packingOption);
              break;
            }
          } else {
            // 目标值不在当前范围的右半部分，将搜索范围的右边界向左移动，以缩小搜索范围并继续在下一次迭代中查找左半部分。
            right = mid - 1;
          }
        }
        //算法二，和算法一比起来，大约耗时20%
        // let options: image.PackingOption = { format: opt.format, quality: opt.quality }
        // while (compressedImageData.byteLength > maxCompressedImageByte) {
        //   options.quality -= 10
        //   compressedImageData = await ImageUtils.packingFromPixelMap(sourcePixelMap, options);
        //   if (options.quality <= 5) {
        //     break
        //   }
        // }
        stopWatch.printElapsedTime(`5_图片压缩到指定大小 大小${compressedImageData?.byteLength}`)
      }

      //④ 判断压缩后的图片大小是否大于指定图片的压缩目标大小，如果大于，继续降低缩放倍数压缩。
      stopWatch.reset()
      if (compressedImageData && compressedImageData.byteLength > maxCompressedImageByte) {
        let imageScale = 1; // 定义图片宽高的缩放倍数，1表示原比例。
        while (compressedImageData && compressedImageData.byteLength > maxCompressedImageByte) {
          if (imageScale > 0) {
            imageScale = imageScale - 0.1; // 每次缩放倍数减0.1
            sourcePixelMap = await ImageUtils.getImagePixelMap(compressedImageData)
            sourcePixelMap?.scaleSync(imageScale, imageScale)
            if (sourcePixelMap) {
              compressedImageData =
                await ImageUtils.packingFromPixelMap(sourcePixelMap, { format: opt.format, quality: 100 });
            }
          } else {
            break;
          }
        }
        stopWatch.printElapsedTime(`6_图片压缩到指定倍数 大小${compressedImageData?.byteLength}`)
      }

      if (compressedImageData) {
        imageResult.compressImageInfo!.size = compressedImageData?.byteLength
      }
      stopWatch.reset()
      imageResult.arrayBuffer = compressedImageData
      imageResult.pixelMap = await ImageUtils.getImagePixelMap(compressedImageData)
      stopWatch.printElapsedTime('7_图片编码')
      if (imageResult.pixelMap) {
        imageInfo = imageResult.pixelMap?.getImageInfoSync()
        if (imageInfo) {
          imageWidth = imageInfo.size.width;
          imageHeight = imageInfo.size.height;
          imageResult.compressImageInfo!.width = imageWidth
          imageResult.compressImageInfo!.height = imageHeight
          console.log(`压缩完后图片:宽高${imageWidth}_${imageHeight} 大小${compressedImageData?.byteLength}`)
        }
      }
      stopWatch.printElapsedTime("8_压缩图片总耗时")
      return imageResult;
    } catch (error) {
      let code = (error as BusinessError).code;
      let message = (error as BusinessError).message;
      LogUtils.error(ImageUtils.name,
        `callback compressedImage failed, error code: ${code}, message: ${message}.`);
    }
    return imageResult
  }

  /**
   * 压缩图片
   * @param sourcePixelMap：原始待压缩图片
   * @param opt：图片压缩参数
   */
  static compressedImageAsync(source: image.PixelMap | ArrayBuffer,
    opt?: ImageCompressOptions): Promise<ImageResult | undefined> {
    return new Promise<ImageResult | undefined>(async (resolve) => {
      try {
        let compressOptions = opt ?? new ImageCompressOptions()
        let arrayBuffer: ArrayBuffer
        if (source instanceof ArrayBuffer) {
          arrayBuffer = source
        } else {
          arrayBuffer = await ImageUtils.packingFromPixelMap(source);
        }
        let task: taskpool.Task = new taskpool.Task(compressedImageAsync, arrayBuffer, compressOptions);
        task.setCloneList([arrayBuffer]);
        taskpool.execute(task, taskpool.Priority.HIGH).then((res?: ImageResult) => {
          LogUtils.debug(ImageUtils.name, `compressedImageAsync 成功` + res?.toString())
          resolve(res)
        }).catch((e: BusinessError) => {
          LogUtils.error(ImageUtils.name,
            `compressedImageAsyncTask 失败, error code: ${e.code}, message: ${e.message}.`);
          resolve(undefined)
        });
      } catch (e) {
        LogUtils.error(ImageUtils.name,
          `compressedImageAsync 失败, error code: ${e.code}, message: ${e.message}.`);
        resolve(undefined)
      }
    })
  }


  static createPixelMap() {
    let opts: image.InitializationOptions = { editable: true, pixelFormat: 3, size: { height: 4, width: 6 } }
    const color: ArrayBuffer = new ArrayBuffer(96);
    let pixelMap: image.PixelMap = image.createPixelMapSync(color, opts);
    return pixelMap
  }
}

export enum ImageMimeType {
  JPG = 'image/jpeg',
  JPEG = 'image/jpeg',
  PNG = 'image/png',
  GIF = 'image/gif',
  WEBP = 'image/webp'
}


