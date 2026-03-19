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

export class TrendPointItem {
  label: string
  score: number

  constructor(label: string, score: number) {
    this.label = label
    this.score = score
  }
}

@Component
export struct RecordPage {
  @Prop overallScore: number = 0
  @Prop summaryTitle: string = '学习表现待生成'
  @Prop summaryAdvice: string = '进入记录页后将根据后端统计结果展示学习建议。'
  @Prop selectedFilter: string = '周'
  @Prop trendPoints: TrendPointItem[] = []
  @Prop recentCourses: RecentCourseItem[] = []
  @Prop loading: boolean = false
  @Prop tip: string = ''
  onFilterChange: (filter: string) => void = () => {}
  onOpenTraining: () => void = () => {}
  onOpenRecentCourse: (courseCode: string) => void = (_courseCode: string) => {}

  private readonly filters: string[] = ['日', '周', '总览']

  build() {
    Column({ space: 18 }) {
      if (this.loading) {
        Row({ space: 8 }) {
          LoadingProgress()
            .width(18)
            .height(18)
            .color('#2E79F4')

          Text('正在加载学习记录...')
            .fontSize(13)
            .fontColor('#6E8099')
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
      }

      if (this.tip.length > 0) {
        Text(this.tip)
          .width('100%')
          .fontSize(13)
          .fontColor('#E5484D')
          .textAlign(TextAlign.Center)
      }

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

          Text(this.summaryTitle)
            .fontSize(13)
            .fontColor('#E5F1FF')
            .maxLines(2)
        }
        .alignItems(HorizontalAlign.Start)

        Blank()

        Column({ space: 2 }) {
          Text('今日手感')
            .fontSize(12)
            .fontColor('#E5F1FF')

          Text(`${Math.round(this.getSafeScore(this.overallScore))}分`)
            .fontSize(34)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFFFFF')
        }
        .alignItems(HorizontalAlign.End)
      }
      .width('100%')

      Text(this.summaryAdvice)
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

        if (this.getNonZeroTrendPoints().length < this.trendPoints.length) {
          Text('已忽略无训练数据')
            .fontSize(11)
            .fontColor('#8EA2BD')
            .margin({ right: 10 })
        }

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

      if (this.trendPoints.length === 0) {
        Text('暂无趋势数据')
          .width('100%')
          .fontSize(13)
          .fontColor('#8AA0BC')
          .textAlign(TextAlign.Center)
          .padding({ top: 16, bottom: 12 })
      } else {
        Row({ space: 10 }) {
          ForEach(this.trendPoints, (point: TrendPointItem) => {
            Column({ space: 8 }) {
              Text(`${Math.round(this.getSafeScore(point.score))}`)
                .fontSize(10)
                .fontWeight(FontWeight.Medium)
                .fontColor(point.score > 0 ? '#4E6D97' : '#A7B7CB')
                .textAlign(TextAlign.Center)
                .width('100%')

              Column() {
                Blank()
                Column() {
                }
                .width('100%')
                .height(`${this.getSegmentedBarHeight(point.score)}%`)
                .linearGradient({
                  angle: 180,
                  colors: [['#68D5F3', 0], ['#3E7CF6', 1]]
                })
                .borderRadius(10)
              }
              .justifyContent(FlexAlign.End)
              .width('100%')
              .height(120)

              Text(this.getDisplayLabel(point.label))
                .fontSize(10)
                .fontColor('#7A8CA7')
                .maxLines(1)
                .textAlign(TextAlign.Center)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
            }
            .layoutWeight(1)
          }, (point: TrendPointItem) => `${point.label}_${point.score}`)
        }
        .width('100%')
        .height(146)
      }
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
            .width(`${this.getSafeScore(item.progressPercent)}%`)
            .height(8)
            .linearGradient({
              angle: 90,
              colors: [['#74B8FF', 0], ['#2E79F4', 1]]
            })
            .borderRadius(8)
        }
        .layoutWeight(1)
        .height(8)

        Text(`${Math.round(this.getSafeScore(item.progressPercent))}%`)
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

  private getSafeScore(score: number): number {
    if (score < 0) {
      return 0
    }
    if (score > 100) {
      return 100
    }
    return score
  }

  private getNonZeroTrendPoints(): TrendPointItem[] {
    const next: TrendPointItem[] = []
    for (let i = 0; i < this.trendPoints.length; i += 1) {
      if (this.trendPoints[i].score > 0) {
        next.push(this.trendPoints[i])
      }
    }
    return next
  }

  private getSegmentedBarHeight(score: number): number {
    if (score <= 0) {
      return 14
    }

    const points = this.getNonZeroTrendPoints()
    if (points.length === 0) {
      return 14
    }

    let minScore = points[0].score
    let maxScore = points[0].score
    for (let i = 1; i < points.length; i += 1) {
      if (points[i].score < minScore) {
        minScore = points[i].score
      }
      if (points[i].score > maxScore) {
        maxScore = points[i].score
      }
    }

    if (maxScore === minScore) {
      return 72
    }

    const normalized = (score - minScore) / (maxScore - minScore)
    const scoreRange = maxScore - minScore
    if (scoreRange <= 5) {
      return 58 + normalized * 14
    }
    if (scoreRange <= 10) {
      return 54 + normalized * 20
    }
    if (scoreRange <= 20) {
      return 48 + normalized * 30
    }
    return 42 + normalized * 44
  }

  private getDisplayLabel(label: string): string {
    const normalized = label.trim()
    if (this.selectedFilter === '日') {
      return this.mapWeekdayLabel(normalized)
    }
    if (normalized.indexOf('第') === 0 && normalized.indexOf('周') > 0) {
      const weekText = normalized.substring(1, normalized.indexOf('周'))
      return `W${weekText}`
    }
    if (normalized.length > 4) {
      return `${normalized.substring(0, 4)}...`
    }
    return normalized
  }

  private mapWeekdayLabel(label: string): string {
    const match = label.match(/(\d{1,2})-(\d{1,2})/)
    if (!match) {
      return label.length > 3 ? `${label.substring(0, 3)}...` : label
    }

    const now = new Date()
    const year = now.getFullYear()
    const month = Number(match[1]) - 1
    const day = Number(match[2])
    const date = new Date(year, month, day)
    const weekLabels: string[] = ['周日', '周一', '周二', '周三', '周四', '周五', '周六']
    return weekLabels[date.getDay()]
  }
}
