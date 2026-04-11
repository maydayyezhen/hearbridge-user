/**
 * 认证用户信息 API 服务，负责获取当前登录用户资料。
 */
import { getUserInfo } from '../../../api/requests/AuthApi'

/**
 * 加载当前登录用户信息。
 */
export async function loadCurrentUserInfo() {
  return await getUserInfo()
}
