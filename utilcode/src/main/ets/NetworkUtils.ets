import { connection, statistics } from '@kit.NetworkKit';
import { radio } from '@kit.TelephonyKit'


/**
 * @author Tanranran
 * @date 2024/5/15 22:21
 * @description
 */
export enum NetworkType {
  NETWORK_TYPE_UNKNOWN = 0,
  NETWORK_TYPE_WIFI = 1,
  NETWORK_TYPE_2G = 2,
  NETWORK_TYPE_3G = 3,
  NETWORK_TYPE_4G = 4,
  NETWORK_TYPE_5G = 5
}

export  class NetworkUtils {
  /**
   * 是否有网络
   */
  static isConnected() {
    return connection.hasDefaultNetSync()
  }

  /**
   * 是否是移动网络
   * @return true->移动网络 false->Wifi等其他网络
   */
  static isMobile(): boolean {
    return NetworkUtils.hasNetBearType(connection.NetBearType.BEARER_CELLULAR)
  }

  /**
   * 判断当前网络是否是wifi网络
   *
   * @return boolean
   */
  static isWifi(): boolean {
    return NetworkUtils.hasNetBearType(connection.NetBearType.BEARER_WIFI)
  }

  /**
   * 判断当前网络是否是以太网网络
   *
   * @return boolean
   */
  static isEthernet(): boolean {
    return NetworkUtils.hasNetBearType(connection.NetBearType.BEARER_ETHERNET)
  }

  /**
   * 获取网络类型
   *
   * @return C中的NETWORK_TYPE常量
   */
  static async getNetworkType(): Promise<NetworkType> {
    try {
      if (NetworkUtils.isWifi()) {
        return NetworkType.NETWORK_TYPE_WIFI
      }
      if (NetworkUtils.isMobile()) {
        let slotId: number = await radio.getPrimarySlotId(); //获取主卡所在卡槽的索引号
        let signalInfo: Array<radio.SignalInformation> = radio.getSignalInformationSync(slotId);
        for (let item of signalInfo) {
          if (item.signalType == radio.NetworkType.NETWORK_TYPE_UNKNOWN) {
            return NetworkType.NETWORK_TYPE_UNKNOWN
          } else if (item.signalType == radio.NetworkType.NETWORK_TYPE_GSM ||
            item.signalType == radio.NetworkType.NETWORK_TYPE_CDMA) {
            return NetworkType.NETWORK_TYPE_2G
          } else if (item.signalType == radio.NetworkType.NETWORK_TYPE_WCDMA ||
            item.signalType == radio.NetworkType.NETWORK_TYPE_TDSCDMA) {
            return NetworkType.NETWORK_TYPE_3G
          } else if (item.signalType == radio.NetworkType.NETWORK_TYPE_LTE) {
            return NetworkType.NETWORK_TYPE_4G;
          } else if (item.signalType == radio.NetworkType.NETWORK_TYPE_NR) {
            return NetworkType.NETWORK_TYPE_5G;
          }
        }
      }
    } catch (e) {
      console.error(e)
    }
    return NetworkType.NETWORK_TYPE_UNKNOWN
  }

  /**
   * 获取网络类型字符
   *
   * @return
   */
  static async getNetStyleString() {
    try {
      switch (await NetworkUtils.getNetworkType()) {
        case NetworkType.NETWORK_TYPE_WIFI:
          return "wifi";
        case NetworkType.NETWORK_TYPE_2G:
          return "2G";
        case NetworkType.NETWORK_TYPE_3G:
          return "3G";
        case NetworkType.NETWORK_TYPE_4G:
          return "4G";
        case NetworkType.NETWORK_TYPE_5G:
          return "5G";
      }
    } catch (e) {
      console.error(e)
    }
    return "noNet_type";
  }

  static async getNetworkState() {
    let slotId = await radio.getPrimarySlotId(); //获取主卡所在卡槽的索引号
    let networkState = await radio.getNetworkState(slotId)
    return networkState
  }

  /**
   * 获取设备的网络运营商
   * 关于PLMN可参考这里 https://zh.wikipedia.org/wiki/%E7%A7%BB%E5%8A%A8%E8%AE%BE%E5%A4%87%E7%BD%91%E7%BB%9C%E4%BB%A3%E7%A0%81#%E4%B8%AD%E5%8D%8E%E4%BA%BA%E6%B0%91%E5%85%B1%E5%92%8C%E5%9B%BD_-_CN
   * @return
   */
  static async getSimOperatorType(_networkState?: radio.NetworkState) {
    try {
      let networkState = _networkState ?? await NetworkUtils.getNetworkState()
      switch (networkState.plmnNumeric) {
        case "46000":
        case "46002":
        case "46004":
        case "46007":
        case "46008":
          return 1; //中国移动
        case "46001":
        case "46006":
        case "46009":
          return 2; //中国联通
        case "46003":
        case "46005":
        case "46011":
          return 3; //中国电信
        case "46020":
          return 4; //中国铁通
        case "46015":
          return 5; //中国广电
      }
    } catch (e) {
      console.error(e)
    }
    return 0;
  }

  static async getSimOperatorName() {
    let networkState = await NetworkUtils.getNetworkState()
    switch (await NetworkUtils.getSimOperatorType(networkState)) {
      case 1:
        return "中国移动";
      case 2:
        return "中国联通";
      case 3:
        return "中国电信";
      case 4:
        return "中国铁通";
      case 5:
        return "中国广电";
    }
    return networkState.longOperatorName;
  }

  /**
   * 获取通过Mobile连接收到的字节总数，不包含WiFi
   *
   * @return 数据流量MB
   */
  static async getMobileRxMB() {
    let mb = await statistics.getCellularRxBytes()
    if (mb <= 0) {
      mb = 0
    } else {
      mb = mb / 1024 / 1024
    }
    return mb + "MB";
  }

  /**
   * 获取通过Mobile连接发送的字节总数，不包含WiFi
   *
   * @return 数据流量MB
   */
  static async getMobileSdMB() {
    let mb = await statistics.getCellularTxBytes()
    if (mb <= 0) {
      mb = 0
    } else {
      mb = mb / 1024 / 1024
    }
    return mb + "MB";
  }

  /**
   * 获取默认激活的网络【可能是移动数据，也可能是WIFI】
   * @returns
   */
  private static getDefaultNet(): connection.NetHandle {
    return connection.getDefaultNetSync()
  }

  /**
   * 是否存在指定的网络
   * @param netType
   * @returns
   */
  private static hasNetBearType(netType: connection.NetBearType) {
    let netCapabilities = connection.getNetCapabilitiesSync(NetworkUtils.getDefaultNet());
    for (let item of netCapabilities.bearerTypes.values()) {
      if (item == netType) {
        return true
      }
    }
    return false
  }
}