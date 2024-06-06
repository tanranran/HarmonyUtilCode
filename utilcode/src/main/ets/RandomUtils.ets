import { util } from '@kit.ArkTS'
import { LogUtils } from './LogUtils'

/**
 * @author Tanranran
 * @date 2024/5/17 11:02
 * @description
 */
export class RandomUtils {
  /**
   * 随机生成32位UUID xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx
   * @param trimmedUuid 是否去除-
   * @returns
   */
  static randomUUID(trimmedUuid: boolean = true) {
    try {
      if (canIUse('SystemCapability.Utils.Lang')) {
        let random = util.generateRandomUUID(true)
        if (trimmedUuid) {
          return random.replace(new RegExp('-', "gm"), '')
        }
      }
    } catch (e) {
      LogUtils.error(RandomUtils.name, e)
    }
    return RandomUtils.generateUUID()
  }

  private static generateUUID(): string {
    return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, (c) => {
      const r = (Math.random() * 16) | 0;
      const v = c === 'x' ? r : (r & 0x3) | 0x8;
      return v.toString(16);
    });
  }
}

