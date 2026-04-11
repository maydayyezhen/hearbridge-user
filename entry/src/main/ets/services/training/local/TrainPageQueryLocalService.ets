/**
 * 训练页面查询服务，负责为训练相关页面提供只读视图选择结果。
 *
 * 说明：
 * 1. 页面层只依赖这里暴露的查询方法与状态类型，不再直接 import repository。
 * 2. 这里可以组合 repository 中的只读事实，但不承担写状态职责。
 */

import { User } from '../../../domain/entity/User'
import { TrainingContentItem } from '../../../domain/static/train/TrainingContentModels'
import {
  clearTrainSessionExitState,
  createEmptyTrainSessionRuntime,
  getCurrentTrainSessionItem,
  TrainSessionRuntime,
  TrainStage
} from '../../../repository/train-session/TrainSessionRepository'
import {
  getAverageTrainScore,
  getBestTrainScore,
  getCompletedTrainItemCount
} from '../query/TrainSessionStatsQueryService'
import { createEmptyTrainSessionViewState, TrainSessionViewState } from '../../../repository/train-session/TrainSessionViewStateRepository'
import { createEmptyTrainResultViewState, TrainResultDimension, TrainResultViewState } from '../../../repository/train-session/TrainResultViewStateRepository'
import { hasFavoriteCourse, hasFavoriteItem } from '../../../repository/user/UserRepository'
import { getTrainPageCourseDisplay } from '../query/TrainPageScaffoldQueryService'
import { TrainPageCourseDisplay } from '../model/TrainPageCourseDisplay'
import { TrainSummaryViewState } from '../model/TrainSummaryViewState'

export {
  TrainSessionRuntime,
  TrainSessionViewState,
  TrainResultDimension,
  TrainResultViewState,
  TrainStage,
  TrainPageCourseDisplay
}


/**
 * 创建空训练运行时默认值，供页面 StorageLink 使用。
 */
export function createEmptyTrainPageRuntime(): TrainSessionRuntime {
  return createEmptyTrainSessionRuntime()
}

/**
 * 创建空训练页视图状态默认值，供页面 StorageLink 使用。
 */
export function createEmptyTrainPageViewState(): TrainSessionViewState {
  return createEmptyTrainSessionViewState()
}

/**
 * 创建空结果页视图状态默认值，供页面 StorageLink 使用。
 */
export function createEmptyTrainPageResultViewState(): TrainResultViewState {
  return createEmptyTrainResultViewState()
}

/**
 * 获取当前训练项。
 */
export function getTrainPageCurrentItem(runtime: TrainSessionRuntime): TrainingContentItem {
  return getCurrentTrainSessionItem(runtime)
}

/**
 * 获取当前训练阶段。
 */
export function getTrainPageStage(runtime: TrainSessionRuntime): TrainStage {
  return runtime.currentStage.length > 0 ? runtime.currentStage : 'intro'
}

/**
 * 计算训练页阶段标签文案。
 */
export function getTrainPageStageLabel(stage: TrainStage): string {
  switch (stage) {
    case 'video':
      return '示范'
    case 'guide':
      return '指导'
    case 'practice':
      return '练习'
    case 'result':
      return '结果'
    case 'summary':
      return '总结'
    default:
      return '准备'
  }
}

/**
 * 计算训练页标题文案。
 */
export function getTrainPageTitle(stage: TrainStage): string {
  switch (stage) {
    case 'video':
      return '示范视频'
    case 'guide':
      return '步骤讲解'
    case 'practice':
      return '开始练习'
    case 'result':
      return '评分结果'
    case 'summary':
      return '课程总结'
    default:
      return '训练介绍'
  }
}

/**
 * 计算训练页副标题文案。
 */
export function getTrainPageSubtitle(stage: TrainStage, trainingTip: string): string {
  if (trainingTip.length > 0) {
    return trainingTip
  }
  switch (stage) {
    case 'video':
      return '观察示范资源，准备进入指导与练习。'
    case 'guide':
      return '动作要点、步骤图和常见错误都会在这里展示。'
    case 'practice':
      return '按当前模式完成本轮练习并提交评分。'
    case 'result':
      return '查看本轮训练结果，再决定是否继续。'
    case 'summary':
      return '本轮训练的整体总结与建议。'
    default:
      return '先确认本轮目标与动作重点，再进入后续阶段。'
  }
}

/**
 * 获取当前训练项名称。
 */
export function getTrainPageCurrentItemName(runtime: TrainSessionRuntime): string {
  const item = getTrainPageCurrentItem(runtime)
  return item.name.length > 0 ? item.name : '尚未选择训练项'
}

/**
 * 获取当前训练项释义。
 */
export function getTrainPageCurrentItemMeaning(runtime: TrainSessionRuntime): string {
  return getTrainPageCurrentItem(runtime).meaning
}

/**
 * 计算训练页进度文本。
 */
export function getTrainPageProgressText(runtime: TrainSessionRuntime): string {
  const total = runtime.totalItemCount > 0 ? runtime.totalItemCount : runtime.items.length
  if (total <= 0) {
    return '0/0'
  }
  const current = Math.max(0, Math.min(runtime.currentItemIndex + 1, total))
  return `${current}/${total}`
}

/**
 * 获取已完成训练项 id 列表。
 */
export function getTrainPageCompletedItemIds(runtime: TrainSessionRuntime): number[] {
  const ids: number[] = []
  for (let i = 0; i < runtime.items.length; i += 1) {
    if (runtime.items[i].status === 'completed') {
      ids.push(runtime.items[i].id)
    }
  }
  return ids
}

/**
 * 判断训练页当前课程是否已收藏。
 */
export function isTrainPageCourseFavorited(user: User, courseCode: string): boolean {
  return courseCode.length > 0 && hasFavoriteCourse(user, courseCode)
}

export function isTrainPageItemFavorited(user: User, itemCode: string): boolean {
  return itemCode.length > 0 && hasFavoriteItem(user, itemCode)
}

/**
 * 构造训练总结页所需的统计视图状态。
 */
export function buildTrainSummaryViewState(runtime: TrainSessionRuntime): TrainSummaryViewState {
  const summary = new TrainSummaryViewState()
  summary.completedCount = getCompletedTrainItemCount(runtime)
  summary.totalCount = runtime.totalItemCount > 0 ? runtime.totalItemCount : runtime.items.length
  summary.averageScore = getAverageTrainScore(runtime)
  summary.bestScore = getBestTrainScore(runtime)
  return summary
}

/**
 * 清空训练退出态。
 */
export function clearTrainPageExitRuntime(): void {
  clearTrainSessionExitState()
}

/**
 * 获取训练页课程展示信息。
 */
export function getTrainPageCourseDisplayState(runtime: TrainSessionRuntime): TrainPageCourseDisplay {
  return getTrainPageCourseDisplay(runtime)
}
