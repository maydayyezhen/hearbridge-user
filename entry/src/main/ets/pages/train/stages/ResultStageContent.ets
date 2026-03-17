@Component
export struct ResultStageContent {
  @Prop itemName: string = ''
  @Prop score: number = 91

  build() {
    Column({ space: 16 }) {
      Stack({ alignContent: Alignment.TopStart }) {
        Column()
          .width('100%')
          .height(452)
          .backgroundColor('#FFFFFF')
          .borderRadius(26)

        Column()
          .width('100%')
          .height(118)
          .linearGradient({
            angle: 180,
            colors: [['#F7FAFF', 0], ['#FFFFFF', 1]]
          })
          .borderRadius({ topLeft: 26, topRight: 26, bottomLeft: 0, bottomRight: 0 })

        Column()
          .width('100%')
          .height(452)
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

          if (this.itemName.length > 0) {
            Text(`当前训练项：${this.itemName}`)
              .width('100%')
              .fontSize(13)
              .fontWeight(FontWeight.Medium)
              .fontColor('#2E79F4')
              .maxLines(1)
              .padding({ left: 12, right: 12, top: 8, bottom: 8 })
              .backgroundColor('#EEF5FF')
              .borderRadius(12)
          }

          Stack({ alignContent: Alignment.Center }) {
            Column()
              .width(178)
              .height(178)
              .borderRadius(89)
              .backgroundColor('#F7F9FD')
              .shadow({ radius: 20, color: '#1F2A4412', offsetX: 0, offsetY: 10 })
              .border({ width: 1, color: '#E8EEF8' })

            Column()
              .width(154)
              .height(154)
              .borderRadius(77)
              .border({ width: 10, color: this.getScoreRingColor(this.score) })
              .shadow({ radius: 8, color: '#FFFFFFCC', offsetX: 0, offsetY: 0 })

            Column({ space: 4 }) {
              Text(`${this.score}`)
                .fontSize(60)
                .fontWeight(FontWeight.Bolder)
                .fontStyle(FontStyle.Italic)
                .fontColor(this.getScoreTextColor(this.score))

              Text('训练得分')
                .fontSize(12)
                .fontWeight(FontWeight.Medium)
                .fontColor('#72829A')
                .letterSpacing(0.8)
            }
          }
          .width('100%')
          .height(178)

          Text(this.getScoreComment(this.score))
            .width('100%')
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .fontColor('#1F2A44')
            .textAlign(TextAlign.Center)

          Text('系统根据本轮动作完成度、节奏稳定性与发音表现，生成本次训练反馈。')
            .width('100%')
            .fontSize(12)
            .fontColor('#7D8CA2')
            .lineHeight(18)
            .textAlign(TextAlign.Center)

          Column()
            .width('100%')
            .height(1)
            .backgroundColor('#EDF2F8')

          this.buildScoreBadges(this.score)
        }
        .width('100%')
        .padding(22)
      }
      .width('100%')
      .height(452)
      .shadow({ radius: 20, color: '#15304B14', offsetX: 0, offsetY: 10 })
      .border({ width: 1, color: '#E8EEF7' })

      Column({ space: 14 }) {
        Text('维度分析')
          .width('100%')
          .fontSize(17)
          .fontWeight(FontWeight.Medium)
          .fontColor('#1F2A44')

        this.buildMetricRow('动作完成度', this.getMetricScore(this.score, 2))
        this.buildMetricRow('节奏稳定性', this.getMetricScore(this.score, -1))
        this.buildMetricRow('发音清晰度', this.getMetricScore(this.score, -5))
      }
      .width('100%')
      .padding(18)
      .backgroundColor('#F8FAFD')
      .borderRadius(20)
      .shadow({ radius: 18, color: '#15304B10', offsetX: 0, offsetY: 8 })
      .border({ width: 1, color: '#E8EEF7' })

      this.buildFeedbackModule(
        this.getStrengthTitle(this.score),
        this.getStrengthTags(this.score),
        this.getStrengthDesc(this.score),
        '#EEF5FF',
        '#2E79F4'
      )
      this.buildFeedbackModule(
        this.getImproveTitle(this.score),
        this.getImproveTags(this.score),
        this.getImproveDesc(this.score),
        '#FFF1F1',
        '#D94C4C'
      )

      this.buildRecentTrendCard()
    }
    .width('100%')
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
          .backgroundColor('#ECF2FA')
          .borderRadius(5)

        Column()
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
    .border({ width: 1, color: '#E3ECF8' })
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
  private buildScoreBadges(score: number) {
    Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Center, alignItems: ItemAlign.Start }) {
      if (score >= 90) {
        this.buildResultBadge('完成度高', '#EEF5FF', '#2E79F4')
        this.buildResultBadge('节奏准确', '#EEF5FF', '#2E79F4')
        this.buildResultBadge('尾音待加强', '#FFF1F1', '#D94C4C')
      } else if (score >= 75) {
        this.buildResultBadge('完成良好', '#EEF5FF', '#2E79F4')
        this.buildResultBadge('节奏基本稳定', '#EEF5FF', '#2E79F4')
        this.buildResultBadge('清晰度待提升', '#FFF1F1', '#D94C4C')
      } else {
        this.buildResultBadge('基础已建立', '#EEF5FF', '#2E79F4')
        this.buildResultBadge('动作可识别', '#EEF5FF', '#2E79F4')
        this.buildResultBadge('稳定性待提升', '#FFF1F1', '#D94C4C')
      }
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

      Row({ space: 12 }) {
        this.buildTrendBar(72, 8, 72)
        this.buildTrendBar(78, 8, 78)
        this.buildTrendBar(83, 8, 83)
        this.buildTrendBar(88, 8, 88)
        this.buildTrendBar(91, 8, 91)
      }
      .width('100%')
      .height(108)
      .alignItems(VerticalAlign.Bottom)

      Text('近 5 次训练整体呈稳定上升趋势，完成度与节奏控制均有明显提升。')
        .width('100%')
        .fontSize(12)
        .fontColor('#7A8CA7')
        .lineHeight(18)
    }
    .width('100%')
    .padding(18)
    .backgroundColor('#F9FBFE')
    .borderRadius(20)
    .shadow({ radius: 18, color: '#15304B10', offsetX: 0, offsetY: 8 })
  }

  @Builder
  private buildTrendBar(height: number, width: number, value: number) {
    Column({ space: 6 }) {
      Text(`${value}`)
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

  private getScoreComment(score: number): string {
    if (score >= 90) {
      return '表现稳定，建议继续巩固尾音控制'
    }
    if (score >= 75) {
      return '基础表现良好，建议提升节奏与发音清晰度'
    }
    return '已完成基础练习，建议放慢语速并稳定口型'
  }

  private getMetricScore(score: number, delta: number): number {
    const value = score + delta
    if (value < 60) {
      return 60
    }
    if (value > 99) {
      return 99
    }
    return value
  }

  private getStrengthTitle(score: number): string {
    if (score >= 90) {
      return '本次亮点'
    }
    if (score >= 75) {
      return '已有进步'
    }
    return '当前亮点'
  }

  private getStrengthTags(score: number): string[] {
    if (score >= 90) {
      return ['口型稳定', '节奏自然', '完成度高']
    }
    if (score >= 75) {
      return ['动作完成', '跟练积极', '基础稳定']
    }
    return ['完成训练', '动作可识别']
  }

  private getStrengthDesc(score: number): string {
    if (score >= 90) {
      return '本轮训练整体节奏稳定，关键发音动作完成较好，跟读完成度较高。'
    }
    if (score >= 75) {
      return '本轮整体完成度良好，关键动作基本到位，节奏控制有明显进步。'
    }
    return '本轮训练已建立基础动作模式，继续坚持可快速提升稳定性。'
  }

  private getImproveTitle(score: number): string {
    if (score >= 90) {
      return '建议改进'
    }
    if (score >= 75) {
      return '下一步建议'
    }
    return '重点改进'
  }

  private getImproveTags(score: number): string[] {
    if (score >= 90) {
      return ['尾音控制不足']
    }
    if (score >= 75) {
      return ['语速控制需加强']
    }
    return ['节奏稳定性不足']
  }

  private getImproveDesc(score: number): string {
    if (score >= 90) {
      return '下一轮建议放慢尾音收束速度，注意口型闭合时机，让结尾更清晰稳定。'
    }
    if (score >= 75) {
      return '建议把语速再放慢一点，保持每个音节都发满，避免中段含混。'
    }
    return '建议先降速并分段练习，优先稳住口型，再逐步提升连贯度。'
  }
}
