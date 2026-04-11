/**
 * 路由路径构造器。
 */
import { AppRoutePath, RouteQueryValue } from './RouteTypes'
import { TrainingType } from '../domain/static/train/TrainingRuntimeTypes'
import {
  COURSE_DETAIL_BASE_PATH,
  HOME_PATH,
  LOGIN_PASSWORD_PATH,
  LOGIN_SMS_PATH,
  PROFILE_ABOUT_PATH,
  PROFILE_ACCOUNT_PATH,
  PROFILE_FAVORITES_PATH,
  PROFILE_FEEDBACK_PATH,
  PROFILE_PASSWORD_PATH,
  PROFILE_PATH,
  PROFILE_SECURITY_PATH,
  REGISTER_PATH,
  TRAIN_PATH,
  TRAIN_SESSION_BASE_PATH
} from './RoutePaths'

class RouteQueryEntry {
  key: string = ''
  value: RouteQueryValue = ''

  constructor(key: string, value: RouteQueryValue) {
    this.key = key
    this.value = value
  }
}

/** buildRoutePath。 */
export function buildRoutePath(basePath: AppRoutePath, params?: RouteQueryEntry[]): AppRoutePath {
  if (!params) return basePath
  const parts: string[] = []
  for (let i = 0; i < params.length; i += 1) {
    const key = params[i].key
    const raw = params[i].value
    if (raw === undefined || raw === null) continue
    const value = String(raw)
    if (value.length === 0) continue
    parts.push(`${encodeURIComponent(key)}=${encodeURIComponent(value)}`)
  }
  if (parts.length === 0) return basePath
  return `${basePath}?${parts.join('&')}`
}

export function buildHomePath(): AppRoutePath { return HOME_PATH }
export function buildLoginSmsPath(): AppRoutePath { return LOGIN_SMS_PATH }
export function buildLoginPasswordPath(): AppRoutePath { return LOGIN_PASSWORD_PATH }
export function buildRegisterPath(): AppRoutePath { return REGISTER_PATH }
export function buildProfilePath(): AppRoutePath { return PROFILE_PATH }
export function buildProfileFavoritesPath(tab?: string): AppRoutePath {
  const params: RouteQueryEntry[] = [new RouteQueryEntry('tab', tab)]
  return buildRoutePath(PROFILE_FAVORITES_PATH, params)
}
export function buildProfileAccountPath(): AppRoutePath { return PROFILE_ACCOUNT_PATH }
export function buildProfileSecurityPath(): AppRoutePath { return PROFILE_SECURITY_PATH }
export function buildProfilePasswordPath(): AppRoutePath { return PROFILE_PASSWORD_PATH }
export function buildProfileFeedbackPath(): AppRoutePath { return PROFILE_FEEDBACK_PATH }
export function buildProfileAboutPath(): AppRoutePath { return PROFILE_ABOUT_PATH }
export function buildTrainRootPath(trainingType: TrainingType): AppRoutePath {
  const params: RouteQueryEntry[] = [new RouteQueryEntry('trainingType', trainingType)]
  return buildRoutePath(TRAIN_PATH, params)
}
export function buildCourseDetailPath(courseCode: string): AppRoutePath { return `${COURSE_DETAIL_BASE_PATH}/${encodeURIComponent(courseCode)}` }
export function buildTrainSessionPath(courseCode: string, itemCode: string, stage?: string): AppRoutePath {
  const safeCourseCode = encodeURIComponent(courseCode)
  const safeItemCode = encodeURIComponent(itemCode)
  const base = safeItemCode.length > 0
    ? `${TRAIN_SESSION_BASE_PATH}/${safeCourseCode}/${safeItemCode}`
    : `${TRAIN_SESSION_BASE_PATH}/${safeCourseCode}`
  const params: RouteQueryEntry[] = [new RouteQueryEntry('stage', stage)]
  return buildRoutePath(base, params)
}
