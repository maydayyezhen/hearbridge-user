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

export function recordApiDebug(moduleName: string, method: string, url: string, hasToken: boolean, requestBody: string,
  responseBody: string): void {
  const debugText =
    `module: ${moduleName}\n` +
    `method: ${method}\n` +
    `url: ${url}\n` +
    `token present: ${hasToken ? 'true' : 'false'}\n` +
    `request body: ${requestBody}\n` +
    `response: ${responseBody}`
  AppStorage.setOrCreate('apiDebugText', debugText)
}
