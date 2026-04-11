/**
 * 个人页头部概览卡片。
 */

import { APP_COLORS } from '../../../config/AppStyle'

@Component
export struct ProfileOverviewCard {
  private readonly coverRadius: number = 12
  @Prop profileCoverUrl: string = ''
  @Prop avatarUrl: string = ''
  @Prop profileNickname: string = ''
  @Prop profileSignature: string = ''
  @Prop companionDays: number = 0
  @Prop trainedQuestionCount: number = 0

  build() {
    Stack({ alignContent: Alignment.BottomStart }) {
      Image(this.profileCoverUrl.length > 0 ? this.profileCoverUrl : $r('app.media.startIcon'))
        .width('100%')
        .height(196)
        .objectFit(ImageFit.Cover)
        .borderRadius(this.coverRadius)

      Column()
        .width('100%')
        .height(112)
        .linearGradient({ angle: 180, colors: [['#00000000', 0], ['#33000000', 1]] })
        .alignSelf(ItemAlign.End)
        .borderRadius(this.coverRadius)

      Row({ space: 12 }) {
        Image(this.avatarUrl.length > 0 ? this.avatarUrl : $r('app.media.startIcon'))
          .width(56)
          .height(56)
          .objectFit(ImageFit.Cover)
          .borderRadius(28)

        Column({ space: 4 }) {
          Text(this.profileNickname)
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFFFFF')

          Text(this.profileSignature)
            .fontSize(13)
            .fontColor('#E8F1FF')
            .maxLines(1)

          Text(`已陪伴 ${this.companionDays} 天 · 练习 ${this.trainedQuestionCount} 题`)
            .fontSize(12)
            .fontColor('#DCEBFF')
            .maxLines(1)
        }
        .alignItems(HorizontalAlign.Start)
      }
      .padding({ left: 16, right: 16, bottom: 16 })
      .width('100%')
    }
    .width('100%')
    .height(196)
    .margin({ left: 0, right: 0, top: -56 })
    .backgroundColor(APP_COLORS.backgroundStart)
    .borderRadius(this.coverRadius)
    .clip(true)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])
    .shadow({ radius: 20, color: '#2A15304B', offsetX: 0, offsetY: 10 })
  }
}
