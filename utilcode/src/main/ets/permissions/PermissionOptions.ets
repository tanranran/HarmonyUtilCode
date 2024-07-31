/**
 * @author Tanranran
 * @date 2024/4/12 15:21
 * @description
 */
import { Permissions } from '@kit.AbilityKit'
import PermissionResult from './PermissionResult'
import PermissionsHelper from './PermissionsHelper'

export class PermissionOptions {
  private mPermissions = new Array<Permissions>()

  // permission(...permissions: Permissions[]): ZDMPermissionOptions {
  //   for (const permission of permissions) {
  //     if (this.mPermissions.indexOf(permission) != -1) {
  //       continue
  //     }
  //     this.mPermissions.push(permission)
  //   }
  //   return this
  // }

  request(...permissions: Permissions[]): Promise<PermissionResult> {
    //检查权限列表
    if (permissions.length == 0) {
      return Promise.resolve(new PermissionResult())
    }
    return PermissionsHelper.getInstance().requestPermissions(permissions)
  }
}
