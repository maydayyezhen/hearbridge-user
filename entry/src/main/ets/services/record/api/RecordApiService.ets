/**
 * 记录页 API 业务服务，负责记录总览、最近课程与记录页数据装配。
 */
import { getRecordOverview } from '../../../api/requests/RecordApi'
import { getRecentTrainingCourses } from '../../../api/requests/TrainingApi'
import { readUserState, writeUserState } from '../../../repository/user/UserRepository'
import { RecordPageState, createRecordPageState } from '../model/RecordPageState'
import { mapRecordRecentCoursesToUserCourses, mapRecentTrainingCourses, mapTrendGroup, mapUserRecentCourses } from '../mapper/RecordPageMapper'
import { RecentCourse } from '../model/RecordViewModels'

interface RecentCoursesCacheMeta {
  loadedOnce: boolean
  hasMore: boolean
  pageNo: number
  total: number
}

interface OverviewCacheMeta {
  loadedOnce: boolean
}

const recentCoursesCacheMeta: RecentCoursesCacheMeta = {
  loadedOnce: false,
  hasMore: true,
  pageNo: 1,
  total: 0
}

const overviewCacheMeta: OverviewCacheMeta = {
  loadedOnce: false
}

const overviewCacheState: RecordPageState = createRecordPageState()

/** buildRecentTrainingCoursesPath。 */
function buildRecentTrainingCoursesPath(pageNo: number, pageSize: number): string {
  const params: string[] = []
  if (pageNo > 0) params.push(`pageNo=${pageNo}`)
  if (pageSize > 0) params.push(`pageSize=${pageSize}`)
  return params.length > 0 ? `/app/training/recent-course?${params.join('&')}` : '/app/training/recent-course'
}

function cloneRecordState(source: RecordPageState): RecordPageState {
  const next = createRecordPageState()
  next.overallScore = source.overallScore
  next.summaryTitle = source.summaryTitle
  next.summaryAdvice = source.summaryAdvice
  next.completedDays = source.completedDays
  next.completedItems = source.completedItems
  next.completedCourses = source.completedCourses
  next.totalPracticeSeconds = source.totalPracticeSeconds
  next.accuracyScore = source.accuracyScore
  next.rhythmScore = source.rhythmScore
  next.completionScore = source.completionScore
  next.improvementRate = source.improvementRate
  next.weaknessTags = source.weaknessTags.slice()
  next.strengthTags = source.strengthTags.slice()
  next.advice = source.advice
  next.dayTrend = source.dayTrend.slice()
  next.weekTrend = source.weekTrend.slice()
  next.overviewTrend = source.overviewTrend.slice()
  next.recentCourses = source.recentCourses.slice()
  next.recentCoursesTotal = source.recentCoursesTotal
  next.loading = source.loading
  next.loaded = source.loaded
  next.tip = source.tip
  next.loadingMoreRecentCourses = source.loadingMoreRecentCourses
  next.hasMoreRecentCourses = source.hasMoreRecentCourses
  next.recentCoursesPageNo = source.recentCoursesPageNo
  return next
}

function copyOverviewFields(target: RecordPageState, source: RecordPageState): void {
  target.overallScore = source.overallScore
  target.summaryTitle = source.summaryTitle
  target.summaryAdvice = source.summaryAdvice
  target.completedDays = source.completedDays
  target.completedItems = source.completedItems
  target.completedCourses = source.completedCourses
  target.totalPracticeSeconds = source.totalPracticeSeconds
  target.accuracyScore = source.accuracyScore
  target.rhythmScore = source.rhythmScore
  target.completionScore = source.completionScore
  target.improvementRate = source.improvementRate
  target.weaknessTags = source.weaknessTags.slice()
  target.strengthTags = source.strengthTags.slice()
  target.advice = source.advice
  target.dayTrend = source.dayTrend.slice()
  target.weekTrend = source.weekTrend.slice()
  target.overviewTrend = source.overviewTrend.slice()
}

function writeOverviewToCache(record: RecordPageState): void {
  copyOverviewFields(overviewCacheState, record)
  overviewCacheMeta.loadedOnce = true
}

function readRecentCoursesFromUserState(): RecentCourse[] {
  const user = readUserState()
  return mapUserRecentCourses(user.recentCourses)
}

function writeRecentCoursesToUserState(recentCourses: RecentCourse[]): void {
  const user = readUserState()
  user.recentCourses = mapRecordRecentCoursesToUserCourses(recentCourses)
  writeUserState(user)
}

/**
 * 判断进入记录页时是否需要请求最近课程。
 */
export function shouldRequestRecentCoursesOnEnter(_record: RecordPageState): boolean {
  return !recentCoursesCacheMeta.loadedOnce
}

/**
 * 判断进入记录页时是否需要请求总览。
 */
export function shouldRequestOverviewOnEnter(_record: RecordPageState): boolean {
  return !overviewCacheMeta.loadedOnce
}

/**
 * 以本地缓存预热记录页总览。
 */
export function hydrateOverviewStateFromCache(record: RecordPageState): RecordPageState {
  const nextRecord = cloneRecordState(record)
  if (!overviewCacheMeta.loadedOnce) return nextRecord
  copyOverviewFields(nextRecord, overviewCacheState)
  nextRecord.loading = false
  nextRecord.loaded = true
  nextRecord.tip = ''
  return nextRecord
}

/**
 * 以用户状态中的 recentCourses 预热记录页列表。
 */
export function hydrateRecentCoursesStateFromUser(record: RecordPageState): RecordPageState {
  const nextRecord = cloneRecordState(record)
  const cachedCourses = readRecentCoursesFromUserState()
  if (cachedCourses.length === 0) return nextRecord
  nextRecord.recentCourses = cachedCourses
  if (recentCoursesCacheMeta.loadedOnce) {
    nextRecord.hasMoreRecentCourses = recentCoursesCacheMeta.hasMore
    nextRecord.recentCoursesPageNo = recentCoursesCacheMeta.pageNo
    nextRecord.recentCoursesTotal = recentCoursesCacheMeta.total
  } else {
    nextRecord.hasMoreRecentCourses = true
    nextRecord.recentCoursesPageNo = 1
    nextRecord.recentCoursesTotal = cachedCourses.length
  }
  return nextRecord
}

/**
 * 加载记录页总览数据。
 */
export async function loadRecordOverviewState(record: RecordPageState): Promise<RecordPageState> {
  const nextRecord = cloneRecordState(record)
  nextRecord.loading = true
  nextRecord.tip = ''
  const result = await getRecordOverview()
  if (!result.ok || !result.data) {
    nextRecord.loading = false
    nextRecord.loaded = false
    nextRecord.tip = result.message.length > 0 ? result.message : '记录页加载失败。'
    return nextRecord
  }
  const data = result.data
  nextRecord.overallScore = Number(data.summary?.overallScore ?? 0)
  nextRecord.summaryTitle = data.summary?.summaryTitle ?? ''
  nextRecord.summaryAdvice = data.summary?.summaryAdvice ?? ''
  nextRecord.completedDays = Number(data.summary?.completedDays ?? 0)
  nextRecord.completedItems = Number(data.summary?.completedItems ?? 0)
  nextRecord.completedCourses = Number(data.summary?.completedCourses ?? 0)
  nextRecord.totalPracticeSeconds = Number(data.summary?.totalPracticeSeconds ?? 0)
  nextRecord.accuracyScore = Number(data.performance?.accuracyScore ?? 0)
  nextRecord.rhythmScore = Number(data.performance?.rhythmScore ?? 0)
  nextRecord.completionScore = Number(data.performance?.completionScore ?? 0)
  nextRecord.improvementRate = Number(data.performance?.improvementRate ?? 0)
  const weaknessTags = data.performance?.weaknessTags
  const strengthTags = data.performance?.strengthTags
  nextRecord.weaknessTags = Array.isArray(weaknessTags) ? weaknessTags.slice() : []
  nextRecord.strengthTags = Array.isArray(strengthTags) ? strengthTags.slice() : []
  nextRecord.advice = data.performance?.advice ?? ''
  nextRecord.dayTrend = mapTrendGroup(data.trends?.day)
  nextRecord.weekTrend = mapTrendGroup(data.trends?.week)
  nextRecord.overviewTrend = mapTrendGroup(data.trends?.overview)
  nextRecord.loading = false
  nextRecord.loaded = true
  nextRecord.tip = ''
  writeOverviewToCache(nextRecord)
  return nextRecord
}

/**
 * 加载记录页最近课程列表。
 */
export async function loadRecentCoursesState(record: RecordPageState, loadMore: boolean): Promise<RecordPageState> {
  if (loadMore && (record.loadingMoreRecentCourses || !record.hasMoreRecentCourses)) return record
  const nextRecord: RecordPageState = cloneRecordState(record)
  if (loadMore) nextRecord.loadingMoreRecentCourses = true
  const targetPageNo = loadMore ? record.recentCoursesPageNo + 1 : 1
  const result = await getRecentTrainingCourses(buildRecentTrainingCoursesPath(targetPageNo, 5))
  if (!result.ok || !result.data) {
    if (!loadMore) {
      const fallbackCourses = readRecentCoursesFromUserState()
      nextRecord.recentCourses = fallbackCourses
      nextRecord.recentCoursesTotal = fallbackCourses.length
      nextRecord.hasMoreRecentCourses = false
      nextRecord.loadingMoreRecentCourses = false
      nextRecord.recentCoursesPageNo = 1
      if (fallbackCourses.length > 0) {
        recentCoursesCacheMeta.loadedOnce = true
        recentCoursesCacheMeta.hasMore = false
        recentCoursesCacheMeta.pageNo = 1
        recentCoursesCacheMeta.total = fallbackCourses.length
      }
      return nextRecord
    }
    nextRecord.loadingMoreRecentCourses = false
    return nextRecord
  }
  const mapped = mapRecentTrainingCourses(result.data.list ?? [])
  const nextCourses = loadMore ? record.recentCourses.slice() : []
  for (let i = 0; i < mapped.length; i += 1) {
    nextCourses.push(mapped[i])
  }
  const totalCourses = Number(result.data.total ?? nextCourses.length)
  nextRecord.recentCourses = nextCourses
  nextRecord.recentCoursesTotal = totalCourses
  nextRecord.hasMoreRecentCourses = nextCourses.length < totalCourses
  nextRecord.loadingMoreRecentCourses = false
  nextRecord.recentCoursesPageNo = Number(result.data.pageNo ?? targetPageNo)
  recentCoursesCacheMeta.loadedOnce = true
  recentCoursesCacheMeta.hasMore = nextRecord.hasMoreRecentCourses
  recentCoursesCacheMeta.pageNo = nextRecord.recentCoursesPageNo
  recentCoursesCacheMeta.total = totalCourses
  writeRecentCoursesToUserState(nextCourses)
  return nextRecord
}

/**
 * 创建空白记录页状态。
 */
export function createEmptyRecordState(): RecordPageState {
  return createRecordPageState()
}
