/**
 * UserProfilePersistence 文件，负责用户账号资料字段的持久化读写。
 */

import preferences from '@ohos.data.preferences'
import common from '@ohos.app.ability.common'

/** 用户资料持久化存储名称。 */
const USER_PROFILE_STORE_NAME: string = 'user_profile_store'
/** 是否存在有效资料快照。 */
const USER_PROFILE_SAVED_KEY: string = 'saved'
/** 资料字段 key。 */
const USER_PROFILE_NICKNAME_KEY: string = 'nickname'
const USER_PROFILE_AVATAR_URL_KEY: string = 'avatarUrl'
const USER_PROFILE_COVER_URL_KEY: string = 'coverUrl'
const USER_PROFILE_GENDER_KEY: string = 'gender'
const USER_PROFILE_BIRTHDAY_KEY: string = 'birthday'
const USER_PROFILE_SIGNATURE_KEY: string = 'signature'

/**
 * 用户账号资料持久化结构。
 */
export interface PersistedUserAccountProfile {
  saved: boolean
  nickname: string
  avatarUrl: string
  coverUrl: string
  gender: number
  birthday: string
  signature: string
}

class PersistedUserAccountProfileBox implements PersistedUserAccountProfile {
  saved: boolean = false
  nickname: string = ''
  avatarUrl: string = ''
  coverUrl: string = ''
  gender: number = 0
  birthday: string = ''
  signature: string = ''
}

/**
 * 创建空白持久化资料。
 */
export function createEmptyPersistedUserAccountProfile(): PersistedUserAccountProfile {
  return new PersistedUserAccountProfileBox()
}

/**
 * 读取用户账号资料持久化值。
 */
export async function readPersistedUserAccountProfileValue(context: common.BaseContext): Promise<PersistedUserAccountProfile> {
  try {
    const store = await preferences.getPreferences(context, USER_PROFILE_STORE_NAME)
    const savedValue = await store.get(USER_PROFILE_SAVED_KEY, false)
    const nicknameValue = await store.get(USER_PROFILE_NICKNAME_KEY, '')
    const avatarUrlValue = await store.get(USER_PROFILE_AVATAR_URL_KEY, '')
    const coverUrlValue = await store.get(USER_PROFILE_COVER_URL_KEY, '')
    const genderValue = await store.get(USER_PROFILE_GENDER_KEY, 0)
    const birthdayValue = await store.get(USER_PROFILE_BIRTHDAY_KEY, '')
    const signatureValue = await store.get(USER_PROFILE_SIGNATURE_KEY, '')

    const profile = new PersistedUserAccountProfileBox()
    profile.saved = Boolean(savedValue)
    profile.nickname = typeof nicknameValue === 'string' ? nicknameValue : ''
    profile.avatarUrl = typeof avatarUrlValue === 'string' ? avatarUrlValue : ''
    profile.coverUrl = typeof coverUrlValue === 'string' ? coverUrlValue : ''
    profile.gender = Number(genderValue ?? 0)
    profile.birthday = typeof birthdayValue === 'string' ? birthdayValue : ''
    profile.signature = typeof signatureValue === 'string' ? signatureValue : ''
    return profile
  } catch (_error) {
    return createEmptyPersistedUserAccountProfile()
  }
}

/**
 * 写入用户账号资料持久化值。
 */
export async function savePersistedUserAccountProfileValue(
  context: common.BaseContext,
  profile: PersistedUserAccountProfile
): Promise<void> {
  try {
    const store = await preferences.getPreferences(context, USER_PROFILE_STORE_NAME)
    await store.put(USER_PROFILE_SAVED_KEY, profile.saved)
    await store.put(USER_PROFILE_NICKNAME_KEY, profile.nickname)
    await store.put(USER_PROFILE_AVATAR_URL_KEY, profile.avatarUrl)
    await store.put(USER_PROFILE_COVER_URL_KEY, profile.coverUrl)
    await store.put(USER_PROFILE_GENDER_KEY, profile.gender)
    await store.put(USER_PROFILE_BIRTHDAY_KEY, profile.birthday)
    await store.put(USER_PROFILE_SIGNATURE_KEY, profile.signature)
    await store.flush()
  } catch (_error) {
    return
  }
}

/**
 * 清理用户账号资料持久化值。
 */
export async function clearPersistedUserAccountProfileValue(context: common.BaseContext): Promise<void> {
  try {
    const store = await preferences.getPreferences(context, USER_PROFILE_STORE_NAME)
    await store.put(USER_PROFILE_SAVED_KEY, false)
    await store.put(USER_PROFILE_NICKNAME_KEY, '')
    await store.put(USER_PROFILE_AVATAR_URL_KEY, '')
    await store.put(USER_PROFILE_COVER_URL_KEY, '')
    await store.put(USER_PROFILE_GENDER_KEY, 0)
    await store.put(USER_PROFILE_BIRTHDAY_KEY, '')
    await store.put(USER_PROFILE_SIGNATURE_KEY, '')
    await store.flush()
  } catch (_error) {
    return
  }
}
