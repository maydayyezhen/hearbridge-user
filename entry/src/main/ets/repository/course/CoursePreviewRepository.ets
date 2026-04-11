/**
 * CoursePreviewRepository 文件，负责对应模块的仓储读写与状态转接。
 * 课程详情加载链路中作为静态字段回退层（detail 未命中时兜底 courseName/intro/cover 等）。
 */

import { Course } from '../../domain/entity/Course'
import { normalizeTrainingType } from '../../utils/TrainingTypeUtil'
import {
  CoursePreviewCacheEntry,
  createDefaultCoursePreviewEntry,
  getCoursePreviewEntry,
  hasCoursePreview,
  initCoursePreviewStore,
  patchCoursePreviewEntry,
  setCoursePreviewEntry,
  clearCoursePreviewCache
} from '../../storage/course/CoursePreviewStore'

/**
 * 初始化课程预览仓储依赖的 Store。
 */
export function initCoursePreviewRepository(): void {
  initCoursePreviewStore()
}

interface CoursePreviewPatchInput {
  courseName?: string
  intro?: string
  coverUrl?: string
  trainingType?: string
  tags?: string[]
  favorite?: boolean
}

/**
 * 将课程实体转换为课程预览缓存条目。
 * @param course 课程实体。
 * @returns 课程预览缓存条目。
 */
function createPreviewEntryFromCourse(course: Course): CoursePreviewCacheEntry {
  return {
    id: course.id,
    courseCode: course.code,
    courseName: course.name,
    coverUrl: course.coverUrl,
    intro: course.intro,
    trainingType: course.trainingType,
    tags: [...course.tags],
    learnCount: course.learnCount,
    level: course.level,
    status: course.status,
    favorite: course.favorite,
    updatedAt: course.updatedAt
  }
}

/**
 * 合并课程预览缓存条目。
 * @param base 旧的缓存条目。
 * @param incoming 新的课程实体。
 * @returns 合并后的缓存条目。
 */
function mergePreviewEntry(base: CoursePreviewCacheEntry | null, incoming: Course): CoursePreviewCacheEntry {
  const source = base ?? createDefaultCoursePreviewEntry(incoming.code)
  return {
    id: incoming.id > 0 ? incoming.id : source.id,
    courseCode: incoming.code.length > 0 ? incoming.code : source.courseCode,
    courseName: incoming.name.length > 0 ? incoming.name : source.courseName,
    coverUrl: incoming.coverUrl.length > 0 ? incoming.coverUrl : source.coverUrl,
    intro: incoming.intro.length > 0 ? incoming.intro : source.intro,
    trainingType: incoming.trainingType.length > 0 ? incoming.trainingType : source.trainingType,
    tags: incoming.tags.length > 0 ? [...incoming.tags] : [...source.tags],
    learnCount: incoming.learnCount > 0 ? incoming.learnCount : source.learnCount,
    level: incoming.level > 0 ? incoming.level : source.level,
    status: incoming.status,
    favorite: incoming.favorite,
    updatedAt: incoming.updatedAt.length > 0 ? incoming.updatedAt : source.updatedAt
  }
}

/**
 * 将课程预览缓存条目转换为课程实体。
 * @param entry 课程预览缓存条目。
 * @returns 课程实体。
 */
function createCourseFromPreviewEntry(entry: CoursePreviewCacheEntry): Course {
  const course = new Course()
  course.id = entry.id
  course.code = entry.courseCode
  course.name = entry.courseName
  course.coverUrl = entry.coverUrl
  course.intro = entry.intro
  course.trainingType = entry.trainingType
  course.tags = entry.tags.slice()
  course.learnCount = entry.learnCount
  course.level = entry.level
  course.status = entry.status
  course.updatedAt = entry.updatedAt
  course.favorite = entry.favorite
  return course
}

/**
 * 批量写入课程预览缓存。
 * @param courses 课程实体列表。
 */
export function saveCoursePreviewList(courses: Course[]): void {
  for (let i = 0; i < courses.length; i += 1) {
    saveCoursePreview(courses[i])
  }
}

/**
 * 写入单个课程预览缓存。
 * @param course 课程实体。
 */
export function saveCoursePreview(course: Course): void {
  if (course.code.length === 0) return
  const merged = mergePreviewEntry(getCoursePreviewEntry(course.code), course)
  setCoursePreviewEntry(course.code, merged)
}

/**
 * 读取课程预览缓存条目。
 * @param courseCode 课程编码。
 * @returns 课程预览缓存条目。
 */
export function getCoursePreview(courseCode: string): CoursePreviewCacheEntry | null {
  return getCoursePreviewEntry(courseCode)
}

/**
 * 读取课程预览对应的课程实体。
 * @param courseCode 课程编码。
 * @returns 课程实体。
 */
export function getCoursePreviewEntity(courseCode: string): Course | null {
  const preview = getCoursePreviewEntry(courseCode)
  return preview ? createCourseFromPreviewEntry(preview) : null
}

/**
 * 判断课程预览缓存是否存在。
 * @param courseCode 课程编码。
 * @returns 是否存在课程预览缓存。
 */
export function hasCoursePreviewRecord(courseCode: string): boolean {
  return hasCoursePreview(courseCode)
}

/**
 * 局部更新课程预览字段。
 * @param courseCode 课程编码。
 * @param patch 需要更新的轻量字段。
 */
export function patchCoursePreview(courseCode: string, patch: CoursePreviewPatchInput): void {
  const nextPatch: Partial<CoursePreviewCacheEntry> = createDefaultCoursePreviewEntry(courseCode)
  nextPatch.courseName = patch.courseName
  nextPatch.intro = patch.intro
  nextPatch.coverUrl = patch.coverUrl
  if (patch.trainingType !== undefined) {
    nextPatch.trainingType = normalizeTrainingType(patch.trainingType)
  }
  nextPatch.tags = patch.tags
  nextPatch.favorite = patch.favorite
  patchCoursePreviewEntry(courseCode, nextPatch)
}

/**
 * 清空课程预览缓存。
 */
export function clearCoursePreviewRecords(): void {
  clearCoursePreviewCache()
}

