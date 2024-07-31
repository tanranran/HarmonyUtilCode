/**
 * 权限工具类
 * @author Tanranran
 * @date 2024/4/2 11:34
 * @description
 */
import { abilityAccessCtrl, bundleManager, common, Permissions } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import PermissionResult from './PermissionResult';

export default class PermissionsHelper {
  /**
   * 单例模型私有化构造函数，使用getInstance静态方法获得单例
   */
  private constructor() {
  }

  /**
   * PermissionModel 单例
   */
  private static instance?: PermissionsHelper;

  /**
   * 获取PermissionsHelper单例实例
   * @returns {PermissionsHelper} PermissionsHelper
   */
  static getInstance(): PermissionsHelper {
    if (!PermissionsHelper.instance) {
      PermissionsHelper.instance = new PermissionsHelper();
    }

    return PermissionsHelper.instance;
  }

  /**
   * 检测是否已授权
   * @param {Permissions} permissionName 检测授权的权限名
   * @returns {boolean} 检测结果
   */
  async checkPermission(...permissions: Permissions[]): Promise<boolean> {
    if (permissions == null || permissions.length == 0) {
      return false;
    }
    for (const permission of permissions) {
      const grantStatus: abilityAccessCtrl.GrantStatus = await this.reqCurGrantStatus(permission);
      if (grantStatus !== abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED) {
        return false;
      }
    }
    return true;
  }

  /**
   * 检查单个权限是否授权
   * 校验当前权限是否已经授权
   * @param permission
   * @returns
   */
  private async reqCurGrantStatus(permission: Permissions): Promise<abilityAccessCtrl.GrantStatus> {
    const atManager: abilityAccessCtrl.AtManager = abilityAccessCtrl.createAtManager();
    let grantStatus: abilityAccessCtrl.GrantStatus = abilityAccessCtrl.GrantStatus.PERMISSION_DENIED;
    // 获取应用程序的accessTokenID
    let tokenID: number = 0;
    try {
      let bundleInfo: bundleManager.BundleInfo = await bundleManager.getBundleInfoForSelf(bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION);
      let appInfo: bundleManager.ApplicationInfo = bundleInfo.appInfo;
      tokenID = appInfo.accessTokenId;
    } catch (err) {
      console.error(`getBundleInfoForSelf failed, error: ${err}`);
    }

    // 校验应用是否被授予权限
    try {
      grantStatus = await atManager.checkAccessToken(tokenID, permission);
    } catch (err) {
      console.error(`checkAccessToken failed, error: ${err}`);
    }
    return grantStatus;
  }

  /**
   * 批量请求权限
   * @param permissions
   * @param context
   */
  async requestPermissions(permissions: Permissions[]): Promise<PermissionResult> {
    let permissionResult = new PermissionResult()
    return new Promise<PermissionResult>(async (resolve) => {
      if (await PermissionsHelper.getInstance().checkPermission(...permissions)) {
        permissionResult.grantedPermissions = permissions
        permissionResult.allGranted = true
        resolve(permissionResult)
        return
      }
      // 向用户申请授权
      let context = getContext() as common.UIAbilityContext;
      let atManager: abilityAccessCtrl.AtManager = abilityAccessCtrl.createAtManager();
      // requestPermissionsFromUser会判断权限的授权状态来决定是否唤起弹窗
      atManager.requestPermissionsFromUser(context, permissions).then((data) => {
        let dataPermissions = data.permissions
        let grantStatus: Array<number> = data.authResults;
        let length: number = grantStatus.length;
        for (let i = 0; i < length; i++) {
          let permission = dataPermissions[i]
          if (grantStatus[i] === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED) {
            // 用户授权，可以继续访问目标操作
            permissionResult.grantedPermissions.push(permission)
          } else {
            // 用户拒绝授权，提示用户必须授权才能访问当前页面的功能，并引导用户到系统设置中打开相应的权限
            permissionResult.deniedPermissions.push(permission)
          }
        }
        permissionResult.allGranted = permissionResult.grantedPermissions.length == dataPermissions.length
        resolve(permissionResult)
        // 授权成功
      }).catch((err: BusinessError) => {
        permissionResult.error = err
        console.error(`Failed to request permissions from user. Code is ${err.code}, message is ${err.message}`);
        resolve(permissionResult)
      })
    })
  }
}
