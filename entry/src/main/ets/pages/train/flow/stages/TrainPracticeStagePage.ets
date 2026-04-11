/**
 * 训练练习阶段页面。
 */

import media from '@ohos.multimedia.media'
import fs from '@ohos.file.fs'
import { hilog } from '@kit.PerformanceAnalysisKit'
import { PageLoadingOverlay } from '../../../../components/PageLoadingOverlay'
import { TrainPageQueries, TrainSessionRuntime, TrainSessionViewState } from '../../../../services/training/index'
import { PracticeMode } from '../../../../domain/static/train/TrainingRuntimeTypes'

@Component
export struct TrainPracticeStagePage {
  @Prop practiceMode: PracticeMode = 'video'
  onStartSpeechRecognition?: () => void
  onStopSpeechRecognition?: () => void
  onOpenLocalAudioPicker?: () => void
  onOpenLocalVideoPicker?: () => void
  @Prop isSpeechPreparing: boolean = false
  @Watch('handleSpeechListeningChange')
  @Prop isSpeechListening: boolean = false
  @Watch('handleSelectedVideoUriChange')
  @Prop selectedVideoUri: string = ''
  @Prop selectedAudioUri: string = ''
  @StorageLink('train.session.runtime') runtime: TrainSessionRuntime = TrainPageQueries.createEmptyRuntime()
  @StorageLink('train.session.viewState') viewState: TrainSessionViewState = TrainPageQueries.createEmptyViewState()

  @State isDemoAudioPlaying: boolean = false
  @State demoAudioProgress: number = 0
  @State demoAudioDurationSec: number = 9
  @State speechWaveTick: number = 0
  @State practiceVideoAspectRatio: number = 9 / 16
  @State practiceVideoAvailableWidth: number = 0
  @State isPracticeVideoRatioReady: boolean = false
  @State isPracticeVideoPrepared: boolean = false
  @State shouldRenderPracticeVideo: boolean = false

  private readonly demoAudioController: VideoController = new VideoController()
  private demoAudioTimer: number = -1
  private demoAudioStartAtMs: number = 0
  private speechWaveTimer: number = -1
  private practiceVideoRemountTimer: number = -1

  aboutToAppear(): void {
    this.handleSpeechListeningChange()
    this.shouldRenderPracticeVideo = this.selectedVideoUri.trim().length > 0
    void this.loadPracticeVideoAspectRatio()
  }

  aboutToDisappear(): void {
    this.stopDemoAudioPlayback()
    this.clearSpeechWaveTimer()
    if (this.practiceVideoRemountTimer !== -1) {
      clearTimeout(this.practiceVideoRemountTimer)
      this.practiceVideoRemountTimer = -1
    }
  }

  private handleSelectedVideoUriChange(): void {
    if (this.practiceVideoRemountTimer !== -1) {
      clearTimeout(this.practiceVideoRemountTimer)
      this.practiceVideoRemountTimer = -1
    }
    this.shouldRenderPracticeVideo = false
    this.isPracticeVideoPrepared = false
    void this.loadPracticeVideoAspectRatio()
    if (this.selectedVideoUri.trim().length > 0) {
      this.practiceVideoRemountTimer = setTimeout(() => {
        this.shouldRenderPracticeVideo = true
        this.practiceVideoRemountTimer = -1
      }, 0)
    }
  }

  private hasRecordedVideo(): boolean {
    return this.selectedVideoUri.trim().length > 0
  }

  private hasDemoAudio(): boolean {
    return TrainPageQueries.getCurrentItem(this.runtime).audio.length > 0
  }

  private getDemoAudioUrl(): string {
    const currentItem = TrainPageQueries.getCurrentItem(this.runtime)
    return currentItem.audio.length > 0 ? String(currentItem.audio[0].url ?? '') : ''
  }

  private formatDuration(durationSec: number): string {
    const safeDuration = Math.max(0, Math.floor(durationSec))
    const minutes = Math.floor(safeDuration / 60)
    const seconds = safeDuration % 60
    return `${minutes.toString().padStart(2, '0')}:${seconds.toString().padStart(2, '0')}`
  }

  private getDemoAudioProgressPercentText(): string {
    if (this.demoAudioDurationSec <= 0) {
      return '0%'
    }
    const raw = (this.demoAudioProgress / this.demoAudioDurationSec) * 100
    const clamped = Math.min(100, Math.max(0, raw))
    return `${clamped.toFixed(1)}%`
  }

  private applyDemoAudioDuration(durationSec: number): void {
    const safeDuration = Math.max(1, Math.floor(durationSec))
    this.demoAudioDurationSec = safeDuration
    if (this.demoAudioProgress > this.demoAudioDurationSec) {
      this.demoAudioProgress = this.demoAudioDurationSec
    }
  }

  private clearDemoAudioTimer(): void {
    if (this.demoAudioTimer !== -1) {
      clearInterval(this.demoAudioTimer)
      this.demoAudioTimer = -1
    }
  }

  private stopDemoAudioPlayback(): void {
    this.clearDemoAudioTimer()
    this.isDemoAudioPlaying = false
    this.demoAudioController.pause()
  }

  private startDemoAudioPlayback(): void {
    if (this.isDemoAudioPlaying) {
      return
    }
    this.clearDemoAudioTimer()
    if (this.demoAudioProgress >= this.demoAudioDurationSec) {
      this.demoAudioProgress = 0
    }
    this.demoAudioStartAtMs = Date.now() - Math.floor(this.demoAudioProgress * 1000)
    this.isDemoAudioPlaying = true
    this.demoAudioController.start()
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
    }, 50)
  }

  private clearSpeechWaveTimer(): void {
    if (this.speechWaveTimer !== -1) {
      clearInterval(this.speechWaveTimer)
      this.speechWaveTimer = -1
    }
  }

  private handleSpeechListeningChange(): void {
    if (!this.isSpeechListening) {
      this.clearSpeechWaveTimer()
      this.speechWaveTick = 0
      return
    }
    if (this.speechWaveTimer !== -1) {
      return
    }
    this.speechWaveTimer = setInterval(() => {
      this.speechWaveTick += 1
    }, 80)
  }

  private getSpeechWaveHeight(index: number): number {
    if (!this.isSpeechListening) {
      return index % 2 === 0 ? 10 : 16
    }
    const phase = (this.speechWaveTick * 0.42) + (index * 0.65)
    const normalized = (Math.sin(phase) + 1) / 2
    return 10 + Math.floor(normalized * 22)
  }

  private async loadPracticeVideoAspectRatio(): Promise<void> {
    const url = this.selectedVideoUri.trim()
    this.isPracticeVideoRatioReady = false
    this.isPracticeVideoPrepared = false
    if (url.length <= 0) {
      this.practiceVideoAspectRatio = 9 / 16
      this.isPracticeVideoRatioReady = true
      hilog.info(0x0, 'TrainVideoTrace', 'practiceVideo.empty')
      return
    }
    try {
      const sourceCandidates: string[] = [url]
      if (url.startsWith('file://')) {
        sourceCandidates.push(decodeURIComponent(url.substring(7)))
      }
      let resolved = false
      for (let index = 0; index < sourceCandidates.length; index += 1) {
        const candidate = sourceCandidates[index].trim()
        if (candidate.length <= 0) {
          continue
        }
        let extractor = await media.createAVMetadataExtractor()
        try {
          extractor.setUrlSource(candidate)
          const metadata = await extractor.fetchMetadata()
          const rawWidth = Number(metadata.videoWidth ?? '0')
          const rawHeight = Number(metadata.videoHeight ?? '0')
          const orientation = Number(metadata.videoOrientation ?? '0')
          hilog.info(0x0, 'TrainVideoTrace',
            `practiceVideo.metadata|candidate=${candidate}|rawWidth=${rawWidth}|rawHeight=${rawHeight}|orientation=${orientation}`)
          let width = rawWidth
          let height = rawHeight
          if (orientation === 90 || orientation === 270) {
            width = rawHeight
            height = rawWidth
          }
          if (width > 0 && height > 0) {
            this.practiceVideoAspectRatio = width / height
            hilog.info(0x0, 'TrainVideoTrace',
              `practiceVideo.resolved|candidate=${candidate}|width=${width}|height=${height}|ratio=${this.practiceVideoAspectRatio}`)
            resolved = true
            break
          }
        } catch (_error) {
          hilog.info(0x0, 'TrainVideoTrace', `practiceVideo.urlSourceFailed|candidate=${candidate}`)
        } finally {
          await extractor.release()
        }
        try {
          const file = await fs.open(candidate)
          extractor = await media.createAVMetadataExtractor()
          try {
            extractor.fdSrc = { fd: file.fd, offset: 0 }
            const metadata = await extractor.fetchMetadata()
            const rawWidth = Number(metadata.videoWidth ?? '0')
            const rawHeight = Number(metadata.videoHeight ?? '0')
            const orientation = Number(metadata.videoOrientation ?? '0')
            hilog.info(0x0, 'TrainVideoTrace',
              `practiceVideo.fdMetadata|candidate=${candidate}|rawWidth=${rawWidth}|rawHeight=${rawHeight}|orientation=${orientation}`)
            let width = rawWidth
            let height = rawHeight
            if (orientation === 90 || orientation === 270) {
              width = rawHeight
              height = rawWidth
            }
            if (width > 0 && height > 0) {
              this.practiceVideoAspectRatio = width / height
              hilog.info(0x0, 'TrainVideoTrace',
                `practiceVideo.fdResolved|candidate=${candidate}|width=${width}|height=${height}|ratio=${this.practiceVideoAspectRatio}`)
              resolved = true
              break
            }
          } finally {
            await extractor.release()
            await fs.close(file)
          }
        } catch (_fdError) {
          hilog.info(0x0, 'TrainVideoTrace', `practiceVideo.fdFailed|candidate=${candidate}`)
        }
      }
      if (!resolved) {
        this.practiceVideoAspectRatio = 9 / 16
        hilog.info(0x0, 'TrainVideoTrace', `practiceVideo.fallbackDefault|url=${url}`)
      }
    } catch (_error) {
      this.practiceVideoAspectRatio = 9 / 16
      hilog.info(0x0, 'TrainVideoTrace', `practiceVideo.error|url=${url}`)
    } finally {
      this.isPracticeVideoRatioReady = true
    }
  }

  private getPracticeVideoFrameWidth(): number {
    if (this.practiceVideoAvailableWidth <= 0) {
      return 360
    }
    return Math.min(this.practiceVideoAvailableWidth, 380)
  }

  private getPracticeVideoFrameHeight(): number {
    const width = this.getPracticeVideoFrameWidth()
    const ratio = this.practiceVideoAspectRatio > 0 ? this.practiceVideoAspectRatio : (9 / 16)
    return Math.min(width / ratio, 620)
  }

  private isPracticeVideoFrameReady(): boolean {
    return this.isPracticeVideoRatioReady && this.isPracticeVideoPrepared
  }

  @Builder
  private buildSpeechRecognitionButton() {
    Column({ space: 14 }) {
      Stack({ alignContent: Alignment.Center }) {
        Row()
          .width(112)
          .height(112)
          .backgroundColor(this.isSpeechListening ? '#EAF2FF' : '#F3F7FD')
          .borderRadius(56)

        if (this.isSpeechListening) {
          Row({ space: 5 }) {
            ForEach([0, 1, 2, 3, 4], (bar: number) => {
              Column()
                .width(6)
                .height(this.getSpeechWaveHeight(bar))
                .borderRadius(3)
                .backgroundColor('#2E79F4')
            }, (bar: number) => `${bar}`)
          }
          .height(40)
          .alignItems(VerticalAlign.Center)
        } else {
          SymbolGlyph($r('sys.symbol.mic_fill'))
            .fontSize(36)
            .fontColor([this.isSpeechPreparing ? '#A9B7CB' : '#2E79F4'])
        }
      }
      .width(112)
      .height(112)

      Button(this.isSpeechPreparing ? '准备中...' : (this.isSpeechListening ? '停止识别' : '开始识别'))
        .height(38)
        .fontSize(13)
        .fontWeight(FontWeight.Medium)
        .fontColor('#FFFFFF')
        .backgroundColor(this.isSpeechListening ? '#F97373' : '#2E79F4')
        .borderRadius(19)
        .enabled(!this.isSpeechPreparing)
        .padding({ left: 18, right: 18 })
        .onClick(() => {
          if (this.isSpeechListening) {
            if (this.onStopSpeechRecognition) this.onStopSpeechRecognition()
          } else if (this.onStartSpeechRecognition) {
            this.onStartSpeechRecognition()
          }
        })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  private buildSpeechDemoPlayer() {
    Column() {
      Row({ space: 12 }) {
        Button() {
          SymbolGlyph(this.isDemoAudioPlaying ? $r('sys.symbol.pause_fill') : $r('sys.symbol.play_fill'))
            .fontSize(18)
            .fontColor(['#2E79F4'])
        }
        .width(42)
        .height(42)
        .backgroundColor('#EEF5FF')
        .border({ width: 1, color: '#D8E6FB' })
        .borderRadius(21)
        .stateEffect(false)
        .onClick(() => {
          if (this.isDemoAudioPlaying) {
            this.stopDemoAudioPlayback()
          } else {
            this.startDemoAudioPlayback()
          }
        })

        Column({ space: 6 }) {
          Row() {
            Text('示范')
              .fontSize(12)
              .fontColor('#6F83A2')
              .fontWeight(FontWeight.Medium)

            Blank()

            Text(`${this.formatDuration(this.demoAudioProgress)} / ${this.formatDuration(this.demoAudioDurationSec)}`)
              .fontSize(12)
              .fontColor('#8FA1BA')
          }
          .width('100%')

          Stack({ alignContent: Alignment.Start }) {
            Row()
              .width('100%')
              .height(4)
              .backgroundColor('#DCE7F7')
              .borderRadius(2)

            Row()
              .width(this.getDemoAudioProgressPercentText())
              .height(4)
              .backgroundColor('#2E79F4')
              .borderRadius(2)
          }
          .width('100%')
        }
        .width('100%')
        .layoutWeight(1)
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)

      Video({
        src: this.getDemoAudioUrl(),
        controller: this.demoAudioController
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
    .padding({ left: 12, right: 12, top: 10, bottom: 10 })
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .border({ width: 1, color: '#E6EDF8' })
  }

  @Builder
  private buildSpeechPracticeContent() {
    Column({ space: 12 }) {
      this.buildSpeechRecognitionButton()

      Column({ space: 8 }) {
        Text(this.runtime.speechRecognizedText.trim().length > 0 ? this.runtime.speechRecognizedText : '识别结果会显示在这里')
          .width('100%')
          .fontSize(16)
          .fontColor(this.runtime.speechRecognizedText.trim().length > 0 ? '#1F2A44' : '#95A4BA')
          .lineHeight(24)

        if (this.viewState.speechPartialText.trim().length > 0 && this.viewState.speechPartialText !== this.runtime.speechRecognizedText) {
          Text(`实时片段：${this.viewState.speechPartialText}`)
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
    }
    .alignItems(HorizontalAlign.Start)
    .width('100%')
    .padding(16)
    .backgroundColor('#F7FAFE')
    .borderRadius(16)
    .border({ width: 1, color: '#E4ECF8' })
  }

  @Builder
  private buildGesturePracticeCard() {
    Column({ space: 14 }) {
      Row() {
        Text('我的练习视频')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor('#1F2A44')

        Blank()

        if (this.hasRecordedVideo()) {
          Button('重选')
            .height(30)
            .fontSize(12)
            .fontWeight(FontWeight.Medium)
            .fontColor('#2E79F4')
            .backgroundColor('#EEF5FF')
            .borderRadius(15)
            .padding({ left: 12, right: 12 })
            .stateEffect(false)
            .onClick(() => {
              if (this.onOpenLocalVideoPicker) this.onOpenLocalVideoPicker()
            })
        }
      }
      .width('100%')

      if (this.hasRecordedVideo()) {
        Stack({ alignContent: Alignment.Center }) {
          Stack({ alignContent: Alignment.Center }) {
            if (this.shouldRenderPracticeVideo) {
              Video({ src: this.selectedVideoUri })
                .width('100%')
                .height('100%')
                .objectFit(ImageFit.Contain)
                .controls(true)
                .autoPlay(false)
                .opacity(this.isPracticeVideoFrameReady() ? 1 : 0.01)
                .onPrepared(() => {
                  this.isPracticeVideoPrepared = true
                })
                .onStart(() => {
                  this.isPracticeVideoPrepared = true
                })
            }

            if (!this.isPracticeVideoFrameReady()) {
              PageLoadingOverlay({
                text: '正在加载视频...'
              })
            }
          }
          .width(this.getPracticeVideoFrameWidth())
          .height(this.getPracticeVideoFrameHeight())
          .backgroundColor('#F7FAFE')
          .borderRadius(20)
          .clip(true)
        }
        .width('100%')
        .onAreaChange((_oldValue: Area, newValue: Area) => {
          const width = Number(newValue.width ?? 0)
          if (width > 0) {
            this.practiceVideoAvailableWidth = width
          }
        })
      } else {
        Column() {
          Button('选择练习视频')
            .height(44)
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor('#FFFFFF')
            .backgroundColor('#2E79F4')
            .borderRadius(16)
            .padding({ left: 18, right: 18 })
            .onClick(() => {
              if (this.onOpenLocalVideoPicker) this.onOpenLocalVideoPicker()
            })
        }
        .width('100%')
        .height(252)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
        .backgroundColor('#F4F8FD')
        .borderRadius(20)
      }
    }
    .width('100%')
    .padding(18)
    .backgroundColor('#FFFFFF')
    .borderRadius(20)
    .border({ width: 1, color: '#E4ECF8' })
  }

  build() {
    Column({ space: 16 }) {
      Column({ space: 14 }) {
        Row({ space: 8 }) {
          Text(this.runtime.trainingType === 'speech' ? '音频跟读' : '手语跟练')
            .fontSize(11)
            .fontColor('#2E79F4')
            .padding({ left: 10, right: 10, top: 6, bottom: 6 })
            .backgroundColor('#EEF5FF')
            .borderRadius(12)

          Text(this.runtime.trainingType === 'speech' ? '发音评估' : '动作评估')
            .fontSize(11)
            .fontColor('#7A8CA7')
        }
        .width('100%')

        if (this.runtime.trainingType === 'speech' && this.hasDemoAudio()) {
          this.buildSpeechDemoPlayer()
        }

        if (this.runtime.trainingType === 'speech') {
          this.buildSpeechPracticeContent()
        } else {
          this.buildGesturePracticeCard()
        }
      }
      .width('100%')
      .padding(18)
      .backgroundColor('#FFFFFF')
      .borderRadius(18)
      .shadow({ radius: 18, color: '#1015304B', offsetX: 0, offsetY: 8 })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }
}
