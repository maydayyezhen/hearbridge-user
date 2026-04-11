/**
 * 训练页页面服务，负责为页面层提供统一的动作门面。
 */
import common from '@ohos.app.ability.common'
import { TrainStage } from '../../repository/train-session/TrainSessionRepository'
import { PracticeMode, TrainingType } from '../../domain/static/train/TrainingRuntimeTypes'
import { toggleCourseFavoriteAction } from '../user/local/UserFavoriteLocalService'
import { clearTrainResultViewState } from '../../repository/train-session/TrainResultViewStateRepository'
import { clearTrainSessionViewState } from '../../repository/train-session/TrainSessionViewStateRepository'
import {
  buildTrainPageSpeechCallbacks,
  createTrainPageSpeechPracticeService,
  jumpTrainPageToItem,
  moveTrainPageBackward,
  moveTrainPageForward,
  openTrainPageAudioPicker,
  openTrainPageVideoPicker,
  pauseTrainPage,
  prepareTrainPageStage,
  restartTrainPagePracticeWithNewSession,
  submitTrainPagePractice,
  switchTrainPageStage,
  syncPracticeModeByRuntime,
  syncTrainPagePracticeMode,
  toggleTrainPageCourseFavorite,
  toggleTrainPageItemFavorite
} from './local/TrainPageLocalService'
import { createEmptyTrainSessionSummaryViewData, loadTrainSessionSummary } from './local/TrainSummaryLocalService'
import { TrainSessionRouteInput } from './local/TrainSessionBootstrapContextLocalService'
import { clearTrainPageExitRuntime } from './local/TrainPageQueryLocalService'
import { SpeechPracticeCallbacks, SpeechPracticeLocalService } from './local/TrainSpeechLocalService'
import { TrainSessionSummaryViewData } from './model/TrainSessionSummaryViewData'

let pendingExitStateClearTimer: number = -1

function clearPendingExitStateClearTimer(): void {
  if (pendingExitStateClearTimer !== -1) {
    clearTimeout(pendingExitStateClearTimer)
    pendingExitStateClearTimer = -1
  }
}

export async function preparePageStage(context: common.BaseContext | undefined, routeInput: TrainSessionRouteInput, stage: TrainStage): Promise<void> {
  clearPendingExitStateClearTimer()
  await prepareTrainPageStage(context, routeInput, stage)
}

export async function moveForward(context: common.BaseContext | undefined, routeInput: TrainSessionRouteInput): Promise<void> {
  await moveTrainPageForward(context, routeInput)
}

export async function moveBackward(context: common.BaseContext | undefined, routeInput: TrainSessionRouteInput): Promise<void> {
  await moveTrainPageBackward(context, routeInput)
}

export async function switchStage(context: common.BaseContext | undefined, routeInput: TrainSessionRouteInput, stage: TrainStage): Promise<void> {
  await switchTrainPageStage(context, routeInput, stage)
}

export async function restartPracticeSession(context: common.BaseContext | undefined, routeInput: TrainSessionRouteInput): Promise<void> {
  clearPendingExitStateClearTimer()
  await restartTrainPagePracticeWithNewSession(context, routeInput)
}

export async function submitPractice(
  context: common.BaseContext | undefined,
  routeInput: TrainSessionRouteInput,
  practiceMode: PracticeMode,
  speechPartialText: string,
  recordedAudioUri: string,
  recordedVideoUri: string
): Promise<void> {
  clearPendingExitStateClearTimer()
  await submitTrainPagePractice(
    context,
    routeInput,
    practiceMode,
    speechPartialText,
    recordedAudioUri,
    recordedVideoUri
  )
}

export async function pause(context: common.BaseContext | undefined, routeInput: TrainSessionRouteInput): Promise<void> {
  clearPendingExitStateClearTimer()
  await pauseTrainPage(context, routeInput)
}

export async function jumpToItem(context: common.BaseContext | undefined, itemId: number): Promise<boolean> {
  clearPendingExitStateClearTimer()
  return await jumpTrainPageToItem(context, itemId)
}

export async function toggleCourseFavorite(
  context: common.BaseContext | undefined,
  courseCode: string,
  courseName: string = '',
  trainingType?: TrainingType
) {
  if (courseName.length > 0 || trainingType !== undefined) {
    return await toggleCourseFavoriteAction(courseCode, courseName, trainingType)
  }
  return await toggleTrainPageCourseFavorite(context, courseCode)
}

export async function toggleItemFavorite(
  context: common.BaseContext | undefined,
  itemCode: string,
  itemName: string = '',
  courseCode: string = '',
  courseName: string = '',
  trainingType?: TrainingType
) {
  return await toggleTrainPageItemFavorite(context, itemCode, itemName, courseCode, courseName, trainingType)
}

export function syncPracticeMode(currentMode: PracticeMode): PracticeMode {
  return syncTrainPagePracticeMode(currentMode)
}

export function syncPracticeModeWithType(trainingType: TrainingType, currentMode: PracticeMode): PracticeMode {
  return syncPracticeModeByRuntime(trainingType, currentMode)
}

export function buildSpeechCallbacks(
  onPreparingChange: (isPreparing: boolean) => void,
  onReadyChange: (isReady: boolean) => void,
  onListeningChange: (isListening: boolean) => void
): SpeechPracticeCallbacks {
  return buildTrainPageSpeechCallbacks(onPreparingChange, onReadyChange, onListeningChange)
}

export function createSpeechPracticeService(
  getAbilityContext: () => common.BaseContext | undefined,
  callbacks: SpeechPracticeCallbacks
): SpeechPracticeLocalService {
  return createTrainPageSpeechPracticeService(getAbilityContext, callbacks)
}

export async function openVideoPicker(): Promise<string> {
  clearPendingExitStateClearTimer()
  return await openTrainPageVideoPicker()
}

export async function openAudioPicker(): Promise<string> {
  clearPendingExitStateClearTimer()
  return await openTrainPageAudioPicker()
}

export async function loadSummary(sessionId: number): Promise<TrainSessionSummaryViewData> {
  return await loadTrainSessionSummary(sessionId)
}

export function createEmptySummary(): TrainSessionSummaryViewData {
  return createEmptyTrainSessionSummaryViewData()
}

/**
 * 清理训练页退出态，但保留课程继续练习快照。
 */
export function clearExitState(): void {
  clearPendingExitStateClearTimer()
  clearTrainResultViewState()
  clearTrainSessionViewState()
  clearTrainPageExitRuntime()
}

export function clearExitStateLater(delayMs: number = 180): void {
  clearPendingExitStateClearTimer()
  pendingExitStateClearTimer = setTimeout(() => {
    pendingExitStateClearTimer = -1
    clearExitState()
  }, delayMs)
}

export {
  SpeechPracticeCallbacks,
  SpeechPracticeLocalService,
  TrainSessionSummaryViewData,
  TrainSessionRouteInput
}
