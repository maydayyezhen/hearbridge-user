/**
 * RecordApi 相关的请求函数与接口访问逻辑。
 */

import http from '@ohos.net.http'
import { ApiResult } from '../common/Http'
import { requestApi } from '../HttpClient'

/** 趋势点位源对象。 */
export interface RecordTrendPointSource {
  label?: string
  score?: number | string
}

/** 趋势分组源对象。 */
export interface RecordTrendGroupSource {
  points?: RecordTrendPointSource[]
}

/** 记录页摘要源对象。 */
export interface RecordSummarySource {
  overallScore?: number | string
  summaryTitle?: string
  summaryAdvice?: string
  completedDays?: number | string
  completedItems?: number | string
  todayCompletedItemCount?: number | string
  todayStatusPercent?: number | string
  completedCourses?: number | string
  totalPracticeSeconds?: number | string
}

/** 记录页表现源对象。 */
export interface RecordPerformanceSource {
  accuracyScore?: number | string
  rhythmScore?: number | string
  completionScore?: number | string
  improvementRate?: number | string
  weaknessTags?: string[]
  strengthTags?: string[]
  advice?: string
}

/** 记录页趋势集合源对象。 */
export interface RecordOverviewTrendSource {
  day?: RecordTrendGroupSource
  week?: RecordTrendGroupSource
  overview?: RecordTrendGroupSource
}

/** 记录页总览响应源对象。 */
export interface RecordOverviewResponseSource {
  summary?: RecordSummarySource
  performance?: RecordPerformanceSource
  trends?: RecordOverviewTrendSource
}

/** getRecordOverview。 */
export async function getRecordOverview(): Promise<ApiResult<RecordOverviewResponseSource>> {
  return await requestApi<RecordOverviewResponseSource>({
    path: '/app/record/overview',
    method: http.RequestMethod.GET
  })
}
