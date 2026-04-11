/**
 * 记录页本地服务，负责趋势点、柱高与标签文案等纯本地展示辅助。
 */
import { RecordPageState } from '../model/RecordPageState'
import { RecentCourse, TrendPointItem } from '../model/RecordViewModels'
export { RecentCourse, TrendPointItem }

/**
 * 顶部总结卡片文案。
 */
export interface RecordScoreCopy {
  heroTitle: string
  title: string
  advice: string
}

/**
 * 规范分数取值范围。
 */
export function getSafeRecordScore(score: number): number { return Math.max(0, Math.min(100, score)) }
/** getNonZeroTrendPoints。 */
function getNonZeroTrendPoints(trendPoints: TrendPointItem[]): TrendPointItem[] { return trendPoints.filter((item) => item.score > 0) }
/**
 * 计算分段柱状图高度。
 */
export function getSegmentedBarHeight(score: number, trendPoints: TrendPointItem[]): number {
  if (score <= 0) return 14
  const points = getNonZeroTrendPoints(trendPoints)
  if (points.length === 0) return 14
  let minScore = points[0].score
  let maxScore = points[0].score
  for (let i = 1; i < points.length; i += 1) {
    if (points[i].score < minScore) minScore = points[i].score
    if (points[i].score > maxScore) maxScore = points[i].score
  }
  if (maxScore === minScore) return 72
  const normalized = (score - minScore) / (maxScore - minScore)
  const range = maxScore - minScore
  if (range <= 5) return 58 + normalized * 14
  if (range <= 10) return 54 + normalized * 20
  if (range <= 20) return 48 + normalized * 30
  return 42 + normalized * 44
}
/** mapWeekdayLabel。 */
function mapWeekdayLabel(label: string): string {
  const match = label.match(/(\d{1,2})-(\d{1,2})/)
  if (!match) return label.length > 3 ? `${label.substring(0, 3)}...` : label
  const now = new Date()
  const date = new Date(now.getFullYear(), Number(match[1]) - 1, Number(match[2]))
  const weekLabels: string[] = ['周日', '周一', '周二', '周三', '周四', '周五', '周六']
  return weekLabels[date.getDay()]
}
/**
 * 计算记录页展示标签。
 */
export function getRecordDisplayLabel(label: string, selectedFilter: string): string {
  const normalized = label.trim()
  if (selectedFilter === '日') return mapWeekdayLabel(normalized)
  if (normalized.indexOf('第') === 0 && normalized.indexOf('周') > 0) return `W${normalized.substring(1, normalized.indexOf('周'))}`
  return normalized.length > 4 ? `${normalized.substring(0, 4)}...` : normalized
}
/**
 * 生成记录页趋势点集合。
 */
export function getRecordTrendPoints(record: RecordPageState, selectedFilter: string): TrendPointItem[] {
  if (selectedFilter === '日') return record.dayTrend as never
  if (selectedFilter === '周') return record.weekTrend as never
  return record.overviewTrend as never
}
/**
 * 过滤掉零值趋势点。
 */
export function getNonZeroRecordTrendPoints(points: TrendPointItem[]): TrendPointItem[] {
  return getNonZeroTrendPoints(points)
}

/**
 * 按分数返回记录页顶部卡片中文文案。
 */
export function getRecordScoreCopy(score: number): RecordScoreCopy {
  const normalizedScore = getSafeRecordScore(score)
  if (normalizedScore >= 95) {
    return {
      heroTitle: '状态超棒',
      title: '表达自然，整体稳定',
      advice: '稳得不像话，继续保持这个节奏'
    }
  }
  if (normalizedScore >= 85) {
    return {
      heroTitle: '表现亮眼',
      title: '整体流畅，熟练度较好',
      advice: '已经很顺了，再打磨几个小细节会更炸'
    }
  }
  if (normalizedScore >= 75) {
    return {
      heroTitle: '渐入佳境',
      title: '状态渐稳，进步明显',
      advice: '进步肉眼可见，把关键动作练成肌肉记忆'
    }
  }
  if (normalizedScore >= 60) {
    return {
      heroTitle: '稳步提升',
      title: '慢慢进入状态，持续积累',
      advice: '基础在变扎实，别急，一步一步来'
    }
  }
  if (normalizedScore > 0) {
    return {
      heroTitle: '正在积累',
      title: '基础逐步建立中',
      advice: '先熟悉核心动作，多练几遍就有感觉了'
    }
  }
  return {
    heroTitle: '准备开始',
    title: '还没有训练记录',
    advice: '点一下开始练习，这里就会活起来'
  }
}
