@Component
export struct FocusTagChip {
  @Prop label: string = ''
  @Prop chipBgColor: string = '#EEF5FF'
  @Prop chipFontColor: string = '#2E79F4'

  build() {
    Text(this.label)
      .fontSize(12)
      .fontColor(this.chipFontColor)
      .padding({ left: 10, right: 10, top: 8, bottom: 8 })
      .backgroundColor(this.chipBgColor)
      .borderRadius(12)
      .margin({ right: 8, bottom: 8 })
  }
}
