/**
 * TrainRootRouteAdapter 文件，负责把训练列表页 routePath 解析为结构化输入。
 */
import { TrainingType } from '../../../domain/static/train/TrainingRuntimeTypes'
import { getRouteParam } from '../../../router/RouteMatcher'
import { normalizeTrainingType } from '../../../utils/TrainingTypeUtil'

/**
 * 获取训练列表页训练类型。
 */
export function getTrainRootTrainingType(routePath: string): TrainingType {
  return normalizeTrainingType(getRouteParam(routePath, 'trainingType'))
}
