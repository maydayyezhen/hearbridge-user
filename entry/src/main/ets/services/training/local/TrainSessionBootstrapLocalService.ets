/**
 * 训练会话启动本地服务，负责训练会话启动、当前训练项详情补齐与阶段预热。
 */
import common from '@ohos.app.ability.common'
import { hilog } from '@kit.PerformanceAnalysisKit'
import {
  getCurrentTrainSessionItem,
  patchActiveTrainSession,
  readActiveTrainSession,
  TrainSessionRuntime,
  TrainStage
} from '../../../repository/train-session/TrainSessionRepository'
import { TrainingContentItem } from '../../../domain/static/train/TrainingContentModels'
import { getRetryLaterMessage } from '../../../utils/FeedbackCopy'
import { patchTrainSessionViewState } from '../../../repository/train-session/TrainSessionViewStateRepository'
import {
  createTrainSessionRouteInput,
  getAbilityContext,
  initializeBootstrapLoadingState,
  resolveBootstrapContext,
  TrainSessionRouteInput,
  tryReuseActiveRuntime
} from './TrainSessionBootstrapContextLocalService'
import { applyBootstrappedSessionDetail, loadItemDetail } from './TrainSessionBootstrapHydrationLocalService'
import { resolveSessionDetailSource, startRemoteSession } from './TrainSessionBootstrapSourceLocalService'

export { createTrainSessionRouteInput, TrainSessionRouteInput } from './TrainSessionBootstrapContextLocalService'

function traceTrainFlow(stage: string, message: string): void {
  hilog.info(0x0, 'TrainFlowTrace', `${stage}|${message}`)
}

function hasHydratedRuntimeItem(item: TrainingContentItem | undefined): boolean {
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

/**
 * 初始化训练会话运行时状态。
 */
export async function bootstrapTrainSession(contextObj: common.BaseContext | undefined, routeInput: TrainSessionRouteInput): Promise<TrainSessionRuntime> {
  const context = resolveBootstrapContext(contextObj, routeInput)
  const reusedRuntime = tryReuseActiveRuntime(context)
  if (reusedRuntime) {
    return reusedRuntime
  }

  if (!context.abilityContext || context.routeCourseCode.length === 0) {
    patchTrainSessionViewState({ trainingTip: getRetryLaterMessage('准备训练会话') })
    return patchActiveTrainSession({ isSessionLoading: false, isCurrentItemDetailLoading: false })
  }

  initializeBootstrapLoadingState(context)
  const startedSession = await startRemoteSession(context)
  if (!startedSession) {
    return readActiveTrainSession()
  }

  const detailSource = await resolveSessionDetailSource(context, startedSession)
  if (!detailSource) {
    return readActiveTrainSession()
  }

  const runtime = applyBootstrappedSessionDetail(context, startedSession, detailSource)
  return await loadItemDetail(context.abilityContext, runtime, getCurrentTrainSessionItem(runtime).code)
}

/**
 * 确保当前训练项详情已加载。
 */
export async function ensureCurrentItemDetail(contextObj: common.BaseContext | undefined, _routeInput: TrainSessionRouteInput): Promise<TrainSessionRuntime> {
  const abilityContext = getAbilityContext(contextObj)
  const runtime = readActiveTrainSession()
  if (!abilityContext || runtime.sessionId <= 0) {
    traceTrainFlow('ensureCurrentItemDetail.skipInvalidContext',
      'hasAbilityContext=' + String(abilityContext !== null)
      + ',sessionId=' + String(runtime.sessionId)
      + ',courseCode=' + runtime.courseCode
      + ',stage=' + runtime.currentStage)
    return patchActiveTrainSession({ isCurrentItemDetailLoading: false })
  }
  const currentItem = getCurrentTrainSessionItem(runtime)
  if (currentItem.code.length === 0) {
    traceTrainFlow('ensureCurrentItemDetail.skipEmptyItemCode',
      'courseCode=' + runtime.courseCode
      + ',sessionId=' + String(runtime.sessionId)
      + ',stage=' + runtime.currentStage
      + ',currentItemIndex=' + String(runtime.currentItemIndex)
      + ',itemsCount=' + String(runtime.items.length))
    return patchActiveTrainSession({ isCurrentItemDetailLoading: false })
  }
  if (hasHydratedRuntimeItem(currentItem)) {
    traceTrainFlow('ensureCurrentItemDetail.skipHydratedRuntime',
      'courseCode=' + runtime.courseCode
      + ',sessionId=' + String(runtime.sessionId)
      + ',stage=' + runtime.currentStage
      + ',itemCode=' + currentItem.code)
    return patchActiveTrainSession({ isCurrentItemDetailLoading: false })
  }
  traceTrainFlow('ensureCurrentItemDetail.enter',
    'courseCode=' + runtime.courseCode
    + ',sessionId=' + String(runtime.sessionId)
    + ',stage=' + runtime.currentStage
    + ',itemCode=' + currentItem.code)
  return await loadItemDetail(abilityContext, runtime, currentItem.code)
}

/**
 * 确保指定训练阶段对应页面所需数据已准备完成。
 */
export async function ensureStagePageReady(abilityContext: common.BaseContext | undefined, routeInput: TrainSessionRouteInput, stage: TrainStage): Promise<TrainSessionRuntime> {
  const nextRouteInput = createTrainSessionRouteInput(
    routeInput.courseCode,
    routeInput.itemCode,
    stage.length > 0 ? stage : routeInput.stage
  )
  return await bootstrapTrainSession(abilityContext, nextRouteInput)
}
