/**
 * TrainingItemDetailRepository 文件，负责训练项详情缓存的基础读写与实体转换。
 */

import { TrainingContentItem } from '../../domain/static/train/TrainingContentModels'
import {
  TrainingItemDetailCacheEntry,
  createDefaultTrainingItemDetailEntry,
  getTrainingItemDetailEntry,
  initTrainingItemDetailStore,
  setTrainingItemDetailEntry,
  clearTrainingItemDetailCache
} from '../../storage/training-item/TrainingItemDetailStore'
import { cloneMediaResources } from '../../storage/training-item/TrainingItemPreviewStore'

export { TrainingItemDetailCacheEntry }

/**
 * 初始化训练项详情仓储依赖的 Store。
 */
export function initTrainingItemDetailRepository(): void {
  initTrainingItemDetailStore()
}

/**
 * 将训练项详情缓存条目转换为训练项实体。
 */
function createTrainingItemFromDetailEntry(entry: TrainingItemDetailCacheEntry): TrainingContentItem {
  const item = new TrainingContentItem(0, '', '', '', 1, false, 0, 0, '', '', '', '', [], [], [], [], [], [], [])
  item.id = entry.id
  item.name = entry.name
  item.code = entry.code
  item.majorCategoryCode = entry.majorCategoryCode
  item.levelNum = entry.levelNum
  item.isRecommended = entry.isRecommended
  item.itemOrder = entry.itemOrder
  item.score = entry.score
  item.status = entry.status
  item.meaning = entry.meaning
  item.description = entry.description
  item.goal = entry.goal
  item.precautions = entry.precautions.slice()
  item.commonErrors = entry.commonErrors.slice()
  item.cover = cloneMediaResources(entry.cover)
  item.video = cloneMediaResources(entry.video)
  item.audio = cloneMediaResources(entry.audio)
  item.actionImages = cloneMediaResources(entry.actionImages)
  item.videoPoster = cloneMediaResources(entry.videoPoster)
  return item
}

/**
 * 根据训练项实体创建训练项详情缓存条目。
 */
export function createTrainingItemDetailEntryFromItem(courseCode: string, item: TrainingContentItem): TrainingItemDetailCacheEntry {
  const entry = createDefaultTrainingItemDetailEntry(courseCode, item.code)
  entry.id = item.id
  entry.name = item.name
  entry.code = item.code
  entry.majorCategoryCode = item.majorCategoryCode
  entry.levelNum = item.levelNum
  entry.isRecommended = item.isRecommended
  entry.itemOrder = item.itemOrder
  entry.score = item.score
  entry.status = item.status
  entry.cover = cloneMediaResources(item.cover)
  entry.videoPoster = cloneMediaResources(item.videoPoster)
  entry.meaning = item.meaning
  entry.description = item.description
  entry.goal = item.goal
  entry.precautions = item.precautions.slice()
  entry.commonErrors = item.commonErrors.slice()
  entry.video = cloneMediaResources(item.video)
  entry.audio = cloneMediaResources(item.audio)
  entry.actionImages = cloneMediaResources(item.actionImages)
  return entry
}

/**
 * 读取训练项详情缓存条目。
 */
export function getTrainingItemDetail(courseCode: string, itemCode: string): TrainingItemDetailCacheEntry | undefined {
  return getTrainingItemDetailEntry(courseCode, itemCode)
}

/**
 * 读取训练项详情对应的训练项实体。
 */
export function getTrainingItemDetailEntity(courseCode: string, itemCode: string): TrainingContentItem | undefined {
  const detail = getTrainingItemDetailEntry(courseCode, itemCode)
  return detail ? createTrainingItemFromDetailEntry(detail) : undefined
}

/**
 * 直接写入训练项详情缓存条目。
 */
export function writeTrainingItemDetail(courseCode: string, itemCode: string, entry: TrainingItemDetailCacheEntry): void {
  setTrainingItemDetailEntry(courseCode, itemCode, entry)
}

/**
 * 创建默认训练项详情缓存条目。
 */
export function createDefaultTrainingItemDetail(courseCode: string, itemCode: string): TrainingItemDetailCacheEntry {
  return createDefaultTrainingItemDetailEntry(courseCode, itemCode)
}

/**
 * 清空训练项详情缓存。
 */
export function clearTrainingItemDetailRecords(): void {
  clearTrainingItemDetailCache()
}
