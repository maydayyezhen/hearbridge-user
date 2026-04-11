/**
 * FileUploadApi 相关的请求函数与接口访问逻辑。
 */

import http from '@ohos.net.http'
import { ApiResult } from '../common/Http'
import { requestApi } from '../HttpClient'

/** 上传接口响应源对象。 */
export interface UploadedFileResponseSource {
  fileUrl?: string
  url?: string
}

/** resolveUploadedFileUrl。 */
function resolveUploadedFileUrl(data: string | UploadedFileResponseSource | null): string | null {
  if (typeof data === 'string') {
    return data
  }
  if (data && typeof data.fileUrl === 'string') {
    return data.fileUrl
  }
  if (data && typeof data.url === 'string') {
    return data.url
  }
  return null
}

/** uploadBinaryFile。 */
export async function uploadBinaryFile(fileName: string, fileBytes: ArrayBuffer): Promise<ApiResult<string>> {
  const result = await requestApi<string | UploadedFileResponseSource>({
    path: '/app/file/upload/binary',
    method: http.RequestMethod.POST,
    headers: {
      'X-Filename': fileName,
      'Content-Type': 'application/octet-stream'
    },
    body: fileBytes
  })

  const mapped: ApiResult<string> = {
    httpCode: result.httpCode,
    code: result.code,
    message: result.message,
    data: resolveUploadedFileUrl(result.data),
    rawBody: result.rawBody,
    ok: result.ok
  }
  return mapped
}
