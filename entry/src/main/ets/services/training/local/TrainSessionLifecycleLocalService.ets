/**
 * 训练会话生命周期本地服务，负责暂停/完成等会话级动作的公共写回。
 */
import { TrainingContentItem } from '../../../domain/static/train/TrainingContentModels'
import {
  patchActiveTrainSession,
  TrainSessionRuntime
} from '../../../repository/train-session/TrainSessionRepository'
import { syncCourseSessionCacheFromRuntime } from '../cache/TrainSessionCacheService'

/**
 * 判断训练项是否包含示范视频。
 */
export function hasVideo(item: TrainingContentItem): boolean {
  return item.video.length > 0
}

/**
 * 统一回写会话级动作结果。
 */
export function applyLifecycleResult(
  runtime: TrainSessionRuntime,
  summaryMode: 'paused' | 'completed',
  progressPercent?: number | string,
  pausedAtName: string = ''
): TrainSessionRuntime {
  const nextProgressPercent = Number(progressPercent ?? runtime.sessionProgressPercent)
  syncCourseSessionCacheFromRuntime(runtime, runtime.items, nextProgressPercent, runtime.currentItemStatus)
  return patchActiveTrainSession({
    summaryMode,
    pausedAtName,
    sessionProgressPercent: nextProgressPercent,
    currentStage: 'summary',
    isScoring: false
  })
}
