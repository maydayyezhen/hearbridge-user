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

export interface CourseListItemDto {
  courseCode: string
  courseName: string
  intro: string
  coverUrl: string
  trainingType: string
  tags: string[]
  learnCount: number
  difficultyLevel: number
  updatedAt: string
  status: string
}

export interface CourseListData {
  list: CourseListItemDto[]
  pageNo: number
  pageSize: number
  total: number
}

export interface CourseDetailData extends CourseListItemDto {}

export interface CourseListQuery {
  keyword?: string
  trainingType?: string
  tags?: string[]
  sortBy?: string
  pageNo?: number
  pageSize?: number
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

function appendQuery(url: string, query: CourseListQuery): string {
  const params: string[] = []
  if (query.keyword && query.keyword.trim().length > 0) {
    params.push(`keyword=${encodeURIComponent(query.keyword.trim())}`)
  }
  if (query.trainingType && query.trainingType.trim().length > 0) {
    params.push(`trainingType=${encodeURIComponent(query.trainingType.trim())}`)
  }
  if (query.tags && query.tags.length > 0) {
    for (let i = 0; i < query.tags.length; i += 1) {
      if (query.tags[i].trim().length > 0) {
        params.push(`tags=${encodeURIComponent(query.tags[i].trim())}`)
      }
    }
  }
  if (query.sortBy && query.sortBy.trim().length > 0) {
    params.push(`sortBy=${encodeURIComponent(query.sortBy.trim())}`)
  }
  if (query.pageNo && query.pageNo > 0) {
    params.push(`pageNo=${query.pageNo}`)
  }
  if (query.pageSize && query.pageSize > 0) {
    params.push(`pageSize=${query.pageSize}`)
  }
  if (params.length === 0) {
    return url
  }
  return `${url}?${params.join('&')}`
}

export async function getCourseList(baseUrl: string, token: string, query: CourseListQuery): Promise<ApiResult<CourseListData>> {
  let requestUrl = `${normalizeBaseUrl(baseUrl)}/app/course/list`
  requestUrl = appendQuery(requestUrl, query)
  return requestApi<CourseListData>(requestUrl, {
    method: http.RequestMethod.GET,
    expectDataType: http.HttpDataType.STRING,
    usingCache: false,
    connectTimeout: 10000,
    readTimeout: 10000,
    header: {
      token
    }
  })
}

export async function getCourseDetail(baseUrl: string, token: string, courseCode: string): Promise<ApiResult<CourseDetailData>> {
  const requestUrl = `${normalizeBaseUrl(baseUrl)}/app/course/detail/${encodeURIComponent(courseCode)}`
  return requestApi<CourseDetailData>(requestUrl, {
    method: http.RequestMethod.GET,
    expectDataType: http.HttpDataType.STRING,
    usingCache: false,
    connectTimeout: 10000,
    readTimeout: 10000,
    header: {
      token
    }
  })
}

