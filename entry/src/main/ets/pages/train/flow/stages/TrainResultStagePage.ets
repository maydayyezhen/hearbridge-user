/**
 * TrainResultStagePage 椤甸潰鏂囦欢锛岃礋璐ｉ〉闈㈠睍绀轰笌浜や簰鎵挎帴銆?
 */

import { TrainPageQueries, TrainResultDimension, TrainResultViewState, TrainSessionRuntime } from '../../../../services/training/index'

@Component
export struct TrainResultStagePage {
  @StorageLink('train.session.runtime') runtime: TrainSessionRuntime = TrainPageQueries.createEmptyRuntime()
  @StorageLink('train.session.resultViewState') resultViewState: TrainResultViewState = TrainPageQueries.createEmptyResultViewState()

  private getCurrentItemName(): string {
    return TrainPageQueries.getCurrentItem(this.runtime).name
  }

  build() {
    Column({ space: 16 }) {
      this.buildHeroCard()
      if (this.resultViewState.resultDimensions.length > 0) {
        this.buildDimensionCard()
      }
      if (this.resultViewState.resultStrengths.title.length > 0
        || this.resultViewState.resultStrengths.tags.length > 0
        || this.resultViewState.resultStrengths.description.length > 0) {
        this.buildFeedbackModule(
          this.resultViewState.resultStrengths.title,
          this.resultViewState.resultStrengths.tags,
          this.resultViewState.resultStrengths.description,
          '#EEF5FF',
          '#2E79F4'
        )
      }
      if (this.resultViewState.resultImprovements.title.length > 0
        || this.resultViewState.resultImprovements.tags.length > 0
        || this.resultViewState.resultImprovements.description.length > 0) {
        this.buildFeedbackModule(
          this.resultViewState.resultImprovements.title,
          this.resultViewState.resultImprovements.tags,
          this.resultViewState.resultImprovements.description,
          '#FFF1F1',
          '#D94C4C'
        )
      }
      if (this.resultViewState.resultRecentTrend.title.length > 0
        || this.resultViewState.resultRecentTrend.scores.length > 0
        || this.resultViewState.resultRecentTrend.description.length > 0) {
        this.buildRecentTrendCard()
      }
    }
    .width('100%')
  }

  @Builder
  private buildHeroCard() {
    Stack({ alignContent: Alignment.TopStart }) {
      Column()
        .width('100%')
        .height(452)
        .backgroundColor('#FFFFFF')
        .borderRadius(26)

      Column()
        .width('100%')
        .height(102)
        .linearGradient({
          angle: 180,
          colors: [['#EEF5FF', 0], ['#FFFFFF', 1]]
        })
        .borderRadius({ topLeft: 26, topRight: 26, bottomLeft: 0, bottomRight: 0 })

      Column({ space: 16 }) {
        Row() {
          Text('评分结果')
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor('#6C7C95')
        }
        .width('100%')

        if (this.getCurrentItemName().length > 0) {
          Row({ space: 6 }) {
            Text('当前训练项')
              .fontSize(12)
              .fontColor('#7A8CA7')

            Text(this.getCurrentItemName())
              .layoutWeight(1)
              .fontSize(13)
              .fontWeight(FontWeight.Medium)
              .fontColor('#2E79F4')
              .maxLines(1)
          }
          .width('100%')
          .padding({ left: 12, right: 12, top: 8, bottom: 8 })
          .backgroundColor('#F4F8FF')
          .borderRadius(14)
          .border({ width: 1, color: '#E1EBFA' })
        }

        Stack({ alignContent: Alignment.Center }) {
          Column()
            .width(192)
            .height(192)
            .borderRadius(96)
            .backgroundColor('#FAFCFF')
            .shadow({ radius: 22, color: '#10153024', offsetX: 0, offsetY: 12 })
            .border({ width: 1, color: '#EDF2F9' })

          Column()
            .width(178)
            .height(178)
            .borderRadius(89)
            .backgroundColor('#F7F9FD')
            .shadow({ radius: 18, color: '#10153020', offsetX: 0, offsetY: 8 })
            .border({ width: 1, color: '#E8EEF8' })

          Column()
            .width(154)
            .height(154)
            .borderRadius(77)
            .border({ width: 10, color: this.getScoreRingColor(this.runtime.currentScore) })

          Column({ space: 4 }) {
            Text(`${this.runtime.currentScore}`)
              .fontSize(60)
              .fontWeight(FontWeight.Bolder)
              .fontStyle(FontStyle.Italic)
              .fontColor(this.getScoreTextColor(this.runtime.currentScore))

            Text(this.resultViewState.resultScoreLabel)
              .fontSize(12)
              .fontWeight(FontWeight.Medium)
              .fontColor('#72829A')
              .letterSpacing(0.8)
          }
        }
        .width('100%')
        .height(192)

        Text(this.resultViewState.resultTitle)
          .width('100%')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor('#1F2A44')
          .textAlign(TextAlign.Center)

        Column()
          .width('100%')
          .height(1)
          .backgroundColor('#EDF2F8')

        if (this.resultViewState.resultBadges.length > 0) {
          this.buildScoreBadges()
        }
      }
      .width('100%')
      .padding(22)
    }
    .width('100%')
    .height(452)
    .borderRadius(26)
    .clip(true)
    .shadow({ radius: 18, color: '#10153026', offsetX: 0, offsetY: 10 })
    .border({ width: 1, color: '#E8EEF7' })
  }

  @Builder
  private buildDimensionCard() {
    Column({ space: 14 }) {
      Text('维度分析')
        .width('100%')
        .fontSize(17)
        .fontWeight(FontWeight.Medium)
        .fontColor('#1F2A44')

      ForEach(this.resultViewState.resultDimensions, (item: TrainResultDimension) => {
        this.buildMetricRow(item.label, item.score)
      }, (item: TrainResultDimension) => `${item.label}_${item.score}`)
    }
    .width('100%')
    .padding(18)
    .backgroundColor('#F8FAFD')
    .borderRadius(20)
    .shadow({ radius: 14, color: '#1015301C', offsetX: 0, offsetY: 8 })
    .border({ width: 1, color: '#E8EEF7' })
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
        Column()
          .width('100%')
          .height(10)
          .backgroundColor('#EAF0F8')
          .borderRadius(5)

        Column()
          .width(`${value}%`)
          .height(10)
          .linearGradient({ angle: 0, colors: [['#6EAFFF', 0], ['#2E79F4', 1]] })
          .borderRadius(5)
      }
      .width('100%')
    }
    .width('100%')
    .padding(14)
    .backgroundColor('#F7FAFD')
    .borderRadius(16)
    .border({ width: 1, color: '#E3ECF8' })
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
  private buildScoreBadges() {
    Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Center, alignItems: ItemAlign.Start }) {
      ForEach(this.resultViewState.resultBadges, (badge: string) => {
        this.buildResultBadge(
          badge,
          this.isWarningBadge(badge) ? '#FFF1F1' : '#EEF5FF',
          this.isWarningBadge(badge) ? '#D94C4C' : '#2E79F4'
        )
      }, (badge: string) => badge)
    }
    .width('100%')
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
    .border({ width: 1, color: '#E8EEF7' })
    .shadow({ radius: 14, color: '#10153018', offsetX: 0, offsetY: 8 })
  }

  @Builder
  private buildRecentTrendCard() {
    Column({ space: 14 }) {
      Row() {
        Text(this.resultViewState.resultRecentTrend.title)
          .fontSize(17)
          .fontWeight(FontWeight.Medium)
          .fontColor('#1F2A44')

        Blank()

        Text(`最近 ${this.resultViewState.resultRecentTrend.scores.length} 次`)
          .fontSize(12)
          .fontColor('#7A8CA7')
      }
      .width('100%')

      Row({ space: 12 }) {
        ForEach(this.resultViewState.resultRecentTrend.scores, (value: number, index: number) => {
          this.buildTrendBar(value, 8)
        }, (value: number, index: number) => `${index}_${value}`)
      }
      .width('100%')
      .height(108)
      .alignItems(VerticalAlign.Bottom)

      Text(this.resultViewState.resultRecentTrend.description)
        .width('100%')
        .fontSize(12)
        .fontColor('#7A8CA7')
        .lineHeight(18)
    }
    .width('100%')
    .padding(18)
    .backgroundColor('#F9FBFE')
    .borderRadius(20)
    .border({ width: 1, color: '#E8EEF7' })
    .shadow({ radius: 14, color: '#10153018', offsetX: 0, offsetY: 8 })
  }

  @Builder
  private buildTrendBar(height: number, width: number) {
    Column({ space: 6 }) {
      Text(`${height}`)
        .fontSize(10)
        .fontColor('#7A8CA7')

      Column()
        .width(width)
        .height(height)
        .linearGradient({ angle: 180, colors: [['#8BB7FF', 0], ['#2E79F4', 1]] })
        .borderRadius(6)
    }
    .width(26)
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.End)
  }

  private getScoreTextColor(score: number): string {
    if (score >= 90) {
      return '#2E79F4'
    }
    if (score >= 75) {
      return '#3C87F6'
    }
    return '#5C9AF8'
  }

  private getScoreRingColor(score: number): string {
    if (score >= 90) {
      return '#C8DEFF'
    }
    if (score >= 75) {
      return '#D2E3FF'
    }
    return '#DCE9FF'
  }

  private isWarningBadge(label: string): boolean {
    return label.indexOf('弱') >= 0 || label.indexOf('不足') >= 0 || label.indexOf('提升') >= 0
  }
}
