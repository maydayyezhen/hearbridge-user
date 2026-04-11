/**
 * TrainResultViewStateRepository 文件，负责结果页视图状态的仓储读写与状态转接。
 */

import {
  createEmptyResultTagSection,
  createEmptyResultTrendState,
  createEmptyTrainResultViewState,
  initTrainResultViewStateStore,
  readTrainResultViewStateStore,
  TrainResultDimension,
  TrainResultTagSection,
  TrainResultTrendState,
  TrainResultViewState,
  writeTrainResultViewStateStore
} from '../../storage/train-session/TrainResultViewStateStore'

export {
  createEmptyResultTagSection,
  createEmptyResultTrendState,
  createEmptyTrainResultViewState,
  TrainResultDimension,
  TrainResultTagSection,
  TrainResultTrendState,
  TrainResultViewState
}

/**
 * 初始化结果页视图状态仓储依赖的 Store。
 */
export function initTrainResultViewStateRepository(): void {
  initTrainResultViewStateStore()
}

/**
 * 读取结果页视图状态。
 * @returns 当前结果页视图状态。
 */
export function readTrainResultViewState(): TrainResultViewState {
  return readTrainResultViewStateStore()
}

/**
 * 写入结果页视图状态。
 * @param state 结果页视图状态。
 * @returns 写入后的结果页视图状态。
 */
export function writeTrainResultViewState(state: TrainResultViewState): TrainResultViewState {
  return writeTrainResultViewStateStore(state)
}

/**
 * 以补丁方式更新结果页视图状态。
 * @param patch 结果页视图状态补丁。
 * @returns 更新后的结果页视图状态。
 */
export function patchTrainResultViewState(patch: Partial<TrainResultViewState>): TrainResultViewState {
  const current = readTrainResultViewStateStore()
  const next: TrainResultViewState = {
    resultTitle: patch.resultTitle !== undefined ? patch.resultTitle : current.resultTitle,
    resultScoreLabel: patch.resultScoreLabel !== undefined ? patch.resultScoreLabel : current.resultScoreLabel,
    resultBadges: patch.resultBadges !== undefined ? patch.resultBadges : current.resultBadges,
    resultDimensions: patch.resultDimensions !== undefined ? patch.resultDimensions : current.resultDimensions,
    resultStrengths: patch.resultStrengths !== undefined ? patch.resultStrengths : current.resultStrengths,
    resultImprovements: patch.resultImprovements !== undefined ? patch.resultImprovements : current.resultImprovements,
    resultRecentTrend: patch.resultRecentTrend !== undefined ? patch.resultRecentTrend : current.resultRecentTrend
  }
  return writeTrainResultViewStateStore(next)
}

/**
 * 清空结果页视图状态。
 * @returns 清空后的结果页视图状态。
 */
export function clearTrainResultViewState(): TrainResultViewState {
  return writeTrainResultViewStateStore(createEmptyTrainResultViewState())
}
