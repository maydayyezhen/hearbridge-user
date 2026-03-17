@Component
export struct SummaryStageContent {
  @Prop trainingType: string = 'gesture'
  @Prop completedCount: number = 0
  @Prop totalCount: number = 0
  @Prop averageScore: number = 0
  @Prop bestScore: number = 0
  @Prop mode: string = 'completed'
  @Prop pausedAtName: string = ''

  build() {
    Column({ space: 14 }) {
      this.buildHeroCard()
      this.buildMetricRow()
      this.buildTrendCard()
      this.buildDimensionCard()
      this.buildSuggestionCard()
    }
    .width('100%')
  }

  @Builder
  private buildHeroCard() {
    Row({ space: 14 }) {
      Stack({ alignContent: Alignment.Center }) {
        Column()
          .width(108)
          .height(108)
          .borderRadius(54)
          .backgroundColor('#EEF5FF')
          .border({ width: 1, color: '#DDE9F8' })

        Stack({ alignContent: Alignment.Center }) {
          Column()
            .width(84)
            .height(84)
            .borderRadius(42)
            .border({ width: 8, color: '#DCE8F8' })

          Column()
            .width(84)
            .height(84)
            .borderRadius(42)
            .clip(true)
            .linearGradient({
              angle: 180,
              colors: [['#73AEFF', 0], ['#2E79F4', 1]]
            })
            .opacity(0.2)

          Text(`${this.getCompletionPercent()}%`)
            .fontSize(17)
            .fontWeight(FontWeight.Bold)
            .fontColor('#2E79F4')
        }
      }

      Column({ space: 6 }) {
        Text(this.mode === 'paused'
          ? `已暂停在「${this.pausedAtName.length > 0 ? this.pausedAtName : '当前训练项'}」，下次将从未完成项继续。`
          : '本轮训练已完成，下面是你的整体表现。')
          .fontSize(13)
          .fontColor('#6E7F98')
          .lineHeight(20)

        Row({ space: 8 }) {
          this.buildBadge(this.trainingType === 'speech' ? '口语专项' : '手势专项')
          this.buildBadge('系统反馈')
        }
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .padding(18)
    .backgroundColor('#FFFFFF')
    .borderRadius(20)
    .border({ width: 1, color: '#E6EDF8' })
    .shadow({ radius: 16, color: '#15304B10', offsetX: 0, offsetY: 8 })
  }

  @Builder
  private buildMetricRow() {
    Row({ space: 10 }) {
      this.buildSummaryMetric('完成项', `${this.completedCount}/${this.totalCount}`)
      this.buildSummaryMetric('平均分', `${this.averageScore}`)
      this.buildSummaryMetric('最高分', `${this.bestScore}`)
    }
    .width('100%')
  }

  @Builder
  private buildTrendCard() {
    Column({ space: 12 }) {
      Row() {
        Text('成绩走势')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#1F2A44')

        Blank()

        Text('最近 5 项')
          .fontSize(12)
          .fontColor('#7A8CA7')
      }
      .width('100%')

      Row({ space: 10 }) {
        this.buildTrendBar('1', this.getTrendScore(0), false)
        this.buildTrendBar('2', this.getTrendScore(1), false)
        this.buildTrendBar('3', this.getTrendScore(2), false)
        this.buildTrendBar('4', this.getTrendScore(3), false)
        this.buildTrendBar('5', this.getTrendScore(4), true)
      }
      .width('100%')
      .height(136)
      .alignItems(VerticalAlign.Bottom)
    }
    .width('100%')
    .padding(18)
    .backgroundColor('#FFFFFF')
    .borderRadius(20)
    .border({ width: 1, color: '#E6EDF8' })
    .shadow({ radius: 16, color: '#15304B10', offsetX: 0, offsetY: 8 })
  }

  @Builder
  private buildDimensionCard() {
    Column({ space: 12 }) {
      Text('能力分布')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor('#1F2A44')

      this.buildDimensionRow('完成度', this.averageScore + 2)
      this.buildDimensionRow(this.trainingType === 'speech' ? '节奏稳定性' : '动作连贯性', this.averageScore - 1)
      this.buildDimensionRow(this.trainingType === 'speech' ? '发音清晰度' : '关键姿态准确度', this.averageScore - 3)
    }
    .width('100%')
    .padding(18)
    .backgroundColor('#FFFFFF')
    .borderRadius(20)
    .border({ width: 1, color: '#E6EDF8' })
    .shadow({ radius: 16, color: '#15304B10', offsetX: 0, offsetY: 8 })
  }

  @Builder
  private buildSuggestionCard() {
    Column({ space: 10 }) {
      Text('系统建议')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor('#1F2A44')

      Text(this.trainingType === 'speech'
        ? '继续保持发音节奏稳定，下一轮重点关注尾音收束和句尾清晰度。'
        : '继续保持动作连贯和幅度稳定，下一轮重点关注关键手势定位。')
        .width('100%')
        .fontSize(13)
        .fontColor('#5F718B')
        .lineHeight(21)
    }
    .width('100%')
    .padding(18)
    .backgroundColor('#FFFFFF')
    .borderRadius(20)
    .border({ width: 1, color: '#E6EDF8' })
    .shadow({ radius: 16, color: '#15304B10', offsetX: 0, offsetY: 8 })
  }

  @Builder
  private buildSummaryMetric(label: string, value: string) {
    Column({ space: 6 }) {
      Text(label)
        .fontSize(12)
        .fontColor('#7A8CA7')

      Text(value)
        .fontSize(21)
        .fontWeight(FontWeight.Bold)
        .fontColor('#2E79F4')
    }
    .layoutWeight(1)
    .padding({ left: 10, right: 10, top: 14, bottom: 14 })
    .backgroundColor('#FFFFFF')
    .borderRadius(16)
    .border({ width: 1, color: '#E6EDF8' })
    .shadow({ radius: 12, color: '#15304B0D', offsetX: 0, offsetY: 6 })
  }

  @Builder
  private buildBadge(label: string) {
    Text(label)
      .fontSize(11)
      .fontColor('#2E79F4')
      .padding({ left: 9, right: 9, top: 6, bottom: 6 })
      .backgroundColor('#EEF5FF')
      .borderRadius(12)
  }

  @Builder
  private buildTrendBar(label: string, score: number, highlighted: boolean) {
    Column({ space: 6 }) {
      Text(`${score}`)
        .fontSize(11)
        .fontWeight(highlighted ? FontWeight.Bold : FontWeight.Medium)
        .fontColor(highlighted ? '#2E79F4' : '#6C7C95')

      Stack({ alignContent: Alignment.Bottom }) {
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor('#F4F8FE')
          .borderRadius(10)

        Column()
          .width('100%')
          .height(`${score}%`)
          .linearGradient({
            angle: 180,
            colors: highlighted ? [['#74AEFF', 0], ['#2E79F4', 1]] : [['#C9D8EB', 0], ['#AFC3DA', 1]]
          })
          .borderRadius({ topLeft: 8, topRight: 8, bottomLeft: 8, bottomRight: 8 })
      }
      .width('100%')
      .layoutWeight(1)
      .padding({ left: 6, right: 6, top: 6, bottom: 6 })
      .backgroundColor(highlighted ? '#EEF5FF' : '#F8FAFD')
      .borderRadius(12)

      Text(label)
        .fontSize(11)
        .fontColor('#8A99AD')
    }
    .width(52)
    .height(130)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  private buildDimensionRow(label: string, value: number) {
    Column({ space: 7 }) {
      Row() {
        Text(label)
          .fontSize(13)
          .fontColor('#30435F')

        Blank()

        Text(`${this.getSafeDimensionValue(value)}`)
          .fontSize(13)
          .fontWeight(FontWeight.Medium)
          .fontColor('#2E79F4')
      }
      .width('100%')

      Stack({ alignContent: Alignment.Start }) {
        Row()
          .width('100%')
          .height(8)
          .backgroundColor('#EAF1FB')
          .borderRadius(4)

        Row()
          .width(`${this.getSafeDimensionValue(value)}%`)
          .height(8)
          .linearGradient({
            angle: 90,
            colors: [['#7CB3FF', 0], ['#2E79F4', 1]]
          })
          .borderRadius(4)
      }
      .width('100%')
    }
    .width('100%')
  }

  private getCompletionPercent(): number {
    if (this.totalCount <= 0) {
      return 0
    }
    return Math.max(0, Math.min(100, Math.floor((this.completedCount * 100) / this.totalCount)))
  }

  private getTrendScore(index: number): number {
    const base = this.averageScore - 8 + index * 3
    return Math.max(55, Math.min(98, base))
  }

  private getSafeDimensionValue(value: number): number {
    return Math.max(40, Math.min(100, value))
  }
}
