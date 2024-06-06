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
      var decrypted = CryptoJS.DES.decrypt({
        ciphertext: CryptoJS.enc.Base64.parse(data)
      }, keyHex, {
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