import http from '@ohos.net.http'
import { recordApiDebug } from './ApiDebug'

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

export interface BootstrapMediaConfig {
  mediaUrl: string
  title: string
  subtitle: string
  jumpType: string
  jumpValue: string
}

export interface BootstrapRecommendConfig {
  courseCode: string
  courseName: string
  coverUrl: string
  recommendText: string
  durationText: string
  jumpType: string
  jumpValue: string
}

export interface BootstrapConfigData {
  homeHero: BootstrapMediaConfig | null
  homeRecommend: BootstrapRecommendConfig | null
  appSplash: BootstrapMediaConfig | null
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

export async function getBootstrapConfig(baseUrl: string): Promise<ApiResult<BootstrapConfigData>> {
  const request = http.createHttp()
  const requestUrl = `${normalizeBaseUrl(baseUrl)}/app/config/bootstrap`
  try {
    const response = await request.request(requestUrl, {
      method: http.RequestMethod.GET,
      expectDataType: http.HttpDataType.STRING,
      usingCache: false,
      connectTimeout: 10000,
      readTimeout: 10000
    })
    const httpCode = Number(response.responseCode)
    const rawBody = stringifyResult(response.result)
    recordApiDebug('ConfigApi', 'GET', requestUrl, false, 'none', rawBody)
    return parseEnvelope<BootstrapConfigData>(httpCode, rawBody)
  } catch (error) {
    const errorText = JSON.stringify(error)
    recordApiDebug('ConfigApi', 'GET', requestUrl, false, 'none', `request error: ${errorText}`)
    throw new Error(errorText)
  } finally {
    request.destroy()
  }
}
