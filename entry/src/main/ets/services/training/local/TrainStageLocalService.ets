/**
 * 训练阶段本地服务，负责训练阶段值规范化与阶段流转规则。
 */
import {
  getCurrentTrainSessionItem,
  readActiveTrainSession,
  TrainSessionRuntime,
  TrainStage
} from '../../../repository/train-session/TrainSessionRepository'

/**
 * 规范训练阶段值。
 */
export function normalizeStage(value: string): TrainStage {
  switch (value) {
    case 'video':
    case 'guide':
    case 'practice':
    case 'result':
    case 'summary':
      return value
    default:
      return 'intro'
  }
}

/**
 * 获取当前阶段的下一阶段。
 */
export function getNextTrainStage(runtime?: TrainSessionRuntime): TrainStage {
  const current = runtime ?? readActiveTrainSession()
  const item = getCurrentTrainSessionItem(current)
  if (current.currentStage === 'intro') {
    return item.video.length > 0 ? 'video' : 'guide'
  }
  if (current.currentStage === 'video') {
    return 'guide'
  }
  if (current.currentStage === 'guide') {
    return 'practice'
  }
  if (current.currentStage === 'result') {
    return current.currentItemIndex >= current.items.length - 1 ? 'summary' : 'intro'
  }
  return current.currentStage
}

/**
 * 获取当前阶段的上一阶段。
 */
export function getPreviousTrainStage(runtime?: TrainSessionRuntime): TrainStage {
  const current = runtime ?? readActiveTrainSession()
  const item = getCurrentTrainSessionItem(current)
  if (current.currentStage === 'video') {
    return 'intro'
  }
  if (current.currentStage === 'guide') {
    return item.video.length > 0 ? 'video' : 'intro'
  }
  if (current.currentStage === 'practice') {
    return 'guide'
  }
  if (current.currentStage === 'result') {
    return 'practice'
  }
  return 'intro'
}
