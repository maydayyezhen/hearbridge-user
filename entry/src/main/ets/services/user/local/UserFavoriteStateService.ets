/**
 * 用户收藏状态本地服务，负责收藏集合替换与去重规则。
 */
import { Course } from '../../../domain/entity/Course'
import { createUser, User } from '../../../domain/entity/User'
import { UserTrainingItem, createUserTrainingItem } from '../../../domain/entity/UserTrainingItem'
import { TrainingType } from '../../../domain/static/train/TrainingRuntimeTypes'
import { patchCoursePreview } from '../../../repository/course/CoursePreviewRepository'
import { readUserState, writeUserState } from '../../../repository/user/UserRepository'

function cloneUserState(user: User): User {
  const next = createUser()
  next.id = user.id
  next.no = user.no
  next.username = user.username
  next.phone = user.phone
  next.status = user.status
  next.createdAt = user.createdAt
  next.lastLoginAt = user.lastLoginAt
  next.nickname = user.nickname
  next.avatarUrl = user.avatarUrl
  next.coverUrl = user.coverUrl
  next.gender = user.gender
  next.birthday = user.birthday
  next.signature = user.signature
  next.hasPassword = user.hasPassword
  next.phoneBound = user.phoneBound
  next.passwordUpdatedAt = user.passwordUpdatedAt
  next.companionDays = user.companionDays
  next.trainedQuestionCount = user.trainedQuestionCount
  next.trainingCount = user.trainingCount
  next.trainingMinutes = user.trainingMinutes
  next.lastTrainingAt = user.lastTrainingAt
  next.favoriteCourses = user.favoriteCourses.slice()
  next.favoriteItems = user.favoriteItems.slice()
  next.recentCourses = user.recentCourses.slice()
  return next
}

function applyCourseFavoriteInUser(user: User, favorited: boolean, nextItem: Course): User {
  const nextCourses: Course[] = []
  let found = false
  for (let i = 0; i < user.favoriteCourses.length; i += 1) {
    const current = user.favoriteCourses[i]
    if (current.code === nextItem.code) {
      found = true
      if (!favorited) continue
      nextCourses.push(nextItem)
      continue
    }
    nextCourses.push(current)
  }
  if (favorited && !found) nextCourses.unshift(nextItem)
  const nextUser = cloneUserState(user)
  nextUser.favoriteCourses = nextCourses
  return nextUser
}

function applyFavoriteItemInUser(user: User, favorited: boolean, nextItem: UserTrainingItem): User {
  const nextItems: UserTrainingItem[] = []
  let found = false
  for (let i = 0; i < user.favoriteItems.length; i += 1) {
    const current = user.favoriteItems[i]
    if (current.code === nextItem.code) {
      found = true
      if (!favorited) continue
      nextItems.push(nextItem)
      continue
    }
    nextItems.push(current)
  }
  if (favorited && !found) nextItems.unshift(nextItem)
  const nextUser = cloneUserState(user)
  nextUser.favoriteItems = nextItems
  return nextUser
}

export function applyCourseFavoriteState(courseCode: string, courseName: string, trainingType: TrainingType, favorited: boolean): void {
  const nextFavorite = new Course()
  nextFavorite.code = courseCode
  nextFavorite.name = courseName
  nextFavorite.trainingType = trainingType
  nextFavorite.status = 1
  nextFavorite.favorite = favorited
  writeUserState(applyCourseFavoriteInUser(readUserState(), favorited, nextFavorite))
}

export function applyTrainingItemFavoriteState(
  itemCode: string,
  itemName: string,
  courseCode: string,
  courseName: string,
  trainingType: TrainingType,
  favorited: boolean
): void {
  const nextItem: UserTrainingItem = createUserTrainingItem()
  nextItem.code = itemCode
  nextItem.name = itemName
  nextItem.courseCode = courseCode
  nextItem.courseName = courseName
  nextItem.trainingType = trainingType
  nextItem.favorite = favorited
  if (courseCode.length > 0 && courseName.length > 0) {
    patchCoursePreview(courseCode, {
      courseName,
      trainingType
    })
  }
  writeUserState(applyFavoriteItemInUser(readUserState(), favorited, nextItem))
}
