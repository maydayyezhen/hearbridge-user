/**
 * 用户状态本地服务，负责把后端返回的用户资料解析为当前前端用户状态。
 */

import common from '@ohos.app.ability.common'
import { User, createUser } from '../../../domain/entity/User'
import {
  readPersistedUserAccountProfile,
  readUserState,
  savePersistedUserAccountProfile,
  writeUserState
} from '../../../repository/user/UserRepository'
import { mapUserStateFromApiData, UserProfileApiData } from '../mapper/UserStateMapper'

function writeMergedUserState(data: UserProfileApiData): User {
  const next = mapUserStateFromApiData(data, readUserState())
  writeUserState(next)
  return next
}

/**
 * 根据后端返回数据构造完整用户状态。
 * @param data 后端用户资料对象。
 * @returns 规范后的用户状态对象。
 */
export function buildUserStateFromApiData(data: UserProfileApiData): User {
  return mapUserStateFromApiData(data, createUser())
}

/**
 * 根据后端返回数据在当前用户状态上做合并更新。
 * @param data 后端用户资料对象。
 * @returns 规范后的用户状态对象。
 */
export function mergeUserStateFromApiData(data: UserProfileApiData): User {
  return mapUserStateFromApiData(data, readUserState())
}

/**
 * 从持久化资料恢复用户账号字段。
 */
export async function hydrateUserAccountProfileFromPersistence(context: common.BaseContext): Promise<void> {
  const persisted = await readPersistedUserAccountProfile(context)
  if (!persisted.saved) return

  const next = readUserState()
  next.nickname = persisted.nickname
  next.avatarUrl = persisted.avatarUrl
  next.coverUrl = persisted.coverUrl
  next.gender = persisted.gender
  next.birthday = persisted.birthday
  next.signature = persisted.signature
  writeUserState(next)
}

/**
 * 将后端返回的用户资料应用到当前用户状态。
 * @param data 后端用户资料对象。
 */
export function applyUserInfoState(data: UserProfileApiData): void {
  writeMergedUserState(data)
}

/**
 * 将后端返回的用户资料应用到当前用户状态并持久化账号资料字段。
 */
export async function applyUserInfoStateWithPersistence(context: common.BaseContext, data: UserProfileApiData): Promise<void> {
  const nextUser = writeMergedUserState(data)
  await savePersistedUserAccountProfile(context, nextUser)
}
