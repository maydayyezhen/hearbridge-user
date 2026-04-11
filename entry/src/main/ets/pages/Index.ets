/**
 * Index 页面文件，负责入口层展示与全局返回处理。
 */

import common from '@ohos.app.ability.common'
import { hilog } from '@kit.PerformanceAnalysisKit'
import { TrainingType } from '../domain/static/train/TrainingRuntimeTypes'
import { goBack, goRootTab, reset } from '../router/Router'
import {
  buildHomePath,
  buildLoginSmsPath,
  buildProfilePath,
  buildProfileSecurityPath,
  buildTrainRootPath
} from '../router/RouteBuilders'
import { ApiDebugOverlay } from '../components/debug/ApiDebugOverlay'
import { AppBottomBar } from './layout/AppBottomBar'
import { AppRouteViewport } from './layout/AppRouteViewport'
import { ensureMinimumDuration } from '../utils/AuthTools'
import { GlobalToast } from '../components/GlobalToast'
import { initializeAppOnLaunch } from '../services/app/index'
import { showGlobalToast } from '../services/ui/index'
import { ENABLE_API_DEBUG_OVERLAY } from '../config/AppConfig'
import { createEmptyTrainSessionRuntime, TrainSessionRuntime } from '../repository/train-session/TrainSessionRepository'
import { getRouteBasePath, isTabPath } from '../router/RouteMatcher'
import { APP_COLORS } from '../config/AppStyle'
import {
  COURSE_DETAIL_BASE_PATH,
  HOME_PATH,
  PROFILE_ABOUT_PATH,
  PROFILE_ACCOUNT_PATH,
  PROFILE_FEEDBACK_PATH,
  PROFILE_FAVORITES_PATH,
  PROFILE_PASSWORD_PATH,
  PROFILE_SECURITY_PATH,
  TRAIN_SESSION_BASE_PATH
} from '../router/RoutePaths'
import { TrainPageService } from '../services/training/index'

class LaunchAuthInitResult {
  isLoggedIn: boolean = false
  message: string = ''
}

const LAUNCH_TRACE_DOMAIN = 0x0
const LAUNCH_TRACE_TAG = 'LaunchRouteTrace'

@Entry
@Component
struct Index {
  @StorageLink('route.path') routePath: string = '/launch'
  @StorageLink('auth.isLoggedIn') isLoggedIn: boolean = false
  @StorageLink('train.session.runtime') trainRuntime: TrainSessionRuntime = createEmptyTrainSessionRuntime()

  private readonly launchMinimumDurationMs: number = 3000
  private readonly launchAuthResolveTimeoutMs: number = 2500
  private readonly exitConfirmWindowMs: number = 2000
  private launchStartedAt: number = 0
  private lastBackPressedAt: number = 0

  aboutToAppear() {
    this.launchStartedAt = new Date().getTime()
    void this.initializeAuthState()
  }

  onBackPress(): boolean {
    if (!this.isLoggedIn) {
      return false
    }

    const basePath = getRouteBasePath(this.routePath)
    if (basePath.startsWith(TRAIN_SESSION_BASE_PATH)) {
      const handled = goBack(buildTrainRootPath(this.getCurrentTrainingType()), true)
      if (handled) {
        TrainPageService.clearExitStateLater()
      }
      return handled
    }

    if (goBack()) {
      return true
    }

    if (basePath === PROFILE_PASSWORD_PATH) {
      return goBack(buildProfileSecurityPath())
    }

    if (this.isProfileSubRoute(basePath)) {
      return goBack(buildProfilePath())
    }

    if (basePath.startsWith(`${COURSE_DETAIL_BASE_PATH}/`)) {
      return goBack(buildTrainRootPath(this.getCurrentTrainingType()), true)
    }

    if (isTabPath(this.routePath) && basePath !== HOME_PATH) {
      goRootTab(buildHomePath())
      this.showExitToast()
      return true
    }

    const now = new Date().getTime()
    if (now - this.lastBackPressedAt < this.exitConfirmWindowMs) {
      this.lastBackPressedAt = 0
      return false
    }
    this.lastBackPressedAt = now
    this.showExitToast()
    return true
  }

  private isProfileSubRoute(path: string): boolean {
    return path === PROFILE_FAVORITES_PATH
      || path === PROFILE_ACCOUNT_PATH
      || path === PROFILE_SECURITY_PATH
      || path === PROFILE_FEEDBACK_PATH
      || path === PROFILE_ABOUT_PATH
  }

  private getCurrentTrainingType(): TrainingType {
    return this.trainRuntime.trainingType === 'speech' ? 'speech' : 'gesture'
  }

  private showExitToast(): void {
    showGlobalToast('再滑一次退出应用。', 'hint')
  }

  private async initializeAuthState() {
    hilog.info(LAUNCH_TRACE_DOMAIN, LAUNCH_TRACE_TAG, 'initializeAuthState.start route=%{public}s', this.routePath)
    let nextPath = buildLoginSmsPath()
    let bootstrapMessage: string = ''
    try {
      const result = await Promise.race([
        initializeAppOnLaunch(this.getAbilityContext()),
        new Promise<LaunchAuthInitResult>((resolve) => {
          setTimeout(() => {
            const timeoutResult = new LaunchAuthInitResult()
            timeoutResult.isLoggedIn = false
            timeoutResult.message = '启动初始化超时，已进入登录页。'
            resolve(timeoutResult)
          }, this.launchAuthResolveTimeoutMs)
        })
      ])
      nextPath = result.isLoggedIn ? buildHomePath() : buildLoginSmsPath()
      bootstrapMessage = !result.isLoggedIn && result.message.length > 0 ? result.message : ''
      hilog.info(LAUNCH_TRACE_DOMAIN, LAUNCH_TRACE_TAG,
        'initializeAuthState.resolved isLoggedIn=%{public}s nextPath=%{public}s message=%{public}s',
        String(result.isLoggedIn), nextPath, bootstrapMessage)
    } catch (_error) {
      nextPath = buildLoginSmsPath()
      bootstrapMessage = '启动初始化失败，已进入登录页。'
      hilog.info(LAUNCH_TRACE_DOMAIN, LAUNCH_TRACE_TAG,
        'initializeAuthState.error fallback nextPath=%{public}s', nextPath)
    }
    await ensureMinimumDuration(this.launchStartedAt, this.launchMinimumDurationMs)
    hilog.info(LAUNCH_TRACE_DOMAIN, LAUNCH_TRACE_TAG,
      'initializeAuthState.beforeReset currentRoute=%{public}s nextPath=%{public}s', this.routePath, nextPath)
    reset(nextPath)
    hilog.info(LAUNCH_TRACE_DOMAIN, LAUNCH_TRACE_TAG,
      'initializeAuthState.afterReset currentRoute=%{public}s nextPath=%{public}s', this.routePath, nextPath)
    if (bootstrapMessage.length > 0) {
      showGlobalToast(bootstrapMessage, 'error', 2200)
    }
  }

  private getAbilityContext(): common.BaseContext {
    return this.getUIContext().getHostContext() as common.BaseContext
  }

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      Column() {
        AppRouteViewport()
          .layoutWeight(1)
          .width('100%')

        AppBottomBar()
          .width('100%')
          .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
      }
      .width('100%')
      .height('100%')
      .backgroundColor(APP_COLORS.backgroundStart)

      GlobalToast()

      if (ENABLE_API_DEBUG_OVERLAY) {
        ApiDebugOverlay()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(APP_COLORS.backgroundStart)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }
}
