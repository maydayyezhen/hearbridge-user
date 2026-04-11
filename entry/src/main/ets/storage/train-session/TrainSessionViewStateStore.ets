/**
 * 训练页视图状态 Store。
 *
 * 说明：
 * 1. 这里只维护训练页展示态与临时上下文的基础读写。
 * 2. 课程展示信息改由 query service 组装，不再放入训练页临时状态。
 */

/**
 * 训练页视图状态。
 */
export interface TrainSessionViewState {
  speechPartialText: string
  speechStatusText: string
  trainingTip: string
}

/** 训练页视图状态存储键。 */
export const TRAIN_SESSION_VIEW_STATE_KEY = 'train.session.viewState'

/**
 * 创建空白训练页视图状态。
 */
export function createEmptyTrainSessionViewState(): TrainSessionViewState {
  return {
    speechPartialText: '',
    speechStatusText: '进入练习页后可开始训练。',
    trainingTip: ''
  }
}

/**
 * 初始化训练页视图状态 Store。
 */
export function initTrainSessionViewStateStore(): void {
  AppStorage.setOrCreate(TRAIN_SESSION_VIEW_STATE_KEY, createEmptyTrainSessionViewState())
}

/**
 * 读取训练页视图状态。
 */
export function readTrainSessionViewStateStore(): TrainSessionViewState {
  return (AppStorage.get(TRAIN_SESSION_VIEW_STATE_KEY) as TrainSessionViewState | undefined) ?? createEmptyTrainSessionViewState()
}

/**
 * 写入训练页视图状态。
 */
export function writeTrainSessionViewStateStore(state: TrainSessionViewState): TrainSessionViewState {
  AppStorage.setOrCreate(TRAIN_SESSION_VIEW_STATE_KEY, state)
  return state
}
