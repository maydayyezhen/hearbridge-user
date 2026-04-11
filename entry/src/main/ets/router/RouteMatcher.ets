/**
 * 路由匹配与参数解析能力。
 */
import { ROUTE_PATTERNS, ROOT_TAB_PATHS } from './RoutePatternRegistry'
import { AppRoutePath } from './RouteTypes'

interface MatchedRouteResult {
  path: AppRoutePath
  params: Record<string, string>
}

export function getRouteBasePath(path: AppRoutePath): AppRoutePath {
  const queryIndex = path.indexOf('?')
  return queryIndex >= 0 ? path.substring(0, queryIndex) : path
}

function splitRouteSegments(path: AppRoutePath): string[] {
  return getRouteBasePath(path).split('/').filter((segment: string) => segment.length > 0)
}

function isDynamicSegment(segment: string): boolean {
  return segment.length > 1 && segment[0] === ':'
}

function buildMatchedRouteResult(path: AppRoutePath, params: Record<string, string>): MatchedRouteResult {
  return { path, params }
}

function tryMatchRoute(path: AppRoutePath, routePath: AppRoutePath): MatchedRouteResult | null {
  const actualSegments = splitRouteSegments(path)
  const routeSegments = splitRouteSegments(routePath)
  if (actualSegments.length !== routeSegments.length) return null
  const params: Record<string, string> = {}
  for (let i = 0; i < routeSegments.length; i += 1) {
    const routeSegment = routeSegments[i]
    const actualSegment = actualSegments[i]
    if (isDynamicSegment(routeSegment)) {
      params[routeSegment.substring(1)] = decodeURIComponent(actualSegment)
      continue
    }
    if (routeSegment !== actualSegment) return null
  }
  return buildMatchedRouteResult(routePath, params)
}

function getRouteMatchScore(routePath: AppRoutePath): number {
  const routeSegments = splitRouteSegments(routePath)
  let score = routeSegments.length * 10
  for (let i = 0; i < routeSegments.length; i += 1) {
    score += isDynamicSegment(routeSegments[i]) ? 1 : 5
  }
  return score
}

function getRegisteredRoutePatterns(): AppRoutePath[] {
  return ROUTE_PATTERNS
}

export function parseRouteQuery(path: AppRoutePath): Record<string, string> {
  const queryIndex = path.indexOf('?')
  if (queryIndex < 0 || queryIndex >= path.length - 1) return {}
  const query = path.substring(queryIndex + 1)
  const result: Record<string, string> = {}
  const parts = query.split('&')
  for (let i = 0; i < parts.length; i += 1) {
    const segment = parts[i]
    if (segment.length === 0) continue
    const equalIndex = segment.indexOf('=')
    if (equalIndex < 0) {
      result[decodeURIComponent(segment)] = ''
      continue
    }
    const key = decodeURIComponent(segment.substring(0, equalIndex))
    const value = decodeURIComponent(segment.substring(equalIndex + 1))
    result[key] = value
  }
  return result
}

function matchRouteWithParams(path: AppRoutePath): MatchedRouteResult | null {
  let matched: MatchedRouteResult | null = null
  let matchedScore = -1
  const patterns = getRegisteredRoutePatterns()
  for (let i = 0; i < patterns.length; i += 1) {
    const result = tryMatchRoute(path, patterns[i])
    if (result === null) continue
    const score = getRouteMatchScore(patterns[i])
    if (score > matchedScore) {
      matched = result
      matchedScore = score
    }
  }
  return matched
}

export function getRouteParam(path: AppRoutePath, key: string): string {
  const queryParams = parseRouteQuery(path)
  if (queryParams[key] !== undefined) return queryParams[key] ?? ''
  const matched = matchRouteWithParams(path)
  if (matched === null) return ''
  return matched.params[key] ?? ''
}

export function matchRoute(path: AppRoutePath): AppRoutePath | null {
  const matched = matchRouteWithParams(path)
  return matched ? matched.path : null
}

export function isTabPath(path: AppRoutePath): boolean {
  const basePath = getRouteBasePath(path)
  for (let i = 0; i < ROOT_TAB_PATHS.length; i += 1) {
    if (ROOT_TAB_PATHS[i] === basePath) return true
  }
  return false
}
