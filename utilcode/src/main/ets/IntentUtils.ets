/**
 * 意图工具类
 * @author Tanranran
 * @date 2024/5/15 22:20
 * @description
 */
import { productViewManager } from '@kit.StoreKit';
import { LogUtils } from './LogUtils';
import { BusinessError } from '@kit.BasicServicesKit';
import { AppUtils } from './AppUtils';
import { Utils } from './Utils';
import { Want } from '@kit.AbilityKit';

export class IntentUtils {

  /**
   * 打开设置页面
   * @param uri 更多参数可参考 https://developer.huawei.com/consumer/cn/doc/harmonyos-faqs/faqs-ability-kit-0000001769732194#section858910165268
   * @returns
   */
  private static getSettingWant(uri?: string, parameters?: Record<string, Object>): Want {
    return {
      bundleName: 'com.huawei.hmos.settings',
      abilityName: 'com.huawei.hmos.settings.MainAbility',
      uri: uri,
      parameters: parameters
    }
  }

  /**
   * 打开应用详情
   */
  static startAppSettings(): Promise<void> {
    return Utils.getAbilityContext().startAbility(IntentUtils.getSettingWant("application_info_entry", {
      "pushParams": AppUtils.getPackageName()
    }));
  }

  /**
   * 打开系统浏览器
   * @param uri
   * @returns
   */
  static startBrowser(uri?: string): Promise<boolean> {
    return new Promise<boolean>((resolve) => {
      let want: Want = {
        action: 'ohos.want.action.viewData',
        entities: ['entity.system.browsable'],
        uri: uri
      };
      Utils.getAbilityContext().startAbility(want).then(() => {
        resolve(true)
      }).catch((error: object) => {
        LogUtils.error(`startBrowser`, error)
        resolve(false)
      })
    })
  }

  /**
   * 打开应用商店详情页
   */
  static startAppStoreDetail() {
    try {
      const request: Want = {
        parameters: {
          bundleName: AppUtils.getPackageName()
        }
      };
      productViewManager.loadProduct(Utils.getAbilityContext(), request, {
        onError: (error: BusinessError) => {
          LogUtils.error('startAppStoreDetail', `loadProduct onError.code is ${error.code}, message is ${error.message}`)
        }
      });
    } catch (err) {
      LogUtils.error('startAppStoreDetail', `loadProduct failed.code is ${err.code}, message is ${err.message}`)
    }
  }
}
