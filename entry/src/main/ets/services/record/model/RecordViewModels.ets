/**
 * RecordViewModels 文件，负责记录模块内部使用的视图模型定义。
 */

/**
 * 最近训练课程视图模型。
 */
export class RecentCourse {
  courseCode: string
  courseName: string
  lastLearnedAt: string
  coverUrl: string
  progressPercent: number

  constructor(courseCode: string, courseName: string, lastLearnedAt: string, coverUrl: string, progressPercent: number) {
    this.courseCode = courseCode
    this.courseName = courseName
    this.lastLearnedAt = lastLearnedAt
    this.coverUrl = coverUrl
    this.progressPercent = progressPercent
  }
}

/**
 * 趋势图单个点位。
 */
export class TrendPointItem {
  label: string
  score: number

  constructor(label: string, score: number) {
    this.label = label
    this.score = score
  }
}
