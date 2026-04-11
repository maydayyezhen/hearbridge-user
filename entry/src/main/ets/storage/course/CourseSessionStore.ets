/**
 * 课程会话缓存条目。
 * 只存课程对应训练会话的摘要状态。
 */
import { TrainingType, TrainItemStatus } from '../../domain/static/train/TrainingRuntimeTypes'

/**
 * 课程会话缓存中的训练项快照。
 */
export interface CourseSessionItemSnapshot {
  itemName: string
  itemCode: string
  levelNum: number
  itemOrder: number
  status: TrainItemStatus
}

/**
 * 课程会话缓存复用成训练会话详情时的本地快照。
 */
export interface CourseSessionDetailSnapshot {
  trainingType: TrainingType
  currentItemCode: string
  progressPercent: number
  completedItemCount: number
  totalItemCount: number
  items: CourseSessionItemSnapshot[]
}

export class CourseSessionCacheEntry {
  /** 会话 ID。 */
  sessionId: number = 0
  /** 会话进度百分比。 */
  sessionProgressPercent: number = 0
  /** 已完成训练项数量。 */
  completedItemCount: number = 0
  /** 训练项总数。 */
  totalItemCount: number = 0
  /** 当前训练项编码。 */
  currentItemCode: string = ''
  /** 当前训练项状态。 */
  currentItemStatus: TrainItemStatus = ''
  /** 训练类型。 */
  trainingType: TrainingType = 'gesture'
  /** 训练项快照。 */
  items: CourseSessionItemSnapshot[] = []
  /** 最近学习时间戳。 */
  lastLearnedAt: string = ''
  /** 缓存更新时间戳。 */
  updatedAt: number = 0
}

/** 课程会话缓存表，按课程编码索引。 */
const COURSE_SESSION_CACHE: Map<string, CourseSessionCacheEntry> = new Map()

/**
 * 初始化课程会话缓存 Store。
 */
export function initCourseSessionStore(): void {}

/**
 * 深拷贝课程会话训练项快照。
 * @param item 原始训练项快照。
 * @returns 拷贝后的训练项快照。
 */
function cloneCourseSessionItemSnapshot(item: CourseSessionItemSnapshot): CourseSessionItemSnapshot {
  return {
    itemName: item.itemName,
    itemCode: item.itemCode,
    levelNum: item.levelNum,
    itemOrder: item.itemOrder,
    status: item.status
  }
}

/**
 * 深拷贝课程会话缓存条目。
 * @param entry 原始缓存条目。
 * @returns 拷贝后的缓存条目。
 */
function cloneCourseSession(entry: CourseSessionCacheEntry): CourseSessionCacheEntry {
  const cloned = new CourseSessionCacheEntry()
  cloned.sessionId = entry.sessionId
  cloned.sessionProgressPercent = entry.sessionProgressPercent
  cloned.completedItemCount = entry.completedItemCount
  cloned.totalItemCount = entry.totalItemCount
  cloned.currentItemCode = entry.currentItemCode
  cloned.currentItemStatus = entry.currentItemStatus
  cloned.trainingType = entry.trainingType
  cloned.items = entry.items.map((item: CourseSessionItemSnapshot): CourseSessionItemSnapshot => cloneCourseSessionItemSnapshot(item))
  cloned.lastLearnedAt = entry.lastLearnedAt
  cloned.updatedAt = entry.updatedAt
  return cloned
}

/**
 * 从课程会话缓存条目提取训练会话详情快照。
 * @param entry 课程会话缓存条目。
 * @returns 可复用的训练会话详情快照。
 */
export function createCourseSessionDetailSnapshot(entry: CourseSessionCacheEntry): CourseSessionDetailSnapshot {
  return {
    trainingType: entry.trainingType,
    currentItemCode: entry.currentItemCode,
    progressPercent: entry.sessionProgressPercent,
    completedItemCount: entry.completedItemCount,
    totalItemCount: entry.totalItemCount,
    items: entry.items.map((item: CourseSessionItemSnapshot): CourseSessionItemSnapshot => cloneCourseSessionItemSnapshot(item))
  }
}

/**
 * 读取课程会话缓存。
 * @param courseCode 课程编码。
 * @returns 课程会话缓存条目。
 */
export function getCourseSessionEntry(courseCode: string): CourseSessionCacheEntry | undefined {
  const cached = COURSE_SESSION_CACHE.get(courseCode)
  return cached ? cloneCourseSession(cached) : undefined
}

/**
 * 写入课程会话缓存。
 * @param courseCode 课程编码。
 * @param value 课程会话缓存条目。
 */
export function setCourseSessionEntry(courseCode: string, value: CourseSessionCacheEntry): void {
  COURSE_SESSION_CACHE.set(courseCode, cloneCourseSession(value))
}

/**
 * 删除单个课程会话缓存。
 * @param courseCode 课程编码。
 */
export function deleteCourseSessionEntry(courseCode: string): void {
  COURSE_SESSION_CACHE.delete(courseCode)
}

/**
 * 清空课程会话缓存。
 */
export function clearCourseSessionCache(): void {
  COURSE_SESSION_CACHE.clear()
}
