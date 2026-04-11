/**
 * UserStore 文件，负责对应模块的本地状态存取。
 */

import { createUser, User } from '../domain/entity/User'

/** 用户信息在 AppStorage 中的键。 */
export const USER_KEY = 'user'

/**
 * 初始化用户 Store 默认值。
 */
export function initUserStore(): void {
  AppStorage.setOrCreate(USER_KEY, createUser())
}

/**
 * 读取当前用户信息。
 * @returns 当前用户对象；若不存在则返回默认用户对象。
 */
export function readUser(): User {
  return (AppStorage.get(USER_KEY) as User | undefined) ?? createUser()
}

/**
 * 写入完整用户信息。
 * @param state 要写入的用户对象。
 * @returns 写入后的用户对象。
 */
export function writeUser(state: User): User {
  AppStorage.setOrCreate(USER_KEY, state)
  return state
}

/**
 * 以补丁方式更新用户信息。
 * @param patch 用户补丁对象。
 * @returns 更新后的用户对象。
 */
export function patchUser(patch: Partial<User>): User {
  const next = readUser()
  if (patch.id !== undefined) next.id = patch.id
  if (patch.no !== undefined) next.no = patch.no
  if (patch.username !== undefined) next.username = patch.username
  if (patch.phone !== undefined) next.phone = patch.phone
  if (patch.status !== undefined) next.status = patch.status
  if (patch.createdAt !== undefined) next.createdAt = patch.createdAt
  if (patch.lastLoginAt !== undefined) next.lastLoginAt = patch.lastLoginAt
  if (patch.nickname !== undefined) next.nickname = patch.nickname
  if (patch.avatarUrl !== undefined) next.avatarUrl = patch.avatarUrl
  if (patch.coverUrl !== undefined) next.coverUrl = patch.coverUrl
  if (patch.gender !== undefined) next.gender = patch.gender
  if (patch.birthday !== undefined) next.birthday = patch.birthday
  if (patch.signature !== undefined) next.signature = patch.signature
  if (patch.hasPassword !== undefined) next.hasPassword = patch.hasPassword
  if (patch.phoneBound !== undefined) next.phoneBound = patch.phoneBound
  if (patch.passwordUpdatedAt !== undefined) next.passwordUpdatedAt = patch.passwordUpdatedAt
  if (patch.companionDays !== undefined) next.companionDays = patch.companionDays
  if (patch.trainedQuestionCount !== undefined) next.trainedQuestionCount = patch.trainedQuestionCount
  if (patch.trainingCount !== undefined) next.trainingCount = patch.trainingCount
  if (patch.trainingMinutes !== undefined) next.trainingMinutes = patch.trainingMinutes
  if (patch.lastTrainingAt !== undefined) next.lastTrainingAt = patch.lastTrainingAt
  if (patch.favoriteCourses !== undefined) next.favoriteCourses = patch.favoriteCourses
  if (patch.favoriteItems !== undefined) next.favoriteItems = patch.favoriteItems
  if (patch.recentCourses !== undefined) next.recentCourses = patch.recentCourses
  return writeUser(next)
}

/**
 * 重置用户信息。
 */
export function resetUser(): void {
  AppStorage.setOrCreate(USER_KEY, createUser())
}
