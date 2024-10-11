import { CryptoUtils } from './CryptoUtils'

export class MD5Utils {
 static  md5(data?: string | ArrayBuffer): string {
    let message: string | ArrayBuffer = data ?? ''
    return CryptoUtils.hash(message, 'MD5')
  }
}