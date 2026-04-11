/**
 * TrainSessionStore 文件，负责对应模块的本地状态存取。
 */

import { TrainingContentItem } from '../../domain/static/train/TrainingContentModels'
import { TrainingType, TrainItemStatus } from '../../domain/static/train/TrainingRuntimeTypes'

/** 训练阶段。 */
export type TrainStage = 'intro' | 'video' | 'guide' | 'practice' | 'result' | 'summary'
/** 训练总结模式。 */
export type TrainSummaryMode = 'paused' | 'completed'

/**
 * 训练运行时补丁对象。
 */
export interface TrainSessionRuntimePatch {
  sessionId?: number
  courseCode?: string
  trainingType?: TrainingType
  currentItemIndex?: number
  currentItemStatus?: TrainItemStatus
  currentStage?: TrainStage
  currentScore?: number
  summaryMode?: TrainSummaryMode
  pausedAtName?: string
  speechRecognizedText?: string
  isScoring?: boolean
  isSessionLoading?: boolean
  isCurrentItemDetailLoading?: boolean
  sessionProgressPercent?: number
  completedItemCount?: number
  totalItemCount?: number
  items?: TrainingContentItem[]
  updatedAt?: number
}

/**
 * 训练运行时对象。
 *
 * 约束：这里只放训练流程推进必需的真源状态，不继续承接课程展示文案、结果页展示块、页面局部 UI 临时态。
 */
export interface TrainSessionRuntime {
  sessionId: number
  courseCode: string
  trainingType: TrainingType
  currentItemIndex: number
  currentItemStatus: TrainItemStatus
  currentStage: TrainStage
  currentScore: number
  summaryMode: TrainSummaryMode
  pausedAtName: string
  speechRecognizedText: string
  isScoring: boolean
  isSessionLoading: boolean
  isCurrentItemDetailLoading: boolean
  sessionProgressPercent: number
  completedItemCount: number
  totalItemCount: number
  items: TrainingContentItem[]
  updatedAt: number
}

/** 当前训练运行时状态键。 */
export const ACTIVE_SESSION_KEY = 'train.session.runtime'
/** 当前训练会话已完成训练项编码列表键。 */
export const COMPLETED_ITEM_CODES_KEY = 'train.session.completedItemCodes'

/** 创建空训练项。 */
export function createEmptyTrainingItem(): TrainingContentItem {
  return new TrainingContentItem(0, '', '', '', 1, false, 0, 0, '', '', '', '', [], [], [], [], [], [], [])
}

/**
 * 创建空训练运行时。
 * @returns 空训练运行时对象。
 */
export function createEmptyTrainSessionRuntime(): TrainSessionRuntime {
  return {
    sessionId: 0,
    courseCode: '',
    trainingType: 'gesture',
    currentItemIndex: 0,
    currentItemStatus: '',
    currentStage: 'intro',
    currentScore: 0,
    summaryMode: 'paused',
    pausedAtName: '',
    speechRecognizedText: '',
    isScoring: false,
    isSessionLoading: false,
    isCurrentItemDetailLoading: false,
    sessionProgressPercent: 0,
    completedItemCount: 0,
    totalItemCount: 0,
    items: [],
    updatedAt: Date.now()
  }
}

/**
 * 初始化训练会话 Store 默认值。
 */
export function initTrainSessionStore(): void {
  AppStorage.setOrCreate(ACTIVE_SESSION_KEY, createEmptyTrainSessionRuntime())
  AppStorage.setOrCreate(COMPLETED_ITEM_CODES_KEY, [] as string[])
}

/**
 * 读取当前训练运行时。
 * @returns 当前训练运行时对象。
 */
export function readActiveTrainSession(): TrainSessionRuntime {
  return (AppStorage.get(ACTIVE_SESSION_KEY) as TrainSessionRuntime | undefined) ?? createEmptyTrainSessionRuntime()
}

/**
 * 获取当前训练项。
 * @param runtime 可选训练运行时对象。
 * @returns 当前训练项。
 */
export function getCurrentTrainSessionItem(runtime?: TrainSessionRuntime): TrainingContentItem {
  const current = runtime ?? readActiveTrainSession()
  if (current.items.length === 0) return createEmptyTrainingItem()
  const index = Math.min(current.items.length - 1, Math.max(0, current.currentItemIndex))
  return current.items[index]
}

/**
 * 写入完整训练运行时对象。
 * @param runtime 训练运行时对象。
 * @returns 写入后的训练运行时对象。
 */
export function writeActiveTrainSession(runtime: TrainSessionRuntime): TrainSessionRuntime {
  runtime.updatedAt = Date.now()
  AppStorage.setOrCreate(ACTIVE_SESSION_KEY, runtime)
  return runtime
}

/**
 * 以补丁方式更新训练运行时对象。
 * @param patch 训练运行时补丁对象。
 * @returns 更新后的训练运行时对象。
 */
export function patchActiveTrainSession(patch: TrainSessionRuntimePatch): TrainSessionRuntime {
  const current = readActiveTrainSession()
  const next: TrainSessionRuntime = {
    sessionId: patch.sessionId !== undefined ? patch.sessionId : current.sessionId,
    courseCode: patch.courseCode !== undefined ? patch.courseCode : current.courseCode,
    trainingType: patch.trainingType !== undefined ? patch.trainingType : current.trainingType,
    currentItemIndex: patch.currentItemIndex !== undefined ? patch.currentItemIndex : current.currentItemIndex,
    currentItemStatus: patch.currentItemStatus !== undefined ? patch.currentItemStatus : current.currentItemStatus,
    currentStage: patch.currentStage !== undefined ? patch.currentStage : current.currentStage,
    currentScore: patch.currentScore !== undefined ? patch.currentScore : current.currentScore,
    summaryMode: patch.summaryMode !== undefined ? patch.summaryMode : current.summaryMode,
    pausedAtName: patch.pausedAtName !== undefined ? patch.pausedAtName : current.pausedAtName,
    speechRecognizedText: patch.speechRecognizedText !== undefined ? patch.speechRecognizedText : current.speechRecognizedText,
    isScoring: patch.isScoring !== undefined ? patch.isScoring : current.isScoring,
    isSessionLoading: patch.isSessionLoading !== undefined ? patch.isSessionLoading : current.isSessionLoading,
    isCurrentItemDetailLoading: patch.isCurrentItemDetailLoading !== undefined ? patch.isCurrentItemDetailLoading : current.isCurrentItemDetailLoading,
    sessionProgressPercent: patch.sessionProgressPercent !== undefined ? patch.sessionProgressPercent : current.sessionProgressPercent,
    completedItemCount: patch.completedItemCount !== undefined ? patch.completedItemCount : current.completedItemCount,
    totalItemCount: patch.totalItemCount !== undefined ? patch.totalItemCount : current.totalItemCount,
    items: patch.items !== undefined ? patch.items : current.items,
    updatedAt: patch.updatedAt !== undefined ? patch.updatedAt : Date.now()
  }
  return writeActiveTrainSession(next)
}

/**
 * 清空训练运行时对象。
 * @returns 清空后的训练运行时对象。
 */
export function clearActiveTrainSession(): TrainSessionRuntime {
  return writeActiveTrainSession(createEmptyTrainSessionRuntime())
}

/**
 * 设置当前训练阶段。
 * @param stage 目标训练阶段。
 * @returns 更新后的训练运行时对象。
 */
export function setCurrentTrainStage(stage: TrainStage): TrainSessionRuntime {
  return patchActiveTrainSession({ currentStage: stage })
}

/**
 * 读取当前训练会话已完成训练项编码列表。
 * @returns 已完成训练项编码列表。
 */
export function readCompletedTrainItemCodes(): string[] {
  return (AppStorage.get(COMPLETED_ITEM_CODES_KEY) as string[] | undefined) ?? []
}

/**
 * 写入当前训练会话已完成训练项编码列表。
 * @param itemCodes 训练项编码列表。
 */
export function writeCompletedTrainItemCodes(itemCodes: string[]): void {
  AppStorage.setOrCreate(COMPLETED_ITEM_CODES_KEY, [...itemCodes])
}

/**
 * 重置当前训练会话已完成训练项编码列表。
 */
export function resetCompletedTrainItemCodes(): void {
  writeCompletedTrainItemCodes([])
}
