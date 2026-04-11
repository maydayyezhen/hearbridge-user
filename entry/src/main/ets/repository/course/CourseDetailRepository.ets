/**
 * CourseDetailRepository 文件，负责对应模块的仓储读写与状态转接。
 * 课程详情加载链路中用于承接课程静态详情缓存（name/intro/cover/trainingType/tags）。
 */

import { Course } from '../../domain/entity/Course'
import { TrainingType } from '../../domain/static/train/TrainingRuntimeTypes'
import {
  CourseDetailCacheEntry,
  createDefaultCourseDetailEntry,
  getCourseDetailEntry,
  hasCourseDetail,
  initCourseDetailStore,
  setCourseDetailEntry,
  clearCourseDetailCache
} from '../../storage/course/CourseDetailStore'
import { CoursePreviewCacheEntry, getCoursePreviewEntry } from '../../storage/course/CoursePreviewStore'
import { getCoursePreviewEntity, saveCoursePreview } from './CoursePreviewRepository'

/**
 * 课程详情缓存写入输入。
 */
export interface CourseDetailCacheInput {
  id: number
  courseName: string
  coverUrl: string
  intro: string
  trainingType: TrainingType
  tags: string[]
  learnCount: number
  level: number
  status: number
  favorite: boolean
  updatedAt: string
}

/**
 * 初始化课程详情仓储依赖的 Store。
 */
export function initCourseDetailRepository(): void {
  initCourseDetailStore()
}

/**
 * 将课程详情缓存条目转换为课程实体。
 * @param entry 课程详情缓存条目。
 * @returns 课程实体。
 */
function createCourseFromDetailEntry(entry: CourseDetailCacheEntry): Course {
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
 * 基于课程详情缓存输入创建详情缓存条目。
 * @param courseCode 课程编码。
 * @param value 课程详情缓存写入输入。
 * @param preview 可选的课程预览缓存条目。
 * @returns 课程详情缓存条目。
 */
function createDetailEntry(courseCode: string, value: CourseDetailCacheInput, preview?: CoursePreviewCacheEntry | null): CourseDetailCacheEntry {
  const basePreview = preview ?? getCoursePreviewEntry(courseCode)
  const base = createDefaultCourseDetailEntry(courseCode)
  if (basePreview) {
    base.id = basePreview.id
    base.courseCode = basePreview.courseCode
    base.courseName = basePreview.courseName
    base.coverUrl = basePreview.coverUrl
    base.intro = basePreview.intro
    base.trainingType = basePreview.trainingType
    base.tags = basePreview.tags.slice()
    base.learnCount = basePreview.learnCount
    base.level = basePreview.level
    base.status = basePreview.status
    base.favorite = basePreview.favorite
    base.updatedAt = basePreview.updatedAt
  }
  return {
    id: value.id > 0 ? value.id : base.id,
    courseCode,
    courseName: value.courseName.length > 0 ? value.courseName : base.courseName,
    coverUrl: value.coverUrl.length > 0 ? value.coverUrl : base.coverUrl,
    intro: value.intro.length > 0 ? value.intro : base.intro,
    trainingType: value.trainingType,
    tags: value.tags.length > 0 ? value.tags.slice() : base.tags.slice(),
    learnCount: Number.isFinite(value.learnCount) ? value.learnCount : base.learnCount,
    level: Number.isFinite(value.level) ? value.level : base.level,
    status: Number.isFinite(value.status) ? value.status : base.status,
    favorite: value.favorite,
    updatedAt: value.updatedAt.length > 0 ? value.updatedAt : base.updatedAt,
    cachedAt: Date.now()
  }
}

/**
 * 读取课程详情缓存条目。
 * @param courseCode 课程编码。
 * @returns 课程详情缓存条目。
 */
export function getCourseDetailCache(courseCode: string): CourseDetailCacheEntry | undefined {
  return getCourseDetailEntry(courseCode)
}

/**
 * 写入课程详情缓存。
 * @param courseCode 课程编码。
 * @param value 课程详情缓存写入输入。
 */
export function setCourseDetailCache(courseCode: string, value: CourseDetailCacheInput): void {
  // 课程详情写入后同步覆盖 preview，保证页面 fallback 字段一致。
  const entry = createDetailEntry(courseCode, value)
  setCourseDetailEntry(courseCode, entry)
  saveCoursePreview(createCourseFromDetailEntry(entry))
}

/**
 * 判断课程详情缓存是否存在。
 * @param courseCode 课程编码。
 * @returns 是否存在课程详情缓存。
 */
export function hasCourseDetailRecord(courseCode: string): boolean {
  return hasCourseDetail(courseCode)
}

/**
 * 读取最佳可用课程实体。
 * 优先使用详情缓存，不存在时回退到预览缓存。
 * @param courseCode 课程编码。
 * @returns 最佳可用课程实体。
 */
export function getCourse(courseCode: string): Course | null {
  const detail = getCourseDetailEntry(courseCode)
  if (detail) return createCourseFromDetailEntry(detail)
  return getCoursePreviewEntity(courseCode)
}

/**
 * 清空课程详情缓存。
 */
export function clearCourseDetailRecords(): void {
  clearCourseDetailCache()
}
