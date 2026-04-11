/**
 * 课程详情 API 业务服务，负责详情缓存回填、会话映射与详情页读模型组装。
 * 链路分层：
 * 1) 先用 createPageDataFromCache 做本地预热。
 * 2) 详情缓存缺失时补拉课程详情接口。
 * 3) 会话缓存缺失或异常时补拉会话接口并回写。
 * 4) 将会话与训练项统一归并到 CourseDetailPageData 返回给页面。
 */

import { getCourseDetail } from '../../../api/requests/CourseApi'
import { ApiResult } from '../../../api/common/Http'
import { TrainingSessionDetailItemSource, TrainingSessionDetailResponseSource } from '../../../api/requests/TrainingApi'
import { CourseDetailSource } from '../../../api/requests/CourseApi'
import { hilog } from '@kit.PerformanceAnalysisKit'
import { getCoursePreview } from '../../../repository/course/CoursePreviewRepository'
import { getCourseDetailCache, setCourseDetailCache } from '../../../repository/course/CourseDetailRepository'
import { CourseSessionCacheEntry, CourseSessionItemSnapshot, getCourseSessionCache } from '../../../repository/course/CourseSessionRepository'
import { getCourseTrainingItems, upsertCourseTrainingItemPreviews } from '../../../repository/training-item/CourseTrainingItemIndexRepository'
import { DEFAULT_COURSE_COVER_URL } from '../../../config/AppConfig'
import { TrainingContentItem } from '../../../domain/static/train/TrainingContentModels'
import { TrainItemStatus, TrainingType } from '../../../domain/static/train/TrainingRuntimeTypes'
import { CourseDetailPageData } from '../model/CourseDetailPageData'
import { CourseSessionItemsViewModel } from '../model/CourseSessionItemsViewModel'
import { mapSessionItemToTrainingContentItem } from '../../training/mapper/TrainingContentItemMapper'
import { normalizeTrainItemStatus, normalizeTrainingType } from '../../../utils/TrainingTypeUtil'
import { mapCourseDetailSourceToCacheInput } from '../mapper/CourseApiMapper'
import {
  fetchTrainSessionDetail,
  StartTrainingSessionResponseSource,
  startTrainSession
} from '../../training/api/TrainSessionApiService'
import { cacheTrainingSessionDetail } from '../../training/cache/TrainSessionCacheService'

const COURSE_DETAIL_TRACE_DOMAIN = 0x0000
const COURSE_DETAIL_TRACE_TAG = 'CourseDetailTrace'

type CourseDetailFieldValue = string | number | boolean | Object | CourseDetailFieldValue[] | null | undefined

function traceCourseDetail(stage: string, message: string): void {
  hilog.info(COURSE_DETAIL_TRACE_DOMAIN, COURSE_DETAIL_TRACE_TAG, '[%{public}s] %{public}s', stage, message)
}

function readObjectByKeys(source: Object, keys: string[]): Object | undefined {
  for (let i = 0; i < keys.length; i += 1) {
    const value = Reflect.get(source, keys[i]) as CourseDetailFieldValue
    if (value !== null && value !== undefined && typeof value === 'object' && !Array.isArray(value)) {
      return value as Object
    }
  }
  return undefined
}

function resolveNestedPayload(payload: Object): Object {
  let resolved = payload
  const nestedKeys = ['data', 'detail', 'result', 'session', 'sessionDetail']
  for (let depth = 0; depth < 4; depth += 1) {
    const nextPayload = readObjectByKeys(resolved, nestedKeys)
    if (!nextPayload) {
      break
    }
    resolved = nextPayload
  }
  return resolved
}

function parsePayloadFromRawBody(rawBody: string): Object | null {
  if (rawBody.length <= 0) {
    return null
  }
  try {
    const parsed = JSON.parse(rawBody) as CourseDetailFieldValue
    if (!parsed || typeof parsed !== 'object' || Array.isArray(parsed)) {
      return null
    }
    return resolveNestedPayload(parsed as Object)
  } catch (_error) {
    return null
  }
}

function resolveApiPayload<T extends Object>(result: ApiResult<T>): T | null {
  if (result.data && typeof result.data === 'object') {
    return resolveNestedPayload(result.data as Object) as T
  }
  if (result.httpCode === 200) {
    return parsePayloadFromRawBody(result.rawBody) as T | null
  }
  return null
}

interface CourseDetailViewData {
  courseName: string
  intro: string
  coverUrl: string
  trainingType: TrainingType
  tags: string[]
}

/** createPageDataFromCache。 */
function createPageDataFromCache(courseCode: string): CourseDetailPageData {
  // 第 1 步：先从 detail/preview 两级缓存恢复课程静态字段。
  const pageData = new CourseDetailPageData()
  pageData.courseCode = courseCode
  const detail = getCourseDetailCache(courseCode)
  const preview = getCoursePreview(courseCode)
  pageData.courseName = String(detail?.courseName ?? preview?.courseName ?? '课程详情')
  pageData.courseIntro = String(detail?.intro ?? preview?.intro ?? '')
  pageData.coverUrl = String(detail?.coverUrl ?? preview?.coverUrl ?? DEFAULT_COURSE_COVER_URL)
  pageData.trainingType = normalizeTrainingType(String(detail?.trainingType ?? preview?.trainingType ?? 'gesture'))
  pageData.tags = detail?.tags ?? preview?.tags ?? []
  // 第 2 步：从训练项索引恢复课程训练项（优先 detail，回退 preview）。
  applyCachedCourseItems(pageData, getCourseTrainingItems(courseCode))
  // 第 3 步：若已存在课程会话缓存，补齐进度、当前项等动态字段。
  const cachedSession = getCourseSessionCache(courseCode)
  if (cachedSession) applySessionCache(pageData, cachedSession)
  normalizeCourseStats(pageData)
  return pageData
}

/** applyCachedCourseItems。 */
function applyCachedCourseItems(pageData: CourseDetailPageData, items: TrainingContentItem[]): void {
  if (items.length === 0) return
  pageData.courseItems = [...items]
  pageData.completedItemIds = []
  pageData.currentItemIndex = -1
  for (let i = 0; i < items.length; i += 1) {
    if (items[i].status === 'completed') pageData.completedItemIds.push(items[i].id)
    if (pageData.currentItemCode.length > 0 && items[i].code === pageData.currentItemCode) {
      pageData.currentItemIndex = i
      pageData.currentItemStatus = items[i].status
    }
  }
  if (pageData.totalItemCount <= 0) pageData.totalItemCount = items.length
  if (pageData.completedItemCount <= 0) pageData.completedItemCount = pageData.completedItemIds.length
}

function findItemIndexByCode(items: TrainingContentItem[], itemCode: string): number {
  if (itemCode.length === 0 || items.length === 0) return -1
  for (let i = 0; i < items.length; i += 1) {
    if (items[i].code === itemCode) return i
  }
  return -1
}

function countCompletedItems(items: TrainingContentItem[]): number {
  let completed = 0
  for (let i = 0; i < items.length; i += 1) {
    if (items[i].status === 'completed') completed += 1
  }
  return completed
}

function normalizeCourseStats(pageData: CourseDetailPageData): void {
  if (pageData.totalItemCount <= 0 && pageData.courseItems.length > 0) {
    pageData.totalItemCount = pageData.courseItems.length
  }

  if (pageData.completedItemCount < 0) pageData.completedItemCount = 0
  if (pageData.completedItemCount <= 0) {
    if (pageData.completedItemIds.length > 0) {
      pageData.completedItemCount = pageData.completedItemIds.length
    } else if (pageData.courseItems.length > 0) {
      pageData.completedItemCount = countCompletedItems(pageData.courseItems)
    }
  }

  if (pageData.totalItemCount > 0 && pageData.completedItemCount > pageData.totalItemCount) {
    pageData.completedItemCount = pageData.totalItemCount
  }

  if (pageData.totalItemCount > 0 && pageData.sessionProgressPercent <= 0 && pageData.completedItemCount > 0) {
    pageData.sessionProgressPercent = (pageData.completedItemCount * 100) / pageData.totalItemCount
  }

  if (!Number.isFinite(pageData.sessionProgressPercent) || pageData.sessionProgressPercent < 0) {
    pageData.sessionProgressPercent = 0
  }
  if (pageData.sessionProgressPercent > 100) {
    pageData.sessionProgressPercent = 100
  }
}

/** buildCourseSessionItems。 */
function buildSessionDetailItemSource(item: CourseSessionItemSnapshot): TrainingSessionDetailItemSource {
  const source: TrainingSessionDetailItemSource = {
    itemName: item.itemName,
    itemCode: item.itemCode,
    levelNum: item.levelNum,
    itemOrder: item.itemOrder,
    status: item.status
  }
  return source
}

/** buildCourseSessionItems。 */
function buildCourseSessionItems(trainingType: TrainingType, items: CourseSessionItemSnapshot[], currentItemCode: string): CourseSessionItemsViewModel {
  const result = new CourseSessionItemsViewModel()
  for (let i = 0; i < items.length; i += 1) {
    const sessionItemSource = buildSessionDetailItemSource(items[i])
    const mapped = mapSessionItemToTrainingContentItem(sessionItemSource, trainingType, i)
    result.courseItems.push(mapped)
    if (items[i].status === 'completed') result.completedItemIds.push(mapped.id)
    if (items[i].itemCode === currentItemCode) {
      result.currentItemIndex = i
      result.currentItemStatus = items[i].status
    }
  }
  return result
}

/** applyCourseDetail。 */
function applyCourseDetail(pageData: CourseDetailPageData, detail: CourseDetailViewData): void {
  pageData.courseName = detail.courseName.length > 0 ? detail.courseName : pageData.courseName
  pageData.courseIntro = detail.intro.length > 0 ? detail.intro : pageData.courseIntro
  pageData.coverUrl = detail.coverUrl.length > 0 ? detail.coverUrl : pageData.coverUrl
  pageData.trainingType = detail.trainingType
  pageData.tags = detail.tags.length > 0 ? [...detail.tags] : pageData.tags
}

/** resolveCurrentItemStatus。 */
function resolveCurrentItemStatus(status: TrainItemStatus, fallbackStatus: TrainItemStatus): TrainItemStatus {
  return status.length > 0 ? status : fallbackStatus
}

/** applySessionCache。 */
function applySessionCache(pageData: CourseDetailPageData, session: CourseSessionCacheEntry): void {
  // 先回填会话摘要字段（进度、完成数、当前项）。
  pageData.sessionProgressPercent = session.sessionProgressPercent
  pageData.completedItemCount = session.completedItemCount
  pageData.totalItemCount = session.totalItemCount
  pageData.currentItemCode = session.currentItemCode
  pageData.currentItemStatus = session.currentItemStatus
  const mappedState = buildCourseSessionItems(session.trainingType, session.items, session.currentItemCode)
  if (mappedState.courseItems.length > 0) {
    // 当会话里带有 items 时，以会话视图为准刷新列表和当前项定位。
    pageData.courseItems = mappedState.courseItems
    pageData.completedItemIds = mappedState.completedItemIds
    pageData.currentItemIndex = mappedState.currentItemIndex
    pageData.currentItemStatus = resolveCurrentItemStatus(mappedState.currentItemStatus, pageData.currentItemStatus)
    upsertCourseTrainingItemPreviews(pageData.courseCode, pageData.courseItems)
  } else {
    // 会话没有 items 时，继续使用已有列表，仅尝试对齐 currentItemIndex。
    const currentItemIndex = findItemIndexByCode(pageData.courseItems, pageData.currentItemCode)
    if (currentItemIndex >= 0) {
      pageData.currentItemIndex = currentItemIndex
      pageData.currentItemStatus = resolveCurrentItemStatus(pageData.courseItems[currentItemIndex].status, pageData.currentItemStatus)
    }
  }
  normalizeCourseStats(pageData)
}

async function refreshCourseDetailFromRemote(pageData: CourseDetailPageData, courseCode: string): Promise<TrainingType> {
  traceCourseDetail('refreshCourseDetailFromRemote.request',
    'courseCode=' + courseCode + ',cachedTrainingType=' + pageData.trainingType)
  // 仅当 detail 缓存缺失才走课程详情接口，避免重复请求。
  const detailResult = await getCourseDetail(courseCode)
  traceCourseDetail('refreshCourseDetailFromRemote.response',
    'courseCode=' + courseCode
      + ',ok=' + String(detailResult.ok)
      + ',httpCode=' + String(detailResult.httpCode)
      + ',code=' + String(detailResult.code)
      + ',hasData=' + String(detailResult.data !== null && detailResult.data !== undefined))
  const detailPayload = resolveApiPayload<CourseDetailSource>(detailResult)
  if (!detailPayload) {
    traceCourseDetail('refreshCourseDetailFromRemote.payload-missing',
      'courseCode=' + courseCode
        + ',httpCode=' + String(detailResult.httpCode)
        + ',code=' + String(detailResult.code)
        + ',rawBodyLength=' + String(detailResult.rawBody.length))
    return pageData.trainingType
  }

  const cacheInput = mapCourseDetailSourceToCacheInput(detailPayload)
  // 详情接口成功后先写缓存，再回填页面结构。
  setCourseDetailCache(courseCode, cacheInput)
  applyCourseDetail(pageData, {
    courseName: cacheInput.courseName,
    intro: cacheInput.intro,
    coverUrl: cacheInput.coverUrl,
    trainingType: cacheInput.trainingType,
    tags: [...cacheInput.tags]
  })
  traceCourseDetail('refreshCourseDetailFromRemote.applied',
    'courseCode=' + courseCode
      + ',trainingType=' + cacheInput.trainingType
      + ',tagsCount=' + String(cacheInput.tags.length))
  return cacheInput.trainingType
}

function hasSessionSummaryStats(session: CourseSessionCacheEntry): boolean {
  return session.totalItemCount > 0 || session.completedItemCount > 0 || session.sessionProgressPercent > 0
}

function mapSessionSourceItems(trainingType: TrainingType, detailSource: TrainingSessionDetailResponseSource): TrainingContentItem[] {
  const mappedItems: TrainingContentItem[] = []
  for (let i = 0; i < (detailSource.items ?? []).length; i += 1) {
    mappedItems.push(mapSessionItemToTrainingContentItem(detailSource.items![i], trainingType, i))
  }
  return mappedItems
}

function mergeSessionDetailWithStartSummary(
  detail: TrainingSessionDetailResponseSource,
  started: StartTrainingSessionResponseSource
): TrainingSessionDetailResponseSource {
  let usedStartProgress = false
  let usedStartCompleted = false
  let usedStartTotal = false
  let usedStartCurrentItemCode = false
  const merged: TrainingSessionDetailResponseSource = {
    progressPercent: detail.progressPercent,
    completedItemCount: detail.completedItemCount,
    totalItemCount: detail.totalItemCount,
    currentItemCode: detail.currentItemCode,
    trainingType: detail.trainingType,
    items: detail.items
  }

  const detailProgress = Number(detail.progressPercent ?? NaN)
  const startProgress = Number(started.progressPercent ?? NaN)
  if ((!Number.isFinite(detailProgress) || detailProgress <= 0) && Number.isFinite(startProgress) && startProgress > 0) {
    merged.progressPercent = startProgress
    usedStartProgress = true
  }

  const detailCompleted = Number(detail.completedItemCount ?? NaN)
  const startCompleted = Number(started.completedItemCount ?? NaN)
  if ((!Number.isFinite(detailCompleted) || detailCompleted <= 0) && Number.isFinite(startCompleted) && startCompleted > 0) {
    merged.completedItemCount = startCompleted
    usedStartCompleted = true
  }

  const detailTotal = Number(detail.totalItemCount ?? NaN)
  const startTotal = Number(started.totalItemCount ?? NaN)
  if ((!Number.isFinite(detailTotal) || detailTotal <= 0) && Number.isFinite(startTotal) && startTotal > 0) {
    merged.totalItemCount = startTotal
    usedStartTotal = true
  }

  const detailCurrentItemCode = String(detail.currentItemCode ?? '')
  const startCurrentItemCode = String(started.currentItemCode ?? '')
  if (detailCurrentItemCode.length <= 0 && startCurrentItemCode.length > 0) {
    merged.currentItemCode = startCurrentItemCode
    usedStartCurrentItemCode = true
  }

  traceCourseDetail('mergeSessionDetailWithStartSummary.result',
    'detailProgress=' + String(detail.progressPercent)
      + ',detailCompletedItemCount=' + String(detail.completedItemCount)
      + ',detailTotalItemCount=' + String(detail.totalItemCount)
      + ',detailCurrentItemCode=' + detailCurrentItemCode
      + ',startProgress=' + String(started.progressPercent)
      + ',startCompletedItemCount=' + String(started.completedItemCount)
      + ',startTotalItemCount=' + String(started.totalItemCount)
      + ',startCurrentItemCode=' + startCurrentItemCode
      + ',mergedProgress=' + String(merged.progressPercent)
      + ',mergedCompletedItemCount=' + String(merged.completedItemCount)
      + ',mergedTotalItemCount=' + String(merged.totalItemCount)
      + ',mergedCurrentItemCode=' + String(merged.currentItemCode)
      + ',usedStartProgress=' + String(usedStartProgress)
      + ',usedStartCompleted=' + String(usedStartCompleted)
      + ',usedStartTotal=' + String(usedStartTotal)
      + ',usedStartCurrentItemCode=' + String(usedStartCurrentItemCode))

  return merged
}

async function ensureCourseSessionCache(
  courseCode: string,
  trainingType: TrainingType,
  forceRefresh: boolean = false
): Promise<CourseSessionCacheEntry | undefined> {
  // 先尝试复用课程会话缓存。
  let session = getCourseSessionCache(courseCode)
  traceCourseDetail('ensureCourseSessionCache.enter',
    'courseCode=' + courseCode
      + ',forceRefresh=' + String(forceRefresh)
      + ',hasSessionCache=' + String(session !== undefined)
      + ',cachedSessionId=' + String(Number(session?.sessionId ?? 0))
      + ',cachedItemsCount=' + String(session?.items.length ?? 0)
      + ',cachedProgress=' + String(session?.sessionProgressPercent ?? 0)
      + ',cachedCompletedItemCount=' + String(session?.completedItemCount ?? 0)
      + ',cachedTotalItemCount=' + String(session?.totalItemCount ?? 0))
  if (session && !forceRefresh) {
    traceCourseDetail('ensureCourseSessionCache.cache-hit',
      'courseCode=' + courseCode
        + ',sessionId=' + String(session.sessionId)
        + ',itemsCount=' + String(session.items.length))
    return session
  }

  // 强刷分支：有 sessionId 时直接拉会话详情并覆盖本地课程会话快照。
  if (session && forceRefresh && session.sessionId > 0) {
    traceCourseDetail('ensureCourseSessionCache.force-refresh.request',
      'courseCode=' + courseCode + ',sessionId=' + String(session.sessionId))
    const sessionDetailResult = await fetchTrainSessionDetail(session.sessionId)
    traceCourseDetail('ensureCourseSessionCache.force-refresh.response',
      'courseCode=' + courseCode
        + ',sessionId=' + String(session.sessionId)
        + ',ok=' + String(sessionDetailResult.ok)
        + ',httpCode=' + String(sessionDetailResult.httpCode)
        + ',code=' + String(sessionDetailResult.code)
        + ',hasData=' + String(sessionDetailResult.data !== null && sessionDetailResult.data !== undefined))
    const sessionDetailPayload = resolveApiPayload<TrainingSessionDetailResponseSource>(sessionDetailResult)
    if (sessionDetailPayload) {
      const detailSource = sessionDetailPayload
      const itemStatus = normalizeTrainItemStatus(String(session.currentItemStatus ?? ''))
      cacheTrainingSessionDetail(courseCode, detailSource, session.sessionId, itemStatus)
      upsertCourseTrainingItemPreviews(courseCode, mapSessionSourceItems(trainingType, detailSource))
      traceCourseDetail('ensureCourseSessionCache.force-refresh.cached',
        'courseCode=' + courseCode
          + ',sessionId=' + String(session.sessionId)
          + ',detailItemsCount=' + String(detailSource.items?.length ?? 0)
          + ',detailProgress=' + String(detailSource.progressPercent)
          + ',detailCompletedItemCount=' + String(detailSource.completedItemCount)
          + ',detailTotalItemCount=' + String(detailSource.totalItemCount))
      return getCourseSessionCache(courseCode)
    }
    traceCourseDetail('ensureCourseSessionCache.force-refresh.payload-missing',
      'courseCode=' + courseCode + ',sessionId=' + String(session.sessionId))
  }

  // 无可用会话缓存时，先启动会话，再拉会话详情。
  traceCourseDetail('ensureCourseSessionCache.start-session.request', 'courseCode=' + courseCode)
  const startResult = await startTrainSession(courseCode)
  traceCourseDetail('ensureCourseSessionCache.start-session.response',
    'courseCode=' + courseCode
      + ',ok=' + String(startResult.ok)
      + ',httpCode=' + String(startResult.httpCode)
      + ',code=' + String(startResult.code)
      + ',hasData=' + String(startResult.data !== null && startResult.data !== undefined))
  const startedPayload = resolveApiPayload<StartTrainingSessionResponseSource>(startResult)
  if (!startedPayload) {
    traceCourseDetail('ensureCourseSessionCache.start-session.payload-missing',
      'courseCode=' + courseCode
        + ',httpCode=' + String(startResult.httpCode)
        + ',code=' + String(startResult.code)
        + ',rawBodyLength=' + String(startResult.rawBody.length))
    return undefined
  }

  const sessionId = Number(startedPayload.sessionId ?? 0)
  traceCourseDetail('ensureCourseSessionCache.start-session.parsed',
    'courseCode=' + courseCode
      + ',sessionId=' + String(sessionId)
      + ',currentItemCode=' + String(startedPayload.currentItemCode)
      + ',progressPercent=' + String(startedPayload.progressPercent)
      + ',completedItemCount=' + String(startedPayload.completedItemCount)
      + ',totalItemCount=' + String(startedPayload.totalItemCount))
  if (sessionId <= 0) {
    traceCourseDetail('ensureCourseSessionCache.start-session.invalid-session-id',
      'courseCode=' + courseCode + ',sessionId=' + String(sessionId))
    return undefined
  }
  traceCourseDetail('ensureCourseSessionCache.session-detail.request',
    'courseCode=' + courseCode + ',sessionId=' + String(sessionId))
  const sessionDetailResult = await fetchTrainSessionDetail(sessionId)
  traceCourseDetail('ensureCourseSessionCache.session-detail.response',
    'courseCode=' + courseCode
      + ',sessionId=' + String(sessionId)
      + ',ok=' + String(sessionDetailResult.ok)
      + ',httpCode=' + String(sessionDetailResult.httpCode)
      + ',code=' + String(sessionDetailResult.code)
      + ',hasData=' + String(sessionDetailResult.data !== null && sessionDetailResult.data !== undefined))
  const sessionDetailPayload = resolveApiPayload<TrainingSessionDetailResponseSource>(sessionDetailResult)
  if (!sessionDetailPayload) {
    traceCourseDetail('ensureCourseSessionCache.session-detail.payload-missing',
      'courseCode=' + courseCode
        + ',sessionId=' + String(sessionId)
        + ',httpCode=' + String(sessionDetailResult.httpCode)
        + ',code=' + String(sessionDetailResult.code)
        + ',rawBodyLength=' + String(sessionDetailResult.rawBody.length))
    return undefined
  }

  const detailSource = mergeSessionDetailWithStartSummary(sessionDetailPayload, startedPayload)
  const itemStatus = normalizeTrainItemStatus(String(startedPayload.currentItemStatus ?? ''))
  // 会话详情作为动态主数据，统一写入课程会话缓存并刷新训练项预览。
  cacheTrainingSessionDetail(courseCode, detailSource, sessionId, itemStatus)
  upsertCourseTrainingItemPreviews(courseCode, mapSessionSourceItems(trainingType, detailSource))
  session = getCourseSessionCache(courseCode)
  traceCourseDetail('ensureCourseSessionCache.completed',
    'courseCode=' + courseCode
      + ',sessionId=' + String(sessionId)
      + ',mergedProgress=' + String(detailSource.progressPercent)
      + ',mergedCompletedItemCount=' + String(detailSource.completedItemCount)
      + ',mergedTotalItemCount=' + String(detailSource.totalItemCount)
      + ',mergedCurrentItemCode=' + String(detailSource.currentItemCode)
      + ',mergedItemsCount=' + String(detailSource.items?.length ?? 0)
      + ',cachedItemsCount=' + String(session?.items.length ?? 0)
      + ',cachedProgress=' + String(session?.sessionProgressPercent ?? 0)
      + ',cachedCompletedItemCount=' + String(session?.completedItemCount ?? 0)
      + ',cachedTotalItemCount=' + String(session?.totalItemCount ?? 0))
  return session
}

/** loadCourseDetailPageData。 */
export async function loadCourseDetailPageData(courseCode: string): Promise<CourseDetailPageData> {
  // A. 本地预热：先拿到可展示页面结构。
  const pageData = createPageDataFromCache(courseCode)
  traceCourseDetail('loadCourseDetailPageData.entry',
    'courseCode=' + courseCode
      + ',cachedItemsCount=' + String(pageData.courseItems.length)
      + ',cachedProgress=' + String(pageData.sessionProgressPercent)
      + ',cachedCompletedItemCount=' + String(pageData.completedItemCount)
      + ',cachedTotalItemCount=' + String(pageData.totalItemCount)
      + ',cachedCurrentItemCode=' + pageData.currentItemCode)
  if (courseCode.length === 0) return pageData

  // B. 详情补齐：仅在详情缓存缺失时请求课程详情接口。
  const hasDetailCache = getCourseDetailCache(courseCode) !== undefined
  traceCourseDetail('loadCourseDetailPageData.detail-cache-state',
    'courseCode=' + courseCode + ',hasDetailCache=' + String(hasDetailCache))
  let trainingType = pageData.trainingType
  if (!hasDetailCache) {
    trainingType = await refreshCourseDetailFromRemote(pageData, courseCode)
  }

  // C. 会话补齐：根据缓存状态决定是否请求会话接口。
  let session = getCourseSessionCache(courseCode)
  traceCourseDetail('loadCourseDetailPageData.session-cache-state',
    'courseCode=' + courseCode
      + ',hasSession=' + String(session !== undefined)
      + ',sessionId=' + String(Number(session?.sessionId ?? 0))
      + ',itemsCount=' + String(session?.items.length ?? 0)
      + ',progress=' + String(session?.sessionProgressPercent ?? 0)
      + ',completedItemCount=' + String(session?.completedItemCount ?? 0)
      + ',totalItemCount=' + String(session?.totalItemCount ?? 0))
  if (!session) {
    traceCourseDetail('loadCourseDetailPageData.session-action',
      'courseCode=' + courseCode + ',action=ensure-no-cache')
    session = await ensureCourseSessionCache(courseCode, trainingType)
  } else if (session.items.length === 0 && !hasSessionSummaryStats(session)) {
    traceCourseDetail('loadCourseDetailPageData.session-action',
      'courseCode=' + courseCode + ',action=ensure-force-refresh-empty-summary')
    session = await ensureCourseSessionCache(courseCode, trainingType, true)
  } else if (session.items.length === 0 && pageData.courseItems.length === 0) {
    traceCourseDetail('loadCourseDetailPageData.session-action',
      'courseCode=' + courseCode + ',action=ensure-empty-items')
    session = await ensureCourseSessionCache(courseCode, trainingType)
  }

  // D. 统一归并：将会话动态字段映射进页面数据。
  if (session) {
    pageData.currentItemStatus = normalizeTrainItemStatus(String(session.currentItemStatus ?? ''))
    applySessionCache(pageData, session)
  }
  // E. 最终归一化，兜底 total/completed/progress 边界。
  normalizeCourseStats(pageData)
  traceCourseDetail('loadCourseDetailPageData.final',
    'courseCode=' + courseCode
      + ',finalItemsCount=' + String(pageData.courseItems.length)
      + ',finalProgress=' + String(pageData.sessionProgressPercent)
      + ',finalCompletedItemCount=' + String(pageData.completedItemCount)
      + ',finalTotalItemCount=' + String(pageData.totalItemCount)
      + ',finalCurrentItemCode=' + pageData.currentItemCode)
  return pageData
}

/** readCachedCourseDetailView。 */
export function readCachedCourseDetailView(courseCode: string): CourseDetailPageData {
  return createPageDataFromCache(courseCode)
}
