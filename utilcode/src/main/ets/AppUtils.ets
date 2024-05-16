import { bundleManager } from '@kit.AbilityKit';

/**
 * @author Tanranran
 * @date 2024/5/15 22:10
 * @description
 */
export class AppUtils {
  private static mBundleInfo?: bundleManager.BundleInfo
  private static mAppName: string = ""

  private static getAppBundleInfo() {
    if (AppUtils.mBundleInfo != null) {
      return AppUtils.mBundleInfo
    }
    let bundleFlags = bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION;
    AppUtils.mBundleInfo = bundleManager.getBundleInfoForSelfSync(bundleFlags)
    return AppUtils.mBundleInfo
  }

  static isAppDebug(): Boolean {
    //https://developer.huawei.com/consumer/cn/forum/topic/0201147109742425145?fid=0109140870620153026
    return AppUtils.getAppBundleInfo().appInfo.debug
  }

  //   public static boolean isAppSystem() {
  //     return isAppSystem(Utils.getApp().getPackageName());
  //   }
  //
  //   public static boolean isAppForeground() {
  //     return UtilsBridge.isAppForeground();
  //   }
  //
  //   public static void launchApp(final String packageName) {
  //
  // }
  //
  // public static void relaunchApp(final boolean isKillProcess) {
  //
  // }
  //
  // launchAppDetailsSettings(){
  //
  // }
  //
  // exitApp(){
  //
  // }
  //
  // getAppIcon(){
  //
  // }
  //
  // getAppIconId()
  // }
  //
  // isFirstTimeInstall()
  // }
  //
  // isAppUpgraded()

  static getPackageName(): string {
    return AppUtils.getAppBundleInfo().name
  }

  static getAppName(): string {
    if (AppUtils.mAppName.length == 0) {
      AppUtils.mAppName = getContext().resourceManager.getStringSync(AppUtils.getAppBundleInfo().appInfo.labelId)
    }
    return AppUtils.mAppName
  }

  // getAppPath()

  static getAppVersionName(): string {
    return AppUtils.getAppBundleInfo().versionName
  }

  static getAppVersionCode(): number {
    return AppUtils.getAppBundleInfo().versionCode
  }

  //
  // getAppMinSdkVersion()
  //
  // getAppTargetSdkVersion()
  //
  // getAppUid()
  //
  // getAppInfo()
}