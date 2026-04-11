/**
 * 收藏页查询服务，负责把用户状态组装成页面直接可用的读模型。
 */

import { User } from '../../../domain/entity/User'
import { TrainingType } from '../../../domain/static/train/TrainingRuntimeTypes'
import { readFavoriteCourseCodesFromUser } from '../local/UserFavoriteLocalService'
import { getDisplayAvatarUrl, getDisplayNickname } from '../local/UserProfileLocalService'
import { FavoriteDisplayItem, FavoritePageHeaderView } from '../model/FavoriteDisplayItem'

/**
 * 获取训练类型展示文案。
 * @param trainingType 训练类型。
 * @returns 页面展示用类型文案。
 */
export function getTrainingTypeLabel(trainingType: TrainingType): string {
  return trainingType === 'speech' ? '口语训练' : '手势训练'
}

/**
 * 构造课程收藏副标题。
 * @param trainingType 训练类型。
 * @param courseCode 课程编码。
 * @returns 收藏页课程副标题。
 */
function buildCourseSubtitle(trainingType: TrainingType, courseCode: string): string {
  const typeLabel = getTrainingTypeLabel(trainingType)
  return courseCode.length > 0 ? `${typeLabel} · ${courseCode}` : typeLabel
}

/**
 * 组装收藏页头部展示数据。
 * @param user 当前用户状态。
 * @returns 收藏页头部读模型。
 */
export function getFavoritePageHeaderView(user: User): FavoritePageHeaderView {
  return {
    avatarUrl: getDisplayAvatarUrl(user),
    nickname: getDisplayNickname(user),
    favoriteCourseCount: readFavoriteCourseCodesFromUser(user).length
  }
}

/**
 * 组装课程收藏列表项。
 * @param user 当前用户状态。
 * @returns 页面直接渲染的课程收藏读模型。
 */
export function getFavoriteCourseDisplayItems(user: User): FavoriteDisplayItem[] {
  const items: FavoriteDisplayItem[] = []
  for (let index = 0; index < user.favoriteCourses.length; index += 1) {
    const course = user.favoriteCourses[index]
    items.push({
      id: course.code.length > 0 ? course.code : `favorite-course-${index}`,
      itemCode: '',
      title: course.name.length > 0 ? course.name : '课程',
      subtitle: buildCourseSubtitle(course.trainingType, course.code),
      courseCode: course.code,
      courseName: course.name.length > 0 ? course.name : '',
      trainingType: course.trainingType,
      phrase: '',
      kind: 'course'
    })
  }
  return items
}

/**
 * 组装训练项收藏列表项。
 * @param user 当前用户状态。
 * @returns 页面直接渲染的训练项收藏读模型。
 */
export function getFavoriteTrainingItemDisplayItems(user: User): FavoriteDisplayItem[] {
  const items: FavoriteDisplayItem[] = []
  for (let index = 0; index < user.favoriteItems.length; index += 1) {
    const item = user.favoriteItems[index]
    items.push({
      id: item.code.length > 0 ? item.code : `favorite-item-${index}`,
      itemCode: item.code,
      title: item.name,
      subtitle: `${getTrainingTypeLabel(item.trainingType)} · ${item.courseName}`,
      courseCode: item.courseCode,
      courseName: item.courseName,
      trainingType: item.trainingType,
      phrase: item.name,
      kind: 'item'
    })
  }
  return items
}

/**
 * 解析收藏训练项可用的课程编码。
 */
export function resolveFavoriteItemCourseCode(user: User, itemCode: string, preferredCourseCode: string): string {
  if (preferredCourseCode.length > 0 && preferredCourseCode !== itemCode) {
    return preferredCourseCode
  }

  for (let index = 0; index < user.favoriteItems.length; index += 1) {
    const current = user.favoriteItems[index]
    if (current.code !== itemCode) continue
    if (current.courseCode.length > 0 && current.courseCode !== itemCode) {
      return current.courseCode
    }
  }

  return preferredCourseCode
}
