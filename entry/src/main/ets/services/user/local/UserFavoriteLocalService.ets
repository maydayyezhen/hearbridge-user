/**
 * 用户收藏本地服务，负责收藏切换后的纯业务结果整理。
 */
import { User } from '../../../domain/entity/User'
import { TrainingType } from '../../../domain/static/train/TrainingRuntimeTypes'
import {
  toggleCourseFavorite,
  toggleTrainingItemFavorite
} from '../api/UserFavoriteApiService'
import { getFavoriteCourseCodes, hasFavoriteCourse, hasFavoriteItem, readUserState } from '../../../repository/user/UserRepository'

/**
 * 收藏切换动作结果。
 */
export class FavoriteToggleActionResult {
  ok: boolean = false
  message: string = ''
  tone: 'success' | 'error' | 'info' = 'info'
  favorited: boolean = false
}

/**
 * 切换课程收藏状态，并返回由页面层自行承接的反馈语义。
 * @param context Ability 上下文。
 * @param courseCode 课程编码。
 * @returns 收藏切换动作结果。
 */
export async function toggleCourseFavoriteAction(
  courseCode: string,
  courseName: string = '',
  trainingType?: TrainingType
): Promise<FavoriteToggleActionResult> {
  const output = new FavoriteToggleActionResult()
  const result = await toggleCourseFavorite(courseCode, courseName, trainingType)
  const favorited = hasFavoriteCourse(readUserState(), courseCode)
  output.ok = result.ok
  output.favorited = favorited
  output.tone = result.ok ? 'success' : 'error'
  output.message = result.message.length > 0
    ? result.message
    : (result.ok ? (favorited ? '已收藏课程。' : '已取消收藏课程。') : '课程收藏操作失败。')
  return output
}

/**
 * 切换训练项收藏状态，并返回由页面层自行承接的反馈语义。
 * @param context Ability 上下文。
 * @param itemCode 训练项编码。
 * @returns 收藏切换动作结果。
 */
export async function toggleTrainingItemFavoriteAction(
  itemCode: string,
  itemName: string = '',
  courseCode: string = '',
  courseName: string = '',
  trainingType?: TrainingType
): Promise<FavoriteToggleActionResult> {
  const output = new FavoriteToggleActionResult()
  const result = await toggleTrainingItemFavorite(itemCode, itemName, courseCode, courseName, trainingType)
  const favorited = hasFavoriteItem(readUserState(), itemCode)
  output.ok = result.ok
  output.favorited = favorited
  output.tone = result.ok ? 'success' : 'error'
  output.message = result.message.length > 0
    ? result.message
    : (result.ok ? (favorited ? '已收藏训练项。' : '已取消收藏训练项。') : '训练项收藏操作失败。')
  return output
}


/**
 * 从当前用户状态提取已收藏课程编码列表，供页面层读取。
 */
export function readFavoriteCourseCodesFromUser(user: User): string[] {
  return getFavoriteCourseCodes(user)
}

/**
 * 判断当前用户是否已收藏指定课程，供页面层读取。
 */
export function isCourseFavoritedInUser(user: User, courseCode: string): boolean {
  return hasFavoriteCourse(user, courseCode)
}

export function isTrainingItemFavoritedInUser(user: User, itemCode: string): boolean {
  return itemCode.length > 0 && hasFavoriteItem(user, itemCode)
}
