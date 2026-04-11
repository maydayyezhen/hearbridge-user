/**
 * TrainVideoStagePage 页面文件，负责页面展示与交互承接。
 */

import media from '@ohos.multimedia.media'
import { PageLoadingOverlay } from '../../../../components/PageLoadingOverlay'

@Component
export struct TrainVideoStagePage {
  @Prop videoUrl: string = ''
  @State videoAspectRatio: number = 9 / 16
  @State availableWidth: number = 0
  @State isVideoRatioReady: boolean = false
  @State isVideoPrepared: boolean = false
  private videoController: VideoController = new VideoController()

  aboutToAppear(): void {
    this.loadVideoAspectRatio()
  }

  private async loadVideoAspectRatio(): Promise<void> {
    const url = this.videoUrl.trim()
    this.isVideoRatioReady = false
    this.isVideoPrepared = false
    if (url.length <= 0) {
      this.videoAspectRatio = 9 / 16
      this.isVideoRatioReady = true
      return
    }
    try {
      const extractor = await media.createAVMetadataExtractor()
      try {
        extractor.setUrlSource(url)
        const metadata = await extractor.fetchMetadata()
        const rawWidth = Number(metadata.videoWidth ?? '0')
        const rawHeight = Number(metadata.videoHeight ?? '0')
        const orientation = Number(metadata.videoOrientation ?? '0')
        let width = rawWidth
        let height = rawHeight
        if (orientation === 90 || orientation === 270) {
          width = rawHeight
          height = rawWidth
        }
        if (width > 0 && height > 0) {
          this.videoAspectRatio = width / height
        } else {
          this.videoAspectRatio = 9 / 16
        }
      } finally {
        await extractor.release()
      }
    } catch (_error) {
      this.videoAspectRatio = 9 / 16
    } finally {
      this.isVideoRatioReady = true
    }
  }

  private isVideoFrameReady(): boolean {
    return this.isVideoRatioReady && this.isVideoPrepared
  }

  private getVideoFrameWidth(): number {
    if (this.availableWidth <= 0) {
      return 360
    }
    return Math.min(this.availableWidth, 380)
  }

  private getVideoFrameHeight(): number {
    const width = this.getVideoFrameWidth()
    const ratio = this.videoAspectRatio > 0 ? this.videoAspectRatio : (9 / 16)
    const computedHeight = width / ratio
    return Math.min(computedHeight, 620)
  }

  build() {
    Stack({ alignContent: Alignment.Center }) {
      Stack({ alignContent: Alignment.Center }) {
        Video({ src: this.videoUrl, controller: this.videoController })
          .width('100%')
          .height('100%')
          .objectFit(ImageFit.Contain)
          .backgroundColor('#F7FAFE')
          .borderRadius(24)
          .controls(true)
          .autoPlay(true)
          .opacity(this.isVideoFrameReady() ? 1 : 0.01)
          .onPrepared(() => {
            this.isVideoPrepared = true
          })
          .onStart(() => {
            this.isVideoPrepared = true
          })

        if (!this.isVideoFrameReady()) {
          PageLoadingOverlay({
            text: '正在加载视频...'
          })
        }
      }
      .width(this.getVideoFrameWidth())
      .height(this.getVideoFrameHeight())
      .backgroundColor('#F7FAFE')
      .borderRadius(24)
      .clip(true)
    }
    .width('100%')
    .height('100%')
    .padding({ left: 16, right: 16, top: 8, bottom: 8 })
    .onAreaChange((_oldValue: Area, newValue: Area) => {
      const width = Number(newValue.width ?? 0)
      if (width > 0) {
        this.availableWidth = width - 32
      }
    })
  }
}
