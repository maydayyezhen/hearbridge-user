/**
 * Http 文件。
 */

export interface ApiEnvelope<T = object> {
  code: number
  message: string
  data: T | null
}

/** ApiResult。 */
export interface ApiResult<T = object> extends ApiEnvelope<T> {
  httpCode: number
  ok: boolean
  rawBody: string
}
