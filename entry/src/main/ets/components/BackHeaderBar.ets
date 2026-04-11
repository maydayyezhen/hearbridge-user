/**
 * BackHeaderBar 组件文件，负责页面局部界面结构与交互。
 */

import { APP_COLORS, APP_RADIUS, APP_SHADOW } from '../config/AppStyle'

@Component
export struct BackHeaderBar {
  @Prop title: string = ''
  @Prop showShadow: boolean = true
  onBack: () => void = () => {}

  @Builder
  private buildContent() {
    Row({ space: 12 }) {
      Stack({ alignContent: Alignment.Center }) {
        Row()
          .width(34)
          .height(34)
          .backgroundColor(APP_COLORS.surfaceSoft)
          .borderRadius(APP_RADIUS.md)
          .shadow(APP_SHADOW.soft)

        SymbolGlyph($r('sys.symbol.chevron_backward'))
          .fontSize(18)
          .fontColor([APP_COLORS.secondaryText])
      }
      .width(34)
      .height(34)
      .onClick(() => {
        this.onBack()
      })

      Column() {
        Text(this.title)
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor(APP_COLORS.primaryText)
      }
      .alignItems(HorizontalAlign.Start)

      Blank()
    }
    .width('100%')
    .padding({ top: 10, bottom: 8 })
  }

  build() {
    if (this.showShadow) {
      Column() {
        this.buildContent()
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 0, bottom: 8 })
      .backgroundColor(APP_COLORS.surface)
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])
      .shadow(APP_SHADOW.soft)
    } else {
      Column() {
        this.buildContent()
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 0, bottom: 8 })
      .backgroundColor(APP_COLORS.surface)
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])
    }
  }
}
