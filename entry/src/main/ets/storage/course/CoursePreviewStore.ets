/**
 * 课程预览缓存条目。
 * 仅保留课程轻量展示需要的字段。
 */
import { TrainingType } from '../../domain/static/train/TrainingRuntimeTypes'

export interface CoursePreviewCacheEntry {
  /** 课程主键。 */
  id: number
  /** 课程编码。 */
  courseCode: string
  /** 课程名称。 */
  courseName: string
  /** 课程封面地址。 */
  coverUrl: string
  /** 课程简介。 */
  intro: string
  /** 训练类型。 */
  trainingType: TrainingType
  /** 课程标签。 */
  tags: string[]
  /** 学习人数。 */
  learnCount: number
  /** 课程难度。 */
  level: number
  /** 课程状态。 */
  status: number
  /** 是否已收藏。 */
  favorite: boolean
  /** 课程更新时间。 */
  updatedAt: string
}

/** 课程预览缓存表，按课程编码索引。 */
const COURSE_PREVIEW_CACHE: Map<string, CoursePreviewCacheEntry> = new Map()

/**
 * 初始化课程预览缓存 Store。
 */
export function initCoursePreviewStore(): void {}

/**
 * 创建默认课程预览缓存条目。
 * @param courseCode 课程编码。
 * @returns 默认课程预览条目。
 */
export function createDefaultCoursePreviewEntry(courseCode: string): CoursePreviewCacheEntry {
  return {
    id: 0,
    courseCode,
    courseName: courseCode,
    coverUrl: '',
    intro: '',
    trainingType: 'gesture',
    tags: [],
    learnCount: 0,
    level: 0,
    status: 1,
    favorite: false,
    updatedAt: ''
  }
}

/**
 * 复制课程预览缓存条目。
 * 说明：这里只做受控浅拷贝，重点断开 tags 数组引用。
 * @param entry 原始缓存条目。
 * @returns 复制后的缓存条目。
 */
function cloneCoursePreviewEntry(entry: CoursePreviewCacheEntry): CoursePreviewCacheEntry {
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
    updatedAt: entry.updatedAt
  }
}

/**
 * 读取课程预览缓存。
 * @param courseCode 课程编码。
 * @returns 课程预览缓存条目。
 */
export function getCoursePreviewEntry(courseCode: string): CoursePreviewCacheEntry | null {
  const preview = COURSE_PREVIEW_CACHE.get(courseCode)
  return preview ? cloneCoursePreviewEntry(preview) : null
}

/**
 * 写入课程预览缓存。
 * @param courseCode 课程编码。
 * @param entry 课程预览缓存条目。
 */
export function setCoursePreviewEntry(courseCode: string, entry: CoursePreviewCacheEntry): void {
  if (courseCode.length === 0) return
  COURSE_PREVIEW_CACHE.set(courseCode, cloneCoursePreviewEntry(entry))
}

/**
 * 局部更新课程预览缓存字段。
 * @param courseCode 课程编码。
 * @param patch 课程预览缓存字段补丁。
 */
export function patchCoursePreviewEntry(courseCode: string, patch: Partial<CoursePreviewCacheEntry>): void {
  const current = getCoursePreviewEntry(courseCode) ?? createDefaultCoursePreviewEntry(courseCode)
  const next: CoursePreviewCacheEntry = createDefaultCoursePreviewEntry(courseCode)
  next.id = patch.id !== undefined ? patch.id : current.id
  next.courseCode = courseCode
  next.courseName = patch.courseName !== undefined ? patch.courseName : current.courseName
  next.coverUrl = patch.coverUrl !== undefined ? patch.coverUrl : current.coverUrl
  next.intro = patch.intro !== undefined ? patch.intro : current.intro
  next.trainingType = patch.trainingType !== undefined ? patch.trainingType : current.trainingType
  next.tags = patch.tags !== undefined ? patch.tags.slice() : current.tags.slice()
  next.learnCount = patch.learnCount !== undefined ? patch.learnCount : current.learnCount
  next.level = patch.level !== undefined ? patch.level : current.level
  next.status = patch.status !== undefined ? patch.status : current.status
  next.favorite = patch.favorite !== undefined ? patch.favorite : current.favorite
  next.updatedAt = patch.updatedAt !== undefined ? patch.updatedAt : current.updatedAt
  COURSE_PREVIEW_CACHE.set(courseCode, next)
}

/**
 * 判断课程预览缓存是否存在。
 * @param courseCode 课程编码。
 * @returns 是否存在课程预览缓存。
 */
export function hasCoursePreview(courseCode: string): boolean {
  return COURSE_PREVIEW_CACHE.has(courseCode)
}

/**
 * 清空课程预览缓存。
 */
export function clearCoursePreviewCache(): void {
  COURSE_PREVIEW_CACHE.clear()
}
