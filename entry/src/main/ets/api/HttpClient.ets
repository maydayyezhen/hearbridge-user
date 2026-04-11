/**
 * HttpClient 文件。
 */

import http from '@ohos.net.http'
import { stringifyDebugBody, recordApiDebug } from './ApiDebug'
import { APP_API_BASE_URL } from '../config/AppConfig'
import { ApiEnvelope, ApiResult } from './common/Http'

/** AuthTokenProvider。 */
type AuthTokenProvider = () => string

class RequestOptionsBag implements http.HttpRequestOptions {
  method: http.RequestMethod = http.RequestMethod.GET
  expectDataType: http.HttpDataType = http.HttpDataType.STRING
  usingCache: boolean = false
  connectTimeout: number = 10000
  readTimeout: number = 10000
  header: Record<string, string> = new Object() as Record<string, string>
  extraData?: Object | string | ArrayBuffer
}

class ApiResultBox<T> implements ApiResult<T> {
  httpCode: number = 0
  code: number = 0
  message: string = ''
  data: T | null = null
  rawBody: string = ''
  ok: boolean = false
}

let authTokenProvider: AuthTokenProvider | null = null

/** RequestDescriptor。 */
export interface RequestDescriptor {
  path: string
  method: http.RequestMethod
  headers?: Record<string, string>
  body?: Object | string | ArrayBuffer
  connectTimeout?: number
  readTimeout?: number
  expectDataType?: http.HttpDataType
}

/** buildUrl。 */
export function buildUrl(pathOrBase: string, maybePath?: string): string {
  const normalizedBaseUrl = APP_API_BASE_URL.endsWith('/') ? APP_API_BASE_URL.slice(0, -1) : APP_API_BASE_URL
  const rawPath = maybePath ?? pathOrBase
  const normalizedPath = rawPath.startsWith('/') ? rawPath : `/${rawPath}`
  return `${normalizedBaseUrl}${normalizedPath}`
}

/** setHttpAuthTokenProvider。 */
export function setHttpAuthTokenProvider(provider: AuthTokenProvider): void {
  authTokenProvider = provider
}

/** clearHttpAuthTokenProvider。 */
export function clearHttpAuthTokenProvider(): void {
  authTokenProvider = null
}

/** resolveRequestToken。 */
export function resolveRequestToken(): string {
  return authTokenProvider ? authTokenProvider() : ''
}

/** buildRequestHeaders。 */
export function buildRequestHeaders(descriptor: RequestDescriptor): Record<string, string> {
  const headers = new Object() as Record<string, string>
  Reflect.set(headers, 'Accept', 'application/json')

  if (descriptor.body instanceof ArrayBuffer) {
    Reflect.set(headers, 'Content-Type', 'application/octet-stream')
  } else {
    Reflect.set(headers, 'Content-Type', 'application/json')
  }

  const token = resolveRequestToken()
  if (token.length > 0) {
    Reflect.set(headers, 'token', token)
  }

  if (descriptor.headers) {
    const customHeaderKeys = Object.keys(descriptor.headers)
    for (let i = 0; i < customHeaderKeys.length; i += 1) {
      const key = customHeaderKeys[i]
      Reflect.set(headers, key, descriptor.headers[key])
    }
  }

  return headers
}

/** buildRequestOptions。 */
export function buildRequestOptions(descriptor: RequestDescriptor): http.HttpRequestOptions {
  const options: RequestOptionsBag = new RequestOptionsBag()
  options.method = descriptor.method
  options.expectDataType = descriptor.expectDataType ?? http.HttpDataType.STRING
  options.usingCache = false
  options.connectTimeout = descriptor.connectTimeout ?? 10000
  options.readTimeout = descriptor.readTimeout ?? 10000
  options.header = buildRequestHeaders(descriptor)

  if (descriptor.body !== undefined) {
    options.extraData = descriptor.body
  }

  return options
}

/** toRequestMethodLabel。 */
function toRequestMethodLabel(method: http.RequestMethod): string {
  switch (method) {
    case http.RequestMethod.GET:
      return 'GET'
    case http.RequestMethod.POST:
      return 'POST'
    case http.RequestMethod.PUT:
      return 'PUT'
    case http.RequestMethod.DELETE:
      return 'DELETE'
    case http.RequestMethod.HEAD:
      return 'HEAD'
    case http.RequestMethod.OPTIONS:
      return 'OPTIONS'
    case http.RequestMethod.TRACE:
      return 'TRACE'
    case http.RequestMethod.CONNECT:
      return 'CONNECT'
    default:
      return `${method}`
  }
}

/** stringifyResult。 */
export function stringifyResult(result: string | Object | ArrayBuffer): string {
  if (typeof result === 'string') {
    return result
  }
  if (result instanceof ArrayBuffer) {
    return `binary response, size=${result.byteLength}`
  }
  return JSON.stringify(result)
}

/** parseEnvelope。 */
export function parseEnvelope<T = object>(httpCode: number, rawBody: string): ApiResult<T> {
  try {
    const parsed = JSON.parse(rawBody) as ApiEnvelope<T>
    const result = new ApiResultBox<T>()
    const businessCode = Number(parsed.code ?? httpCode)
    result.httpCode = httpCode
    result.code = businessCode
    result.message = parsed.message ?? ''
    result.data = parsed.data ?? null
    result.rawBody = rawBody
    result.ok = httpCode === 200 && (businessCode === 0 || businessCode === 200)
    return result
  } catch (_error) {
    const result = new ApiResultBox<T>()
    result.httpCode = httpCode
    result.code = httpCode
    result.message = rawBody
    result.data = null
    result.rawBody = rawBody
    result.ok = false
    return result
  }
}

/** requestApi。 */
export async function requestApi<T = object>(descriptor: RequestDescriptor): Promise<ApiResult<T>> {
  const request = http.createHttp()
  const requestUrl = buildUrl(descriptor.path)
  const resolvedToken = resolveRequestToken()
  const debugBody = stringifyDebugBody(descriptor.body)
  const startedAt = Date.now()

  try {
    const response = await request.request(requestUrl, buildRequestOptions(descriptor))
    const httpCode = Number(response.responseCode)
    const rawBody = stringifyResult(response.result)
    recordApiDebug(toRequestMethodLabel(descriptor.method), descriptor.path, resolvedToken.length > 0, debugBody, rawBody, httpCode,
      Date.now() - startedAt)
    return parseEnvelope<T>(httpCode, rawBody)
  } catch (error) {
    const errorText = `request error: ${JSON.stringify(error)}`
    recordApiDebug(toRequestMethodLabel(descriptor.method), descriptor.path, resolvedToken.length > 0, debugBody, errorText, 0,
      Date.now() - startedAt)
    const result = new ApiResultBox<T>()
    result.httpCode = 0
    result.code = 0
    result.message = errorText
    result.data = null
    result.rawBody = errorText
    result.ok = false
    return result
  } finally {
    request.destroy()
  }
}
