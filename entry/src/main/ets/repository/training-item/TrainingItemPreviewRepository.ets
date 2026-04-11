/**
 * TrainingItemPreviewRepository 文件，负责对应模块的仓储读写与状态转接。
 */

import { TrainingContentItem } from '../../domain/static/train/TrainingContentModels'
import {
  TrainingItemPreviewCacheEntry,
  buildTrainingItemCacheKey,
  cloneMediaResources,
  createDefaultTrainingItemPreviewEntry,
  getTrainingItemPreviewEntry,
  initTrainingItemPreviewStore,
  setTrainingItemPreviewEntry,
  clearTrainingItemPreviewCache
} from '../../storage/training-item/TrainingItemPreviewStore'
import { appendCourseItemKey } from '../../storage/training-item/CourseTrainingItemIndexStore'

export {
  TrainingItemPreviewCacheEntry,
  cloneMediaResources
}

/**
 * 初始化训练项预览仓储依赖的 Store。
 */
export function initTrainingItemPreviewRepository(): void {
  initTrainingItemPreviewStore()
}

/**
 * 将训练项实体转换为训练项预览缓存条目。
 * @param courseCode 课程编码。
 * @param item 训练项实体。
 * @returns 训练项预览缓存条目。
 */
function createPreviewEntryFromItem(courseCode: string, item: TrainingContentItem): TrainingItemPreviewCacheEntry {
  return {
    courseCode,
    id: item.id,
    name: item.name,
    code: item.code,
    majorCategoryCode: item.majorCategoryCode,
    levelNum: item.levelNum,
    isRecommended: item.isRecommended,
    itemOrder: item.itemOrder,
    score: item.score,
    status: item.status,
    cover: cloneMediaResources(item.cover),
    videoPoster: cloneMediaResources(item.videoPoster)
  }
}

/**
 * 将训练项预览缓存条目转换为训练项实体。
 * @param entry 训练项预览缓存条目。
 * @returns 训练项实体。
 */
function createTrainingItemFromPreviewEntry(entry: TrainingItemPreviewCacheEntry): TrainingContentItem {
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
  item.cover = cloneMediaResources(entry.cover)
  item.videoPoster = cloneMediaResources(entry.videoPoster)
  return item
}

/**
 * 合并训练项预览缓存条目。
 * @param base 旧的缓存条目。
 * @param courseCode 课程编码。
 * @param incoming 新的训练项实体。
 * @returns 合并后的缓存条目。
 */
function mergePreviewEntry(base: TrainingItemPreviewCacheEntry | undefined, courseCode: string, incoming: TrainingContentItem): TrainingItemPreviewCacheEntry {
  const source = base ?? createDefaultTrainingItemPreviewEntry(courseCode, incoming.code)
  return {
    courseCode,
    id: incoming.id > 0 ? incoming.id : source.id,
    name: incoming.name.length > 0 ? incoming.name : source.name,
    code: incoming.code.length > 0 ? incoming.code : source.code,
    majorCategoryCode: incoming.majorCategoryCode.length > 0 ? incoming.majorCategoryCode : source.majorCategoryCode,
    levelNum: incoming.levelNum > 0 ? incoming.levelNum : source.levelNum,
    isRecommended: incoming.isRecommended ? incoming.isRecommended : source.isRecommended,
    itemOrder: incoming.itemOrder > 0 ? incoming.itemOrder : source.itemOrder,
    score: incoming.score > 0 || incoming.status === 'completed' ? incoming.score : source.score,
    status: incoming.status.length > 0 ? incoming.status : source.status,
    cover: incoming.cover.length > 0 ? cloneMediaResources(incoming.cover) : cloneMediaResources(source.cover),
    videoPoster: incoming.videoPoster.length > 0 ? cloneMediaResources(incoming.videoPoster) : cloneMediaResources(source.videoPoster)
  }
}

/**
 * 读取训练项预览缓存条目。
 * @param courseCode 课程编码。
 * @param itemCode 训练项编码。
 * @returns 训练项预览缓存条目。
 */
export function getTrainingItemPreview(courseCode: string, itemCode: string): TrainingItemPreviewCacheEntry | undefined {
  return getTrainingItemPreviewEntry(courseCode, itemCode)
}

/**
 * 读取训练项预览对应的训练项实体。
 * @param courseCode 课程编码。
 * @param itemCode 训练项编码。
 * @returns 训练项实体。
 */
export function getTrainingItemPreviewEntity(courseCode: string, itemCode: string): TrainingContentItem | undefined {
  const preview = getTrainingItemPreviewEntry(courseCode, itemCode)
  return preview ? createTrainingItemFromPreviewEntry(preview) : undefined
}

/**
 * 写入训练项预览缓存。
 * @param courseCode 课程编码。
 * @param item 训练项实体。
 */
export function setTrainingItemPreview(courseCode: string, item: TrainingContentItem): void {
  const entry = mergePreviewEntry(getTrainingItemPreviewEntry(courseCode, item.code), courseCode, item)
  setTrainingItemPreviewEntry(courseCode, item.code, entry)
  appendCourseItemKey(courseCode, buildTrainingItemCacheKey(courseCode, item.code))
}

/**
 * 清空训练项预览缓存。
 */
export function clearTrainingItemPreviewRecords(): void {
  clearTrainingItemPreviewCache()
}
