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

export interface TrainingResourceDto {
  resourceType: string
  fileName: string
  fileUrl: string
  sortNum: number
}

export interface TrainingSessionItemDto {
  itemCode: string
  itemName: string
  itemOrder: number
  levelNum: number
  status: string
}

export interface TrainingSessionItemDetailDto {
  itemCode: string
  itemName: string
  itemOrder: number
  levelNum: number
  status: string
  score: number | null
  attemptCount: number
  durationSeconds: number
  meaning: string
  description: string
  goal: string
  precautions: string[]
  commonErrors: string[]
  tags: string[]
  resources: TrainingResourceDto[]
  feedback: string | null
  startedAt: string | null
  submittedAt: string | null
  completedAt: string | null
}

export interface StartTrainingSessionData {
  sessionId: number
  resumeMode: string
  currentItemCode: string
  currentItemStatus: string
  progressPercent: number
  completedItemCount: number
  totalItemCount: number
}

export interface TrainingSessionDetailData {
  sessionId: number
  courseCode: string
  courseName: string
  coverUrl: string
  trainingType: string
  status: string
  currentItemCode: string
  progressPercent: number
  completedItemCount: number
  totalItemCount: number
  favorite: boolean
  startedAt: string
  lastActiveAt: string
  completedAt: string | null
  items: TrainingSessionItemDto[]
}

export interface TrainingItemDetailData {
  sessionId: number
  courseCode: string
  trainingType: string
  itemCode: string
  itemName: string
  itemOrder: number
  levelNum: number
  status: string
  score: number | null
  attemptCount: number
  durationSeconds: number
  meaning: string
  description: string
  goal: string
  precautions: string[]
  commonErrors: string[]
  tags: string[]
  resources: TrainingResourceDto[]
  feedback: string | null
  startedAt: string | null
  submittedAt: string | null
  completedAt: string | null
}

export interface SubmitTrainingItemPayload {
  submitType: string
  fileUrl: string
  fileName?: string
  mimeType?: string
  fileSize?: number
  fileDuration?: number
  recognizedText?: string
  partialText?: string
  submitResult?: string
  viewedDemo?: boolean
  finished?: boolean
  retried?: boolean
  firstSuccess?: boolean
}

export interface TrainingResultDimensionDto {
  key: string
  label: string
  score: number
}

export interface TrainingResultTagModuleDto {
  title: string
  tags: string[]
  description: string
}

export interface TrainingResultTrendDto {
  title: string
  scores: number[]
  description: string
}

export interface TrainingResultDetailDto {
  title: string
  scoreLabel: string
  badges: string[]
  dimensions: TrainingResultDimensionDto[]
  strengths: TrainingResultTagModuleDto | null
  improvements: TrainingResultTagModuleDto | null
  recentTrend: TrainingResultTrendDto | null
}

export interface SubmitTrainingItemData {
  sessionId: number
  courseCode: string
  courseName: string
  trainingType: string
  itemCode: string
  itemName: string
  itemOrder: number
  itemStatus: string
  evaluationStatus: string
  score: number
  feedback: string
  nextItemCode: string | null
  nextItemName: string | null
  nextItemStatus: string | null
  progressPercent: number
  completedItemCount: number
  totalItemCount: number
  courseCompleted: boolean
  submittedAt: string | null
  completedAt: string | null
  resultDetail: TrainingResultDetailDto | null
}

export interface PauseTrainingSessionData {
  sessionId: number
  status: string
  currentItemCode: string
  lastActiveAt: string
  progressPercent: number
}

export interface CompleteTrainingSessionData {
  sessionId: number
  status: string
  completedAt: string
  totalScore: number | null
  progressPercent: number
  completedItemCount: number
  totalItemCount: number
}

export interface RecentTrainingCourseItemDto {
  courseCode: string
  courseName: string
  coverUrl: string
  trainingType: string
  sessionId: number
  currentItemCode: string | null
  currentItemName: string | null
  progressPercent: number
  completedItemCount: number
  totalItemCount: number
  status: string
  lastLearnedAt: string
}

export interface RecentTrainingCourseData {
  list: RecentTrainingCourseItemDto[]
  pageNo: number
  pageSize: number
  total: number
}

interface TokenHeader {
  token: string
}

interface JsonTokenHeader extends TokenHeader {
  'Content-Type': string
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

async function requestApi<T>(url: string, options: http.HttpRequestOptions, debugMethod: string, hasToken: boolean,
  debugBody: string): Promise<ApiResult<T>> {
  const request = http.createHttp()
  try {
    const response = await request.request(url, options)
    const httpCode = Number(response.responseCode)
    const rawBody = stringifyResult(response.result)
    recordApiDebug('TrainingApi', debugMethod, url, hasToken, debugBody, rawBody)
    return parseEnvelope<T>(httpCode, rawBody)
  } catch (error) {
    recordApiDebug('TrainingApi', debugMethod, url, hasToken, debugBody, `request error: ${JSON.stringify(error)}`)
    throw new Error(JSON.stringify(error))
  } finally {
    request.destroy()
  }
}

function buildTokenHeader(token: string, withJson: boolean = false): TokenHeader | JsonTokenHeader {
  if (withJson) {
    return {
      'Content-Type': 'application/json',
      token
    }
  }
  return {
    token
  }
}

export async function startTrainingSession(baseUrl: string, token: string, courseCode: string): Promise<ApiResult<StartTrainingSessionData>> {
  const requestUrl = `${normalizeBaseUrl(baseUrl)}/app/training/session/start`
  const requestBody = JSON.stringify({
    courseCode
  })
  return requestApi<StartTrainingSessionData>(requestUrl, {
    method: http.RequestMethod.POST,
    expectDataType: http.HttpDataType.STRING,
    usingCache: false,
    connectTimeout: 10000,
    readTimeout: 10000,
    header: buildTokenHeader(token, true),
    extraData: requestBody
  }, 'POST', token.length > 0, requestBody)
}

export async function getTrainingSessionDetail(baseUrl: string, token: string, sessionId: number): Promise<ApiResult<TrainingSessionDetailData>> {
  const requestUrl = `${normalizeBaseUrl(baseUrl)}/app/training/session/${sessionId}`
  return requestApi<TrainingSessionDetailData>(requestUrl, {
    method: http.RequestMethod.GET,
    expectDataType: http.HttpDataType.STRING,
    usingCache: false,
    connectTimeout: 10000,
    readTimeout: 10000,
    header: buildTokenHeader(token)
  }, 'GET', token.length > 0, 'none')
}

export async function getTrainingItemDetail(baseUrl: string, token: string, sessionId: number,
  itemCode: string): Promise<ApiResult<TrainingItemDetailData>> {
  const requestUrl = `${normalizeBaseUrl(baseUrl)}/app/training/session/${sessionId}/item/${encodeURIComponent(itemCode)}`
  return requestApi<TrainingItemDetailData>(requestUrl, {
    method: http.RequestMethod.GET,
    expectDataType: http.HttpDataType.STRING,
    usingCache: false,
    connectTimeout: 10000,
    readTimeout: 10000,
    header: buildTokenHeader(token)
  }, 'GET', token.length > 0, 'none')
}

export async function submitTrainingItem(baseUrl: string, token: string, sessionId: number, itemCode: string,
  payload: SubmitTrainingItemPayload): Promise<ApiResult<SubmitTrainingItemData>> {
  const requestUrl = `${normalizeBaseUrl(baseUrl)}/app/training/session/${sessionId}/item/${encodeURIComponent(itemCode)}/submit`
  const requestBody = JSON.stringify(payload)
  return requestApi<SubmitTrainingItemData>(requestUrl, {
    method: http.RequestMethod.POST,
    expectDataType: http.HttpDataType.STRING,
    usingCache: false,
    connectTimeout: 100000,
    readTimeout: 100000,
    header: buildTokenHeader(token, true),
    extraData: requestBody
  }, 'POST', token.length > 0, requestBody)
}

export async function pauseTrainingSession(baseUrl: string, token: string, sessionId: number): Promise<ApiResult<PauseTrainingSessionData>> {
  const requestUrl = `${normalizeBaseUrl(baseUrl)}/app/training/session/${sessionId}/pause`
  return requestApi<PauseTrainingSessionData>(requestUrl, {
    method: http.RequestMethod.POST,
    expectDataType: http.HttpDataType.STRING,
    usingCache: false,
    connectTimeout: 10000,
    readTimeout: 10000,
    header: buildTokenHeader(token)
  }, 'POST', token.length > 0, 'none')
}

export async function completeTrainingSession(baseUrl: string, token: string, sessionId: number): Promise<ApiResult<CompleteTrainingSessionData>> {
  const requestUrl = `${normalizeBaseUrl(baseUrl)}/app/training/session/${sessionId}/complete`
  return requestApi<CompleteTrainingSessionData>(requestUrl, {
    method: http.RequestMethod.POST,
    expectDataType: http.HttpDataType.STRING,
    usingCache: false,
    connectTimeout: 10000,
    readTimeout: 10000,
    header: buildTokenHeader(token)
  }, 'POST', token.length > 0, 'none')
}

export async function getRecentTrainingCourses(baseUrl: string, token: string, pageNo: number = 1,
  pageSize: number = 10): Promise<ApiResult<RecentTrainingCourseData>> {
  const requestUrl = `${normalizeBaseUrl(baseUrl)}/app/training/recent-course?pageNo=${pageNo}&pageSize=${pageSize}`
  return requestApi<RecentTrainingCourseData>(requestUrl, {
    method: http.RequestMethod.GET,
    expectDataType: http.HttpDataType.STRING,
    usingCache: false,
    connectTimeout: 10000,
    readTimeout: 10000,
    header: buildTokenHeader(token)
  }, 'GET', token.length > 0, `{"pageNo":${pageNo},"pageSize":${pageSize}}`)
}
