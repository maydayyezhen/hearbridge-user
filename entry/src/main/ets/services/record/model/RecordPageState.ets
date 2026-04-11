/**
 * RecordPageState 文件，负责记录页页面状态与分页控制模型定义。
 */

import { Record, createRecord } from '../../../domain/entity/Record'
import { RecentCourse } from './RecordViewModels'

/**
 * 记录页状态模型。
 */
export interface RecordPageState extends Record {
  recentCourses: RecentCourse[]
  recentCoursesTotal: number
  loading: boolean
  loaded: boolean
  tip: string
  loadingMoreRecentCourses: boolean
  hasMoreRecentCourses: boolean
  recentCoursesPageNo: number
}

/**
 * 创建空白记录页状态。
 */
export function createRecordPageState(): RecordPageState {
  const record = createRecord()
  return {
    overallScore: record.overallScore,
    summaryTitle: record.summaryTitle,
    summaryAdvice: record.summaryAdvice,
    completedDays: record.completedDays,
    completedItems: record.completedItems,
    completedCourses: record.completedCourses,
    totalPracticeSeconds: record.totalPracticeSeconds,
    accuracyScore: record.accuracyScore,
    rhythmScore: record.rhythmScore,
    completionScore: record.completionScore,
    improvementRate: record.improvementRate,
    weaknessTags: record.weaknessTags.slice(),
    strengthTags: record.strengthTags.slice(),
    advice: record.advice,
    dayTrend: record.dayTrend.slice(),
    weekTrend: record.weekTrend.slice(),
    overviewTrend: record.overviewTrend.slice(),
    recentCourses: [],
    recentCoursesTotal: 0,
    loading: true,
    loaded: false,
    tip: '',
    loadingMoreRecentCourses: false,
    hasMoreRecentCourses: false,
    recentCoursesPageNo: 1
  }
}
