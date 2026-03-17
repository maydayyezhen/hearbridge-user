@Component
export struct TrainBottomBar {
  @Prop isFavorited: boolean = false
  @Prop progressText: string = '0/0'
  @Prop showRetry: boolean = false
  onRetryClick: () => void = () => {}
  onFavoriteToggle: () => void = () => {}
  onOutlineToggle: () => void = () => {}

  build() {
    Column() {
      Row() {
        if (this.showRetry) {
          Button() {
            Column({ space: 2 }) {
              SymbolGlyph($r('sys.symbol.arrow_counterclockwise'))
                .fontSize(18)
                .fontColor(['#2E79F4'])

              Text('再练一次')
                .fontSize(11)
                .fontWeight(FontWeight.Medium)
                .fontColor('#2E79F4')
            }
            .alignItems(HorizontalAlign.Center)
          }
          .width(64)
          .height(46)
          .stateEffect(false)
          .backgroundColor(Color.Transparent)
          .borderRadius(0)
          .onClick(() => {
            this.onRetryClick()
          })
        }

        Blank()

        Button() {
          Column({ space: 2 }) {
            SymbolGlyph(this.isFavorited ? $r('sys.symbol.star_fill') : $r('sys.symbol.star'))
              .fontSize(18)
              .fontColor([this.isFavorited ? '#2E79F4' : '#7E8FA8'])

            Text(this.isFavorited ? '已收藏' : '收藏')
              .fontSize(11)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.isFavorited ? '#2E79F4' : '#5F718B')
          }
          .alignItems(HorizontalAlign.Center)
        }
        .width(56)
        .height(46)
        .stateEffect(false)
        .backgroundColor(Color.Transparent)
        .borderRadius(0)
        .onClick(() => {
          this.onFavoriteToggle()
        })

        Button() {
          Column({ space: 2 }) {
            SymbolGlyph($r('sys.symbol.square_grid_2x2'))
              .fontSize(18)
              .fontColor(['#7E8FA8'])

            Text(this.progressText)
              .fontSize(11)
              .fontWeight(FontWeight.Medium)
              .fontColor('#5F718B')
          }
          .alignItems(HorizontalAlign.Center)
        }
        .width(56)
        .height(46)
        .stateEffect(false)
        .backgroundColor(Color.Transparent)
        .borderRadius(0)
        .onClick(() => {
          this.onOutlineToggle()
        })
      }
      .width('100%')
      .padding({ left: 12, right: 16, top: 2, bottom: 6 })
    }
    .width('100%')
    .backgroundColor('#FFFFFF')
    .border({ width: { top: 1, right: 0, bottom: 0, left: 0 }, color: '#E9EFF8' })
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
  }
}
