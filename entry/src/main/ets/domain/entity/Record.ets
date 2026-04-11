/**
 * Record 文件，负责训练记录领域实体定义。
 */

/** RecordTrendPoint。 */
export interface RecordTrendPoint {
  label: string
  score: number
}

/**
 * 训练记录领域实体。
 * 只保留总览与趋势等稳定业务数据，不承载页面加载态与分页状态。
 */
export interface Record {
  overallScore: number
  summaryTitle: string
  summaryAdvice: string
  completedDays: number
  completedItems: number
  completedCourses: number
  totalPracticeSeconds: number
  accuracyScore: number
  rhythmScore: number
  completionScore: number
  improvementRate: number
  weaknessTags: string[]
  strengthTags: string[]
  advice: string
  dayTrend: RecordTrendPoint[]
  weekTrend: RecordTrendPoint[]
  overviewTrend: RecordTrendPoint[]
}

/** createRecord。 */
export function createRecord(): Record {
  return {
    overallScore: 0,
    summaryTitle: '',
    summaryAdvice: '',
    completedDays: 0,
    completedItems: 0,
    completedCourses: 0,
    totalPracticeSeconds: 0,
    accuracyScore: 0,
    rhythmScore: 0,
    completionScore: 0,
    improvementRate: 0,
    weaknessTags: [],
    strengthTags: [],
    advice: '',
    dayTrend: [],
    weekTrend: [],
    overviewTrend: []
  }
}
