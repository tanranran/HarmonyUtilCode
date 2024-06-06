import { DeviceUtils, JsonUtils } from '@android/utilcode';
import CommonItemTitle from '../bean/CommonItemTitle';
import CommonConst from '../const/CommonConst';
import { BaseFragmentComp } from '../components/BaseFragmentComp';
import wifiManager from '@ohos.wifiManager';

/**
 * @author Tanranran
 * @date 2024/5/13 22:25
 * @description
 */
@Component
export struct DeviceFragment {
  @Consume(CommonConst.NavPathStack) pageInfos: NavPathStack
  @State listData: Array<CommonItemTitle> = []
  @State title: string = ""
  msgHistory: string = ""

  async aboutToAppear(): Promise<void> {
    this.listData.push(new CommonItemTitle('设备ID-getDeviceId', await DeviceUtils.getDeviceId()))
    this.listData.push(new CommonItemTitle('设备AAID-getAAID', await DeviceUtils.getAAID()))
    this.listData.push(new CommonItemTitle('设备类型-getDeviceType', `${DeviceUtils.getDeviceType()}`))
    this.listData.push(new CommonItemTitle('是否是平板-isTabletDevice',
      DeviceUtils.isTabletDevice() ? '是平板' : '不是平板'))
    this.listData.push(new CommonItemTitle('手机型号-getDeviceModel', DeviceUtils.getDeviceModel()))
    this.listData.push(new CommonItemTitle('设备外部产品系列-getDeviceMarketName', DeviceUtils.getDeviceMarketName()))
    this.listData.push(new CommonItemTitle('设备品牌名称-getDeviceBrand', DeviceUtils.getDeviceBrand()))
    this.listData.push(new CommonItemTitle('设备设备厂家名称-getManufacturer', DeviceUtils.getManufacturer()))
    this.listData.push(new CommonItemTitle('设备系统版本号-getDeviceVersionCode', DeviceUtils.getDeviceVersionCode()))
    this.listData.push(new CommonItemTitle('设备系统版本-getSdkApiVersion', DeviceUtils.getSdkApiVersion()))
    this.listData.push(new CommonItemTitle('设备型号-getDeviceModelName', DeviceUtils.getDeviceModelName()))
    this.listData.push(new CommonItemTitle('系统区域-getLanguage', DeviceUtils.getLanguage()))

    let ipInfo = wifiManager.getIpInfo();

    let ipAddr = this.getIpAddrFromNum(ipInfo.ipAddress)
    this.msgHistory += `IP地址: ${ipAddr}\r\n`;

    let gateAddr = this.getIpAddrFromNum(ipInfo.gateway)
    this.msgHistory += `网关地址: ${gateAddr}\r\n`;

    let maskAddr = this.getIpAddrFromNum(ipInfo.netmask)
    this.msgHistory += `子网掩码: ${maskAddr}\r\n`;

    let dnsAddr = this.getIpAddrFromNum(ipInfo.primaryDns)
    this.msgHistory += `DNS服务器: ${dnsAddr}\r\n`;

    let dhcpServer = this.getIpAddrFromNum(ipInfo.serverIp)
    this.msgHistory += `DHCP服务器: ${dhcpServer}\r\n`;

    this.msgHistory += `租用时长: ${ipInfo.leaseDuration}\r\n`;

    wifiManager.getLinkedInfo()
      .then((linkedInfo) => {
        console.log("WIFI信息"+JsonUtils.bean2Json(linkedInfo))
        let len = linkedInfo.ssid.length
        let ssid = linkedInfo.ssid.substring(1, len - 1)
        this.msgHistory += `SSID: ${ssid}\r\n`;
        this.msgHistory += `信号强度: ${linkedInfo.rssi}\r\n`;
        this.msgHistory += `网络频段: ${linkedInfo.band}\r\n`;
        this.msgHistory += `链接速度: ${linkedInfo.linkSpeed}\r\n`;
        this.msgHistory += `网络频率: ${linkedInfo.frequency}\r\n`;
        this.msgHistory += `MAC地址: ${linkedInfo.macAddress}\r\n`;
        console.log(this.msgHistory)
      }
      )
  }

  //根据数字形式的IP地址获取字符串形式的IP地址
  getIpAddrFromNum(ipNum: number): string {
    return (ipNum >>> 24) + '.' + (ipNum >> 16 & 0xFF) + '.' + (ipNum >> 8 & 0xFF) + '.' + (ipNum & 0xFF);
  }

  build() {
    BaseFragmentComp({ title: this.title, listData: this.listData })
  }
}
