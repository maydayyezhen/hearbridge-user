/**
 * 用户资料图片缓存 API 服务，只负责下载头像/头图二进制数据。
 */

import http from '@ohos.net.http'
import { buildUrl, resolveRequestToken } from '../../../api/HttpClient'

class ProfileImageRequestOptions implements http.HttpRequestOptions {
  method: http.RequestMethod = http.RequestMethod.GET
  expectDataType: http.HttpDataType = http.HttpDataType.ARRAY_BUFFER
  usingCache: boolean = false
  connectTimeout: number = 10000
  readTimeout: number = 10000
  header: Record<string, string> = new Object() as Record<string, string>
}

/**
 * 是否为绝对 URL。
 */
function isAbsoluteUrl(url: string): boolean {
  return url.indexOf('http://') === 0 || url.indexOf('https://') === 0
}

/**
 * 解析可请求的图片地址。
 */
function resolveDownloadUrl(urlOrPath: string): string {
  if (isAbsoluteUrl(urlOrPath)) return urlOrPath
  if (urlOrPath.length === 0) return ''
  if (urlOrPath.indexOf('/') === 0) return buildUrl(urlOrPath)
  return buildUrl(`/${urlOrPath}`)
}

/**
 * 构建图片下载请求参数。
 */
function buildImageRequestOptions(): http.HttpRequestOptions {
  const options = new ProfileImageRequestOptions()
  const token = resolveRequestToken()
  if (token.length > 0) {
    Reflect.set(options.header, 'token', token)
  }
  Reflect.set(options.header, 'Accept', 'image/*')
  return options
}

/**
 * 下载远端图片字节。
 */
export async function requestProfileImageBinary(urlOrPath: string): Promise<ArrayBuffer> {
  const requestUrl = resolveDownloadUrl(urlOrPath)
  if (requestUrl.length === 0) return new ArrayBuffer(0)

  const request = http.createHttp()
  try {
    const response = await request.request(requestUrl, buildImageRequestOptions())
    if (Number(response.responseCode) !== 200) {
      return new ArrayBuffer(0)
    }
    return response.result instanceof ArrayBuffer ? response.result : new ArrayBuffer(0)
  } catch (_error) {
    return new ArrayBuffer(0)
  } finally {
    request.destroy()
  }
}
