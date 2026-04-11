/**
 * 训练流程顶部标题区域。
 */

import { TrainStage } from '../../../../services/training/index'

@Component
export struct TrainStageTopArea {
  @Prop headerTitle: string = ''
  @Prop courseName: string = ''
  @Prop stageTitle: string = ''
  @Prop stage: TrainStage = 'intro'
  @Prop progressText: string = '0/0'
  @Prop isScoring: boolean = false
  @Prop isLastItem: boolean = false
  onBackClick: () => void = () => {}
  onNextClick: () => void = () => {}

  private getNextLabel(): string {
    if (this.stage === 'practice') {
      return this.isScoring ? '提交中...' : '提交'
    }
    if (this.stage === 'result') {
      return this.isLastItem ? '查看总结' : '下一项'
    }
    if (this.stage === 'summary') {
      return '返回课程'
    }
    return '下一步'
  }

  private getMetaLeftText(): string {
    return this.stageTitle.trim().length > 0 ? this.stageTitle : this.courseName
  }

  build() {
    Column({ space: 8 }) {
      Stack({ alignContent: Alignment.Center }) {
        Text(this.headerTitle.length > 0 ? this.headerTitle : this.courseName)
          .width('100%')
          .padding({ left: 44, right: 44 })
          .textAlign(TextAlign.Center)
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1F2A44')
          .maxLines(1)

        Row() {
          Button() {
            SymbolGlyph($r('sys.symbol.chevron_backward'))
              .fontSize(15)
              .fontColor([this.stage !== 'summary' && !this.isScoring ? '#2E79F4' : '#A6B4C8'])
          }
            .width(34)
            .height(34)
            .backgroundColor('#F1F5FB')
            .borderRadius(17)
            .enabled(this.stage !== 'summary' && !this.isScoring)
            .opacity(this.stage !== 'summary' && !this.isScoring ? 1 : 0.5)
            .onClick(() => {
              this.onBackClick()
            })

          Blank()

          if (this.stage === 'practice' || this.stage === 'result' || this.stage === 'summary') {
            Button(this.getNextLabel())
              .height(34)
              .fontSize(12)
              .fontWeight(FontWeight.Medium)
              .fontColor('#FFFFFF')
              .backgroundColor('#2E79F4')
              .borderRadius(17)
              .padding({ left: 10, right: 10 })
              .enabled(!this.isScoring)
              .opacity(this.isScoring ? 0.55 : 1)
              .onClick(() => {
                this.onNextClick()
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
              .enabled(!this.isScoring)
              .opacity(this.isScoring ? 0.55 : 1)
              .onClick(() => {
                this.onNextClick()
              })
          }
        }
        .width('100%')
      }
      .width('100%')

      Row({ space: 8 }) {
        Text(this.getMetaLeftText())
          .fontSize(11)
          .fontColor('#8A9AB0')
          .maxLines(1)

        Text(`· ${this.progressText}`)
          .fontSize(12)
          .fontWeight(FontWeight.Medium)
          .fontColor('#6F83A2')

        if (this.courseName.trim().length > 0 && this.stageTitle.trim().length > 0) {
          Text(`· ${this.courseName}`)
            .fontSize(11)
            .fontColor('#8A9AB0')
            .maxLines(1)
        }
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
    }
    .width('100%')
  }
}
