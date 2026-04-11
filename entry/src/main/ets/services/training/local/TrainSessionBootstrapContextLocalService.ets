/**
 * 训练会话启动上下文本地服务，负责 route input、启动上下文解析与运行时复用判定。
 */
import common from '@ohos.app.ability.common'
import { TrainingContentItem } from '../../../domain/static/train/TrainingContentModels'
import { TrainingType } from '../../../domain/static/train/TrainingRuntimeTypes'
import { getCoursePreview } from '../../../repository/course/CoursePreviewRepository'
import { getCourseDetailCache } from '../../../repository/course/CourseDetailRepository'
import { getCourseSessionCache } from '../../../repository/course/CourseSessionRepository'
import { upsertCourseTrainingItemPreviews } from '../../../repository/training-item/CourseTrainingItemIndexRepository'
import {
  patchActiveTrainSession,
  readActiveTrainSession,
  TrainSessionRuntime,
  TrainStage
} from '../../../repository/train-session/TrainSessionRepository'
import { normalizeTrainingType } from '../../../utils/TrainingTypeUtil'
import { getPendingMessage } from '../../../utils/FeedbackCopy'
import { normalizeStage } from './TrainStageLocalService'
import { patchTrainSessionViewState } from '../../../repository/train-session/TrainSessionViewStateRepository'
import { clearTrainResultViewState } from '../../../repository/train-session/TrainResultViewStateRepository'
import { resetTrainSessionTransientViewState } from './TrainSessionViewStateService'

/**
 * 训练会话路由输入。
 */
export interface TrainSessionRouteInput {
  courseCode: string
  itemCode: string
  stage: TrainStage
}

/**
 * 创建训练会话路由输入。
 */
export function createTrainSessionRouteInput(courseCode: string = '', itemCode: string = '', stage: TrainStage = 'intro'): TrainSessionRouteInput {
  return {
    courseCode,
    itemCode,
    stage
  }
}

/**
 * 训练会话启动上下文。
 */
export interface TrainSessionBootstrapContext {
  abilityContext: common.BaseContext | null
  routeCourseCode: string
  preferredItemCode: string
  nextStage: TrainStage
  routeTrainingType: TrainingType
}

/**
 * 从通用对象中安全获取 AbilityContext。
 */
export function getAbilityContext(context?: common.BaseContext): common.BaseContext | null {
  return context ?? null
}

/**
 * 根据优先训练项编码解析当前训练项下标。
 */
export function resolveSelectedIndex(items: TrainingContentItem[], preferredItemCode: string): number {
  if (preferredItemCode.length === 0) return 0
  for (let index = 0; index < items.length; index += 1) {
    if (items[index].code === preferredItemCode) return index
  }
  return 0
}

/**
 * 解析训练启动上下文。
 */
export function resolveBootstrapContext(contextObj: common.BaseContext | undefined, routeInput: TrainSessionRouteInput): TrainSessionBootstrapContext {
  const routeCourseCode = routeInput.courseCode.trim()
  const detail = getCourseDetailCache(routeCourseCode)
  const preview = getCoursePreview(routeCourseCode)
  return {
    abilityContext: getAbilityContext(contextObj),
    routeCourseCode,
    preferredItemCode: routeInput.itemCode.trim(),
    nextStage: normalizeStage(routeInput.stage),
    routeTrainingType: normalizeTrainingType(String(detail?.trainingType ?? preview?.trainingType ?? 'gesture'))
  }
}

/**
 * 尝试复用当前仍然有效的训练运行时。
 */
export function tryReuseActiveRuntime(context: TrainSessionBootstrapContext): TrainSessionRuntime | null {
  const current = readActiveTrainSession()
  if (current.sessionId <= 0 || current.courseCode !== context.routeCourseCode || current.items.length === 0) {
    return null
  }
  const cached = getCourseSessionCache(context.routeCourseCode)
  if (cached && cached.sessionId > 0 && cached.sessionId !== current.sessionId) {
    return null
  }
  upsertCourseTrainingItemPreviews(context.routeCourseCode, current.items)
  patchTrainSessionViewState({ trainingTip: '' })
  const selectedIndex = resolveSelectedIndex(current.items, context.preferredItemCode)
  return patchActiveTrainSession({
    currentStage: context.nextStage,
    currentItemIndex: selectedIndex,
    isSessionLoading: false,
    isCurrentItemDetailLoading: false
  })
}

/**
 * 初始化训练启动阶段的页面 loading 与运行时状态。
 */
export function initializeBootstrapLoadingState(context: TrainSessionBootstrapContext): void {
  resetTrainSessionTransientViewState()
  clearTrainResultViewState()
  patchTrainSessionViewState({ trainingTip: getPendingMessage('准备训练会话') })
  patchActiveTrainSession({
    isSessionLoading: true,
    isCurrentItemDetailLoading: true,
    currentStage: context.nextStage,
    courseCode: context.routeCourseCode,
    trainingType: context.routeTrainingType,
    currentScore: 0,
    speechRecognizedText: ''
  })
}
