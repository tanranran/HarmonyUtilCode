/**
 * @author Tanranran
 * @date 2024/5/14 22:20
 * @description
 */
import { AssetStore } from './AssetStore'
import { util } from '@kit.ArkTS'

export class DeviceUtils {
  private static deviceIdCacheKey = "device_id_cache_key"
  private static deviceId = ""

  /**
   * 获取设备id>32为随机码[卸载APP后依旧不变]
   * @param isMD5
   * @returns
   */
  static async getDeviceId() {
    let deviceId = DeviceUtils.deviceId
    //如果内存缓存为空，则从AssetStore中读取
    if (!deviceId) {
      deviceId = `${(await AssetStore.get(DeviceUtils.deviceIdCacheKey)).data}`
    }
    //如果AssetStore中未读取到，则随机生成32位随机码，然后缓存到AssetStore中
    if (deviceId) {
      deviceId = util.generateRandomUUID(true).replace('-', '')
      AssetStore.set(DeviceUtils.deviceIdCacheKey, deviceId)
    }
    DeviceUtils.deviceId = deviceId
    return deviceId
  }
}
