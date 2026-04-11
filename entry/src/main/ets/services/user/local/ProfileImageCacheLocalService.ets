/**
 * 资料图片缓存本地服务，负责头像/头图缓存预热与持久化下载流程编排。
 */

import common from '@ohos.app.ability.common'
import { readUserState } from '../../../repository/user/UserRepository'
import {
  ProfileImageSlot,
  bindProfileImageSlotLocalPath,
  clearPersistedProfileImageCache,
  hydrateProfileImageCacheFromPersistence,
  isProfileImageSlotCached,
  writeProfileImageBinaryToSlot
} from '../../../repository/resource-cache/ProfileImageCacheRepository'
import { requestProfileImageBinary } from '../api/ProfileImageCacheApiService'

/** 缓存下载中标记。 */
const PROFILE_IMAGE_DOWNLOAD_INFLIGHT: Map<string, boolean> = new Map()

/**
 * 判断是否为可下载远端 URL。
 */
function isDownloadableRemoteUri(uri: string): boolean {
  return uri.indexOf('http://') === 0 || uri.indexOf('https://') === 0 || uri.indexOf('/') === 0
}

/**
 * 构建下载去重 key。
 */
function buildInflightKey(slot: ProfileImageSlot, remoteUrl: string): string {
  return `${slot}:${remoteUrl}`
}

/**
 * 保障单个槽位图片缓存可用。
 */
async function ensureProfileImageSlotCached(context: common.BaseContext, slot: ProfileImageSlot, remoteUrl: string): Promise<void> {
  if (!isDownloadableRemoteUri(remoteUrl)) return
  if (isProfileImageSlotCached(slot, remoteUrl)) return

  const inflightKey = buildInflightKey(slot, remoteUrl)
  if (PROFILE_IMAGE_DOWNLOAD_INFLIGHT.get(inflightKey) === true) return

  PROFILE_IMAGE_DOWNLOAD_INFLIGHT.set(inflightKey, true)
  try {
    const bytes = await requestProfileImageBinary(remoteUrl)
    if (bytes.byteLength <= 0) return

    const localPath = writeProfileImageBinaryToSlot(context, slot, bytes)
    if (localPath.length <= 0) return

    await bindProfileImageSlotLocalPath(context, slot, remoteUrl, localPath)
  } finally {
    PROFILE_IMAGE_DOWNLOAD_INFLIGHT.delete(inflightKey)
  }
}

/**
 * 预热资料图片持久化缓存状态。
 */
export async function hydrateProfileImageCache(context: common.BaseContext): Promise<void> {
  await hydrateProfileImageCacheFromPersistence(context)
}

/**
 * 按指定头像/头图 URL 刷新本地持久化缓存。
 */
export async function refreshProfileImageCacheWithUrls(context: common.BaseContext, avatarUrl: string, coverUrl: string): Promise<void> {
  await hydrateProfileImageCache(context)
  await ensureProfileImageSlotCached(context, 'avatar', avatarUrl)
  await ensureProfileImageSlotCached(context, 'cover', coverUrl)
}

/**
 * 按当前用户状态刷新本地持久化缓存。
 */
export async function refreshProfileImageCacheForCurrentUser(context: common.BaseContext): Promise<void> {
  const user = readUserState()
  await refreshProfileImageCacheWithUrls(context, user.avatarUrl, user.coverUrl)
}

/**
 * 清理资料图片持久化缓存。
 */
export async function clearPersistedProfileImages(context: common.BaseContext): Promise<void> {
  await clearPersistedProfileImageCache(context)
}
