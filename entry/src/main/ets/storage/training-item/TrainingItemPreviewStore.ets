/**
 * TrainingItemPreviewStore 文件，负责对应模块的本地状态存取。
 */

import { MediaResourceItem } from '../../domain/static/train/TrainingContentModels'
import { TrainItemStatus } from '../../domain/static/train/TrainingRuntimeTypes'

/**
 * 训练项预览缓存条目。
 * 仅保留列表和轻量展示需要的字段。
 */
export interface TrainingItemPreviewCacheEntry {
  /** 所属课程编码。 */
  courseCode: string
  /** 训练项主键。 */
  id: number
  /** 训练项名称。 */
  name: string
  /** 训练项编码。 */
  code: string
  /** 训练所属类型编码。 */
  majorCategoryCode: string
  /** 训练项难度。 */
  levelNum: number
  /** 是否推荐。 */
  isRecommended: boolean
  /** 训练项在课程内的顺序。 */
  itemOrder: number
  /** 最近一次评分。 */
  score: number
  /** 当前状态。 */
  status: TrainItemStatus
  /** 封面资源列表。 */
  cover: MediaResourceItem[]
  /** 视频封面资源列表。 */
  videoPoster: MediaResourceItem[]
}

/** 训练项预览缓存表，按课程编码与训练项编码联合索引。 */
const TRAINING_ITEM_PREVIEW_CACHE: Map<string, TrainingItemPreviewCacheEntry> = new Map()

/**
 * 初始化训练项预览缓存 Store。
 */
export function initTrainingItemPreviewStore(): void {}

/**
 * 构建训练项缓存键。
 * @param courseCode 课程编码。
 * @param itemCode 训练项编码。
 * @returns 训练项缓存键。
 */
export function buildTrainingItemCacheKey(courseCode: string, itemCode: string): string {
  return `${courseCode}:${itemCode}`
}

/**
 * 深拷贝媒体资源列表。
 * @param resources 原始媒体资源列表。
 * @returns 拷贝后的媒体资源列表。
 */
export function cloneMediaResources(resources: MediaResourceItem[]): MediaResourceItem[] {
  const result: MediaResourceItem[] = []
  for (let i = 0; i < resources.length; i += 1) {
    result.push(new MediaResourceItem(
      resources[i].uid,
      resources[i].name,
      resources[i].url,
      resources[i].status,
      resources[i].title,
      resources[i].description
    ))
  }
  return result
}

/**
 * 创建默认训练项预览缓存条目。
 * @param courseCode 课程编码。
 * @param itemCode 训练项编码。
 * @returns 默认训练项预览缓存条目。
 */
export function createDefaultTrainingItemPreviewEntry(courseCode: string, itemCode: string): TrainingItemPreviewCacheEntry {
  return {
    courseCode,
    id: 0,
    name: itemCode,
    code: itemCode,
    majorCategoryCode: '',
    levelNum: 1,
    isRecommended: false,
    itemOrder: 0,
    score: 0,
    status: '',
    cover: [],
    videoPoster: []
  }
}

/**
 * 深拷贝训练项预览缓存条目。
 * @param item 原始缓存条目。
 * @returns 拷贝后的缓存条目。
 */
function clonePreviewEntry(item: TrainingItemPreviewCacheEntry): TrainingItemPreviewCacheEntry {
  return {
    courseCode: item.courseCode,
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
 * 读取训练项预览缓存条目。
 * @param courseCode 课程编码。
 * @param itemCode 训练项编码。
 * @returns 训练项预览缓存条目。
 */
export function getTrainingItemPreviewEntry(courseCode: string, itemCode: string): TrainingItemPreviewCacheEntry | undefined {
  const cached = TRAINING_ITEM_PREVIEW_CACHE.get(buildTrainingItemCacheKey(courseCode, itemCode))
  return cached ? clonePreviewEntry(cached) : undefined
}

/**
 * 写入训练项预览缓存。
 * @param courseCode 课程编码。
 * @param itemCode 训练项编码。
 * @param entry 训练项预览缓存条目。
 */
export function setTrainingItemPreviewEntry(courseCode: string, itemCode: string, entry: TrainingItemPreviewCacheEntry): void {
  if (courseCode.length === 0 || itemCode.length === 0) return
  TRAINING_ITEM_PREVIEW_CACHE.set(buildTrainingItemCacheKey(courseCode, itemCode), clonePreviewEntry(entry))
}

/**
 * 清空训练项预览缓存。
 */
export function clearTrainingItemPreviewCache(): void {
  TRAINING_ITEM_PREVIEW_CACHE.clear()
}
