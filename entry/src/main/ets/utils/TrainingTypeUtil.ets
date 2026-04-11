/**
 * 训练类型与训练运行时值规范化工具。
 */
import { PracticeMode, TrainingType, TrainItemStatus } from '../domain/static/train/TrainingRuntimeTypes'

/**
 * 规范训练类型值。
 * @returns 规范化后的训练类型，仅返回 speech 或 gesture。
 */
export function normalizeTrainingType(value: string): TrainingType {
  const raw = value.trim().toLowerCase()
  if (raw === 'voice' || raw === 'speech') {
    return 'speech'
  }
  if (raw === 'gesture' || raw === 'sign') {
    return 'gesture'
  }
  return 'gesture'
}

/**
 * 规范训练项状态值。
 */
export function normalizeTrainItemStatus(value: string): TrainItemStatus {
  const raw = value.trim().toLowerCase()
  switch (raw) {
    case 'completed':
    case 'current':
    case 'in_progress':
    case 'pending':
      return raw
    default:
      return ''
  }
}

/**
 * 根据训练类型规范练习模式。
 */
export function normalizePracticeMode(value: string, trainingType: TrainingType = 'gesture'): PracticeMode {
  if (trainingType !== 'speech') {
    return 'video'
  }
  return 'audio'
}
