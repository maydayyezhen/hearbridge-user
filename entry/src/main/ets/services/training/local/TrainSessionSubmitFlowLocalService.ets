/**
 * 训练会话提交流程本地服务，负责暂停、完成、文件提交与语音提交后的状态同步。
 */
import common from '@ohos.app.ability.common'
import {
  completeTrainSession,
  pauseTrainSession,
  submitTrainFilePractice,
  submitTrainSpeechPractice,
  SubmitTrainingItemResponseSource
} from '../api/TrainSessionApiService'
import { TrainingContentItem } from '../../../domain/static/train/TrainingContentModels'
import {
  getCurrentTrainSessionItem,
  markTrainSessionCompleted,
  markTrainSessionPaused,
  patchActiveTrainSession,
  readActiveTrainSession,
  TrainSessionRuntime
} from '../../../repository/train-session/TrainSessionRepository'
import { getPendingMessage, getRetryLaterMessage } from '../../../utils/FeedbackCopy'
import { patchTrainSessionViewState } from '../../../repository/train-session/TrainSessionViewStateRepository'
import { applyTrainSessionSubmissionState } from './TrainSessionSubmissionStateLocalService'
import { applyLifecycleResult, hasVideo } from './TrainSessionLifecycleLocalService'
import { resolvePracticeUploadPayload, uploadPracticeResource } from './TrainPracticeUploadLocalService'

/**
 * 从通用对象中安全获取 AbilityContext。
 */
function getAbilityContext(context?: common.BaseContext): common.BaseContext | null {
  return context ?? null
}

/**
 * 提交语音识别型练习载荷。
 */
async function submitPracticeSpeechPayload(
  runtime: TrainSessionRuntime,
  item: TrainingContentItem,
  recognizedText: string,
  partialText: string
): Promise<SubmitTrainingItemResponseSource | null> {
  const wasCompletedBeforeSubmit = item.status === 'completed'
  const submitResult = await submitTrainSpeechPractice(
    runtime.sessionId,
    item.code,
    recognizedText,
    partialText,
    hasVideo(item),
    true,
    wasCompletedBeforeSubmit,
    !wasCompletedBeforeSubmit
  )
  if (!submitResult.ok || !submitResult.data) {
    patchTrainSessionViewState({
      trainingTip: submitResult.message.length > 0 ? submitResult.message : getRetryLaterMessage('生成训练评分')
    })
    patchActiveTrainSession({ isScoring: false })
    return null
  }
  return submitResult.data
}

/**
 * 成功提交后统一应用评分结果。
 */
function applyPracticeSubmitResult(
  runtime: TrainSessionRuntime,
  submitData: SubmitTrainingItemResponseSource,
  partialText: string,
  recognizedText: string
): TrainSessionRuntime {
  return applyTrainSessionSubmissionState(runtime, submitData, partialText, recognizedText)
}

/**
 * 暂停训练会话并同步运行时状态。
 */
export async function pauseTrainSessionRemote(contextObj: common.BaseContext | undefined): Promise<TrainSessionRuntime> {
  const abilityContext = getAbilityContext(contextObj)
  const runtime = readActiveTrainSession()
  const currentItem = getCurrentTrainSessionItem(runtime)
  if (!abilityContext || runtime.sessionId <= 0) return markTrainSessionPaused(currentItem.name)
  const result = await pauseTrainSession(runtime.sessionId)
  if (result.ok && result.data) {
    return applyLifecycleResult(runtime, 'paused', result.data.progressPercent, currentItem.name)
  }
  return markTrainSessionPaused(currentItem.name)
}

/**
 * 完成训练会话并同步运行时状态。
 */
export async function completeTrainSessionRemote(contextObj: common.BaseContext | undefined): Promise<TrainSessionRuntime> {
  const abilityContext = getAbilityContext(contextObj)
  const runtime = readActiveTrainSession()
  if (!abilityContext || runtime.sessionId <= 0) return markTrainSessionCompleted()
  const result = await completeTrainSession(runtime.sessionId)
  if (result.ok && result.data) {
    return applyLifecycleResult(runtime, 'completed', result.data.progressPercent)
  }
  return markTrainSessionCompleted()
}

/**
 * 使用文件提交训练练习。
 */
export async function submitTrainPracticeByFile(contextObj: common.BaseContext | undefined, fileUri: string, useAudioMode: boolean): Promise<TrainSessionRuntime> {
  const abilityContext = getAbilityContext(contextObj)
  let runtime = readActiveTrainSession()
  const item = getCurrentTrainSessionItem(runtime)
  if (!abilityContext || runtime.sessionId <= 0 || item.code.length === 0) {
    patchTrainSessionViewState({ trainingTip: getRetryLaterMessage('准备训练会话') })
    return runtime
  }
  if (fileUri.length === 0) {
    patchTrainSessionViewState({ trainingTip: useAudioMode ? '请先选择音频文件。' : '请先选择视频文件。' })
    return runtime
  }

  patchActiveTrainSession({ isScoring: true })
  patchTrainSessionViewState({ trainingTip: getPendingMessage('上传练习文件') })
  const payload = await resolvePracticeUploadPayload(abilityContext, runtime, fileUri, useAudioMode)
  const uploadedUrl = await uploadPracticeResource(payload)
  if (uploadedUrl.length === 0) {
    patchTrainSessionViewState({ trainingTip: getRetryLaterMessage('上传练习文件') })
    return patchActiveTrainSession({ isScoring: false })
  }

  const submitData = await submitTrainFilePractice(
    runtime.sessionId,
    item.code,
    payload.submitType,
    uploadedUrl,
    payload.fileName,
    payload.mimeType,
    hasVideo(item),
    true,
    item.status === 'completed',
    item.status !== 'completed'
  )
  if (!submitData.ok || !submitData.data) {
    patchTrainSessionViewState({
      trainingTip: submitData.message.length > 0 ? submitData.message : getRetryLaterMessage('生成训练评分')
    })
    return patchActiveTrainSession({ isScoring: false })
  }

  runtime = readActiveTrainSession()
  return applyPracticeSubmitResult(runtime, submitData.data, '', runtime.speechRecognizedText)
}

/**
 * 使用语音识别文本提交训练练习。
 */
export async function submitTrainPracticeBySpeech(contextObj: common.BaseContext | undefined, recognizedText: string, partialText: string): Promise<TrainSessionRuntime> {
  const abilityContext = getAbilityContext(contextObj)
  const runtime = readActiveTrainSession()
  const item = getCurrentTrainSessionItem(runtime)
  if (!abilityContext || runtime.sessionId <= 0 || item.code.length === 0) {
    patchTrainSessionViewState({ trainingTip: getRetryLaterMessage('准备训练会话') })
    return runtime
  }
  if (recognizedText.trim().length === 0) {
    patchTrainSessionViewState({ trainingTip: '请先完成一次语音识别，再进行评分。' })
    return runtime
  }

  patchActiveTrainSession({ isScoring: true })
  patchTrainSessionViewState({ trainingTip: getPendingMessage('生成评分结果') })
  const submitData = await submitPracticeSpeechPayload(runtime, item, recognizedText, partialText)
  if (!submitData) {
    return readActiveTrainSession()
  }
  return applyPracticeSubmitResult(runtime, submitData, partialText, recognizedText)
}
