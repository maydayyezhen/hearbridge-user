/**
 * 训练页本地服务，负责训练页阶段切换、前进后退、暂停提交与本地文件选择流程。
 */
import common from '@ohos.app.ability.common'
import { hilog } from '@kit.PerformanceAnalysisKit'
import { applyCompletedTrainingItemProgress } from '../../user/local/UserTrainingProgressLocalService'
import { PracticeMode, TrainingType } from '../../../domain/static/train/TrainingRuntimeTypes'
import { FavoriteToggleActionResult, toggleCourseFavoriteAction, toggleTrainingItemFavoriteAction } from '../../user/local/UserFavoriteLocalService'
import { createTrainSessionRouteInput, TrainSessionRouteInput, ensureCurrentItemDetail, ensureStagePageReady } from './TrainSessionBootstrapLocalService'
import {
  clearTrainSessionRuntime,
  getCurrentTrainSessionItem,
  markTrainSessionCompleted,
  moveToNextTrainItem,
  moveToPreviousTrainItem,
  patchActiveTrainSession,
  readActiveTrainSession,
  setCurrentTrainStage,
  TrainSessionRuntime,
  TrainStage
} from '../../../repository/train-session/TrainSessionRepository'
import { clearTrainResultViewState } from '../../../repository/train-session/TrainResultViewStateRepository'
import { resetTrainSessionTransientViewState } from './TrainSessionViewStateService'
import { patchTrainSessionViewState } from '../../../repository/train-session/TrainSessionViewStateRepository'
import {
  completeTrainSessionRemote,
  pauseTrainSessionRemote,
  submitTrainPracticeByFile,
  submitTrainPracticeBySpeech
} from './TrainSessionSubmitFlowLocalService'
import { pickSingleAudioUri, pickSingleVideoUri, SpeechPracticeCallbacks, SpeechPracticeLocalService } from './TrainSpeechLocalService'
import { normalizePracticeMode, normalizeTrainItemStatus } from '../../../utils/TrainingTypeUtil'
import { getNextTrainStage, getPreviousTrainStage } from './TrainStageLocalService'
import { syncCourseSessionCacheFromRuntime } from '../cache/TrainSessionCacheService'

const TRAIN_SUBMIT_TRACE_DOMAIN = 0x0
const TRAIN_SUBMIT_TRACE_TAG = 'TrainSubmitTrace'

/**
 * 进入下一训练项；若已是最后一项则切到总结态。
 */
function moveToNextItemOrSummary(runtime?: TrainSessionRuntime): TrainStage {
  const current = runtime ?? readActiveTrainSession()
  if (current.currentItemIndex >= current.items.length - 1) {
    markTrainSessionCompleted()
    syncCourseSessionCacheFromRuntime(readActiveTrainSession())
    return 'summary'
  }
  moveToNextTrainItem()
  resetTrainSessionTransientViewState()
  clearTrainResultViewState()
  syncCourseSessionCacheFromRuntime(readActiveTrainSession())
  return 'intro'
}

/**
 * 回到上一训练项的 intro；若已是第一项则仍停留 intro。
 */
function moveToPreviousItemOrIntro(runtime?: TrainSessionRuntime): TrainStage {
  const current = runtime ?? readActiveTrainSession()
  if (current.currentItemIndex <= 0) {
    syncCourseSessionCacheFromRuntime(readActiveTrainSession())
    return 'intro'
  }
  moveToPreviousTrainItem()
  resetTrainSessionTransientViewState()
  clearTrainResultViewState()
  syncCourseSessionCacheFromRuntime(readActiveTrainSession())
  return 'intro'
}

/**
 * 为训练页构造语音识别回调集合。
 */
export function buildTrainPageSpeechCallbacks(
  onPreparingChange: (isPreparing: boolean) => void,
  onReadyChange: (isReady: boolean) => void,
  onListeningChange: (isListening: boolean) => void
): SpeechPracticeCallbacks {
  return {
    onPreparingChange,
    onReadyChange,
    onListeningChange,
    onStatusTextChange: (statusText: string): void => { patchTrainSessionViewState({ speechStatusText: statusText }) },
    onRecognitionTextChange: (recognizedText: string, partialText: string): void => {
      hilog.info(TRAIN_SUBMIT_TRACE_DOMAIN, TRAIN_SUBMIT_TRACE_TAG, '[%{public}s] %{public}s',
        'speech.storePatch',
        `recognized=${recognizedText.trim().length > 0},partial=${partialText.trim().length > 0}`)
      patchActiveTrainSession({ speechRecognizedText: recognizedText })
      patchTrainSessionViewState({ speechPartialText: partialText })
    }
  }
}

/**
 * 创建训练页语音识别本地服务。
 */
export function createTrainPageSpeechPracticeService(
  getAbilityContext: () => common.BaseContext | undefined,
  callbacks: SpeechPracticeCallbacks
): SpeechPracticeLocalService {
  return new SpeechPracticeLocalService(getAbilityContext, callbacks)
}

/**
 * 切换训练课程收藏状态，并返回由页面层承接的反馈结果。
 */
export async function toggleTrainPageCourseFavorite(_context: common.BaseContext | undefined, courseCode: string): Promise<FavoriteToggleActionResult> {
  return await toggleCourseFavoriteAction(courseCode)
}

export async function toggleTrainPageItemFavorite(
  _context: common.BaseContext | undefined,
  itemCode: string,
  itemName: string = '',
  courseCode: string = '',
  courseName: string = '',
  trainingType?: TrainingType
): Promise<FavoriteToggleActionResult> {
  return await toggleTrainingItemFavoriteAction(itemCode, itemName, courseCode, courseName, trainingType)
}

/**
 * 跳转到指定训练项并预热详情。
 */
export async function jumpTrainPageToItem(context: common.BaseContext | undefined, itemId: number): Promise<boolean> {
  const runtime = readActiveTrainSession()
  let targetIndex = -1
  for (let i = 0; i < runtime.items.length; i += 1) {
    if (runtime.items[i].id === itemId) {
      targetIndex = i
      break
    }
  }
  if (targetIndex < 0) return false
  const targetItemStatus = normalizeTrainItemStatus(runtime.items[targetIndex].status)
  patchActiveTrainSession({
    currentItemIndex: targetIndex,
    currentItemStatus: targetItemStatus === 'completed' ? 'completed' : 'in_progress',
    currentStage: 'intro'
  })
  resetTrainSessionTransientViewState()
  clearTrainResultViewState()
  syncCourseSessionCacheFromRuntime(readActiveTrainSession())
  const routeInput = createTrainSessionRouteInput()
  await ensureCurrentItemDetail(context, routeInput)
  return true
}

/**
 * 根据训练类型同步练习模式。
 */
export function syncPracticeModeByRuntime(trainingType: TrainingType, currentMode: PracticeMode): PracticeMode {
  return normalizePracticeMode(currentMode, trainingType)
}

/**
 * 预热训练页指定阶段所需数据。
 */
export async function prepareTrainPageStage(context: common.BaseContext | undefined, routeInput: TrainSessionRouteInput, stage: TrainStage): Promise<void> {
  const runtime = await ensureStagePageReady(context, routeInput, stage)
  if (runtime.currentStage === 'summary' && runtime.summaryMode === 'completed') {
    await completeTrainSessionRemote(context)
  }
}

/**
 * 切换训练页阶段。
 */
export async function switchTrainPageStage(context: common.BaseContext | undefined, routeInput: TrainSessionRouteInput, stage: TrainStage): Promise<void> {
  setCurrentTrainStage(stage)
  syncCourseSessionCacheFromRuntime(readActiveTrainSession())
  await prepareTrainPageStage(context, routeInput, stage)
}

/**
 * 在结果页重新开始当前训练项，并强制创建新的训练会话。
 */
export async function restartTrainPagePracticeWithNewSession(
  context: common.BaseContext | undefined,
  routeInput: TrainSessionRouteInput
): Promise<void> {
  const current = readActiveTrainSession()
  const currentItem = getCurrentTrainSessionItem(current)
  const targetCourseCode = routeInput.courseCode.trim().length > 0 ? routeInput.courseCode : current.courseCode
  const targetItemCode = currentItem.code.trim().length > 0 ? currentItem.code : routeInput.itemCode
  clearTrainSessionRuntime()
  resetTrainSessionTransientViewState()
  clearTrainResultViewState()
  await prepareTrainPageStage(
    context,
    createTrainSessionRouteInput(targetCourseCode, targetItemCode, 'practice'),
    'practice'
  )
}

/**
 * 推进训练页到下一个阶段或训练项。
 */
export async function moveTrainPageForward(context: common.BaseContext | undefined, routeInput: TrainSessionRouteInput): Promise<void> {
  const current = readActiveTrainSession()
  if (current.currentStage === 'result') {
    const targetStage = moveToNextItemOrSummary(current)
    const nextRuntime = readActiveTrainSession()
    const nextItem = getCurrentTrainSessionItem(nextRuntime)
    const nextRouteInput = createTrainSessionRouteInput(routeInput.courseCode, nextItem.code, targetStage)
    await prepareTrainPageStage(context, nextRouteInput, targetStage)
    if (targetStage !== 'summary') {
      await ensureCurrentItemDetail(context, nextRouteInput)
    }
    return
  }
  const nextStage = getNextTrainStage(current)
  await switchTrainPageStage(context, routeInput, nextStage)
}

/**
 * 回退训练页到上一个阶段。
 */
export async function moveTrainPageBackward(context: common.BaseContext | undefined, routeInput: TrainSessionRouteInput): Promise<void> {
  const current = readActiveTrainSession()
  if (current.currentStage === 'intro') {
    const targetStage = moveToPreviousItemOrIntro(current)
    const nextRuntime = readActiveTrainSession()
    const nextItem = getCurrentTrainSessionItem(nextRuntime)
    const nextRouteInput = createTrainSessionRouteInput(routeInput.courseCode, nextItem.code, targetStage)
    await prepareTrainPageStage(context, nextRouteInput, targetStage)
    await ensureCurrentItemDetail(context, nextRouteInput)
    return
  }
  const previousStage = getPreviousTrainStage(current)
  await switchTrainPageStage(context, routeInput, previousStage)
}

/**
 * 暂停当前训练页对应的会话。
 */
export async function pauseTrainPage(context: common.BaseContext | undefined, routeInput: TrainSessionRouteInput): Promise<void> {
  await pauseTrainSessionRemote(context)
  syncCourseSessionCacheFromRuntime(readActiveTrainSession())
  await prepareTrainPageStage(context, routeInput, 'summary')
}

/**
 * 提交训练页当前练习。
 */
export async function submitTrainPagePractice(
  context: common.BaseContext | undefined,
  routeInput: TrainSessionRouteInput,
  practiceMode: PracticeMode,
  speechPartialText: string,
  recordedAudioUri: string,
  recordedVideoUri: string
): Promise<void> {
  const current = readActiveTrainSession()
  const itemCode = getCurrentTrainSessionItem(current).code
  let submitRuntime = current
  patchActiveTrainSession({ isScoring: true })
  try {
    if (current.trainingType === 'speech' && practiceMode === 'audio') {
      if (current.speechRecognizedText.trim().length > 0) {
        submitRuntime = await submitTrainPracticeBySpeech(context, current.speechRecognizedText, speechPartialText)
      } else {
        submitRuntime = await submitTrainPracticeByFile(context, recordedAudioUri, true)
      }
    } else {
      submitRuntime = await submitTrainPracticeByFile(context, recordedVideoUri, false)
    }

    if (submitRuntime.currentStage !== 'result') {
      return
    }

    if (itemCode.length > 0) {
      applyCompletedTrainingItemProgress(itemCode)
    }
    await prepareTrainPageStage(context, routeInput, 'result')
  } finally {
    if (readActiveTrainSession().currentStage !== 'result') {
      patchActiveTrainSession({ isScoring: false })
    }
  }
}

/**
 * 打开视频选择器并回写训练页视图状态。
 */
export async function openTrainPageVideoPicker(): Promise<string> {
  patchTrainSessionViewState({ trainingTip: '', speechStatusText: '正在打开视频选择...' })
  try {
    const selectedUri = await pickSingleVideoUri()
    if (selectedUri.length > 0) {
      patchTrainSessionViewState({ speechStatusText: '视频已就位，预览后继续评分。' })
      return selectedUri
    }
    return ''
  } catch (_error) {
    patchTrainSessionViewState({ trainingTip: '这次没选成功，再试一次就好。' })
    return ''
  }
}

/**
 * 打开音频选择器并回写训练页视图状态。
 */
export async function openTrainPageAudioPicker(): Promise<string> {
  patchTrainSessionViewState({ trainingTip: '', speechStatusText: '正在打开音频选择...' })
  try {
    const selectedUri = await pickSingleAudioUri()
    if (selectedUri.length > 0) {
      patchTrainSessionViewState({ speechStatusText: '音频已就位，可以直接提交评分。' })
      return selectedUri
    }
    return ''
  } catch (_error) {
    patchTrainSessionViewState({ trainingTip: '这次没选成功，再试一次就好。' })
    return ''
  }
}

/**
 * 根据当前运行时同步训练页练习模式。
 */
export function syncTrainPagePracticeMode(currentMode: PracticeMode): PracticeMode {
  return syncPracticeModeByRuntime(readActiveTrainSession().trainingType, currentMode)
}
