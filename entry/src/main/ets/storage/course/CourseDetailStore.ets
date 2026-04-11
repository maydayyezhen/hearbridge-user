/**
 * CourseDetailStore 文件，负责对应模块的本地状态存取。
 */

import { CoursePreviewCacheEntry, createDefaultCoursePreviewEntry } from './CoursePreviewStore'

/**
 * 课程详情缓存条目。
 * 在课程预览字段基础上，补充详情页需要的额外信息。
 */
export interface CourseDetailCacheEntry extends CoursePreviewCacheEntry {
  /** 详情缓存写入时间戳。 */
  cachedAt: number
}

/** 课程详情缓存表，按课程编码索引。 */
const COURSE_DETAIL_CACHE: Map<string, CourseDetailCacheEntry> = new Map()

/**
 * 初始化课程详情缓存 Store。
 */
export function initCourseDetailStore(): void {}

/**
 * 创建默认课程详情缓存条目。
 * @param courseCode 课程编码。
 * @returns 默认课程详情缓存条目。
 */
export function createDefaultCourseDetailEntry(courseCode: string): CourseDetailCacheEntry {
  const preview = createDefaultCoursePreviewEntry(courseCode)
  return {
    id: preview.id,
    courseCode: preview.courseCode,
    courseName: preview.courseName,
    coverUrl: preview.coverUrl,
    intro: preview.intro,
    trainingType: preview.trainingType,
    tags: preview.tags.slice(),
    learnCount: preview.learnCount,
    level: preview.level,
    status: preview.status,
    favorite: preview.favorite,
    updatedAt: preview.updatedAt,
    cachedAt: 0
  }
}

/**
 * 复制课程详情缓存条目。
 * 说明：这里只做受控浅拷贝，重点断开 tags 数组引用。
 * @param entry 原始缓存条目。
 * @returns 复制后的缓存条目。
 */
function cloneCourseDetailEntry(entry: CourseDetailCacheEntry): CourseDetailCacheEntry {
  return {
    id: entry.id,
    courseCode: entry.courseCode,
    courseName: entry.courseName,
    coverUrl: entry.coverUrl,
    intro: entry.intro,
    trainingType: entry.trainingType,
    tags: entry.tags.slice(),
    learnCount: entry.learnCount,
    level: entry.level,
    status: entry.status,
    favorite: entry.favorite,
    updatedAt: entry.updatedAt,
    cachedAt: entry.cachedAt
  }
}

/**
 * 读取课程详情缓存。
 * @param courseCode 课程编码。
 * @returns 课程详情缓存条目。
 */
export function getCourseDetailEntry(courseCode: string): CourseDetailCacheEntry | undefined {
  const cached = COURSE_DETAIL_CACHE.get(courseCode)
  return cached ? cloneCourseDetailEntry(cached) : undefined
}

/**
 * 写入课程详情缓存。
 * @param courseCode 课程编码。
 * @param entry 课程详情缓存条目。
 */
export function setCourseDetailEntry(courseCode: string, entry: CourseDetailCacheEntry): void {
  if (courseCode.length === 0) return
  COURSE_DETAIL_CACHE.set(courseCode, cloneCourseDetailEntry(entry))
}

/**
 * 判断课程详情缓存是否存在。
 * @param courseCode 课程编码。
 * @returns 是否存在详情缓存。
 */
export function hasCourseDetail(courseCode: string): boolean {
  return COURSE_DETAIL_CACHE.has(courseCode)
}

/**
 * 清空课程详情缓存。
 */
export function clearCourseDetailCache(): void {
  COURSE_DETAIL_CACHE.clear()
}
