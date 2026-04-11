/**
 * 首页推荐课程卡片。
 */

import { APP_RADIUS, APP_SHADOW } from '../../../config/AppStyle'
@Component
export struct HomeRecommendCard {
  @Prop recommendCourseName: string = ''
  @Prop recommendText: string = ''
  @Prop recommendDurationText: string = ''
  @Prop recommendCoverUrl: string = ''
  onOpenTodayRecommend: () => void = () => {}

  build() {
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
            colors: [['#DCEBFF', 0], ['#C4DEFF', 0.55], ['#B2D3FF', 1]]
          })
      }

      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('rgba(10,18,32,0.20)')

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
    .borderRadius(APP_RADIUS.xxl)
    .clip(true)
    .shadow(APP_SHADOW.soft)
    .onClick(() => {
      this.onOpenTodayRecommend()
    })
  }
}
