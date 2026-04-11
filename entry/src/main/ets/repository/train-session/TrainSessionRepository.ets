/**
 * TrainSessionRepository 文件，负责对应模块的仓储读写与状态转接。
 */

import {
  clearActiveTrainSession,
  createEmptyTrainSessionRuntime,
  getCurrentTrainSessionItem,
  initTrainSessionStore,
  patchActiveTrainSession,
  readActiveTrainSession,
  readCompletedTrainItemCodes,
  resetCompletedTrainItemCodes,
  setCurrentTrainStage,
  TrainSessionRuntime,
  TrainStage,
  writeCompletedTrainItemCodes
} from '../../storage/train-session/TrainSessionStore'
import { TrainItemStatus } from '../../domain/static/train/TrainingRuntimeTypes'
import { normalizeTrainItemStatus } from '../../utils/TrainingTypeUtil'

export {
  createEmptyTrainSessionRuntime,
  getCurrentTrainSessionItem,
  patchActiveTrainSession,
  readActiveTrainSession,
  setCurrentTrainStage,
  TrainSessionRuntime,
  TrainStage
}

/**
 * 初始化训练会话仓储依赖的 Store。
 */
export function initTrainSessionRepository(): void {
  initTrainSessionStore()
}

/**
 * 清空训练运行时状态。
 * @returns 清空后的运行时状态。
 */
export function clearTrainSessionRuntime(): TrainSessionRuntime {
  resetCompletedTrainItemCodes()
  return clearActiveTrainSession()
}

/**
 * 读取当前训练会话已完成训练项编码列表。
 * @returns 已完成训练项编码列表。
 */
export function getCompletedTrainItemCodes(): string[] {
  return readCompletedTrainItemCodes()
}

/**
 * 重置当前训练会话已完成训练项编码列表。
 */
export function clearCompletedTrainItemCodes(): void {
  resetCompletedTrainItemCodes()
}

/**
 * 将训练项编码加入当前训练会话已完成列表。
 * 若已存在则不重复添加。
 * @param itemCode 训练项编码。
 * @returns 本次是否为首次记录。
 */
export function appendCompletedTrainItemCode(itemCode: string): boolean {
  if (itemCode.length === 0) return false
  const current = readCompletedTrainItemCodes()
  for (let index = 0; index < current.length; index += 1) {
    if (current[index] === itemCode) return false
  }
  current.push(itemCode)
  writeCompletedTrainItemCodes(current)
  return true
}

function resolveCurrentItemStatusAfterMove(runtime: TrainSessionRuntime, targetIndex: number): TrainItemStatus {
  if (runtime.items.length <= 0 || targetIndex < 0 || targetIndex >= runtime.items.length) {
    return ''
  }
  const normalizedStatus = normalizeTrainItemStatus(runtime.items[targetIndex].status)
  if (normalizedStatus === 'completed') {
    return 'completed'
  }
  return 'in_progress'
}

/**
 * 将训练运行时切到下一训练项，并重置基础运行时字段。
 * @returns 更新后的训练运行时对象。
 */
export function moveToNextTrainItem(): TrainSessionRuntime {
  const current = readActiveTrainSession()
  const nextIndex = Math.min(current.items.length - 1, current.currentItemIndex + 1)
  return patchActiveTrainSession({
    currentItemIndex: nextIndex,
    currentItemStatus: resolveCurrentItemStatusAfterMove(current, nextIndex),
    currentStage: 'intro',
    currentScore: 0,
    speechRecognizedText: ''
  })
}

/**
 * 将训练运行时切到上一训练项。
 * @returns 更新后的训练运行时对象。
 */
export function moveToPreviousTrainItem(): TrainSessionRuntime {
  const current = readActiveTrainSession()
  const nextIndex = Math.max(0, current.currentItemIndex - 1)
  return patchActiveTrainSession({
    currentItemIndex: nextIndex,
    currentItemStatus: resolveCurrentItemStatusAfterMove(current, nextIndex),
    currentStage: 'intro',
    currentScore: 0,
    speechRecognizedText: ''
  })
}

/**
 * 标记训练会话为暂停总结状态。
 * @param pausedAtName 暂停时的训练项名称。
 * @returns 更新后的训练运行时对象。
 */
export function markTrainSessionPaused(pausedAtName?: string): TrainSessionRuntime {
  const current = readActiveTrainSession()
  const currentItem = getCurrentTrainSessionItem(current)
  return patchActiveTrainSession({
    summaryMode: 'paused',
    pausedAtName: pausedAtName !== undefined ? pausedAtName : currentItem.name,
    currentStage: 'summary',
    isScoring: false
  })
}

/**
 * 标记训练会话为完成总结状态。
 * @returns 更新后的训练运行时对象。
 */
export function markTrainSessionCompleted(): TrainSessionRuntime {
  return patchActiveTrainSession({ summaryMode: 'completed', pausedAtName: '', currentStage: 'summary', isScoring: false })
}

/**
 * 清空训练退出态。
 */
export function clearTrainSessionExitState(): void {
  clearCompletedTrainItemCodes()
  clearActiveTrainSession()
}
