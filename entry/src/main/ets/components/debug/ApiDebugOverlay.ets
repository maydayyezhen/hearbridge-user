/**
 * ApiDebugOverlay 组件文件，负责页面局部界面结构与交互。
 */

import { ApiDebugPanel } from './ApiDebugPanel'
import { initRouteDebugStore } from '../../storage/ui/RouteDebugStore'

@Component
export struct ApiDebugOverlay {
  @StorageLink('ui.showApiDebugDialog') visible: boolean = false
  @StorageLink('ui.showApiDebugBall') showFloatingBall: boolean = true
  @State private floatingBallX: number = 300
  @State private floatingBallY: number = 600
  @State private touchStartX: number = 0
  @State private touchStartY: number = 0
  @State private dragStartX: number = 300
  @State private dragStartY: number = 600
  @State private suppressNextClick: boolean = false

  aboutToAppear(): void {
    AppStorage.setOrCreate('ui.showApiDebugDialog', false)
    AppStorage.setOrCreate('ui.showApiDebugBall', true)
    initRouteDebugStore()
  }

  build() {
    if (this.visible) {
      Stack({ alignContent: Alignment.Center }) {
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor('#520A1628')
          .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
          .onClick(() => {
            this.visible = false
          })

        ApiDebugPanel({
          onClose: () => {
            this.visible = false
          },
          onHideFloatingBall: () => {
            this.showFloatingBall = false
            this.visible = false
          }
        })
        .zIndex(1)
      }
      .width('100%')
      .height('100%')
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
      .zIndex(9999)
    } else {
      if (this.showFloatingBall) {
        Button() {
          SymbolGlyph($r('sys.symbol.info_circle'))
            .fontSize(18)
            .fontColor(['#FFFFFF'])
        }
        .width(50)
        .height(50)
        .backgroundColor('#2E79F4')
        .borderRadius(25)
        .shadow({ radius: 20, color: '#552E79F4', offsetX: 0, offsetY: 8 })
        .stateEffect(false)
        .position({ x: this.floatingBallX, y: this.floatingBallY })
        .zIndex(9998)
        .onTouch((event: TouchEvent) => {
          if (event.type === TouchType.Down && event.touches.length > 0) {
            const touch = event.touches[0]
            this.touchStartX = touch.windowX
            this.touchStartY = touch.windowY
            this.dragStartX = this.floatingBallX
            this.dragStartY = this.floatingBallY
            this.suppressNextClick = false
            return
          }
          if (event.type === TouchType.Move && event.touches.length > 0) {
            const touch = event.touches[0]
            const offsetX = touch.windowX - this.touchStartX
            const offsetY = touch.windowY - this.touchStartY
            this.floatingBallX = this.dragStartX + offsetX
            this.floatingBallY = this.dragStartY + offsetY
            if (Math.abs(offsetX) > 4 || Math.abs(offsetY) > 4) {
              this.suppressNextClick = true
            }
          }
        })
        .onClick(() => {
          if (this.suppressNextClick) {
            this.suppressNextClick = false
            return
          }
          this.visible = true
        })
      }
    }
  }
}
