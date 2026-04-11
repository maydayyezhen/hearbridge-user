/**
 * 认证本地服务，负责登录态恢复、用户信息加载、退出后清场等端内流程编排。
 */
import common from '@ohos.app.ability.common'
import { loadCurrentUserInfo } from '../api/AuthUserInfoApiService'
import { UserProfileApiData } from '../../user/mapper/UserStateMapper'
import {
  clearAuthRepositoryState,
  clearPersistedAuthToken,
  readPersistedAuthToken,
  savePersistedAuthToken,
  writeAuthToken
} from '../../../repository/auth/AuthRepository'
import {
  applyUserInfoStateWithPersistence,
  hydrateUserAccountProfileFromPersistence
} from '../../user/local/UserStateLocalService'
import { clearPersistedUserAccountProfile, resetUserState } from '../../../repository/user/UserRepository'
import { clearCoursePreviewRecords } from '../../../repository/course/CoursePreviewRepository'
import { clearCourseDetailRecords } from '../../../repository/course/CourseDetailRepository'
import { clearCourseSessionRecords } from '../../../repository/course/CourseSessionRepository'
import { clearTrainingItemEntityCache } from '../../../repository/training-item/CourseTrainingItemIndexRepository'
import { clearTrainSessionRuntime } from '../../../repository/train-session/TrainSessionRepository'
import { clearTrainSessionViewState } from '../../../repository/train-session/TrainSessionViewStateRepository'
import { clearTrainResultViewState } from '../../../repository/train-session/TrainResultViewStateRepository'
import { clearToastState } from '../../../repository/ui/ToastRepository'
import { clearProfileImageCacheRuntimeState } from '../../../repository/resource-cache/ProfileImageCacheRepository'
import { refreshProfileImageCacheForCurrentUser } from '../../user/local/ProfileImageCacheLocalService'
import { clearHomeViewCache } from '../../home/api/HomeApiService'
import { clearCourseListServiceCache } from '../../course/CourseListPageService'
import { preloadRootTabData, resetRootTabPreloadState } from '../../app/local/RootTabPreloadLocalService'

/**
 * 认证动作执行结果。
 */
export class AuthActionResult {
  ok: boolean = false
  message: string = ''
  data: UserProfileApiData | null = null
}

/**
 * 应用启动阶段的认证恢复结果。
 */
export class AuthBootstrapResult {
  isLoggedIn: boolean = false
  message: string = ''
}

/**
 * 清空登录态相关的本地状态与缓存。
 */
export function clearAuthSession(): void {
  clearAuthRepositoryState()
  clearCoursePreviewRecords()
  clearCourseDetailRecords()
  clearCourseSessionRecords()
  clearTrainingItemEntityCache()
  clearTrainSessionRuntime()
  clearTrainSessionViewState()
  clearTrainResultViewState()
  clearToastState()
  clearProfileImageCacheRuntimeState()
  clearHomeViewCache()
  clearCourseListServiceCache()
  resetRootTabPreloadState()
  resetUserState()
}

async function clearPersistedUserProfileSafely(context: common.BaseContext): Promise<void> {
  try {
    await clearPersistedUserAccountProfile(context)
  } catch (_error) {
    return
  }
}

function isTimeoutFailure(message: string): boolean {
  const normalized = message.toLowerCase()
  return message.indexOf('超时') >= 0
    || normalized.indexOf('timeout') >= 0
    || normalized.indexOf('timed out') >= 0
    || normalized.indexOf('etimedout') >= 0
}

/**
 * 安全清理持久化 token。
 */
async function clearPersistedAuthSafely(context: common.BaseContext, clearSession: boolean): Promise<boolean> {
  try {
    await clearPersistedAuthToken(context)
    if (clearSession) {
      await clearPersistedUserProfileSafely(context)
      clearAuthSession()
    } else {
      writeAuthToken('')
    }
    return true
  } catch (_error) {
    if (clearSession) {
      await clearPersistedUserProfileSafely(context)
      clearAuthSession()
    } else {
      writeAuthToken('')
    }
    return false
  }
}

/**
 * 在持有 token 的前提下加载用户信息，并把结果同步到仓储状态。
 */
export async function loadUserInfoAfterAuth(
  token: string,
  context: common.BaseContext,
  forceLogoutOnFailure: boolean = false,
  allowTimeoutAsLoggedIn: boolean = false
): Promise<AuthActionResult> {
  const output = new AuthActionResult()
  writeAuthToken(token)
  const result = await loadCurrentUserInfo()
  if (!result.ok || !result.data) {
    if (allowTimeoutAsLoggedIn && isTimeoutFailure(result.message)) {
      output.ok = true
      output.message = ''
      return output
    }

    output.ok = false
    output.message = result.message.length > 0 ? `获取用户信息失败：${result.message}` : '获取用户信息失败，请重新登录。'
    const cleared = await clearPersistedAuthSafely(context, forceLogoutOnFailure)
    if (!cleared && forceLogoutOnFailure) {
      output.message = '获取用户信息失败，且登录状态清理未完成，请重新登录。'
    }
    return output
  }
  await applyUserInfoStateWithPersistence(context, result.data)
  void refreshProfileImageCacheForCurrentUser(context)
  preloadRootTabData()
  writeAuthToken(token)
  output.ok = true
  output.data = result.data
  return output
}

/**
 * 登录成功后的统一收尾流程，包含持久化 token 与用户信息拉取。
 */
export async function completeAuthSuccessFlow(
  token: string,
  context: common.BaseContext,
  forceLogoutOnFailure: boolean = true
): Promise<AuthActionResult> {
  const output = new AuthActionResult()
  try {
    await savePersistedAuthToken(context, token)
  } catch (_error) {
    output.ok = false
    output.message = '登录状态处理失败，请重新登录。'
    if (forceLogoutOnFailure) {
      await clearPersistedAuthSafely(context, true)
    } else {
      writeAuthToken('')
    }
    return output
  }

  const loadResult = await loadUserInfoAfterAuth(token, context, forceLogoutOnFailure)
  output.ok = loadResult.ok
  output.message = loadResult.message
  output.data = loadResult.data
  if (!loadResult.ok && forceLogoutOnFailure) {
    await clearPersistedAuthSafely(context, true)
  }
  return output
}

/**
 * 应用启动时恢复登录状态。
 */
export async function initializeAuthAfterLaunch(
  context: common.BaseContext,
  forceLogoutOnFailure: boolean = true
): Promise<AuthBootstrapResult> {
  const output = new AuthBootstrapResult()
  let token = ''
  try {
    token = await readPersistedAuthToken(context)
  } catch (_error) {
    output.isLoggedIn = false
    output.message = '登录状态初始化失败，请重新登录。'
    return output
  }

  if (token.length === 0) {
    output.isLoggedIn = false
    return output
  }

  await hydrateUserAccountProfileFromPersistence(context)
  const authResult = await loadUserInfoAfterAuth(token, context, forceLogoutOnFailure, true)
  output.isLoggedIn = authResult.ok
  output.message = authResult.ok ? '' : (authResult.message.length > 0 ? authResult.message : '登录状态初始化失败，请重新登录。')
  return output
}

/**
 * 退出登录成功后的页面级收尾处理。
 */
export function handleLogoutSuccess(): void {
  clearAuthSession()
}

/**
 * 修改密码后强制重新登录的统一处理。
 */
export function handlePasswordUpdatedRelogin(): void {
  clearAuthSession()
}
