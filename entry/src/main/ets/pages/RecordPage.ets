export class RecentCourseItem {
  courseCode: string
  courseName: string
  lastLearnedAt: string
  coverUrl: string
  progressPercent: number

  constructor(
    courseCode: string,
    courseName: string,
    lastLearnedAt: string,
    coverUrl: string,
    progressPercent: number
  ) {
    this.courseCode = courseCode
    this.courseName = courseName
    this.lastLearnedAt = lastLearnedAt
    this.coverUrl = coverUrl
    this.progressPercent = progressPercent
  }
}

@Component
export struct RecordPage {
  @Prop dailyProgress: number = 0
  @Prop selectedFilter: string = '周'
  @Prop recentCourses: RecentCourseItem[] = []
  onFilterChange: (filter: string) => void = () => {}
  onOpenTraining: () => void = () => {}
  onOpenRecentCourse: (courseCode: string) => void = (_courseCode: string) => {}

  private readonly filters: string[] = ['周', '月', '总览']
  private readonly trendPoints: number[] = [30, 42, 36, 51, 47, 58, 64]

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

      Text('建议：跟随示例再做一轮，准确度会更稳定。')
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
            .borderRadius(10)
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
        Text('最近学习课程')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor('#1F2A44')

        Blank()

        Text(`${this.recentCourses.length} 条`)
          .fontSize(13)
          .fontColor('#8AA3C3')
      }
      .width('100%')

      if (this.recentCourses.length === 0) {
        Text('暂无学习记录')
          .width('100%')
          .fontSize(13)
          .fontColor('#8AA0BC')
          .textAlign(TextAlign.Center)
          .padding({ top: 10, bottom: 6 })
      } else {
        ForEach(this.recentCourses, (item: RecentCourseItem) => {
          this.buildRecentCourseCard(item)
        }, (item: RecentCourseItem) => `${item.courseCode}_${item.lastLearnedAt}`)
      }
    }
    .width('100%')
    .padding(18)
    .backgroundColor('#FFFFFF')
    .borderRadius(28)
    .shadow({ radius: 18, color: '#15304B10', offsetX: 0, offsetY: 8 })
  }

  @Builder
  private buildRecentCourseCard(item: RecentCourseItem) {
    Column({ space: 10 }) {
      Row({ space: 12 }) {
        Image(item.coverUrl)
          .width(96)
          .height(54)
          .objectFit(ImageFit.Cover)
          .borderRadius(10)

        Column({ space: 6 }) {
          Text(item.courseName)
            .width('100%')
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor('#1F2A44')
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })

          Text(`${item.courseCode}  ·  ${item.lastLearnedAt}`)
            .width('100%')
            .fontSize(11)
            .fontColor('#7A8CA7')
            .maxLines(1)
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')

      Row({ space: 8 }) {
        Stack({ alignContent: Alignment.Start }) {
          Row()
            .width('100%')
            .height(8)
            .backgroundColor('#EAF1FB')
            .borderRadius(8)

          Row()
            .width(`${this.getSafeProgress(item.progressPercent)}%`)
            .height(8)
            .linearGradient({
              angle: 90,
              colors: [['#74B8FF', 0], ['#2E79F4', 1]]
            })
            .borderRadius(8)
        }
        .layoutWeight(1)
        .height(8)

        Text(`${this.getSafeProgress(item.progressPercent)}%`)
          .fontSize(12)
          .fontWeight(FontWeight.Medium)
          .fontColor('#2E79F4')
      }
      .width('100%')
    }
    .width('100%')
    .padding(12)
    .backgroundColor('#F7FAFE')
    .borderRadius(18)
    .onClick(() => {
      this.onOpenRecentCourse(item.courseCode)
    })
  }

  private getSafeProgress(progress: number): number {
    if (progress < 0) {
      return 0
    }
    if (progress > 100) {
      return 100
    }
    return progress
  }
}
