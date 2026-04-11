/**
 * 训练会话启动注水本地服务，负责把详情源映射到运行时与训练项详情。
 */
import common from '@ohos.app.ability.common'
import { hilog } from '@kit.PerformanceAnalysisKit'
import { fetchTrainItemDetail, TrainingSessionDetailResponseSource } from '../api/TrainSessionApiService'
import { TrainingContentItem } from '../../../domain/static/train/TrainingContentModels'
import { ApiResult } from '../../../api/common/Http'
import { TrainingItemDetailResponseSource } from '../../../api/requests/TrainingApi'
import { mapSessionItemToTrainingContentItem, mapTrainingItemDetailToTrainingContentItem } from '../mapper/TrainingContentItemMapper'
import { upsertCourseTrainingItemPreviews } from '../../../repository/training-item/CourseTrainingItemIndexRepository'
import { getTrainingItemDetailEntity } from '../../../repository/training-item/TrainingItemDetailRepository'
import { upsertTrainingItemDetail } from '../../training-item/local/TrainingItemDetailLocalService'
import {
  patchActiveTrainSession,
  TrainSessionRuntime
} from '../../../repository/train-session/TrainSessionRepository'
import { normalizeTrainItemStatus, normalizeTrainingType } from '../../../utils/TrainingTypeUtil'
import { getPendingMessage, getRetryLaterMessage } from '../../../utils/FeedbackCopy'
import { patchTrainSessionViewState } from '../../../repository/train-session/TrainSessionViewStateRepository'
import { cacheTrainingSessionDetail, syncCourseSessionCacheFromRuntime } from '../cache/TrainSessionCacheService'
import {
  resolveSelectedIndex,
  TrainSessionBootstrapContext
} from './TrainSessionBootstrapContextLocalService'
import { StartedTrainSession } from './TrainSessionBootstrapSourceLocalService'

function traceTrainFlow(stage: string, message: string): void {
  hilog.info(0x0, 'TrainFlowTrace', `${stage}|${message}`)
}

type HydrationFieldValue = string | number | boolean | Object | HydrationFieldValue[] | null | undefined

function readObjectByKeys(source: Object, keys: string[]): Object | undefined {
  for (let i = 0; i < keys.length; i += 1) {
    const value = Reflect.get(source, keys[i]) as HydrationFieldValue
    if (value !== null && value !== undefined && typeof value === 'object' && !Array.isArray(value)) {
      return value as Object
    }
  }
  return undefined
}

function resolveNestedDetailPayload(payload: Object): Object {
  let resolved = payload
  const nestedKeys = ['data', 'itemDetail', 'item', 'detail', 'trainingItem', 'result']
  for (let depth = 0; depth < 4; depth += 1) {
    const nextPayload = readObjectByKeys(resolved, nestedKeys)
    if (!nextPayload) {
      break
    }
    resolved = nextPayload
  }
  return resolved
}

function parseDetailPayloadFromRawBody(rawBody: string): TrainingItemDetailResponseSource | null {
  if (rawBody.length <= 0) {
    return null
  }
  try {
    const parsed = JSON.parse(rawBody) as HydrationFieldValue
    if (!parsed || typeof parsed !== 'object' || Array.isArray(parsed)) {
      return null
    }
    return resolveNestedDetailPayload(parsed as Object) as TrainingItemDetailResponseSource
  } catch (_error) {
    return null
  }
}

function resolveDetailPayload(detailResult: ApiResult<TrainingItemDetailResponseSource>): TrainingItemDetailResponseSource | null {
  if (detailResult.data && typeof detailResult.data === 'object') {
    return resolveNestedDetailPayload(detailResult.data as Object) as TrainingItemDetailResponseSource
  }
  if (detailResult.httpCode === 200) {
    return parseDetailPayloadFromRawBody(detailResult.rawBody)
  }
  return null
}

function hasHydratedItemDetail(item: TrainingContentItem | undefined): boolean {
  if (!item) return false
  if (item.description.length > 0 || item.goal.length > 0 || item.meaning.length > 0) {
    return true
  }
  if (item.video.length > 0 || item.audio.length > 0 || item.actionImages.length > 0) {
    return true
  }
  if (item.precautions.length > 0 || item.commonErrors.length > 0) {
    return true
  }
  return false
}

function mergeHydratedDetailWithRuntimeItem(currentItem: TrainingContentItem, hydratedItem: TrainingContentItem): TrainingContentItem {
  const mergedItem = hydratedItem
  const normalizedCurrentStatus = normalizeTrainItemStatus(currentItem.status)
  const normalizedHydratedStatus = normalizeTrainItemStatus(hydratedItem.status)
  if (normalizedCurrentStatus === 'completed') {
    mergedItem.status = 'completed'
  } else if (normalizedCurrentStatus === 'in_progress' || normalizedCurrentStatus === 'current') {
    mergedItem.status = normalizedHydratedStatus === 'completed' ? 'completed' : 'in_progress'
  } else if (normalizedHydratedStatus.length <= 0) {
    mergedItem.status = normalizedCurrentStatus
  }

  if (currentItem.score > 0 && mergedItem.score <= 0) {
    mergedItem.score = currentItem.score
  }
  if (currentItem.id > 0 && mergedItem.id <= 0) {
    mergedItem.id = currentItem.id
  }
  if (currentItem.code.length > 0 && mergedItem.code.length <= 0) {
    mergedItem.code = currentItem.code
  }
  if (currentItem.name.length > 0 && mergedItem.name.length <= 0) {
    mergedItem.name = currentItem.name
  }
  return mergedItem
}

/**
 * 根据会话详情映射训练项并统一回写运行时与课程快照缓存。
 */
export function applyBootstrappedSessionDetail(
  context: TrainSessionBootstrapContext,
  startedSession: StartedTrainSession,
  detailSource: TrainingSessionDetailResponseSource
): TrainSessionRuntime {
  const detailItems = detailSource.items ?? []
  const normalizedTrainingType = normalizeTrainingType(String(detailSource.trainingType ?? context.routeTrainingType))
  const normalizedItemStatus = normalizeTrainItemStatus(startedSession.currentItemStatus)
  const mappedItems: TrainingContentItem[] = []
  for (let i = 0; i < detailItems.length; i += 1) {
    mappedItems.push(mapSessionItemToTrainingContentItem(detailItems[i], normalizedTrainingType, i))
  }
  const selectedIndex = resolveSelectedIndex(mappedItems, context.preferredItemCode)

  upsertCourseTrainingItemPreviews(context.routeCourseCode, mappedItems)
  cacheTrainingSessionDetail(context.routeCourseCode, detailSource, startedSession.sessionId, normalizedItemStatus)

  const runtime = patchActiveTrainSession({
    sessionId: startedSession.sessionId,
    trainingType: normalizedTrainingType,
    items: mappedItems,
    currentItemIndex: selectedIndex,
    currentItemStatus: normalizedItemStatus,
    sessionProgressPercent: Number(detailSource.progressPercent ?? 0),
    completedItemCount: Number(detailSource.completedItemCount ?? 0),
    totalItemCount: Number(detailSource.totalItemCount ?? 0) > 0 ? Number(detailSource.totalItemCount ?? 0) : mappedItems.length,
    isSessionLoading: false,
    isCurrentItemDetailLoading: true
  })
  patchTrainSessionViewState({ trainingTip: '' })
  syncCourseSessionCacheFromRuntime(runtime, mappedItems, Number(detailSource.progressPercent ?? 0), normalizedItemStatus)
  return runtime
}

/**
 * 加载指定训练项详情，并回写当前训练运行时。
 */
export async function loadItemDetail(abilityContext: common.BaseContext, runtime: TrainSessionRuntime, itemCode: string): Promise<TrainSessionRuntime> {
  patchActiveTrainSession({ isCurrentItemDetailLoading: true })
  const cached = getTrainingItemDetailEntity(runtime.courseCode, itemCode)
  if (hasHydratedItemDetail(cached)) {
    traceTrainFlow('loadItemDetail.cacheHit',
      'courseCode=' + runtime.courseCode
      + ',sessionId=' + String(runtime.sessionId)
      + ',itemCode=' + itemCode)
    const hydratedCached = mergeHydratedDetailWithRuntimeItem(runtime.items[runtime.currentItemIndex], cached as TrainingContentItem)
    const items = runtime.items.slice()
    items[runtime.currentItemIndex] = hydratedCached
    patchTrainSessionViewState({ trainingTip: '' })
    return patchActiveTrainSession({ items, isCurrentItemDetailLoading: false })
  }
  traceTrainFlow('loadItemDetail.remoteRequest',
    'courseCode=' + runtime.courseCode
    + ',sessionId=' + String(runtime.sessionId)
    + ',itemCode=' + itemCode)
  patchTrainSessionViewState({ trainingTip: getPendingMessage('加载训练项内容') })
  const detailResult = await fetchTrainItemDetail(runtime.sessionId, itemCode)
  const detailPayload = resolveDetailPayload(detailResult)
  if (!detailPayload) {
    traceTrainFlow('loadItemDetail.remoteFailed',
      'courseCode=' + runtime.courseCode
      + ',sessionId=' + String(runtime.sessionId)
      + ',itemCode=' + itemCode
      + ',ok=' + String(detailResult.ok)
      + ',httpCode=' + String(detailResult.httpCode)
      + ',message=' + detailResult.message)
    const failureMessage = detailResult.message.length > 0
      ? detailResult.message
      : getRetryLaterMessage('加载训练项详情')
    patchTrainSessionViewState({ trainingTip: failureMessage })
    return patchActiveTrainSession({ isCurrentItemDetailLoading: false })
  }
  const detailItem = mergeHydratedDetailWithRuntimeItem(
    runtime.items[runtime.currentItemIndex],
    mapTrainingItemDetailToTrainingContentItem(detailPayload, runtime.trainingType, runtime.currentItemIndex)
  )
  traceTrainFlow('loadItemDetail.remoteApplied',
    'courseCode=' + runtime.courseCode
    + ',sessionId=' + String(runtime.sessionId)
    + ',itemCode=' + itemCode
    + ',resolvedCode=' + detailItem.code
    + ',meaningLen=' + String(detailItem.meaning.length)
    + ',descriptionLen=' + String(detailItem.description.length)
    + ',goalLen=' + String(detailItem.goal.length)
    + ',precautions=' + String(detailItem.precautions.length)
    + ',commonErrors=' + String(detailItem.commonErrors.length)
    + ',resourcesVideo=' + String(detailItem.video.length)
    + ',resourcesAudio=' + String(detailItem.audio.length)
    + ',resourcesImages=' + String(detailItem.actionImages.length))
  upsertTrainingItemDetail(runtime.courseCode, itemCode, detailItem)
  const nextItems = runtime.items.slice()
  nextItems[runtime.currentItemIndex] = detailItem
  patchTrainSessionViewState({ trainingTip: '' })
  return patchActiveTrainSession({ items: nextItems, isCurrentItemDetailLoading: false })
}
