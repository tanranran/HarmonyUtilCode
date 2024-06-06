import { CryptoJS } from '@ohos/crypto-js'

/**
 * @author Tanranran
 * @date 2024/6/6 22:05
 * @description
 */
export class AESUtils {
  static encode(_key, _data) {
    try {
      let key = CryptoJS.enc.Utf8.parse(_key);
      let data = CryptoJS.enc.Utf8.parse(_data);
      let encrypted = CryptoJS.AES.encrypt(data, key, {
        iv: key,
        mode: CryptoJS.mode.CFB,
        padding: CryptoJS.pad.Pkcs7
      });
      return encrypted.toString()
    } catch (e) {
      console.error(e)
    }
    return ""
  }

  static decode(_key, data) {
    try {
      var key = CryptoJS.enc.Utf8.parse(_key);
      let decrypted = CryptoJS.AES.decrypt(data, key, {
        iv: key,
        mode: CryptoJS.mode.CFB,
        padding: CryptoJS.pad.Pkcs7
      })
      return decrypted.toString(CryptoJS.enc.Utf8)
    } catch (e) {
      console.error(e)
    }
    return ""
  }
}
