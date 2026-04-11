/**
 * 用户账户动作 API 服务，只负责账户相关远端请求。
 */
import { logout, updatePassword } from '../../../api/requests/AuthApi'

/**
 * 请求修改密码。
 */
export async function requestPasswordChange(
  currentPassword: string,
  nextPassword: string,
  confirmPassword: string
) {
  return await updatePassword(currentPassword, nextPassword, confirmPassword)
}

/**
 * 请求退出登录。
 */
export async function requestLogout() {
  return await logout()
}
