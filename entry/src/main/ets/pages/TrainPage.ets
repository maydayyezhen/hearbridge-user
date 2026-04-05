import photoAccessHelper from '@ohos.file.photoAccessHelper'
import picker from '@ohos.file.picker'
import common from '@ohos.app.ability.common'
import { abilityAccessCtrl } from '@kit.AbilityKit'
import { speechRecognizer } from '@kit.CoreSpeechKit'
import { BusinessError } from '@kit.BasicServicesKit'
import { readToken } from '../api/AuthStorage'
import { uploadFileToServer } from '../api/FileUploadApi'
import {
  completeTrainingSession,
  getTrainingItemDetail,
  getTrainingSessionDetail,
  pauseTrainingSession,
  startTrainingSession,
  submitTrainingItem,
  TrainingResultDetailDto,
  TrainingResultDimensionDto,
  TrainingResultTagModuleDto,
  TrainingResultTrendDto,
  TrainingSessionItemDto
} from '../api/TrainingApi'
import { MediaResourceItem, TrainingItem, mapSessionItemToTrainingItem, mapTrainingItemDetailToTrainingItem } from './train/TrainData'
import { ResultStageContent } from './train/stages/ResultStageContent'
import { IntroStageContent } from './train/stages/IntroStageContent'
import { GuideStageContent } from './train/stages/GuideStageContent'
import { SummaryStageContent } from './train/stages/SummaryStageContent'
import { TrainBottomBar } from './train/components/TrainBottomBar'
import { TrainOutlinePanel } from './train/components/TrainOutlinePanel'

const SPEECH_LANGUAGE = 'zh-CN'
const MICROPHONE_AUDIO_INFO: speechRecognizer.AudioInfo = {
  audioType: 'pcm',
  sampleRate: 16000,
  soundChannel: 1,
  sampleBit: 16
}

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

class ResultDimensionEntry {
  label: string
  score: number

  constructor(label: string, score: number) {
    this.label = label
    this.score = score
  }
}

class ResultTagSection {
  title: string
  tags: string[]
  description: string

  constructor(title: string, tags: string[], description: string) {
    this.title = title
    this.tags = tags
    this.description = description
  }
}

class ResultTrendState {
  title: string
  scores: number[]
  description: string

  constructor(title: string, scores: number[], description: string) {
    this.title = title
    this.scores = scores
    this.description = description
  }
}

const COURSE_PROGRESS_CACHE: Map<string, CourseProgressSnapshot> = new Map()
const TRAINING_ITEM_DETAIL_FIELD_CACHE: Map<string, TrainingItem> = new Map()
class TrainingSessionFieldCacheEntry {
  sessionId: number = 0
  trainingType: string = 'gesture'
  currentItemCode: string = ''
  currentItemStatus: string = ''
  items: TrainingSessionItemDto[] = []
}
const TRAINING_SESSION_FIELD_CACHE: Map<string, TrainingSessionFieldCacheEntry> = new Map()

export function clearTrainingItemDetailFieldCache() {
  TRAINING_ITEM_DETAIL_FIELD_CACHE.clear()
  TRAINING_SESSION_FIELD_CACHE.clear()
}

@Component
export struct TrainPage {
  @Prop apiBaseUrl: string = ''
  @Prop courseName: string = '日常问候入门'
  @Prop courseCode: string = 'COURSE-101'
  @Prop trainingType: string = 'gesture'
  @Prop selectedPhrase: string = '你好'
  @Prop selectedItemCode: string = ''
  @Prop initialStage: string = 'intro'
  @Prop isCourseFavorited: boolean = false
  @Prop favoriteTrainingItemCodes: string[] = []
  @State currentItemIndex: number = 0
  @State currentStage: string = 'intro'
  @State practiceMode: string = 'video'
  @State isCapturing: boolean = false
  @State currentScore: number = 0
  @State resultTitle: string = ''
  @State resultScoreLabel: string = '训练得分'
  @State resultBadges: string[] = []
  @State resultDimensions: ResultDimensionEntry[] = []
  @State resultStrengths: ResultTagSection = new ResultTagSection('本次亮点', [], '')
  @State resultImprovements: ResultTagSection = new ResultTagSection('建议改进', [], '')
  @State resultRecentTrend: ResultTrendState = new ResultTrendState('最近表现', [], '')
  @State recordedVideoUri: string = ''
  @State recordedAudioUri: string = ''
  @State audioCaptureTip: string = '已就绪，选一段音频开始跟读吧。'
  @State captureTip: string = '已就绪，选一段视频开始练习吧。'
  @State isLaunchingVideoCapture: boolean = false
  @State isLaunchingAudioCapture: boolean = false
  @State speechRecognizedText: string = ''
  @State speechPartialText: string = ''
  @State speechStatusText: string = '点击开始识别后直接说话，系统会实时显示识别内容。'
  @State isSpeechEngineReady: boolean = false
  @State isSpeechPreparing: boolean = false
  @State isSpeechListening: boolean = false
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
  @State stageContentOpacity: number = 1
  @State stageContentOffsetX: number = 0
  @State isStageAnimating: boolean = false
  @State resolvedTrainingType: string = ''
  @State sessionId: number = 0
  @State sessionFavorite: boolean = false
  @State trainingTip: string = ''
  @State isSessionLoading: boolean = false
  @State isCurrentItemDetailLoading: boolean = false
  @State trainingItems: TrainingItem[] = []
  onSelectPhrase: (phrase: string) => void = () => {}
  onBackToCourseList: () => void = () => {}
  onCompleteTraining: () => void = () => {}
  onTrainingItemCompleted: (itemCode: string) => void = (_itemCode: string) => {}
  onRecentCourseTouched: (progressPercent: number) => void = (_progressPercent: number) => {}
  onScoringStateChange: (isScoring: boolean) => void = () => {}
  onToggleCourseFavorite: (courseCode: string) => void = (_courseCode: string) => {}
  onToggleTrainingItemFavorite: (itemCode: string) => void = (_itemCode: string) => {}

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
  private speechSessionId: string = ''
  private speechEngine: speechRecognizer.SpeechRecognitionEngine | undefined = undefined
  private shouldAutoStartSpeechRecognition: boolean = false
  aboutToAppear() {
    this.initializeTrainingSession()
  }

  aboutToDisappear() {
    this.clearDemoAudioTimer()
    this.clearScoringTimer()
    this.clearStageTransitionTimer()
    this.clearOutlinePanelTimer()
    this.setScoringState(false)
    this.shutdownSpeechEngine()
  }

  private getAbilityContext(): common.BaseContext {
    return this.getUIContext().getHostContext() as common.BaseContext
  }

  private getTrainingSessionCacheKey(): string {
    return `${this.courseCode}|${this.normalizeTrainingType(this.trainingType)}`
  }

  private async initializeTrainingSession() {
    this.isSessionLoading = true
    this.resolvedTrainingType = this.normalizeTrainingType(this.trainingType)
    this.trainingTip = '正在同步训练进度...'
    try {
      const cachedSession = TRAINING_SESSION_FIELD_CACHE.get(this.getTrainingSessionCacheKey())
      if (cachedSession) {
        this.sessionId = cachedSession.sessionId
        this.resolvedTrainingType = this.normalizeTrainingType(cachedSession.trainingType)
        this.trainingItems = this.mapTrainingItems(cachedSession.trainingType, cachedSession.items)
        this.hydrateCourseScores(cachedSession.items)
        const preferredItemCode = this.selectedItemCode.trim().length > 0 ? this.selectedItemCode : cachedSession.currentItemCode
        const preferredItemStatus = preferredItemCode === cachedSession.currentItemCode ? cachedSession.currentItemStatus : ''
        await this.syncCurrentItemFromSelection(preferredItemCode, preferredItemStatus)
        this.trainingTip = ''
        return
      }

      const token = await readToken(this.getAbilityContext())
      if (token.length === 0) {
        this.trainingItems = []
        this.trainingTip = '登录已失效，请重新登录。'
        return
      }

      const startResult = await startTrainingSession(this.apiBaseUrl, token, this.courseCode)
      if (!startResult.ok || !startResult.data) {
        this.trainingItems = []
        this.trainingTip = startResult.message.length > 0 ? startResult.message : `训练会话启动失败（错误码 ${startResult.code}）`
        return
      }

      this.sessionId = startResult.data.sessionId
      const preferredItemCode = this.selectedItemCode.trim().length > 0 ? this.selectedItemCode : startResult.data.currentItemCode
      const preferredItemStatus = preferredItemCode === startResult.data.currentItemCode ? startResult.data.currentItemStatus : ''
      await this.refreshTrainingSessionDetail(token, preferredItemCode, preferredItemStatus)
      this.trainingTip = ''
    } catch (_error) {
      this.trainingItems = []
      this.trainingTip = '网络异常，无法获取训练会话。'
    } finally {
      this.isSessionLoading = false
    }
  }

  private async refreshTrainingSessionDetail(token: string, preferredItemCode: string = '', preferredItemStatus: string = '') {
    const detailResult = await getTrainingSessionDetail(this.apiBaseUrl, token, this.sessionId)
    if (!detailResult.ok || !detailResult.data) {
      this.trainingItems = []
      this.trainingTip = detailResult.message.length > 0 ? detailResult.message : `训练详情加载失败（错误码 ${detailResult.code}）`
      return
    }

    this.resolvedTrainingType = this.normalizeTrainingType(detailResult.data.trainingType)
    this.sessionFavorite = detailResult.data.favorite
    this.trainingItems = this.mapTrainingItems(detailResult.data.trainingType, detailResult.data.items)
    this.hydrateCourseScores(detailResult.data.items)
    const cacheEntry = new TrainingSessionFieldCacheEntry()
    cacheEntry.sessionId = this.sessionId
    cacheEntry.trainingType = detailResult.data.trainingType
    cacheEntry.currentItemCode = detailResult.data.currentItemCode
    cacheEntry.currentItemStatus = preferredItemStatus
    cacheEntry.items = detailResult.data.items
    TRAINING_SESSION_FIELD_CACHE.set(this.getTrainingSessionCacheKey(), cacheEntry)
    await this.syncCurrentItemFromSelection(preferredItemCode, preferredItemStatus)
  }

  private normalizeTrainingType(value: string): string {
    if (value === 'voice' || value === 'speech') {
      return 'speech'
    }
    return 'gesture'
  }

  private isSpeechTraining(): boolean {
    return this.resolvedTrainingType === 'speech'
  }

  private mapTrainingItems(trainingType: string, items: TrainingSessionItemDto[]): TrainingItem[] {
    const mapped: TrainingItem[] = []
    for (let i = 0; i < items.length; i += 1) {
      const cacheKey = this.getTrainingItemDetailCacheKey(items[i].itemCode)
      const cachedItem = TRAINING_ITEM_DETAIL_FIELD_CACHE.get(cacheKey)
      if (cachedItem) {
        mapped.push(new TrainingItem(
          i + 1,
          cachedItem.name,
          cachedItem.code,
          cachedItem.majorCategoryCode,
          cachedItem.levelNum,
          cachedItem.isRecommended,
          items[i].itemOrder,
          items[i].status,
          cachedItem.meaning,
          cachedItem.description,
          cachedItem.goal,
          cachedItem.precautions,
          cachedItem.commonErrors,
          cachedItem.cover,
          cachedItem.video,
          cachedItem.audio,
          cachedItem.actionImages,
          cachedItem.videoPoster
        ))
      } else {
        mapped.push(mapSessionItemToTrainingItem(items[i], trainingType, i))
      }
    }
    mapped.sort((left: TrainingItem, right: TrainingItem) => left.sortNum - right.sortNum)
    return mapped
  }

  private getTrainingItemDetailCacheKey(itemCode: string): string {
    return `${this.courseCode}|${itemCode}`
  }

  private async loadItemDetailAtIndex(index: number) {
    const items: TrainingItem[] = this.getVisibleItems()
    if (index < 0 || index >= items.length || this.sessionId <= 0) {
      return
    }
    const currentItem = items[index]
    if (currentItem.description.length > 0 || currentItem.goal.length > 0 || currentItem.cover.length > 0 || currentItem.video.length > 0) {
      if (currentItem.status === 'completed' && this.getCurrentItemScore() <= 0) {
        this.currentScore = this.getStoredScoreByItemId(currentItem.id)
      }
      return
    }

    this.isCurrentItemDetailLoading = true
    try {
      const token = await readToken(this.getAbilityContext())
      if (token.length === 0) {
        this.trainingTip = '登录已失效，请重新登录。'
        return
      }
      const detailResult = await getTrainingItemDetail(this.apiBaseUrl, token, this.sessionId, currentItem.code)
      if (!detailResult.ok || !detailResult.data) {
        this.trainingTip = detailResult.message.length > 0 ? detailResult.message : '训练项详情加载失败。'
        return
      }

      const updated: TrainingItem[] = []
      for (let i = 0; i < this.trainingItems.length; i += 1) {
        if (this.trainingItems[i].code === currentItem.code) {
          const detailItem = mapTrainingItemDetailToTrainingItem(detailResult.data, this.resolvedTrainingType, i)
          TRAINING_ITEM_DETAIL_FIELD_CACHE.set(this.getTrainingItemDetailCacheKey(currentItem.code), detailItem)
          updated.push(detailItem)
        } else {
          updated.push(this.trainingItems[i])
        }
      }
      this.trainingItems = updated
      if (detailResult.data.score !== null) {
        this.upsertCourseScoreByItemCode(currentItem.code, Math.round(Number(detailResult.data.score)))
        if (this.currentItemIndex === index) {
          this.currentScore = Math.round(Number(detailResult.data.score))
        }
      }
    } catch (_error) {
      this.trainingTip = '训练项详情加载失败，请检查网络后重试。'
    } finally {
      this.isCurrentItemDetailLoading = false
    }
  }

  private getStoredScoreByItemId(itemId: number): number {
    for (let i = 0; i < this.courseScoreEntries.length; i += 1) {
      if (this.courseScoreEntries[i].itemId === itemId) {
        return this.courseScoreEntries[i].score
      }
    }
    return 0
  }

  private upsertCourseScoreByItemCode(itemCode: string, score: number) {
    for (let i = 0; i < this.trainingItems.length; i += 1) {
      if (this.trainingItems[i].code === itemCode) {
        let found = false
        for (let j = 0; j < this.courseScoreEntries.length; j += 1) {
          if (this.courseScoreEntries[j].itemId === this.trainingItems[i].id) {
            this.courseScoreEntries[j].score = score
            found = true
            break
          }
        }
        if (!found) {
          this.courseScoreEntries.push(new CourseScoreEntry(this.trainingItems[i].id, score))
        }
        this.refreshSummaryStats()
        return
      }
    }
  }

  private hydrateCourseScores(items: TrainingSessionItemDto[]) {
    this.resetCourseSummary()
  }

  private async syncCurrentItemFromSelection(preferredItemCode: string = '', preferredItemStatus: string = '') {
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

    if (preferredItemCode.length > 0) {
      for (let index = 0; index < items.length; index += 1) {
        if (items[index].code === preferredItemCode) {
          selectedIndex = index
          break
        }
      }
    }

    if (selectedIndex >= 0) {
      this.currentItemIndex = selectedIndex
      this.onSelectPhrase(items[this.currentItemIndex].name)
    } else {
      this.currentItemIndex = 0
      this.onSelectPhrase(items[this.currentItemIndex].name)
    }

    this.resetTrainingFlow()
    await this.loadItemDetailAtIndex(this.currentItemIndex)
    this.applyInitialStage(preferredItemStatus)
  }

  private applyInitialStage(preferredItemStatus: string = '') {
    this.currentStage = 'intro'
  }

  private resetCourseSummary() {
    this.courseScoreEntries = []
    this.summaryCompletedCount = 0
    this.summaryAverageScore = 0
    this.summaryBestScore = 0
    this.resetResultDetailState()
  }

  private resetTrainingFlow(resetAnimationState: boolean = true) {
    if (resetAnimationState) {
      this.clearStageTransitionTimer()
      this.isStageAnimating = false
      this.stageContentOpacity = 1
      this.stageContentOffsetX = 0
    }
    this.currentStage = 'intro'
    this.practiceMode = this.isSpeechTraining() ? 'audio' : 'video'
    this.isCapturing = false
    this.setScoringState(false)
    this.clearScoringTimer()
    this.resetResultDetailState()
    this.currentScore = this.getCurrentItemScore()
    this.recordedVideoUri = ''
    this.recordedAudioUri = ''
    this.speechRecognizedText = ''
    this.speechPartialText = ''
    this.speechStatusText = this.isSpeechTraining() ? '点击开始识别后直接说话，系统会实时显示识别内容。' : this.speechStatusText
    this.summaryMode = 'completed'
    this.summaryPausedAtName = ''
    this.stopDemoAudioPlayback()
    this.stopSpeechRecognition(false)
    if (this.isSpeechTraining()) {
      this.audioCaptureTip = '已就绪，选一段音频开始跟读吧。'
      this.captureTip = '已就绪，选一段视频开始练习吧。'
    } else {
      this.audioCaptureTip = '当前是手势训练，请使用视频练习。'
      this.captureTip = '已就绪，选一段手势视频开始练习吧。'
    }
  }

  private getCourseProgressKey(): string {
    return `${this.courseCode}|${this.resolvedTrainingType}`
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

  private getCurrentItemScore(): number {
    const current = this.getCurrentItem()
    if (current.id <= 0) {
      return 0
    }
    for (let i = 0; i < this.courseScoreEntries.length; i += 1) {
      if (this.courseScoreEntries[i].itemId === current.id) {
        return this.courseScoreEntries[i].score
      }
    }
    return 0
  }

  private getHighestScore(): number {
    let best = 0
    for (let i = 0; i < this.courseScoreEntries.length; i += 1) {
      if (this.courseScoreEntries[i].score > best) {
        best = this.courseScoreEntries[i].score
      }
    }
    return best
  }

  private resetResultDetailState() {
    this.resultTitle = ''
    this.resultScoreLabel = '训练得分'
    this.resultBadges = []
    this.resultDimensions = []
    this.resultStrengths = new ResultTagSection('本次亮点', [], '')
    this.resultImprovements = new ResultTagSection('建议改进', [], '')
    this.resultRecentTrend = new ResultTrendState('最近表现', [], '')
  }

  private mapResultDimensions(source: TrainingResultDimensionDto[]): ResultDimensionEntry[] {
    const result: ResultDimensionEntry[] = []
    for (let i = 0; i < source.length; i += 1) {
      result.push(new ResultDimensionEntry(source[i].label, Math.round(Number(source[i].score))))
    }
    return result
  }

  private mapResultTagSection(source: TrainingResultTagModuleDto | null, defaultTitle: string): ResultTagSection {
    if (source === null) {
      return new ResultTagSection('', [], '')
    }
    return new ResultTagSection(source.title, source.tags, source.description)
  }

  private mapResultTrend(source: TrainingResultTrendDto | null): ResultTrendState {
    if (source === null) {
      return new ResultTrendState('', [], '')
    }
    return new ResultTrendState(source.title, source.scores, source.description)
  }

  private applySubmitStatus(itemCode: string, itemStatus: string, nextItemCode: string, nextItemStatus: string) {
    const updatedItems: TrainingItem[] = []
    for (let i = 0; i < this.trainingItems.length; i += 1) {
      const current = this.trainingItems[i]
      if (current.code === itemCode && itemStatus.length > 0) {
        current.status = itemStatus
      } else if (current.code === nextItemCode && nextItemStatus.length > 0) {
        current.status = nextItemStatus
      }
      updatedItems.push(current)
    }
    this.trainingItems = updatedItems
    const cacheEntry = TRAINING_SESSION_FIELD_CACHE.get(this.getTrainingSessionCacheKey())
    if (!cacheEntry) {
      return
    }
    cacheEntry.currentItemCode = nextItemCode.length > 0 ? nextItemCode : itemCode
    cacheEntry.currentItemStatus = nextItemStatus.length > 0 ? nextItemStatus : itemStatus
    const nextSessionItems: TrainingSessionItemDto[] = []
    for (let i = 0; i < cacheEntry.items.length; i += 1) {
      const current = cacheEntry.items[i]
      if (current.itemCode === itemCode && itemStatus.length > 0) {
        current.status = itemStatus
      } else if (current.itemCode === nextItemCode && nextItemStatus.length > 0) {
        current.status = nextItemStatus
      }
      nextSessionItems.push(current)
    }
    cacheEntry.items = nextSessionItems
  }

  private applyResultDetail(detail: TrainingResultDetailDto | null) {
    if (detail === null) {
      this.resetResultDetailState()
      return
    }
    this.resultTitle = detail.title
    this.resultScoreLabel = detail.scoreLabel
    this.resultBadges = detail.badges
    this.resultDimensions = this.mapResultDimensions(detail.dimensions)
    this.resultStrengths = this.mapResultTagSection(detail.strengths, '')
    this.resultImprovements = this.mapResultTagSection(detail.improvements, '')
    this.resultRecentTrend = this.mapResultTrend(detail.recentTrend)
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
      if (item.status === 'published' || item.status === 'enabled' || item.status === 'completed' || item.status === 'in_progress' ||
        item.status === 'not_started' || item.status === 'skipped') {
        items.push(item)
      }
    }
    items.sort((left: TrainingItem, right: TrainingItem) => left.sortNum - right.sortNum)
    return items
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

  private hasLoadedItemDetail(item: TrainingItem): boolean {
    return item.meaning.length > 0 || item.description.length > 0 || item.goal.length > 0 || item.cover.length > 0 ||
      item.video.length > 0 || item.audio.length > 0 || item.actionImages.length > 0
  }

  private getPrimaryCoverUrl(item: TrainingItem): string {
    if (item.cover.length > 0) {
      return item.cover[0].url
    }
    return ''
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

  private async selectItem(index: number) {
    const items: TrainingItem[] = this.getVisibleItems()
    if (items.length === 0) {
      return
    }
    this.currentItemIndex = Math.min(items.length - 1, Math.max(0, index))
    this.onSelectPhrase(items[this.currentItemIndex].name)
    this.resetTrainingFlow()
    await this.loadItemDetailAtIndex(this.currentItemIndex)
  }

  private async switchItemWithAnimation(targetIndex: number, forward: boolean, targetStage: string = 'intro') {
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
    await this.loadItemDetailAtIndex(this.currentItemIndex)
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
        this.switchItemWithAnimation(this.currentItemIndex - 1, false, 'intro')
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

  private extractFileName(fileUri: string): string {
    const slashIndex = fileUri.lastIndexOf('/')
    if (slashIndex >= 0 && slashIndex < fileUri.length - 1) {
      return fileUri.substring(slashIndex + 1)
    }
    return `training_${Date.now()}`
  }

  private getMimeTypeForCurrentPractice(fileName: string): string {
    const lower = fileName.toLowerCase()
    if (this.isSpeechTraining() && this.practiceMode === 'audio') {
      if (lower.endsWith('.wav')) {
        return 'audio/wav'
      }
      if (lower.endsWith('.aac')) {
        return 'audio/aac'
      }
      if (lower.endsWith('.ogg')) {
        return 'audio/ogg'
      }
      return 'audio/mpeg'
    }
    if (lower.endsWith('.mov')) {
      return 'video/quicktime'
    }
    return 'video/mp4'
  }

  private createSpeechEngine() {
    if (!this.isSpeechTraining() || this.practiceMode !== 'audio') {
      return
    }
    if (this.isSpeechPreparing) {
      return
    }
    if (this.isSpeechListening) {
      this.speechStatusText = '识别中，请先停止后再重建识别引擎。'
      return
    }

    try {
      this.speechEngine?.shutdown()
    } catch (_err) {
    }

    this.speechStatusText = '正在初始化语音识别...'
    this.speechRecognizedText = ''
    this.speechPartialText = ''
    this.isSpeechEngineReady = false
    this.isSpeechPreparing = true

    const createParams: speechRecognizer.CreateEngineParams = {
      language: SPEECH_LANGUAGE,
      online: 1,
      extraParams: {
        locate: 'CN',
        recognizerMode: 'short'
      }
    }

    speechRecognizer.createEngine(createParams, (err: BusinessError, engine: speechRecognizer.SpeechRecognitionEngine) => {
      this.isSpeechPreparing = false
      if (err) {
        this.speechStatusText = `语音识别初始化失败（${err.code}）`
        this.shouldAutoStartSpeechRecognition = false
        return
      }
      this.speechEngine = engine
      this.bindSpeechListener()
      this.isSpeechEngineReady = true
      this.speechStatusText = '识别引擎已就绪，点击开始识别后直接说话。'
      if (this.shouldAutoStartSpeechRecognition) {
        this.shouldAutoStartSpeechRecognition = false
        this.startSpeechRecognition()
      }
    })
  }

  private bindSpeechListener() {
    if (!this.speechEngine) {
      return
    }
    const listener: speechRecognizer.RecognitionListener = {
      onStart: (_sessionId: string, _eventMessage: string) => {
        this.speechStatusText = '正在监听，请直接说出练习内容。'
        this.speechPartialText = ''
        this.speechRecognizedText = ''
      },
      onEvent: (_sessionId: string, _eventCode: number, _eventMessage: string) => {
      },
      onResult: (_sessionId: string, result: speechRecognizer.SpeechRecognitionResult) => {
        const text = result.result ?? ''
        this.speechRecognizedText = text
        this.speechPartialText = text
      },
      onComplete: (_sessionId: string, _eventMessage: string) => {
        this.isSpeechListening = false
        this.speechSessionId = ''
        if (this.speechRecognizedText.trim().length > 0) {
          this.audioCaptureTip = '识别完成，可以直接提交评分。'
          this.speechStatusText = '识别完成，确认文本后可直接评分。'
        } else {
          this.speechStatusText = '没有识别到清晰语音，再试一次。'
        }
      },
      onError: (_sessionId: string, errorCode: number, _errorMessage: string) => {
        this.isSpeechListening = false
        this.speechSessionId = ''
        this.speechStatusText = `识别失败（${errorCode}），请重试。`
      }
    }
    this.speechEngine.setListener(listener)
  }

  private async ensureMicrophonePermission(): Promise<boolean> {
    try {
      const atManager = abilityAccessCtrl.createAtManager()
      const result = await atManager.requestPermissionsFromUser(
        this.getAbilityContext() as common.UIAbilityContext,
        ['ohos.permission.MICROPHONE']
      )
      const authResults = result.authResults
      if (!authResults || authResults.length === 0) {
        return false
      }
      return authResults[0] === 0
    } catch (_err) {
      return false
    }
  }

  private async startSpeechRecognition() {
    const hasPermission = await this.ensureMicrophonePermission()
    if (!hasPermission) {
      this.isSpeechPreparing = false
      this.isSpeechListening = false
      this.shouldAutoStartSpeechRecognition = false
      this.speechStatusText = '未获得麦克风权限，无法开始识别。'
      return
    }
    if (this.isSpeechPreparing) {
      return
    }
    if (!this.isSpeechEngineReady || !this.speechEngine) {
      this.shouldAutoStartSpeechRecognition = true
      this.createSpeechEngine()
      return
    }
    this.shouldAutoStartSpeechRecognition = false
    this.speechSessionId = `${Date.now()}`
    this.speechRecognizedText = ''
    this.speechPartialText = ''
    const startParams: speechRecognizer.StartParams = {
      sessionId: this.speechSessionId,
      audioInfo: MICROPHONE_AUDIO_INFO,
      extraParams: {
        recognitionMode: 0,
        vadBegin: 2000,
        vadEnd: 3000,
        maxAudioDuration: 60000
      }
    }

    try {
      this.speechEngine.startListening(startParams)
      this.isSpeechListening = true
      this.audioCaptureTip = '正在实时识别，请直接说话。'
      this.speechStatusText = '正在监听，请直接说出练习内容。'
    } catch (err) {
      const error = err as BusinessError
      this.isSpeechListening = false
      this.speechStatusText = `开始识别失败（${error.code}）`
    }
  }

  private stopSpeechRecognition(updateTip: boolean = true) {
    if (!this.speechEngine || this.speechSessionId.length === 0 || !this.isSpeechListening) {
      return
    }
    try {
      this.speechEngine.finish(this.speechSessionId)
      this.isSpeechListening = false
      if (updateTip) {
        this.speechStatusText = '正在停止识别，等待最终结果...'
      }
    } catch (err) {
      const error = err as BusinessError
      this.isSpeechListening = false
      if (updateTip) {
        this.speechStatusText = `停止识别失败（${error.code}）`
      }
    }
  }

  private shutdownSpeechEngine() {
    try {
      this.speechEngine?.shutdown()
    } catch (_err) {
    }
    this.speechEngine = undefined
    this.speechSessionId = ''
    this.isSpeechEngineReady = false
    this.isSpeechPreparing = false
    this.isSpeechListening = false
    this.shouldAutoStartSpeechRecognition = false
  }

  private async submitPractice() {
    if (this.isScoring || this.isStageAnimating) {
      return
    }
    this.trainingTip = ''
    const item = this.getCurrentItem()
    if (item.id <= 0 || this.sessionId <= 0) {
      this.trainingTip = '当前训练会话还没准备好，请稍后重试。'
      return
    }
    const isSpeechAsrMode = this.isSpeechTraining() && this.practiceMode === 'audio'
    const localUri = isSpeechAsrMode ? '' : this.recordedVideoUri
    if (isSpeechAsrMode) {
      if (this.isSpeechListening) {
        this.audioCaptureTip = '请先停止识别，等待最终文本后再评分。'
        return
      }
      if (this.speechRecognizedText.trim().length === 0) {
        this.audioCaptureTip = '请先完成一次实时识别，再进行评分。'
        return
      }
    } else if (localUri.length === 0) {
      this.captureTip = '请先选择一段本地视频，再进行评分。'
      return
    }

    this.isCapturing = false
    const wasCompleted = item.status === 'completed'
    this.trainingTip = isSpeechAsrMode ? '正在提交识别结果...' : '正在上传练习文件...'
    this.setScoringState(true)
    try {
      const token = await readToken(this.getAbilityContext())
      if (token.length === 0) {
        this.trainingTip = '登录已失效，请重新登录。'
        return
      }
      let fileName = ''
      let mimeType = ''
      let fileUrl = ''
      if (!isSpeechAsrMode) {
        fileName = this.extractFileName(localUri)
        mimeType = this.getMimeTypeForCurrentPractice(fileName)
        const uploadResult = await uploadFileToServer(this.getAbilityContext() as common.UIAbilityContext,
          this.apiBaseUrl, token, localUri, fileName, mimeType)
        if (!uploadResult.ok || !uploadResult.data) {
          this.trainingTip = uploadResult.message.length > 0 ? uploadResult.message : '练习文件上传失败。'
          return
        }
        fileUrl = uploadResult.data
      }

      this.trainingTip = '正在生成评分结果...'
      const submitResult = await submitTrainingItem(this.apiBaseUrl, token, this.sessionId, item.code, {
        submitType: isSpeechAsrMode ? 'audio' : 'video',
        fileUrl,
        fileName,
        mimeType,
        recognizedText: isSpeechAsrMode ? this.speechRecognizedText : '',
        partialText: isSpeechAsrMode ? this.speechPartialText : '',
        submitResult: 'success',
        viewedDemo: this.hasVideo(item),
        finished: true,
        retried: this.getCurrentItemScore() > 0,
        firstSuccess: this.getCurrentItemScore() <= 0
      })
      if (!submitResult.ok || !submitResult.data) {
        this.trainingTip = submitResult.message.length > 0 ? submitResult.message : '训练评分失败。'
        return
      }

      this.currentScore = Math.round(Number(submitResult.data.score))
      this.applyResultDetail(submitResult.data.resultDetail)
      this.recordCurrentItemScore(this.currentScore)
      this.onRecentCourseTouched(Number(submitResult.data.progressPercent ?? 0))
      this.applySubmitStatus(
        submitResult.data.itemCode,
        submitResult.data.itemStatus,
        submitResult.data.nextItemCode ?? '',
        submitResult.data.nextItemStatus ?? ''
      )
      if (!wasCompleted && submitResult.data.itemStatus === 'completed') {
        this.onTrainingItemCompleted(submitResult.data.itemCode)
      }
      if (submitResult.data.courseCompleted) {
        const completeResult = await completeTrainingSession(this.apiBaseUrl, token, this.sessionId)
        if (completeResult.ok && completeResult.data) {
          this.summaryMode = 'completed'
          this.summaryCompletedCount = completeResult.data.completedItemCount
          this.summaryAverageScore = completeResult.data.totalScore === null ? this.summaryAverageScore : Math.round(Number(completeResult.data.totalScore))
          this.summaryBestScore = this.getHighestScore()
        }
      }
      this.setScoringState(false)
      this.trainingTip = ''
      this.transitionToStage('result', true)
    } catch (_error) {
      this.trainingTip = '提交练习失败，请检查网络后重试。'
    } finally {
      this.setScoringState(false)
    }
  }

  private async openLocalVideoPicker() {
    if (this.isLaunchingVideoCapture) {
      return
    }

    this.isLaunchingVideoCapture = true
    this.captureTip = '正在打开视频选择...'

    try {
      let documentPicker = new picker.DocumentViewPicker()
      let documentSelectOptions = new picker.DocumentSelectOptions()
      documentSelectOptions.maxSelectNumber = 1
      documentSelectOptions.fileSuffixFilters = ['视频|.mp4,.mov,.m4v,.3gp,.mkv,.webm']

      const documentSelectResult = await documentPicker.select(documentSelectOptions) as Array<string>
      if (documentSelectResult.length > 0) {
        this.recordedVideoUri = documentSelectResult[0]
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
    this.onBackToCourseList()
  }

  private async handlePauseConfirm() {
    const item = this.getCurrentItem()
    if (this.sessionId <= 0) {
      this.summaryMode = 'paused'
      this.summaryPausedAtName = item.name
      this.transitionToStage('summary', true)
      return
    }
    try {
      const token = await readToken(this.getAbilityContext())
      if (token.length === 0) {
        this.trainingTip = '登录已失效，请重新登录。'
        return
      }
      const pauseResult = await pauseTrainingSession(this.apiBaseUrl, token, this.sessionId)
      if (!pauseResult.ok || !pauseResult.data) {
        this.trainingTip = pauseResult.message.length > 0 ? pauseResult.message : '暂停训练失败。'
        return
      }
      this.summaryMode = 'paused'
      this.summaryPausedAtName = item.name
      this.transitionToStage('summary', true)
    } catch (_error) {
      this.trainingTip = '暂停训练失败，请稍后重试。'
    }
  }

  private handleHeaderBackAction() {
    if (this.currentStage === 'summary' || this.isScoring || this.isStageAnimating) {
      return
    }
    if (this.currentStage === 'result') {
      this.finishCourseAndExit()
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
    const currentCode = this.getCurrentItem().code
    if (currentCode.length === 0) {
      return false
    }
    for (let i = 0; i < this.favoriteTrainingItemCodes.length; i += 1) {
      if (this.favoriteTrainingItemCodes[i] === currentCode) {
        return true
      }
    }
    return false
  }

  private toggleCurrentItemFavorite() {
    const currentCode = this.getCurrentItem().code
    if (currentCode.length === 0) {
      return
    }
    this.onToggleTrainingItemFavorite(currentCode)
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
    const items: TrainingItem[] = this.getVisibleItems()
    for (let i = 0; i < items.length; i += 1) {
      if (items[i].status === 'completed') {
        result.push(items[i].id)
      }
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

  private async handleOutlineItemClick(itemId: number, completed: boolean) {
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

    await this.selectItem(targetIndex)
    this.currentStage = 'intro'
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
                if (this.isCurrentItemDetailLoading && !this.hasLoadedItemDetail(this.getCurrentItem())) {
                  this.buildItemDetailLoadingState()
                } else {
                  this.buildIntroStage(this.getCurrentItem())
                }
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
                trainingType: this.resolvedTrainingType,
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
      if (this.getPrimaryCoverUrl(item).length > 0) {
        Image(this.getPrimaryCoverUrl(item))
          .width(1)
          .height(1)
          .opacity(0.01)
      }

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
      if (this.isSpeechTraining()) {
        Row({ space: 10 }) {
          this.buildPracticeModeCard('audio', '录音练习', '音')
          this.buildPracticeModeCard('video', '录像练习', '视')
        }
        .width('100%')
      }

      Column({ space: 14 }) {
        Row({ space: 8 }) {
          Text(this.isSpeechTraining()
            ? (this.practiceMode === 'audio' ? '音频跟读' : '视频跟练')
            : '手势跟练')
            .fontSize(11)
            .fontColor('#2E79F4')
            .padding({ left: 10, right: 10, top: 6, bottom: 6 })
            .backgroundColor('#EEF5FF')
            .borderRadius(12)

          Text(this.isSpeechTraining()
            ? (this.practiceMode === 'audio' ? '发音节奏' : '口型动作')
            : '动作评估')
            .fontSize(11)
            .fontColor('#7A8CA7')
        }
        .width('100%')

        if (this.isSpeechTraining() && this.practiceMode === 'audio' && item.audio.length > 0) {
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

        Text(this.isSpeechTraining()
          ? (this.practiceMode === 'audio' ? '实时语音识别练习' : '上传你的口语练习视频')
          : '上传你的手势练习视频')
          .width('100%')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor('#1F2A44')

        Text(this.isSpeechTraining()
          ? (this.practiceMode === 'audio'
            ? (item.audio.length > 0 ? '先听示范，再直接开口练习，系统会实时显示识别结果。' : '直接开始说话，系统会实时显示识别结果并用于评分。')
            : '建议横屏拍摄，口型清晰、语速稳定，评分会更准确。')
          : '请完整拍到手部和上半身动作，评估结果会更稳定。')
          .width('100%')
          .fontSize(13)
          .fontColor('#7A8CA7')
          .lineHeight(20)

        if (this.isSpeechTraining() && this.practiceMode === 'audio') {
          Column({ space: 12 }) {
            Column({ space: 10 }) {
              Button(this.isSpeechPreparing ? '正在准备识别...' : (this.isSpeechListening ? '停止识别' : '开始识别'))
                .width('100%')
                .height(44)
                .fontSize(14)
                .fontWeight(FontWeight.Medium)
                .fontColor('#FFFFFF')
                .backgroundColor(this.isSpeechListening ? '#F97373' : '#2E79F4')
                .borderRadius(14)
                .enabled(!this.isSpeechPreparing)
                .onClick(() => {
                  if (this.isSpeechListening) {
                    this.stopSpeechRecognition()
                  } else {
                    this.startSpeechRecognition()
                  }
                })

              if (this.speechRecognizedText.trim().length > 0) {
                Text('识别完成，继续提交评分')
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

            Column({ space: 8 }) {
              Text('实时识别结果')
                .width('100%')
                .fontSize(13)
                .fontWeight(FontWeight.Medium)
                .fontColor('#1F2A44')

              Text(this.speechRecognizedText.trim().length > 0 ? this.speechRecognizedText : '识别结果会显示在这里')
                .width('100%')
                .fontSize(16)
                .fontColor(this.speechRecognizedText.trim().length > 0 ? '#1F2A44' : '#95A4BA')
                .lineHeight(24)

              if (this.speechPartialText.trim().length > 0 && this.speechPartialText !== this.speechRecognizedText) {
                Text(`实时片段：${this.speechPartialText}`)
                  .width('100%')
                  .fontSize(12)
                  .fontColor('#6F83A2')
                  .lineHeight(18)
              }
            }
            .width('100%')
            .padding(14)
            .backgroundColor('#FFFFFF')
            .borderRadius(12)
            .border({ width: 1, color: '#E6EDF8' })

            Column({ space: 6 }) {
              Text('识别状态')
                .fontSize(12)
                .fontColor('#6F83A2')

              Text(this.speechStatusText)
                .width('100%')
                .fontSize(13)
                .fontColor('#1F2A44')
                .lineHeight(20)
            }
            .width('100%')
            .padding(14)
            .backgroundColor('#F2F7FF')
            .borderRadius(12)
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
              Text(this.isSpeechTraining() ? '选好视频后，就能进入评分' : '选好手势视频后，就能进入评分')
                .fontSize(20)
                .fontWeight(FontWeight.Medium)
                .fontColor('#FFFFFF')

              Button(this.isSpeechTraining() ? '选择本地视频' : '选择手势视频')
                .height(44)
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

        Text(this.isSpeechTraining() && this.practiceMode === 'audio' ? this.audioCaptureTip : this.captureTip)
          .width('100%')
          .fontSize(12)
          .fontColor('#7A8CA7')
          .lineHeight(18)

        if (this.trainingTip.length > 0) {
          Text(this.trainingTip)
            .width('100%')
            .fontSize(12)
            .lineHeight(18)
            .fontColor(this.isScoring ? '#2E79F4' : '#E5484D')
            .padding({ left: 12, right: 12, top: 10, bottom: 10 })
            .backgroundColor(this.isScoring ? '#EEF5FF' : '#FFF1F1')
            .borderRadius(12)
        }

        if ((!this.isSpeechTraining() || this.practiceMode === 'video') && this.recordedVideoUri.length > 0) {
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
      score: this.currentScore,
      title: this.resultTitle,
      scoreLabel: this.resultScoreLabel,
      badges: this.resultBadges,
      dimensions: this.resultDimensions,
      strengthsTitle: this.resultStrengths.title,
      strengthsTags: this.resultStrengths.tags,
      strengthsDescription: this.resultStrengths.description,
      improvementsTitle: this.resultImprovements.title,
      improvementsTags: this.resultImprovements.tags,
      improvementsDescription: this.resultImprovements.description,
      recentTrendTitle: this.resultRecentTrend.title,
      recentTrendScores: this.resultRecentTrend.scores,
      recentTrendDescription: this.resultRecentTrend.description
    })
  }

  @Builder
  private buildEmptyState() {
    Column({ space: 12 }) {
      Text(this.isSessionLoading ? '正在加载训练内容...' : (this.trainingTip.length > 0 ? this.trainingTip : '当前课程还没有训练项'))
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.isSessionLoading ? '#5F7593' : (this.trainingTip.length > 0 ? '#E5484D' : '#1F2A44'))
        .textAlign(TextAlign.Center)

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

  @Builder
  private buildItemDetailLoadingState() {
    Column({ space: 12 }) {
      LoadingProgress()
        .width(26)
        .height(26)
        .color('#2E79F4')

      Text('正在加载训练项内容...')
        .fontSize(15)
        .fontWeight(FontWeight.Medium)
        .fontColor('#1F2A44')

      Text('封面、说明和步骤内容马上就好')
        .fontSize(12)
        .fontColor('#7A8CA7')
    }
    .width('100%')
    .padding(24)
    .backgroundColor('#FFFFFF')
    .borderRadius(18)
  }
}




