@Component
export struct ApiDebugPanel {
  @StorageLink('apiDebugText') debugText: string = '暂无 API 调试信息'
  onClose: () => void = () => {}

  private getLines(): string[] {
    const content = this.debugText.length > 0 ? this.debugText : '暂无 API 调试信息'
    return content.split('\n')
  }

  build() {
    Column({ space: 10 }) {
      Row() {
        Text('API 调试信息')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#1F2A44')

        Blank()

        Button() {
          SymbolGlyph($r('sys.symbol.xmark'))
            .fontSize(14)
            .fontColor(['#6C7F99'])
        }
        .width(28)
        .height(28)
        .backgroundColor('#F3F7FD')
        .borderRadius(14)
        .stateEffect(false)
        .onClick(() => {
          this.onClose()
        })
      }
      .width('100%')

      Scroll() {
        Column({ space: 0 }) {
          ForEach(this.getLines(), (line: string, index: number) => {
            Text(line.length > 0 ? line : ' ')
              .width('100%')
              .fontSize(11)
              .lineHeight(17)
              .fontColor(index % 2 === 0 ? '#38506E' : '#6C7F99')
              .fontFamily('monospace')
              .textAlign(TextAlign.Start)
              .padding({ left: 10, right: 10, top: 6, bottom: 6 })
              .backgroundColor(index % 2 === 0 ? '#F7FAFF' : '#EEF4FB')
          }, (line: string, index: number) => `${index}_${line}`)
        }
        .width('100%')
      }
      .width('100%')
      .height(320)
      .scrollBar(BarState.On)
    }
    .width('86%')
    .padding(14)
    .backgroundColor('#FFFFFF')
    .borderRadius(24)
    .shadow({ radius: 24, color: '#15304B24', offsetX: 0, offsetY: 12 })
  }
}
