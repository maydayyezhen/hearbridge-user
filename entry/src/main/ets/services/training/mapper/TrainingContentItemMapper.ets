/**
 * TrainingContentItemMapper 文件，负责训练内容 DTO 与训练内容展示模型的映射。
 */
import { MediaResourceItem, TrainingContentItem } from '../../../domain/static/train/TrainingContentModels'
import { TrainItemStatus, TrainingType } from '../../../domain/static/train/TrainingRuntimeTypes'
import {
  TrainingItemDetailResponseSource,
  TrainingItemResourceSource,
  TrainingSessionDetailItemSource
} from '../../../api/requests/TrainingApi'
import { normalizeTrainItemStatus, normalizeTrainingType } from '../../../utils/TrainingTypeUtil'

type MapperFieldValue = string | number | boolean | Object | null | undefined
type MapperArrayValue = Array<string | number | boolean | Object | null | undefined>

function collectNestedObjects(root: Object): Object[] {
  const queue: Object[] = [root]
  const collected: Object[] = [root]
  let queueIndex = 0
  while (queueIndex < queue.length && collected.length < 80) {
    const current = queue[queueIndex]
    queueIndex += 1
    const keys = Object.keys(current)
    for (let i = 0; i < keys.length; i += 1) {
      const value = Reflect.get(current, keys[i]) as MapperFieldValue | MapperArrayValue
      if (value !== null && value !== undefined && typeof value === 'object' && !Array.isArray(value)) {
        const nextObject = value as Object
        if (collected.indexOf(nextObject) < 0) {
          collected.push(nextObject)
          queue.push(nextObject)
        }
        continue
      }
      if (Array.isArray(value)) {
        const valueArray = value as MapperArrayValue
        for (let j = 0; j < valueArray.length; j += 1) {
          const currentItem = valueArray[j]
          if (currentItem !== null && currentItem !== undefined && typeof currentItem === 'object' && !Array.isArray(currentItem)) {
            const nextArrayObject = currentItem as Object
            if (collected.indexOf(nextArrayObject) < 0) {
              collected.push(nextArrayObject)
              queue.push(nextArrayObject)
            }
          }
        }
      }
    }
  }
  return collected
}

function readStringByKeysDeep(source: Object, keys: string[]): string {
  const candidates = collectNestedObjects(source)
  for (let i = 0; i < candidates.length; i += 1) {
    const value = readStringByKeys(candidates[i], keys)
    if (value.length > 0) {
      return value
    }
  }
  return ''
}

function readNumberByKeysDeep(source: Object, keys: string[], fallback: number): number {
  const candidates = collectNestedObjects(source)
  for (let i = 0; i < candidates.length; i += 1) {
    const value = readNumberByKeys(candidates[i], keys, Number.NaN)
    if (Number.isFinite(value)) {
      return value
    }
  }
  return fallback
}

function readStringArrayByKeysDeep(source: Object, keys: string[]): string[] {
  const candidates = collectNestedObjects(source)
  for (let i = 0; i < candidates.length; i += 1) {
    const value = readStringArrayByKeys(candidates[i], keys)
    if (value.length > 0) {
      return value
    }
  }
  return []
}

function readTextFromObject(source: Object): string {
  const textKeys = ['text', 'content', 'value', 'name', 'label', 'title']
  for (let i = 0; i < textKeys.length; i += 1) {
    const value = Reflect.get(source, textKeys[i]) as MapperFieldValue
    if (typeof value === 'string' && value.length > 0) {
      return value
    }
    if (typeof value === 'number') {
      return `${value}`
    }
  }
  return ''
}

function readObjectByKeys(source: Object, keys: string[]): Object | undefined {
  for (let i = 0; i < keys.length; i += 1) {
    const value = Reflect.get(source, keys[i]) as MapperFieldValue
    if (value !== null && value !== undefined && typeof value === 'object' && !Array.isArray(value)) {
      return value as Object
    }
  }
  return undefined
}

function readStringByKeys(source: Object, keys: string[]): string {
  for (let i = 0; i < keys.length; i += 1) {
    const value = Reflect.get(source, keys[i]) as MapperFieldValue
    if (typeof value === 'string' && value.length > 0) {
      return value
    }
    if (typeof value === 'number') {
      return `${value}`
    }
    if (value !== null && value !== undefined && typeof value === 'object' && !Array.isArray(value)) {
      const objectText = readTextFromObject(value as Object)
      if (objectText.length > 0) {
        return objectText
      }
    }
  }
  return ''
}

function readNumberByKeys(source: Object, keys: string[], fallback: number): number {
  for (let i = 0; i < keys.length; i += 1) {
    const value = Reflect.get(source, keys[i]) as MapperFieldValue
    if (typeof value === 'number' && Number.isFinite(value)) {
      return value
    }
    if (typeof value === 'string' && value.length > 0) {
      const parsed = Number(value)
      if (Number.isFinite(parsed)) {
        return parsed
      }
    }
  }
  return fallback
}

function readStringArrayByKeys(source: Object, keys: string[]): string[] {
  for (let i = 0; i < keys.length; i += 1) {
    const value = Reflect.get(source, keys[i]) as MapperFieldValue
    if (Array.isArray(value)) {
      const valueArray = value as MapperArrayValue
      const result: string[] = []
      for (let j = 0; j < valueArray.length; j += 1) {
        const current = valueArray[j]
        if (typeof current === 'string' && current.length > 0) {
          result.push(current)
          continue
        }
        if (current !== null && current !== undefined && typeof current === 'object' && !Array.isArray(current)) {
          const objectText = readTextFromObject(current as Object)
          if (objectText.length > 0) {
            result.push(objectText)
          }
        }
      }
      return result
    }
    if (typeof value === 'string' && value.length > 0) {
      return value.split(/[;,，；|]/).map((part: string) => part.trim()).filter((part: string) => part.length > 0)
    }
  }
  return []
}

function resolveItemDetailPayload(item: TrainingItemDetailResponseSource): Object {
  let payload = item as Object
  const nestedKeys = ['data', 'itemDetail', 'item', 'detail', 'trainingItem', 'result']
  for (let depth = 0; depth < 4; depth += 1) {
    const nextPayload = readObjectByKeys(payload, nestedKeys)
    if (!nextPayload) {
      break
    }
    payload = nextPayload
  }
  return payload
}

function readStringFromNestedOrRoot(nestedPayload: Object, rootPayload: Object, keys: string[]): string {
  const nestedValue = readStringByKeys(nestedPayload, keys)
  if (nestedValue.length > 0) {
    return nestedValue
  }
  const rootValue = readStringByKeys(rootPayload, keys)
  if (rootValue.length > 0) {
    return rootValue
  }
  const nestedDeepValue = readStringByKeysDeep(nestedPayload, keys)
  if (nestedDeepValue.length > 0) {
    return nestedDeepValue
  }
  return readStringByKeysDeep(rootPayload, keys)
}

function readNumberFromNestedOrRoot(nestedPayload: Object, rootPayload: Object, keys: string[], fallback: number): number {
  const nestedValue = readNumberByKeys(nestedPayload, keys, Number.NaN)
  if (Number.isFinite(nestedValue)) {
    return nestedValue
  }
  const rootValue = readNumberByKeys(rootPayload, keys, Number.NaN)
  if (Number.isFinite(rootValue)) {
    return rootValue
  }
  const nestedDeepValue = readNumberByKeysDeep(nestedPayload, keys, Number.NaN)
  if (Number.isFinite(nestedDeepValue)) {
    return nestedDeepValue
  }
  return readNumberByKeysDeep(rootPayload, keys, fallback)
}

function readStringArrayFromNestedOrRoot(nestedPayload: Object, rootPayload: Object, keys: string[]): string[] {
  const nestedValue = readStringArrayByKeys(nestedPayload, keys)
  if (nestedValue.length > 0) {
    return nestedValue
  }
  const rootValue = readStringArrayByKeys(rootPayload, keys)
  if (rootValue.length > 0) {
    return rootValue
  }
  const nestedDeepValue = readStringArrayByKeysDeep(nestedPayload, keys)
  if (nestedDeepValue.length > 0) {
    return nestedDeepValue
  }
  return readStringArrayByKeysDeep(rootPayload, keys)
}

function normalizeTypedResourceKey(key: string): string {
  const normalized = key.toLowerCase().replace(/[-\s]/g, '_')
  if (normalized.indexOf('poster') >= 0) {
    return 'video_poster'
  }
  if (normalized.indexOf('cover') >= 0) {
    return 'cover'
  }
  if (normalized.indexOf('audio') >= 0 || normalized.indexOf('voice') >= 0) {
    return 'audio'
  }
  if (normalized.indexOf('video') >= 0) {
    return 'video'
  }
  if (normalized.indexOf('action') >= 0 || normalized.indexOf('image') >= 0 || normalized.indexOf('img') >= 0) {
    return 'action_image'
  }
  return normalized
}

function appendResourceItem(result: TrainingItemResourceSource[], fallbackType: string, item: MapperFieldValue): void {
  if (typeof item === 'string') {
    if (item.length <= 0) {
      return
    }
    result.push({
      resourceType: fallbackType,
      fileName: '',
      fileUrl: item,
      sortNum: result.length
    })
    return
  }
  if (!item || typeof item !== 'object' || Array.isArray(item)) {
    return
  }
  const objectItem = item as Object
  const resourceType = readStringByKeys(objectItem,
    ['resourceType', 'type', 'resource_type', 'mediaType', 'media_type', 'kind'])
  result.push({
    resourceType: resourceType.length > 0 ? resourceType : fallbackType,
    fileName: readStringByKeys(objectItem, ['fileName', 'name', 'file_name', 'title']),
    fileUrl: readStringByKeys(objectItem, ['fileUrl', 'url', 'file_url', 'mediaUrl', 'media_url', 'resourceUrl', 'resource_url', 'ossUrl']),
    sortNum: readNumberByKeys(objectItem, ['sortNum', 'sort_num', 'orderNum', 'order_num', 'order'], result.length)
  })
}

function appendTypedResourceLists(result: TrainingItemResourceSource[], source: Object): void {
  const keys = Object.keys(source)
  for (let i = 0; i < keys.length; i += 1) {
    const value = Reflect.get(source, keys[i]) as MapperFieldValue
    if (Array.isArray(value)) {
      const fallbackType = normalizeTypedResourceKey(keys[i])
      const list = value as MapperArrayValue
      for (let j = 0; j < list.length; j += 1) {
        appendResourceItem(result, fallbackType, list[j] as MapperFieldValue)
      }
      continue
    }
    appendResourceItem(result, normalizeTypedResourceKey(keys[i]), value)
  }
}

function readResourcesByKeys(itemPayload: Object): TrainingItemResourceSource[] {
  const resourcesValue = Reflect.get(itemPayload, 'resources') as MapperFieldValue
  const resourceListValue = Reflect.get(itemPayload, 'resourceList') as MapperFieldValue
  const mediaResourcesValue = Reflect.get(itemPayload, 'mediaResources') as MapperFieldValue
  const filesValue = Reflect.get(itemPayload, 'files') as MapperFieldValue
  const attachmentsValue = Reflect.get(itemPayload, 'attachments') as MapperFieldValue
  const resourceItemsValue = Reflect.get(itemPayload, 'resourceItems') as MapperFieldValue
  const rawList = Array.isArray(resourcesValue)
    ? (resourcesValue as MapperArrayValue)
    : (Array.isArray(resourceListValue)
      ? (resourceListValue as MapperArrayValue)
      : (Array.isArray(mediaResourcesValue)
        ? (mediaResourcesValue as MapperArrayValue)
        : (Array.isArray(filesValue)
          ? (filesValue as MapperArrayValue)
          : (Array.isArray(attachmentsValue)
            ? (attachmentsValue as MapperArrayValue)
            : (Array.isArray(resourceItemsValue) ? (resourceItemsValue as MapperArrayValue) : [])))))

  const result: TrainingItemResourceSource[] = []
  for (let i = 0; i < rawList.length; i += 1) {
    appendResourceItem(result, '', rawList[i] as MapperFieldValue)
  }

  if (result.length <= 0) {
    if (resourcesValue && typeof resourcesValue === 'object' && !Array.isArray(resourcesValue)) {
      appendTypedResourceLists(result, resourcesValue as Object)
    }
    if (result.length <= 0 && resourceListValue && typeof resourceListValue === 'object' && !Array.isArray(resourceListValue)) {
      appendTypedResourceLists(result, resourceListValue as Object)
    }
    if (result.length <= 0 && mediaResourcesValue && typeof mediaResourcesValue === 'object' && !Array.isArray(mediaResourcesValue)) {
      appendTypedResourceLists(result, mediaResourcesValue as Object)
    }
  }
  return result
}

function readResourcesByKeysDeep(itemPayload: Object): TrainingItemResourceSource[] {
  const candidates = collectNestedObjects(itemPayload)
  for (let i = 0; i < candidates.length; i += 1) {
    const value = readResourcesByKeys(candidates[i])
    if (value.length > 0) {
      return value
    }
  }
  return []
}

function normalizeResourceType(resourceType: string, fileUrl: string, fileName: string): string {
  const normalized = resourceType.toLowerCase().replace(/[-\s]/g, '_')
  if (normalized === 'videoposter' || normalized === 'video_poster' || normalized === 'poster' || normalized === 'thumbnail') {
    return 'video_poster'
  }
  if (normalized === 'actionimage' || normalized === 'action_image' || normalized === 'image' || normalized === 'images') {
    return 'action_image'
  }
  if (normalized === 'voice') {
    return 'audio'
  }
  if (normalized === 'cover_image') {
    return 'cover'
  }
  if (normalized === 'demo_video' || normalized === 'sample_video') {
    return 'video'
  }
  if (normalized === 'demo_audio' || normalized === 'sample_audio') {
    return 'audio'
  }
  if (normalized.length > 0) {
    return normalized
  }
  const extensionSource = `${fileUrl} ${fileName}`.toLowerCase()
  if (extensionSource.indexOf('poster') >= 0 || extensionSource.indexOf('thumbnail') >= 0) {
    return 'video_poster'
  }
  if (extensionSource.indexOf('cover') >= 0) {
    return 'cover'
  }
  if (/\.(mp4|mov|m3u8|webm)(\?|$)/.test(extensionSource)) {
    return 'video'
  }
  if (/\.(mp3|wav|aac|m4a|ogg|flac)(\?|$)/.test(extensionSource)) {
    return 'audio'
  }
  if (/\.(jpg|jpeg|png|webp|bmp|gif)(\?|$)/.test(extensionSource)) {
    return 'action_image'
  }
  return normalized
}

/** mapResources。 */
function getSafeResourceSortNum(resource: TrainingItemResourceSource, fallback: number): number {
  const parsedValue = Number(resource.sortNum ?? Number.NaN)
  if (Number.isFinite(parsedValue)) {
    return parsedValue
  }
  return fallback
}

function getSortedResources(resources: TrainingItemResourceSource[]): TrainingItemResourceSource[] {
  const sortedResources = resources.slice()
  sortedResources.sort((left: TrainingItemResourceSource, right: TrainingItemResourceSource) => {
    return getSafeResourceSortNum(left, 0) - getSafeResourceSortNum(right, 0)
  })
  return sortedResources
}

function mapResources(resources: TrainingItemResourceSource[], resourceType: string): MediaResourceItem[] {
  const result: MediaResourceItem[] = []
  const sortedResources = getSortedResources(resources)
  for (let i = 0; i < sortedResources.length; i += 1) {
    const normalizedType = normalizeResourceType(
      String(sortedResources[i].resourceType ?? ''),
      String(sortedResources[i].fileUrl ?? ''),
      String(sortedResources[i].fileName ?? '')
    )
    if (normalizedType === resourceType) {
      result.push(new MediaResourceItem(
        `${resourceType}_${i + 1}`,
        String(sortedResources[i].fileName ?? ''),
        String(sortedResources[i].fileUrl ?? ''),
        'done'
      ))
    }
  }
  return result
}

/** mapActionImages。 */
function mapActionImages(resources: TrainingItemResourceSource[]): MediaResourceItem[] {
  const result: MediaResourceItem[] = []
  let index = 0
  const sortedResources = getSortedResources(resources)
  for (let i = 0; i < sortedResources.length; i += 1) {
    const normalizedType = normalizeResourceType(
      String(sortedResources[i].resourceType ?? ''),
      String(sortedResources[i].fileUrl ?? ''),
      String(sortedResources[i].fileName ?? '')
    )
    if (normalizedType === 'action_image') {
      result.push(new MediaResourceItem(
        `action_${index + 1}`,
        String(sortedResources[i].fileName ?? ''),
        String(sortedResources[i].fileUrl ?? ''),
        'done'
      ))
      index += 1
    }
  }
  return result
}

/** normalizeItemStatus。 */
function normalizeItemStatus(value: string): TrainItemStatus {
  return normalizeTrainItemStatus(String(value ?? ''))
}

/** normalizeItemTrainingType。 */
function normalizeItemTrainingType(value: string): TrainingType {
  return normalizeTrainingType(String(value ?? 'gesture'))
}

/** mapSessionItemToTrainingContentItem。 */
export function mapSessionItemToTrainingContentItem(item: TrainingSessionDetailItemSource, trainingType: TrainingType, index: number): TrainingContentItem {
  // 兼容多种后端字段别名，避免 current item code 为空导致详情请求被跳过。
  const payload = item as Object
  const normalizedType = normalizeItemTrainingType(trainingType)
  const mapped = new TrainingContentItem(0, '', '', '', 1, false, 0, 0, '', '', '', '', [], [], [], [], [], [], [])
  mapped.id = Math.max(1, Math.floor(readNumberByKeysDeep(payload, ['id', 'itemId', 'trainingItemId'], index + 1)))
  mapped.name = readStringByKeysDeep(payload, ['itemName', 'trainingItemName', 'name', 'title'])
  mapped.code = readStringByKeysDeep(payload, ['itemCode', 'trainingItemCode', 'code', 'itemId', 'id'])
  mapped.majorCategoryCode = normalizedType
  mapped.levelNum = Math.max(1, Math.floor(readNumberByKeysDeep(payload, ['levelNum', 'level', 'difficultyLevel', 'itemLevel'], 1)))
  mapped.isRecommended = false
  mapped.itemOrder = Math.max(1, Math.floor(readNumberByKeysDeep(payload, ['itemOrder', 'sortNum', 'orderNum', 'order'], index + 1)))
  mapped.score = 0
  mapped.status = normalizeItemStatus(readStringByKeysDeep(payload, ['status', 'itemStatus', 'currentStatus']))
  return mapped
}

/** mapTrainingItemDetailToTrainingContentItem。 */
export function mapTrainingItemDetailToTrainingContentItem(item: TrainingItemDetailResponseSource, trainingType: TrainingType, index: number): TrainingContentItem {
  // 兼容 wrapped payload / alias 字段，避免首进仅封面显示而说明信息为空。
  const rootPayload = item as Object
  const nestedPayload = resolveItemDetailPayload(item)
  const normalizedType = normalizeItemTrainingType(trainingType)
  const resources = readResourcesByKeys(nestedPayload)
  const resolvedResources = resources.length > 0
    ? resources
    : (readResourcesByKeys(rootPayload).length > 0 ? readResourcesByKeys(rootPayload) : readResourcesByKeysDeep(rootPayload))
  const mapped = new TrainingContentItem(0, '', '', '', 1, false, 0, 0, '', '', '', '', [], [], [], [], [], [], [])
  mapped.id = index + 1
  mapped.name = readStringFromNestedOrRoot(nestedPayload, rootPayload, ['itemName', 'trainingItemName', 'name', 'title'])
  mapped.code = readStringFromNestedOrRoot(nestedPayload, rootPayload, ['itemCode', 'trainingItemCode', 'code', 'itemId', 'id'])
  mapped.majorCategoryCode = normalizedType
  mapped.levelNum = Math.max(1,
    Math.floor(readNumberFromNestedOrRoot(nestedPayload, rootPayload, ['levelNum', 'level', 'difficultyLevel', 'itemLevel'], 1)))
  mapped.isRecommended = false
  mapped.itemOrder = Math.max(1,
    Math.floor(readNumberFromNestedOrRoot(nestedPayload, rootPayload, ['itemOrder', 'sortNum', 'orderNum', 'order'], index + 1)))
  mapped.score = readNumberFromNestedOrRoot(nestedPayload, rootPayload, ['score', 'itemScore'], 0)
  mapped.status = normalizeItemStatus(readStringFromNestedOrRoot(nestedPayload, rootPayload, ['status', 'itemStatus', 'currentStatus']))
  mapped.meaning = readStringFromNestedOrRoot(nestedPayload, rootPayload,
    ['meaning', 'itemMeaning', 'subtitle', 'intro', 'summary'])
  mapped.description = readStringFromNestedOrRoot(nestedPayload, rootPayload,
    ['description', 'trainingDescription', 'desc', 'instruction', 'content'])
  mapped.goal = readStringFromNestedOrRoot(nestedPayload, rootPayload,
    ['goal', 'trainingGoal', 'target', 'objective'])
  mapped.precautions = readStringArrayFromNestedOrRoot(nestedPayload, rootPayload,
    ['precautions', 'focusSegments', 'focusPoints', 'attentionPoints', 'attentionTags', 'tags'])
  mapped.commonErrors = readStringArrayFromNestedOrRoot(nestedPayload, rootPayload,
    ['commonErrors', 'commonMistakes', 'mistakes'])
  mapped.cover = mapResources(resolvedResources, 'cover')
  mapped.video = mapResources(resolvedResources, 'video')
  mapped.audio = mapResources(resolvedResources, 'audio')
  mapped.actionImages = mapActionImages(resolvedResources)
  mapped.videoPoster = mapResources(resolvedResources, 'video_poster')
  return mapped
}
