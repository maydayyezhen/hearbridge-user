@Component
export struct RecordPage {
  @Prop dailyProgress: number = 0
  @Prop selectedFilter: string = 'Week'
  onFilterChange: (filter: string) => void = () => {}
  onOpenTraining: () => void = () => {}

  private readonly filters: string[] = ['Week', 'Month', 'All']

  build() {
    Column({ space: 18 }) {
      Text('Records')
        .fontSize(28)
        .fontWeight(FontWeight.Bold)
        .fontColor('#203040')

      Row({ space: 10 }) {
        ForEach(this.filters, (filter: string) => {
          Text(filter)
            .fontSize(13)
            .fontColor(this.selectedFilter === filter ? '#FFFFFF' : '#4E6072')
            .padding({ left: 14, right: 14, top: 10, bottom: 10 })
            .backgroundColor(this.selectedFilter === filter ? '#246BFD' : '#EAF2FA')
            .borderRadius(16)
            .onClick(() => {
              this.onFilterChange(filter)
            })
        }, (filter: string) => filter)
      }
      .width('100%')

      this.buildItem('Greeting practice', 'Score 88')
      this.buildItem('Lip reading practice', 'Score 82')
      this.buildItem('Daily repetition', `Progress ${this.dailyProgress}%`)

      Button('Open training page')
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
    .padding({ left: 20, right: 20, top: 10, bottom: 110 })
  }

  @Builder
  private buildItem(title: string, subtitle: string) {
    Column({ space: 6 }) {
      Text(title)
        .fontSize(17)
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
