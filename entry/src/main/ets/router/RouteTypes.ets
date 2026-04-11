/**
 * 路由基础类型定义。
 */

/** AppRoutePath。 */
export type AppRoutePath = string
/** RouteQueryValue。 */
export type RouteQueryValue = string | number | boolean | undefined | null

/** RouteItem。 */
export interface RouteItem {
  path: AppRoutePath
  render: () => void
}

/** TabItem。 */
export interface TabItem {
  path: AppRoutePath
  label: string
  icon: Resource
  selectedIcon: Resource
}
