/**
 * TrainSessionViewStateRepository 文件，负责训练页视图状态的仓储读写与状态转接。
 */

import {
  createEmptyTrainSessionViewState,
  initTrainSessionViewStateStore,
  readTrainSessionViewStateStore,
  TrainSessionViewState,
  writeTrainSessionViewStateStore
} from '../../storage/train-session/TrainSessionViewStateStore'

export {
  createEmptyTrainSessionViewState,
  TrainSessionViewState
}

/**
 * 初始化训练页视图状态仓储依赖的 Store。
 */
export function initTrainSessionViewStateRepository(): void {
  initTrainSessionViewStateStore()
}

/**
 * 读取训练页视图状态。
 */
export function readTrainSessionViewState(): TrainSessionViewState {
  return readTrainSessionViewStateStore()
}

/**
 * 写入训练页视图状态。
 */
export function writeTrainSessionViewState(state: TrainSessionViewState): TrainSessionViewState {
  return writeTrainSessionViewStateStore(state)
}

/**
 * 以补丁方式更新训练页视图状态。
 */
export function patchTrainSessionViewState(patch: Partial<TrainSessionViewState>): TrainSessionViewState {
  const current = readTrainSessionViewStateStore()
  const next: TrainSessionViewState = {
    speechPartialText: patch.speechPartialText !== undefined ? patch.speechPartialText : current.speechPartialText,
    speechStatusText: patch.speechStatusText !== undefined ? patch.speechStatusText : current.speechStatusText,
    trainingTip: patch.trainingTip !== undefined ? patch.trainingTip : current.trainingTip
  }
  return writeTrainSessionViewStateStore(next)
}

/**
 * 清空训练页视图状态。
 */
export function clearTrainSessionViewState(): TrainSessionViewState {
  return writeTrainSessionViewStateStore(createEmptyTrainSessionViewState())
}
