/**
 * 课程 API 映射与归一化工具，负责把接口 DTO 转成前端缓存/页面使用的数据结构。
 * 在课程详情加载链路中，这里承担“接口字段 -> 缓存写入模型”的统一规范化职责。
 */

import { CourseDetailSource, CourseListItemSource, CourseTagSource } from '../../../api/requests/CourseApi'
import { Course } from '../../../domain/entity/Course'
import { CourseDetailCacheInput } from '../../../repository/course/CourseDetailRepository'
import { normalizeTrainingType } from '../../../utils/TrainingTypeUtil'

/** containsTag。 */
function containsTag(list: string[], target: string): boolean { return list.includes(target) }
/** mapCourseStatusToNumber。 */
function mapCourseStatusToNumber(status: string): number {
  const value = status.toLowerCase()
  return value === 'published' || value === 'enabled' || value === 'online' ? 1 : 0
}

/**
 * 对课程标签做去重与空值过滤。
 */
export function normalizeCourseTags(tags: string[]): string[] {
  const result: string[] = []
  for (let i = 0; i < tags.length; i += 1) {
    const tag = tags[i].trim()
    if (tag.length > 0 && !containsTag(result, tag)) result.push(tag)
  }
  return result
}

/**
 * 把后端返回的标签 DTO 映射为前端标签列表。
 */
export function mapCourseTagDtos(list: CourseTagSource[]): string[] {
  const tags: string[] = []
  for (let i = 0; i < list.length; i += 1) {
    const name = String(list[i].name ?? '').trim()
    if (name.length > 0 && !containsTag(tags, name)) tags.push(name)
  }
  return tags
}

/**
 * 把后端课程列表数据映射为页面使用的课程对象。
 */
export function mapCourseListDtos(list: CourseListItemSource[]): Course[] {
  const mapped: Course[] = []
  for (let i = 0; i < list.length; i += 1) {
    const dto = list[i]
    const course = new Course()
    course.id = Number(dto.id ?? (i + 1))
    course.code = String(dto.courseCode ?? '')
    course.name = String(dto.courseName ?? '')
    course.coverUrl = String(dto.coverUrl ?? '')
    course.intro = String(dto.intro ?? '')
    course.trainingType = normalizeTrainingType(String(dto.trainingType ?? 'gesture'))
    course.tags = normalizeCourseTags(Array.isArray(dto.tags) ? dto.tags : [])
    course.learnCount = Number(dto.learnCount ?? 0)
    course.level = Number(dto.difficultyLevel ?? 0)
    course.status = mapCourseStatusToNumber(String(dto.status ?? ''))
    mapped.push(course)
  }
  return mapped
}

/**
 * 把后端课程详情数据映射为详情缓存写入输入。
 * 说明：loadCourseDetailPageData 会先调用这个映射，再写入 CourseDetailRepository。
 */
export function mapCourseDetailSourceToCacheInput(detail: CourseDetailSource): CourseDetailCacheInput {
  return {
    id: Number(detail.id ?? 0),
    courseName: String(detail.courseName ?? ''),
    coverUrl: String(detail.coverUrl ?? ''),
    intro: String(detail.intro ?? ''),
    trainingType: normalizeTrainingType(String(detail.trainingType ?? 'gesture')),
    tags: Array.isArray(detail.tags) ? [...detail.tags] : [],
    learnCount: Number(detail.learnCount ?? 0),
    level: Number(detail.difficultyLevel ?? detail.level ?? 0),
    status: Number(detail.status ?? 0),
    favorite: Boolean(detail.favorite ?? false),
    updatedAt: String(detail.updatedAt ?? '')
  }
}
