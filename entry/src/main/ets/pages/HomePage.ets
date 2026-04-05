class WeatherSummary {
  label: string
  detail: string

  constructor(label: string, detail: string) {
    this.label = label
    this.detail = detail
  }
}

@Component
export struct HomePage {
  @Prop dailyProgress: number = 0
  @Prop avatarUrl: string = ''
  @Prop heroTitle: string = '你好，准备开始训练'
  @Prop heroSubtitle: string = '面向听障训练的口语与手语学习平台'
  @Prop heroMediaUrl: string = ''
  @Prop todayStatusPercent: number = 40
  @Prop todayStatusTitle: string = '今天状态已更新'
  @Prop todayStatusDetail: string = '继续保持当前训练节奏。'
  @Prop recommendCourseName: string = '日常问候入门'
  @Prop recommendText: string = '用最简单的表达开始今天的练习'
  @Prop recommendDurationText: string = '5 分钟可完成'
  @Prop recommendCoverUrl: string = ''
  @State currentDateText: string = ''
  @State currentTimeText: string = ''
  @State weatherSummary: WeatherSummary = new WeatherSummary('实时天气', '多云 24°C')
  onOpenGestureCourses: () => void = () => {}
  onOpenSpeechCourses: () => void = () => {}
  onOpenHeroTraining: () => void = () => {}
  onOpenTodayRecommend: () => void = () => {}
  private clockTimer: number = -1

  aboutToAppear() {
    this.updateLiveSummary()
    this.clearClockTimer()
    this.clockTimer = setInterval(() => {
      this.updateLiveSummary()
    }, 1000)
  }

  aboutToDisappear() {
    this.clearClockTimer()
  }

  private clearClockTimer() {
    if (this.clockTimer !== -1) {
      clearInterval(this.clockTimer)
      this.clockTimer = -1
    }
  }

  private updateLiveSummary() {
    const now: Date = new Date()
    const weekDays: string[] = ['周日', '周一', '周二', '周三', '周四', '周五', '周六']
    const month: string = this.padNumber(now.getMonth() + 1)
    const day: string = this.padNumber(now.getDate())
    const hours: number = now.getHours()
    const minutes: string = this.padNumber(now.getMinutes())
    const seconds: string = this.padNumber(now.getSeconds())

    this.currentDateText = `${month}月${day}日 ${weekDays[now.getDay()]}`
    this.currentTimeText = `${this.padNumber(hours)}:${minutes}:${seconds}`
    this.weatherSummary = this.getWeatherSummaryByHour(hours)
  }

  private padNumber(value: number): string {
    return value < 10 ? `0${value}` : `${value}`
  }

  private getWeatherSummaryByHour(hour: number): WeatherSummary {
    if (hour >= 6 && hour < 11) {
      return new WeatherSummary('晨间体感', '晴间多云 22°C')
    }
    if (hour >= 11 && hour < 17) {
      return new WeatherSummary('午后天气', '明亮微风 26°C')
    }
    if (hour >= 17 && hour < 21) {
      return new WeatherSummary('傍晚天气', '云层舒展 23°C')
    }
    return new WeatherSummary('夜间天气', '微凉安静 20°C')
  }

  private getHeroGreetingByHour(hour: number): string {
    if (hour >= 5 && hour < 11) {
      return '早安，来练一会儿'
    }
    if (hour >= 11 && hour < 14) {
      return '中午好，保持节奏'
    }
    if (hour >= 14 && hour < 18) {
      return '下午好，继续推进'
    }
    if (hour >= 18 && hour < 23) {
      return '晚上好，完成今日目标'
    }
    return '夜深了，也可以轻练一下'
  }

  private getHeroActionLabelByHour(hour: number): string {
    if (hour >= 5 && hour < 11) {
      return '开始晨练'
    }
    if (hour >= 18 && hour < 23) {
      return '开始晚练'
    }
    return '开始训练'
  }

  build() {
    Column({ space: 18 }) {
      this.buildHeroCard()
      this.buildTodayStatusCard()
      this.buildTodayCourseCard()
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 6, bottom: 118 })
  }

  @Builder
  private buildHeroCard() {
    Stack({ alignContent: Alignment.Center }) {
      if (this.heroMediaUrl.length > 0) {
        Image(this.heroMediaUrl)
          .width('100%')
          .height('100%')
          .objectFit(ImageFit.Cover)
      } else {
        Column()
          .width('100%')
          .height('100%')
          .linearGradient({
            angle: 135,
            colors: [
              ['#A9D4FF', 0],
              ['#7DBDFF', 0.45],
              ['#5D9DF7', 1]
            ]
          })
      }

      Row()
        .width('100%')
        .height('100%')
        .linearGradient({
          angle: 0,
          colors: [
            ['rgba(255,255,255,0.20)', 0],
            ['rgba(255,255,255,0.10)', 0.42],
            ['rgba(255,255,255,0.00)', 1]
          ]
        })

      Row() {
        Column({ space: 30 }) {
          Column({ space: 2 }) {
            Text(this.getHeroGreetingByHour(new Date().getHours()))
              .fontSize(22)
              .fontWeight(FontWeight.Bold)
              .fontColor(Color.White)
              .maxLines(1)
              .opacity(0.9)

            Text(this.heroTitle.length > 0 ? this.heroTitle : '来练一会儿吧')
              .fontSize(26)
              .fontWeight(FontWeight.Bold)
              .fontColor(Color.White)
              .maxLines(1)
              .opacity(1.0)
          }
          .alignItems(HorizontalAlign.Start)

          Button() {
            Row({ space: 6 }) {
              Text(this.getHeroActionLabelByHour(new Date().getHours()))
                .fontSize(14)
                .fontWeight(FontWeight.Medium)
                .fontColor('#2E79F4')
              Text('->')
                .fontSize(14)
                .fontColor('#2E79F4')
            }
          }
          .type(ButtonType.Capsule)
          .backgroundColor('rgba(255,255,255,0.92)')
          .height(36)
          .padding({ left: 16, right: 16 })
          .margin({ top: 6 })
          .onClick(() => {
            this.onOpenHeroTraining()
          })
        }
        .alignItems(HorizontalAlign.Start)
        .justifyContent(FlexAlign.Center)
        .width('58%')
        .height('100%')
        .padding({ left: 20, right: 12, top: 20, bottom: 20 })

        Blank()
      }
      .width('100%')
      .height('100%')
    }
    .width('100%')
    .height(200)
    .borderRadius(30)
    .clip(true)
    .margin({ top: 12, bottom: 18 })
    .shadow({
      radius: 16,
      color: 'rgba(46,121,244,0.10)',
      offsetX: 0,
      offsetY: 6
    })
  }

  @Builder
  private buildTodayStatusCard() {
    Column({ space: 10 }) {
      Text('今日状态')
        .fontSize(14)
        .fontColor('#8A93A6')

      Column({ space: 6 }) {
        Text(`${this.todayStatusPercent}%`)
          .fontSize(32)
          .fontWeight(FontWeight.Bold)
          .fontColor('#2E79F4')

        Text(this.todayStatusTitle)
          .fontSize(12)
          .fontColor('#8A93A6')
          .maxLines(1)

        Text(this.todayStatusDetail)
          .fontSize(12)
          .fontColor('#A0A8B8')
          .maxLines(1)
      }
    }
    .width('100%')
    .padding(20)
    .backgroundColor('#FFFFFF')
    .borderRadius(24)
    .shadow({
      radius: 12,
      color: 'rgba(0,0,0,0.04)',
      offsetX: 0,
      offsetY: 4
    })
  }

  @Builder
  private buildTodayCourseCard() {
    Stack({ alignContent: Alignment.Center }) {
      if (this.recommendCoverUrl.length > 0) {
        Image(this.recommendCoverUrl)
          .width('100%')
          .height('100%')
          .objectFit(ImageFit.Cover)
      } else {
        Column()
          .width('100%')
          .height('100%')
          .linearGradient({
            angle: 135,
            colors: [
              ['#DCEBFF', 0],
              ['#C4DEFF', 0.55],
              ['#B2D3FF', 1]
            ]
          })
      }

      // 第一层：整体压暗
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('rgba(10,18,32,0.20)')

      // 第二层：底部再加深，保证文字可读
      Column()
        .width('100%')
        .height('100%')
        .linearGradient({
          angle: 180,
          colors: [
            ['rgba(10,18,32,0.08)', 0],
            ['rgba(10,18,32,0.26)', 0.5],
            ['rgba(10,18,32,0.58)', 1]
          ]
        })

      Column({ space: 12 }) {
        Text('今日推荐')
          .fontSize(14)
          .fontColor('rgba(255,255,255,0.92)')

        Column({ space: 6 }) {
          Text(this.recommendCourseName)
            .fontSize(20)
            .fontWeight(FontWeight.Medium)
            .fontColor('#FFFFFF')
            .maxLines(1)

          Text(this.recommendText)
            .fontSize(12)
            .fontColor('rgba(255,255,255,0.88)')
            .maxLines(2)

          Text(this.recommendDurationText)
            .fontSize(12)
            .fontColor('#D6E7FF')
            .maxLines(1)
        }
      }
      .width('100%')
      .padding(20)
      .alignItems(HorizontalAlign.Center)
    }
    .width('100%')
    .height(150)
    .borderRadius(24)
    .clip(true)
    .shadow({
      radius: 12,
      color: 'rgba(0,0,0,0.04)',
      offsetX: 0,
      offsetY: 4
    })
    .onClick(() => {
      this.onOpenTodayRecommend()
    })
  }
}
