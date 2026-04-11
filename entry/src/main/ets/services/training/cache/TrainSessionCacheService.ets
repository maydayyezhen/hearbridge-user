/**
 * 训练缓存服务，负责运行时训练状态与课程会话缓存之间的同步。
 * 课程详情加载链路中用于把训练会话接口结果落盘为 CourseSessionCache。
 */
import { TrainingContentItem } from '../../../domain/static/train/TrainingContentModels'
import { TrainItemStatus } from '../../../domain/static/train/TrainingRuntimeTypes'
import type { TrainingSessionDetailItemSource, TrainingSessionDetailResponseSource } from '../../../api/requests/TrainingApi'
import {
  clearCourseSessionRecords,
  CourseSessionCacheEntry,
  CourseSessionItemSnapshot,
  removeCourseSessionCache,
  setCourseSessionCache
} from '../../../repository/course/CourseSessionRepository'
import { TrainSessionRuntime } from '../../../repository/train-session/TrainSessionRepository'
import { normalizeTrainItemStatus, normalizeTrainingType } from '../../../utils/TrainingTypeUtil'

function resolveProjectedCurrentItemStatus(runtime: TrainSessionRuntime, currentItem?: TrainingContentItem, currentItemStatus?: TrainItemStatus): TrainItemStatus {
  const normalizedCurrentStatus = currentItemStatus !== undefined && currentItemStatus.length > 0
    ? normalizeTrainItemStatus(currentItemStatus)
    : normalizeTrainItemStatus(currentItem ? currentItem.status : runtime.currentItemStatus)
  if (normalizedCurrentStatus === 'completed') return 'completed'
  if (runtime.currentStage === 'summary') return normalizedCurrentStatus
  return 'in_progress'
}

/**
 * 清理训练模块缓存。
 * @param courseCode 可选课程编码；有值时仅清理当前课程缓存。
 */
export function clearTrainingSessionCache(courseCode?: string): void {
  const safeCourseCode = String(courseCode ?? '').trim()
  if (safeCourseCode.length > 0) {
    removeCourseSessionCache(safeCourseCode)
    return
  }
  clearCourseSessionRecords()
}

/**
 * 把详情源中的训练项映射为课程会话缓存快照。
 * @param items 训练项源数组。
 * @returns 课程会话缓存训练项快照数组。
 */
function mapDetailItemsToCourseSessionItems(items: TrainingSessionDetailItemSource[]): CourseSessionItemSnapshot[] {
  const result: CourseSessionItemSnapshot[] = []
  for (let i = 0; i < items.length; i += 1) {
    result.push({
      itemName: String(items[i].itemName ?? ''),
      itemCode: String(items[i].itemCode ?? ''),
      levelNum: Number(items[i].levelNum ?? 1),
      itemOrder: Number(items[i].itemOrder ?? (i + 1)),
      status: normalizeTrainItemStatus(String(items[i].status ?? ''))
    })
  }
  return result
}

/**
 * 把运行时训练项映射为课程会话缓存快照。
 * @param items 训练运行时训练项数组。
 * @returns 课程会话缓存训练项快照数组。
 */
function mapRuntimeItemsToCourseSessionItems(items: TrainingContentItem[]): CourseSessionItemSnapshot[] {
  const result: CourseSessionItemSnapshot[] = []
  for (let i = 0; i < items.length; i += 1) {
    result.push({
      itemName: items[i].name,
      itemCode: items[i].code,
      levelNum: items[i].levelNum,
      itemOrder: Number(items[i].itemOrder ?? (i + 1)),
      status: items[i].status
    })
  }
  return result
}

/**
 * 把训练会话详情同步到课程会话缓存。
 * @param courseCode 课程编码。
 * @param detail 训练会话详情源。
 * @param sessionId 训练会话 id。
 * @param currentItemStatus 当前训练项状态。
 */
export function cacheTrainingSessionDetail(courseCode: string, detail: TrainingSessionDetailResponseSource, sessionId: number, currentItemStatus: TrainItemStatus): void {
  // 这里写入的 courseSessionEntry 会被课程详情页直接读取并映射成页面进度信息。
  const courseSessionEntry = new CourseSessionCacheEntry()
  courseSessionEntry.sessionId = sessionId
  courseSessionEntry.sessionProgressPercent = Number(detail.progressPercent ?? 0)
  courseSessionEntry.completedItemCount = Number(detail.completedItemCount ?? 0)
  courseSessionEntry.totalItemCount = Number(detail.totalItemCount ?? 0)
  courseSessionEntry.currentItemCode = String(detail.currentItemCode ?? '')
  courseSessionEntry.currentItemStatus = normalizeTrainItemStatus(currentItemStatus)
  courseSessionEntry.trainingType = normalizeTrainingType(String(detail.trainingType ?? 'gesture'))
  courseSessionEntry.items = mapDetailItemsToCourseSessionItems(detail.items ?? [])
  courseSessionEntry.updatedAt = Date.now()
  setCourseSessionCache(courseCode, courseSessionEntry)
}

/**
 * 根据训练运行时状态同步课程会话缓存。
 * @param runtime 当前训练运行时。
 * @param items 可选训练项数组。
 * @param progressPercent 可选训练进度百分比。
 * @param currentItemStatus 可选当前训练项状态。
 */
export function syncCourseSessionCacheFromRuntime(runtime: TrainSessionRuntime, items?: TrainingContentItem[], progressPercent?: number, currentItemStatus?: TrainItemStatus): void {
  if (runtime.courseCode.length === 0 || runtime.sessionId <= 0) return
  const sourceItems = items ?? runtime.items
  const entry = new CourseSessionCacheEntry()
  entry.sessionId = runtime.sessionId
  entry.sessionProgressPercent = progressPercent !== undefined ? progressPercent : runtime.sessionProgressPercent
  entry.completedItemCount = 0
  entry.totalItemCount = sourceItems.length
  for (let i = 0; i < sourceItems.length; i += 1) {
    if (sourceItems[i].status === 'completed') entry.completedItemCount += 1
  }
  const safeIndex = sourceItems.length > 0 ? Math.max(0, Math.min(runtime.currentItemIndex, sourceItems.length - 1)) : 0
  const currentItem = sourceItems.length > 0 ? sourceItems[safeIndex] : undefined
  const projectedCurrentStatus = resolveProjectedCurrentItemStatus(runtime, currentItem, currentItemStatus)
  entry.currentItemCode = currentItem ? currentItem.code : ''
  entry.currentItemStatus = projectedCurrentStatus
  entry.trainingType = runtime.trainingType
  entry.items = mapRuntimeItemsToCourseSessionItems(sourceItems)
  if (currentItem && safeIndex >= 0 && safeIndex < entry.items.length) {
    entry.items[safeIndex] = {
      itemName: entry.items[safeIndex].itemName,
      itemCode: entry.items[safeIndex].itemCode,
      levelNum: entry.items[safeIndex].levelNum,
      itemOrder: entry.items[safeIndex].itemOrder,
      status: projectedCurrentStatus
    }
  }
  entry.updatedAt = Date.now()
  setCourseSessionCache(runtime.courseCode, entry)
}
