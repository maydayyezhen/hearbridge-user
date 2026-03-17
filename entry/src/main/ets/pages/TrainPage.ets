import photoAccessHelper from '@ohos.file.photoAccessHelper'
import picker from '@ohos.file.picker'

class MediaResourceItem {
  uid: string
  name: string
  url: string
  status: string
  title: string
  description: string

  constructor(uid: string, name: string, url: string, status: string, title: string = '', description: string = '') {
    this.uid = uid
    this.name = name
    this.url = url
    this.status = status
    this.title = title
    this.description = description
  }
}

class TrainingItem {
  id: number
  name: string
  code: string
  majorCategoryCode: string
  levelNum: number
  isRecommended: boolean
  sortNum: number
  status: string
  meaning: string
  description: string
  goal: string
  precautions: string[]
  commonErrors: string[]
  cover: MediaResourceItem[]
  video: MediaResourceItem[]
  audio: MediaResourceItem[]
  actionImages: MediaResourceItem[]
  videoPoster: MediaResourceItem[]

  constructor(id: number, name: string, code: string, majorCategoryCode: string, levelNum: number, isRecommended: boolean,
    sortNum: number, status: string, meaning: string, description: string, goal: string, precautions: string[],
    commonErrors: string[], cover: MediaResourceItem[], video: MediaResourceItem[], audio: MediaResourceItem[],
    actionImages: MediaResourceItem[], videoPoster: MediaResourceItem[]) {
    this.id = id
    this.name = name
    this.code = code
    this.majorCategoryCode = majorCategoryCode
    this.levelNum = levelNum
    this.isRecommended = isRecommended
    this.sortNum = sortNum
    this.status = status
    this.meaning = meaning
    this.description = description
    this.goal = goal
    this.precautions = precautions
    this.commonErrors = commonErrors
    this.cover = cover
    this.video = video
    this.audio = audio
    this.actionImages = actionImages
    this.videoPoster = videoPoster
  }
}

@Component
export struct TrainPage {
  @Prop courseName: string = '日常问候入门'
  @Prop courseCode: string = 'COURSE-101'
  @Prop trainingType: string = 'gesture'
  @Prop selectedPhrase: string = '你好'
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
  onSelectPhrase: (phrase: string) => void = () => {}
  onBackToCourseList: () => void = () => {}
  onCompleteTraining: () => void = () => {}
  onScoringStateChange: (isScoring: boolean) => void = () => {}

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
  private readonly fallbackCoverUrl: string = 'http://192.168.142.128:9001/hearbridge-bucket/20260316/3ad909fc0af94c58a8f2be4ca2fe4cbcChatGPT%20Image%202026%E5%B9%B43%E6%9C%8816%E6%97%A5%2001_25_49.png'
  private readonly trainingItems: TrainingItem[] = [
    new TrainingItem(
      1, '你好', 'GESTURE_HELLO', 'gesture', 3, true, 10, 'published',
      '用于日常问候场景。', '抬起右手，掌心朝外，轻微摆动。', '帮助学员完成基础问候表达。',
      ['手掌方向朝外', '动作幅度自然'], ['手掌方向错误'],
      [new MediaResourceItem('g-cover-1', 'cover-hello.png', 'https://placehold.co/400x240/png?text=Hello', 'done')],
      [new MediaResourceItem('g-video-1', 'hello-demo.mp4', 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4', 'done')],
      [],
      [
        new MediaResourceItem('g-step-1', 'hello-step-1.png', 'https://placehold.co/200x200/png?text=Hello+1', 'done', '抬手准备', '右手自然抬起，手臂不要僵硬，准备进入问候动作。'),
        new MediaResourceItem('g-step-2', 'hello-step-2.png', 'https://placehold.co/200x200/png?text=Hello+2', 'done', '掌心朝外', '保持掌心朝外，轻微摆动，动作幅度自然即可。')
      ],
      []
    ),
    new TrainingItem(
      3, '阿', 'VOICE_A', 'voice', 1, true, 10, 'published',
      '用于学习基础元音发音。', '张口自然，保持声音平稳输出。', '帮助学员完成元音发音入门训练。',
      ['口型自然张开', '发音时长稳定'], ['发音过短', '口型过紧'],
      [new MediaResourceItem('v-cover-1', 'cover-voice-a.png', 'https://placehold.co/400x240/png?text=Voice+A', 'done')],
      [new MediaResourceItem('v-video-1', 'voice-a-demo.mp4', 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4', 'done')],
      [new MediaResourceItem('v-audio-1', 'voice-a.mp3', 'https://www.w3schools.com/html/horse.mp3', 'done')],
      [
        new MediaResourceItem('v-step-1', 'voice-a-mouth-1.png', 'https://placehold.co/200x200/png?text=Voice+A+1', 'done', '张口准备', '嘴巴自然张开，面部放松，不要刻意用力。'),
        new MediaResourceItem('v-step-2', 'voice-a-mouth-2.png', 'https://placehold.co/200x200/png?text=Voice+A+2', 'done', '稳定发音', '保持口型稳定，均匀发出阿的声音。')
      ],
      []
    ),
    new TrainingItem(
      6, '你好', 'VOI_001', 'voice', 1, true, 10, 'enabled',
      '你好', '先看口型，再跟随视频完成模仿练习。', '帮助学员掌握“你好”的发音节奏。',
      ['先看口型再发音', '保持语速平稳'], ['尾音不清晰'],
      [new MediaResourceItem('v-cover-2', 'cover-voice-hello.png', 'http://192.168.142.128:9001/hearbridge-bucket/20260316/nihao.png', 'done')],
      [new MediaResourceItem('v-video-2', '%E4%BD%A0%E5%A5%BD.mp4', 'http://192.168.142.128:9001/hearbridge-bucket/20260316/7375fc2d133c4ffdb11ed159fefd7a24%E4%BD%A0%E5%A5%BD.mp4', 'done')],
      [new MediaResourceItem('v-audio-2', 'nihao.mp3', 'http://192.168.142.128:9001/hearbridge-bucket/20260316/nihao.mp3', 'done')],
      [
        new MediaResourceItem(
          'v-step-1',
          'step-1.jpg',
          'http://192.168.142.128:9001/hearbridge-bucket/20260316/ni.png',
          'done',
          '第一步',
          '嘴角自然打开'
        ),
        new MediaResourceItem(
          'v-step-2',
          'step-2.jpg',
          'http://192.168.142.128:9001/hearbridge-bucket/20260316/hao.png',
          'done',
          '第二步',
          '舌尖轻抵下齿'
        )
      ],
      [new MediaResourceItem('v-poster-2', 'video-cover-1773594512063.png', 'http://192.168.142.128:9001/hearbridge-bucket/20260316/76b784b8925d45deb0afdb109387ad35video-cover-1773594511837.png', 'done')]
    )
  ]

  aboutToAppear() {
    this.syncCurrentItemFromSelection()
  }

  aboutToDisappear() {
    this.clearDemoAudioTimer()
    this.clearScoringTimer()
    this.setScoringState(false)
  }

  private syncCurrentItemFromSelection() {
    const items: TrainingItem[] = this.getVisibleItems()
    this.currentItemIndex = 0
    for (let index = 0; index < items.length; index += 1) {
      if (items[index].name === this.selectedPhrase) {
        this.currentItemIndex = index
        break
      }
    }
    this.resetTrainingFlow()
  }

  private resetTrainingFlow() {
    this.currentStage = 'intro'
    this.practiceMode = this.trainingType === 'speech' ? 'audio' : 'video'
    this.isCapturing = false
    this.setScoringState(false)
    this.clearScoringTimer()
    this.mockScore = 86
    this.recordedVideoUri = ''
    this.recordedAudioUri = ''
    this.stopDemoAudioPlayback()
    if (this.trainingType === 'speech') {
      this.audioCaptureTip = '已就绪，选一段音频开始跟读吧。'
      this.captureTip = '已就绪，选一段视频开始练习吧。'
    } else {
      this.audioCaptureTip = '当前是手势训练，请使用视频练习。'
      this.captureTip = '已就绪，选一段手势视频开始练习吧。'
    }
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
      return item.id === 6
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

  private hasAudio(item: TrainingItem): boolean {
    return item.audio.length > 0
  }

  private hasActionImages(item: TrainingItem): boolean {
    return item.actionImages.length > 0
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
    return 5
  }

  private getProgressText(): string {
    const totalCount: number = this.getVisibleItems().length
    if (totalCount === 0) {
      return '0/0'
    }
    return `${Math.min(this.currentItemIndex + 1, totalCount)}/${totalCount}`
  }

  private getDifficultyStars(levelNum: number): string[] {
    const stars: string[] = []
    const safeLevel = Math.max(1, Math.min(5, levelNum))
    for (let index = 0; index < 5; index += 1) {
      stars.push(index < safeLevel ? 'filled' : 'empty')
    }
    return stars
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

  private goToNextStage() {
    if (this.isScoring) {
      return
    }
    if (this.currentStage === 'intro') {
      this.currentStage = this.hasVideo(this.getCurrentItem()) ? 'video' : 'guide'
      if (this.currentStage === 'video') {
        this.scrollVideoIntoView()
      } else {
        this.scrollContentToTop()
      }
      return
    }
    if (this.currentStage === 'video') {
      this.currentStage = 'guide'
      this.scrollContentToTop()
      return
    }
    if (this.currentStage === 'guide') {
      this.currentStage = 'practice'
      this.scrollContentToTop()
      return
    }
    if (this.currentStage === 'practice') {
      this.submitPractice()
    }
  }

  private goToPreviousStage() {
    if (this.isScoring) {
      return
    }
    if (this.currentStage === 'video') {
      this.currentStage = 'intro'
      this.scrollContentToTop()
      return
    }
    if (this.currentStage === 'guide') {
      this.currentStage = this.hasVideo(this.getCurrentItem()) ? 'video' : 'intro'
      if (this.currentStage === 'video') {
        this.scrollVideoIntoView()
      } else {
        this.scrollContentToTop()
      }
      return
    }
    if (this.currentStage === 'practice') {
      this.currentStage = 'guide'
      this.scrollContentToTop()
      return
    }
    if (this.currentStage === 'result') {
      this.currentStage = 'practice'
      this.scrollContentToTop()
    }
  }

  private scrollVideoIntoView() {
    setTimeout(() => {
      this.videoScroller.scrollTo({
        xOffset: 0,
        yOffset: 72,
        animation: {
          duration: 260,
          curve: Curve.EaseInOut
        }
      })
    }, 80)
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
    return this.introScroller
  }

  private submitPractice() {
    if (this.isScoring) {
      return
    }
    this.isCapturing = false
    this.setScoringState(true)
    this.clearScoringTimer()
    this.scoringTimer = setTimeout(() => {
      this.mockScore = this.trainingType === 'speech' ? 91 : 88
      this.setScoringState(false)
      this.currentStage = 'result'
      this.scrollContentToTop()
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
    const items: TrainingItem[] = this.getVisibleItems()
    if (this.currentItemIndex < items.length - 1) {
      this.selectItem(this.currentItemIndex + 1)
      return
    }
    this.onCompleteTraining()
    this.onBackToCourseList()
  }

  private canShowPrevious(): boolean {
    return this.currentStage !== 'intro'
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
    return '下一步'
  }

  private handleFloatingNext() {
    if (this.isScoring) {
      return
    }
    if (this.currentStage === 'result') {
      this.handleNextItem()
      return
    }
    this.goToNextStage()
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
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
        Scroll(this.videoScroller) {
          Column({ space: 16 }) {
            Blank()
              .height(106)
            if (this.hasVisibleItems()) {
              this.buildVideoStage(this.getCurrentItem())
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
        .height('100%')
        .backgroundColor('#F4F7FB')
        .scrollBar(BarState.Off)
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
      }

      this.buildPreloadAssets(this.getCurrentItem())

      Column({ space: 10 }) {
        this.buildTopHeader()
        this.buildStageStepper()
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 0, bottom: 10 })
      .backgroundColor('#FFFFFF')
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])

      if (this.isScoring) {
        this.buildScoringOverlay()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F4F7FB')
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
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
      Row({ space: 8 }) {
        Text(this.courseName)
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1F2A44')

        Blank()

        Stack({ alignContent: Alignment.Center }) {
          Row() {
          }
          .width(34)
          .height(34)
          .backgroundColor('#EEF4FF')
          .borderRadius(17)

          SymbolGlyph($r('sys.symbol.chevron_backward'))
            .fontSize(17)
            .fontColor(['#4C79C9'])
        }
        .width(34)
        .height(34)
        .onClick(() => {
          if (this.currentStage === 'intro') {
            this.onBackToCourseList()
          } else {
            this.currentStage = 'intro'
          }
        })

        if (this.canShowPrevious()) {
          Button(this.getPreviousLabel())
            .height(34)
            .fontSize(12)
            .fontWeight(FontWeight.Medium)
            .fontColor('#2E79F4')
            .backgroundColor('#FFFFFF')
            .borderRadius(17)
            .padding({ left: 12, right: 12 })
            .enabled(!this.isScoring)
            .opacity(this.isScoring ? 0.45 : 1)
            .onClick(() => {
              this.goToPreviousStage()
            })
        }

        Button(this.getNextLabel())
          .height(34)
          .fontSize(12)
          .fontWeight(FontWeight.Medium)
          .fontColor('#FFFFFF')
          .backgroundColor('#2E79F4')
          .borderRadius(17)
          .padding({ left: 12, right: 12 })
          .enabled(!this.isScoring)
          .opacity(this.isScoring ? 0.55 : 1)
          .onClick(() => {
            this.handleFloatingNext()
          })
      }
      .width('100%')

      Text(`${this.getStageTitle()} · 第 ${this.getProgressText()} 项`)
        .width('100%')
        .fontSize(12)
        .fontColor('#7A8CA7')
    }
    .width('100%')
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
    Column({ space: 16 }) {
      Stack({ alignContent: Alignment.BottomStart }) {
        Image(this.getPrimaryCoverUrl(item))
          .width('100%')
          .height(188)
          .objectFit(ImageFit.Cover)
          .borderRadius(20)

        Column() {
        }
        .width('100%')
        .height(188)
        .borderRadius(20)
        .linearGradient({
          angle: 180,
          colors: [['#00000012', 0], ['#00000088', 1]]
        })

        Column({ space: 6 }) {
          Text(item.name)
            .fontSize(30)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFFFFF')
            .shadow({ radius: 12, color: '#00000099', offsetX: 0, offsetY: 3 })

          Text(item.meaning)
            .fontSize(13)
            .fontColor('#F2F7FF')
            .shadow({ radius: 10, color: '#00000088', offsetX: 0, offsetY: 2 })
        }
        .alignItems(HorizontalAlign.Start)
        .padding(18)
      }
      .width('100%')
      .height(188)

      Column({ space: 14 }) {
        this.buildDifficultySection(item.levelNum)
        this.buildInfoSection('训练说明', item.description)
        this.buildInfoSection('训练目标', item.goal)
        this.buildTagSection('本轮关注点', item.precautions, '#EEF5FF', '#2E79F4')
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
  private buildVideoStage(item: TrainingItem) {
    Column() {
      Row() {
        Blank()

        Video({
          src: item.video[0].url,
          previewUri: this.getVideoPosterUrl(item),
          controller: this.videoController
        })
          .width('78%')
          .height(520)
          .borderRadius(20)
          .controls(true)
          .autoPlay(true)

        Blank()
      }
      .width('100%')
    }
    .width('100%')
    .padding({ top: 8 })
  }

  @Builder
  private buildGuideStage(item: TrainingItem) {
    Column({ space: 16 }) {
      if (this.hasActionImages(item)) {
        this.buildActionImagesCard(item)
      }

      Column({ space: 16 }) {
        this.buildInfoSection('动作说明', item.description)
        this.buildTagSection('注意要点', item.precautions, '#EEF5FF', '#2E79F4')
        this.buildTagSection('常见错误', item.commonErrors, '#FFF1F1', '#D94C4C')
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

        if (this.trainingType === 'speech' && this.practiceMode === 'audio' && this.hasAudio(item)) {
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

            // Keep audio player hidden and controlled by buttons.
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
            ? (this.hasAudio(item) ? '先听示范，再录一遍，你会更容易拿到高分。' : '没有示范也没关系，直接上传你的练习音频即可。')
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
    Column({ space: 16 }) {
      Stack({ alignContent: Alignment.TopStart }) {
        Column() {
        }
        .width('100%')
        .height(412)
        .backgroundColor('#FFFFFF')
        .borderRadius(26)

        Column() {
        }
        .width('100%')
        .height(118)
        .linearGradient({
          angle: 180,
          colors: [['#F7FAFF', 0], ['#FFFFFF', 1]]
        })
        .borderRadius({ topLeft: 26, topRight: 26, bottomLeft: 0, bottomRight: 0 })

        Column() {
        }
        .width('100%')
        .height(412)
        .backgroundColor('#FFFFFF')
        .borderRadius(26)
        .opacity(0.02)

        Column({ space: 16 }) {
          Row() {
            Text('评分结果')
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .fontColor('#6C7C95')
          }
          .width('100%')

          Stack({ alignContent: Alignment.Center }) {
            Column() {
            }
            .width(178)
            .height(178)
            .borderRadius(89)
            .backgroundColor('#F7F9FD')
            .shadow({ radius: 20, color: '#1F2A4412', offsetX: 0, offsetY: 10 })
            .border({
              width: 1,
              color: '#E8EEF8'
            })

            Column() {
            }
            .width(154)
            .height(154)
            .borderRadius(77)
            .border({
              width: 10,
              color: '#C8DEFF'
            })
            .shadow({ radius: 8, color: '#FFFFFFCC', offsetX: 0, offsetY: 0 })

            Column({ space: 4 }) {
              Text('91')
                .fontSize(60)
                .fontWeight(FontWeight.Bolder)
                .fontStyle(FontStyle.Italic)
                .fontColor('#2E79F4')

              Text('训练得分')
                .fontSize(12)
                .fontWeight(FontWeight.Medium)
                .fontColor('#72829A')
                .letterSpacing(0.8)
            }
          }
          .width('100%')
          .height(178)

          Text('表现稳定，建议继续巩固尾音控制')
            .width('100%')
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .fontColor('#1F2A44')
            .textAlign(TextAlign.Center)

          Text('系统根据本轮动作完成度、节奏稳定性与发音表现综合生成本次训练反馈。')
            .width('100%')
            .fontSize(12)
            .fontColor('#7D8CA2')
            .lineHeight(18)
            .textAlign(TextAlign.Center)

          Column() {
          }
          .width('100%')
          .height(1)
          .backgroundColor('#EDF2F8')

          Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Center, alignItems: ItemAlign.Start }) {
            this.buildResultBadge('完成度高', '#EEF5FF', '#2E79F4')
            this.buildResultBadge('节奏准确', '#EEF5FF', '#2E79F4')
            this.buildResultBadge('尾音待加强', '#FFF1F1', '#D94C4C')
          }
          .width('100%')
        }
        .width('100%')
        .padding(22)
      }
      .width('100%')
      .height(412)
      .shadow({ radius: 20, color: '#15304B14', offsetX: 0, offsetY: 10 })
      .border({
        width: 1,
        color: '#E8EEF7'
      })

      Column({ space: 14 }) {
        Text('维度分析')
          .width('100%')
          .fontSize(17)
          .fontWeight(FontWeight.Medium)
          .fontColor('#1F2A44')

        this.buildMetricRow('动作完成度', 93)
        this.buildMetricRow('节奏稳定性', 89)
        this.buildMetricRow('发音清晰度', 84)
      }
      .width('100%')
      .padding(18)
      .backgroundColor('#F8FAFD')
      .borderRadius(20)
      .shadow({ radius: 18, color: '#15304B10', offsetX: 0, offsetY: 8 })
      .border({
        width: 1,
        color: '#E8EEF7'
      })

      this.buildFeedbackModule(
        '本次亮点',
        ['口型稳定', '节奏自然', '完成度高'],
        '本轮训练整体节奏稳定，关键发音动作完成较好，跟读完成度也比较高。',
        '#EEF5FF',
        '#2E79F4'
      )

      this.buildFeedbackModule(
        '建议改进',
        ['尾音控制不足'],
        '建议下一轮训练中放慢尾音收束速度，注意口型闭合时机，让结尾更清晰稳定。',
        '#FFF1F1',
        '#D94C4C'
      )

      this.buildRecentTrendCard()

      Row({ space: 12 }) {
        Button('再练一次')
          .layoutWeight(1)
          .height(48)
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor('#2E79F4')
          .backgroundColor('#EEF5FF')
          .borderRadius(18)
          .onClick(() => {
            this.resetTrainingFlow()
          })

        Button(this.currentItemIndex < this.getVisibleItems().length - 1 ? '下一项' : '返回课程')
          .layoutWeight(1)
          .height(48)
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor('#FFFFFF')
          .linearGradient({
            angle: 90,
            colors: [['#6EA8FF', 0], ['#2E79F4', 1]]
          })
          .borderRadius(18)
          .onClick(() => {
            this.handleNextItem()
          })
      }
      .width('100%')
    }
    .width('100%')
  }

  @Builder
  private buildPracticeChip(mode: string, label: string, active: boolean) {
    Button(label)
      .type(ButtonType.Normal)
      .stateEffect(true)
      .fontSize(13)
      .fontWeight(active ? FontWeight.Bold : FontWeight.Medium)
      .fontColor(active ? '#FFFFFF' : '#607089')
      .height(40)
      .padding({ left: 14, right: 14, top: 10, bottom: 10 })
      .backgroundColor(active ? '#2E79F4' : '#FFFFFF')
      .borderRadius(16)
      .border({ width: 1, color: active ? '#2E79F4' : '#DCE7F6' })
      .shadow({
        radius: active ? 12 : 0,
        color: active ? '#2E79F433' : '#00000000',
        offsetX: 0,
        offsetY: 4
      })
      .onClick(() => {
        this.practiceMode = mode
      })
  }

  @Builder
  private buildScoreTag(label: string, value: string) {
    Column({ space: 4 }) {
      Text(label)
        .fontSize(11)
        .fontColor('#7A8CA7')

      Text(value)
        .fontSize(13)
        .fontWeight(FontWeight.Medium)
        .fontColor('#1F2A44')
    }
    .padding({ left: 12, right: 12, top: 10, bottom: 10 })
    .backgroundColor('#F5F8FD')
    .borderRadius(14)
  }

  @Builder
  private buildMetricCard(label: string, value: number, description: string) {
    Column({ space: 8 }) {
      Row() {
        Text(label)
          .fontSize(13)
          .fontWeight(FontWeight.Medium)
          .fontColor('#1F2A44')

        Blank()

        Text(`${value}`)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#2E79F4')
      }
      .width('100%')

      Stack({ alignContent: Alignment.Start }) {
        Column() {
        }
        .width('100%')
        .height(8)
        .backgroundColor('#ECF2FA')
        .borderRadius(4)

        Column() {
        }
        .width(`${value}%`)
        .height(8)
        .linearGradient({
          angle: 0,
          colors: [['#7DB2FF', 0], ['#2E79F4', 1]]
        })
        .borderRadius(4)
      }
      .width('100%')

      Text(description)
        .fontSize(11)
        .fontColor('#7A8CA7')
        .lineHeight(17)
    }
    .width('48%')
    .padding(14)
    .backgroundColor('#F8FBFF')
    .borderRadius(16)
  }

  @Builder
  private buildMetricRow(label: string, value: number) {
    Column({ space: 8 }) {
      Row() {
        Text(label)
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor('#1F2A44')

        Blank()

        Text(`${value}`)
          .fontSize(15)
          .fontWeight(FontWeight.Bold)
          .fontColor('#2E79F4')
      }
      .width('100%')

      Stack({ alignContent: Alignment.Start }) {
        Column() {
        }
        .width('100%')
        .height(10)
        .backgroundColor('#ECF2FA')
        .borderRadius(5)

        Column() {
        }
        .width(`${value}%`)
        .height(10)
        .backgroundColor('#2E79F4')
        .borderRadius(5)
      }
      .width('100%')
    }
    .width('100%')
    .padding(14)
    .backgroundColor('#F6F8FC')
    .borderRadius(16)
    .border({
      width: 1,
      color: '#E3ECF8'
    })
    .shadow({ radius: 6, color: '#FFFFFFD8', offsetX: 0, offsetY: 0 })
  }

  @Builder
  private buildResultBadge(label: string, backgroundColor: string, fontColor: string) {
    Text(label)
      .fontSize(12)
      .fontWeight(FontWeight.Medium)
      .fontColor(fontColor)
      .padding({ left: 12, right: 12, top: 9, bottom: 9 })
      .backgroundColor(backgroundColor)
      .borderRadius(14)
      .border({
        width: 1,
        color: backgroundColor === '#FFF1F1' ? '#F1D7D7' : '#DDE9F8'
      })
      .margin({ right: 8, bottom: 8 })
  }

  @Builder
  private buildFeedbackModule(title: string, tags: string[], description: string, tagBackgroundColor: string, tagColor: string) {
    Column({ space: 12 }) {
      Text(title)
        .width('100%')
        .fontSize(17)
        .fontWeight(FontWeight.Medium)
        .fontColor('#1F2A44')

      Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Start, alignItems: ItemAlign.Start }) {
        ForEach(tags, (tag: string) => {
          Text(tag)
            .fontSize(12)
            .fontWeight(FontWeight.Medium)
            .fontColor(tagColor)
            .padding({ left: 10, right: 10, top: 7, bottom: 7 })
            .backgroundColor(tagBackgroundColor)
            .borderRadius(12)
            .margin({ right: 8, bottom: 8 })
        }, (tag: string) => tag)
      }
      .width('100%')

      Text(description)
        .width('100%')
        .fontSize(13)
        .fontColor('#6A7B93')
        .lineHeight(21)
    }
    .width('100%')
    .padding(18)
    .backgroundColor('#F9FBFE')
    .borderRadius(20)
    .shadow({ radius: 18, color: '#15304B10', offsetX: 0, offsetY: 8 })
  }

  @Builder
  private buildRecentTrendCard() {
    Column({ space: 14 }) {
      Row() {
        Text('最近表现')
          .fontSize(17)
          .fontWeight(FontWeight.Medium)
          .fontColor('#1F2A44')

        Blank()

        Text('近 5 次')
          .fontSize(12)
          .fontColor('#7A8CA7')
      }
      .width('100%')

      Row({ space: 10 }) {
        this.buildTrendBar('1', 74, false)
        this.buildTrendBar('2', 79, false)
        this.buildTrendBar('3', 83, false)
        this.buildTrendBar('4', 87, false)
        this.buildTrendBar('5', 91, true)
      }
      .width('100%')
      .alignItems(VerticalAlign.Bottom)

      Text('最近 5 次训练整体呈稳定上升趋势，当前完成度和节奏控制都有明显改善。')
        .width('100%')
        .fontSize(13)
        .fontColor('#6A7B93')
        .lineHeight(21)
    }
    .width('100%')
    .padding(18)
    .backgroundColor('#F9FBFE')
    .borderRadius(20)
    .shadow({ radius: 18, color: '#15304B10', offsetX: 0, offsetY: 8 })
  }

  @Builder
  private buildTrendBar(label: string, score: number, highlighted: boolean) {
    Column({ space: 8 }) {
      Text(`${score}`)
        .fontSize(11)
        .fontWeight(highlighted ? FontWeight.Bold : FontWeight.Medium)
        .fontColor(highlighted ? '#2E79F4' : '#6C7C95')

      Stack({ alignContent: Alignment.Bottom }) {
        Column() {
        }
        .width('100%')
        .height('100%')
        .backgroundColor('#F7FAFD')
        .borderRadius(12)

        Column() {
        }
        .width('100%')
        .height(`${score}%`)
        .linearGradient({
          angle: 180,
          colors: highlighted ? [['#6EA8FF', 0], ['#2E79F4', 1]] : [['#C9D8EB', 0], ['#AFC3DA', 1]]
        })
        .borderRadius({ topLeft: 8, topRight: 8, bottomLeft: 8, bottomRight: 8 })
      }
      .width('100%')
      .layoutWeight(1)
      .padding({ left: 6, right: 6, top: 8, bottom: 8 })
      .backgroundColor(highlighted ? '#F4F8FF' : '#F8FAFD')
      .borderRadius(14)
      .border({
        width: 1,
        color: highlighted ? '#D9E6F8' : '#E8EEF6'
      })

      Text(label)
        .fontSize(11)
        .fontColor('#8A99AD')
    }
    .width(52)
    .height(132)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  private buildResultPill(label: string, value: string, backgroundColor: string, fontColor: string) {
    Column({ space: 4 }) {
      Text(label)
        .fontSize(10)
        .fontColor('#7A8CA7')

      Text(value)
        .fontSize(12)
        .fontWeight(FontWeight.Medium)
        .fontColor(fontColor)
    }
    .padding({ left: 12, right: 12, top: 8, bottom: 8 })
    .backgroundColor(backgroundColor)
    .borderRadius(14)
  }

  @Builder
  private buildActionImagesCard(item: TrainingItem) {
    Column({ space: 12 }) {
      Text('步骤动作')
        .width('100%')
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .fontColor('#1F2A44')

      Swiper() {
        ForEach(item.actionImages, (resource: MediaResourceItem, index: number) => {
          this.buildActionImage(resource, index, item.actionImages.length)
        }, (resource: MediaResourceItem) => resource.uid)
      }
      .width('100%')
      .height(318)
      .indicator(true)
      .loop(false)
      .autoPlay(false)
    }
    .width('100%')
    .padding(18)
    .backgroundColor('#FFFFFF')
    .borderRadius(18)
    .shadow({ radius: 18, color: '#15304B10', offsetX: 0, offsetY: 8 })
  }

  @Builder
  private buildActionImage(resource: MediaResourceItem, index: number, total: number) {
    Column({ space: 10 }) {
      Row() {
        Text(`步骤 ${index + 1}`)
          .fontSize(12)
          .fontWeight(FontWeight.Medium)
          .fontColor('#2E79F4')
          .padding({ left: 10, right: 10, top: 6, bottom: 6 })
          .backgroundColor('#EEF5FF')
          .borderRadius(12)

        Blank()

        Text(`${index + 1}/${total}`)
          .fontSize(12)
          .fontColor('#7A8CA7')
      }
      .width('100%')

      Image(resource.url)
        .width('100%')
        .height(236)
        .objectFit(ImageFit.Contain)
        .borderRadius(16)
        .backgroundColor('#F5F8FD')

      if (resource.description.length > 0) {
        Text(resource.description)
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor('#42526B')
          .lineHeight(22)
          .maxLines(3)
      }
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  private buildInfoSection(title: string, content: string) {
    Column({ space: 8 }) {
      Text(title)
        .width('100%')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor('#1F2A44')

      Text(content)
        .width('100%')
        .fontSize(14)
        .fontColor('#5E6D85')
        .lineHeight(22)
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  private buildDifficultySection(levelNum: number) {
    Column({ space: 8 }) {
      Text('难度等级')
        .width('100%')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor('#1F2A44')

      Row({ space: 6 }) {
        ForEach(this.getDifficultyStars(levelNum), (star: string, index: number) => {
          SymbolGlyph($r('sys.symbol.star_fill'))
            .fontSize(18)
            .fontColor(star === 'filled' ? ['#FFB938'] : ['#D6E0EE'])
        }, (_star: string, index: number) => `${index}`)

        Text(`Lv.${Math.max(1, Math.min(5, levelNum))}`)
          .fontSize(13)
          .fontWeight(FontWeight.Medium)
          .fontColor('#7A8CA7')
          .margin({ left: 6 })
      }
      .width('100%')
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  private buildTagSection(title: string, tags: string[], backgroundColor: string, textColor: string) {
    Column({ space: 10 }) {
      Text(title)
        .width('100%')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor('#1F2A44')

      Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Start, alignItems: ItemAlign.Start }) {
        ForEach(tags, (tag: string) => {
          Text(tag)
            .fontSize(12)
            .fontColor(textColor)
            .padding({ left: 10, right: 10, top: 7, bottom: 7 })
            .backgroundColor(backgroundColor)
            .borderRadius(12)
            .margin({ right: 8, bottom: 8 })
        }, (tag: string) => tag)
      }
      .width('100%')
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
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




