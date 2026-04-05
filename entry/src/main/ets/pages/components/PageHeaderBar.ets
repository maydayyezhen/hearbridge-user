@Component
export struct PageHeaderBar {
  @Prop title: string = ''
  @Prop subtitle: string = ''
  onBack: () => void = () => {}

  build() {
    Column() {
      Row({ space: 12 }) {
        Stack({ alignContent: Alignment.Center }) {
          Row()
            .width(34)
            .height(34)
            .backgroundColor('#F1F3F6')
            .borderRadius(17)

          SymbolGlyph($r('sys.symbol.chevron_backward'))
            .fontSize(18)
            .fontColor(['#6F7785'])
        }
        .width(34)
        .height(34)
        .onClick(() => {
          this.onBack()
        })

        Column({ space: 4 }) {
          Text(this.title)
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1F2A44')

          if (this.subtitle.length > 0) {
            Text(this.subtitle)
              .fontSize(12)
              .fontColor('#7A8CA7')
          }
        }
        .alignItems(HorizontalAlign.Start)

        Blank()
      }
      .width('100%')
      .padding({ top: 10, bottom: 8 })
    }
    .width('100%')
    .backgroundColor('#FFFFFF')
  }
}
