/**
 * 训练项详情本地服务，负责训练项详情的字段合并与写回。
 */
import { MediaResourceItem, TrainingContentItem } from '../../../domain/static/train/TrainingContentModels'
import { TrainItemStatus } from '../../../domain/static/train/TrainingRuntimeTypes'
import { appendCourseTrainingItem } from '../../../repository/training-item/CourseTrainingItemIndexRepository'
import {
  createDefaultTrainingItemDetail,
  getTrainingItemDetail,
  TrainingItemDetailCacheEntry,
  writeTrainingItemDetail
} from '../../../repository/training-item/TrainingItemDetailRepository'
import { cloneMediaResources, getTrainingItemPreview, TrainingItemPreviewCacheEntry } from '../../../repository/training-item/TrainingItemPreviewRepository'

function createTrainingContentItem(
  id: number,
  name: string,
  code: string,
  majorCategoryCode: string,
  levelNum: number,
  isRecommended: boolean,
  itemOrder: number,
  score: number,
  status: TrainItemStatus,
  meaning: string,
  description: string,
  goal: string,
  precautions: string[],
  commonErrors: string[],
  cover: MediaResourceItem[],
  video: MediaResourceItem[],
  audio: MediaResourceItem[],
  actionImages: MediaResourceItem[],
  videoPoster: MediaResourceItem[]
): TrainingContentItem {
  return new TrainingContentItem(
    id,
    name,
    code,
    majorCategoryCode,
    levelNum,
    isRecommended,
    itemOrder,
    score,
    status,
    meaning,
    description,
    goal,
    precautions,
    commonErrors,
    cover,
    video,
    audio,
    actionImages,
    videoPoster
  )
}

function createTrainingItemFromSource(base: TrainingItemDetailCacheEntry | TrainingItemPreviewCacheEntry | undefined, incoming: TrainingContentItem): TrainingContentItem {
  if (base) {
    const detailBase = base as TrainingItemDetailCacheEntry
    if (detailBase.meaning !== undefined) {
      return createTrainingContentItem(
        detailBase.id,
        detailBase.name,
        detailBase.code,
        detailBase.majorCategoryCode,
        detailBase.levelNum,
        detailBase.isRecommended,
        detailBase.itemOrder,
        detailBase.score,
        detailBase.status,
        detailBase.meaning,
        detailBase.description,
        detailBase.goal,
        detailBase.precautions.slice(),
        detailBase.commonErrors.slice(),
        cloneMediaResources(detailBase.cover),
        cloneMediaResources(detailBase.video),
        cloneMediaResources(detailBase.audio),
        cloneMediaResources(detailBase.actionImages),
        cloneMediaResources(detailBase.videoPoster)
      )
    }
    return createTrainingContentItem(
      base.id,
      base.name,
      base.code,
      base.majorCategoryCode,
      base.levelNum,
      base.isRecommended,
      base.itemOrder,
      base.score,
      base.status,
      '',
      '',
      '',
      [],
      [],
      cloneMediaResources(base.cover),
      [],
      [],
      [],
      cloneMediaResources(base.videoPoster)
    )
  }
  return createTrainingContentItem(
    incoming.id,
    incoming.name,
    incoming.code,
    incoming.majorCategoryCode,
    incoming.levelNum,
    incoming.isRecommended,
    incoming.itemOrder,
    incoming.score,
    incoming.status,
    incoming.meaning,
    incoming.description,
    incoming.goal,
    incoming.precautions.slice(),
    incoming.commonErrors.slice(),
    cloneMediaResources(incoming.cover),
    cloneMediaResources(incoming.video),
    cloneMediaResources(incoming.audio),
    cloneMediaResources(incoming.actionImages),
    cloneMediaResources(incoming.videoPoster)
  )
}

function mergeTrainingItemDetailEntry(base: TrainingItemDetailCacheEntry | TrainingItemPreviewCacheEntry | undefined, courseCode: string, incoming: TrainingContentItem): TrainingItemDetailCacheEntry {
  const source = createTrainingItemFromSource(base, incoming)
  const fallback = createDefaultTrainingItemDetail(courseCode, incoming.code)
  return {
    courseCode,
    id: incoming.id > 0 ? incoming.id : (source.id > 0 ? source.id : fallback.id),
    name: incoming.name.length > 0 ? incoming.name : (source.name.length > 0 ? source.name : fallback.name),
    code: incoming.code.length > 0 ? incoming.code : (source.code.length > 0 ? source.code : fallback.code),
    majorCategoryCode: incoming.majorCategoryCode.length > 0 ? incoming.majorCategoryCode : source.majorCategoryCode,
    levelNum: incoming.levelNum > 0 ? incoming.levelNum : source.levelNum,
    isRecommended: incoming.isRecommended ? incoming.isRecommended : source.isRecommended,
    itemOrder: incoming.itemOrder > 0 ? incoming.itemOrder : source.itemOrder,
    score: incoming.score > 0 || incoming.status === 'completed' ? incoming.score : source.score,
    status: incoming.status.length > 0 ? incoming.status : source.status,
    meaning: incoming.meaning.length > 0 ? incoming.meaning : source.meaning,
    description: incoming.description.length > 0 ? incoming.description : source.description,
    goal: incoming.goal.length > 0 ? incoming.goal : source.goal,
    precautions: incoming.precautions.length > 0 ? [...incoming.precautions] : [...source.precautions],
    commonErrors: incoming.commonErrors.length > 0 ? [...incoming.commonErrors] : [...source.commonErrors],
    cover: incoming.cover.length > 0 ? cloneMediaResources(incoming.cover) : cloneMediaResources(source.cover),
    video: incoming.video.length > 0 ? cloneMediaResources(incoming.video) : cloneMediaResources(source.video),
    audio: incoming.audio.length > 0 ? cloneMediaResources(incoming.audio) : cloneMediaResources(source.audio),
    actionImages: incoming.actionImages.length > 0 ? cloneMediaResources(incoming.actionImages) : cloneMediaResources(source.actionImages),
    videoPoster: incoming.videoPoster.length > 0 ? cloneMediaResources(incoming.videoPoster) : cloneMediaResources(source.videoPoster)
  }
}

/**
 * 合并并写入训练项详情缓存。
 */
export function upsertTrainingItemDetail(courseCode: string, itemCode: string, item: TrainingContentItem): void {
  const merged = mergeTrainingItemDetailEntry(
    getTrainingItemDetail(courseCode, itemCode) ?? getTrainingItemPreview(courseCode, itemCode),
    courseCode,
    item
  )
  writeTrainingItemDetail(courseCode, itemCode, merged)
  appendCourseTrainingItem(courseCode, itemCode)
}
