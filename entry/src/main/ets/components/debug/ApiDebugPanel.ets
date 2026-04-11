/**
 * Floating API debug dialog content.
 */

@Component
export struct ApiDebugPanel {
  @StorageLink('apiDebugText') debugText: string = ''
  @StorageLink('routeDebugText') routeDebugText: string = ''
  @StorageLink('ui.showApiDebugBall') showFloatingBall: boolean = true
  onClose: () => void = () => {}
  onHideFloatingBall: () => void = () => {}

  private getRouteLines(): string[] {
    const content = this.routeDebugText.length > 0
      ? this.routeDebugText
      : 'route.path=unavailable\nroute.matched=unavailable\noverlay.target=unavailable\noverlay.displayed=unavailable'
    return content.split('\n')
  }

  private getApiLines(): string[] {
    const content = this.debugText.length > 0
      ? this.debugText
      : '\u5f53\u524d\u8fd8\u6ca1\u6709\u53ef\u663e\u793a\u7684\u63a5\u53e3\u8bb0\u5f55\u3002\n\u5b8c\u6210\u4e00\u6b21\u767b\u5f55\u3001\u8bfe\u7a0b\u52a0\u8f7d\u6216\u8bad\u7ec3\u63d0\u4ea4\u540e\uff0c\u518d\u56de\u6765\u67e5\u770b\u8fd9\u91cc\u3002'
    return content.split('\n')
  }

  @Builder
  private buildDebugLine(line: string, index: number) {
    Text(line.length > 0 ? line : ' ')
      .width('100%')
      .fontSize(11)
      .lineHeight(17)
      .fontColor(index % 2 === 0 ? '#38506E' : '#6C7F99')
      .fontFamily('monospace')
      .textAlign(TextAlign.Start)
      .padding({ left: 10, right: 10, top: 6, bottom: 6 })
      .backgroundColor(index % 2 === 0 ? '#F7FAFF' : '#EEF4FB')
  }

  build() {
    Column({ space: 10 }) {
      Row() {
        Text('\u63a5\u53e3\u8bf7\u6c42\u8bb0\u5f55')
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
        Column({ space: 12 }) {
          Column({ space: 0 }) {
            Text('Route Diagnostics')
              .width('100%')
              .fontSize(12)
              .fontWeight(FontWeight.Medium)
              .fontColor('#5B6F8C')
              .padding({ left: 2, right: 2, top: 2, bottom: 6 })

            ForEach(this.getRouteLines(), (line: string, index: number) => {
              this.buildDebugLine(line, index)
            }, (line: string, index: number) => `route_${index}_${line}`)
          }
          .width('100%')

          Column({ space: 0 }) {
            Text('API Requests')
              .width('100%')
              .fontSize(12)
              .fontWeight(FontWeight.Medium)
              .fontColor('#5B6F8C')
              .padding({ left: 2, right: 2, top: 2, bottom: 6 })

            ForEach(this.getApiLines(), (line: string, index: number) => {
              this.buildDebugLine(line, index)
            }, (line: string, index: number) => `api_${index}_${line}`)
          }
          .width('100%')
        }
        .width('100%')
      }
      .width('100%')
      .height(320)
      .scrollBar(BarState.On)

      Row({ space: 10 }) {
        Button('\u5173\u95ed')
          .layoutWeight(1)
          .height(42)
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor('#5C728F')
          .backgroundColor('#F3F7FD')
          .borderRadius(14)
          .stateEffect(false)
          .onClick(() => {
            this.onClose()
          })

        if (this.showFloatingBall) {
          Button('\u9690\u85cf\u60ac\u6d6e\u7403')
            .layoutWeight(1)
            .height(42)
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor('#2E79F4')
            .backgroundColor('#EAF2FF')
            .borderRadius(14)
            .stateEffect(false)
            .onClick(() => {
              this.showFloatingBall = false
              this.onHideFloatingBall()
            })
        }
      }
      .width('100%')
    }
    .width('86%')
    .padding(14)
    .backgroundColor('#FFFFFF')
    .borderRadius(24)
    .shadow({ radius: 24, color: '#2415304B', offsetX: 0, offsetY: 12 })
  }
}
