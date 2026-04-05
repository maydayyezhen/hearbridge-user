import http from '@ohos.net.http'
import { recordApiDebug, stringifyDebugBody } from './ApiDebug'

export interface ApiEnvelope<T> {
  code: number
  message: string
  data: T | null
}

export interface ApiResult<T> extends ApiEnvelope<T> {
  httpCode: number
  ok: boolean
  rawBody: string
}

export interface SmsLoginData {
  token: string
  refresh_token: string | null
}

export interface PasswordRegisterPayload {
  username: string
  password: string
  phone?: string
  nickname?: string
}

export interface PasswordLoginPayload {
  username: string
  password: string
}

export interface UserInfoIdentity {
  id: number
  userNo: string
  username: string
  phone: string | null
  status: number
  createdAt: string
  lastLoginAt: string | null
}

export interface UserInfoProfile {
  nickname: string
  avatarUrl: string
  coverUrl: string
  gender: number
  birthday: string | null
  signature: string
}

export interface UserInfoSecurity {
  hasPassword: boolean
  phoneBound: boolean
  passwordUpdatedAt: string | null
}

export interface UserInfoStats {
  companionDays: number
  completedTrainingItemCount: number
  inProgressTrainingItemCount: number
  totalTrainingMinutes: number
  lastTrainingAt: string | null
}

export interface UserInfoFavorites {
  favoriteCourseCodes: string[]
  favoriteTrainingItemIds: number[]
  favoriteCourses: UserInfoFavoriteCourse[]
  favoriteTrainingItems: UserInfoFavoriteTrainingItem[]
  favoriteUpdatedAt: string | null
}

export interface UserInfoFavoriteCourse {
  courseCode: string
  courseName: string
  trainingType?: string
}

export interface UserInfoFavoriteTrainingItem {
  itemId: number
  itemCode: string
  itemName: string
  courseCode?: string
  courseName: string
  trainingType?: string
}

export interface UserInfoRecentCourse {
  courseName: string
  trainingType: string
  coverUrl: string
  lastLearnAt: string
  progressPercent: number
}

export interface AppUserInfoData {
  identity: UserInfoIdentity
  profile: UserInfoProfile
  security: UserInfoSecurity
  stats: UserInfoStats
  favorites: UserInfoFavorites
  recentCourses: UserInfoRecentCourse[]
}

export interface UpdateUserProfilePayload {
  nickname?: string
  gender?: number
  birthday?: string | null
  signature?: string
  avatarUrl?: string
  coverUrl?: string
}

export interface UpdateUserProfileData {
  profile: UserInfoProfile
}

export interface UpdatePasswordPayload {
  oldPassword: string
  newPassword: string
  confirmPassword: string
}

export interface UpdatePasswordData {
  success: boolean
}

export interface LogoutData {
}

function stringifyResult(result: string | Object | ArrayBuffer): string {
  if (typeof result === 'string') {
    return result
  }
  if (result instanceof ArrayBuffer) {
    return `binary response, size=${result.byteLength}`
  }
  return JSON.stringify(result)
}

function normalizeBaseUrl(baseUrl: string): string {
  return baseUrl.endsWith('/') ? baseUrl.slice(0, -1) : baseUrl
}

function parseEnvelope<T>(httpCode: number, rawBody: string): ApiResult<T> {
  try {
    const parsed = JSON.parse(rawBody) as ApiEnvelope<T>
    return {
      httpCode,
      code: Number(parsed.code ?? httpCode),
      message: parsed.message ?? '',
      data: parsed.data ?? null,
      rawBody,
      ok: httpCode === 200 && Number(parsed.code) === 200
    }
  } catch (_error) {
    return {
      httpCode,
      code: httpCode,
      message: rawBody,
      data: null,
      rawBody,
      ok: false
    }
  }
}

async function requestApi<T>(url: string, options: http.HttpRequestOptions, debugModule: string, debugMethod: string,
  hasToken: boolean, debugBody: string): Promise<ApiResult<T>> {
  const request = http.createHttp()

  try {
    const response = await request.request(url, options)
    const httpCode = Number(response.responseCode)
    const rawBody = stringifyResult(response.result)
    recordApiDebug(debugModule, debugMethod, url, hasToken, debugBody, rawBody)
    return parseEnvelope<T>(httpCode, rawBody)
  } catch (error) {
    recordApiDebug(debugModule, debugMethod, url, hasToken, debugBody, `request error: ${JSON.stringify(error)}`)
    throw new Error(JSON.stringify(error))
  } finally {
    request.destroy()
  }
}

export async function sendSmsCode(baseUrl: string, phone: string): Promise<ApiResult<null>> {
  const requestUrl = `${normalizeBaseUrl(baseUrl)}/app/auth/sms/send/${phone}`
  return requestApi<null>(requestUrl, {
    method: http.RequestMethod.POST,
    expectDataType: http.HttpDataType.STRING,
    usingCache: false,
    connectTimeout: 10000,
    readTimeout: 10000
  }, 'AuthApi', 'POST', false, 'none')
}

export async function smsLogin(baseUrl: string, phone: string, code: string): Promise<ApiResult<SmsLoginData>> {
  const requestUrl = `${normalizeBaseUrl(baseUrl)}/app/auth/sms/login`
  return requestApi<SmsLoginData>(requestUrl, {
    method: http.RequestMethod.POST,
    expectDataType: http.HttpDataType.STRING,
    usingCache: false,
    connectTimeout: 10000,
    readTimeout: 10000,
    header: {
      'Content-Type': 'application/json'
    },
    extraData: {
      phone,
      code
    }
  }, 'AuthApi', 'POST', false, `{"phone":"${phone}","code":"${code}"}`)
}

export async function passwordRegister(baseUrl: string, payload: PasswordRegisterPayload): Promise<ApiResult<SmsLoginData>> {
  const requestUrl = `${normalizeBaseUrl(baseUrl)}/app/auth/password/register`
  return requestApi<SmsLoginData>(requestUrl, {
    method: http.RequestMethod.POST,
    expectDataType: http.HttpDataType.STRING,
    usingCache: false,
    connectTimeout: 10000,
    readTimeout: 10000,
    header: {
      'Content-Type': 'application/json'
    },
    extraData: payload
  }, 'AuthApi', 'POST', false, stringifyDebugBody(payload))
}

export async function passwordLogin(baseUrl: string, payload: PasswordLoginPayload): Promise<ApiResult<SmsLoginData>> {
  const requestUrl = `${normalizeBaseUrl(baseUrl)}/app/auth/password/login`
  return requestApi<SmsLoginData>(requestUrl, {
    method: http.RequestMethod.POST,
    expectDataType: http.HttpDataType.STRING,
    usingCache: false,
    connectTimeout: 10000,
    readTimeout: 10000,
    header: {
      'Content-Type': 'application/json'
    },
    extraData: payload
  }, 'AuthApi', 'POST', false, stringifyDebugBody(payload))
}

export async function getUserInfo(baseUrl: string, token: string): Promise<ApiResult<AppUserInfoData>> {
  const requestUrl = `${normalizeBaseUrl(baseUrl)}/app/user/info`
  return requestApi<AppUserInfoData>(requestUrl, {
    method: http.RequestMethod.GET,
    expectDataType: http.HttpDataType.STRING,
    usingCache: false,
    connectTimeout: 10000,
    readTimeout: 10000,
    header: {
      token
    }
  }, 'AuthApi', 'GET', token.length > 0, 'none')
}

export async function updateUserProfile(baseUrl: string, token: string, payload: UpdateUserProfilePayload): Promise<ApiResult<UpdateUserProfileData>> {
  const requestUrl = `${normalizeBaseUrl(baseUrl)}/app/user/profile/update`
  return requestApi<UpdateUserProfileData>(requestUrl, {
    method: http.RequestMethod.PUT,
    expectDataType: http.HttpDataType.STRING,
    usingCache: false,
    connectTimeout: 10000,
    readTimeout: 10000,
    header: {
      'Content-Type': 'application/json',
      token
    },
    extraData: payload
  }, 'AuthApi', 'PUT', token.length > 0, stringifyDebugBody(payload))
}

export async function updatePassword(baseUrl: string, token: string, payload: UpdatePasswordPayload): Promise<ApiResult<UpdatePasswordData>> {
  const requestUrl = `${normalizeBaseUrl(baseUrl)}/app/user/password/update`
  return requestApi<UpdatePasswordData>(requestUrl, {
    method: http.RequestMethod.PUT,
    expectDataType: http.HttpDataType.STRING,
    usingCache: false,
    connectTimeout: 10000,
    readTimeout: 10000,
    header: {
      'Content-Type': 'application/json',
      token
    },
    extraData: payload
  }, 'AuthApi', 'PUT', token.length > 0, stringifyDebugBody(payload))
}

export async function logout(baseUrl: string, token: string): Promise<ApiResult<LogoutData>> {
  const requestUrl = `${normalizeBaseUrl(baseUrl)}/app/auth/logout`
  return requestApi<LogoutData>(requestUrl, {
    method: http.RequestMethod.POST,
    expectDataType: http.HttpDataType.STRING,
    usingCache: false,
    connectTimeout: 10000,
    readTimeout: 10000,
    header: {
      'Content-Type': 'application/json',
      token
    }
  }, 'AuthApi', 'POST', token.length > 0, 'none')
}
