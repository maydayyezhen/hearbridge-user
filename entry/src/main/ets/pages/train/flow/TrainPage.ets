/**
 * TrainPage 页面文件，负责页面展示与交互承接。
 */

import common from '@ohos.app.ability.common'
import { hilog } from '@kit.PerformanceAnalysisKit'
import { User, createUser } from '../../../domain/entity/User'
import {
  TrainPageQueries,
  TrainPageService,
  TrainSessionRuntime,
  TrainSessionSummaryViewData,
  TrainSessionViewState,
  TrainStage
} from '../../../services/training/index'
import { TrainIntroStagePage } from './stages/TrainIntroStagePage'
import { TrainVideoStagePage } from './stages/TrainVideoStagePage'
import { TrainGuideStagePage } from './stages/TrainGuideStagePage'
import { TrainPracticeStagePage } from './stages/TrainPracticeStagePage'
import { TrainResultStagePage } from './stages/TrainResultStagePage'
import { TrainSummaryStagePage } from './stages/TrainSummaryStagePage'
import { goBack } from '../../../router/Router'
import { buildTrainRootPath } from '../../../router/RouteBuilders'
import { showGlobalToast } from '../../../services/ui/index'
import { TrainBottomBar, TrainOutlinePanel, TrainStageStepper, TrainStageTopArea } from './components/TrainFlowPanels'
import { TrainPageController } from './TrainPageController'
import { PracticeMode } from '../../../domain/static/train/TrainingRuntimeTypes'
import { MediaResourceItem } from '../../../domain/static/train/TrainingContentModels'
import { PageLoadingOverlay } from '../../../components/PageLoadingOverlay'
import { BackHeaderBar } from '../../../components/BackHeaderBar'

const TRAIN_STAGE_TRANSITION_SWAP_DELAY_MS = 110
const TRAIN_STAGE_SWIPE_TRIGGER_PX = 72
const TRAIN_STAGE_EDGE_BOUNCE_OFFSET_PX = 20
const TRAIN_PAGE_EXIT_DELAY_MS = 120
const TRAIN_SUBMIT_TRACE_DOMAIN = 0x0
const TRAIN_SUBMIT_TRACE_TAG = 'TrainSubmitTrace'

@Component
export struct TrainPage {
  @StorageLink('train.session.runtime') runtime: TrainSessionRuntime = TrainPageQueries.createEmptyRuntime()
  @StorageLink('train.session.summaryData') summaryData: TrainSessionSummaryViewData = TrainPageService.createEmptySummary()
  @StorageLink('train.session.summaryLoadedSessionId') summaryLoadedSessionId: number = 0
  @StorageLink('train.session.viewState') viewState: TrainSessionViewState = TrainPageQueries.createEmptyViewState()
  @StorageLink('user') user: User = createUser()
  @StorageLink('route.path') routePath: string = '/train'

  @State outlineVisible: boolean = false
  @State outlinePanelOffsetX: number = 420
  @State practiceMode: PracticeMode = 'video'
  @State isSpeechEngineReady: boolean = false
  @State isSpeechPreparing: boolean = false
  @State isSpeechListening: boolean = false
  @State selectedVideoUri: string = ''
  @State selectedAudioUri: string = ''
  @State isPagePreparing: boolean = true
  @State summaryPreparing: boolean = false
  @State displayItemCode: string = ''
  @State displayItemName: string = '未命名训练项'
  @State displayItemMeaning: string = '暂无释义'
  @State displayItemDescription: string = '暂无训练说明'
  @State displayItemGoal: string = '暂无训练目标'
  @State displayItemPrecautions: string[] = []
  @State displayItemCommonErrors: string[] = []
  @State displayItemLevelNum: number = 1
  @State displayItemCoverUrl: string = ''
  @State displayItemVideoUrl: string = ''
  @State displayItemPreviewUrl: string = ''
  @State displayItemActionImages: MediaResourceItem[] = []
  @State stagePageOffsetX: number = 0
  @State stagePageOpacity: number = 1
  @State isExiting: boolean = false
  @State pageExitOpacity: number = 1
  @State pageExitOffsetX: number = 0

  private introScroller: Scroller = new Scroller()
  private guideScroller: Scroller = new Scroller()
  private practiceScroller: Scroller = new Scroller()
  private resultScroller: Scroller = new Scroller()
  private summaryScroller: Scroller = new Scroller()
  private stageTransitionTimer: number = -1
  private stageTransitionRunning: boolean = false
  private pageExitTimer: number = -1

  private readonly controller: TrainPageController = new TrainPageController({
    getAbilityContext: (): common.BaseContext => this.getAbilityContextSafely(),
    getRoutePath: (): string => this.routePath,
    getCourseCode: (): string => this.runtime.courseCode,
    getItemCode: (): string => this.displayItemCode,
    getCurrentStage: (): TrainStage => this.getCurrentStage(),
    getPracticeMode: (): PracticeMode => this.practiceMode,
    setPracticeMode: (mode: PracticeMode): void => { this.practiceMode = mode },
    clearSelectedPracticeMedia: (): void => { this.clearSelectedPracticeMedia() },
    onSpeechPreparingChange: (isPreparing: boolean): void => { this.isSpeechPreparing = isPreparing },
    onSpeechReadyChange: (isReady: boolean): void => { this.isSpeechEngineReady = isReady },
    onSpeechListeningChange: (isListening: boolean): void => { this.isSpeechListening = isListening },
    onVideoUriChange: (uri: string): void => {
      this.selectedVideoUri = ''
      setTimeout(() => {
        this.selectedVideoUri = uri
      }, 0)
    },
    onAudioUriChange: (uri: string): void => { this.selectedAudioUri = uri }
  })

  private clearSelectedPracticeMedia(): void {
    this.selectedVideoUri = ''
    this.selectedAudioUri = ''
  }

  private traceTrainSubmit(stage: string, message: string): void {
    hilog.info(TRAIN_SUBMIT_TRACE_DOMAIN, TRAIN_SUBMIT_TRACE_TAG, '[%{public}s] %{public}s', stage, message)
  }

  aboutToAppear(): void {
    this.isExiting = false
    this.pageExitOpacity = 1
    this.pageExitOffsetX = 0
    this.isPagePreparing = true
    this.clearSelectedPracticeMedia()
    this.controller.syncPracticeModeWithRuntime()
    this.controller.ensureSpeechPracticeService()
    this.syncDisplayCurrentItemFromRuntime()
    void this.prepareCurrentStageAndSync()
  }

  aboutToDisappear(): void {
    this.clearSelectedPracticeMedia()
    this.clearStageTransitionTimer()
    if (this.pageExitTimer !== -1) {
      clearTimeout(this.pageExitTimer)
      this.pageExitTimer = -1
    }
    this.controller.dispose()
  }

  private clearStageTransitionTimer(): void {
    if (this.stageTransitionTimer !== -1) {
      clearTimeout(this.stageTransitionTimer)
      this.stageTransitionTimer = -1
    }
  }

  private getAbilityContextSafely(): common.BaseContext {
    return this.getUIContext().getHostContext() as common.BaseContext
  }

  private getCurrentStage(): TrainStage {
    if (this.summaryPreparing && this.runtime.currentStage === 'summary') {
      return 'result'
    }
    return TrainPageQueries.getStage(this.runtime)
  }

  private isSpeechTraining(): boolean {
    return this.runtime.trainingType === 'speech'
  }

  private normalizeItemText(rawValue: string, fallback: string = ''): string {
    let value = String(rawValue ?? '')
    value = value
      .replace(/<br\s*\/?>/gi, '\n')
      .replace(/<\/p>/gi, '\n')
      .replace(/<[^>]+>/g, '')
      .replace(/&nbsp;/gi, ' ')
      .replace(/&amp;/gi, '&')
      .replace(/&lt;/gi, '<')
      .replace(/&gt;/gi, '>')
      .replace(/\\r\\n/g, '\n')
      .replace(/\\n/g, '\n')
      .replace(/\\t/g, ' ')
      .replace(/[\u200B-\u200D\uFEFF]/g, '')
      .replace(/\r/g, '\n')
    value = value
      .replace(/[ \t]+/g, ' ')
      .replace(/\n{3,}/g, '\n\n')
      .trim()
    return value.length > 0 ? value : fallback
  }

  private normalizeItemTags(values: string[]): string[] {
    const normalized: string[] = []
    for (let i = 0; i < values.length; i += 1) {
      const nextValue = this.normalizeItemText(values[i], '')
      if (nextValue.length <= 0) {
        continue
      }
      if (!normalized.includes(nextValue)) {
        normalized.push(nextValue)
      }
    }
    return normalized
  }

  private filterDisplayActionImages(actionImages: MediaResourceItem[], excludedUrls: string[]): MediaResourceItem[] {
    const normalizedExcludedUrls: string[] = []
    for (let index = 0; index < excludedUrls.length; index += 1) {
      const nextUrl = this.normalizeItemText(excludedUrls[index], '')
      if (nextUrl.length > 0 && !normalizedExcludedUrls.includes(nextUrl)) {
        normalizedExcludedUrls.push(nextUrl)
      }
    }

    const filtered: MediaResourceItem[] = []
    for (let index = 0; index < actionImages.length; index += 1) {
      const resource = actionImages[index]
      const normalizedUrl = this.normalizeItemText(resource.url, '')
      if (normalizedUrl.length === 0 || normalizedExcludedUrls.includes(normalizedUrl)) {
        continue
      }
      filtered.push(resource)
    }
    return filtered
  }

  private syncDisplayCurrentItemFromRuntime(): void {
    const currentItem = TrainPageQueries.getCurrentItem(this.runtime)
    const courseDisplay = TrainPageQueries.getCourseDisplay(this.runtime)
    const normalizedCode = this.normalizeItemText(currentItem.code, '')
    const normalizedName = this.normalizeItemText(currentItem.name,
      normalizedCode.length > 0 ? normalizedCode : '未命名训练项')
    const coverUrl = currentItem.cover.length > 0 ? currentItem.cover[0].url : ''
    const posterUrl = currentItem.videoPoster.length > 0 ? currentItem.videoPoster[0].url : ''
    const actionImageUrl = currentItem.actionImages.length > 0 ? currentItem.actionImages[0].url : ''
    const courseCoverUrl = this.normalizeItemText(courseDisplay.courseCoverUrl, '')
    const resolvedCoverUrl = coverUrl.length > 0
      ? coverUrl
      : (posterUrl.length > 0
        ? posterUrl
        : (actionImageUrl.length > 0 ? actionImageUrl : courseCoverUrl))
    const resolvedPreviewUrl = posterUrl.length > 0
      ? posterUrl
      : (coverUrl.length > 0
        ? coverUrl
        : (actionImageUrl.length > 0 ? actionImageUrl : courseCoverUrl))

    this.displayItemCode = normalizedCode
    this.displayItemName = normalizedName
    this.displayItemMeaning = this.normalizeItemText(currentItem.meaning, '暂无释义')
    this.displayItemDescription = this.normalizeItemText(currentItem.description, '暂无训练说明')
    this.displayItemGoal = this.normalizeItemText(currentItem.goal, '暂无训练目标')
    this.displayItemPrecautions = this.normalizeItemTags(currentItem.precautions)
    this.displayItemCommonErrors = this.normalizeItemTags(currentItem.commonErrors)
    this.displayItemLevelNum = currentItem.levelNum > 0 ? currentItem.levelNum : 1
    this.displayItemActionImages = this.filterDisplayActionImages(currentItem.actionImages, [
      coverUrl,
      posterUrl,
      courseCoverUrl
    ])
    this.displayItemCoverUrl = this.normalizeItemText(resolvedCoverUrl, '')
    this.displayItemVideoUrl = currentItem.video.length > 0 ? currentItem.video[0].url : ''
    this.displayItemPreviewUrl = ''
  }

  private async prepareCurrentStageAndSync(): Promise<void> {
    try {
      await this.controller.prepareCurrentStage()
      this.syncDisplayCurrentItemFromRuntime()
    } finally {
      this.isPagePreparing = false
    }
  }

  private getStageOrder(stage: TrainStage): number {
    if (stage === 'video') {
      return 2
    }
    if (stage === 'guide') {
      return 3
    }
    if (stage === 'practice') {
      return 4
    }
    if (stage === 'result') {
      return 5
    }
    if (stage === 'summary') {
      return 6
    }
    return 1
  }

  private async runStagePageTransition(action: () => Promise<void>, direction: number): Promise<void> {
    if (this.stageTransitionRunning || this.shouldShowLoadingOverlay()) {
      await action()
      return
    }

    this.stageTransitionRunning = true
    this.clearStageTransitionTimer()
    const forward = direction >= 0
    const exitOffset = forward ? -28 : 28
    const enterOffset = forward ? 28 : -28

    this.getUIContext().animateTo({ duration: 110, curve: Curve.EaseIn }, () => {
      this.stagePageOffsetX = exitOffset
      this.stagePageOpacity = 0
    })

    await new Promise<void>((resolve) => {
      this.stageTransitionTimer = setTimeout(() => {
        this.stageTransitionTimer = -1
        resolve()
      }, TRAIN_STAGE_TRANSITION_SWAP_DELAY_MS)
    })

    try {
      await action()
    } finally {
      this.stagePageOffsetX = enterOffset
      this.stagePageOpacity = 0
      this.getUIContext().animateTo({ duration: 220, curve: Curve.EaseOut }, () => {
        this.stagePageOffsetX = 0
        this.stagePageOpacity = 1
      })
      this.stageTransitionTimer = setTimeout(() => {
        this.stageTransitionRunning = false
        this.stageTransitionTimer = -1
      }, 220)
    }
  }

  private async switchStageAndSync(stage: TrainStage): Promise<void> {
    const direction = this.getStageOrder(stage) >= this.getStageOrder(this.getCurrentStage()) ? 1 : -1
    await this.runStagePageTransition(async () => {
      await this.controller.switchStage(stage)
      this.syncDisplayCurrentItemFromRuntime()
    }, direction)
  }

  private async moveForwardAndSync(): Promise<void> {
    if (this.getCurrentStage() === 'result' && this.isLastTrainItem()) {
      this.summaryPreparing = true
      try {
        await this.controller.moveForward()
        this.syncDisplayCurrentItemFromRuntime()
        this.summaryData = await TrainPageService.loadSummary(this.runtime.sessionId)
        this.summaryLoadedSessionId = this.runtime.sessionId
      } finally {
        this.summaryPreparing = false
      }
      return
    }
    await this.runStagePageTransition(async () => {
      await this.controller.moveForward()
      this.syncDisplayCurrentItemFromRuntime()
    }, 1)
  }

  private async moveBackwardAndSync(): Promise<void> {
    await this.runStagePageTransition(async () => {
      await this.controller.moveBackward()
      this.syncDisplayCurrentItemFromRuntime()
    }, -1)
  }

  private async submitPracticeAndSync(): Promise<void> {
    this.traceTrainSubmit('submitPracticeAndSync.enter',
      `stage=${this.getCurrentStage()},mode=${this.practiceMode},audioUri=${this.selectedAudioUri.length > 0},videoUri=${this.selectedVideoUri.length > 0}`)
    await this.controller.submitPractice(this.viewState.speechPartialText, this.selectedAudioUri, this.selectedVideoUri)
    this.traceTrainSubmit('submitPracticeAndSync.return',
      `runtimeStage=${this.runtime.currentStage},recognized=${this.runtime.speechRecognizedText.trim().length > 0},partial=${this.viewState.speechPartialText.trim().length > 0}`)
    this.syncDisplayCurrentItemFromRuntime()
  }

  private async restartPracticeSessionAndSync(): Promise<void> {
    await this.runStagePageTransition(async () => {
      await this.controller.restartPracticeSession()
      this.syncDisplayCurrentItemFromRuntime()
    }, -1)
  }

  private showOutlinePanel(): void {
    this.outlineVisible = true
    this.outlinePanelOffsetX = 420
    this.getUIContext().animateTo({ duration: 220, curve: Curve.EaseOut }, () => {
      this.outlinePanelOffsetX = 0
    })
  }

  private hideOutlinePanel(): void {
    this.getUIContext().animateTo({ duration: 180, curve: Curve.EaseIn }, () => {
      this.outlinePanelOffsetX = 420
    })
    setTimeout(() => {
      this.outlineVisible = false
    }, 180)
  }

  private toggleOutlinePanel(): void {
    if (this.outlineVisible) {
      this.hideOutlinePanel()
      return
    }
    this.showOutlinePanel()
  }

  private async handleToggleCourseFavorite(): Promise<void> {
    if (this.runtime.courseCode.length === 0) return
    await TrainPageService.toggleCourseFavorite(
      this.getAbilityContextSafely(),
      this.runtime.courseCode,
      TrainPageQueries.getCourseDisplay(this.runtime).courseName,
      this.runtime.trainingType
    )
    showGlobalToast('收藏状态已更新', 'success')
  }

  private async handleToggleItemFavorite(): Promise<void> {
    if (this.displayItemCode.length === 0) return
    await TrainPageService.toggleItemFavorite(
      this.getAbilityContextSafely(),
      this.displayItemCode,
      this.displayItemName,
      this.runtime.courseCode,
      TrainPageQueries.getCourseDisplay(this.runtime).courseName,
      this.runtime.trainingType
    )
    showGlobalToast('收藏状态已更新', 'success')
  }

  private async jumpToItemById(itemId: number): Promise<void> {
    const changed = await TrainPageService.jumpToItem(this.getAbilityContextSafely(), itemId)
    this.hideOutlinePanel()
    if (changed) {
      this.clearSelectedPracticeMedia()
      this.controller.syncPracticeModeWithRuntime()
      this.syncDisplayCurrentItemFromRuntime()
    }
  }

  private exitToTrainRoot(): void {
    if (this.isExiting) {
      return
    }
    this.isExiting = true
    this.outlineVisible = false
    this.clearStageTransitionTimer()
    this.getUIContext().animateTo({ duration: TRAIN_PAGE_EXIT_DELAY_MS, curve: Curve.EaseIn }, () => {
      this.pageExitOpacity = 0
      this.pageExitOffsetX = 18
    })
    this.pageExitTimer = setTimeout(() => {
      this.pageExitTimer = -1
      this.clearSelectedPracticeMedia()
      goBack(buildTrainRootPath(this.runtime.trainingType.length > 0 ? this.runtime.trainingType : 'gesture'), true)
      TrainPageService.clearExitStateLater()
    }, TRAIN_PAGE_EXIT_DELAY_MS)
  }

  private handleTopBack(): void {
    if (this.runtime.isScoring) {
      return
    }
    this.exitToTrainRoot()
  }

  private handleTopNext(): void {
    this.traceTrainSubmit('handleTopNext.enter',
      `stage=${this.getCurrentStage()},scoring=${this.runtime.isScoring},speech=${this.isSpeechTraining()}`)
    if (this.runtime.isScoring) {
      this.traceTrainSubmit('handleTopNext.blocked', 'runtime.isScoring=true')
      return
    }
    if (this.getCurrentStage() === 'practice') {
      if (this.isSpeechTraining()) {
        const hasSpeechText = this.runtime.speechRecognizedText.trim().length > 0
        const hasSpeechPartial = this.viewState.speechPartialText.trim().length > 0
        const hasRecordedAudio = this.selectedAudioUri.trim().length > 0
        this.traceTrainSubmit('handleTopNext.practiceSpeechCheck',
          `recognized=${hasSpeechText},partial=${hasSpeechPartial},audio=${hasRecordedAudio}`)
        if (!hasSpeechText && !hasSpeechPartial && !hasRecordedAudio) {
          this.traceTrainSubmit('handleTopNext.practiceBlocked', 'speech no input')
          showGlobalToast('请先完成录音或语音识别', 'warning')
          return
        }
      } else if (this.selectedVideoUri.trim().length <= 0) {
        this.traceTrainSubmit('handleTopNext.practiceBlocked', 'gesture no video')
        showGlobalToast('请先选择练习视频', 'warning')
        return
      }
      this.traceTrainSubmit('handleTopNext.practicePassed', 'call submitPracticeAndSync')
      void this.submitPracticeAndSync()
      return
    }
    if (this.getCurrentStage() === 'summary') {
      this.exitToTrainRoot()
      return
    }
    void this.moveForwardAndSync()
  }

  private shouldShowLoadingOverlay(): boolean {
    return this.isPagePreparing || this.runtime.isSessionLoading || this.runtime.isCurrentItemDetailLoading
  }

  private canHandleStageSwipe(): boolean {
    return !this.outlineVisible
      && !this.runtime.isScoring
      && !this.shouldShowLoadingOverlay()
      && !this.stageTransitionRunning
  }

  private handleStageEdgeBounce(direction: number): void {
    if (this.stageTransitionRunning) {
      return
    }
    this.clearStageTransitionTimer()
    const bounceOffset = direction > 0 ? TRAIN_STAGE_EDGE_BOUNCE_OFFSET_PX : -TRAIN_STAGE_EDGE_BOUNCE_OFFSET_PX
    this.getUIContext().animateTo({ duration: 110, curve: Curve.EaseOut }, () => {
      this.stagePageOffsetX = bounceOffset
    })
    this.stageTransitionTimer = setTimeout(() => {
      this.getUIContext().animateTo({ duration: 180, curve: Curve.EaseOut }, () => {
        this.stagePageOffsetX = 0
      })
      this.stageTransitionTimer = -1
    }, 110)
  }

  private handleStageSwipe(offsetX: number, offsetY: number): void {
    if (!this.canHandleStageSwipe()) {
      return
    }
    if (Math.abs(offsetX) < TRAIN_STAGE_SWIPE_TRIGGER_PX || Math.abs(offsetX) <= Math.abs(offsetY)) {
      return
    }

    const currentStage = this.getCurrentStage()
    if (offsetX < 0) {
      if (currentStage === 'intro' || currentStage === 'video' || currentStage === 'guide' || currentStage === 'result') {
        void this.moveForwardAndSync()
        return
      }
      this.handleStageEdgeBounce(-1)
      return
    }

    if (currentStage === 'video' || currentStage === 'guide' || currentStage === 'practice' || currentStage === 'summary') {
      void this.moveBackwardAndSync()
      return
    }
    if (currentStage === 'result') {
      void this.restartPracticeSessionAndSync()
      return
    }
    this.handleStageEdgeBounce(1)
  }

  private getLoadingOverlayText(): string {
    if (this.summaryPreparing) {
      return '正在生成训练总结...'
    }
    if (this.runtime.isSessionLoading) {
      return '正在准备训练内容...'
    }
    if (this.runtime.isCurrentItemDetailLoading) {
      return '正在加载训练项内容...'
    }
    return '正在加载训练内容...'
  }

  private isLastTrainItem(): boolean {
    const total = this.runtime.items.length
    if (total <= 0) {
      return false
    }
    return this.runtime.currentItemIndex >= total - 1
  }

  @Builder
  private buildSummaryTopHeader(): void {
    Row() {
      Button() {
        SymbolGlyph($r('sys.symbol.chevron_backward'))
          .fontSize(15)
          .fontColor(['#2E79F4'])
      }
      .width(34)
      .height(34)
      .backgroundColor('#F1F5FB')
      .borderRadius(17)
      .stateEffect(false)
      .onClick(() => {
        this.exitToTrainRoot()
      })

      Text('课程总结')
        .layoutWeight(1)
        .textAlign(TextAlign.Center)
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor('#1F2A44')

      Blank()
        .width(34)
        .height(34)
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 0, bottom: 10 })
    .backgroundColor('#FFFFFF')
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])
  }

  @Builder
  private buildScoringOverlay(): void {
    Stack({ alignContent: Alignment.Center }) {
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('#660B1522')
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])

      Column({ space: 12 }) {
        LoadingProgress()
          .width(34)
          .height(34)
          .color('#2E79F4')

        Text(this.isSpeechTraining() ? 'AI 正在评估发音...' : 'AI 正在评估动作...')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#1F2A44')

        Text(this.isSpeechTraining()
          ? '正在分析发音清晰度、节奏稳定性和口型表现'
          : '正在分析动作完整度、连贯性和关键姿态准确度')
          .fontSize(12)
          .fontColor('#6E7F98')
      }
      .padding({ left: 22, right: 22, top: 20, bottom: 20 })
      .backgroundColor('#FFFFFF')
      .borderRadius(18)
      .border({ width: 1, color: '#E4ECF8' })
    }
    .width('100%')
    .height('100%')
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
    .zIndex(999)
  }

  @Builder
  private buildSummaryPreparingOverlay(): void {
    Stack({ alignContent: Alignment.Center }) {
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('#660B1522')
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])

      Column({ space: 12 }) {
        LoadingProgress()
          .width(34)
          .height(34)
          .color('#2E79F4')

        Text('正在生成训练总结...')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#1F2A44')

        Text('请稍等，完成后会自动进入课程总结。')
          .fontSize(12)
          .fontColor('#6E7F98')
      }
      .padding({ left: 22, right: 22, top: 20, bottom: 20 })
      .backgroundColor('#FFFFFFFF')
      .borderRadius(18)
      .border({ width: 1, color: '#FFE4ECF8' })
    }
    .width('100%')
    .height('100%')
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
    .zIndex(998)
  }

  @Builder
  private buildSummaryBackHeader(): void {
    BackHeaderBar({
      title: '课程总结',
      showShadow: false,
      onBack: () => {
        this.exitToTrainRoot()
      }
    })
  }

  @Builder
  private buildCurrentStage(): void {
    if (!this.isExiting) {
      if (this.getCurrentStage() === 'intro') {
        Scroll(this.introScroller) {
          Column({ space: 16 }) {
            Blank()
              .height(106)
            TrainIntroStagePage({
              courseCoverUrl: this.displayItemCoverUrl,
              itemName: this.displayItemName,
              itemMeaning: this.displayItemMeaning,
              itemLevelNum: this.displayItemLevelNum,
              itemDescription: this.displayItemDescription,
              itemGoal: this.displayItemGoal
            })
          }
          .width('100%')
          .padding({ left: 16, right: 16, top: 6, bottom: 16 })
        }
        .width('100%')
        .height('100%')
        .scrollBar(BarState.Off)
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
      } else if (this.getCurrentStage() === 'video') {
        Column({ space: 16 }) {
          Blank()
            .height(106)
          Column() {
            TrainVideoStagePage({
              videoUrl: this.displayItemVideoUrl
            })
          }
          .width('100%')
          .layoutWeight(1)
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 6, bottom: 16 })
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
      } else if (this.getCurrentStage() === 'guide') {
        Scroll(this.guideScroller) {
          Column({ space: 16 }) {
            Blank()
              .height(106)
            TrainGuideStagePage({
              actionImages: this.displayItemActionImages,
              itemPrecautions: this.displayItemPrecautions,
              itemCommonErrors: this.displayItemCommonErrors
            })
          }
          .width('100%')
          .padding({ left: 16, right: 16, top: 6, bottom: 16 })
        }
        .width('100%')
        .height('100%')
        .scrollBar(BarState.Off)
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
      } else if (this.getCurrentStage() === 'practice') {
        Scroll(this.practiceScroller) {
          Column({ space: 16 }) {
            Blank()
              .height(106)
            TrainPracticeStagePage({
              practiceMode: this.practiceMode,
              onStartSpeechRecognition: () => { void this.controller.startSpeechRecognition() },
              onStopSpeechRecognition: () => { this.controller.stopSpeechRecognition() },
              onOpenLocalAudioPicker: () => { void this.controller.openLocalAudioPicker() },
              onOpenLocalVideoPicker: () => { void this.controller.openLocalVideoPicker() },
              isSpeechPreparing: this.isSpeechPreparing,
              isSpeechListening: this.isSpeechListening,
              selectedVideoUri: this.selectedVideoUri,
              selectedAudioUri: this.selectedAudioUri
            })
          }
          .width('100%')
          .padding({ left: 16, right: 16, top: 6, bottom: 16 })
        }
        .width('100%')
        .height('100%')
        .scrollBar(BarState.Off)
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
      } else if (this.getCurrentStage() === 'summary') {
        Scroll(this.summaryScroller) {
          Column({ space: 16 }) {
            Blank()
              .height(52)
            TrainSummaryStagePage()
          }
          .width('100%')
          .padding({ left: 16, right: 16, top: 4, bottom: 16 })
          .backgroundColor('#F4F7FB')
        }
        .width('100%')
        .height('100%')
        .backgroundColor('#F4F7FB')
        .scrollBar(BarState.Off)
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
      } else {
        Scroll(this.resultScroller) {
          Column({ space: 16 }) {
            Blank()
              .height(106)
            TrainResultStagePage()
          }
          .width('100%')
          .padding({ left: 16, right: 16, top: 6, bottom: 16 })
          .backgroundColor('#F4F7FB')
        }
        .width('100%')
        .backgroundColor('#F4F7FB')
        .height('100%')
        .scrollBar(BarState.Off)
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
      }
    }
  }

  build(): void {
    Stack({ alignContent: Alignment.Top }) {
      if (this.shouldShowLoadingOverlay()) {
        PageLoadingOverlay({
          text: this.getLoadingOverlayText()
        })
      } else {
        Column({ space: 0 }) {
          Column() {
            this.buildCurrentStage()
          }
          .width('100%')
          .layoutWeight(1)
          .backgroundColor('#F4F7FB')
          .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
          .translate({ x: this.stagePageOffsetX, y: 0 })
          .opacity(this.stagePageOpacity)
          .gesture(
            PanGesture({ direction: PanDirection.Horizontal, distance: 10 })
              .onActionEnd((event: GestureEvent) => {
                this.handleStageSwipe(event.offsetX, event.offsetY)
              })
          )

          if (this.getCurrentStage() !== 'summary') {
            TrainBottomBar({
              isFavorited: TrainPageQueries.isItemFavorited(this.user, this.displayItemCode),
              progressText: TrainPageQueries.getProgressText(this.runtime),
              showRetry: this.getCurrentStage() === 'result',
              onRetryClick: () => {
                void this.restartPracticeSessionAndSync()
              },
              onFavoriteToggle: () => { void this.handleToggleItemFavorite() },
              onOutlineToggle: () => { this.toggleOutlinePanel() }
            })
          }
        }
        .width('100%')
        .height('100%')

        Column({ space: 0 }) {
          if (this.getCurrentStage() !== 'summary') {
            Column({ space: 10 }) {
              TrainStageTopArea({
                headerTitle: this.displayItemName,
                courseName: TrainPageQueries.getCourseDisplay(this.runtime).courseName,
                stageTitle: TrainPageQueries.getTitle(this.getCurrentStage()),
                stage: this.getCurrentStage(),
                progressText: TrainPageQueries.getProgressText(this.runtime),
                isScoring: this.runtime.isScoring,
                isLastItem: this.isLastTrainItem(),
                onBackClick: () => {
                  this.handleTopBack()
                },
                onNextClick: () => {
                  this.handleTopNext()
                }
              })
              TrainStageStepper({ stage: this.getCurrentStage() })
            }
            .width('100%')
            .padding({ left: 16, right: 16, top: 0, bottom: 10 })
            .backgroundColor('#FFFFFF')
            .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])
          } else {
            this.buildSummaryBackHeader()
          }
        }
        .width('100%')

        if (this.outlineVisible) {
          TrainOutlinePanel({
            courseName: TrainPageQueries.getCourseDisplay(this.runtime).courseName,
            courseCode: this.runtime.courseCode,
            progressText: TrainPageQueries.getProgressText(this.runtime),
            panelOffsetX: this.outlinePanelOffsetX,
            items: this.runtime.items,
            completedItemIds: TrainPageQueries.getCompletedItemIds(this.runtime),
            currentIndex: this.runtime.currentItemIndex,
            isCourseFavorited: TrainPageQueries.isCourseFavorited(this.user, this.runtime.courseCode),
            onClose: () => { this.hideOutlinePanel() },
            onItemClick: (itemId: number, _completed: boolean) => { void this.jumpToItemById(itemId) },
            onCourseFavoriteToggle: (_courseCode: string) => { void this.handleToggleCourseFavorite() }
          })
        }
      }

      if (this.runtime.isScoring) {
        this.buildScoringOverlay()
      }

      if (this.summaryPreparing) {
        this.buildSummaryPreparingOverlay()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F4F7FB')
    .opacity(this.pageExitOpacity)
    .translate({ x: this.pageExitOffsetX, y: 0 })
  }
}
