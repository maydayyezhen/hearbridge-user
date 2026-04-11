/**
 * 用户资料保存 API 服务，只负责资料保存远端请求。
 */
import { updateUserProfile } from '../../../api/requests/AuthApi'

/**
 * 资料更新载荷。
 */
export interface UserProfileSavePayload {
  nickname: string
  gender: string
  birthday: string
  signature: string
  avatarUrl: string
  coverUrl: string
}

/**
 * 把性别文案转换为接口需要的编码。
 */
function resolveProfileGenderCode(profileGender: string): number {
  return profileGender === '男' ? 1 : profileGender === '女' ? 2 : 0
}

/**
 * 提交用户资料更新。
 */
export async function submitUserProfileUpdate(payload: UserProfileSavePayload) {
  return await updateUserProfile(
    payload.nickname.trim(),
    resolveProfileGenderCode(payload.gender),
    payload.birthday.length > 0 ? payload.birthday : null,
    payload.signature,
    payload.avatarUrl,
    payload.coverUrl
  )
}
