/** 图片结果
 * @author Tanranran
 * @date 2024/7/15 16:25
 * @description
 */
import { image } from '@kit.ImageKit'
import { ImageInfo } from './ImageInfo'

export class ImageResult {
  arrayBuffer?: ArrayBuffer | null
  pixelMap?: image.PixelMap | null
  imageInfo?: ImageInfo = new ImageInfo()
  compressImageInfo?: ImageInfo = new ImageInfo()
  isOriginalPhoto?: boolean = false

  constructor() {
    this.imageInfo=new ImageInfo()
    this.compressImageInfo=new ImageInfo()
  }
}