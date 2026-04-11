/**
 * AppRouteViewport page host with persistent root tabs and overlay routes.
 */

import { getRouteBasePath, matchRoute } from '../../router/RouteMatcher'
import {
  COURSE_DETAIL_PATH,
  HOME_PATH,
  LAUNCH_PATH,
  LOGIN_PASSWORD_PATH,
  LOGIN_SMS_PATH,
  PROFILE_ABOUT_PATH,
  PROFILE_ACCOUNT_PATH,
  PROFILE_FEEDBACK_PATH,
  PROFILE_FAVORITES_PATH,
  PROFILE_PASSWORD_PATH,
  PROFILE_PATH,
  PROFILE_SECURITY_PATH,
  RECORD_PATH,
  REGISTER_PATH,
  TRAIN_PATH,
  TRAIN_SESSION_COURSE_PATH,
  TRAIN_SESSION_PATH
} from '../../router/RoutePaths'
import { LaunchLoadingPage } from '../layout/LaunchLoadingPage'
import { SmsLoginPage } from '../auth/SmsLoginPage'
import { PasswordLoginPage } from '../auth/PasswordLoginPage'
import { RegisterPage } from '../auth/RegisterPage'
import { HomePage } from '../home/HomePage'
import { TrainRootPage } from '../train/root/TrainRootPage'
import { RecordPage } from '../record/RecordPage'
import { ProfilePage } from '../profile/ProfilePage'
import { FavoritesPage } from '../profile/FavoritesPage'
import { AccountPage } from '../profile/AccountPage'
import { SecurityPage } from '../profile/SecurityPage'
import { PasswordPage } from '../profile/PasswordPage'
import { FeedbackPage } from '../profile/FeedbackPage'
import { AboutPage } from '../profile/AboutPage'
import { CoursePage } from '../train/detail/CoursePage'
import { TrainPage } from '../train/flow/TrainPage'
import { APP_COLORS } from '../../config/AppStyle'
import { writeRouteDebugText } from '../../storage/ui/RouteDebugStore'

const TRANSITION_SWAP_DELAY_MS = 130
const ROUTE_OVERLAY_ACTIVE_KEY = 'route.overlay.active'

@Component
export struct AppRouteViewport {
  @StorageLink('route.path')
  @Watch('handleRoutePathChange')
  routePath: string = '/launch'

  @StorageLink('route.transition.direction')
  transitionDirection: number = 0

  @State private displayedOverlayPath: string = ''
  @State private displayedStandalonePath: string = LAUNCH_PATH
  @State private overlayOffsetX: number = 0
  @State private overlayOpacity: number = 1
  @State private rootTabsOffsetX: number = 0
  @State private rootTabsOpacity: number = 1
  @State private activeRootTabPath: string = HOME_PATH
  @State private currentRootTabIndex: number = 0
  @State private displayedRootTabIndex: number = 0
  @State private frozenRootTabIndex: number = -1

  private swapTimer: number = -1
  private pendingRootTabIndex: number = -1

  aboutToAppear(): void {
    this.displayedStandalonePath = this.routePath
    this.syncActiveRootTabPath(this.routePath)
    this.syncVisibleRootTabIndex(this.routePath)
    this.displayedRootTabIndex = this.currentRootTabIndex
    this.syncOverlayImmediately(this.routePath)
    this.syncRouteDebugSnapshot(this.routePath)
  }

  aboutToDisappear(): void {
    this.clearTransitionTimers()
  }

  private clearTransitionTimers(): void {
    if (this.swapTimer !== -1) {
      clearTimeout(this.swapTimer)
      this.swapTimer = -1
    }
  }

  private writeOverlayActiveState(): void {
    AppStorage.setOrCreate(ROUTE_OVERLAY_ACTIVE_KEY, this.displayedOverlayPath.length > 0)
  }

  private getMatchedRoutePath(path: string): string | null {
    return matchRoute(path)
  }

  private isStandaloneRoute(path: string): boolean {
    const matchedRoutePath = this.getMatchedRoutePath(path)
    return matchedRoutePath === LAUNCH_PATH
      || matchedRoutePath === LOGIN_SMS_PATH
      || matchedRoutePath === LOGIN_PASSWORD_PATH
      || matchedRoutePath === REGISTER_PATH
  }

  private isRootTabRoute(path: string): boolean {
    const matchedRoutePath = this.getMatchedRoutePath(path)
    return matchedRoutePath === HOME_PATH
      || matchedRoutePath === TRAIN_PATH
      || matchedRoutePath === RECORD_PATH
      || matchedRoutePath === PROFILE_PATH
  }

  private shouldUsePersistentRootHost(path: string): boolean {
    const matchedRoutePath = this.getMatchedRoutePath(path)
    return matchedRoutePath !== null && !this.isStandaloneRoute(path)
  }

  private getOverlayPath(path: string): string {
    if (!this.shouldUsePersistentRootHost(path) || this.isRootTabRoute(path)) {
      return ''
    }
    return path
  }

  private syncOverlayImmediately(path: string): void {
    const nextOverlayPath = this.getOverlayPath(path)
    this.displayedOverlayPath = nextOverlayPath
    this.overlayOffsetX = 0
    this.overlayOpacity = nextOverlayPath.length > 0 ? 1 : 0
    this.rootTabsOffsetX = 0
    this.rootTabsOpacity = 1
    if (nextOverlayPath.length === 0) {
      this.displayedRootTabIndex = this.currentRootTabIndex
    }
    this.writeOverlayActiveState()
    this.syncRouteDebugSnapshot(path)
  }

  private handleRoutePathChange(): void {
    if (!this.shouldUsePersistentRootHost(this.routePath)) {
      this.displayedStandalonePath = this.routePath
      this.clearTransitionTimers()
      this.syncRouteDebugSnapshot(this.routePath)
      return
    }
    this.syncActiveRootTabPath(this.routePath)
    const nextOverlayPath = this.getOverlayPath(this.routePath)
    const nextRootTabIndex = this.getRootTabIndex(this.resolveVisibleRootTabPath(this.routePath))
    const shouldDeferRootTabSwitch = this.displayedOverlayPath.length > 0 && nextOverlayPath !== this.displayedOverlayPath
    this.syncVisibleRootTabIndex(this.routePath, shouldDeferRootTabSwitch)
    const shouldSwitchRootImmediately = this.displayedOverlayPath.length === 0
      && nextOverlayPath.length === 0
      && this.isRootTabRoute(this.routePath)
      && nextRootTabIndex !== this.displayedRootTabIndex
    if (shouldSwitchRootImmediately) {
      this.clearTransitionTimers()
      this.displayedRootTabIndex = nextRootTabIndex
      this.rootTabsOffsetX = 0
      this.rootTabsOpacity = 1
      this.syncRouteDebugSnapshot(this.routePath)
      return
    }
    if (nextOverlayPath === this.displayedOverlayPath) {
      this.flushPendingRootTabIndexIfReady(nextOverlayPath)
      this.syncRouteDebugSnapshot(this.routePath)
      return
    }
    if (this.transitionDirection === 0) {
      this.clearTransitionTimers()
      this.syncOverlayImmediately(this.routePath)
      this.flushPendingRootTabIndexIfReady(nextOverlayPath)
      return
    }
    const forward = this.transitionDirection > 0
    if (this.displayedOverlayPath.length === 0 && nextOverlayPath.length > 0) {
      this.runOverlayEnter(nextOverlayPath, forward)
      return
    }
    if (this.displayedOverlayPath.length > 0 && nextOverlayPath.length === 0) {
      this.runOverlayExit(forward)
      return
    }
    this.runOverlayReplace(nextOverlayPath, forward)
  }

  private runOverlayEnter(path: string, forward: boolean): void {
    this.clearTransitionTimers()
    this.displayedOverlayPath = path
    const enterOffset = forward ? 28 : -28
    const rootExitOffset = forward ? -28 : 28
    this.overlayOffsetX = enterOffset
    this.overlayOpacity = 0
    this.rootTabsOffsetX = 0
    this.rootTabsOpacity = 1
    this.getUIContext().animateTo({ duration: 120, curve: Curve.EaseIn }, () => {
      this.rootTabsOffsetX = rootExitOffset
      this.rootTabsOpacity = 0
    })
    this.writeOverlayActiveState()
    this.syncRouteDebugSnapshot(this.routePath)
    this.getUIContext().animateTo({ duration: 220, curve: Curve.EaseOut }, () => {
      this.overlayOffsetX = 0
      this.overlayOpacity = 1
    })
  }

  private runOverlayExit(forward: boolean): void {
    this.clearTransitionTimers()
    const exitOffset = forward ? -28 : 28
    const rootEnterOffset = forward ? 28 : -28
    this.rootTabsOffsetX = rootEnterOffset
    this.rootTabsOpacity = 0
    this.getUIContext().animateTo({ duration: 220, curve: Curve.EaseOut }, () => {
      this.rootTabsOffsetX = 0
      this.rootTabsOpacity = 1
    })
    this.getUIContext().animateTo({ duration: 120, curve: Curve.EaseIn }, () => {
      this.overlayOffsetX = exitOffset
      this.overlayOpacity = 0
    })
    this.swapTimer = setTimeout(() => {
      this.displayedOverlayPath = ''
      this.overlayOffsetX = 0
      this.overlayOpacity = 1
      this.rootTabsOffsetX = 0
      this.rootTabsOpacity = 1
      this.writeOverlayActiveState()
      this.flushPendingRootTabIndex()
      this.displayedRootTabIndex = this.currentRootTabIndex
      this.syncRouteDebugSnapshot(this.routePath)
      this.swapTimer = -1
    }, TRANSITION_SWAP_DELAY_MS)
  }

  private runOverlayReplace(path: string, forward: boolean): void {
    this.clearTransitionTimers()
    const exitOffset = forward ? -28 : 28
    const enterOffset = forward ? 28 : -28
    this.getUIContext().animateTo({ duration: 110, curve: Curve.EaseIn }, () => {
      this.overlayOffsetX = exitOffset
      this.overlayOpacity = 0
    })
    this.swapTimer = setTimeout(() => {
      this.displayedOverlayPath = path
      this.overlayOffsetX = enterOffset
      this.overlayOpacity = 0
      this.writeOverlayActiveState()
      this.syncRouteDebugSnapshot(this.routePath)
      this.getUIContext().animateTo({ duration: 220, curve: Curve.EaseOut }, () => {
        this.overlayOffsetX = 0
        this.overlayOpacity = 1
      })
      this.swapTimer = -1
    }, TRANSITION_SWAP_DELAY_MS)
  }

  private applyRootTabIndex(nextIndex: number): void {
    if (nextIndex === this.currentRootTabIndex) {
      return
    }
    this.currentRootTabIndex = nextIndex
  }

  private flushPendingRootTabIndex(): void {
    if (this.pendingRootTabIndex >= 0) {
      this.applyRootTabIndex(this.pendingRootTabIndex)
      this.pendingRootTabIndex = -1
    }
    this.frozenRootTabIndex = -1
  }

  private flushPendingRootTabIndexIfReady(nextOverlayPath: string): void {
    if (this.pendingRootTabIndex < 0) {
      return
    }
    if (nextOverlayPath.length > 0 || this.displayedOverlayPath.length > 0) {
      return
    }
    this.flushPendingRootTabIndex()
  }

  private syncActiveRootTabPath(path: string): void {
    const matchedRoutePath = this.getMatchedRoutePath(path)
    if (matchedRoutePath === HOME_PATH
      || matchedRoutePath === TRAIN_PATH
      || matchedRoutePath === RECORD_PATH
      || matchedRoutePath === PROFILE_PATH) {
      this.activeRootTabPath = matchedRoutePath
    }
  }

  private resolveVisibleRootTabPath(path: string): string {
    const matchedRoutePath = this.getMatchedRoutePath(path)
    if (matchedRoutePath === HOME_PATH
      || matchedRoutePath === TRAIN_PATH
      || matchedRoutePath === RECORD_PATH
      || matchedRoutePath === PROFILE_PATH) {
      return matchedRoutePath
    }
    if (this.activeRootTabPath.length > 0) {
      return this.activeRootTabPath
    }
    if (matchedRoutePath === COURSE_DETAIL_PATH
      || matchedRoutePath === TRAIN_SESSION_COURSE_PATH
      || matchedRoutePath === TRAIN_SESSION_PATH) {
      return TRAIN_PATH
    }
    if (matchedRoutePath === PROFILE_FAVORITES_PATH
      || matchedRoutePath === PROFILE_ACCOUNT_PATH
      || matchedRoutePath === PROFILE_SECURITY_PATH
      || matchedRoutePath === PROFILE_PASSWORD_PATH
      || matchedRoutePath === PROFILE_FEEDBACK_PATH
      || matchedRoutePath === PROFILE_ABOUT_PATH) {
      return PROFILE_PATH
    }
    return HOME_PATH
  }

  private getRootTabIndex(path: string): number {
    if (path === TRAIN_PATH) {
      return 1
    }
    if (path === RECORD_PATH) {
      return 2
    }
    if (path === PROFILE_PATH) {
      return 3
    }
    return 0
  }

  private syncVisibleRootTabIndex(path: string, deferSwitchWhenOverlayActive: boolean = false): void {
    const visibleRootTabPath = this.resolveVisibleRootTabPath(path)
    const nextIndex = this.getRootTabIndex(visibleRootTabPath)

    if (deferSwitchWhenOverlayActive && nextIndex !== this.currentRootTabIndex) {
      this.pendingRootTabIndex = nextIndex
      if (this.frozenRootTabIndex < 0) {
        this.frozenRootTabIndex = this.currentRootTabIndex
      }
      return
    }

    this.pendingRootTabIndex = -1
    this.frozenRootTabIndex = -1
    this.applyRootTabIndex(nextIndex)
  }

  private getDisplayedRootTabIndex(): number {
    return this.frozenRootTabIndex >= 0 ? this.frozenRootTabIndex : this.displayedRootTabIndex
  }

  private isDisplayedRootTab(index: number): boolean {
    return this.displayedRootTabIndex === index
  }

  private getRootTabVisibility(index: number): Visibility {
    return this.isDisplayedRootTab(index) ? Visibility.Visible : Visibility.Hidden
  }

  private getRootTabZIndex(index: number): number {
    return this.isDisplayedRootTab(index) ? 1 : 0
  }

  private isTrainSessionOverlay(path: string): boolean {
    const matchedRoutePath = this.getMatchedRoutePath(path)
    return matchedRoutePath === TRAIN_SESSION_COURSE_PATH || matchedRoutePath === TRAIN_SESSION_PATH
  }

  private getOverlayRenderKey(path: string): string {
    const matchedRoutePath = this.getMatchedRoutePath(path)
    if (matchedRoutePath === PROFILE_FAVORITES_PATH) {
      return PROFILE_FAVORITES_PATH
    }
    return path
  }

  private buildRouteDebugSnapshot(path: string): string {
    const matchedRoutePath = this.getMatchedRoutePath(path) ?? 'null'
    const overlayTargetPath = this.getOverlayPath(path)
    const displayedOverlayPath = this.displayedOverlayPath.length > 0 ? this.displayedOverlayPath : 'none'
    const displayedOverlayMatchedPath = this.displayedOverlayPath.length > 0
      ? (this.getMatchedRoutePath(this.displayedOverlayPath) ?? 'null')
      : 'none'
    const overlayTargetText = overlayTargetPath.length > 0 ? overlayTargetPath : 'none'
    const visibleRootTabPath = this.resolveVisibleRootTabPath(path)
    return [
      `route.path=${path}`,
      `route.base=${getRouteBasePath(path)}`,
      `route.matched=${matchedRoutePath}`,
      `overlay.target=${overlayTargetText}`,
      `overlay.displayed=${displayedOverlayPath}`,
      `overlay.displayedMatched=${displayedOverlayMatchedPath}`,
      `root.active=${this.activeRootTabPath}`,
      `root.visible=${visibleRootTabPath}`,
      `root.index=${this.currentRootTabIndex}`,
      `root.displayedIndex=${this.getDisplayedRootTabIndex()}`,
      `transition.direction=${this.transitionDirection}`
    ].join('\n')
  }

  private syncRouteDebugSnapshot(path: string): void {
    writeRouteDebugText(this.buildRouteDebugSnapshot(path))
  }

  @Builder
  private buildUnknownRoute(path: string) {
    Column({ space: 12 }) {
      Text('当前页面暂时无法打开')
        .fontSize(22)
        .fontWeight(FontWeight.Bold)
        .fontColor('#1F2A44')
      Text(`路径：${path}`)
        .fontSize(12)
        .fontColor('#98A6BA')
    }
    .width('100%')
    .height('100%')
    .padding(20)
    .backgroundColor(APP_COLORS.backgroundStart)
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  private buildStandaloneRoute(path: string) {
    if (this.getMatchedRoutePath(path) === LAUNCH_PATH) {
      LaunchLoadingPage()
    } else if (this.getMatchedRoutePath(path) === LOGIN_SMS_PATH) {
      SmsLoginPage()
    } else if (this.getMatchedRoutePath(path) === LOGIN_PASSWORD_PATH) {
      PasswordLoginPage()
    } else if (this.getMatchedRoutePath(path) === REGISTER_PATH) {
      RegisterPage()
    } else {
      this.buildUnknownRoute(path)
    }
  }

  @Builder
  private buildPersistentRootTabs() {
    Stack({ alignContent: Alignment.TopStart }) {
      Column() {
        HomePage({ isActive: this.isDisplayedRootTab(0) })
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Start)
      .alignItems(HorizontalAlign.Start)
      .visibility(this.getRootTabVisibility(0))
      .zIndex(this.getRootTabZIndex(0))

      Column() {
        TrainRootPage({ isActive: this.isDisplayedRootTab(1) })
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Start)
      .alignItems(HorizontalAlign.Start)
      .visibility(this.getRootTabVisibility(1))
      .zIndex(this.getRootTabZIndex(1))

      Column() {
        RecordPage({ isActive: this.isDisplayedRootTab(2) })
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Start)
      .alignItems(HorizontalAlign.Start)
      .visibility(this.getRootTabVisibility(2))
      .zIndex(this.getRootTabZIndex(2))

      Column() {
        ProfilePage({ isActive: this.isDisplayedRootTab(3) })
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Start)
      .alignItems(HorizontalAlign.Start)
      .visibility(this.getRootTabVisibility(3))
      .zIndex(this.getRootTabZIndex(3))
    }
    .width('100%')
    .height('100%')
    .backgroundColor(APP_COLORS.backgroundStart)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }

  @Builder
  private buildOverlayRoute(path: string) {
    if (this.getMatchedRoutePath(path) === PROFILE_FAVORITES_PATH) {
      FavoritesPage()
    } else if (this.getMatchedRoutePath(path) === PROFILE_ACCOUNT_PATH) {
      AccountPage()
    } else if (this.getMatchedRoutePath(path) === PROFILE_SECURITY_PATH) {
      SecurityPage()
    } else if (this.getMatchedRoutePath(path) === PROFILE_PASSWORD_PATH) {
      PasswordPage()
    } else if (this.getMatchedRoutePath(path) === PROFILE_FEEDBACK_PATH) {
      FeedbackPage()
    } else if (this.getMatchedRoutePath(path) === PROFILE_ABOUT_PATH) {
      AboutPage()
    } else if (this.getMatchedRoutePath(path) === COURSE_DETAIL_PATH) {
      CoursePage()
    } else if (this.isTrainSessionOverlay(path)) {
      TrainPage()
    } else {
      this.buildUnknownRoute(path)
    }
  }

  build() {
    if (!this.shouldUsePersistentRootHost(this.routePath)) {
      Stack({ alignContent: Alignment.TopStart }) {
        ForEach([this.displayedStandalonePath], (standalonePath: string) => {
          Column() {
            this.buildStandaloneRoute(standalonePath)
          }
          .width('100%')
          .height('100%')
          .justifyContent(FlexAlign.Start)
          .alignItems(HorizontalAlign.Start)
          .backgroundColor(APP_COLORS.backgroundStart)
          .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
        }, (standalonePath: string) => standalonePath)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(APP_COLORS.backgroundStart)
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
    } else {
      Stack({ alignContent: Alignment.TopStart }) {
        Column() {
          this.buildPersistentRootTabs()
        }
        .width('100%')
        .height('100%')
        .translate({ x: this.rootTabsOffsetX, y: 0 })
        .opacity(this.rootTabsOpacity)
        .visibility(this.displayedOverlayPath.length > 0 ? Visibility.Hidden : Visibility.Visible)
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])

        if (this.displayedOverlayPath.length > 0) {
          ForEach([this.displayedOverlayPath], (overlayPath: string) => {
            Column() {
              this.buildOverlayRoute(overlayPath)
            }
            .width('100%')
            .height('100%')
            .justifyContent(FlexAlign.Start)
            .alignItems(HorizontalAlign.Start)
            .backgroundColor(APP_COLORS.backgroundStart)
            .translate({ x: this.overlayOffsetX, y: 0 })
            .opacity(this.overlayOpacity)
            .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
          }, (overlayPath: string) => this.getOverlayRenderKey(overlayPath))
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor(APP_COLORS.backgroundStart)
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
    }
  }
}
