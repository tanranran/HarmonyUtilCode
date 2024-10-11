import { cryptoFramework } from '@kit.CryptoArchitectureKit';
import { buffer } from '@kit.ArkTS';
import { LogUtils } from './LogUtils';

/**
 * 系统加解密工具类
 * @author Tanranran
 * @date 2024/7/9 21:59
 * @description
 */
type HashType = 'SHA1' | 'SHA224' | 'SHA256' | 'SHA384' | 'SHA512' | 'MD5' | 'SM3'

export class CryptoUtils {
  /**
   * 消息摘要HASH 算法
   * https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V5/crypto-generate-message-digest-V5#%E6%94%AF%E6%8C%81%E7%9A%84%E7%AE%97%E6%B3%95%E4%B8%8E%E8%A7%84%E6%A0%BC
   * @param message
   * @param hashType
   * @returns
   */
  static hash(message: string | ArrayBuffer, hashType: HashType): string {
    try {
      let md = cryptoFramework.createMd(hashType);
      let messageData: Uint8Array = new Uint8Array();
      if (message instanceof ArrayBuffer) {
        messageData = new Uint8Array(message)
      } else {
        messageData = new Uint8Array(buffer.from(message, 'utf-8').buffer)
      }
      let dataBlob: cryptoFramework.DataBlob = {
        data: messageData
      }
      md.updateSync(dataBlob)
      let mdResult = md.digestSync();
      let bufferStr = buffer.from(mdResult.data).toString('hex');
      return bufferStr
    } catch (e) {
      LogUtils.error(`${CryptoUtils.name}_hash`, e)
      return ''
    }
  }
}
