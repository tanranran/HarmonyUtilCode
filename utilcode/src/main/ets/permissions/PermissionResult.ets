/**
 * @author Tanranran
 * @date 2024/4/19 16:25
 * @description
 */
import { BusinessError } from '@kit.BasicServicesKit'

export default class PermissionResult {
  //同意了的授权
  grantedPermissions: string[] = []
  //拒绝了的授权
  deniedPermissions: string[] = []
  //是否全部授予
  allGranted: boolean = false
  //error 异常
  error?: BusinessError
}
