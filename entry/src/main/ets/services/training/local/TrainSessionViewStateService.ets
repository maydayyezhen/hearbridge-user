/**
 * 训练页视图业务服务。
 *
 * 说明：
 * 1. 基础状态存取已经下沉到 TrainSessionViewStateRepository。
 * 2. 这里仅保留面向训练流程的业务动作，不直接操作 AppStorage。
 */

import {
  patchTrainSessionViewState,
  TrainSessionViewState,
  writeTrainSessionViewState
} from '../../../repository/train-session/TrainSessionViewStateRepository'

export { TrainSessionViewState }

/**
 * 重置训练页临时视图状态。
 */
export function resetTrainSessionTransientViewState(): TrainSessionViewState {
  return writeTrainSessionViewState({
    speechPartialText: '',
    speechStatusText: '进入练习页后可开始训练。',
    trainingTip: ''
  })
}

/**
 * 提交成功后重置训练页临时输入与提示文案。
 */
export function resetTrainSessionViewStateAfterSubmission(partialText: string): TrainSessionViewState {
  return patchTrainSessionViewState({
    trainingTip: '',
    speechStatusText: '进入练习页后可开始训练。',
    speechPartialText: partialText
  })
}
