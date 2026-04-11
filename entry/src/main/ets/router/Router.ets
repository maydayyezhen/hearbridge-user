/**
 * Router 文件，负责路由状态与基础跳转能力。
 */

import { LAUNCH_PATH } from './RoutePaths'
import { hilog } from '@kit.PerformanceAnalysisKit'
import { AppRoutePath } from './RouteTypes'
import { getRouteBasePath } from './RouteMatcher'
import { HOME_PATH, PROFILE_PATH, RECORD_PATH, TRAIN_PATH } from './RoutePaths'

/** RouteState。 */
export interface RouteState {
  path: string
}

const ROUTE_PATH_KEY = 'route.path'
const ROUTE_HISTORY_KEY = 'route.history'
const ROUTE_TRANSITION_DIRECTION_KEY = 'route.transition.direction'
const ROUTE_OVERLAY_ACTIVE_KEY = 'route.overlay.active'
const LAUNCH_TRACE_DOMAIN = 0x0
const LAUNCH_TRACE_TAG = 'LaunchRouteTrace'

function normalizeHistory(value: AppRoutePath[] | undefined): AppRoutePath[] {
  if (value === undefined) {
    return []
  }
  const next: AppRoutePath[] = []
  for (let index = 0; index < value.length; index += 1) {
    const item = value[index]
    if (item.length > 0) {
      next.push(item)
    }
  }
  return next
}

function writeTransitionDirection(direction: number): void {
  AppStorage.setOrCreate(ROUTE_TRANSITION_DIRECTION_KEY, direction)
}

function readRouteHistory(): AppRoutePath[] {
  return normalizeHistory(AppStorage.get(ROUTE_HISTORY_KEY) as AppRoutePath[] | undefined)
}

function writeRouteHistory(history: AppRoutePath[]): AppRoutePath[] {
  const next = normalizeHistory(history)
  AppStorage.setOrCreate(ROUTE_HISTORY_KEY, next)
  return next
}

function writePath(path: AppRoutePath): void {
  hilog.info(LAUNCH_TRACE_DOMAIN, LAUNCH_TRACE_TAG, 'Router.writePath %{public}s', path)
  writeRouteState({ path })
}

function getRootTabIndex(path: AppRoutePath): number {
  const basePath = getRouteBasePath(path)
  if (basePath === TRAIN_PATH) return 1
  if (basePath === RECORD_PATH) return 2
  if (basePath === PROFILE_PATH) return 3
  return 0
}

function isRootTabPath(path: AppRoutePath): boolean {
  const basePath = getRouteBasePath(path)
  return basePath === HOME_PATH || basePath === TRAIN_PATH || basePath === RECORD_PATH || basePath === PROFILE_PATH
}

function pushRouteHistory(path: AppRoutePath): void {
  if (path.length === 0) {
    return
  }
  const history = readRouteHistory()
  const lastPath = history.length > 0 ? history[history.length - 1] : ''
  if (lastPath === path) {
    return
  }
  history.push(path)
  writeRouteHistory(history)
}

/** createRouteState。 */
export function createRouteState(): RouteState {
  return { path: LAUNCH_PATH }
}

/** initRouter。 */
export function initRouter(): void {
  AppStorage.setOrCreate(ROUTE_PATH_KEY, LAUNCH_PATH)
  AppStorage.setOrCreate(ROUTE_HISTORY_KEY, [])
  AppStorage.setOrCreate(ROUTE_TRANSITION_DIRECTION_KEY, 0)
  AppStorage.setOrCreate(ROUTE_OVERLAY_ACTIVE_KEY, false)
}

/** readRouteState。 */
export function readRouteState(): RouteState {
  const path = (AppStorage.get(ROUTE_PATH_KEY) as string | undefined) ?? LAUNCH_PATH
  return { path }
}

/** writeRouteState。 */
export function writeRouteState(state: RouteState): RouteState {
  AppStorage.setOrCreate(ROUTE_PATH_KEY, state.path)
  return state
}

export function clearHistory(): void {
  writeRouteHistory([])
}

export function canGoBack(): boolean {
  return readRouteHistory().length > 0
}

export function replace(path: AppRoutePath): void {
  writeTransitionDirection(0)
  writePath(path)
}

export function reset(path: AppRoutePath): void {
  clearHistory()
  writeTransitionDirection(0)
  writePath(path)
}

/** go。 */
export function go(path: AppRoutePath): void {
  const currentPath = readRouteState().path
  if (currentPath === path) {
    return
  }
  pushRouteHistory(currentPath)
  writeTransitionDirection(1)
  writePath(path)
}

export function goRootTab(path: AppRoutePath): void {
  const currentPath = readRouteState().path
  clearHistory()
  if (currentPath === path) {
    writeTransitionDirection(0)
    writePath(path)
    return
  }
  if (isRootTabPath(currentPath) && isRootTabPath(path)) {
    const direction = getRootTabIndex(path) > getRootTabIndex(currentPath) ? 1 : -1
    writeTransitionDirection(direction)
  } else {
    writeTransitionDirection(0)
  }
  writePath(path)
}

export function goBack(fallbackPath?: AppRoutePath, resetOnFallback: boolean = false): boolean {
  const history = readRouteHistory()
  const currentPath = readRouteState().path
  while (history.length > 0) {
    const previousPath = history.pop() ?? ''
    if (previousPath.length === 0 || previousPath === currentPath) {
      continue
    }
    writeRouteHistory(history)
    writeTransitionDirection(-1)
    writePath(previousPath)
    return true
  }
  writeRouteHistory(history)
  if (fallbackPath === undefined || fallbackPath.length === 0 || fallbackPath === currentPath) {
    return false
  }
  if (resetOnFallback) {
    clearHistory()
  }
  writeTransitionDirection(-1)
  writePath(fallbackPath)
  return true
}
