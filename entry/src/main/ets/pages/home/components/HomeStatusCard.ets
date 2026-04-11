/**
 * 首页状态卡片。
 */

import { APP_COLORS, APP_RADIUS, APP_SHADOW } from '../../../config/AppStyle'
@Component
export struct HomeStatusCard {
  @Prop todayStatusPercent: number = 0
  @Prop todayStatusTitle: string = ''
  @Prop todayStatusDetail: string = ''

  build() {
    Column({ space: 10 }) {
      Text('今日状态')
        .fontSize(14)
        .fontColor(APP_COLORS.secondaryText)

      Column({ space: 6 }) {
        Text(`${this.todayStatusPercent}%`)
          .fontSize(32)
          .fontWeight(FontWeight.Bold)
          .fontColor(APP_COLORS.primary)

        Text(this.todayStatusTitle)
          .fontSize(12)
          .fontColor(APP_COLORS.secondaryText)
          .maxLines(1)

        Text(this.todayStatusDetail)
          .fontSize(12)
          .fontColor(APP_COLORS.mutedText)
          .maxLines(1)
      }
    }
    .width('100%')
    .padding(20)
    .backgroundColor(APP_COLORS.surface)
    .borderRadius(APP_RADIUS.xxl)
    .shadow(APP_SHADOW.soft)
  }
}
