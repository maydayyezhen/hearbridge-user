/**
 * AuthApi 相关的请求函数与接口访问逻辑。
 */

import http from '@ohos.net.http'
import { ApiResult } from '../common/Http'
import { requestApi } from '../HttpClient'

class SmsLoginPayload {
  phone: string = ''
  code: string = ''
}

class RegisterPayload {
  username: string = ''
  password: string = ''
  phone: string = ''
  nickname: string = ''
}

class PasswordLoginPayload {
  username: string = ''
  password: string = ''
}

class UserProfileUpdatePayload {
  nickname: string = ''
  gender: number = 0
  birthday: string | null = null
  signature: string = ''
  avatarUrl: string = ''
  coverUrl: string = ''
}

class PasswordUpdatePayload {
  oldPassword: string = ''
  newPassword: string = ''
  confirmPassword: string = ''
}

/** 登录/注册成功后的认证结果。 */
export interface AuthTokenResponseSource {
  token?: string
}

/** 用户收藏课程源对象。 */
export interface FavoriteCourseSource {
  courseCode?: string
  courseName?: string
  trainingType?: string
}

/** 用户收藏训练项源对象。 */
export interface FavoriteTrainingItemSource {
  itemId?: number | string
  itemCode?: string
  itemName?: string
  courseCode?: string
  courseName?: string
  trainingType?: string
}

/** 用户最近课程源对象。 */
export interface RecentUserCourseSource {
  courseCode?: string
  courseName?: string
  coverUrl?: string
  trainingType?: string
  progressPercent?: number | string
  lastLearnAt?: string
  currentItemCode?: string
  currentItemName?: string
}

/** 用户身份信息源对象。 */
export interface UserIdentitySource {
  id?: number | string
  userNo?: string
  username?: string
  phone?: string
  status?: number | string
  createdAt?: string
  lastLoginAt?: string
}

/** 用户资料信息源对象。 */
export interface UserProfileSource {
  nickname?: string
  avatarUrl?: string
  coverUrl?: string
  signature?: string
  gender?: number | string
  birthday?: string
}

/** 用户安全信息源对象。 */
export interface UserSecuritySource {
  hasPassword?: boolean
  phoneBound?: boolean
  passwordUpdatedAt?: string
}

/** 用户统计信息源对象。 */
export interface UserStatsSource {
  companionDays?: number | string
  completedTrainingItemCount?: number | string
  inProgressTrainingItemCount?: number | string
  totalTrainingMinutes?: number | string
  lastTrainingAt?: string
}

/** 用户收藏信息源对象。 */
export interface UserFavoritesSource {
  favoriteCourses?: FavoriteCourseSource[]
  favoriteTrainingItems?: FavoriteTrainingItemSource[]
}

/** 用户资料接口源对象。 */
export interface UserProfileApiData {
  identity?: UserIdentitySource
  profile?: UserProfileSource
  security?: UserSecuritySource
  stats?: UserStatsSource
  favorites?: UserFavoritesSource
  recentCourses?: RecentUserCourseSource[]
}

/** sendSmsCode。 */
export async function sendSmsCode(phone: string): Promise<ApiResult<object>> {
  return await requestApi<object>({
    path: `/app/auth/sms/send/${phone}`,
    method: http.RequestMethod.POST
  })
}

/** smsLogin。 */
export async function smsLogin(phone: string, code: string): Promise<ApiResult<AuthTokenResponseSource>> {
  const payload = new SmsLoginPayload()
  payload.phone = phone
  payload.code = code
  return await requestApi<AuthTokenResponseSource>({
    path: '/app/auth/sms/login',
    method: http.RequestMethod.POST,
    body: payload
  })
}

/** passwordRegister。 */
export async function passwordRegister(username: string, password: string, phone: string = '', nickname: string = ''): Promise<ApiResult<AuthTokenResponseSource>> {
  const payload = new RegisterPayload()
  payload.username = username
  payload.password = password
  payload.phone = phone
  payload.nickname = nickname
  return await requestApi<AuthTokenResponseSource>({
    path: '/app/auth/password/register',
    method: http.RequestMethod.POST,
    body: payload
  })
}

/** passwordLogin。 */
export async function passwordLogin(username: string, password: string): Promise<ApiResult<AuthTokenResponseSource>> {
  const payload = new PasswordLoginPayload()
  payload.username = username
  payload.password = password
  return await requestApi<AuthTokenResponseSource>({
    path: '/app/auth/password/login',
    method: http.RequestMethod.POST,
    body: payload
  })
}

/** getUserInfo。 */
export async function getUserInfo(): Promise<ApiResult<UserProfileApiData>> {
  return await requestApi<UserProfileApiData>({
    path: '/app/user/info',
    method: http.RequestMethod.GET
  })
}

/** updateUserProfile。 */
export async function updateUserProfile(
  nickname: string,
  gender: number,
  birthday: string | null,
  signature: string,
  avatarUrl: string,
  coverUrl: string
): Promise<ApiResult<UserProfileApiData>> {
  const payload = new UserProfileUpdatePayload()
  payload.nickname = nickname
  payload.gender = gender
  payload.birthday = birthday
  payload.signature = signature
  payload.avatarUrl = avatarUrl
  payload.coverUrl = coverUrl
  return await requestApi<UserProfileApiData>({
    path: '/app/user/profile/update',
    method: http.RequestMethod.PUT,
    body: payload
  })
}

/** updatePassword。 */
export async function updatePassword(oldPassword: string, newPassword: string, confirmPassword: string): Promise<ApiResult<object>> {
  const payload = new PasswordUpdatePayload()
  payload.oldPassword = oldPassword
  payload.newPassword = newPassword
  payload.confirmPassword = confirmPassword
  return await requestApi<object>({
    path: '/app/user/password/update',
    method: http.RequestMethod.PUT,
    body: payload
  })
}

/** logout。 */
export async function logout(): Promise<ApiResult<object>> {
  return await requestApi<object>({
    path: '/app/auth/logout',
    method: http.RequestMethod.POST
  })
}
