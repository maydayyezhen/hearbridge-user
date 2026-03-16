class RecordItem {
  date: string
  title: string
  duration: string

  constructor(date: string, title: string, duration: string) {
    this.date = date
    this.title = title
    this.duration = duration
  }
}

@Component
export struct RecordPage {
  @Prop dailyProgress: number = 0
  @Prop selectedFilter: string = '周'
  onFilterChange: (filter: string) => void = () => {}
  onOpenTraining: () => void = () => {}

  private readonly filters: string[] = ['周', '月', '总览']
  private readonly trendPoints: number[] = [30, 42, 36, 51, 47, 58, 64]
  private readonly recordItems: RecordItem[] = [
    new RecordItem('4月15日', '日常问候训练', '12 分钟'),
    new RecordItem('4月12日', '口型临摹练习', '8 分钟')
  ]

  build() {
    Column({ space: 18 }) {
      this.buildSummaryCard()
      this.buildTrendCard()
      this.buildHistoryCard()
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 6, bottom: 118 })
  }

  @Builder
  private buildSummaryCard() {
    Column({ space: 14 }) {
      Row() {
        Column({ space: 4 }) {
          Text('训练明星')
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFFFFF')

          Text('本周表现持续上升')
            .fontSize(13)
            .fontColor('#E5F1FF')
        }
        .alignItems(HorizontalAlign.Start)

        Blank()

        Text(`${this.dailyProgress}%`)
          .fontSize(34)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')
      }
      .width('100%')

      Text('建议：跟随范例再做一轮，准确度会更稳定。')
        .width('100%')
        .fontSize(13)
        .fontColor('#E5F1FF')
        .lineHeight(20)

      Button('开始一轮')
        .width('100%')
        .height(46)
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor('#2A74F4')
        .backgroundColor('#FFFFFF')
        .borderRadius(18)
        .onClick(() => {
          this.onOpenTraining()
        })
    }
    .width('100%')
    .padding(20)
    .linearGradient({
      angle: 135,
      colors: [['#58B8FF', 0], ['#2E79F4', 1]]
    })
    .borderRadius(28)
    .shadow({ radius: 20, color: '#2E79F433', offsetX: 0, offsetY: 10 })
  }

  @Builder
  private buildTrendCard() {
    Column({ space: 16 }) {
      Row() {
        Text('学习曲线')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor('#1F2A44')

        Blank()

        Row({ space: 8 }) {
          ForEach(this.filters, (filter: string) => {
            Text(filter)
              .fontSize(12)
              .fontColor(this.selectedFilter === filter ? '#2563EB' : '#7A8CA7')
              .padding({ left: 10, right: 10, top: 6, bottom: 6 })
              .backgroundColor(this.selectedFilter === filter ? '#E7F0FF' : '#F5F8FD')
              .borderRadius(12)
              .onClick(() => {
                this.onFilterChange(filter)
              })
          }, (filter: string) => filter)
        }
      }
      .width('100%')

      Row({ space: 10 }) {
        ForEach(this.trendPoints, (point: number) => {
          Column() {
            Blank()
            Column() {
            }
            .width('100%')
            .height(`${point}%`)
            .linearGradient({
              angle: 180,
              colors: [['#68D5F3', 0], ['#3E7CF6', 1]]
            })
            .borderRadius({ topLeft: 10, topRight: 10, bottomLeft: 10, bottomRight: 10 })
          }
          .justifyContent(FlexAlign.End)
          .layoutWeight(1)
          .height(120)
        }, (point: number) => point.toString())
      }
      .width('100%')
      .height(120)
    }
    .width('100%')
    .padding(18)
    .backgroundColor('#FFFFFF')
    .borderRadius(28)
    .shadow({ radius: 18, color: '#15304B10', offsetX: 0, offsetY: 8 })
  }

  @Builder
  private buildHistoryCard() {
    Column({ space: 12 }) {
      Row() {
        Text('历史记录')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor('#1F2A44')

        Blank()

        Text('...')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#8AA3C3')
      }
      .width('100%')

      ForEach(this.recordItems, (item: RecordItem) => {
        Row() {
          Column({ space: 4 }) {
            Text(item.date)
              .fontSize(13)
              .fontWeight(FontWeight.Medium)
              .fontColor('#1F2A44')

            Text(item.title)
              .fontSize(14)
              .fontColor('#607089')
          }
          .alignItems(HorizontalAlign.Start)

          Blank()

          Text(item.duration)
            .fontSize(13)
            .fontWeight(FontWeight.Medium)
            .fontColor('#3A86FF')
        }
        .width('100%')
        .padding(14)
        .backgroundColor('#F7FAFE')
        .borderRadius(20)
      }, (item: RecordItem) => item.date)
    }
    .width('100%')
    .padding(18)
    .backgroundColor('#FFFFFF')
    .borderRadius(28)
    .shadow({ radius: 18, color: '#15304B10', offsetX: 0, offsetY: 8 })
  }
}
