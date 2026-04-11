/**
 * 训练结果页视图状态 Store。
 *
 * 说明：
 * 1. 这里只维护结果页展示模型的基础读写。
 * 2. 结果解析、标题/标签/趋势组装等业务逻辑不放在 Store 中。
 */

/**
 * 结果页单个维度分数。
 */
export interface TrainResultDimension {
  label: string
  score: number
}

/**
 * 结果页标签区块。
 */
export interface TrainResultTagSection {
  title: string
  tags: string[]
  description: string
}

/**
 * 结果页趋势区块。
 */
export interface TrainResultTrendState {
  title: string
  scores: number[]
  description: string
}

/**
 * 结果页完整视图状态。
 */
export interface TrainResultViewState {
  resultTitle: string
  resultScoreLabel: string
  resultBadges: string[]
  resultDimensions: TrainResultDimension[]
  resultStrengths: TrainResultTagSection
  resultImprovements: TrainResultTagSection
  resultRecentTrend: TrainResultTrendState
}

/** 结果页视图状态存储键。 */
export const TRAIN_RESULT_VIEW_STATE_KEY = 'train.session.resultViewState'

/**
 * 创建空白标签区块。
 * @param title 区块标题。
 * @returns 空白标签区块。
 */
export function createEmptyResultTagSection(title: string): TrainResultTagSection {
  return { title, tags: [], description: '' }
}

/**
 * 创建空白趋势区块。
 * @returns 空白趋势区块。
 */
export function createEmptyResultTrendState(): TrainResultTrendState {
  return { title: '最近表现', scores: [], description: '' }
}

/**
 * 创建空白结果页视图状态。
 * @returns 空白结果页视图状态。
 */
export function createEmptyTrainResultViewState(): TrainResultViewState {
  return {
    resultTitle: '',
    resultScoreLabel: '训练得分',
    resultBadges: [],
    resultDimensions: [],
    resultStrengths: createEmptyResultTagSection('本次亮点'),
    resultImprovements: createEmptyResultTagSection('建议改进'),
    resultRecentTrend: createEmptyResultTrendState()
  }
}

/**
 * 初始化结果页视图状态 Store。
 */
export function initTrainResultViewStateStore(): void {
  AppStorage.setOrCreate(TRAIN_RESULT_VIEW_STATE_KEY, createEmptyTrainResultViewState())
}

/**
 * 读取结果页视图状态。
 * @returns 当前结果页视图状态。
 */
export function readTrainResultViewStateStore(): TrainResultViewState {
  return (AppStorage.get(TRAIN_RESULT_VIEW_STATE_KEY) as TrainResultViewState | undefined) ?? createEmptyTrainResultViewState()
}

/**
 * 写入结果页视图状态。
 * @param state 结果页视图状态。
 * @returns 写入后的结果页视图状态。
 */
export function writeTrainResultViewStateStore(state: TrainResultViewState): TrainResultViewState {
  AppStorage.setOrCreate(TRAIN_RESULT_VIEW_STATE_KEY, state)
  return state
}
