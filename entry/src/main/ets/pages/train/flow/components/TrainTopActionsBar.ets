/**
 * 训练流程顶部动作栏。
 */
import { TrainStage } from '../../../../services/training/index'

@Component
export struct TrainTopActionsBar {
  @Prop stage: TrainStage = 'intro'
  @Prop hasDemoVideo: boolean = false
  @Prop isScoring: boolean = false
  @Prop isLastItem: boolean = false
  onPause: () => void = () => {}
  onForward: () => void = () => {}
  onBackToIntro: () => void = () => {}
  onBackToGuide: () => void = () => {}
  onBackToPreviousStage: () => void = () => {}
  onSubmitPractice: () => void = () => {}
  onRetryPractice: () => void = () => {}
  onExitToTrainRoot: () => void = () => {}

  @Builder
  private buildSecondaryAction(label: string, action: () => void) {
    Button(label)
      .layoutWeight(1)
      .height(38)
      .fontSize(13)
      .fontWeight(FontWeight.Medium)
      .fontColor('#2E79F4')
      .backgroundColor('#FFFFFF')
      .borderRadius(19)
      .border({ width: 1, color: '#D9E6FA' })
      .stateEffect(false)
      .onClick(() => { action() })
  }

  @Builder
  private buildPrimaryAction(label: string, action: () => void, enabled: boolean = true) {
    Button(label)
      .layoutWeight(1)
      .height(38)
      .fontSize(13)
      .fontWeight(FontWeight.Medium)
      .fontColor('#FFFFFF')
      .linearGradient({ angle: 135, colors: [['#4F95FF', 0], ['#2E79F4', 1]] })
      .borderRadius(19)
      .opacity(enabled ? 1 : 0.6)
      .stateEffect(false)
      .enabled(enabled)
      .onClick(() => { action() })
  }

  build() {
    Row({ space: 12 }) {
      if (this.stage === 'intro') {
        this.buildSecondaryAction('暂停训练', () => { this.onPause() })
        this.buildPrimaryAction(this.hasDemoVideo ? '进入示范' : '进入指导', () => { this.onForward() })
      } else if (this.stage === 'video') {
        this.buildSecondaryAction('返回准备', () => { this.onBackToIntro() })
        this.buildPrimaryAction('进入指导', () => { this.onForward() })
      } else if (this.stage === 'guide') {
        this.buildSecondaryAction('返回上一阶段', () => { this.onBackToPreviousStage() })
        this.buildPrimaryAction('开始练习', () => { this.onForward() })
      } else if (this.stage === 'practice') {
        this.buildSecondaryAction('返回指导', () => { this.onBackToGuide() })
        this.buildPrimaryAction('提交本轮练习', () => { this.onSubmitPractice() }, !this.isScoring)
      } else if (this.stage === 'result') {
        this.buildSecondaryAction('再练一次', () => { this.onRetryPractice() })
        this.buildPrimaryAction(this.isLastItem ? '查看总结' : '下一项', () => { this.onForward() })
      } else {
        Button('返回训练列表')
          .width('100%')
          .height(38)
          .fontSize(13)
          .fontWeight(FontWeight.Medium)
          .fontColor('#2E79F4')
          .backgroundColor('#EEF5FF')
          .borderRadius(19)
          .stateEffect(false)
          .onClick(() => { this.onExitToTrainRoot() })
      }
    }
    .width('100%')
  }
}
