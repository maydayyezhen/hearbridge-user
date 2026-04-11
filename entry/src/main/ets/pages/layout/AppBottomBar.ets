/**
 * AppBottomBar 页面文件，负责页面展示与交互承接。
 */

import { goRootTab } from '../../router/Router'
import { ROOT_TABS } from '../../router/RouteRegistry'
import { TabItem } from '../../router/RouteTypes'
import { isTabPath, getRouteBasePath } from '../../router/RouteMatcher'
import { APP_COLORS } from '../../config/AppStyle'

@Component
export struct AppBottomBar {
  @StorageLink('route.path')
  @Watch('handleVisibilityChange')
  routePath: string = '/launch'
  @StorageLink('route.overlay.active')
  @Watch('handleVisibilityChange')
  overlayActive: boolean = false
  @State renderedTabs: boolean = false
  @State displayedTabPath: string = '/home'
  @State barOffsetY: number = 0
  @State barOpacity: number = 1

  private hideTimer: number = -1

  private shouldShowTabs(): boolean {
    return isTabPath(this.routePath) && !this.overlayActive
  }

  aboutToAppear(): void {
    this.syncVisibilityImmediately()
  }

  aboutToDisappear(): void {
    this.clearHideTimer()
  }

  private clearHideTimer(): void {
    if (this.hideTimer !== -1) {
      clearTimeout(this.hideTimer)
      this.hideTimer = -1
    }
  }

  private syncVisibilityImmediately(): void {
    const visible = this.shouldShowTabs()
    this.clearHideTimer()
    this.syncDisplayedTabPath()
    this.renderedTabs = visible
    this.barOffsetY = 0
    this.barOpacity = visible ? 1 : 0
  }

  private handleVisibilityChange(): void {
    this.syncDisplayedTabPath()
    const visible = this.shouldShowTabs()
    if (visible) {
      this.runShowAnimation()
      return
    }
    this.runHideAnimation()
  }

  private runShowAnimation(): void {
    this.clearHideTimer()
    if (!this.renderedTabs) {
      this.renderedTabs = true
      this.barOffsetY = 18
      this.barOpacity = 0
    }
    this.getUIContext().animateTo({ duration: 220, curve: Curve.EaseOut }, () => {
      this.barOffsetY = 0
      this.barOpacity = 1
    })
  }

  private runHideAnimation(): void {
    if (!this.renderedTabs) {
      return
    }
    this.clearHideTimer()
    this.getUIContext().animateTo({ duration: 120, curve: Curve.EaseIn }, () => {
      this.barOffsetY = 18
      this.barOpacity = 0
    })
    this.hideTimer = setTimeout(() => {
      this.renderedTabs = false
      this.barOffsetY = 0
      this.barOpacity = 1
      this.hideTimer = -1
    }, 120)
  }

  private handleTabChange(item: TabItem): void {
    goRootTab(item.path)
  }

  private syncDisplayedTabPath(): void {
    if (isTabPath(this.routePath)) {
      this.displayedTabPath = getRouteBasePath(this.routePath)
    }
  }

  build() {
    if (this.renderedTabs) {
      RootTabsBar({
        currentPath: this.displayedTabPath,
        items: ROOT_TABS,
        onTabChange: (item: TabItem): void => { this.handleTabChange(item) }
      })
        .opacity(this.barOpacity)
        .translate({ x: 0, y: this.barOffsetY })
    }
  }
}

@Component
export struct RootTabsBar {
  @Prop currentPath: string = '/home'
  @Prop items: TabItem[] = []
  onTabChange?: (item: TabItem) => void

  private isActive(item: TabItem): boolean {
    return getRouteBasePath(this.currentPath) === item.path
  }

  @Builder
  private buildNavItem(item: TabItem) {
    Column({ space: 6 }) {
      Stack({ alignContent: Alignment.Center }) {
        Row() {}
          .width(32)
          .height(32)
          .backgroundColor(this.isActive(item) ? '#E7F0FF' : '#F4F7FB')
          .borderRadius(16)
        SymbolGlyph(this.isActive(item) ? item.selectedIcon : item.icon)
          .fontSize(18)
          .fontColor(this.isActive(item) ? ['#2E79F4'] : ['#97A7C0'])
          .symbolEffect(new BounceSymbolEffect(EffectScope.WHOLE, EffectDirection.UP), this.isActive(item))
      }
      .width(32)
      .height(32)
      Text(item.label)
        .fontSize(11)
        .fontColor(this.isActive(item) ? '#2E79F4' : '#7A8CA7')
    }
    .layoutWeight(1)
    .padding({ top: 2, bottom: 2 })
    .onClick(() => {
      if (this.onTabChange) this.onTabChange(item)
    })
  }

  build() {
    Column() {
      Column() {
        Row() {
          ForEach(this.items, (item: TabItem) => {
            this.buildNavItem(item)
          })
        }
        .width('100%')
        .padding({ left: 12, right: 12, top: 8, bottom: 4 })

        Blank()
          .height(12)
      }
      .width('100%')
      .backgroundColor('#FFFFFF')
      .borderRadius({ topLeft: 26, topRight: 26 })
      .clip(true)
      .shadow({ radius: 24, color: '#1A15304B', offsetX: 0, offsetY: -4 })

      Blank()
        .width('100%')
        .backgroundColor('#FFFFFF')
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
    }
    .width('100%')
    .backgroundColor(APP_COLORS.backgroundStart)
  }
}
