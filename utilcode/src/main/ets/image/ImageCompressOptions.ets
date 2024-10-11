import { ImageMimeType } from './ImageUtils';


export class ImageCompressOptions {
  /** 压缩最大大小，单位为byte，默认为10MB */
  maxSize: number = 10*1000*1000;
  /** 压缩最大宽度，单位是px，默认是4000 */
  maxWidth: number = 4000;
  /** 压缩最大高度，单位是px，默认是4000 */
  maxHeight: number = 4000;
  /** 压缩图片格式，默认JPEG */
  format: ImageMimeType = ImageMimeType.JPG;
  /** 压缩质量，0-100，100为最佳，默认为80 */
  quality: number = 90;
}