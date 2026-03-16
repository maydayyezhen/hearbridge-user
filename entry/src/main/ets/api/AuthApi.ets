import http from '@ohos.net.http'

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

async function requestApi<T>(url: string, options: http.HttpRequestOptions): Promise<ApiResult<T>> {
  const request = http.createHttp()

  try {
    const response = await request.request(url, options)
    const httpCode = Number(response.responseCode)
    const rawBody = stringifyResult(response.result)
    return parseEnvelope<T>(httpCode, rawBody)
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
  })
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
  })
}
