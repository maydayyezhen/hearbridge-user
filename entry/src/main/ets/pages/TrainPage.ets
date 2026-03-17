import photoAccessHelper from '@ohos.file.photoAccessHelper'
import picker from '@ohos.file.picker'
import { FALLBACK_COVER_URL, MediaResourceItem, TrainingItem, getMockTrainingItems } from './train/TrainData'
import { ResultStageContent } from './train/stages/ResultStageContent'
import { IntroStageContent } from './train/stages/IntroStageContent'
import { GuideStageContent } from './train/stages/GuideStageContent'
import { SummaryStageContent } from './train/stages/SummaryStageContent'
import { TrainBottomBar } from './train/components/TrainBottomBar'
import { TrainOutlinePanel } from './train/components/TrainOutlinePanel'

class CourseScoreEntry {
  itemId: number
  score: number

  constructor(itemId: number, score: number) {
    this.itemId = itemId
    this.score = score
  }
}

class CourseProgressSnapshot {
  completedItemIds: number[]
  scoreEntries: CourseScoreEntry[]
  pausedAtItemName: string

  constructor(completedItemIds: number[], scoreEntries: CourseScoreEntry[], pausedAtItemName: string) {
    this.completedItemIds = completedItemIds
    this.scoreEntries = scoreEntries
    this.pausedAtItemName = pausedAtItemName
  }
}

const COURSE_PROGRESS_CACHE: Map<string, CourseProgressSnapshot> = new Map()

@Component
export struct TrainPage {
  @Prop courseName: string = '日常问候入门'
  @Prop courseCode: string = 'COURSE-101'
  @Prop trainingType: string = 'gesture'
  @Prop selectedPhrase: string = '你好'
  @Prop initialStage: string = 'intro'
  @Prop isCourseFavorited: boolean = false
  @State currentItemIndex: number = 0
  @State currentStage: string = 'intro'
  @State practiceMode: string = 'video'
  @State isCapturing: boolean = false
  @State mockScore: number = 86
  @State recordedVideoUri: string = ''
  @State recordedAudioUri: string = ''
  @State audioCaptureTip: string = '已就绪，选一段音频开始跟读吧。'
  @State captureTip: string = '已就绪，选一段视频开始练习吧。'
  @State isLaunchingVideoCapture: boolean = false
  @State isLaunchingAudioCapture: boolean = false
  @State isScoring: boolean = false
  @State demoAudioProgress: number = 0
  @State isDemoAudioPlaying: boolean = false
  @State demoAudioDurationSec: number = 9
  @State demoAudioWaveTick: number = 0
  @State summaryCompletedCount: number = 0
  @State summaryAverageScore: number = 0
  @State summaryBestScore: number = 0
  @State summaryMode: string = 'completed'
  @State summaryPausedAtName: string = ''
  @State showOutlinePanel: boolean = false
  @State outlinePanelOffsetX: number = 360
  @State favoriteItemIds: number[] = []
  @State stageContentOpacity: number = 1
  @State stageContentOffsetX: number = 0
  @State isStageAnimating: boolean = false
  onSelectPhrase: (phrase: string) => void = () => {}
  onBackToCourseList: () => void = () => {}
  onCompleteTraining: () => void = () => {}
  onScoringStateChange: (isScoring: boolean) => void = () => {}
  onToggleCourseFavorite: (courseCode: string) => void = (_courseCode: string) => {}

  private introScroller: Scroller = new Scroller()
  private videoScroller: Scroller = new Scroller()
  private guideScroller: Scroller = new Scroller()
  private practiceScroller: Scroller = new Scroller()
  private resultScroller: Scroller = new Scroller()
  private videoController: VideoController = new VideoController()
  private practiceVideoController: VideoController = new VideoController()
  private demoAudioTimer: number = -1
  private demoAudioStartAtMs: number = 0
  private scoringTimer: number = -1
  private stageTransitionTimer: number = -1
  private outlinePanelTimer: number = -1
  private courseScoreEntries: CourseScoreEntry[] = []
  private readonly fallbackCoverUrl: string = FALLBACK_COVER_URL
  private readonly trainingItems: TrainingItem[] = getMockTrainingItems()

  aboutToAppear() {
    this.syncCurrentItemFromSelection()
  }

  aboutToDisappear() {
    this.clearDemoAudioTimer()
    this.clearScoringTimer()
    this.clearStageTransitionTimer()
    this.clearOutlinePanelTimer()
    this.setScoringState(false)
  }

  private syncCurrentItemFromSelection() {
    const items: TrainingItem[] = this.getVisibleItems()
    if (items.length === 0) {
      this.resetCourseSummary()
      this.resetTrainingFlow()
      return
    }

    let selectedIndex = -1
    for (let index = 0; index < items.length; index += 1) {
      if (items[index].name === this.selectedPhrase) {
        selectedIndex = index
        break
      }
    }

    const restored = this.tryRestoreCourseProgress(items)
    if (!restored) {
      this.applyMockCompletedProgress(items)
    }

    if (selectedIndex >= 0) {
      this.currentItemIndex = selectedIndex
      this.onSelectPhrase(items[this.currentItemIndex].name)
    } else if (!restored) {
      this.currentItemIndex = 0
    }

    this.resetTrainingFlow()
    this.applyInitialStage()
  }

  private applyInitialStage() {
    if (this.initialStage === 'result') {
      this.currentStage = 'result'
      return
    }
    this.currentStage = 'intro'
  }

  private applyMockCompletedProgress(items: TrainingItem[]) {
    this.resetCourseSummary()
    if (this.courseCode !== 'COURSE-301') {
      return
    }
    const presetCount = Math.min(3, items.length)
    for (let i = 0; i < presetCount; i += 1) {
      const score = 84 + (i * 3)
      this.courseScoreEntries.push(new CourseScoreEntry(items[i].id, score))
    }
    this.refreshSummaryStats()
  }

  private resetCourseSummary() {
    this.courseScoreEntries = []
    this.summaryCompletedCount = 0
    this.summaryAverageScore = 0
    this.summaryBestScore = 0
  }

  private resetTrainingFlow(resetAnimationState: boolean = true) {
    if (resetAnimationState) {
      this.clearStageTransitionTimer()
      this.isStageAnimating = false
      this.stageContentOpacity = 1
      this.stageContentOffsetX = 0
    }
    this.currentStage = 'intro'
    this.practiceMode = this.trainingType === 'speech' ? 'audio' : 'video'
    this.isCapturing = false
    this.setScoringState(false)
    this.clearScoringTimer()
    this.mockScore = 86
    this.recordedVideoUri = ''
    this.recordedAudioUri = ''
    this.summaryMode = 'completed'
    this.summaryPausedAtName = ''
    this.stopDemoAudioPlayback()
    if (this.trainingType === 'speech') {
      this.audioCaptureTip = '已就绪，选一段音频开始跟读吧。'
      this.captureTip = '已就绪，选一段视频开始练习吧。'
    } else {
      this.audioCaptureTip = '当前是手势训练，请使用视频练习。'
      this.captureTip = '已就绪，选一段手势视频开始练习吧。'
    }
  }

  private getCourseProgressKey(): string {
    return `${this.courseCode}|${this.trainingType}`
  }

  private tryRestoreCourseProgress(items: TrainingItem[]): boolean {
    const snapshot = COURSE_PROGRESS_CACHE.get(this.getCourseProgressKey())
    if (!snapshot) {
      return false
    }

    this.courseScoreEntries = []
    for (let i = 0; i < snapshot.scoreEntries.length; i += 1) {
      this.courseScoreEntries.push(new CourseScoreEntry(snapshot.scoreEntries[i].itemId, snapshot.scoreEntries[i].score))
    }
    this.refreshSummaryStats()
    this.summaryPausedAtName = snapshot.pausedAtItemName

    const nextIndex = this.getFirstUncompletedIndex(items, snapshot.completedItemIds)
    this.currentItemIndex = nextIndex
    this.onSelectPhrase(items[this.currentItemIndex].name)
    return true
  }

  private getFirstUncompletedIndex(items: TrainingItem[], completedIds: number[]): number {
    for (let index = 0; index < items.length; index += 1) {
      let completed = false
      for (let i = 0; i < completedIds.length; i += 1) {
        if (completedIds[i] === items[index].id) {
          completed = true
          break
        }
      }
      if (!completed) {
        return index
      }
    }
    return Math.max(0, items.length - 1)
  }

  private saveCourseProgress(pausedAtName: string) {
    const completedIds: number[] = []
    const copiedEntries: CourseScoreEntry[] = []
    for (let i = 0; i < this.courseScoreEntries.length; i += 1) {
      completedIds.push(this.courseScoreEntries[i].itemId)
      copiedEntries.push(new CourseScoreEntry(this.courseScoreEntries[i].itemId, this.courseScoreEntries[i].score))
    }
    COURSE_PROGRESS_CACHE.set(this.getCourseProgressKey(), new CourseProgressSnapshot(completedIds, copiedEntries, pausedAtName))
  }

  private clearCourseProgress() {
    COURSE_PROGRESS_CACHE.delete(this.getCourseProgressKey())
  }

  private recordCurrentItemScore(score: number) {
    const current = this.getCurrentItem()
    if (current.id <= 0) {
      return
    }
    let found = false
    for (let i = 0; i < this.courseScoreEntries.length; i += 1) {
      if (this.courseScoreEntries[i].itemId === current.id) {
        this.courseScoreEntries[i].score = score
        found = true
        break
      }
    }
    if (!found) {
      this.courseScoreEntries.push(new CourseScoreEntry(current.id, score))
    }
    this.refreshSummaryStats()
  }

  private refreshSummaryStats() {
    const count = this.courseScoreEntries.length
    this.summaryCompletedCount = count
    if (count === 0) {
      this.summaryAverageScore = 0
      this.summaryBestScore = 0
      return
    }
    let total = 0
    let best = 0
    for (let i = 0; i < this.courseScoreEntries.length; i += 1) {
      total += this.courseScoreEntries[i].score
      if (this.courseScoreEntries[i].score > best) {
        best = this.courseScoreEntries[i].score
      }
    }
    this.summaryAverageScore = Math.floor(total / count)
    this.summaryBestScore = best
  }

  private clearDemoAudioTimer() {
    if (this.demoAudioTimer !== -1) {
      clearInterval(this.demoAudioTimer)
      this.demoAudioTimer = -1
    }
  }

  private clearScoringTimer() {
    if (this.scoringTimer !== -1) {
      clearTimeout(this.scoringTimer)
      this.scoringTimer = -1
    }
  }

  private clearStageTransitionTimer() {
    if (this.stageTransitionTimer !== -1) {
      clearTimeout(this.stageTransitionTimer)
      this.stageTransitionTimer = -1
    }
  }

  private clearOutlinePanelTimer() {
    if (this.outlinePanelTimer !== -1) {
      clearTimeout(this.outlinePanelTimer)
      this.outlinePanelTimer = -1
    }
  }

  private transitionToStage(nextStage: string, forward: boolean, scrollTop: boolean = true) {
    if (this.currentStage === nextStage) {
      return
    }
    this.clearStageTransitionTimer()
    this.isStageAnimating = true

    const outOffset: number = forward ? -28 : 28
    animateTo({ duration: 120, curve: Curve.EaseInOut }, () => {
      this.stageContentOpacity = 0
      this.stageContentOffsetX = outOffset
    })

    this.stageTransitionTimer = setTimeout(() => {
      this.currentStage = nextStage
      this.stageContentOpacity = 0
      this.stageContentOffsetX = forward ? 28 : -28
      if (scrollTop) {
        this.scrollContentToTop()
      }
      animateTo({ duration: 180, curve: Curve.EaseOut }, () => {
        this.stageContentOpacity = 1
        this.stageContentOffsetX = 0
      })
      this.stageTransitionTimer = setTimeout(() => {
        this.isStageAnimating = false
        this.stageTransitionTimer = -1
      }, 190)
    }, 130)
  }

  private setScoringState(isScoring: boolean) {
    if (this.isScoring === isScoring) {
      return
    }
    this.isScoring = isScoring
    this.onScoringStateChange(isScoring)
  }

  private formatDuration(seconds: number): string {
    const safe = Math.max(0, Math.floor(seconds))
    const mm = Math.floor(safe / 60)
    const ss = safe % 60
    return `${mm < 10 ? '0' : ''}${mm}:${ss < 10 ? '0' : ''}${ss}`
  }

  private getDemoAudioProgressPercentText(): string {
    if (this.demoAudioDurationSec <= 0) {
      return '0%'
    }
    const raw = (this.demoAudioProgress / this.demoAudioDurationSec) * 100
    const clamped = Math.min(100, Math.max(0, raw))
    return `${clamped.toFixed(1)}%`
  }

  private applyDemoAudioDuration(durationSec: number) {
    const safeDuration = Math.max(1, Math.floor(durationSec))
    this.demoAudioDurationSec = safeDuration
    if (this.demoAudioProgress > this.demoAudioDurationSec) {
      this.demoAudioProgress = this.demoAudioDurationSec
    }
  }

  private stopDemoAudioPlayback() {
    this.clearDemoAudioTimer()
    this.isDemoAudioPlaying = false
    this.practiceVideoController.pause()
  }

  private startDemoAudioPlayback() {
    if (this.isDemoAudioPlaying) {
      return
    }
    this.clearDemoAudioTimer()
    if (this.demoAudioProgress >= this.demoAudioDurationSec) {
      this.demoAudioProgress = 0
    }
    this.demoAudioWaveTick = 0
    // Resume from current progress instead of always restarting from zero.
    this.demoAudioStartAtMs = Date.now() - Math.floor(this.demoAudioProgress * 1000)
    this.isDemoAudioPlaying = true
    this.practiceVideoController.start()
    this.demoAudioTimer = setInterval(() => {
      if (!this.isDemoAudioPlaying) {
        this.clearDemoAudioTimer()
        return
      }
      const elapsedSec = (Date.now() - this.demoAudioStartAtMs) / 1000
      if (elapsedSec >= this.demoAudioDurationSec) {
        this.demoAudioProgress = this.demoAudioDurationSec
        this.stopDemoAudioPlayback()
        return
      }
      this.demoAudioProgress = elapsedSec
      this.demoAudioWaveTick = elapsedSec * 10
    }, 50)
  }

  private getAudioWaveHeight(index: number): number {
    if (!this.isDemoAudioPlaying) {
      return 8
    }
    const phase = (this.demoAudioWaveTick * 0.26) + (index * 0.48)
    const value = Math.abs(Math.sin(phase))
    return 8 + Math.floor(value * 18)
  }

  private getVisibleItems(): TrainingItem[] {
    const items: TrainingItem[] = []
    for (let index = 0; index < this.trainingItems.length; index += 1) {
      const item = this.trainingItems[index]
      if (this.isItemMatchedToCourse(item) && (item.status === 'published' || item.status === 'enabled')) {
        items.push(item)
      }
    }
    items.sort((left: TrainingItem, right: TrainingItem) => left.sortNum - right.sortNum)
    return items
  }

  private isItemMatchedToCourse(item: TrainingItem): boolean {
    if (this.courseCode === 'COURSE-301') {
      return item.majorCategoryCode === 'voice' && item.code.startsWith('VOI_')
    }
    if (this.courseCode === 'COURSE-302') {
      return item.id === 3
    }
    if (this.courseCode === 'COURSE-101') {
      return item.id === 1
    }
    return item.majorCategoryCode === (this.trainingType === 'speech' ? 'voice' : 'gesture')
  }

  private hasVisibleItems(): boolean {
    return this.getVisibleItems().length > 0
  }

  private getCurrentItem(): TrainingItem {
    const items: TrainingItem[] = this.getVisibleItems()
    if (items.length === 0) {
      return new TrainingItem(0, '', '', 'gesture', 0, false, 0, 'empty', '', '', '', [], [], [], [], [], [], [])
    }
    return items[Math.min(items.length - 1, Math.max(0, this.currentItemIndex))]
  }

  private getPrimaryCoverUrl(item: TrainingItem): string {
    if (item.cover.length > 0) {
      return item.cover[0].url
    }
    return this.fallbackCoverUrl
  }

  private getVideoPosterUrl(item: TrainingItem): string {
    if (item.videoPoster.length > 0) {
      return item.videoPoster[0].url
    }
    return this.getPrimaryCoverUrl(item)
  }

  private hasVideo(item: TrainingItem): boolean {
    return item.video.length > 0
  }

  private getStageTitle(): string {
    if (this.currentStage === 'intro') {
      return '训练介绍'
    }
    if (this.currentStage === 'video') {
      return '示范视频'
    }
    if (this.currentStage === 'guide') {
      return '步骤讲解'
    }
    if (this.currentStage === 'practice') {
      return '开始练习'
    }
    if (this.currentStage === 'summary') {
      return '课程总结'
    }
    return '评分结果'
  }

  private getStageOrder(): number {
    if (this.currentStage === 'intro') {
      return 1
    }
    if (this.currentStage === 'video') {
      return 2
    }
    if (this.currentStage === 'guide') {
      return 3
    }
    if (this.currentStage === 'practice') {
      return 4
    }
    if (this.currentStage === 'summary') {
      return 5
    }
    return 5
  }

  private getProgressText(): string {
    const totalCount: number = this.getVisibleItems().length
    if (totalCount === 0) {
      return '0/0'
    }
    return `${Math.min(this.currentItemIndex + 1, totalCount)}/${totalCount}`
  }

  private selectItem(index: number) {
    const items: TrainingItem[] = this.getVisibleItems()
    if (items.length === 0) {
      return
    }
    this.currentItemIndex = Math.min(items.length - 1, Math.max(0, index))
    this.onSelectPhrase(items[this.currentItemIndex].name)
    this.resetTrainingFlow()
  }

  private switchItemWithAnimation(targetIndex: number, forward: boolean, targetStage: string = 'intro') {
    const items: TrainingItem[] = this.getVisibleItems()
    if (items.length === 0 || this.isStageAnimating) {
      return
    }
    const nextIndex = Math.min(items.length - 1, Math.max(0, targetIndex))
    if (nextIndex === this.currentItemIndex) {
      return
    }
    this.clearStageTransitionTimer()
    this.isStageAnimating = true
    this.currentItemIndex = nextIndex
    this.onSelectPhrase(items[this.currentItemIndex].name)
    this.resetTrainingFlow(false)
    this.currentStage = targetStage
    this.stageContentOpacity = 0
    this.stageContentOffsetX = forward ? 20 : -20
    animateTo({ duration: 220, curve: Curve.EaseOut }, () => {
      this.stageContentOpacity = 1
      this.stageContentOffsetX = 0
    })
    this.stageTransitionTimer = setTimeout(() => {
      this.isStageAnimating = false
      this.stageTransitionTimer = -1
    }, 230)
  }

  private goToNextStage() {
    if (this.isScoring || this.isStageAnimating) {
      return
    }
    if (this.currentStage === 'intro') {
      const next = this.hasVideo(this.getCurrentItem()) ? 'video' : 'guide'
      this.transitionToStage(next, true, next !== 'video')
      return
    }
    if (this.currentStage === 'video') {
      this.transitionToStage('guide', true)
      return
    }
    if (this.currentStage === 'guide') {
      this.transitionToStage('practice', true)
      return
    }
    if (this.currentStage === 'practice') {
      this.submitPractice()
    }
  }

  private goToPreviousStage() {
    if (this.isScoring || this.isStageAnimating) {
      return
    }
    if (this.currentStage === 'intro') {
      if (this.currentItemIndex > 0) {
        this.switchItemWithAnimation(this.currentItemIndex - 1, false, 'result')
      }
      return
    }
    if (this.currentStage === 'video') {
      this.transitionToStage('intro', false)
      return
    }
    if (this.currentStage === 'guide') {
      const prev = this.hasVideo(this.getCurrentItem()) ? 'video' : 'intro'
      this.transitionToStage(prev, false, prev !== 'video')
      return
    }
    if (this.currentStage === 'practice') {
      this.transitionToStage('guide', false)
      return
    }
    if (this.currentStage === 'result') {
      this.transitionToStage('practice', false)
      return
    }
    if (this.currentStage === 'summary') {
      this.transitionToStage('result', false)
    }
  }

  private scrollContentToTop() {
    setTimeout(() => {
      this.getCurrentStageScroller().scrollTo({
        xOffset: 0,
        yOffset: 0,
        animation: {
          duration: 220,
          curve: Curve.EaseInOut
        }
      })
    }, 40)
  }

  private getCurrentStageScroller(): Scroller {
    if (this.currentStage === 'video') {
      return this.videoScroller
    }
    if (this.currentStage === 'guide') {
      return this.guideScroller
    }
    if (this.currentStage === 'practice') {
      return this.practiceScroller
    }
    if (this.currentStage === 'result') {
      return this.resultScroller
    }
    if (this.currentStage === 'summary') {
      return this.resultScroller
    }
    return this.introScroller
  }

  private submitPractice() {
    if (this.isScoring || this.isStageAnimating) {
      return
    }
    this.isCapturing = false
    this.setScoringState(true)
    this.clearScoringTimer()
    this.scoringTimer = setTimeout(() => {
      this.mockScore = this.trainingType === 'speech' ? 91 : 88
      this.recordCurrentItemScore(this.mockScore)
      this.setScoringState(false)
      this.transitionToStage('result', true)
      this.scoringTimer = -1
    }, 1800)
  }

  private async openLocalVideoPicker() {
    if (this.isLaunchingVideoCapture) {
      return
    }

    this.isLaunchingVideoCapture = true
    this.captureTip = '正在打开视频选择...'

    try {
      let videoPicker = new photoAccessHelper.PhotoViewPicker()
      let pickerOptions = new photoAccessHelper.PhotoSelectOptions()
      pickerOptions.MIMEType = photoAccessHelper.PhotoViewMIMETypes.VIDEO_TYPE
      pickerOptions.maxSelectNumber = 1

      const pickerResult = await videoPicker.select(pickerOptions)
      if (pickerResult.photoUris.length > 0) {
        this.recordedVideoUri = pickerResult.photoUris[0]
        this.captureTip = '视频已就位，预览后继续闯关。'
      } else {
        this.captureTip = '还没选到视频，再挑一段试试。'
      }
    } catch (_pickerError) {
      this.captureTip = '这次没选成功，再试一次就好。'
    } finally {
      this.isLaunchingVideoCapture = false
    }
  }

  private async openLocalAudioPicker() {
    if (this.isLaunchingAudioCapture) {
      return
    }

    this.isLaunchingAudioCapture = true
    this.audioCaptureTip = '正在打开音频选择...'

    try {
      let documentPicker = new picker.DocumentViewPicker()
      let documentSelectOptions = new picker.DocumentSelectOptions()
      documentSelectOptions.maxSelectNumber = 1
      documentSelectOptions.fileSuffixFilters = ['音频|.mp3,.m4a,.aac,.wav,.ogg,.flac']

      const documentSelectResult = await documentPicker.select(documentSelectOptions) as Array<string>
      if (documentSelectResult.length > 0) {
        this.recordedAudioUri = documentSelectResult[0]
        this.audioCaptureTip = '音频已就位，继续练习拿高分。'
      } else {
        this.audioCaptureTip = '还没选到音频，再挑一段试试。'
      }
    } catch (_pickerError) {
      this.audioCaptureTip = '这次没选成功，再试一次就好。'
    } finally {
      this.isLaunchingAudioCapture = false
    }
  }

  private handleNextItem() {
    if (this.isStageAnimating) {
      return
    }
    const items: TrainingItem[] = this.getVisibleItems()
    if (this.currentItemIndex < items.length - 1) {
      this.switchItemWithAnimation(this.currentItemIndex + 1, true)
      return
    }
    this.onCompleteTraining()
    this.summaryMode = 'completed'
    this.summaryPausedAtName = ''
    this.transitionToStage('summary', true)
  }

  private finishCourseAndExit() {
    if (this.summaryMode === 'completed') {
      this.clearCourseProgress()
    } else {
      this.saveCourseProgress(this.summaryPausedAtName)
    }
    this.onBackToCourseList()
  }

  private handlePauseConfirm() {
    const item = this.getCurrentItem()
    this.summaryMode = 'paused'
    this.summaryPausedAtName = item.name
    this.saveCourseProgress(item.name)
    this.transitionToStage('summary', true)
  }

  private handleHeaderBackAction() {
    if (this.currentStage === 'summary' || this.isScoring || this.isStageAnimating) {
      return
    }
    this.handlePauseConfirm()
  }

  private canShowPrevious(): boolean {
    return this.currentStage !== 'intro' || this.currentItemIndex > 0
  }

  private getPreviousLabel(): string {
    return '上一步'
  }

  private getNextLabel(): string {
    if (this.currentStage === 'practice') {
      if (this.isScoring) {
        return '评分中...'
      }
      return '评分'
    }
    if (this.currentStage === 'result') {
      return '下一项'
    }
    if (this.currentStage === 'summary') {
      return '返回课程'
    }
    return '下一步'
  }

  private handleFloatingNext() {
    if (this.isScoring || this.isStageAnimating) {
      return
    }
    if (this.currentStage === 'result') {
      this.handleNextItem()
      return
    }
    if (this.currentStage === 'summary') {
      this.finishCourseAndExit()
      return
    }
    this.goToNextStage()
  }

  private handleStageSwipe(offsetX: number, offsetY: number) {
    if (this.isScoring || this.isStageAnimating || this.currentStage === 'summary') {
      return
    }
    const horizontal = Math.abs(offsetX)
    const vertical = Math.abs(offsetY)
    if (horizontal < 72 || horizontal < vertical * 1.2) {
      return
    }
    if (offsetX < 0) {
      this.handleFloatingNext()
      return
    }
    if (this.canShowPrevious()) {
      this.goToPreviousStage()
    }
  }

  private isCurrentItemFavorited(): boolean {
    const currentId = this.getCurrentItem().id
    if (currentId <= 0) {
      return false
    }
    for (let i = 0; i < this.favoriteItemIds.length; i += 1) {
      if (this.favoriteItemIds[i] === currentId) {
        return true
      }
    }
    return false
  }

  private toggleCurrentItemFavorite() {
    const currentId = this.getCurrentItem().id
    if (currentId <= 0) {
      return
    }
    const updated: number[] = []
    let found = false
    for (let i = 0; i < this.favoriteItemIds.length; i += 1) {
      if (this.favoriteItemIds[i] === currentId) {
        found = true
        continue
      }
      updated.push(this.favoriteItemIds[i])
    }
    if (!found) {
      updated.push(currentId)
    }
    this.favoriteItemIds = updated
  }

  private isItemCompleted(itemId: number): boolean {
    for (let i = 0; i < this.courseScoreEntries.length; i += 1) {
      if (this.courseScoreEntries[i].itemId === itemId) {
        return true
      }
    }
    return false
  }

  private getCompletedItemIds(): number[] {
    const result: number[] = []
    for (let i = 0; i < this.courseScoreEntries.length; i += 1) {
      result.push(this.courseScoreEntries[i].itemId)
    }
    return result
  }

  private openOutlinePanel() {
    if (this.showOutlinePanel) {
      return
    }
    this.clearOutlinePanelTimer()
    this.showOutlinePanel = true
    this.outlinePanelOffsetX = 360
    animateTo({ duration: 220, curve: Curve.EaseOut }, () => {
      this.outlinePanelOffsetX = 0
    })
  }

  private closeOutlinePanel() {
    if (!this.showOutlinePanel) {
      return
    }
    this.clearOutlinePanelTimer()
    animateTo({ duration: 180, curve: Curve.EaseInOut }, () => {
      this.outlinePanelOffsetX = 360
    })
    this.outlinePanelTimer = setTimeout(() => {
      this.showOutlinePanel = false
      this.outlinePanelTimer = -1
    }, 190)
  }

  private toggleOutlinePanel() {
    if (this.showOutlinePanel) {
      this.closeOutlinePanel()
      return
    }
    this.openOutlinePanel()
  }

  private handleOutlineItemClick(itemId: number, completed: boolean) {
    const items: TrainingItem[] = this.getVisibleItems()
    let targetIndex = -1
    for (let i = 0; i < items.length; i += 1) {
      if (items[i].id === itemId) {
        targetIndex = i
        break
      }
    }
    if (targetIndex < 0) {
      this.closeOutlinePanel()
      return
    }

    this.selectItem(targetIndex)
    if (completed) {
      this.currentStage = 'result'
    } else {
      this.currentStage = 'intro'
    }
    this.closeOutlinePanel()
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      Column() {
        Stack({ alignContent: Alignment.Top }) {
        Column() {
        if (this.currentStage === 'intro') {
          Scroll(this.introScroller) {
            Column({ space: 16 }) {
              Blank()
                .height(106)
              if (this.hasVisibleItems()) {
                this.buildIntroStage(this.getCurrentItem())
              } else {
                this.buildEmptyState()
              }
            }
            .width('100%')
            .padding({ left: 16, right: 16, top: 6, bottom: 16 })
          }
          .width('100%')
          .height('100%')
          .scrollBar(BarState.Off)
          .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
        } else if (this.currentStage === 'video') {
          Column({ space: 16 }) {
            Blank()
              .height(106)
            if (this.hasVisibleItems()) {
              Column() {
                this.buildVideoStage(this.getCurrentItem())
              }
              .width('100%')
              .layoutWeight(1)
            } else {
              Column() {
                this.buildEmptyState()
              }
              .width('100%')
              .layoutWeight(1)
            }
          }
          .width('100%')
          .padding({ left: 16, right: 16, top: 6, bottom: 16 })
          .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
        } else if (this.currentStage === 'guide') {
          Scroll(this.guideScroller) {
            Column({ space: 16 }) {
              Blank()
                .height(106)
              if (this.hasVisibleItems()) {
                this.buildGuideStage(this.getCurrentItem())
              } else {
                this.buildEmptyState()
              }
            }
            .width('100%')
            .padding({ left: 16, right: 16, top: 6, bottom: 16 })
          }
          .width('100%')
          .height('100%')
          .scrollBar(BarState.Off)
          .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
        } else if (this.currentStage === 'practice') {
          Scroll(this.practiceScroller) {
            Column({ space: 16 }) {
              Blank()
                .height(106)
              if (this.hasVisibleItems()) {
                this.buildPracticeStage(this.getCurrentItem())
              } else {
                this.buildEmptyState()
              }
            }
            .width('100%')
            .padding({ left: 16, right: 16, top: 6, bottom: 16 })
          }
          .width('100%')
          .height('100%')
          .scrollBar(BarState.Off)
          .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
        } else if (this.currentStage === 'summary') {
          Scroll(this.resultScroller) {
            Column({ space: 16 }) {
              Blank()
                .height(74)
              SummaryStageContent({
                trainingType: this.trainingType,
                completedCount: this.summaryCompletedCount,
                totalCount: this.getVisibleItems().length,
                averageScore: this.summaryAverageScore,
                bestScore: this.summaryBestScore,
                mode: this.summaryMode,
                pausedAtName: this.summaryPausedAtName
              })
            }
            .width('100%')
            .padding({ left: 16, right: 16, top: 16, bottom: 16 })
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
              if (this.hasVisibleItems()) {
                this.buildResultStage(this.getCurrentItem())
              } else {
                this.buildEmptyState()
              }
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
        .width('100%')
        .height('100%')
        .opacity(this.stageContentOpacity)
        .translate({ x: this.stageContentOffsetX, y: 0 })

        this.buildPreloadAssets(this.getCurrentItem())

        if (this.currentStage !== 'summary') {
          Column({ space: 10 }) {
            this.buildTopHeader()
            this.buildStageStepper()
          }
          .width('100%')
          .padding({ left: 16, right: 16, top: 0, bottom: 10 })
          .backgroundColor('#FFFFFF')
          .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])
        } else {
          this.buildSummaryTopHeader()
        }

        if (this.showOutlinePanel) {
          TrainOutlinePanel({
            courseName: this.courseName,
            courseCode: this.courseCode,
            progressText: this.getProgressText(),
            panelOffsetX: this.outlinePanelOffsetX,
            items: this.getVisibleItems(),
            completedItemIds: this.getCompletedItemIds(),
            currentIndex: this.currentItemIndex,
            isCourseFavorited: this.isCourseFavorited,
            onClose: () => {
              this.closeOutlinePanel()
            },
            onItemClick: (itemId: number, completed: boolean) => {
              this.handleOutlineItemClick(itemId, completed)
            },
            onCourseFavoriteToggle: (courseCode: string) => {
              this.onToggleCourseFavorite(courseCode)
            }
          })
        }

        }
        .layoutWeight(1)
        .gesture(
          PanGesture({ direction: PanDirection.Horizontal, distance: 8 })
            .onActionEnd((event) => {
              this.handleStageSwipe(event.offsetX, event.offsetY)
            })
        )
        .width('100%')
        .backgroundColor('#F4F7FB')
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])

        if (this.currentStage !== 'summary') {
          TrainBottomBar({
            showRetry: this.currentStage === 'result',
            isFavorited: this.isCurrentItemFavorited(),
            progressText: this.getProgressText(),
            onRetryClick: () => {
              this.resetTrainingFlow()
            },
            onFavoriteToggle: () => {
              this.toggleCurrentItemFavorite()
            },
            onOutlineToggle: () => {
              this.toggleOutlinePanel()
            }
          })
        }
      }
      .width('100%')
      .height('100%')

      if (this.isScoring) {
        this.buildScoringOverlay()
      }

    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F4F7FB')
  }

  @Builder
  private buildPreloadAssets(item: TrainingItem) {
    Column({ space: 2 }) {
      Image(this.getPrimaryCoverUrl(item))
        .width(1)
        .height(1)
        .opacity(0.01)

      if (item.videoPoster.length > 0) {
        Image(this.getVideoPosterUrl(item))
          .width(1)
          .height(1)
          .opacity(0.01)
      }

      ForEach(item.actionImages, (resource: MediaResourceItem) => {
        Image(resource.url)
          .width(1)
          .height(1)
          .opacity(0.01)
      }, (resource: MediaResourceItem) => resource.uid)
    }
    .width(1)
    .height(1)
    .clip(true)
    .position({ x: -9999, y: -9999 })
  }

  @Builder
  private buildScoringOverlay() {
    Stack({ alignContent: Alignment.Center }) {
      Column() {
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#660B1522')
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])

      Column({ space: 12 }) {
        LoadingProgress()
          .width(34)
          .height(34)
          .color('#2E79F4')

        Text(this.trainingType === 'speech' ? 'AI 正在评估发音...' : 'AI 正在评估动作...')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#1F2A44')

        Text(this.trainingType === 'speech'
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
  private buildTopHeader() {
    Column({ space: 10 }) {
      Stack({ alignContent: Alignment.Center }) {
        Text(this.getHeaderTitle())
          .width('100%')
          .padding({ left: 56, right: 56 })
          .textAlign(TextAlign.Center)
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1F2A44')
          .maxLines(1)

        Row() {
          Button() {
            SymbolGlyph($r('sys.symbol.chevron_backward'))
              .fontSize(15)
              .fontColor([
                this.currentStage !== 'summary' && !this.isScoring && !this.isStageAnimating
                  ? '#2E79F4'
                  : '#A6B4C8'
              ])
          }
            .width(34)
            .height(34)
            .backgroundColor('#F1F5FB')
            .borderRadius(17)
            .enabled(this.currentStage !== 'summary' && !this.isScoring && !this.isStageAnimating)
            .opacity(this.currentStage !== 'summary' && !this.isScoring && !this.isStageAnimating ? 1 : 0.5)
            .onClick(() => {
              this.handleHeaderBackAction()
            })

          Blank()

          if (this.currentStage === 'result' || this.currentStage === 'summary') {
            Button(this.getNextLabel())
              .height(34)
              .fontSize(12)
              .fontWeight(FontWeight.Medium)
              .fontColor('#FFFFFF')
              .backgroundColor('#2E79F4')
              .borderRadius(17)
              .padding({ left: 12, right: 12 })
              .enabled(!this.isScoring && !this.isStageAnimating)
              .opacity(this.isScoring || this.isStageAnimating ? 0.55 : 1)
              .onClick(() => {
                this.handleFloatingNext()
              })
          } else {
            Button() {
              SymbolGlyph($r('sys.symbol.chevron_forward'))
                .fontSize(15)
                .fontColor(['#FFFFFF'])
            }
              .width(34)
              .height(34)
              .backgroundColor('#2E79F4')
              .borderRadius(17)
              .enabled(!this.isScoring && !this.isStageAnimating)
              .opacity(this.isScoring || this.isStageAnimating ? 0.55 : 1)
              .onClick(() => {
                this.handleFloatingNext()
              })
          }
        }
        .width('100%')
      }
      .width('100%')

      Text(`${this.courseName} · 第 ${this.getProgressText()} 项 · ${this.getStageTitle()}`)
        .width('100%')
        .fontSize(12)
        .fontColor('#7A8CA7')
        .maxLines(1)
    }
    .width('100%')
  }

  @Builder
  private buildSummaryTopHeader() {
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
      .onClick(() => {
        this.finishCourseAndExit()
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

  private getHeaderTitle(): string {
    if (this.hasVisibleItems()) {
      return this.getCurrentItem().name
    }
    return this.courseName
  }

  @Builder
  private buildStageStepper() {
    Row({ space: 8 }) {
      this.buildStageDot(1, '介绍')
      this.buildStageDot(2, '视频')
      this.buildStageDot(3, '步骤')
      this.buildStageDot(4, '练习')
      this.buildStageDot(5, '评分')
    }
    .width('100%')
  }

  @Builder
  private buildStageDot(order: number, label: string) {
    Row({ space: 6 }) {
      Text(`${order}`)
        .width(20)
        .height(20)
        .textAlign(TextAlign.Center)
        .fontSize(11)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.getStageOrder() >= order ? '#FFFFFF' : '#7A8CA7')
        .backgroundColor(this.getStageOrder() >= order ? '#2E79F4' : '#E7EEF8')
        .borderRadius(10)

      Text(label)
        .fontSize(11)
        .fontWeight(this.getStageOrder() === order ? FontWeight.Medium : FontWeight.Regular)
        .fontColor(this.getStageOrder() === order ? '#2E79F4' : '#7A8CA7')
    }
    .padding({ left: 8, right: 8, top: 6, bottom: 6 })
    .backgroundColor(this.getStageOrder() === order ? '#EEF5FF' : '#F5F8FD')
    .borderRadius(14)
  }

  @Builder
  private buildIntroStage(item: TrainingItem) {
    IntroStageContent({
      item: item,
      coverUrl: this.getPrimaryCoverUrl(item)
    })
  }

  @Builder
  private buildVideoStage(item: TrainingItem) {
    Stack({ alignContent: Alignment.Center }) {
      Video({
        src: item.video[0].url,
        previewUri: this.getVideoPosterUrl(item),
        controller: this.videoController
      })
        .width(320)
        .height(568)
        .borderRadius(24)
        .controls(true)
        .autoPlay(true)
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  private buildGuideStage(item: TrainingItem) {
    GuideStageContent({ item: item })
  }

  @Builder
  private buildPracticeStage(item: TrainingItem) {
    Column({ space: 16 }) {
      if (this.trainingType === 'speech') {
        Row({ space: 10 }) {
          this.buildPracticeModeCard('audio', '录音练习', '音')
          this.buildPracticeModeCard('video', '录像练习', '视')
        }
        .width('100%')
      }

      Column({ space: 14 }) {
        Row({ space: 8 }) {
          Text(this.trainingType === 'speech'
            ? (this.practiceMode === 'audio' ? '音频跟读' : '视频跟练')
            : '手势跟练')
            .fontSize(11)
            .fontColor('#2E79F4')
            .padding({ left: 10, right: 10, top: 6, bottom: 6 })
            .backgroundColor('#EEF5FF')
            .borderRadius(12)

          Text(this.trainingType === 'speech'
            ? (this.practiceMode === 'audio' ? '发音节奏' : '口型动作')
            : '动作评估')
            .fontSize(11)
            .fontColor('#7A8CA7')
        }
        .width('100%')

        if (this.trainingType === 'speech' && this.practiceMode === 'audio' && item.audio.length > 0) {
          Text('先听示范，模仿更准')
            .width('100%')
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .fontColor('#1F2A44')

          Column({ space: 10 }) {
            Row() {
              Column({ space: 4 }) {
                Text('点右侧播放键，先完整听一遍示范发音')
                  .fontSize(11)
                  .fontColor('#7A8CA7')
              }
              .alignItems(HorizontalAlign.Start)

              Blank()

              Row() {
                Button() {
                  SymbolGlyph(this.isDemoAudioPlaying ? $r('sys.symbol.pause_fill') : $r('sys.symbol.play_fill'))
                    .fontSize(16)
                    .fontColor(['#2E79F4'])
                }
                  .width(36)
                  .height(30)
                  .backgroundColor('#EEF5FF')
                  .border({ width: 1, color: '#D8E6FB' })
                  .borderRadius(10)
                  .onClick(() => {
                    if (this.isDemoAudioPlaying) {
                      this.stopDemoAudioPlayback()
                    } else {
                      this.startDemoAudioPlayback()
                    }
                  })
              }
            }
            .width('100%')

            Column({ space: 8 }) {
              Stack({ alignContent: Alignment.Start }) {
                Row() {
                }
                .width('100%')
                .height(8)
                .backgroundColor('#D8E6FB')
                .borderRadius(4)

                Row() {
                }
                .width(this.getDemoAudioProgressPercentText())
                .height(8)
                .backgroundColor('#2E79F4')
                .borderRadius(4)
              }
              .width('100%')

              Row() {
                Text(this.formatDuration(this.demoAudioProgress))
                  .fontSize(11)
                  .fontColor('#6E7F98')

                Blank()

                Text(this.formatDuration(this.demoAudioDurationSec))
                  .fontSize(11)
                  .fontColor('#9AA8BD')
              }
              .width('100%')

              Row({ space: 6 }) {
                ForEach([0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11], (bar: number) => {
                  Column() {
                  }
                  .layoutWeight(1)
                  .height(this.getAudioWaveHeight(bar))
                  .borderRadius(4)
                  .backgroundColor(this.isDemoAudioPlaying ? '#58A6FF' : '#D7E6FB')
                }, (bar: number) => `${bar}`)
              }
              .width('100%')
              .height(24)
              .alignItems(VerticalAlign.Bottom)
            }
            .width('100%')

            Text('听完示范后上传你的跟读音频，系统会从清晰度和节奏给你反馈。')
              .width('100%')
              .fontSize(11)
              .lineHeight(18)
              .fontColor('#5F7593')

            Video({
              src: item.audio[0].url,
              controller: this.practiceVideoController
            })
              .width(1)
              .height(1)
              .controls(false)
              .autoPlay(false)
              .opacity(0.01)
              .loop(false)
              .onPrepared((event) => {
                if (event && event.duration > 0) {
                  this.applyDemoAudioDuration(event.duration)
                }
              })
              .onFinish(() => {
                this.demoAudioProgress = this.demoAudioDurationSec
                this.stopDemoAudioPlayback()
              })
          }
          .width('100%')
          .padding(12)
          .backgroundColor('#FFFFFF')
          .borderRadius(12)
          .border({ width: 1, color: '#E6EDF8' })
        }

        Text(this.trainingType === 'speech'
          ? (this.practiceMode === 'audio' ? '上传你的跟读音频' : '上传你的口语练习视频')
          : '上传你的手势练习视频')
          .width('100%')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor('#1F2A44')

        Text(this.trainingType === 'speech'
          ? (this.practiceMode === 'audio'
            ? (item.audio.length > 0 ? '先听示范，再录一遍，你会更容易拿到高分。' : '没有示范也没关系，直接上传你的练习音频即可。')
            : '建议横屏拍摄，口型清晰、语速稳定，评分会更准确。')
          : '请完整拍到手部和上半身动作，评估结果会更稳定。')
          .width('100%')
          .fontSize(13)
          .fontColor('#7A8CA7')
          .lineHeight(20)

        if (this.trainingType === 'speech' && this.practiceMode === 'audio') {
          Column({ space: 12 }) {
            Column({ space: 10 }) {
              Button('选择本地音频')
                .width(168)
                .height(44)
                .fontSize(15)
                .fontWeight(FontWeight.Medium)
                .fontColor('#FFFFFF')
                .backgroundColor('#2E79F4')
                .borderRadius(14)
                .onClick(() => {
                  this.openLocalAudioPicker()
                })

              if (this.recordedAudioUri.length > 0) {
                Text('已选好音频，继续加油')
                  .width('100%')
                  .fontSize(12)
                  .fontColor('#5F7593')
              }
            }
            .alignItems(HorizontalAlign.Start)
            .width('100%')
            .padding(12)
            .backgroundColor('#FFFFFF')
            .borderRadius(12)
            .border({ width: 1, color: '#E6EDF8' })
          }
          .alignItems(HorizontalAlign.Start)
          .width('100%')
          .padding(16)
          .backgroundColor('#F7FAFE')
          .borderRadius(16)
          .border({ width: 1, color: '#E4ECF8' })
        } else {
          Stack({ alignContent: Alignment.Center }) {
            Column() {
            }
            .width('100%')
            .height(220)
            .backgroundColor('#0D1B2A')
            .borderRadius(20)

            Column({ space: 14 }) {
              Text(this.trainingType === 'speech' ? '选好视频后，就能进入评分' : '选好手势视频后，就能进入评分')
                .fontSize(20)
                .fontWeight(FontWeight.Medium)
                .fontColor('#FFFFFF')

              Button(this.trainingType === 'speech' ? '选择本地视频' : '选择手势视频')
                .width(160)
                .height(46)
                .fontSize(15)
                .fontWeight(FontWeight.Medium)
                .fontColor('#0B1522')
                .backgroundColor('#FFFFFF')
                .borderRadius(16)
                .onClick(() => {
                  this.openLocalVideoPicker()
                })
            }
          }
          .width('100%')
          .height(220)
        }

        Text(this.trainingType === 'speech' && this.practiceMode === 'audio' ? this.audioCaptureTip : this.captureTip)
          .width('100%')
          .fontSize(12)
          .fontColor('#7A8CA7')
          .lineHeight(18)

        if ((this.trainingType !== 'speech' || this.practiceMode === 'video') && this.recordedVideoUri.length > 0) {
          Video({
            src: this.recordedVideoUri,
            controller: this.practiceVideoController
          })
            .width('100%')
            .height(220)
            .objectFit(ImageFit.Contain)
            .controls(true)
            .autoPlay(false)
            .borderRadius(20)
        }
      }
      .width('100%')
      .padding(18)
      .backgroundColor('#FFFFFF')
      .borderRadius(18)
      .shadow({ radius: 18, color: '#15304B10', offsetX: 0, offsetY: 8 })
    }
    .width('100%')
  }

  @Builder
  private buildPracticeModeCard(mode: string, label: string, shortLabel: string) {
    Column({ space: 10 }) {
      Stack({ alignContent: Alignment.Center }) {
        Row() {
        }
        .width(34)
        .height(34)
        .backgroundColor(this.practiceMode === mode ? '#FFFFFFEB' : '#EFF4FC')
        .borderRadius(12)
        .border({ width: 1, color: this.practiceMode === mode ? '#FFFFFF70' : '#D4DFEF' })

        Text(shortLabel)
          .fontSize(14)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.practiceMode === mode ? '#2E79F4' : '#5F7593')
      }
      .width(34)
      .height(34)

      Text(label)
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.practiceMode === mode ? '#FFFFFF' : '#4F6280')
    }
    .justifyContent(FlexAlign.Center)
    .layoutWeight(1)
    .height(92)
    .padding({ left: 12, right: 12, top: 10, bottom: 10 })
    .linearGradient({
      angle: 135,
      colors: this.practiceMode === mode ? [['#5BA9FF', 0], ['#2E79F4', 1]] : [['#F4F8FE', 0], ['#EAF1FB', 1]]
    })
    .borderRadius(20)
    .border({ width: 1, color: this.practiceMode === mode ? '#2E79F400' : '#DCE6F4' })
    .shadow({
      radius: this.practiceMode === mode ? 16 : 8,
      color: this.practiceMode === mode ? '#2E79F43D' : '#1D355012',
      offsetX: 0,
      offsetY: this.practiceMode === mode ? 8 : 4
    })
    .onClick(() => {
      this.practiceMode = mode
    })
  }

  @Builder
  private buildResultStage(item: TrainingItem) {
    ResultStageContent({
      itemName: item.name,
      score: this.mockScore
    })
  }

  @Builder
  private buildEmptyState() {
    Column({ space: 12 }) {
      Text('当前课程还没有训练项')
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .fontColor('#1F2A44')

      Button('返回课程列表')
        .width('100%')
        .height(46)
        .fontSize(15)
        .fontWeight(FontWeight.Medium)
        .fontColor('#2E79F4')
        .backgroundColor('#EEF5FF')
        .borderRadius(16)
        .onClick(() => {
          this.onBackToCourseList()
        })
    }
    .width('100%')
    .padding(24)
    .backgroundColor('#FFFFFF')
    .borderRadius(18)
  }
}




