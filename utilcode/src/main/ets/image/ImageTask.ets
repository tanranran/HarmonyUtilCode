import { ImageCompressOptions } from './ImageCompressOptions';
import { ImageUtils } from './ImageUtils';
import { image } from '@kit.ImageKit';
import { ImageResult } from './ImageResult';


@Concurrent
export async function compressedImageAsync(source: image.PixelMap|ArrayBuffer, opt: ImageCompressOptions): Promise<ImageResult> {
  return await ImageUtils.compressedImage(source,opt);
}