/**
 * 训练提交结果状态写回服务。
 *
 * 说明：
 * 1. 统一收口“单次提交成功后需要同步哪些本地状态”。
 * 2. 提交 API 调用仍由 TrainSessionSubmitFlowLocalService 负责。
 * 3. 这里仅负责成功提交后的运行时、缓存、结果页与视图态写回。
 */

import { TrainingContentItem } from '../../../domain/static/train/TrainingContentModels'
import { TrainItemStatus } from '../../../domain/static/train/TrainingRuntimeTypes'
import {
  patchActiveTrainSession,
  TrainSessionRuntime
} from '../../../repository/train-session/TrainSessionRepository'
import type { SubmitTrainingItemResponseSource } from '../api/TrainSessionApiService'
import { upsertCourseTrainingItemPreviews } from '../../../repository/training-item/CourseTrainingItemIndexRepository'
import { syncCourseSessionCacheFromRuntime } from '../cache/TrainSessionCacheService'
import { applyTrainResultDetail } from './TrainResultLocalService'
import { resetTrainSessionViewStateAfterSubmission } from './TrainSessionViewStateService'
import { normalizeTrainItemStatus } from '../../../utils/TrainingTypeUtil'

/**
 * 克隆训练项，避免直接修改运行时引用。
 */
function cloneTrainingItem(item: TrainingContentItem): TrainingContentItem {
  return new TrainingContentItem(
    item.id,
    item.name,
    item.code,
    item.majorCategoryCode,
    item.levelNum,
    item.isRecommended,
    item.itemOrder,
    item.score,
    item.status,
    item.meaning,
    item.description,
    item.goal,
    item.precautions.slice(),
    item.commonErrors.slice(),
    item.cover.slice(),
    item.video.slice(),
    item.audio.slice(),
    item.actionImages.slice(),
    item.videoPoster.slice()
  )
}

/**
 * 根据提交结果生成下一份训练项数组。
 */
function resolveSubmittedItemStatus(submitData: SubmitTrainingItemResponseSource): TrainItemStatus {
  const normalizedItemStatus = normalizeTrainItemStatus(String(submitData.itemStatus ?? ''))
  if (normalizedItemStatus.length > 0) {
    return normalizedItemStatus
  }
  const normalizedEvaluationStatus = normalizeTrainItemStatus(String(submitData.evaluationStatus ?? ''))
  if (normalizedEvaluationStatus.length > 0) {
    return normalizedEvaluationStatus
  }
  return 'completed'
}

function updateSubmittedItemStates(
  runtime: TrainSessionRuntime,
  itemCode: string,
  itemStatus: string,
  score: number
): TrainingContentItem[] {
  const normalizedItemStatus = normalizeTrainItemStatus(itemStatus)
  const nextItems: TrainingContentItem[] = []
  for (let index = 0; index < runtime.items.length; index += 1) {
    const cloned = cloneTrainingItem(runtime.items[index])
    if (cloned.code === itemCode) {
      cloned.status = normalizedItemStatus
      cloned.score = score
    }
    nextItems.push(cloned)
  }
  return nextItems
}

function countCompletedTrainingItems(items: TrainingContentItem[]): number {
  let completedCount = 0
  for (let index = 0; index < items.length; index += 1) {
    if (normalizeTrainItemStatus(items[index].status) === 'completed') {
      completedCount += 1
    }
  }
  return completedCount
}

/**
 * 提交成功后统一回写训练运行时、课程缓存、结果页与训练页视图状态。
 */
export function applyTrainSessionSubmissionState(
  runtime: TrainSessionRuntime,
  submitData: SubmitTrainingItemResponseSource,
  partialText: string,
  recognizedText: string
): TrainSessionRuntime {
  const submittedItemCode = String(submitData.itemCode ?? '')
  const normalizedItemStatus = resolveSubmittedItemStatus(submitData)
  const nextScore = Math.round(Number(submitData.score))
  const nextItems = updateSubmittedItemStates(
    runtime,
    submittedItemCode,
    normalizedItemStatus,
    nextScore
  )

  upsertCourseTrainingItemPreviews(runtime.courseCode, nextItems)
  syncCourseSessionCacheFromRuntime(
    runtime,
    nextItems,
    Number(submitData.progressPercent ?? runtime.sessionProgressPercent),
    normalizedItemStatus
  )
  applyTrainResultDetail(submitData.resultDetail ?? null)
  resetTrainSessionViewStateAfterSubmission(partialText)

  return patchActiveTrainSession({
    items: nextItems,
    currentScore: nextScore,
    speechRecognizedText: recognizedText,
    currentStage: 'result',
    isScoring: false,
    currentItemStatus: normalizedItemStatus,
    completedItemCount: countCompletedTrainingItems(nextItems),
    totalItemCount: nextItems.length > 0 ? nextItems.length : runtime.totalItemCount,
    sessionProgressPercent: Number(submitData.progressPercent ?? runtime.sessionProgressPercent)
  })
}
