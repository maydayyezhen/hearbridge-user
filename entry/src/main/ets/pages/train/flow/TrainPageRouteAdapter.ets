/**
 * TrainPageRouteAdapter 文件，负责把训练页 routePath 解析为结构化业务输入。
 */
import { getRouteParam } from '../../../router/RouteMatcher'
import { createTrainSessionRouteInput, normalizeTrainStage, TrainSessionRouteInput, TrainStage } from '../../../services/training/index'

/**
 * 构造训练页路由输入。
 */
export function buildTrainPageRouteInput(routePath: string, stage?: TrainStage): TrainSessionRouteInput {
  const courseCode = getRouteParam(routePath, 'courseCode')
  const itemCode = getRouteParam(routePath, 'itemCode')
  const routeStage = normalizeTrainStage(getRouteParam(routePath, 'stage'))
  return createTrainSessionRouteInput(courseCode, itemCode, stage && stage.length > 0 ? stage : routeStage)
}
