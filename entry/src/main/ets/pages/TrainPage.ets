@Component
export struct TrainPage {
  @Prop selectedPhrase: string = 'Hello'
  onSelectPhrase: (phrase: string) => void = () => {}
  onCompleteTraining: () => void = () => {}

  private readonly phrases: string[] = ['Hello', 'Good morning', 'Thank you', 'See you']

  build() {
    Column({ space: 18 }) {
      Text('Training')
        .fontSize(28)
        .fontWeight(FontWeight.Bold)
        .fontColor('#203040')

      Column({ space: 12 }) {
        Text('Select phrase')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#203040')

        Row({ space: 10 }) {
          ForEach(this.phrases, (phrase: string) => {
            this.buildPhrase(phrase)
          }, (phrase: string) => phrase)
        }
        .width('100%')
      }
      .width('100%')
      .padding(18)
      .backgroundColor('#FFFFFF')
      .borderRadius(24)

      Column({ space: 10 }) {
        Text('Current phrase')
          .fontSize(14)
          .fontColor('#6C7B8A')
        Text(this.selectedPhrase)
          .fontSize(26)
          .fontWeight(FontWeight.Bold)
          .fontColor('#15304B')
        Text('Tap the action button after you finish one round.')
          .fontSize(12)
          .fontColor('#6C7B8A')
      }
      .width('100%')
      .padding(18)
      .backgroundColor('#F2F6FA')
      .borderRadius(24)

      Button('Complete one round')
        .width('100%')
        .height(48)
        .backgroundColor('#246BFD')
        .fontColor('#FFFFFF')
        .borderRadius(16)
        .onClick(() => {
          this.onCompleteTraining()
        })
    }
    .width('100%')
    .padding({ left: 20, right: 20, top: 10, bottom: 110 })
  }

  @Builder
  private buildPhrase(phrase: string) {
    Text(phrase)
      .layoutWeight(1)
      .textAlign(TextAlign.Center)
      .fontSize(13)
      .fontColor(this.selectedPhrase === phrase ? '#FFFFFF' : '#203040')
      .padding({ top: 12, bottom: 12 })
      .backgroundColor(this.selectedPhrase === phrase ? '#246BFD' : '#EAF2FA')
      .borderRadius(16)
      .onClick(() => {
        this.onSelectPhrase(phrase)
      })
  }
}
