/**
 * TrainingItemDetailStore 文件，负责对应模块的本地状态存取。
 */

import { MediaResourceItem } from '../../domain/static/train/TrainingContentModels'
import {
  TrainingItemPreviewCacheEntry,
  buildTrainingItemCacheKey,
  cloneMediaResources,
  createDefaultTrainingItemPreviewEntry
} from './TrainingItemPreviewStore'

/**
 * 训练项详情缓存条目。
 * 在训练项预览字段基础上补充完整详情字段。
 */
export interface TrainingItemDetailCacheEntry extends TrainingItemPreviewCacheEntry {
  /** 含义说明。 */
  meaning: string
  /** 描述文本。 */
  description: string
  /** 训练目标。 */
  goal: string
  /** 注意事项列表。 */
  precautions: string[]
  /** 常见错误列表。 */
  commonErrors: string[]
  /** 视频资源列表。 */
  video: MediaResourceItem[]
  /** 音频资源列表。 */
  audio: MediaResourceItem[]
  /** 动作图片资源列表。 */
  actionImages: MediaResourceItem[]
}

/** 训练项详情缓存表，按课程编码与训练项编码联合索引。 */
const TRAINING_ITEM_DETAIL_CACHE: Map<string, TrainingItemDetailCacheEntry> = new Map()

/**
 * 初始化训练项详情缓存 Store。
 */
export function initTrainingItemDetailStore(): void {}

/**
 * 创建默认训练项详情缓存条目。
 * @param courseCode 课程编码。
 * @param itemCode 训练项编码。
 * @returns 默认训练项详情缓存条目。
 */
export function createDefaultTrainingItemDetailEntry(courseCode: string, itemCode: string): TrainingItemDetailCacheEntry {
  const preview = createDefaultTrainingItemPreviewEntry(courseCode, itemCode)
  return {
    courseCode: preview.courseCode,
    id: preview.id,
    name: preview.name,
    code: preview.code,
    majorCategoryCode: preview.majorCategoryCode,
    levelNum: preview.levelNum,
    isRecommended: preview.isRecommended,
    itemOrder: preview.itemOrder,
    score: preview.score,
    status: preview.status,
    cover: cloneMediaResources(preview.cover),
    videoPoster: cloneMediaResources(preview.videoPoster),
    meaning: '',
    description: '',
    goal: '',
    precautions: [],
    commonErrors: [],
    video: [],
    audio: [],
    actionImages: []
  }
}

/**
 * 深拷贝训练项详情缓存条目。
 * @param item 原始缓存条目。
 * @returns 拷贝后的缓存条目。
 */
function cloneDetailEntry(item: TrainingItemDetailCacheEntry): TrainingItemDetailCacheEntry {
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
    meaning: item.meaning,
    description: item.description,
    goal: item.goal,
    precautions: item.precautions.slice(),
    commonErrors: item.commonErrors.slice(),
    cover: cloneMediaResources(item.cover),
    video: cloneMediaResources(item.video),
    audio: cloneMediaResources(item.audio),
    actionImages: cloneMediaResources(item.actionImages),
    videoPoster: cloneMediaResources(item.videoPoster)
  }
}

/**
 * 读取训练项详情缓存条目。
 * @param courseCode 课程编码。
 * @param itemCode 训练项编码。
 * @returns 训练项详情缓存条目。
 */
export function getTrainingItemDetailEntry(courseCode: string, itemCode: string): TrainingItemDetailCacheEntry | undefined {
  const cached = TRAINING_ITEM_DETAIL_CACHE.get(buildTrainingItemCacheKey(courseCode, itemCode))
  return cached ? cloneDetailEntry(cached) : undefined
}

/**
 * 写入训练项详情缓存。
 * @param courseCode 课程编码。
 * @param itemCode 训练项编码。
 * @param entry 训练项详情缓存条目。
 */
export function setTrainingItemDetailEntry(courseCode: string, itemCode: string, entry: TrainingItemDetailCacheEntry): void {
  if (courseCode.length === 0 || itemCode.length === 0) return
  TRAINING_ITEM_DETAIL_CACHE.set(buildTrainingItemCacheKey(courseCode, itemCode), cloneDetailEntry(entry))
}

/**
 * 清空训练项详情缓存。
 */
export function clearTrainingItemDetailCache(): void {
  TRAINING_ITEM_DETAIL_CACHE.clear()
}
