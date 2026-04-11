/**
 * Shared loading overlay for page content areas.
 */

@Component
export struct PageLoadingOverlay {
  @Prop text: string = '\u6b63\u5728\u52a0\u8f7d...'
  @Prop maskColor: string = 'transparent'
  @Prop showCard: boolean = false

  build() {
    Stack({ alignContent: Alignment.Center }) {
      if (this.maskColor.length > 0 && this.maskColor !== 'transparent') {
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor(this.maskColor)
      }

      Column({ space: 12 }) {
        LoadingProgress()
          .width(34)
          .height(34)
          .color('#2E79F4')

        Text(this.text)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#1F2A44')
      }
      .padding({ left: 22, right: 22, top: 20, bottom: 20 })
      .backgroundColor(this.showCard ? '#FFFFFF' : 'transparent')
      .borderRadius(this.showCard ? 18 : 0)
      .border({ width: this.showCard ? 1 : 0, color: '#E4ECF8' })
    }
    .width('100%')
    .height('100%')
  }
}
