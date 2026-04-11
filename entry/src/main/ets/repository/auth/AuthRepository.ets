/**
 * AuthRepository 文件，负责对应模块的仓储读写与状态转接。
 */

import common from '@ohos.app.ability.common'
import {
  clearPersistedAuthTokenValue,
  readPersistedAuthTokenValue,
  savePersistedAuthTokenValue
} from '../../persistence/AuthPersistence'
import { clearAuthState, getToken, initAuthStore, readLoggedIn, setLoggedIn, setToken } from '../../storage/auth/AuthStore'

/**
 * 初始化认证仓储依赖的 Store。
 */
export function initAuthRepository(): void {
  initAuthStore()
}

/**
 * 读取当前内存 token。
 * @returns 当前内存 token。
 */
export function readAuthToken(): string {
  return getToken()
}

/**
 * 写入当前内存 token。
 * @param token 当前登录 token。
 */
export function writeAuthToken(token: string): void {
  setToken(token)
}

/**
 * 读取当前登录标记。
 * @returns 当前是否已登录。
 */
export function readAuthLoggedIn(): boolean {
  return readLoggedIn()
}

/**
 * 写入当前登录标记。
 * @param loggedIn 当前是否已登录。
 */
export function writeAuthLoggedIn(loggedIn: boolean): void {
  setLoggedIn(loggedIn)
}

/**
 * 清空认证核心状态。
 */
export function clearAuthRepositoryState(): void {
  clearAuthState()
}

/**
 * 从持久化存储中读取登录 token。
 * @param context 应用上下文。
 * @returns 本地持久化 token。
 */
export async function readPersistedAuthToken(context: common.BaseContext): Promise<string> {
  return await readPersistedAuthTokenValue(context)
}

/**
 * 将登录 token 写入持久化存储。
 * @param context 应用上下文。
 * @param token 当前登录 token。
 */
export async function savePersistedAuthToken(context: common.BaseContext, token: string): Promise<void> {
  await savePersistedAuthTokenValue(context, token)
}

/**
 * 清除本地持久化 token。
 * @param context 应用上下文。
 */
export async function clearPersistedAuthToken(context: common.BaseContext): Promise<void> {
  await clearPersistedAuthTokenValue(context)
}

