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

@Component
export struct HomePage {
  @Prop dailyProgress: number = 0
  @Prop avatarUrl: string = ''
  onOpenGestureCourses: () => void = () => {}
  onOpenSpeechCourses: () => void = () => {}

  private readonly homeworkItems: HomeworkItem[] = [
    new HomeworkItem('日常问候入门', '5 分钟', '#3A86FF', 'http://10.133.132.87:9001/hearbridge-bucket/20260316/3ad909fc0af94c58a8f2be4ca2fe4cbcChatGPT%20Image%202026%E5%B9%B43%E6%9C%8816%E6%97%A5%2001_25_49.png'),
    new HomeworkItem('清晰口型训练', '8 分钟', '#36CFC9', 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=600&q=80')
  ]

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
          Text('你好，筱暄')
            .fontSize(28)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1F2A44')

          Text(`今日训练目标 ${Math.min(5, Math.max(1, Math.ceil(this.dailyProgress / 20)))}/5`)
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
  private buildQuickActions() {
    Row({ space: 12 }) {
      this.buildInfoCard('今日训练进度', `${this.dailyProgress}%`, '继续保持，节奏很好')
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
          .fontColor('#FFAC4A')
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
        .borderRadius(18)

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
