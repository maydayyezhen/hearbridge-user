/**
 * 用户资料保存本地服务，负责登录态检查、本地图片预处理与资料状态回写。
 */
import common from '@ohos.app.ability.common'
import { readPersistedAuthToken } from '../../../repository/auth/AuthRepository'
import { getReloginRequiredMessage, getRetryLaterMessage, getSuccessToastMessage } from '../../../utils/FeedbackCopy'
import { applyUserInfoStateWithPersistence } from './UserStateLocalService'
import { UserActionResult } from '../api/UserActionResult'
import { uploadProfileImageIfNeeded } from './ProfileMediaUploadLocalService'
import { submitUserProfileUpdate, UserProfileSavePayload } from '../api/UserProfileSaveApiService'
import { refreshProfileImageCacheWithUrls } from './ProfileImageCacheLocalService'

interface ProfileUrls {
  avatarUrl: string
  coverUrl: string
}

class ProfileUrlsBox implements ProfileUrls {
  avatarUrl: string = ''
  coverUrl: string = ''
}

/**
 * 统一执行资料保存。
 */
async function saveUserProfileInternal(
  context: common.UIAbilityContext,
  successActionName: string,
  retryActionName: string,
  nickname: string,
  gender: string,
  birthday: string,
  signature: string,
  resolveProfileUrls: () => Promise<ProfileUrls>
): Promise<UserActionResult> {
  const output = new UserActionResult()
  let token = ''
  try {
    token = await readPersistedAuthToken(context)
  } catch (_error) {
    output.message = getRetryLaterMessage('读取登录状态')
    output.tone = 'error'
    return output
  }
  if (token.length === 0) {
    output.message = getReloginRequiredMessage()
    output.tone = 'error'
    return output
  }

  let profileUrls: ProfileUrls
  try {
    profileUrls = await resolveProfileUrls()
  } catch (_error) {
    output.message = getRetryLaterMessage(retryActionName)
    output.tone = 'error'
    return output
  }

  const payload: UserProfileSavePayload = {
    nickname,
    gender,
    birthday,
    signature,
    avatarUrl: profileUrls.avatarUrl,
    coverUrl: profileUrls.coverUrl
  }
  const result = await submitUserProfileUpdate(payload)
  if (!result.ok || !result.data) {
    output.message = result.message.length > 0 ? result.message : getRetryLaterMessage(retryActionName)
    output.tone = 'error'
    return output
  }

  await applyUserInfoStateWithPersistence(context, result.data)
  void refreshProfileImageCacheWithUrls(context, profileUrls.avatarUrl, profileUrls.coverUrl)
  output.ok = true
  output.message = getSuccessToastMessage(successActionName)
  output.tone = 'success'
  output.data = result.data
  return output
}

/**
 * 保存头像相关资料。
 */
export async function saveAvatarProfile(
  context: common.UIAbilityContext,
  nickname: string,
  gender: string,
  birthday: string,
  signature: string,
  avatarUrl: string,
  coverUrl: string
): Promise<UserActionResult> {
  return await saveUserProfileInternal(
    context,
    '头像保存',
    '保存头像',
    nickname,
    gender,
    birthday,
    signature,
    async () => {
      const urls = new ProfileUrlsBox()
      urls.avatarUrl = await uploadProfileImageIfNeeded(context, avatarUrl, 'avatar.jpg')
      urls.coverUrl = coverUrl
      return urls
    }
  )
}

/**
 * 保存封面相关资料。
 */
export async function saveCoverProfile(
  context: common.UIAbilityContext,
  nickname: string,
  gender: string,
  birthday: string,
  signature: string,
  avatarUrl: string,
  coverUrl: string
): Promise<UserActionResult> {
  return await saveUserProfileInternal(
    context,
    '头图保存',
    '保存头图',
    nickname,
    gender,
    birthday,
    signature,
    async () => {
      const urls = new ProfileUrlsBox()
      urls.avatarUrl = avatarUrl
      urls.coverUrl = await uploadProfileImageIfNeeded(context, coverUrl, 'cover.jpg')
      return urls
    }
  )
}

/**
 * 保存用户资料。
 */
export async function saveUserProfile(
  context: common.UIAbilityContext,
  nickname: string,
  gender: string,
  birthday: string,
  signature: string,
  avatarUrl: string,
  coverUrl: string
): Promise<UserActionResult> {
  return await saveUserProfileInternal(
    context,
    '资料保存',
    '保存资料',
    nickname,
    gender,
    birthday,
    signature,
    async () => {
      const urls = new ProfileUrlsBox()
      urls.avatarUrl = avatarUrl
      urls.coverUrl = coverUrl
      return urls
    }
  )
}
