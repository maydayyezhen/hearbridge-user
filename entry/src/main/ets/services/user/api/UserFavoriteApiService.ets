/**
 * 用户收藏 API 业务服务，负责调用收藏接口并回写本地收藏状态。
 */
import { addCourseFavorite, addTrainingItemFavorite, removeCourseFavorite, removeTrainingItemFavorite } from '../../../api/requests/FavoriteApi'
import { TrainingType } from '../../../domain/static/train/TrainingRuntimeTypes'
import { getCourseDetailCache } from '../../../repository/course/CourseDetailRepository'
import { getCoursePreview } from '../../../repository/course/CoursePreviewRepository'
import { getCurrentTrainSessionItem, readActiveTrainSession } from '../../../repository/train-session/TrainSessionRepository'
import { hasFavoriteCourse, hasFavoriteItem, readUserState } from '../../../repository/user/UserRepository'
import { applyCourseFavoriteState, applyTrainingItemFavoriteState } from '../local/UserFavoriteStateService'

interface CourseFavoriteInfo {
  courseName: string
  trainingType: TrainingType
}

interface FavoriteItemInfo {
  itemName: string
  courseCode: string
  courseName: string
  trainingType: TrainingType
}

class FavoriteToggleResult {
  ok: boolean = false
  message: string = ''
}

function resolveCourseFavoriteInfo(courseCode: string): CourseFavoriteInfo {
  const user = readUserState()
  for (let i = 0; i < user.favoriteCourses.length; i += 1) {
    const current = user.favoriteCourses[i]
    if (current.code === courseCode) {
      return {
        courseName: current.name.length > 0 ? current.name : '',
        trainingType: current.trainingType
      }
    }
  }
  const detail = getCourseDetailCache(courseCode)
  if (detail) {
    return {
      courseName: detail.courseName.length > 0 ? detail.courseName : '',
      trainingType: detail.trainingType
    }
  }
  const preview = getCoursePreview(courseCode)
  if (preview) {
    return {
      courseName: preview.courseName.length > 0 ? preview.courseName : '',
      trainingType: preview.trainingType
    }
  }
  return { courseName: '', trainingType: 'gesture' }
}

function resolveFavoriteItemInfo(itemCode: string): FavoriteItemInfo {
  const user = readUserState()
  for (let i = 0; i < user.favoriteItems.length; i += 1) {
    const current = user.favoriteItems[i]
    if (current.code === itemCode) {
      return {
        itemName: current.name.length > 0 ? current.name : itemCode,
        courseCode: current.courseCode,
        courseName: current.courseName.length > 0 ? current.courseName : '',
        trainingType: current.trainingType
      }
    }
  }
  const runtime = readActiveTrainSession()
  const currentItem = getCurrentTrainSessionItem(runtime)
  const courseInfo = resolveCourseFavoriteInfo(runtime.courseCode)
  return {
    itemName: currentItem.code === itemCode && currentItem.name.length > 0 ? currentItem.name : itemCode,
    courseCode: runtime.courseCode,
    courseName: courseInfo.courseName,
    trainingType: runtime.trainingType.length > 0 ? runtime.trainingType : courseInfo.trainingType
  }
}

export async function toggleCourseFavorite(
  courseCode: string,
  courseName: string = '',
  trainingType?: TrainingType
): Promise<FavoriteToggleResult> {
  const output = new FavoriteToggleResult()
  const favorited = hasFavoriteCourse(readUserState(), courseCode)
  const result = favorited ? await removeCourseFavorite(courseCode) : await addCourseFavorite(courseCode)
  if (!result.ok || !result.data?.success) {
    output.message = result.message.length > 0 ? result.message : '课程收藏操作失败。'
    return output
  }
  const courseInfo = resolveCourseFavoriteInfo(courseCode)
  applyCourseFavoriteState(
    courseCode,
    courseName.length > 0 ? courseName : courseInfo.courseName,
    trainingType ?? courseInfo.trainingType,
    !favorited
  )
  output.ok = true
  return output
}

export async function toggleTrainingItemFavorite(
  itemCode: string,
  itemName: string = '',
  courseCode: string = '',
  courseName: string = '',
  trainingType?: TrainingType
): Promise<FavoriteToggleResult> {
  const output = new FavoriteToggleResult()
  const favorited = hasFavoriteItem(readUserState(), itemCode)
  const result = favorited ? await removeTrainingItemFavorite(itemCode) : await addTrainingItemFavorite(itemCode)
  if (!result.ok || !result.data?.success) {
    output.message = result.message.length > 0 ? result.message : '训练项收藏操作失败。'
    return output
  }
  const itemInfo = resolveFavoriteItemInfo(itemCode)
  applyTrainingItemFavoriteState(
    itemCode,
    itemName.length > 0 ? itemName : itemInfo.itemName,
    courseCode.length > 0 ? courseCode : itemInfo.courseCode,
    courseName.length > 0 ? courseName : itemInfo.courseName,
    trainingType ?? itemInfo.trainingType,
    !favorited
  )
  output.ok = true
  return output
}
