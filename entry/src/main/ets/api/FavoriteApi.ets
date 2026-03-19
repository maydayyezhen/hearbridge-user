import http from '@ohos.net.http'
import { recordApiDebug } from './ApiDebug'

export interface FavoriteApiEnvelope<T> {
  code: number
  message: string
  data: T | null
}

export interface FavoriteApiResult<T> extends FavoriteApiEnvelope<T> {
  httpCode: number
  ok: boolean
  rawBody: string
}

export interface FavoriteToggleData {
  success: boolean
}

export interface FavoriteStatusData {
  favorite: boolean
}

export class FavoriteCourseSummary {
  courseCode: string
  courseName: string

  constructor(courseCode: string, courseName: string) {
    this.courseCode = courseCode
    this.courseName = courseName
  }
}

export class FavoriteTrainingItemSummary {
  itemCode: string
  itemName: string

  constructor(itemCode: string, itemName: string) {
    this.itemCode = itemCode
    this.itemName = itemName
  }
}

export interface FavoriteListData {
  favoriteCourses?: FavoriteCourseSummary[]
  favoriteTrainingItems?: FavoriteTrainingItemSummary[]
  favoriteCourseCodes?: string[]
  favoriteTrainingItemCodes?: string[]
  favoriteUpdatedAt: string | null
}

class TokenHeader {
  token: string

  constructor(token: string) {
    this.token = token
  }
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

function parseEnvelope<T>(httpCode: number, rawBody: string): FavoriteApiResult<T> {
  try {
    const parsed = JSON.parse(rawBody) as FavoriteApiEnvelope<T>
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

async function requestApi<T>(url: string, options: http.HttpRequestOptions, method: string,
  token: string): Promise<FavoriteApiResult<T>> {
  const request = http.createHttp()
  try {
    const response = await request.request(url, options)
    const rawBody = stringifyResult(response.result)
    recordApiDebug('FavoriteApi', method, url, token.length > 0, 'none', rawBody)
    return parseEnvelope<T>(Number(response.responseCode), rawBody)
  } catch (error) {
    const errorText = `request error: ${JSON.stringify(error)}`
    recordApiDebug('FavoriteApi', method, url, token.length > 0, 'none', errorText)
    throw new Error(errorText)
  } finally {
    request.destroy()
  }
}

function buildTokenHeader(token: string): TokenHeader {
  return new TokenHeader(token)
}

export async function addCourseFavorite(baseUrl: string, token: string, courseCode: string): Promise<FavoriteApiResult<FavoriteToggleData>> {
  const requestUrl = `${normalizeBaseUrl(baseUrl)}/app/favorite/course/${encodeURIComponent(courseCode)}`
  return requestApi<FavoriteToggleData>(requestUrl, {
    method: http.RequestMethod.POST,
    expectDataType: http.HttpDataType.STRING,
    usingCache: false,
    connectTimeout: 10000,
    readTimeout: 10000,
    header: buildTokenHeader(token)
  }, 'POST', token)
}

export async function removeCourseFavorite(baseUrl: string, token: string, courseCode: string): Promise<FavoriteApiResult<FavoriteToggleData>> {
  const requestUrl = `${normalizeBaseUrl(baseUrl)}/app/favorite/course/${encodeURIComponent(courseCode)}`
  return requestApi<FavoriteToggleData>(requestUrl, {
    method: http.RequestMethod.DELETE,
    expectDataType: http.HttpDataType.STRING,
    usingCache: false,
    connectTimeout: 10000,
    readTimeout: 10000,
    header: buildTokenHeader(token)
  }, 'DELETE', token)
}

export async function getCourseFavoriteStatus(baseUrl: string, token: string, courseCode: string): Promise<FavoriteApiResult<FavoriteStatusData>> {
  const requestUrl = `${normalizeBaseUrl(baseUrl)}/app/favorite/course/${encodeURIComponent(courseCode)}/status`
  return requestApi<FavoriteStatusData>(requestUrl, {
    method: http.RequestMethod.GET,
    expectDataType: http.HttpDataType.STRING,
    usingCache: false,
    connectTimeout: 10000,
    readTimeout: 10000,
    header: buildTokenHeader(token)
  }, 'GET', token)
}

export async function addTrainingItemFavorite(baseUrl: string, token: string,
  itemCode: string): Promise<FavoriteApiResult<FavoriteToggleData>> {
  const requestUrl = `${normalizeBaseUrl(baseUrl)}/app/favorite/training-item/${encodeURIComponent(itemCode)}`
  return requestApi<FavoriteToggleData>(requestUrl, {
    method: http.RequestMethod.POST,
    expectDataType: http.HttpDataType.STRING,
    usingCache: false,
    connectTimeout: 10000,
    readTimeout: 10000,
    header: buildTokenHeader(token)
  }, 'POST', token)
}

export async function removeTrainingItemFavorite(baseUrl: string, token: string,
  itemCode: string): Promise<FavoriteApiResult<FavoriteToggleData>> {
  const requestUrl = `${normalizeBaseUrl(baseUrl)}/app/favorite/training-item/${encodeURIComponent(itemCode)}`
  return requestApi<FavoriteToggleData>(requestUrl, {
    method: http.RequestMethod.DELETE,
    expectDataType: http.HttpDataType.STRING,
    usingCache: false,
    connectTimeout: 10000,
    readTimeout: 10000,
    header: buildTokenHeader(token)
  }, 'DELETE', token)
}

export async function getTrainingItemFavoriteStatus(baseUrl: string, token: string,
  itemCode: string): Promise<FavoriteApiResult<FavoriteStatusData>> {
  const requestUrl = `${normalizeBaseUrl(baseUrl)}/app/favorite/training-item/${encodeURIComponent(itemCode)}/status`
  return requestApi<FavoriteStatusData>(requestUrl, {
    method: http.RequestMethod.GET,
    expectDataType: http.HttpDataType.STRING,
    usingCache: false,
    connectTimeout: 10000,
    readTimeout: 10000,
    header: buildTokenHeader(token)
  }, 'GET', token)
}

export async function getFavoriteList(baseUrl: string, token: string): Promise<FavoriteApiResult<FavoriteListData>> {
  const requestUrl = `${normalizeBaseUrl(baseUrl)}/app/favorite/list`
  return requestApi<FavoriteListData>(requestUrl, {
    method: http.RequestMethod.GET,
    expectDataType: http.HttpDataType.STRING,
    usingCache: false,
    connectTimeout: 10000,
    readTimeout: 10000,
    header: buildTokenHeader(token)
  }, 'GET', token)
}
