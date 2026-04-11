/**
 * UserStateMapper 文件，负责用户资料接口到前端用户状态的映射。
 */

import { UserProfileApiData, FavoriteCourseSource, FavoriteTrainingItemSource, RecentUserCourseSource } from '../../../api/requests/AuthApi'
import { Course } from '../../../domain/entity/Course'
import { createUser, User } from '../../../domain/entity/User'
import { createUserTrainingItem, UserTrainingItem } from '../../../domain/entity/UserTrainingItem'
import { normalizeTrainingType, normalizeTrainItemStatus } from '../../../utils/TrainingTypeUtil'

export type { UserProfileApiData } from '../../../api/requests/AuthApi'

/**
 * 映射收藏课程。
 */
export function mapFavoriteCourses(input: FavoriteCourseSource[]): Course[] {
  const output: Course[] = []
  for (let i = 0; i < input.length; i += 1) {
    const course = new Course()
    course.code = input[i].courseCode ?? ''
    course.name = input[i].courseName ?? ''
    course.trainingType = normalizeTrainingType(input[i].trainingType ?? '')
    course.status = 1
    course.favorite = true
    output.push(course)
  }
  return output
}

/**
 * 映射收藏训练项。
 */
export function mapFavoriteItems(input: FavoriteTrainingItemSource[]): UserTrainingItem[] {
  const output: UserTrainingItem[] = []
  for (let i = 0; i < input.length; i += 1) {
    const item = createUserTrainingItem()
    item.id = Number(input[i].itemId ?? 0)
    item.code = input[i].itemCode ?? ''
    item.name = input[i].itemName ?? ''
    item.courseCode = input[i].courseCode ?? ''
    item.courseName = input[i].courseName ?? ''
    item.trainingType = normalizeTrainingType(input[i].trainingType ?? '')
    item.status = normalizeTrainItemStatus('')
    item.favorite = true
    output.push(item)
  }
  return output
}

/**
 * 映射最近学习课程。
 */
export function mapRecentCourses(list: RecentUserCourseSource[]): Course[] {
  const output: Course[] = []
  for (let i = 0; i < list.length; i += 1) {
    const item = list[i]
    const course = new Course()
    course.code = item.courseCode ?? ''
    course.name = item.courseName ?? ''
    course.coverUrl = item.coverUrl ?? ''
    course.trainingType = normalizeTrainingType(item.trainingType ?? '')
    course.status = 1
    course.progressPercent = Number(item.progressPercent ?? 0)
    course.lastLearnedAt = item.lastLearnAt ?? ''
    course.currentItemCode = item.currentItemCode ?? ''
    course.currentItemName = item.currentItemName ?? ''
    course.favorite = false
    output.push(course)
  }
  return output
}

/**
 * 根据接口数据构造用户状态。
 */
export function mapUserStateFromApiData(data: UserProfileApiData, base: User): User {
  const next: User = createUser()
  next.id = base.id
  next.no = base.no
  next.username = base.username
  next.phone = base.phone
  next.status = base.status
  next.createdAt = base.createdAt
  next.lastLoginAt = base.lastLoginAt
  next.nickname = base.nickname
  next.avatarUrl = base.avatarUrl
  next.coverUrl = base.coverUrl
  next.gender = base.gender
  next.birthday = base.birthday
  next.signature = base.signature
  next.hasPassword = base.hasPassword
  next.phoneBound = base.phoneBound
  next.passwordUpdatedAt = base.passwordUpdatedAt
  next.companionDays = base.companionDays
  next.trainedQuestionCount = base.trainedQuestionCount
  next.trainingCount = base.trainingCount
  next.trainingMinutes = base.trainingMinutes
  next.lastTrainingAt = base.lastTrainingAt
  next.favoriteCourses = base.favoriteCourses
  next.favoriteItems = base.favoriteItems
  next.recentCourses = base.recentCourses

  if (data.identity?.id !== undefined) next.id = Number(data.identity.id)
  if (data.identity?.userNo !== undefined) next.no = data.identity.userNo ?? ''
  if (data.identity?.username !== undefined) next.username = data.identity.username ?? ''
  if (data.identity?.phone !== undefined) next.phone = data.identity.phone ?? ''
  if (data.identity?.status !== undefined) next.status = Number(data.identity.status)
  if (data.identity?.createdAt !== undefined) next.createdAt = data.identity.createdAt ?? ''
  if (data.identity?.lastLoginAt !== undefined) next.lastLoginAt = data.identity.lastLoginAt ?? ''

  if (data.profile?.nickname !== undefined) next.nickname = data.profile.nickname ?? ''
  if (data.profile?.avatarUrl !== undefined) next.avatarUrl = data.profile.avatarUrl ?? ''
  if (data.profile?.coverUrl !== undefined) next.coverUrl = data.profile.coverUrl ?? ''
  if (data.profile?.signature !== undefined) next.signature = data.profile.signature ?? ''
  if (data.profile?.gender !== undefined) next.gender = Number(data.profile.gender)
  if (data.profile?.birthday !== undefined) next.birthday = data.profile.birthday ?? ''

  if (data.security?.hasPassword !== undefined) next.hasPassword = Boolean(data.security.hasPassword)
  if (data.security?.phoneBound !== undefined) next.phoneBound = Boolean(data.security.phoneBound)
  if (data.security?.passwordUpdatedAt !== undefined) next.passwordUpdatedAt = data.security.passwordUpdatedAt ?? ''

  if (data.stats?.companionDays !== undefined) next.companionDays = Number(data.stats.companionDays)
  if (data.stats?.completedTrainingItemCount !== undefined) {
    next.trainedQuestionCount = Number(data.stats.completedTrainingItemCount)
  }
  if (data.stats?.inProgressTrainingItemCount !== undefined) {
    next.trainingCount = Number(data.stats.inProgressTrainingItemCount)
  }
  if (data.stats?.totalTrainingMinutes !== undefined) next.trainingMinutes = Number(data.stats.totalTrainingMinutes)
  if (data.stats?.lastTrainingAt !== undefined) next.lastTrainingAt = data.stats.lastTrainingAt ?? ''

  if (data.favorites?.favoriteCourses !== undefined) {
    next.favoriteCourses = mapFavoriteCourses(data.favorites.favoriteCourses ?? [])
  }
  if (data.favorites?.favoriteTrainingItems !== undefined) {
    next.favoriteItems = mapFavoriteItems(data.favorites.favoriteTrainingItems ?? [])
  }
  if (data.recentCourses !== undefined) {
    next.recentCourses = mapRecentCourses(data.recentCourses ?? [])
  }
  return next
}
