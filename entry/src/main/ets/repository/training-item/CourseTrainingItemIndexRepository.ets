/**
 * CourseTrainingItemIndexRepository 文件，负责对应模块的仓储读写与状态转接。
 * 课程详情加载链路中用于读取/刷新课程训练项列表（detail 优先，preview 回退）。
 */

import { TrainingContentItem } from '../../domain/static/train/TrainingContentModels'
import {
  appendCourseItemKey,
  clearCourseTrainingItemIndexCache,
  ensureCourseItemIndex,
  getCourseTrainingItemCodes,
  initCourseTrainingItemIndexStore
} from '../../storage/training-item/CourseTrainingItemIndexStore'
import { buildTrainingItemCacheKey } from '../../storage/training-item/TrainingItemPreviewStore'
import { getTrainingItemDetailEntity } from './TrainingItemDetailRepository'
import { getTrainingItemPreviewEntity, setTrainingItemPreview } from './TrainingItemPreviewRepository'
import { clearTrainingItemDetailCache } from '../../storage/training-item/TrainingItemDetailStore'
import { clearTrainingItemPreviewCache } from '../../storage/training-item/TrainingItemPreviewStore'

/**
 * 初始化课程训练项索引仓储依赖的 Store。
 */
export function initCourseTrainingItemIndexRepository(): void {
  initCourseTrainingItemIndexStore()
}

/**
 * 读取课程下的训练项缓存键列表。
 * @param courseCode 课程编码。
 * @returns 训练项缓存键列表。
 */
export function getCourseTrainingItemKeys(courseCode: string): string[] {
  return getCourseTrainingItemCodes(courseCode)
}

/**
 * 读取课程下全部训练项实体。
 * @param courseCode 课程编码。
 * @returns 训练项实体列表。
 */
export function getCourseTrainingItems(courseCode: string): TrainingContentItem[] {
  const keys = getCourseTrainingItemCodes(courseCode)
  const result: TrainingContentItem[] = []
  for (let i = 0; i < keys.length; i += 1) {
    const key = keys[i]
    const separatorIndex = key.indexOf(':')
    const itemCode = separatorIndex >= 0 ? key.slice(separatorIndex + 1) : key
    // 读取顺序：先拿 detail，detail 不存在时回退 preview。
    const detail = getTrainingItemDetailEntity(courseCode, itemCode)
    if (detail) {
      result.push(detail)
      continue
    }
    const preview = getTrainingItemPreviewEntity(courseCode, itemCode)
    if (preview) result.push(preview)
  }
  return result
}

/**
 * 以统一实体形式读取训练项。
 * @param courseCode 课程编码。
 * @param itemCode 训练项编码。
 * @returns 训练项实体。
 */
export function getTrainingItemEntity(courseCode: string, itemCode: string): TrainingContentItem | undefined {
  return getTrainingItemDetailEntity(courseCode, itemCode) ?? getTrainingItemPreviewEntity(courseCode, itemCode)
}

/**
 * 批量写入课程下的训练项预览缓存，并覆盖课程与训练项索引。
 * @param courseCode 课程编码。
 * @param items 训练项实体列表。
 */
export function upsertCourseTrainingItemPreviews(courseCode: string, items: TrainingContentItem[]): void {
  if (courseCode.length === 0) return
  const nextKeys: string[] = []
  for (let i = 0; i < items.length; i += 1) {
    const item = items[i]
    if (item.code.length === 0) continue
    const key = buildTrainingItemCacheKey(courseCode, item.code)
    nextKeys.push(key)
    setTrainingItemPreview(courseCode, item)
  }
  // 批量覆盖课程训练项索引，供课程详情页后续快速预热。
  if (nextKeys.length > 0) ensureCourseItemIndex(courseCode, nextKeys)
}

/**
 * 向课程与训练项索引中追加单个训练项键。
 * @param courseCode 课程编码。
 * @param itemCode 训练项编码。
 */
export function appendCourseTrainingItem(courseCode: string, itemCode: string): void {
  appendCourseItemKey(courseCode, buildTrainingItemCacheKey(courseCode, itemCode))
}

/**
 * 清空训练项实体缓存与课程训练项索引。
 */
export function clearTrainingItemEntityCache(): void {
  clearTrainingItemPreviewCache()
  clearTrainingItemDetailCache()
  clearCourseTrainingItemIndexCache()
}

