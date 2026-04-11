/**
 * Route debug snapshot storage.
 */

export const ROUTE_DEBUG_TEXT_KEY = 'routeDebugText'

export function initRouteDebugStore(): void {
  AppStorage.setOrCreate(ROUTE_DEBUG_TEXT_KEY, '')
}

export function readRouteDebugText(): string {
  return (AppStorage.get(ROUTE_DEBUG_TEXT_KEY) as string | undefined) ?? ''
}

export function writeRouteDebugText(text: string): void {
  AppStorage.setOrCreate(ROUTE_DEBUG_TEXT_KEY, text)
}

export function clearRouteDebugText(): void {
  writeRouteDebugText('')
}
