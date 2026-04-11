/**
 * 训练会话统计查询服务，负责基于训练运行时计算总结页所需统计结果。
 */

import { readActiveTrainSession, TrainSessionRuntime } from '../../../repository/train-session/TrainSessionRepository'

/**
 * 统计已完成训练项数量。
 */
export function getCompletedTrainItemCount(runtime?: TrainSessionRuntime): number {
  const current = runtime ?? readActiveTrainSession()
  let count = 0
  for (let index = 0; index < current.items.length; index += 1) {
    if (current.items[index].status === 'completed') count += 1
  }
  return count
}

/**
 * 统计平均训练得分。
 */
export function getAverageTrainScore(runtime?: TrainSessionRuntime): number {
  const current = runtime ?? readActiveTrainSession()
  let total = 0
  let count = 0
  for (let index = 0; index < current.items.length; index += 1) {
    if (current.items[index].status === 'completed' && current.items[index].score > 0) {
      total += current.items[index].score
      count += 1
    }
  }
  if (count === 0) return current.currentScore > 0 ? current.currentScore : 0
  return Math.round(total / count)
}

/**
 * 获取本次训练内最高得分。
 */
export function getBestTrainScore(runtime?: TrainSessionRuntime): number {
  const current = runtime ?? readActiveTrainSession()
  let best = current.currentScore
  for (let index = 0; index < current.items.length; index += 1) {
    if (current.items[index].score > best) best = current.items[index].score
  }
  return best
}
