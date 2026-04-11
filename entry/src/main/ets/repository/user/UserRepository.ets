/**
 * UserRepository 文件，负责用户状态的基础读写与只读事实查询。
 */

import common from '@ohos.app.ability.common'
import { User } from '../../domain/entity/User'
import { initUserStore, readUser, resetUser, writeUser } from '../../storage/UserStore'
import {
  PersistedUserAccountProfile,
  clearPersistedUserAccountProfileValue,
  createEmptyPersistedUserAccountProfile,
  readPersistedUserAccountProfileValue,
  savePersistedUserAccountProfileValue
} from '../../persistence/UserProfilePersistence'

export type { PersistedUserAccountProfile }

function createPersistedUserAccountProfile(user: User): PersistedUserAccountProfile {
  const profile = createEmptyPersistedUserAccountProfile()
  profile.saved = true
  profile.nickname = user.nickname
  profile.avatarUrl = user.avatarUrl
  profile.coverUrl = user.coverUrl
  profile.gender = user.gender
  profile.birthday = user.birthday
  profile.signature = user.signature
  return profile
}

/**
 * 初始化用户仓储依赖的本地状态。
 */
export function initUserRepository(): void {
  initUserStore()
}

/**
 * 写入完整用户状态。
 */
export function writeUserState(user: User): User {
  return writeUser(user)
}

/**
 * 读取当前用户状态。
 */
export function readUserState(): User {
  return readUser()
}

/**
 * 重置当前用户状态。
 */
export function resetUserState(): void {
  resetUser()
}

/**
 * 读取持久化用户账号资料字段。
 */
export async function readPersistedUserAccountProfile(context: common.BaseContext): Promise<PersistedUserAccountProfile> {
  return await readPersistedUserAccountProfileValue(context)
}

/**
 * 持久化用户账号资料字段。
 */
export async function savePersistedUserAccountProfile(context: common.BaseContext, user: User): Promise<void> {
  await savePersistedUserAccountProfileValue(context, createPersistedUserAccountProfile(user))
}

/**
 * 清理持久化用户账号资料字段。
 */
export async function clearPersistedUserAccountProfile(context: common.BaseContext): Promise<void> {
  await clearPersistedUserAccountProfileValue(context)
}

/**
 * 获取用户当前已收藏课程编码列表。
 */
export function getFavoriteCourseCodes(user: User): string[] {
  const codes: string[] = []
  for (let i = 0; i < user.favoriteCourses.length; i += 1) {
    if (user.favoriteCourses[i].code.length > 0) {
      codes.push(user.favoriteCourses[i].code)
    }
  }
  return codes
}

/**
 * 判断用户是否已收藏指定课程。
 */
export function hasFavoriteCourse(user: User, courseCode: string): boolean {
  for (let i = 0; i < user.favoriteCourses.length; i += 1) {
    if (user.favoriteCourses[i].code === courseCode) return true
  }
  return false
}

/**
 * 判断用户是否已收藏指定训练项。
 */
export function hasFavoriteItem(user: User, itemCode: string): boolean {
  for (let i = 0; i < user.favoriteItems.length; i += 1) {
    if (user.favoriteItems[i].code === itemCode) return true
  }
  return false
}
