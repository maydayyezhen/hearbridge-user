/**
 * ProfileImageCacheRepository 文件，负责头像/头图持久化缓存状态与访问转接。
 */

import common from '@ohos.app.ability.common'
import {
  ProfileImagePersistedState,
  ProfileImageSlot,
  clearPersistedProfileImageState,
  createEmptyProfileImagePersistedState,
  isProfileImageFilePathAvailable,
  readPersistedProfileImageState,
  savePersistedProfileImageState,
  toProfileImageFileUri,
  writeProfileImageBinaryToPath
} from '../../persistence/ProfileImageCachePersistence'

export type { ProfileImageSlot }

interface ProfileImageRuntimeState {
  hydrated: boolean
  avatarRemoteUrl: string
  avatarLocalPath: string
  coverRemoteUrl: string
  coverLocalPath: string
}

const PROFILE_IMAGE_RUNTIME_STATE: ProfileImageRuntimeState = {
  hydrated: false,
  avatarRemoteUrl: '',
  avatarLocalPath: '',
  coverRemoteUrl: '',
  coverLocalPath: ''
}

/**
 * 初始化头像/头图缓存仓储依赖。
 */
export function initProfileImageCacheRepository(): void {
  PROFILE_IMAGE_RUNTIME_STATE.hydrated = false
  PROFILE_IMAGE_RUNTIME_STATE.avatarRemoteUrl = ''
  PROFILE_IMAGE_RUNTIME_STATE.avatarLocalPath = ''
  PROFILE_IMAGE_RUNTIME_STATE.coverRemoteUrl = ''
  PROFILE_IMAGE_RUNTIME_STATE.coverLocalPath = ''
}

/**
 * 清理头像/头图缓存运行时状态。
 */
export function clearProfileImageCacheRuntimeState(): void {
  PROFILE_IMAGE_RUNTIME_STATE.hydrated = false
  PROFILE_IMAGE_RUNTIME_STATE.avatarRemoteUrl = ''
  PROFILE_IMAGE_RUNTIME_STATE.avatarLocalPath = ''
  PROFILE_IMAGE_RUNTIME_STATE.coverRemoteUrl = ''
  PROFILE_IMAGE_RUNTIME_STATE.coverLocalPath = ''
}

/**
 * 应用持久化状态到运行时。
 */
function applyPersistedStateToRuntime(state: ProfileImagePersistedState): void {
  PROFILE_IMAGE_RUNTIME_STATE.avatarRemoteUrl = state.avatarRemoteUrl
  PROFILE_IMAGE_RUNTIME_STATE.avatarLocalPath = state.avatarLocalPath
  PROFILE_IMAGE_RUNTIME_STATE.coverRemoteUrl = state.coverRemoteUrl
  PROFILE_IMAGE_RUNTIME_STATE.coverLocalPath = state.coverLocalPath
  PROFILE_IMAGE_RUNTIME_STATE.hydrated = true
}

/**
 * 从持久化状态预热头像/头图缓存。
 */
export async function hydrateProfileImageCacheFromPersistence(context: common.BaseContext): Promise<void> {
  if (PROFILE_IMAGE_RUNTIME_STATE.hydrated) return
  const persisted = await readPersistedProfileImageState(context)
  applyPersistedStateToRuntime(persisted)
}

/**
 * 构建当前运行时对应的持久化状态。
 */
function buildPersistedStateFromRuntime(): ProfileImagePersistedState {
  const state: ProfileImagePersistedState = {
    avatarRemoteUrl: PROFILE_IMAGE_RUNTIME_STATE.avatarRemoteUrl,
    avatarLocalPath: PROFILE_IMAGE_RUNTIME_STATE.avatarLocalPath,
    coverRemoteUrl: PROFILE_IMAGE_RUNTIME_STATE.coverRemoteUrl,
    coverLocalPath: PROFILE_IMAGE_RUNTIME_STATE.coverLocalPath
  }
  return state
}

/**
 * 更新单个槽位缓存映射。
 */
export async function bindProfileImageSlotLocalPath(
  context: common.BaseContext,
  slot: ProfileImageSlot,
  remoteUrl: string,
  localPath: string
): Promise<void> {
  if (slot === 'avatar') {
    PROFILE_IMAGE_RUNTIME_STATE.avatarRemoteUrl = remoteUrl
    PROFILE_IMAGE_RUNTIME_STATE.avatarLocalPath = localPath
  } else {
    PROFILE_IMAGE_RUNTIME_STATE.coverRemoteUrl = remoteUrl
    PROFILE_IMAGE_RUNTIME_STATE.coverLocalPath = localPath
  }
  PROFILE_IMAGE_RUNTIME_STATE.hydrated = true
  await savePersistedProfileImageState(context, buildPersistedStateFromRuntime())
}

/**
 * 判断槽位缓存是否已命中指定远端 URL。
 */
export function isProfileImageSlotCached(slot: ProfileImageSlot, remoteUrl: string): boolean {
  if (remoteUrl.length === 0 || !PROFILE_IMAGE_RUNTIME_STATE.hydrated) return false
  if (slot === 'avatar') {
    return PROFILE_IMAGE_RUNTIME_STATE.avatarRemoteUrl === remoteUrl
      && isProfileImageFilePathAvailable(PROFILE_IMAGE_RUNTIME_STATE.avatarLocalPath)
  }
  return PROFILE_IMAGE_RUNTIME_STATE.coverRemoteUrl === remoteUrl
    && isProfileImageFilePathAvailable(PROFILE_IMAGE_RUNTIME_STATE.coverLocalPath)
}

/**
 * 写入头像/头图缓存文件。
 */
export function writeProfileImageBinaryToSlot(context: common.BaseContext, slot: ProfileImageSlot, imageData: ArrayBuffer): string {
  return writeProfileImageBinaryToPath(context, slot, imageData)
}

/**
 * 根据远端 URL 解析头像显示地址。
 */
export function resolveProfileAvatarDisplayUri(remoteUrl: string): string {
  return resolveSlotDisplayUri('avatar', remoteUrl)
}

/**
 * 根据远端 URL 解析头图显示地址。
 */
export function resolveProfileCoverDisplayUri(remoteUrl: string): string {
  return resolveSlotDisplayUri('cover', remoteUrl)
}

/**
 * 解析槽位显示地址。
 */
function resolveSlotDisplayUri(slot: ProfileImageSlot, remoteUrl: string): string {
  if (remoteUrl.length === 0 || !PROFILE_IMAGE_RUNTIME_STATE.hydrated) return remoteUrl

  if (slot === 'avatar') {
    if (PROFILE_IMAGE_RUNTIME_STATE.avatarRemoteUrl !== remoteUrl) return remoteUrl
    if (!isProfileImageFilePathAvailable(PROFILE_IMAGE_RUNTIME_STATE.avatarLocalPath)) return remoteUrl
    return toProfileImageFileUri(PROFILE_IMAGE_RUNTIME_STATE.avatarLocalPath)
  }

  if (PROFILE_IMAGE_RUNTIME_STATE.coverRemoteUrl !== remoteUrl) return remoteUrl
  if (!isProfileImageFilePathAvailable(PROFILE_IMAGE_RUNTIME_STATE.coverLocalPath)) return remoteUrl
  return toProfileImageFileUri(PROFILE_IMAGE_RUNTIME_STATE.coverLocalPath)
}

/**
 * 清理头像/头图持久化缓存状态。
 */
export async function clearPersistedProfileImageCache(context: common.BaseContext): Promise<void> {
  await clearPersistedProfileImageState(context)
  applyPersistedStateToRuntime(createEmptyProfileImagePersistedState())
}
