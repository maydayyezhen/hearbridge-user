@Component
export struct ResultStageContent {
  @Prop hasNextItem: boolean = false
  @Prop itemName: string = ''
  onRetry: () => void = () => {}
  onNext: () => void = () => {}

  build() {
    Column({ space: 16 }) {
      Stack({ alignContent: Alignment.TopStart }) {
        Column() {
        }
        .width('100%')
        .height(452)
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
      .height(452)
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
            this.onRetry()
          })

        Button(this.hasNextItem ? '下一项' : '返回课程')
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
            this.onNext()
          })
      }
      .width('100%')
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
}
