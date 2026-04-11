import { DEFAULT_PROFILE_COVER_URL, DEFAULT_USER_AVATAR_URL } from '../../../config/AppConfig'
import { User } from '../../../domain/entity/User'
import { resolveProfileAvatarDisplayUri, resolveProfileCoverDisplayUri } from '../../../repository/resource-cache/ProfileImageCacheRepository'

/**
 * 用户资料本地服务，负责资料页展示用的纯本地派生结果。
 */

/**
 * 根据提示语气返回资料页提示颜色。
 */
export function getProfileTipColor(tone: string): string { return tone === 'success' ? '#2BA471' : tone === 'error' ? '#E5484D' : '#7A8CA7' }

/**
 * 获取用于展示的昵称。
 */
export function getDisplayNickname(user: User): string {
  return user.nickname.length > 0 ? user.nickname : '听桥用户'
}

/**
 * 获取用于展示的头像地址并预热内存缓存。
 */
export function resolveDisplayAvatarUrl(avatarUrl: string): string {
  const resolved = avatarUrl.length > 0 ? avatarUrl : DEFAULT_USER_AVATAR_URL
  return resolveProfileAvatarDisplayUri(resolved)
}

/**
 * 获取用于展示的头图地址并预热内存缓存。
 */
export function resolveDisplayCoverUrl(coverUrl: string): string {
  const resolved = coverUrl.length > 0 ? coverUrl : DEFAULT_PROFILE_COVER_URL
  return resolveProfileCoverDisplayUri(resolved)
}

/**
 * 获取用于展示的头像地址。
 */
export function getDisplayAvatarUrl(user: User): string {
  return resolveDisplayAvatarUrl(user.avatarUrl)
}

/**
 * 获取用于展示的主页封面地址。
 */
export function getDisplayCoverUrl(user: User): string {
  return resolveDisplayCoverUrl(user.coverUrl)
}
