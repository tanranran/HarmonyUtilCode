/**
 * @author Tanranran
 * @date 2024/4/12 15:18
 * @description
 */
import { PermissionOptions } from './PermissionOptions';
import PermissionsHelper from './PermissionsHelper';
import { Permissions } from '@kit.AbilityKit';
import Permission from './Permission'
import { IntentUtils } from '../IntentUtils';

/**
 * 权限工具类
 * 用法：
 * let result = await PermissionUtils.with().request(Permission.CAMERA,Permission.APP_TRACKING_CONSENT)
 */
export  class PermissionUtils {
  static with(): PermissionOptions {
    return new PermissionOptions()
  }

  /**
   * 是否有权限
   * @param permissions
   * @returns
   */
  static async hasPermissions(...permissions: Permissions[]) {
    return await PermissionsHelper.getInstance().checkPermission(...permissions)
  }

  /**
   * 打开应用详情
   */
  static startAppSettings() {
    IntentUtils.startAppSettings()
  }
}

export {
  Permission
}

