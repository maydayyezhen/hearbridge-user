/**
 * 用户账户动作本地服务，负责改密、退出登录与本地登录态清理。
 */
import common from '@ohos.app.ability.common'
import { clearPersistedAuthToken, readPersistedAuthToken } from '../../../repository/auth/AuthRepository'
import { clearPersistedUserAccountProfile } from '../../../repository/user/UserRepository'
import { getReloginRequiredMessage, getRetryLaterMessage } from '../../../utils/FeedbackCopy'
import { handleLogoutSuccess, handlePasswordUpdatedRelogin } from '../../auth/local/AuthLocalService'
import { UserActionResult } from '../api/UserActionResult'
import { requestLogout, requestPasswordChange } from '../api/UserAccountActionService'
import { clearPersistedProfileImages } from './ProfileImageCacheLocalService'

/**
 * 修改用户密码。
 */
export async function changePassword(
  context: common.BaseContext,
  currentPassword: string,
  nextPassword: string,
  confirmPassword: string
): Promise<UserActionResult> {
  const output = new UserActionResult()
  let token = ''
  try {
    token = await readPersistedAuthToken(context)
  } catch (_error) {
    output.message = getRetryLaterMessage('读取登录状态')
    output.tone = 'error'
    return output
  }
  if (token.length === 0) {
    output.message = getReloginRequiredMessage()
    output.tone = 'error'
    return output
  }

  const result = await requestPasswordChange(currentPassword, nextPassword, confirmPassword)
  if (!result.ok) {
    output.message = result.message.length > 0 ? result.message : getRetryLaterMessage('修改密码')
    output.tone = 'error'
    return output
  }

  try {
    await clearPersistedAuthToken(context)
  } catch (_error) {
    output.message = getRetryLaterMessage('清理登录状态')
    output.tone = 'error'
    return output
  }
  try {
    await clearPersistedUserAccountProfile(context)
  } catch (_error) {
    // Best-effort cleanup; relogin flow should not be blocked by profile cache clear failure.
  }
  await clearPersistedProfileImages(context)
  handlePasswordUpdatedRelogin()
  output.ok = true
  output.message = '密码已更新，请重新登录。'
  output.tone = 'success'
  return output
}

/**
 * 执行退出登录。
 */
export async function logoutCurrentUser(context: common.BaseContext): Promise<UserActionResult> {
  const output = new UserActionResult()
  let token = ''
  try {
    token = await readPersistedAuthToken(context)
  } catch (_error) {
    output.message = getRetryLaterMessage('读取登录状态')
    output.tone = 'error'
    return output
  }

  if (token.length > 0) {
    const result = await requestLogout()
    if (!result.ok) {
      output.message = result.message.length > 0 ? result.message : '退出登录失败，请稍后重试。'
      output.tone = 'error'
      return output
    }
  }

  try {
    await clearPersistedAuthToken(context)
  } catch (_error) {
    output.message = getRetryLaterMessage('清理登录状态')
    output.tone = 'error'
    return output
  }
  try {
    await clearPersistedUserAccountProfile(context)
  } catch (_error) {
    // Best-effort cleanup; logout should not be blocked by profile cache clear failure.
  }
  await clearPersistedProfileImages(context)
  handleLogoutSuccess()
  output.ok = true
  output.message = '已退出登录。'
  output.tone = 'success'
  return output
}
