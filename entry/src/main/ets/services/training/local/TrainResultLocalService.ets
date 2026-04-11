/**
 * 训练结果页业务服务。
 *
 * 说明：
 * 1. 基础状态存取已经下沉到 TrainResultViewStateRepository。
 * 2. 这里仅保留“把后端结果详情组装成结果页视图模型”的业务动作。
 */

import {
  createEmptyResultTagSection,
  createEmptyResultTrendState,
  createEmptyTrainResultViewState,
  TrainResultDimension,
  TrainResultTagSection,
  TrainResultTrendState,
  TrainResultViewState,
  writeTrainResultViewState
} from '../../../repository/train-session/TrainResultViewStateRepository'
import type {
  SubmitTrainingDimensionSource,
  SubmitTrainingResultDetailSource,
  SubmitTrainingTagSectionSource,
  SubmitTrainingTrendSource
} from '../../../api/requests/TrainingApi'

export {
  TrainResultDimension,
  TrainResultTagSection,
  TrainResultTrendState,
  TrainResultViewState
}

/**
 * 把结果详情源映射为结果页维度数组。
 * @param source 维度源数组。
 * @returns 结果页维度数组。
 */
function toResultDimensions(source: SubmitTrainingDimensionSource[]): TrainResultDimension[] {
  const result: TrainResultDimension[] = []
  for (let i = 0; i < source.length; i += 1) {
    result.push({ label: String(source[i].label ?? ''), score: Math.round(Number(source[i].score ?? 0)) })
  }
  return result
}

/**
 * 把结果详情源映射为结果页标签区块。
 * @param source 标签区块源。
 * @param defaultTitle 默认标题。
 * @returns 结果页标签区块。
 */
function toResultTagSection(source: SubmitTrainingTagSectionSource | null | undefined, defaultTitle: string): TrainResultTagSection {
  if (source === null || source === undefined) return createEmptyResultTagSection(defaultTitle)
  return { title: source.title ?? defaultTitle, tags: source.tags ?? [], description: source.description ?? '' }
}

/**
 * 把结果详情源映射为结果页趋势区块。
 * @param source 趋势区块源。
 * @returns 结果页趋势区块。
 */
function toResultTrend(source: SubmitTrainingTrendSource | null | undefined): TrainResultTrendState {
  if (source === null || source === undefined) return createEmptyResultTrendState()
  return { title: source.title ?? '最近表现', scores: source.scores ?? [], description: source.description ?? '' }
}

/**
 * 把后端返回的结果详情应用到结果页视图状态。
 * @param resultDetail 接口返回的结果详情。
 * @returns 写入后的结果页视图状态。
 */
export function applyTrainResultDetail(resultDetail: SubmitTrainingResultDetailSource | null | undefined): TrainResultViewState {
  if (!resultDetail) {
    return writeTrainResultViewState(createEmptyTrainResultViewState())
  }
  return writeTrainResultViewState({
    resultTitle: resultDetail.title ?? '',
    resultScoreLabel: resultDetail.scoreLabel ?? '训练得分',
    resultBadges: resultDetail.badges ?? [],
    resultDimensions: toResultDimensions(resultDetail.dimensions ?? []),
    resultStrengths: toResultTagSection(resultDetail.strengths ?? null, '本次亮点'),
    resultImprovements: toResultTagSection(resultDetail.improvements ?? null, '建议改进'),
    resultRecentTrend: toResultTrend(resultDetail.recentTrend ?? null)
  })
}
