/**
 * CourseSessionRepository 文件，负责对应模块的仓储读写与状态转接。
 * 课程详情加载链路中承载动态进度快照（progress/currentItem/completedCount/items）。
 */

import {
  clearCourseSessionCache,
  CourseSessionCacheEntry,
  CourseSessionDetailSnapshot,
  CourseSessionItemSnapshot,
  createCourseSessionDetailSnapshot,
  deleteCourseSessionEntry,
  getCourseSessionEntry,
  initCourseSessionStore,
  setCourseSessionEntry
} from '../../storage/course/CourseSessionStore'

export {
  CourseSessionCacheEntry,
  CourseSessionDetailSnapshot,
  CourseSessionItemSnapshot,
  createCourseSessionDetailSnapshot
}

/**
 * 初始化课程会话仓储依赖的 Store。
 */
export function initCourseSessionRepository(): void {
  initCourseSessionStore()
}

/**
 * 读取课程会话缓存。
 * @param courseCode 课程编码。
 * @returns 课程会话缓存条目。
 */
export function getCourseSessionCache(courseCode: string): CourseSessionCacheEntry | undefined {
  return getCourseSessionEntry(courseCode)
}

/**
 * 写入课程会话缓存。
 * @param courseCode 课程编码。
 * @param value 课程会话缓存条目。
 */
export function setCourseSessionCache(courseCode: string, value: CourseSessionCacheEntry): void {
  setCourseSessionEntry(courseCode, value)
}

/**
 * 删除单个课程会话缓存。
 * @param courseCode 课程编码。
 */
export function removeCourseSessionCache(courseCode: string): void {
  deleteCourseSessionEntry(courseCode)
}

/**
 * 清空课程会话缓存。
 */
export function clearCourseSessionRecords(): void {
  clearCourseSessionCache()
}
