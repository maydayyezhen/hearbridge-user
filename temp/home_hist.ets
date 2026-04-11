class HomeworkItem {
  title: string
  minutes: string
  accent: string
  coverUrl: string

  constructor(title: string, minutes: string, accent: string, coverUrl: string) {
    this.title = title
    this.minutes = minutes
    this.accent = accent
    this.coverUrl = coverUrl
  }
}

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
  @State currentDateText: string = ''
  @State currentTimeText: string = ''
  @State weatherSummary: WeatherSummary = new WeatherSummary('实时天气', '多云 24°C')
  onOpenGestureCourses: () => void = () => {}
  onOpenSpeechCourses: () => void = () => {}
  private clockTimer: number = -1

  private readonly homeworkItems: HomeworkItem[] = [
    new HomeworkItem(
      '日常问候入门',
      '5 分钟',
      '#3A86FF',
      'http://10.133.132.87:9001/hearbridge-bucket/20260316/3ad909fc0af94c58a8f2be4ca2fe4cbcChatGPT%20Image%202026%E5%B9%B43%E6%9C%8816%E6%97%A5%2001_25_49.png'
    ),
    new HomeworkItem(
      '清晰口型训练',
      '8 分钟',
      '#36CFC9',
      'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=600&q=80'
    )
  ]

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

  build() {
    Column({ space: 18 }) {
      this.buildHeroCard()
      this.buildQuickActions()
      this.buildHomeworkSection()
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 6, bottom: 118 })
  }

  @Builder
  private buildHeroCard() {
    Column({ space: 14 }) {
      Row() {
        Column({ space: 6 }) {
          Text('你好，准备开始训练')
            .fontSize(28)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1F2A44')

          Text(`${this.currentDateText} · ${this.currentTimeText}`)
            .fontSize(14)
            .fontColor('#5E6D85')
        }
        .alignItems(HorizontalAlign.Start)

        Blank()

        Image(this.avatarUrl)
          .width(46)
          .height(46)
          .objectFit(ImageFit.Cover)
          .borderRadius(23)
          .border({ width: 2, color: '#FFFFFFAA' })
      }
      .width('100%')

      Row({ space: 10 }) {
        this.buildWeatherInfoPill(this.weatherSummary.label, this.weatherSummary.detail)
        this.buildHeroInfoPill('今日目标', `${Math.min(5, Math.max(1, Math.ceil(this.dailyProgress / 20)))}/5`)
      }
      .width('100%')

      Column({ space: 8 }) {
        Row() {
          Text('今日进度')
            .fontSize(12)
            .fontColor('#5E6D85')

          Blank()

          Text(`${this.dailyProgress}%`)
            .fontSize(12)
            .fontWeight(FontWeight.Medium)
            .fontColor('#2E79F4')
        }
        .width('100%')

        Stack({ alignContent: Alignment.Start }) {
          Row() {
          }
          .width('100%')
          .height(10)
          .backgroundColor('#FFFFFF99')
          .borderRadius(8)

          Row() {
          }
          .width(`${this.dailyProgress}%`)
          .height(10)
          .linearGradient({
            angle: 90,
            colors: [['#67D4F3', 0], ['#2E79F4', 1]]
          })
          .borderRadius(8)
        }
        .width('100%')
        .height(10)
      }

      Row({ space: 12 }) {
        this.buildActionTile($r('sys.symbol.paperplane'), '手势训练', '#3478F6', '#2364E8', () => {
          this.onOpenGestureCourses()
        })
        this.buildActionTile($r('sys.symbol.ellipsis_message'), '口语训练', '#3EC8F6', '#31A8F0', () => {
          this.onOpenSpeechCourses()
        })
      }
      .width('100%')
    }
    .width('100%')
    .padding({ left: 20, right: 20, top: 22, bottom: 20 })
    .backgroundImage($r('app.media.background'))
    .backgroundImageSize(ImageSize.Cover)
    .backgroundBlurStyle(BlurStyle.COMPONENT_ULTRA_THICK)
    .borderRadius(30)
  }

  @Builder
  private buildHeroInfoPill(label: string, value: string) {
    Column({ space: 4 }) {
      Text(label)
        .fontSize(11)
        .fontColor('#6E7F98')

      Text(value)
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .fontColor('#1F2A44')
    }
    .alignItems(HorizontalAlign.Start)
    .layoutWeight(1)
    .padding({ left: 14, right: 14, top: 10, bottom: 10 })
    .backgroundColor('#F8FBFFCC')
    .borderRadius(16)
    .border({ width: 1, color: '#DCE8F8' })
  }

  @Builder
  private buildWeatherInfoPill(label: string, value: string) {
    Row({ space: 10 }) {
      Stack({ alignContent: Alignment.Center }) {
        Row() {
        }
        .width(34)
        .height(34)
        .backgroundColor('#FFFFFF')
        .borderRadius(17)
        .border({ width: 1, color: '#DCE8F8' })

        SymbolGlyph($r('sys.symbol.cloud'))
          .fontSize(18)
          .fontColor(['#5D8DE8'])
      }
      .width(34)
      .height(34)

      Column({ space: 4 }) {
        Text(label)
          .fontSize(11)
          .fontColor('#6E7F98')

        Text(value)
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor('#1F2A44')
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
    }
    .alignItems(VerticalAlign.Center)
    .layoutWeight(1)
    .padding({ left: 14, right: 14, top: 10, bottom: 10 })
    .backgroundColor('#F8FBFFCC')
    .borderRadius(16)
    .border({ width: 1, color: '#DCE8F8' })
  }

  @Builder
  private buildQuickActions() {
    Row({ space: 12 }) {
      this.buildInfoCard('今日训练进度', `${this.dailyProgress}%`, '继续保持，节奏很稳')
      this.buildInfoCard('本周打卡', '7 天', '已经进入稳定训练期')
    }
    .width('100%')
  }

  @Builder
  private buildHomeworkSection() {
    Column({ space: 14 }) {
      Row() {
        Column({ space: 4 }) {
          Text('候练课程')
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .fontColor('#1F2A44')

          Text('根据今日状态推荐')
            .fontSize(12)
            .fontColor('#7B8BA5')
        }
        .alignItems(HorizontalAlign.Start)

        Blank()

        Text('...')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#7B8BA5')
      }
      .width('100%')

      ForEach(this.homeworkItems, (item: HomeworkItem) => {
        this.buildHomeworkCard(item)
      }, (item: HomeworkItem) => item.title)
    }
    .width('100%')
    .padding(18)
    .backgroundColor('#FFFFFF')
    .borderRadius(22)
    .shadow({ radius: 20, color: '#15304B12', offsetX: 0, offsetY: 10 })
  }

  @Builder
  private buildActionTile(icon: Resource, label: string, startColor: string, endColor: string, onClickAction: () => void) {
    Column({ space: 10 }) {
      Stack({ alignContent: Alignment.Center }) {
        Row() {
        }
        .width(36)
        .height(36)
        .backgroundColor('#FFFFFFE6')
        .borderRadius(12)
        .border({ width: 1, color: '#FFFFFF66' })

        SymbolGlyph(icon)
          .fontSize(20)
          .fontColor(['#2E79F4'])
      }
      .width(36)
      .height(36)

      Text(label)
        .fontSize(15)
        .fontWeight(FontWeight.Medium)
        .fontColor('#FFFFFF')
    }
    .justifyContent(FlexAlign.Center)
    .width('50%')
    .height(122)
    .linearGradient({
      angle: 135,
      colors: [[startColor, 0], [endColor, 1]]
    })
    .borderRadius(24)
    .shadow({ radius: 16, color: `${startColor}33`, offsetX: 0, offsetY: 8 })
    .onClick(() => {
      onClickAction()
    })
  }

  @Builder
  private buildInfoCard(title: string, value: string, subtitle: string) {
    Column({ space: 8 }) {
      Text(title)
        .fontSize(13)
        .fontColor('#7B8BA5')

      Text(value)
        .fontSize(26)
        .fontWeight(FontWeight.Bold)
        .fontColor('#2563EB')

      Text(subtitle)
        .fontSize(12)
        .fontColor('#5E6D85')
        .maxLines(2)
    }
    .alignItems(HorizontalAlign.Start)
    .layoutWeight(1)
    .padding(18)
    .backgroundColor('#FFFFFF')
    .borderRadius(24)
    .shadow({ radius: 18, color: '#15304B10', offsetX: 0, offsetY: 8 })
  }

  @Builder
  private buildHomeworkCard(item: HomeworkItem) {
    Row({ space: 14 }) {
      Stack({ alignContent: Alignment.BottomEnd }) {
        Image(item.coverUrl)
          .width(88)
          .height(50)
          .objectFit(ImageFit.Cover)
          .borderRadius(12)

        Column() {
        }
        .width(88)
        .height(50)
        .linearGradient({
          angle: 180,
          colors: [['#00000008', 0], ['#00000024', 1]]
        })
        .borderRadius(12)

        Stack({ alignContent: Alignment.Center }) {
          Row() {
          }
          .width(28)
          .height(28)
          .backgroundColor('#FFFFFFE8')
          .borderRadius(14)
          .border({ width: 1, color: '#DCE8F8' })

          SymbolGlyph($r('sys.symbol.square_grid_2x2'))
            .fontSize(14)
            .fontColor(['#3A86FF'])
        }
        .width(28)
        .height(28)
        .margin({ right: 8, bottom: 8 })
      }

      Column({ space: 10 }) {
        Text(item.title)
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor('#1F2A44')

        Row({ space: 8 }) {
          this.buildMetaTag('推荐')
          this.buildMetaTag(item.minutes)
        }
      }
      .alignItems(HorizontalAlign.Start)

      Blank()
    }
    .width('100%')
    .padding(14)
    .backgroundColor('#F7FAFE')
    .borderRadius(16)
  }

  @Builder
  private buildMetaTag(label: string) {
    Text(label)
      .fontSize(11)
      .fontColor('#63738C')
      .padding({ left: 10, right: 10, top: 6, bottom: 6 })
      .backgroundColor('#FFFFFF')
      .borderRadius(12)
  }
}
