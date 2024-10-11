import { CryptoJS } from '@ohos/crypto-js'

/**
 * DES加解密工具
 * @author Tanranran
 * @date 2024/6/06 22:18
 * @description
 */
export class DESUtils {
  static encode(key, data): string {
    try {
      let keyHex = CryptoJS.enc.Utf8.parse(key);
      var encrypted = CryptoJS.DES.encrypt(data, keyHex, {
        mode: CryptoJS.mode.ECB,
        padding: CryptoJS.pad.Pkcs7
      });
      return encrypted.toString()
    } catch (e) {
      console.error(e)
    }
    return ""
  }

  static decode(key, data): string {
    try {
      var keyHex = CryptoJS.enc.Utf8.parse(key);
      let ciphertext: CryptoJS.lib.CipherParams = {
        ciphertext: CryptoJS.enc.Base64.parse(data),
        key: undefined,
        iv: undefined,
        salt: undefined,
        algorithm: undefined,
        mode: undefined,
        padding: undefined,
        blockSize: 0,
        formatter: undefined
      }
      var decrypted = CryptoJS.DES.decrypt(ciphertext, keyHex, {
        mode: CryptoJS.mode.ECB,
        padding: CryptoJS.pad.Pkcs7
      });
      return decrypted.toString(CryptoJS.enc.Utf8);
    } catch (e) {
      console.error(e)
    }
    return ""
  }
}