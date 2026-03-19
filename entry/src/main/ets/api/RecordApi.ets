import http from '@ohos.net.http'
import { recordApiDebug, stringifyDebugBody } from './ApiDebug'

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

export interface RecordSummaryDto {
  overallScore: number
  summaryTitle: string
  summaryAdvice: string
  completedDays: number
  completedItems: number
  completedCourses: number
  totalPracticeSeconds: number
}

export interface RecordTrendPointDto {
  label: string
  score: number
  practiceCount: number
  completedItemCount: number
  practiceSeconds: number
}

export interface RecordTrendDto {
  rangeType: string
  points: RecordTrendPointDto[]
}

export interface RecordTrendGroupDto {
  day: RecordTrendDto
  week: RecordTrendDto
  overview: RecordTrendDto
}

export interface RecordPerformanceDto {
  accuracyScore: number
  rhythmScore: number
  completionScore: number
  improvementRate: number
  weaknessTags: string[]
  strengthTags: string[]
  advice: string
}

export interface RecordRecentCourseDto {
  courseCode: string
  courseName: string
  coverUrl: string
  lastLearnedAt: string
  progressPercent: number
  lastItemCode: string
  lastItemName: string
  courseStatus: string
}

export interface RecordOverviewData {
  summary: RecordSummaryDto
  trends: RecordTrendGroupDto
  performance: RecordPerformanceDto
  recentCourses: RecordRecentCourseDto[]
}

function normalizeBaseUrl(baseUrl: string): string {
  return baseUrl.endsWith('/') ? baseUrl.slice(0, -1) : baseUrl
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

export async function getRecordOverview(baseUrl: string, token: string): Promise<ApiResult<RecordOverviewData>> {
  const requestUrl = `${normalizeBaseUrl(baseUrl)}/app/record/overview`
  const request = http.createHttp()
  try {
    const response = await request.request(requestUrl, {
      method: http.RequestMethod.GET,
      expectDataType: http.HttpDataType.STRING,
      usingCache: false,
      connectTimeout: 10000,
      readTimeout: 10000,
      header: {
        token
      }
    })
    const httpCode = Number(response.responseCode)
    const rawBody = stringifyResult(response.result)
    recordApiDebug('RecordApi', 'GET', requestUrl, token.length > 0, '', rawBody)
    return parseEnvelope<RecordOverviewData>(httpCode, rawBody)
  } catch (error) {
    recordApiDebug('RecordApi', 'GET', requestUrl, token.length > 0, '', `request error: ${JSON.stringify(error)}`)
    throw new Error(JSON.stringify(error))
  } finally {
    request.destroy()
  }
}
