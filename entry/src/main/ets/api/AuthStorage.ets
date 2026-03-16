import preferences from '@ohos.data.preferences'
import common from '@ohos.app.ability.common'

const STORE_NAME: string = 'auth_store'
const TOKEN_KEY: string = 'token'

async function getStore(context: common.BaseContext): Promise<preferences.Preferences> {
  return preferences.getPreferences(context, STORE_NAME)
}

export async function saveToken(context: common.BaseContext, token: string): Promise<void> {
  const store = await getStore(context)
  await store.put(TOKEN_KEY, token)
  await store.flush()
}

export async function readToken(context: common.BaseContext): Promise<string> {
  const store = await getStore(context)
  const value = await store.get(TOKEN_KEY, '')
  return typeof value === 'string' ? value : ''
}

export async function clearToken(context: common.BaseContext): Promise<void> {
  const store = await getStore(context)
  await store.delete(TOKEN_KEY)
  await store.flush()
}
