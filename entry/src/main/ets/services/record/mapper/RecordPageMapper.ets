/**
 * 记录页映射工具，负责记录页接口 source 到页面 view-model 的纯映射。
 */

import { RecordTrendGroupSource, RecordTrendPointSource } from '../../../api/requests/RecordApi'
import { RecentTrainingCourseSource } from '../../../api/requests/TrainingApi'
import { Course } from '../../../domain/entity/Course'
import { RecentCourse, TrendPointItem } from '../model/RecordViewModels'

/** mapRecordTrendPoints。 */
export function mapRecordTrendPoints(points: RecordTrendPointSource[]): TrendPointItem[] {
  const next: TrendPointItem[] = []
  for (let i = 0; i < points.length; i += 1) {
    next.push(new TrendPointItem(String(points[i].label ?? ''), Number(points[i].score ?? 0)))
  }
  return next
}

/** mapTrendGroup。 */
export function mapTrendGroup(group?: RecordTrendGroupSource): TrendPointItem[] {
  if (!group || !group.points) {
    return []
  }
  return mapRecordTrendPoints(group.points)
}

/** mapRecentTrainingCourses。 */
export function mapRecentTrainingCourses(recentCourses: RecentTrainingCourseSource[]): RecentCourse[] {
  const next: RecentCourse[] = []
  for (let i = 0; i < recentCourses.length; i += 1) {
    const lastLearnedAt = String(recentCourses[i].lastLearnedAt ?? recentCourses[i].lastLearnAt ?? '')
    next.push(new RecentCourse(
      String(recentCourses[i].courseCode ?? ''),
      String(recentCourses[i].courseName ?? ''),
      lastLearnedAt,
      String(recentCourses[i].coverUrl ?? ''),
      Number(recentCourses[i].progressPercent ?? 0)
    ))
  }
  return next
}

/** mapUserRecentCourses。 */
export function mapUserRecentCourses(recentCourses: Course[]): RecentCourse[] {
  const next: RecentCourse[] = []
  for (let i = 0; i < recentCourses.length; i += 1) {
    const item = recentCourses[i]
    next.push(new RecentCourse(
      String(item.code ?? ''),
      String(item.name ?? ''),
      String(item.lastLearnedAt ?? ''),
      String(item.coverUrl ?? ''),
      Number(item.progressPercent ?? 0)
    ))
  }
  return next
}

/** mapRecordRecentCoursesToUserCourses。 */
export function mapRecordRecentCoursesToUserCourses(recentCourses: RecentCourse[]): Course[] {
  const next: Course[] = []
  for (let i = 0; i < recentCourses.length; i += 1) {
    const item = recentCourses[i]
    const course = new Course()
    course.code = item.courseCode
    course.name = item.courseName
    course.coverUrl = item.coverUrl
    course.progressPercent = Number(item.progressPercent ?? 0)
    course.lastLearnedAt = item.lastLearnedAt
    course.status = 1
    course.favorite = false
    next.push(course)
  }
  return next
}
