import { Want } from '@kit.AbilityKit'
import common from '@ohos.app.ability.common'
import photoAccessHelper from '@ohos.file.photoAccessHelper'

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
  @State audioCaptureTip: string = '录音练习会尝试调用系统录音能力，录完后只保留本地结果。'
  @State captureTip: string = '录像练习会调用系统相机，录完后只在本地预览，不会上传。'
  @State isLaunchingVideoCapture: boolean = false
  @State isLaunchingAudioCapture: boolean = false
  onSelectPhrase: (phrase: string) => void = () => {}
  onBackToCourseList: () => void = () => {}
  onCompleteTraining: () => void = () => {}

  private introScroller: Scroller = new Scroller()
  private videoScroller: Scroller = new Scroller()
  private guideScroller: Scroller = new Scroller()
  private practiceScroller: Scroller = new Scroller()
  private resultScroller: Scroller = new Scroller()
  private videoController: VideoController = new VideoController()
  private practiceVideoController: VideoController = new VideoController()
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
      [],
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
    this.mockScore = 86
    this.recordedVideoUri = ''
    this.recordedAudioUri = ''
    this.audioCaptureTip = '录音练习会尝试调用系统录音能力，录完后只保留本地结果。'
    this.captureTip = '录像练习会调用系统相机，录完后只在本地预览，不会上传。'
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
    this.isCapturing = false
    this.mockScore = this.trainingType === 'speech' ? 91 : 88
    this.currentStage = 'result'
    this.scrollContentToTop()
  }

  private async openSystemVideoCapture() {
    if (this.isLaunchingVideoCapture) {
      return
    }

    this.isLaunchingVideoCapture = true
    this.captureTip = '正在打开系统相机录像...'

    try {
      const context = this.getUIContext().getHostContext() as common.UIAbilityContext
      const want: Want = {
        action: 'ohos.want.action.videoCapture',
        parameters: {
          supportMultiMode: false
        }
      }
      const result = await context.startAbilityForResult(want)
      const localVideoUri = this.extractVideoUri(result)
      if (localVideoUri.length > 0) {
        this.recordedVideoUri = localVideoUri
        this.captureTip = '录像已完成，文件只保存在本地预览状态，当前不会上传。'
      } else {
        this.captureTip = '录像已结束，但系统没有返回可预览的视频地址。'
      }
    } catch (_error) {
      this.captureTip = '当前环境无法直接拉起系统相机，正在切换到本地视频选择。'
      await this.openLocalVideoPicker()
    } finally {
      this.isLaunchingVideoCapture = false
    }
  }

  private async openLocalVideoPicker() {
    try {
      let videoPicker = new photoAccessHelper.PhotoViewPicker()
      let pickerOptions = new photoAccessHelper.PhotoSelectOptions()
      pickerOptions.MIMEType = photoAccessHelper.PhotoViewMIMETypes.VIDEO_TYPE
      pickerOptions.maxSelectNumber = 1

      const pickerResult = await videoPicker.select(pickerOptions)
      if (pickerResult.photoUris.length > 0) {
        this.recordedVideoUri = pickerResult.photoUris[0]
        this.captureTip = '已选择本地视频，当前仅用于练习预览，不会上传。'
      } else {
        this.captureTip = '你还没有选择视频。'
      }
    } catch (_pickerError) {
      this.captureTip = '本地视频选择失败，请在真机或支持媒体库的模拟器中重试。'
    }
  }

  private async openSystemAudioCapture() {
    if (this.isLaunchingAudioCapture) {
      return
    }

    this.isLaunchingAudioCapture = true
    this.audioCaptureTip = '正在打开系统录音...'

    try {
      const context = this.getUIContext().getHostContext() as common.UIAbilityContext
      const want: Want = {
        action: 'ohos.want.action.audioCapture'
      }
      const result = await context.startAbilityForResult(want)
      const localAudioUri = this.extractAudioUri(result)
      if (localAudioUri.length > 0) {
        this.recordedAudioUri = localAudioUri
        this.audioCaptureTip = '录音已完成，当前仅保留本地结果，未上传。'
      } else {
        this.audioCaptureTip = '录音已结束，但系统没有返回可用的音频地址。'
      }
    } catch (_error) {
      this.audioCaptureTip = '当前环境无法直接拉起系统录音，模拟器里可能不支持。'
    } finally {
      this.isLaunchingAudioCapture = false
    }
  }

  private extractVideoUri(result: common.AbilityResult): string {
    const resourceUri = this.readResultParameter(result, 'resourceUri')
    if (resourceUri.length > 0) {
      return resourceUri
    }

    const uri = this.readResultParameter(result, 'uri')
    if (uri.length > 0) {
      return uri
    }

    return ''
  }

  private extractAudioUri(result: common.AbilityResult): string {
    const resourceUri = this.readResultParameter(result, 'resourceUri')
    if (resourceUri.length > 0) {
      return resourceUri
    }

    const uri = this.readResultParameter(result, 'uri')
    if (uri.length > 0) {
      return uri
    }

    return ''
  }

  private readResultParameter(result: common.AbilityResult, key: string): string {
    if (!result.want || !result.want.parameters) {
      return ''
    }

    const rawValue = result.want.parameters[key]
    if (rawValue === undefined || rawValue === null) {
      return ''
    }
    return `${rawValue}`
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
      return '评分'
    }
    if (this.currentStage === 'result') {
      return '下一项'
    }
    return '下一步'
  }

  private handleFloatingNext() {
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
          .padding({ left: 16, right: 16, top: 6, bottom: 132 })
        }
        .width('100%')
        .height('100%')
        .scrollBar(BarState.Off)
      } else if (this.currentStage === 'video') {
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
        .height('100%')
        .padding({ left: 16, right: 16, top: 6, bottom: 132 })
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
          .padding({ left: 16, right: 16, top: 6, bottom: 132 })
        }
        .width('100%')
        .height('100%')
        .scrollBar(BarState.Off)
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
          .padding({ left: 16, right: 16, top: 6, bottom: 132 })
        }
        .width('100%')
        .height('100%')
        .scrollBar(BarState.Off)
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
          .padding({ left: 16, right: 16, top: 6, bottom: 132 })
          .backgroundColor('#F4F7FB')
        }
        .width('100%')
        .height('100%')
        .backgroundColor('#F4F7FB')
        .scrollBar(BarState.Off)
      }

      this.buildPreloadAssets(this.getCurrentItem())

      Column({ space: 10 }) {
        this.buildTopHeader()
        this.buildStageStepper()
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 6, bottom: 10 })
      .backgroundColor('#F7FAFEF2')
      .backgroundBlurStyle(BlurStyle.COMPONENT_THICK)
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
      Row({ space: 10 }) {
        this.buildPracticeChip('audio', '录音练习', this.practiceMode === 'audio')
        this.buildPracticeChip('video', '录像练习', this.practiceMode === 'video')
      }
      .width('100%')

      Column({ space: 14 }) {
        Row({ space: 8 }) {
          Text(this.practiceMode === 'audio' ? '音频模式' : '视频模式')
            .fontSize(11)
            .fontColor('#2E79F4')
            .padding({ left: 10, right: 10, top: 6, bottom: 6 })
            .backgroundColor('#EEF5FF')
            .borderRadius(12)

          Text(this.practiceMode === 'audio' ? '适合跟读与发音评分' : '适合动作与口型纠正')
            .fontSize(11)
            .fontColor('#7A8CA7')
        }
        .width('100%')

        Text(this.practiceMode === 'audio' ? '先听示范，再开始录音' : '打开前置摄像头，按动作或口型练习')
          .width('100%')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor('#1F2A44')

        Text(this.practiceMode === 'audio'
          ? (this.hasAudio(item) ? '当前训练项已挂载音频资源，可用于跟读练习。' : '当前训练项没有音频资源，先按步骤练习后再录音。')
          : '录像模式更适合手势与口型动作校验。')
          .width('100%')
          .fontSize(13)
          .fontColor('#7A8CA7')
          .lineHeight(20)

        Stack({ alignContent: Alignment.Center }) {
          Column() {
          }
          .width('100%')
          .height(220)
          .backgroundColor('#0D1B2A')
          .borderRadius(20)

          Column({ space: 14 }) {
            Text(this.isCapturing ? '练习采集中...' : this.practiceMode === 'audio' ? '准备开始录音' : '准备开始录像')
              .fontSize(20)
              .fontWeight(FontWeight.Medium)
              .fontColor('#FFFFFF')

            Button(this.isCapturing ? '结束采集' : this.practiceMode === 'audio' ? '开始录音' : '开始录像')
              .width(160)
              .height(46)
              .fontSize(15)
              .fontWeight(FontWeight.Medium)
              .fontColor('#0B1522')
              .backgroundColor('#FFFFFF')
              .borderRadius(16)
              .onClick(() => {
                if (this.practiceMode === 'audio') {
                  this.openSystemAudioCapture()
                } else {
                  this.openSystemVideoCapture()
                }
              })
          }
        }
        .width('100%')
        .height(220)

        Text(this.practiceMode === 'audio' ? this.audioCaptureTip : this.captureTip)
          .width('100%')
          .fontSize(12)
          .fontColor('#7A8CA7')
          .lineHeight(18)

        if (this.practiceMode === 'audio' && this.recordedAudioUri.length > 0) {
          Text(`已录音：${this.recordedAudioUri}`)
            .width('100%')
            .fontSize(11)
            .fontColor('#9AA8BD')
            .maxLines(2)
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
  private buildResultStage(item: TrainingItem) {
    Column({ space: 16 }) {
      Stack({ alignContent: Alignment.TopStart }) {
        Column() {
        }
        .width('100%')
        .height(342)
        .backgroundColor('#FFFFFF')
        .borderRadius(26)

        Column() {
        }
        .width(210)
        .height(210)
        .borderRadius(105)
        .border({
          width: 1,
          color: '#E6EEF9'
        })
        .position({ x: 198, y: -68 })
        .opacity(0.7)

        Column() {
        }
        .width(124)
        .height(124)
        .borderRadius(62)
        .border({
          width: 1,
          color: '#EEF3FA'
        })
        .position({ x: -22, y: 228 })
        .opacity(0.8)

        Column() {
        }
        .width('100%')
        .height(342)
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
              color: '#DCE6F5'
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

          Row({ space: 8 }) {
            this.buildResultBadge('完成度高', '#EEF5FF', '#2E79F4')
            this.buildResultBadge('节奏准确', '#EEF5FF', '#2E79F4')
            this.buildResultBadge('尾音待加强', '#EEF3FA', '#4E6F9F')
          }
          .width('100%')
          .justifyContent(FlexAlign.Center)
        }
        .width('100%')
        .padding(22)
      }
      .width('100%')
      .height(342)
      .shadow({ radius: 20, color: '#15304B14', offsetX: 0, offsetY: 10 })

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
        '#EEF3FA',
        '#4E6F9F'
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
    Text(label)
      .fontSize(13)
      .fontWeight(active ? FontWeight.Medium : FontWeight.Regular)
      .fontColor(active ? '#2563EB' : '#607089')
      .padding({ left: 14, right: 14, top: 10, bottom: 10 })
      .backgroundColor(active ? '#E7F0FF' : '#FFFFFF')
      .borderRadius(16)
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
  }

  @Builder
  private buildResultBadge(label: string, backgroundColor: string, fontColor: string) {
    Text(label)
      .fontSize(12)
      .fontWeight(FontWeight.Medium)
      .fontColor(fontColor)
      .padding({ left: 12, right: 12, top: 8, bottom: 8 })
      .backgroundColor(backgroundColor)
      .borderRadius(14)
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

      Row({ space: 0 }) {
        this.buildTrendPoint('1', 74, true)
        this.buildTrendConnector()
        this.buildTrendPoint('2', 79, false)
        this.buildTrendConnector()
        this.buildTrendPoint('3', 83, false)
        this.buildTrendConnector()
        this.buildTrendPoint('4', 87, false)
        this.buildTrendConnector()
        this.buildTrendPoint('5', 91, false)
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
  private buildTrendConnector() {
    Column() {
    }
    .width(18)
    .height(2)
    .backgroundColor('#C8D9EE')
    .margin({ bottom: 46 })
  }

  @Builder
  private buildTrendPoint(label: string, score: number, highlighted: boolean) {
    Column({ space: 8 }) {
      Text(`${score}`)
        .fontSize(12)
        .fontWeight(highlighted ? FontWeight.Bold : FontWeight.Medium)
        .fontColor(highlighted ? '#2E79F4' : '#6C7C95')

      Column() {
      }
      .width(10)
      .height(10)
      .backgroundColor(highlighted ? '#2E79F4' : '#B7CBE1')
      .borderRadius(5)
      .border({
        width: 3,
        color: highlighted ? '#E7F0FF' : '#EDF4FA'
      })

      Text(label)
        .fontSize(11)
        .fontColor('#8A99AD')
    }
    .width(40)
    .alignItems(HorizontalAlign.Center)
    .margin({ top: `${100 - score}%` })
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
