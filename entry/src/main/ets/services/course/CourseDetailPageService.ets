/**
 * 课程详情页服务出口，供页面层统一使用课程详情相关能力。
 * 课程详情加载链路中的“页面门面层”：页面只调用这里，不直接依赖 api/repository。
 */
import { TrainingType } from '../../domain/static/train/TrainingRuntimeTypes'
import { TrainingContentItem } from '../../domain/static/train/TrainingContentModels'
import { buildTrainRootPath, buildTrainSessionPath } from '../../router/RouteBuilders'
import { FavoriteToggleActionResult, toggleCourseFavoriteAction } from '../user/index'
import { normalizeTrainingType } from '../../utils/TrainingTypeUtil'
import { loadCourseDetailPageData, readCachedCourseDetailView } from './api/CourseDetailApiService'
import { CourseDetailPageData } from './model/CourseDetailPageData'

// 对页面暴露两个核心入口：
// 1) readCachedCourseDetailView: 首屏缓存预热。
// 2) loadCourseDetailPageData: 完整加载链路（详情 + 会话 + 训练项）。
export { CourseDetailPageData, loadCourseDetailPageData, readCachedCourseDetailView }

export function getCourseDetailIntroText(displayCourseIntro: string): string {
  return displayCourseIntro.length > 0 ? displayCourseIntro : '本课程将带你逐步完成训练目标。'
}

export function getNextCourseTrainingItemCode(courseItems: TrainingContentItem[], completedItemIds: number[]): string {
  if (courseItems.length === 0) return ''
  for (let i = 0; i < courseItems.length; i += 1) {
    if (!completedItemIds.includes(courseItems[i].id)) return courseItems[i].code
  }
  return courseItems[courseItems.length - 1].code
}

export function canContinueCourseTraining(completedItemCount: number, currentItemIndex: number): boolean {
  return completedItemCount > 0 || currentItemIndex >= 0
}

export async function toggleCourseDetailFavorite(
  courseCode: string,
  courseName: string = '',
  trainingType?: TrainingType
): Promise<FavoriteToggleActionResult> {
  return await toggleCourseFavoriteAction(courseCode, courseName, trainingType)
}

export function buildCourseDetailBackPath(trainingType: TrainingType): string {
  return buildTrainRootPath(normalizeTrainingType(trainingType))
}

export function buildCourseTrainingPath(courseCode: string, itemCode: string): string {
  return buildTrainSessionPath(courseCode, itemCode, 'intro')
}
