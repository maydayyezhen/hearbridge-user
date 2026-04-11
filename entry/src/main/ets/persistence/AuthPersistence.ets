/**
 * AuthPersistence 文件，负责持久化读写能力。
 */

import preferences from '@ohos.data.preferences'
import common from '@ohos.app.ability.common'

/** 认证持久化存储名称。 */
const AUTH_STORE_NAME: string = 'auth_store'
/** 持久化 token 的键名。 */
const AUTH_TOKEN_KEY: string = 'token'

/**
 * 读取本地持久化 token。
 * @param context 应用上下文。
 * @returns 本地持久化 token。
 */
export async function readPersistedAuthTokenValue(context: common.BaseContext): Promise<string> {
  try {
    const store = await preferences.getPreferences(context, AUTH_STORE_NAME)
    const value = await store.get(AUTH_TOKEN_KEY, '')
    return typeof value === 'string' ? value : ''
  } catch (_error) {
    return ''
  }
}

/**
 * 写入本地持久化 token。
 * @param context 应用上下文。
 * @param token 当前登录 token。
 */
export async function savePersistedAuthTokenValue(context: common.BaseContext, token: string): Promise<void> {
  try {
    const store = await preferences.getPreferences(context, AUTH_STORE_NAME)
    await store.put(AUTH_TOKEN_KEY, token)
    await store.flush()
  } catch (_error) {
    return
  }
}

/**
 * 清除本地持久化 token。
 * @param context 应用上下文。
 */
export async function clearPersistedAuthTokenValue(context: common.BaseContext): Promise<void> {
  try {
    const store = await preferences.getPreferences(context, AUTH_STORE_NAME)
    await store.delete(AUTH_TOKEN_KEY)
    await store.flush()
  } catch (_error) {
    return
  }
}
