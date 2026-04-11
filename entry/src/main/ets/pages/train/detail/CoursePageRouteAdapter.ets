/**
 * CoursePageRouteAdapter 文件，负责把课程详情页 routePath 解析为结构化输入。
 * 课程详情加载链路起点：只做 route -> courseCode 的纯解析，不混入业务逻辑。
 */
import { getRouteParam } from '../../../router/RouteMatcher'

/**
 * 获取课程详情页课程编码。
 */
export function getCoursePageRouteCode(routePath: string): string {
  return getRouteParam(routePath, 'courseCode')
}
