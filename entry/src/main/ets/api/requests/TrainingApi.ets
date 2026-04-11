/**
 * TrainingApi 相关的请求函数与接口访问逻辑。
 */

import http from '@ohos.net.http'
import { ApiResult } from '../common/Http'
import { requestApi } from '../HttpClient'

class StartTrainingSessionPayload {
  courseCode: string = ''
}

class SubmitTrainingItemPayload {
  submitType: string = ''
  fileUrl: string = ''
  fileName: string = ''
  mimeType: string = ''
  recognizedText: string = ''
  partialText: string = ''
  submitResult: string = ''
  viewedDemo: boolean = false
  finished: boolean = false
  retried: boolean = false
  firstSuccess: boolean = false
}

/** 训练会话启动响应源对象。 */
export interface StartTrainingSessionResponseSource {
  sessionId?: number | string
  resumeMode?: string
  currentItemCode?: string
  currentItemStatus?: string
  progressPercent?: number | string
  completedItemCount?: number | string
  totalItemCount?: number | string
}

/** 训练会话详情中的训练项源对象。 */
export interface TrainingSessionDetailItemSource {
  id?: number | string
  itemName?: string
  itemCode?: string
  levelNum?: number | string
  itemOrder?: number | string
  status?: string
}

/** 训练会话详情响应源对象。 */
export interface TrainingSessionDetailResponseSource {
  sessionId?: number | string
  courseCode?: string
  courseName?: string
  coverUrl?: string
  progressPercent?: number | string
  completedItemCount?: number | string
  totalItemCount?: number | string
  currentItemCode?: string
  trainingType?: string
  status?: string
  favorite?: boolean
  startedAt?: string
  lastActiveAt?: string
  completedAt?: string | null
  items?: TrainingSessionDetailItemSource[]
}

/** 训练项媒体资源源对象。 */
export interface TrainingItemResourceSource {
  resourceType?: string
  fileName?: string
  fileUrl?: string
  sortNum?: number | string
}

/** 单个训练项详情响应源对象。 */
export interface TrainingItemDetailResponseSource {
  sessionId?: number | string
  courseCode?: string
  trainingType?: string
  itemName?: string
  itemCode?: string
  levelNum?: number | string
  itemOrder?: number | string
  status?: string
  score?: number | string | null
  attemptCount?: number | string
  durationSeconds?: number | string
  meaning?: string
  description?: string
  goal?: string
  precautions?: string[]
  commonErrors?: string[]
  tags?: string[]
  resources?: TrainingItemResourceSource[]
  feedback?: string | null
  startedAt?: string | null
  submittedAt?: string | null
  completedAt?: string | null
}

/** 训练结果标签区块源对象。 */
export interface SubmitTrainingTagSectionSource {
  title?: string
  tags?: string[]
  description?: string
}

/** 训练结果趋势区块源对象。 */
export interface SubmitTrainingTrendSource {
  title?: string
  scores?: number[]
  description?: string
}

/** 训练结果维度源对象。 */
export interface SubmitTrainingDimensionSource {
  label?: string
  score?: number | string
}

/** 训练结果详情源对象。 */
export interface SubmitTrainingResultDetailSource {
  title?: string
  scoreLabel?: string
  badges?: string[]
  dimensions?: SubmitTrainingDimensionSource[]
  strengths?: SubmitTrainingTagSectionSource | null
  improvements?: SubmitTrainingTagSectionSource | null
  recentTrend?: SubmitTrainingTrendSource | null
}

/** 提交训练项响应源对象。 */
export interface SubmitTrainingItemResponseSource {
  sessionId?: number | string
  courseCode?: string
  courseName?: string
  trainingType?: string
  itemCode?: string
  itemName?: string
  itemOrder?: number | string
  itemStatus?: string
  evaluationStatus?: string
  score?: number | string
  feedback?: string
  nextItemCode?: string
  nextItemName?: string
  nextItemStatus?: string
  progressPercent?: number | string
  completedItemCount?: number | string
  totalItemCount?: number | string
  courseCompleted?: boolean
  submittedAt?: string | null
  completedAt?: string | null
  resultDetail?: SubmitTrainingResultDetailSource | null
}

/** 最近训练课程单项源对象。 */
export interface RecentTrainingCourseSource {
  courseCode?: string
  courseName?: string
  lastLearnedAt?: string
  lastLearnAt?: string
  coverUrl?: string
  progressPercent?: number | string
}

/** 最近训练课程列表响应源对象。 */
export interface RecentTrainingCourseListResponseSource {
  list?: RecentTrainingCourseSource[]
  total?: number | string
  pageNo?: number | string
}

/** 训练会话进度响应源对象。 */
export interface TrainSessionProgressResponseSource {
  progressPercent?: number | string
}

export interface TrainSummaryDimensionSource {
  key?: string
  label?: string
  score?: number | string
  description?: string
}

export interface TrainSummaryTrendSource {
  title?: string
  scores?: Array<number | string>
  labels?: string[]
  description?: string
}

export interface TrainSummarySuggestionSource {
  title?: string
  description?: string
}

export interface TrainSummaryHighlightItemSource {
  itemCode?: string
  itemName?: string
  score?: number | string
  status?: string
}

export interface TrainSessionSummaryResponseSource {
  sessionId?: number | string
  courseCode?: string
  courseName?: string
  trainingType?: string
  summaryMode?: string
  textSource?: string
  completedCount?: number | string
  totalCount?: number | string
  completionPercent?: number | string
  averageScore?: number | string
  bestScore?: number | string
  summaryTitle?: string
  summaryDescription?: string
  badges?: string[]
  dimensions?: TrainSummaryDimensionSource[]
  trend?: TrainSummaryTrendSource | null
  suggestions?: TrainSummarySuggestionSource[]
  highlightItems?: TrainSummaryHighlightItemSource[]
  completedAt?: string | null
}

/** startTrainingSession。 */
export async function startTrainingSession(courseCode: string): Promise<ApiResult<StartTrainingSessionResponseSource>> {
  const payload = new StartTrainingSessionPayload()
  payload.courseCode = courseCode
  return await requestApi<StartTrainingSessionResponseSource>({
    path: '/app/training/session/start',
    method: http.RequestMethod.POST,
    body: payload
  })
}

/** getTrainingSessionDetail。 */
export async function getTrainingSessionDetail(sessionId: number): Promise<ApiResult<TrainingSessionDetailResponseSource>> {
  return await requestApi<TrainingSessionDetailResponseSource>({
    path: `/app/training/session/${sessionId}`,
    method: http.RequestMethod.GET
  })
}

/** getTrainingItemDetail。 */
export async function getTrainingItemDetail(sessionId: number, itemCode: string): Promise<ApiResult<TrainingItemDetailResponseSource>> {
  return await requestApi<TrainingItemDetailResponseSource>({
    path: `/app/training/session/${sessionId}/item/${encodeURIComponent(itemCode)}`,
    method: http.RequestMethod.GET
  })
}

/** submitTrainingItem。 */
export async function submitTrainingItem(
  sessionId: number,
  itemCode: string,
  submitType: string,
  fileUrl: string,
  fileName: string,
  mimeType: string,
  recognizedText: string,
  partialText: string,
  submitResult: string,
  viewedDemo: boolean,
  finished: boolean,
  retried: boolean,
  firstSuccess: boolean
): Promise<ApiResult<SubmitTrainingItemResponseSource>> {
  const payload = new SubmitTrainingItemPayload()
  payload.submitType = submitType
  payload.fileUrl = fileUrl
  payload.fileName = fileName
  payload.mimeType = mimeType
  payload.recognizedText = recognizedText
  payload.partialText = partialText
  payload.submitResult = submitResult
  payload.viewedDemo = viewedDemo
  payload.finished = finished
  payload.retried = retried
  payload.firstSuccess = firstSuccess
  return await requestApi<SubmitTrainingItemResponseSource>({
    path: `/app/training/session/${sessionId}/item/${encodeURIComponent(itemCode)}/submit`,
    method: http.RequestMethod.POST,
    body: payload,
    readTimeout: 60000
  })
}

/** pauseTrainingSession。 */
export async function pauseTrainingSession(sessionId: number): Promise<ApiResult<TrainSessionProgressResponseSource>> {
  return await requestApi<TrainSessionProgressResponseSource>({
    path: `/app/training/session/${sessionId}/pause`,
    method: http.RequestMethod.POST
  })
}

/** completeTrainingSession。 */
export async function completeTrainingSession(sessionId: number): Promise<ApiResult<TrainSessionProgressResponseSource>> {
  return await requestApi<TrainSessionProgressResponseSource>({
    path: `/app/training/session/${sessionId}/complete`,
    method: http.RequestMethod.POST
  })
}

/** getRecentTrainingCourses。 */
export async function getRecentTrainingCourses(path: string): Promise<ApiResult<RecentTrainingCourseListResponseSource>> {
  return await requestApi<RecentTrainingCourseListResponseSource>({
    path,
    method: http.RequestMethod.GET
  })
}

export async function getTrainingSessionSummary(sessionId: number): Promise<ApiResult<TrainSessionSummaryResponseSource>> {
  return await requestApi<TrainSessionSummaryResponseSource>({
    path: `/app/training/session/${sessionId}/summary`,
    method: http.RequestMethod.GET,
    readTimeout: 60000
  })
}
