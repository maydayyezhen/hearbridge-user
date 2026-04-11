/**
 * 记录页服务出口，供页面层统一使用记录页数据加载与展示辅助能力。
 */
import { buildCourseDetailPath, buildTrainRootPath } from '../../router/RouteBuilders'
import { RecordPageState } from './model/RecordPageState'
import { createEmptyRecordState, hydrateOverviewStateFromCache, hydrateRecentCoursesStateFromUser, loadRecentCoursesState, loadRecordOverviewState, shouldRequestOverviewOnEnter, shouldRequestRecentCoursesOnEnter } from './api/RecordApiService'
import { RecentCourse, RecordScoreCopy, TrendPointItem, getNonZeroRecordTrendPoints, getRecordDisplayLabel, getRecordScoreCopy, getRecordTrendPoints, getSafeRecordScore, getSegmentedBarHeight } from './local/RecordLocalService'

export {
  RecordPageState,
  createEmptyRecordState,
  RecentCourse,
  RecordScoreCopy,
  TrendPointItem,
  getNonZeroRecordTrendPoints,
  getRecordDisplayLabel,
  getSafeRecordScore,
  getSegmentedBarHeight
}

/**
 * 加载记录页总览。
 */
export async function loadRecordPageOverview(record: RecordPageState): Promise<RecordPageState> {
  return await loadRecordOverviewState(record)
}

/**
 * 从本地缓存预热记录页总览。
 */
export function hydrateRecordPageOverview(record: RecordPageState): RecordPageState {
  return hydrateOverviewStateFromCache(record)
}

/**
 * 判断进入记录页时是否需要刷新总览。
 */
export function shouldRefreshRecordPageOverview(record: RecordPageState): boolean {
  return shouldRequestOverviewOnEnter(record)
}

/**
 * 从用户状态预热记录页最近课程。
 */
export function hydrateRecordPageRecentCourses(record: RecordPageState): RecordPageState {
  return hydrateRecentCoursesStateFromUser(record)
}

/**
 * 判断进入记录页时是否需要刷新最近课程。
 */
export function shouldRefreshRecordPageRecentCourses(record: RecordPageState): boolean {
  return shouldRequestRecentCoursesOnEnter(record)
}

/**
 * 加载记录页最近课程。
 */
export async function loadRecordPageRecentCourses(record: RecordPageState, loadMore: boolean): Promise<RecordPageState> {
  return await loadRecentCoursesState(record, loadMore)
}

/**
 * 获取记录页当前筛选下的趋势点集合。
 */
export function getRecordPageTrendPoints(record: RecordPageState, selectedFilter: string): TrendPointItem[] {
  return getRecordTrendPoints(record, selectedFilter)
}

/**
 * 获取记录页顶部总结卡分数文案。
 */
export function getRecordPageScoreCopy(score: number): RecordScoreCopy {
  return getRecordScoreCopy(score)
}

/**
 * 构造记录页“开始一轮”按钮路径。
 */
export function buildRecordPracticePath(): string {
  return buildTrainRootPath('gesture')
}

/**
 * 构造记录页打开课程详情的路径。
 */
export function buildRecordCourseDetailPath(item: RecentCourse): string {
  return buildCourseDetailPath(item.courseCode)
}
