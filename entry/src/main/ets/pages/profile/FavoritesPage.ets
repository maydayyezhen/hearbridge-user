import { User, createUser } from '../../domain/entity/User'
import { go, goBack, replace } from '../../router/Router'
import { buildCourseDetailPath, buildProfileFavoritesPath, buildProfilePath, buildTrainSessionPath } from '../../router/RouteBuilders'
import { BackHeaderBar } from '../../components/BackHeaderBar'
import { APP_COLORS } from '../../config/AppStyle'
import { patchCoursePreview } from '../../repository/course/CoursePreviewRepository'
import { showGlobalToast } from '../../services/ui/index'
import { getRouteParam, matchRoute } from '../../router/RouteMatcher'
import { PROFILE_FAVORITES_PATH } from '../../router/RoutePaths'
import { hilog } from '@kit.PerformanceAnalysisKit'
import {
  FavoriteDisplayItem,
  getFavoriteCourseDisplayItems,
  getFavoriteTrainingItemDisplayItems,
  getTrainingTypeLabel,
  resolveFavoriteItemCourseCode
} from '../../services/user/index'

@Component
export struct FavoritesPage {
  @StorageLink('user') user: User = createUser()
  @StorageLink('route.path')
  @Watch('handleRoutePathChange')
  routePath: string = '/profile/favorites'

  @State private favoriteTab: string = 'course'
  @State private pagerWidth: number = 0
  @State private pagerTranslateX: number = 0
  @State private pagerDragStartX: number = 0
  @State private pagerDragStartIndex: number = 0
  @State private pagerDragging: boolean = false
  @State private settledPagerIndex: number = 0
  @State private tabBarWidth: number = 0

  private readonly courseTabIndicatorWidth: number = 30
  private readonly itemTabIndicatorWidth: number = 46
  private readonly pagerTransitionMinDurationMs: number = 120
  private readonly pagerTransitionMaxDurationMs: number = 220
  private readonly pagerReboundMinDurationMs: number = 120
  private readonly pagerReboundMaxDurationMs: number = 190
  private readonly pagerFastSwipeMinDistanceRatio: number = 0.07
  private readonly pagerFastSwipeMinVelocityPxPerSecond: number = 950
  private readonly logTag: string = 'FavoritesPagerTrace'
  private pagerDragStartedAt: number = 0
  private pagerAnimationTimer: number = -1

  aboutToAppear(): void {
    this.syncFavoriteTabFromRoute()
  }

  aboutToDisappear(): void {
    this.clearPagerAnimationTimer()
  }

  private clearPagerAnimationTimer(): void {
    if (this.pagerAnimationTimer !== -1) {
      hilog.info(0x0, this.logTag, '%{public}s', '[anim.clear] timer active')
      clearTimeout(this.pagerAnimationTimer)
      this.pagerAnimationTimer = -1
    }
  }

  private handleRoutePathChange(): void {
    hilog.info(0x0, this.logTag, '%{public}s', `[route.change] path=${this.routePath}`)
    this.syncFavoriteTabFromRoute()
  }

  private syncFavoriteTabFromRoute(): void {
    if (matchRoute(this.routePath) !== PROFILE_FAVORITES_PATH) {
      return
    }
    const routeTab = getRouteParam(this.routePath, 'tab')
    const nextTab = routeTab === 'item' ? 'item' : 'course'
    const nextIndex = this.getFavoriteTabByIndex(1) === nextTab ? 1 : 0
    const tabChanged = this.favoriteTab !== nextTab
    hilog.info(0x0, this.logTag, '%{public}s',
      `[route.sync] nextTab=${nextTab},tabChanged=${tabChanged},dragging=${this.pagerDragging}`)
    this.favoriteTab = nextTab
    if (!this.pagerDragging && tabChanged) {
      this.settledPagerIndex = nextIndex
      this.syncPagerToFavoriteTab(false)
    }
  }

  private switchFavoriteTab(tab: string): void {
    const nextTab = tab === 'item' ? 'item' : 'course'
    if (this.favoriteTab === nextTab && getRouteParam(this.routePath, 'tab') === nextTab) {
      return
    }
    this.transitionToFavoriteTab(nextTab)
  }

  private getFavoriteTabIndex(): number {
    return this.favoriteTab === 'item' ? 1 : 0
  }

  private getFavoriteTabByIndex(index: number): string {
    return index === 1 ? 'item' : 'course'
  }

  private getPagerIndexByTranslateX(translateX: number): number {
    if (this.pagerWidth <= 0) {
      return this.getFavoriteTabIndex()
    }
    const progress = -translateX / this.pagerWidth
    if (progress >= 0.5) {
      return 1
    }
    return 0
  }

  private getPagerTargetTranslateXByIndex(index: number): number {
    if (this.pagerWidth <= 0) {
      return 0
    }
    return -this.pagerWidth * index
  }

  private getPagerTransitionDuration(targetX: number): number {
    if (this.pagerWidth <= 0) {
      return this.pagerTransitionMaxDurationMs
    }
    const remainingRatio = Math.abs(targetX - this.pagerTranslateX) / this.pagerWidth
    const safeRatio = Math.max(0, Math.min(1, remainingRatio))
    return Math.round(
      this.pagerTransitionMinDurationMs
      + (this.pagerTransitionMaxDurationMs - this.pagerTransitionMinDurationMs) * safeRatio
    )
  }

  private getPagerReboundDuration(targetX: number): number {
    if (this.pagerWidth <= 0) {
      return this.pagerReboundMaxDurationMs
    }
    const remainingRatio = Math.abs(targetX - this.pagerTranslateX) / this.pagerWidth
    const safeRatio = Math.max(0, Math.min(1, remainingRatio))
    return Math.round(
      this.pagerReboundMinDurationMs
      + (this.pagerReboundMaxDurationMs - this.pagerReboundMinDurationMs) * safeRatio
    )
  }

  private syncPagerToFavoriteTab(animated: boolean): void {
    const targetIndex = this.getFavoriteTabIndex()
    const targetX = this.getPagerTargetTranslateXByIndex(targetIndex)
    this.clearPagerAnimationTimer()
    if (!animated || this.pagerWidth <= 0) {
      hilog.info(0x0, this.logTag, '%{public}s', `[pager.sync] animated=false,targetX=${targetX}`)
      this.pagerTranslateX = targetX
      this.settledPagerIndex = targetIndex
      return
    }
    const duration = this.getPagerTransitionDuration(targetX)
    hilog.info(0x0, this.logTag, '%{public}s',
      `[pager.sync] animated=true,targetX=${targetX},duration=${duration}`)
    this.getUIContext().animateTo({ duration, curve: Curve.EaseOut }, () => {
      this.pagerTranslateX = targetX
    })
    this.pagerAnimationTimer = setTimeout(() => {
      hilog.info(0x0, this.logTag, '%{public}s', '[anim.done]')
      this.settledPagerIndex = targetIndex
      this.pagerAnimationTimer = -1
    }, duration)
  }

  private transitionToFavoriteTab(tab: string): void {
    const nextTab = tab === 'item' ? 'item' : 'course'
    this.favoriteTab = nextTab
    hilog.info(0x0, this.logTag, '%{public}s', `[transition.start] nextTab=${nextTab},translateX=${this.pagerTranslateX}`)
    if (getRouteParam(this.routePath, 'tab') !== nextTab) {
      replace(buildProfileFavoritesPath(nextTab))
    }
    this.syncPagerToFavoriteTab(true)
  }

  private reboundPagerToIndex(index: number): void {
    const targetX = this.getPagerTargetTranslateXByIndex(index)
    this.clearPagerAnimationTimer()
    if (this.pagerWidth <= 0) {
      this.pagerTranslateX = targetX
      return
    }
    const duration = this.getPagerReboundDuration(targetX)
    hilog.info(0x0, this.logTag, '%{public}s',
      `[rebound.start] index=${index},targetX=${targetX},duration=${duration}`)
    this.getUIContext().animateTo({ duration, curve: Curve.EaseOut }, () => {
      this.pagerTranslateX = targetX
    })
    this.pagerAnimationTimer = setTimeout(() => {
      hilog.info(0x0, this.logTag, '%{public}s', '[rebound.done]')
      this.pagerAnimationTimer = -1
    }, duration)
  }

  private resolvePagerTranslateX(nextTranslateX: number): number {
    if (this.pagerWidth <= 0) {
      return nextTranslateX
    }
    const minTranslateX = -this.pagerWidth
    if (nextTranslateX > 0) {
      return nextTranslateX * 0.42
    }
    if (nextTranslateX < minTranslateX) {
      return minTranslateX + (nextTranslateX - minTranslateX) * 0.42
    }
    return nextTranslateX
  }

  private handlePagerAreaChange(newValue: Area): void {
    const width = Number(newValue.width ?? 0)
    if (width <= 0 || width === this.pagerWidth) {
      return
    }
    this.pagerWidth = width
    if (!this.pagerDragging) {
      this.pagerTranslateX = this.getPagerTargetTranslateXByIndex(this.getFavoriteTabIndex())
    }
  }

  private handleTabBarAreaChange(newValue: Area): void {
    const width = Number(newValue.width ?? 0)
    if (width > 0) {
      this.tabBarWidth = width
    }
  }

  private handlePagerDragStart(): void {
    this.clearPagerAnimationTimer()
    this.pagerDragging = true
    this.pagerDragStartX = this.pagerTranslateX
    this.pagerDragStartIndex = this.getPagerIndexByTranslateX(this.pagerDragStartX)
    this.pagerDragStartedAt = new Date().getTime()
    hilog.info(0x0, this.logTag, '%{public}s',
      `[drag.start] settledIndex=${this.settledPagerIndex},dragStartIndex=${this.pagerDragStartIndex},startX=${this.pagerDragStartX}`)
  }

  private handlePagerDragUpdate(event: GestureEvent): void {
    if (this.pagerWidth <= 0) {
      return
    }
    this.pagerTranslateX = this.resolvePagerTranslateX(this.pagerDragStartX + event.offsetX)
  }

  private handlePagerDragEnd(event: GestureEvent): void {
    this.pagerDragging = false
    if (this.pagerWidth <= 0) {
      this.syncPagerToFavoriteTab(false)
      return
    }

    const currentIndex = this.pagerDragStartIndex
    let nextIndex = currentIndex
    const dragDurationMs = Math.max(1, new Date().getTime() - this.pagerDragStartedAt)
    const dragDistance = Math.abs(event.offsetX)
    const fastSwipeMinDistancePx = this.pagerWidth > 0
      ? this.pagerWidth * this.pagerFastSwipeMinDistanceRatio
      : 24
    const dragVelocityPxPerSecond = dragDistance / dragDurationMs * 1000
    const isFastSwipe = dragDistance >= fastSwipeMinDistancePx
      && dragVelocityPxPerSecond >= this.pagerFastSwipeMinVelocityPxPerSecond
    const dragOffsetFromStart = this.pagerTranslateX - this.pagerDragStartX

    if (dragOffsetFromStart <= -this.pagerWidth * 0.5) {
      nextIndex = Math.min(1, currentIndex + 1)
    } else if (dragOffsetFromStart >= this.pagerWidth * 0.5) {
      nextIndex = Math.max(0, currentIndex - 1)
    } else if (isFastSwipe) {
      if (event.offsetX < 0) {
        nextIndex = Math.min(1, currentIndex + 1)
      } else if (event.offsetX > 0) {
        nextIndex = Math.max(0, currentIndex - 1)
      }
    }

    const nextTab = this.getFavoriteTabByIndex(nextIndex)
    hilog.info(0x0, this.logTag, '%{public}s',
      `[drag.end] currentIndex=${currentIndex},nextIndex=${nextIndex},offset=${event.offsetX},dragOffsetFromStart=${dragOffsetFromStart},translateX=${this.pagerTranslateX},fast=${isFastSwipe},minDistancePx=${fastSwipeMinDistancePx},velocityPxPerSecond=${dragVelocityPxPerSecond},duration=${dragDurationMs}`)
    if (nextIndex === currentIndex) {
      this.reboundPagerToIndex(currentIndex)
      return
    }
    this.transitionToFavoriteTab(nextTab)
  }

  private getPagerProgress(): number {
    if (this.pagerWidth <= 0) {
      return this.getFavoriteTabIndex()
    }
    const progress = -this.pagerTranslateX / this.pagerWidth
    if (progress < 0) {
      return 0
    }
    if (progress > 1) {
      return 1
    }
    return progress
  }

  private getTabIndicatorOffsetX(): number {
    if (this.tabBarWidth <= 0) {
      return 0
    }
    const tabWidth = this.tabBarWidth / 2
    const progress = this.getPagerProgress()
    const startX = (tabWidth - this.courseTabIndicatorWidth) / 2
    const endX = tabWidth + (tabWidth - this.itemTabIndicatorWidth) / 2
    return startX + (endX - startX) * progress
  }

  private getTabIndicatorWidth(): number {
    const progress = this.getPagerProgress()
    return this.courseTabIndicatorWidth
      + (this.itemTabIndicatorWidth - this.courseTabIndicatorWidth) * progress
  }

  private clampProgress(value: number): number {
    if (value < 0) {
      return 0
    }
    if (value > 1) {
      return 1
    }
    return value
  }

  private toHexChannel(value: number): string {
    const channel = Math.max(0, Math.min(255, Math.round(value)))
    const hex = channel.toString(16).toUpperCase()
    return hex.length === 1 ? `0${hex}` : hex
  }

  private mixTabColor(from: number[], to: number[], progress: number): string {
    const safeProgress = this.clampProgress(progress)
    const red = from[0] + (to[0] - from[0]) * safeProgress
    const green = from[1] + (to[1] - from[1]) * safeProgress
    const blue = from[2] + (to[2] - from[2]) * safeProgress
    return `#${this.toHexChannel(red)}${this.toHexChannel(green)}${this.toHexChannel(blue)}`
  }

  private getTabTextColor(tab: string): string {
    const progress = this.getPagerProgress()
    const activeProgress = tab === 'course' ? 1 - progress : progress
    return this.mixTabColor([111, 131, 162], [46, 121, 244], activeProgress)
  }

  private openFavoriteItem(item: FavoriteDisplayItem): void {
    if (item.kind === 'course') {
      go(buildCourseDetailPath(item.courseCode))
      return
    }

    const itemCode = item.itemCode.length > 0 ? item.itemCode : item.id
    const courseCode = resolveFavoriteItemCourseCode(this.user, itemCode, item.courseCode)
    if (itemCode.length === 0 || courseCode.length === 0 || courseCode === itemCode) {
      showGlobalToast('训练项课程编码异常，请先从课程详情进入。', 'error')
      return
    }

    if (item.courseName.length > 0) {
      patchCoursePreview(courseCode, {
        courseName: item.courseName,
        trainingType: item.trainingType
      })
    }
    go(buildTrainSessionPath(courseCode, itemCode))
  }

  @Builder
  private buildHeader() {
    Column({ space: 0 }) {
      BackHeaderBar({
        title: '我的收藏',
        showShadow: false,
        onBack: () => {
          goBack(buildProfilePath())
        }
      })

      Column() {
        Stack({ alignContent: Alignment.BottomStart }) {
          Row({ space: 0 }) {
            this.buildTabButton('course', '课程')
            this.buildTabButton('item', '训练项')
          }
          .width('100%')

          Row()
            .width(this.getTabIndicatorWidth())
            .height(3)
            .backgroundColor('#2E79F4')
            .borderRadius(2)
            .translate({ x: this.getTabIndicatorOffsetX(), y: -4 })
        }
        .width('100%')
        .height(38)
        .onAreaChange((_oldValue: Area, newValue: Area) => {
          this.handleTabBarAreaChange(newValue)
        })
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 2, bottom: 0 })
    }
    .width('100%')
    .backgroundColor('#FFFFFF')
    .shadow({ radius: 12, color: '#0D15304B', offsetX: 0, offsetY: 4 })
  }

  @Builder
  private buildTabButton(tab: string, label: string) {
    Text(label)
      .layoutWeight(1)
      .height(30)
      .textAlign(TextAlign.Center)
      .fontSize(14)
      .fontWeight(this.favoriteTab === tab ? FontWeight.Medium : FontWeight.Regular)
      .fontColor(this.getTabTextColor(tab))
      .onClick(() => {
        this.switchFavoriteTab(tab)
      })
  }

  @Builder
  private buildItemCard(item: FavoriteDisplayItem) {
    Button() {
      Row({ space: 12 }) {
        Stack({ alignContent: Alignment.Center }) {
          Row()
            .width(30)
            .height(30)
            .backgroundColor('#EDF4FF')
            .borderRadius(15)
          SymbolGlyph($r('sys.symbol.star_fill'))
            .fontSize(15)
            .fontColor(['#2E79F4'])
        }
        .width(30)
        .height(30)

        Column({ space: 4 }) {
          Text(item.title)
            .width('100%')
            .fontSize(15)
            .fontWeight(FontWeight.Medium)
            .fontColor('#1F2A44')
            .maxLines(1)

          Text(item.subtitle.length > 0 ? item.subtitle : `${getTrainingTypeLabel(item.trainingType)} · ${item.courseCode}`)
            .width('100%')
            .fontSize(12)
            .fontColor('#7A8CA7')
            .maxLines(1)
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)

        SymbolGlyph($r('sys.symbol.chevron_forward'))
          .fontSize(14)
          .fontColor(['#9BAAC0'])
      }
    }
    .type(ButtonType.Normal)
    .stateEffect(false)
    .padding(14)
    .backgroundColor(APP_COLORS.surface)
    .borderRadius(16)
    .shadow({ radius: 12, color: '#0D15304B', offsetX: 0, offsetY: 5 })
    .onClick(() => {
      this.openFavoriteItem(item)
    })
  }

  @Builder
  private buildEmpty(text: string) {
    Column({ space: 8 }) {
      SymbolGlyph($r('sys.symbol.star'))
        .fontSize(22)
        .fontColor(['#9FB0C8'])
      Text(text)
        .fontSize(13)
        .fontColor('#7F90A8')
    }
    .width('100%')
    .padding({ top: 30, bottom: 30 })
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  private buildCourseList() {
    Column({ space: 12 }) {
      if (getFavoriteCourseDisplayItems(this.user).length === 0) {
        this.buildEmpty('还没有收藏课程')
      } else {
        ForEach(getFavoriteCourseDisplayItems(this.user), (item: FavoriteDisplayItem) => {
          this.buildItemCard(item)
        }, (item: FavoriteDisplayItem) => item.id)
      }
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 6, bottom: 20 })
    .justifyContent(FlexAlign.Start)
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  private buildTrainingItemList() {
    Column({ space: 12 }) {
      if (getFavoriteTrainingItemDisplayItems(this.user).length === 0) {
        this.buildEmpty('还没有收藏训练项')
      } else {
        ForEach(getFavoriteTrainingItemDisplayItems(this.user), (item: FavoriteDisplayItem) => {
          this.buildItemCard(item)
        }, (item: FavoriteDisplayItem) => item.id)
      }
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 6, bottom: 20 })
    .justifyContent(FlexAlign.Start)
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  private buildPagerContent() {
    Row({ space: 0 }) {
      Scroll() {
        Column({ space: 0 }) {
          this.buildCourseList()
        }
        .width('100%')
        .justifyContent(FlexAlign.Start)
        .alignItems(HorizontalAlign.Start)
        .constraintSize({ minHeight: '100%' })
      }
      .width('50%')
      .height('100%')
      .scrollBar(BarState.Off)
      .nestedScroll({ scrollForward: NestedScrollMode.PARENT_FIRST, scrollBackward: NestedScrollMode.SELF_FIRST })
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])

      Scroll() {
        Column({ space: 0 }) {
          this.buildTrainingItemList()
        }
        .width('100%')
        .justifyContent(FlexAlign.Start)
        .alignItems(HorizontalAlign.Start)
        .constraintSize({ minHeight: '100%' })
      }
      .width('50%')
      .height('100%')
      .scrollBar(BarState.Off)
      .nestedScroll({ scrollForward: NestedScrollMode.PARENT_FIRST, scrollBackward: NestedScrollMode.SELF_FIRST })
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
    }
    .width('200%')
    .height('100%')
    .translate({ x: this.pagerTranslateX, y: 0 })
  }

  build() {
    Column({ space: 0 }) {
      this.buildHeader()

      Stack({ alignContent: Alignment.TopStart }) {
        this.buildPagerContent()
      }
      .width('100%')
      .layoutWeight(1)
      .clip(true)
      .onAreaChange((_oldValue: Area, newValue: Area) => {
        this.handlePagerAreaChange(newValue)
      })
      .gesture(
        PanGesture({ direction: PanDirection.Horizontal, distance: 10 })
          .onActionStart(() => {
            this.handlePagerDragStart()
          })
          .onActionUpdate((event: GestureEvent) => {
            this.handlePagerDragUpdate(event)
          })
          .onActionEnd((event: GestureEvent) => {
            this.handlePagerDragEnd(event)
          })
      )
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
    }
    .width('100%')
    .height('100%')
    .backgroundColor(APP_COLORS.backgroundStart)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }
}
