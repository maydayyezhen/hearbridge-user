/**
 * 训练流程阶段进度条。
 */
import { TrainStage } from '../../../../services/training/index'

@Component
export struct TrainStageStepper {
  @Prop stage: TrainStage = 'intro'

  private getStageOrder(): number {
    if (this.stage === 'video') {
      return 2
    }
    if (this.stage === 'guide') {
      return 3
    }
    if (this.stage === 'practice') {
      return 4
    }
    if (this.stage === 'result' || this.stage === 'summary') {
      return 5
    }
    return 1
  }

  @Builder
  private buildStageDot(order: number, label: string): void {
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
        .maxLines(1)
    }
    .padding({ left: 8, right: 8, top: 6, bottom: 6 })
    .backgroundColor(this.getStageOrder() === order ? '#EEF5FF' : '#F5F8FD')
    .borderRadius(14)
  }

  @Builder
  private buildStageSlot(order: number, label: string, justifyContent: FlexAlign): void {
    Row() {
      this.buildStageDot(order, label)
    }
    .layoutWeight(1)
    .justifyContent(justifyContent)
  }

  build(): void {
    Row() {
      this.buildStageSlot(1, '介绍', FlexAlign.Start)
      this.buildStageSlot(2, '视频', FlexAlign.Center)
      this.buildStageSlot(3, '步骤', FlexAlign.Center)
      this.buildStageSlot(4, '练习', FlexAlign.Center)
      this.buildStageSlot(5, '评分', FlexAlign.End)
    }
    .width('100%')
  }
}
