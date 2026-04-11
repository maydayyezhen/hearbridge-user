/**
 * 路由渲染器，负责根据路径匹配具体页面并执行 render。
 */
import { AppRoutePath, RouteItem } from './RouteTypes'
import { ROUTES } from './RouteRegistry'
import { matchRoute } from './RouteMatcher'

export function hasRegisteredRoute(path: AppRoutePath): boolean {
  return matchRoute(path) !== null
}

export function getRegisteredRoute(path: AppRoutePath): RouteItem | null {
  const matchedPath = matchRoute(path)
  if (matchedPath === null) return null
  for (let i = 0; i < ROUTES.length; i += 1) {
    if (ROUTES[i].path === matchedPath) {
      return ROUTES[i]
    }
  }
  return null
}
