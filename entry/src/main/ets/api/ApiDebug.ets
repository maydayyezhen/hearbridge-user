/**
 * ApiDebug 文件。
 */

/** API 调试文本写入器。 */
export type ApiDebugWriter = (text: string) => void

/** 当前注册的 API 调试文本写入器。 */
let apiDebugWriter: ApiDebugWriter | null = null

/**
 * 注册 API 调试文本写入器。
 */
export function setApiDebugWriter(writer: ApiDebugWriter | null): void {
  apiDebugWriter = writer
}

export function stringifyDebugBody(body: Object | string | ArrayBuffer | number | boolean | null | undefined): string {
  if (body === undefined) {
    return 'none'
  }
  if (body === null) {
    return 'null'
  }
  if (typeof body === 'string') {
    return body.length > 0 ? body : 'empty string'
  }
  if (typeof body === 'number' || typeof body === 'boolean') {
    return `${body}`
  }
  if (body instanceof ArrayBuffer) {
    return `ArrayBuffer(${body.byteLength})`
  }
  return JSON.stringify(body)
}

/** recordApiDebug。 */
export function recordApiDebug(
  method: string,
  path: string,
  hasToken: boolean,
  requestBody: string,
  responseBody: string,
  statusCode?: number,
  costMs?: number
): void {
  const debugText =
    `[HTTP] ${method} ${path}
` +
    `status: ${statusCode !== undefined ? statusCode : 'unknown'}
` +
    `cost: ${costMs !== undefined ? `${costMs}ms` : 'unknown'}
` +
    `token present: ${hasToken ? 'true' : 'false'}
` +
    `request body: ${requestBody}
` +
    `response: ${responseBody}`
  if (apiDebugWriter) {
    apiDebugWriter(debugText)
  }
}
