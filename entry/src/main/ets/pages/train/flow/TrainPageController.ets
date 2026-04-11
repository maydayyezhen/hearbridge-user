/**
 * TrainPageController 文件，负责训练页内部 UI glue 与页面动作编排。
 */
import common from '@ohos.app.ability.common'
import { hilog } from '@kit.PerformanceAnalysisKit'
import {
  SpeechPracticeLocalService,
  TrainPageService,
  TrainSessionRouteInput,
  TrainStage
} from '../../../services/training/index'
import { PracticeMode } from '../../../domain/static/train/TrainingRuntimeTypes'
import { buildTrainPageRouteInput } from './TrainPageRouteAdapter'

const TRAIN_SUBMIT_TRACE_DOMAIN = 0x0
const TRAIN_SUBMIT_TRACE_TAG = 'TrainSubmitTrace'

export interface TrainPageControllerBindings {
  getAbilityContext: () => common.BaseContext
  getRoutePath: () => string
  getCourseCode: () => string
  getItemCode: () => string
  getCurrentStage: () => TrainStage
  getPracticeMode: () => PracticeMode
  setPracticeMode: (mode: PracticeMode) => void
  clearSelectedPracticeMedia: () => void
  onSpeechPreparingChange: (isPreparing: boolean) => void
  onSpeechReadyChange: (isReady: boolean) => void
  onSpeechListeningChange: (isListening: boolean) => void
  onVideoUriChange: (uri: string) => void
  onAudioUriChange: (uri: string) => void
}

export class TrainPageController {
  private readonly bindings: TrainPageControllerBindings
  private speechPracticeService?: SpeechPracticeLocalService
  private isLaunchingVideoCapture: boolean = false
  private isLaunchingAudioCapture: boolean = false

  constructor(bindings: TrainPageControllerBindings) {
    this.bindings = bindings
  }

  private buildCurrentRouteInput(stage?: TrainStage): TrainSessionRouteInput {
    const routeInput = buildTrainPageRouteInput(this.bindings.getRoutePath(), stage)
    const currentCourseCode = this.bindings.getCourseCode().trim()
    const currentItemCode = this.bindings.getItemCode().trim()
    return {
      courseCode: currentCourseCode.length > 0 ? currentCourseCode : routeInput.courseCode,
      itemCode: currentItemCode.length > 0 ? currentItemCode : routeInput.itemCode,
      stage: routeInput.stage
    }
  }

  async moveForward(): Promise<void> {
    await this.runStageAction(() => TrainPageService.moveForward(
      this.bindings.getAbilityContext(),
      this.buildCurrentRouteInput(this.bindings.getCurrentStage())
    ))
  }

  async moveBackward(): Promise<void> {
    await this.runStageAction(() => TrainPageService.moveBackward(
      this.bindings.getAbilityContext(),
      this.buildCurrentRouteInput(this.bindings.getCurrentStage())
    ))
  }

  async pause(): Promise<void> {
    await this.runStageAction(() => TrainPageService.pause(
      this.bindings.getAbilityContext(),
      this.buildCurrentRouteInput(this.bindings.getCurrentStage())
    ))
  }

  async switchStage(stage: TrainStage): Promise<void> {
    await this.runStageAction(() => TrainPageService.switchStage(
      this.bindings.getAbilityContext(),
      this.buildCurrentRouteInput(stage),
      stage
    ))
  }

  async restartPracticeSession(): Promise<void> {
    await this.runStageAction(() => TrainPageService.restartPracticeSession(
      this.bindings.getAbilityContext(),
      this.buildCurrentRouteInput('practice')
    ))
  }

  async submitPractice(speechPartialText: string, recordedAudioUri: string, recordedVideoUri: string): Promise<void> {
    hilog.info(TRAIN_SUBMIT_TRACE_DOMAIN, TRAIN_SUBMIT_TRACE_TAG, '[%{public}s] %{public}s',
      'controller.submitPractice.enter',
      `stage=${this.bindings.getCurrentStage()},mode=${this.bindings.getPracticeMode()},partial=${speechPartialText.trim().length > 0},audioUri=${recordedAudioUri.length > 0},videoUri=${recordedVideoUri.length > 0}`)
    await this.runStageAction(() => TrainPageService.submitPractice(
      this.bindings.getAbilityContext(),
      this.buildCurrentRouteInput(this.bindings.getCurrentStage()),
      this.bindings.getPracticeMode(),
      speechPartialText,
      recordedAudioUri,
      recordedVideoUri
    ))
    hilog.info(TRAIN_SUBMIT_TRACE_DOMAIN, TRAIN_SUBMIT_TRACE_TAG, '[%{public}s] %{public}s',
      'controller.submitPractice.return',
      `stage=${this.bindings.getCurrentStage()}`)
  }

  syncPracticeModeWithRuntime(): void {
    this.bindings.setPracticeMode(TrainPageService.syncPracticeMode(this.bindings.getPracticeMode()))
  }

  async runStageAction(action: () => Promise<void>): Promise<void> {
    await action()
    const nextStage = this.bindings.getCurrentStage()
    if (nextStage === 'intro' || nextStage === 'summary') {
      this.bindings.clearSelectedPracticeMedia()
    }
    this.syncPracticeModeWithRuntime()
  }

  async prepareCurrentStage(): Promise<void> {
    const routeInput = this.buildCurrentRouteInput()
    const stage = routeInput.stage
    await this.runStageAction(() => TrainPageService.preparePageStage(
      this.bindings.getAbilityContext(),
      routeInput,
      stage
    ))
  }

  ensureSpeechPracticeService(): void {
    if (this.speechPracticeService) return
    this.speechPracticeService = TrainPageService.createSpeechPracticeService(
      (): common.BaseContext => this.bindings.getAbilityContext(),
      TrainPageService.buildSpeechCallbacks(
        (isPreparing: boolean): void => { this.bindings.onSpeechPreparingChange(isPreparing) },
        (isReady: boolean): void => { this.bindings.onSpeechReadyChange(isReady) },
        (isListening: boolean): void => { this.bindings.onSpeechListeningChange(isListening) }
      )
    )
  }

  async openLocalVideoPicker(): Promise<void> {
    if (this.isLaunchingVideoCapture) return
    this.isLaunchingVideoCapture = true
    try {
      const selectedUri = await TrainPageService.openVideoPicker()
      if (selectedUri.length > 0) {
        this.bindings.onVideoUriChange(selectedUri)
      }
    } finally {
      this.isLaunchingVideoCapture = false
    }
  }

  async openLocalAudioPicker(): Promise<void> {
    if (this.isLaunchingAudioCapture) return
    this.isLaunchingAudioCapture = true
    try {
      const selectedUri = await TrainPageService.openAudioPicker()
      if (selectedUri.length > 0) {
        this.bindings.onAudioUriChange(selectedUri)
      }
    } finally {
      this.isLaunchingAudioCapture = false
    }
  }

  async startSpeechRecognition(): Promise<void> {
    this.ensureSpeechPracticeService()
    if (this.speechPracticeService) {
      await this.speechPracticeService.startListening()
    }
  }

  stopSpeechRecognition(): void {
    if (this.speechPracticeService) {
      this.speechPracticeService.stopListening()
    }
  }

  dispose(): void {
    if (this.speechPracticeService) {
      this.speechPracticeService.dispose()
    }
    this.speechPracticeService = undefined
  }
}
