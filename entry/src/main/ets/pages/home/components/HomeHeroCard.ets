import { APP_RADIUS, APP_SHADOW } from '../../../config/AppStyle'

function getHeroGreetingByHour(hour: number): string {
  if (hour >= 5 && hour < 11) return '\u65e9\u5b89\uff0c\u6765\u7ec3\u4e00\u4f1a\u513f'
  if (hour >= 11 && hour < 14) return '\u4e2d\u5348\u597d\uff0c\u4fdd\u6301\u8282\u594f'
  if (hour >= 14 && hour < 18) return '\u4e0b\u5348\u597d\uff0c\u7ee7\u7eed\u63a8\u8fdb'
  if (hour >= 18 && hour < 23) return '\u665a\u4e0a\u597d\uff0c\u5b8c\u6210\u4eca\u65e5\u76ee\u6807'
  return '\u591c\u6df1\u4e86\uff0c\u4e5f\u53ef\u4ee5\u8f7b\u7ec3\u4e00\u4e2a'
}

function getHeroActionLabelByHour(hour: number): string {
  if (hour >= 5 && hour < 11) return '\u5f00\u59cb\u6668\u7ec3'
  if (hour >= 18 && hour < 23) return '\u5f00\u59cb\u665a\u7ec3'
  return '\u5f00\u59cb\u8bad\u7ec3'
}

@Component
export struct HomeHeroCard {
  @Prop heroTitle: string = ''
  @Prop heroSubtitle: string = ''
  @Prop heroMediaUrl: string = ''
  onOpenHeroTraining: () => void = () => {}

  build() {
    Column({ space: 0 }) {
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
            .linearGradient({ angle: 135, colors: [['#A9D4FF', 0], ['#7DBDFF', 0.45], ['#5D9DF7', 1]] })
        }

        Row()
          .width('100%')
          .height('100%')
          .linearGradient({ angle: 0, colors: [['rgba(255,255,255,0.20)', 0], ['rgba(255,255,255,0.10)', 0.42], ['rgba(255,255,255,0.00)', 1]] })

        Row() {
          Column({ space: 30 }) {
            Column({ space: 2 }) {
              Text(this.heroSubtitle.length > 0 ? this.heroSubtitle : getHeroGreetingByHour(new Date().getHours()))
                .fontSize(22)
                .fontWeight(FontWeight.Bold)
                .fontColor(Color.White)
                .maxLines(1)
                .opacity(0.9)

              Text(this.heroTitle)
                .fontSize(26)
                .fontWeight(FontWeight.Bold)
                .fontColor(Color.White)
                .maxLines(1)
            }
            .alignItems(HorizontalAlign.Start)

            Button() {
              Row({ space: 4 }) {
                Text(getHeroActionLabelByHour(new Date().getHours()))
                  .fontSize(14)
                  .fontWeight(FontWeight.Medium)
                  .fontColor('#2E79F4')
                SymbolGlyph($r('sys.symbol.chevron_forward'))
                  .fontSize(13)
                  .fontColor(['#2E79F4'])
                  .opacity(0.88)
              }
            }
            .type(ButtonType.Capsule)
            .backgroundColor('rgba(255,255,255,0.92)')
            .height(36)
            .padding({ left: 16, right: 16 })
            .margin({ top: 6 })
            .onClick(() => { this.onOpenHeroTraining() })
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
      .borderRadius(APP_RADIUS.hero)
      .clip(true)
      .margin({ top: 12, bottom: 18 })
      .shadow(APP_SHADOW.hero)
    }
    .width('100%')
  }
}
