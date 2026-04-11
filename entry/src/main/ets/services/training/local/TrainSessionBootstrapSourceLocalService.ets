/**
 * 训练会话启动来源本地服务，负责启动远端会话与解析详情来源。
 */
import {
  fetchTrainSessionDetail,
  startTrainSession,
  StartTrainingSessionResponseSource,
  TrainingSessionDetailResponseSource
} from '../api/TrainSessionApiService'
import { createCourseSessionDetailSnapshot, getCourseSessionCache } from '../../../repository/course/CourseSessionRepository'
import { patchActiveTrainSession } from '../../../repository/train-session/TrainSessionRepository'
import { normalizeTrainItemStatus, normalizeTrainingType } from '../../../utils/TrainingTypeUtil'
import { getRetryLaterMessage } from '../../../utils/FeedbackCopy'
import { patchTrainSessionViewState } from '../../../repository/train-session/TrainSessionViewStateRepository'
import { TrainSessionBootstrapContext } from './TrainSessionBootstrapContextLocalService'
import { TrainItemStatus } from '../../../domain/static/train/TrainingRuntimeTypes'

export interface StartedTrainSession {
  sessionId: number
  currentItemStatus: TrainItemStatus
}

/**
 * 统一处理启动训练会话接口返回。
 */
export function resolveStartedTrainSession(data: StartTrainingSessionResponseSource | null | undefined): StartedTrainSession | null {
  if (!data) return null
  const sessionId = Number(data.sessionId ?? 0)
  if (sessionId <= 0) return null
  return {
    sessionId,
    currentItemStatus: normalizeTrainItemStatus(String(data.currentItemStatus ?? ''))
  }
}

/**
 * 启动远端训练会话。
 */
export async function startRemoteSession(context: TrainSessionBootstrapContext): Promise<StartedTrainSession | null> {
  const startResult = await startTrainSession(context.routeCourseCode)
  const startedSession = resolveStartedTrainSession(startResult.data)
  if (!startResult.ok || !startedSession) {
    patchTrainSessionViewState({
      trainingTip: startResult.message.length > 0 ? startResult.message : getRetryLaterMessage('启动训练会话')
    })
    patchActiveTrainSession({ isSessionLoading: false, isCurrentItemDetailLoading: false })
    return null
  }
  return startedSession
}

/**
 * 解析训练会话详情来源，优先尝试课程继续练习缓存。
 */
export async function resolveSessionDetailSource(
  context: TrainSessionBootstrapContext,
  startedSession: StartedTrainSession
): Promise<TrainingSessionDetailResponseSource | null> {
  const cached = getCourseSessionCache(context.routeCourseCode)
  const canReuseCachedSession = cached !== undefined
    && cached.sessionId === startedSession.sessionId
    && normalizeTrainingType(cached.trainingType) === context.routeTrainingType
  const cachedDetail = canReuseCachedSession && cached ? createCourseSessionDetailSnapshot(cached) : null
  if (cachedDetail) {
    return cachedDetail
  }

  const remoteDetailResult = await fetchTrainSessionDetail(startedSession.sessionId)
  if (!remoteDetailResult.ok || !remoteDetailResult.data) {
    patchTrainSessionViewState({
      trainingTip: remoteDetailResult.message.length > 0
        ? remoteDetailResult.message
        : getRetryLaterMessage('加载训练会话详情')
    })
    patchActiveTrainSession({ isSessionLoading: false, isCurrentItemDetailLoading: false })
    return null
  }
  return remoteDetailResult.data
}
