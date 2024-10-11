/**
 * @author Tanranran
 * @date 2024/5/14 22:20
 * @description
 */
import { AssetStore } from './AssetStore'
import { util } from '@kit.ArkTS'
import { AAID } from '@kit.PushKit';
import { StringUtils } from './StringUtils'
import { deviceInfo } from '@kit.BasicServicesKit'
import { i18n, resourceManager } from '@kit.LocalizationKit'
import { Utils } from './Utils'

export class DeviceUtils {
  private static deviceIdCacheKey = "device_id_cache_key"
  private static deviceId = ""

  /**
   * 判断字符串是否为空
   * @param property 被检测的字符串
   */
  static isEmpty(property?: string | null): Boolean {
    if (property == '' || property == null || property == undefined || property == 'undefined' ||
      property.length == 0) {
      return true
    }
    return false
  }

  /**
   * 获取设备id>32为随机码[卸载APP后依旧不变]
   * @param isMD5
   * @returns
   */
  static async getDeviceId() {
    let deviceId = DeviceUtils.deviceId
    //如果内存缓存为空，则从AssetStore中读取
    if (DeviceUtils.isEmpty(deviceId)) {
      deviceId = `${(await AssetStore.get(DeviceUtils.deviceIdCacheKey)).data}`
    }
    //如果AssetStore中未读取到，则随机生成32位随机码，然后缓存到AssetStore中
    if (DeviceUtils.isEmpty(deviceId)) {
      deviceId = util.generateRandomUUID(true).replace(new RegExp('-', "gm"), '')
      AssetStore.set(DeviceUtils.deviceIdCacheKey, deviceId)
    }
    DeviceUtils.deviceId = deviceId
    return deviceId
  }

  static async getAAID() {
    try {
      return await AAID.getAAID();
    } catch (e) {
      console.error("getAAID error is " + e);
    }
    return ''
  }

  /**
   * 获取设备类型
   * DEVICE_TYPE_PHONE  0x00  手机。
   * DEVICE_TYPE_TABLET  0x01  平板。
   * DEVICE_TYPE_CAR  0x02  汽车。
   * DEVICE_TYPE_PC  0x03  电脑。
   * DEVICE_TYPE_TV  0x04  电视。
   * DEVICE_TYPE_WEARABLE  0x06  穿戴。
   * DEVICE_TYPE_2IN111+  0x07  2IN1。
   * @returns
   */
  static getDeviceType(): resourceManager.DeviceType {
    try {
      let value = Utils.getAbilityContext().resourceManager.getDeviceCapabilitySync();
      let deviceType = value.deviceType;
      return deviceType
    } catch (error) {
      console.error("getDeviceCapabilitySync error is " + error);
    }
    return resourceManager.DeviceType.DEVICE_TYPE_PHONE
  }

  /**
   * 获取 是否是平板设备
   *
   * @param context
   * @return true:平板,false:手机
   */
  static isTabletDevice() {
    return DeviceUtils.getDeviceType() == resourceManager.DeviceType.DEVICE_TYPE_TABLET
  }

  /**
   * 获取手机型号
   *
   * @return 例如 HUAWEI ALN-AL00
   */
  static getDeviceModel() {
    return util.format("%s %s", DeviceUtils.getDeviceBrand(), DeviceUtils.getDeviceModelName());
  }

  /**
   * 获取设备外部产品系列
   *
   * @return HUAWEI Mate 60 Pro
   */
  static getDeviceMarketName() {
    return deviceInfo.marketName
  }

  /**
   * 获取设备品牌名称
   *
   * @return HUAWEI
   */
  static getDeviceBrand() {
    return deviceInfo.brand;
  }

  /**
   * 获取设备设备厂家名称
   *
   * @return HUAWEI
   */
  static getManufacturer() {
    return deviceInfo.manufacture;
  }

  /**
   * 获取设备型号
   *
   * @return ALN-AL00
   */
  static getDeviceModelName() {
    return deviceInfo.productModel;
  }

  /**
   * 获取设备系统版本号
   *
   * @return HarmonyOS 2.1.7.1
   */
  static getDeviceVersionCode() {
    return "HarmonyOS" + deviceInfo.osFullName;
  }

  /**
   * 获取设备系统版本号
   *
   * @return 10/11/12...
   */
  static getSdkApiVersion() {
    return `${deviceInfo.sdkApiVersion}`
  }

  /**
   * 获取系统区域。
   * @returns zh-Hans-CN
   */
  static getLanguage() {
    return i18n.System.getSystemLocale()
  }
}
