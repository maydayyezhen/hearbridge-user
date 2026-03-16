@Component
export struct HomePage {
  @Prop dailyProgress: number = 0
  onOpenTraining: () => void = () => {}

  build() {
    Column({ space: 18 }) {
      Text('Today')
        .fontSize(28)
        .fontWeight(FontWeight.Bold)
        .fontColor('#203040')

      Column({ space: 14 }) {
        Text('Daily voice practice')
          .fontSize(20)
          .fontWeight(FontWeight.Medium)
          .fontColor('#203040')

        Text(`Progress ${this.dailyProgress}%`)
          .fontSize(13)
          .fontColor('#6C7B8A')

        Column() {
          Row() {
          }
          .width(`${this.dailyProgress}%`)
          .height(10)
          .backgroundColor('#246BFD')
          .borderRadius(6)
        }
        .width('100%')
        .height(10)
        .backgroundColor('#DDE8F4')
        .borderRadius(6)

        Button('Continue training')
          .width('100%')
          .height(46)
          .backgroundColor('#15304B')
          .fontColor('#FFFFFF')
          .borderRadius(16)
          .onClick(() => {
            this.onOpenTraining()
          })
      }
      .width('100%')
      .padding(18)
      .backgroundColor('#FFFFFF')
      .borderRadius(24)

      this.buildCard('Recommended', 'Greeting basics', '5 min daily warm-up')
      this.buildCard('Recommended', 'Lip reading drill', 'Short focused session')
      this.buildCard('Recommended', 'Expression practice', 'Repeat after the avatar')
    }
    .width('100%')
    .padding({ left: 20, right: 20, top: 10, bottom: 110 })
  }

  @Builder
  private buildCard(tag: string, title: string, subtitle: string) {
    Column({ space: 10 }) {
      Text(tag)
        .fontSize(12)
        .fontColor('#246BFD')
      Text(title)
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .fontColor('#203040')
      Text(subtitle)
        .fontSize(12)
        .fontColor('#6C7B8A')
    }
    .width('100%')
    .padding(18)
    .backgroundColor('#FFFFFF')
    .borderRadius(20)
  }
}
