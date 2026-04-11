/**
 * 训练语音本地服务，负责录音相关权限、文件选择与语音练习本地能力。
 */
import common from '@ohos.app.ability.common'
import picker from '@ohos.file.picker'
import { speechRecognizer } from '@kit.CoreSpeechKit'
import { BusinessError } from '@kit.BasicServicesKit'
import { abilityAccessCtrl } from '@kit.AbilityKit'
import { hilog } from '@kit.PerformanceAnalysisKit'
import { getRetryLaterMessage } from '../../../utils/FeedbackCopy'

/**
 * 确保麦克风权限已授予。
 */
export async function ensureMicrophonePermission(context: common.UIAbilityContext | null): Promise<boolean> {
  if (!context) return false
  try {
    const atManager = abilityAccessCtrl.createAtManager()
    const result = await atManager.requestPermissionsFromUser(context, ['ohos.permission.MICROPHONE'])
    return !!result.authResults && result.authResults.length > 0 && result.authResults[0] === 0
  } catch (_error) {
    return false
  }
}

/**
 * 打开系统选择器并返回单个文档 uri。
 */
async function pickSingleDocument(fileSuffixFilters: string[]): Promise<string> {
  const documentPicker = new picker.DocumentViewPicker()
  const documentSelectOptions = new picker.DocumentSelectOptions()
  documentSelectOptions.fileSuffixFilters = fileSuffixFilters
  const result = await documentPicker.select(documentSelectOptions) as Array<string>
  if (!result || result.length === 0) return ''
  return result[0]
}

/** 选择单个视频文件。 */
export async function pickSingleVideoUri(): Promise<string> {
  return await pickSingleDocument(['视频|.mp4,.mov,.m4v,.3gp,.mkv,.webm'])
}

/** 选择单个音频文件。 */
export async function pickSingleAudioUri(): Promise<string> {
  return await pickSingleDocument(['音频|.mp3,.m4a,.aac,.wav,.ogg,.flac'])
}

const SPEECH_LANGUAGE = 'zh-CN'
const MICROPHONE_AUDIO_INFO: speechRecognizer.AudioInfo = {
  audioType: 'pcm',
  sampleRate: 16000,
  soundChannel: 1,
  sampleBit: 16
}
const TRAIN_SUBMIT_TRACE_DOMAIN = 0x0
const TRAIN_SUBMIT_TRACE_TAG = 'TrainSubmitTrace'

/**
 * 语音练习回调集合。
 */
export interface SpeechPracticeCallbacks {
  onPreparingChange?: (isPreparing: boolean) => void
  onReadyChange?: (isReady: boolean) => void
  onListeningChange?: (isListening: boolean) => void
  onStatusTextChange?: (statusText: string) => void
  onRecognitionTextChange?: (recognizedText: string, partialText: string) => void
}

/**
 * 语音练习本地服务，负责语音识别过程控制。
 */
export class SpeechPracticeLocalService {
  private getAbilityContext?: () => common.BaseContext | undefined
  private callbacks: SpeechPracticeCallbacks
  private speechEngine: speechRecognizer.SpeechRecognitionEngine | undefined = undefined
  private speechSessionId: string = ''
  private isSpeechPreparing: boolean = false
  private isSpeechEngineReady: boolean = false
  private isSpeechListening: boolean = false
  private shouldAutoStart: boolean = false

  constructor(getAbilityContext?: () => common.BaseContext | undefined, callbacks: SpeechPracticeCallbacks = {}) {
    this.getAbilityContext = getAbilityContext
    this.callbacks = callbacks
  }

  private traceTrainSubmit(stage: string, message: string): void {
    hilog.info(TRAIN_SUBMIT_TRACE_DOMAIN, TRAIN_SUBMIT_TRACE_TAG, '[%{public}s] %{public}s', stage, message)
  }

  private setPreparing(nextValue: boolean) {
    this.isSpeechPreparing = nextValue
    this.callbacks.onPreparingChange?.(nextValue)
  }

  private setReady(nextValue: boolean) {
    this.isSpeechEngineReady = nextValue
    this.callbacks.onReadyChange?.(nextValue)
  }

  private setListening(nextValue: boolean) {
    this.isSpeechListening = nextValue
    this.callbacks.onListeningChange?.(nextValue)
  }

  private setStatus(nextValue: string) {
    this.callbacks.onStatusTextChange?.(nextValue)
  }

  private setRecognition(recognizedText: string, partialText: string) {
    this.callbacks.onRecognitionTextChange?.(recognizedText, partialText)
  }

  private bindSpeechListener() {
    if (!this.speechEngine) return
    const listener: speechRecognizer.RecognitionListener = {
      onStart: (_sessionId: string, _eventMessage: string) => {
        this.traceTrainSubmit('speech.onStart', 'listener started')
        this.setRecognition('', '')
        this.setStatus('正在监听，请直接说出练习内容。')
      },
      onEvent: (_sessionId: string, _eventCode: number, _eventMessage: string) => {},
      onResult: (_sessionId: string, result: speechRecognizer.SpeechRecognitionResult) => {
        const text = result.result ?? ''
        this.traceTrainSubmit('speech.onResult', `textLength=${text.trim().length},text=${text}`)
        this.setRecognition(text, text)
      },
      onComplete: (_sessionId: string, _eventMessage: string) => {
        this.traceTrainSubmit('speech.onComplete', 'listener completed')
        this.setListening(false)
        this.speechSessionId = ''
        this.setStatus('识别完成，确认文本后可直接评分。')
      },
      onError: (_sessionId: string, errorCode: number, errorMessage: string) => {
        this.traceTrainSubmit('speech.onError', `errorCode=${errorCode},message=${errorMessage}`)
        this.setListening(false)
        this.speechSessionId = ''
        this.setStatus(getRetryLaterMessage('语音识别'))
      }
    }
    this.speechEngine.setListener(listener)
  }

  private createSpeechEngine() {
    if (this.isSpeechPreparing) return
    try {
      this.speechEngine?.shutdown()
    } catch (_error) {}
    this.setPreparing(true)
    this.setReady(false)
    this.setStatus('正在初始化语音识别...')
    const createParams: speechRecognizer.CreateEngineParams = {
      language: SPEECH_LANGUAGE,
      online: 1,
      extraParams: { locate: 'CN', recognizerMode: 'short' }
    }
    speechRecognizer.createEngine(createParams, (err: BusinessError, engine: speechRecognizer.SpeechRecognitionEngine) => {
      this.setPreparing(false)
      if (err) {
        this.traceTrainSubmit('speech.createEngine.error', JSON.stringify(err))
        this.setStatus(getRetryLaterMessage('初始化语音识别'))
        this.shouldAutoStart = false
        return
      }
      this.speechEngine = engine
      this.bindSpeechListener()
      this.setReady(true)
      this.setStatus('识别引擎已就绪，点击开始识别后直接说话。')
      if (this.shouldAutoStart) {
        this.shouldAutoStart = false
        void this.startListening()
      }
    })
  }

  async startListening(): Promise<void> {
    this.traceTrainSubmit('speech.startListening.enter', `ready=${this.isSpeechEngineReady},preparing=${this.isSpeechPreparing}`)
    const hasPermission = await ensureMicrophonePermission(this.getAbilityContext?.() as common.UIAbilityContext | null)
    if (!hasPermission) {
      this.traceTrainSubmit('speech.startListening.blocked', 'no microphone permission')
      this.setStatus('未获得麦克风权限，无法开始识别。')
      return
    }
    if (this.isSpeechPreparing) return
    if (!this.isSpeechEngineReady || !this.speechEngine) {
      this.shouldAutoStart = true
      this.createSpeechEngine()
      return
    }
    this.shouldAutoStart = false
    this.speechSessionId = `${Date.now()}`
    try {
      this.speechEngine.startListening({
        sessionId: this.speechSessionId,
        audioInfo: MICROPHONE_AUDIO_INFO,
        extraParams: { recognitionMode: 0, vadBegin: 2000, vadEnd: 3000, maxAudioDuration: 60000 }
      })
      this.traceTrainSubmit('speech.startListening.started', `sessionId=${this.speechSessionId}`)
      this.setListening(true)
      this.setStatus('正在监听，请直接说出练习内容。')
    } catch (_err) {
      this.traceTrainSubmit('speech.startListening.error', 'startListening throw')
      this.setListening(false)
      this.setStatus(getRetryLaterMessage('开始语音识别'))
    }
  }

  stopListening(): void {
    if (!this.speechEngine || this.speechSessionId.length === 0 || !this.isSpeechListening) return
    try {
      this.traceTrainSubmit('speech.stopListening.enter', `sessionId=${this.speechSessionId}`)
      this.speechEngine.finish(this.speechSessionId)
      this.setListening(false)
      this.setStatus('正在停止识别，等待最终结果...')
    } catch (_err) {
      this.traceTrainSubmit('speech.stopListening.error', 'finish throw')
      this.setListening(false)
      this.setStatus(getRetryLaterMessage('停止语音识别'))
    }
  }

  dispose(): void {
    try {
      this.speechEngine?.shutdown()
    } catch (_error) {}
    this.speechEngine = undefined
    this.speechSessionId = ''
    this.setReady(false)
    this.setPreparing(false)
    this.setListening(false)
    this.shouldAutoStart = false
  }
}
