/**
 * ProfileImageCachePersistence 文件，负责头像/头图本地持久化缓存的底层读写。
 */

import common from '@ohos.app.ability.common'
import fileIo from '@ohos.file.fs'
import preferences from '@ohos.data.preferences'

export type ProfileImageSlot = 'avatar' | 'cover'

/**
 * 头像/头图缓存持久化状态。
 */
export interface ProfileImagePersistedState {
  avatarRemoteUrl: string
  avatarLocalPath: string
  coverRemoteUrl: string
  coverLocalPath: string
}

const PROFILE_IMAGE_STORE_NAME: string = 'profile_image_cache_store'
const PROFILE_IMAGE_DIR_NAME: string = 'profile_image_cache'

const AVATAR_REMOTE_URL_KEY: string = 'avatarRemoteUrl'
const AVATAR_LOCAL_PATH_KEY: string = 'avatarLocalPath'
const COVER_REMOTE_URL_KEY: string = 'coverRemoteUrl'
const COVER_LOCAL_PATH_KEY: string = 'coverLocalPath'

interface FilesDirCarrier {
  filesDir?: string
}

/**
 * 创建空白持久化状态。
 */
export function createEmptyProfileImagePersistedState(): ProfileImagePersistedState {
  const emptyState: ProfileImagePersistedState = {
    avatarRemoteUrl: '',
    avatarLocalPath: '',
    coverRemoteUrl: '',
    coverLocalPath: ''
  }
  return emptyState
}

/**
 * 读取头像/头图缓存持久化状态。
 */
export async function readPersistedProfileImageState(context: common.BaseContext): Promise<ProfileImagePersistedState> {
  try {
    const store = await preferences.getPreferences(context, PROFILE_IMAGE_STORE_NAME)
    const avatarRemoteValue = await store.get(AVATAR_REMOTE_URL_KEY, '')
    const avatarLocalValue = await store.get(AVATAR_LOCAL_PATH_KEY, '')
    const coverRemoteValue = await store.get(COVER_REMOTE_URL_KEY, '')
    const coverLocalValue = await store.get(COVER_LOCAL_PATH_KEY, '')

    const state: ProfileImagePersistedState = {
      avatarRemoteUrl: typeof avatarRemoteValue === 'string' ? avatarRemoteValue : '',
      avatarLocalPath: typeof avatarLocalValue === 'string' ? avatarLocalValue : '',
      coverRemoteUrl: typeof coverRemoteValue === 'string' ? coverRemoteValue : '',
      coverLocalPath: typeof coverLocalValue === 'string' ? coverLocalValue : ''
    }
    return state
  } catch (_error) {
    return createEmptyProfileImagePersistedState()
  }
}

/**
 * 写入头像/头图缓存持久化状态。
 */
export async function savePersistedProfileImageState(context: common.BaseContext, state: ProfileImagePersistedState): Promise<void> {
  try {
    const store = await preferences.getPreferences(context, PROFILE_IMAGE_STORE_NAME)
    await store.put(AVATAR_REMOTE_URL_KEY, state.avatarRemoteUrl)
    await store.put(AVATAR_LOCAL_PATH_KEY, state.avatarLocalPath)
    await store.put(COVER_REMOTE_URL_KEY, state.coverRemoteUrl)
    await store.put(COVER_LOCAL_PATH_KEY, state.coverLocalPath)
    await store.flush()
  } catch (_error) {
    return
  }
}

/**
 * 清理头像/头图缓存持久化状态。
 */
export async function clearPersistedProfileImageState(context: common.BaseContext): Promise<void> {
  try {
    const store = await preferences.getPreferences(context, PROFILE_IMAGE_STORE_NAME)
    await store.put(AVATAR_REMOTE_URL_KEY, '')
    await store.put(AVATAR_LOCAL_PATH_KEY, '')
    await store.put(COVER_REMOTE_URL_KEY, '')
    await store.put(COVER_LOCAL_PATH_KEY, '')
    await store.flush()
  } catch (_error) {
    return
  }
}

/**
 * 将本地文件路径转换为图片可渲染 URI。
 */
export function toProfileImageFileUri(filePath: string): string {
  if (filePath.length === 0) return ''
  return filePath.indexOf('file://') === 0 ? filePath : `file://${filePath}`
}

/**
 * 规范化 file:// URI 到文件路径。
 */
export function normalizeProfileImageFilePath(pathOrUri: string): string {
  const prefix = 'file://'
  if (pathOrUri.indexOf(prefix) === 0) {
    return pathOrUri.substring(prefix.length)
  }
  return pathOrUri
}

/**
 * 判断图片缓存文件路径是否可读。
 */
export function isProfileImageFilePathAvailable(pathOrUri: string): boolean {
  const filePath = normalizeProfileImageFilePath(pathOrUri)
  if (filePath.length === 0) return false

  let file: fileIo.File | null = null
  try {
    file = fileIo.openSync(filePath, fileIo.OpenMode.READ_ONLY)
    return true
  } catch (_error) {
    return false
  } finally {
    if (file !== null) {
      try {
        fileIo.closeSync(file)
      } catch (_error) {
      }
    }
  }
}

/**
 * 构建缓存目录路径。
 */
function buildProfileImageCacheDirPath(context: common.BaseContext): string {
  const carrier = context as FilesDirCarrier
  const filesDir = typeof carrier.filesDir === 'string' ? carrier.filesDir : ''
  if (filesDir.length === 0) return ''
  return filesDir.endsWith('/') ? `${filesDir}${PROFILE_IMAGE_DIR_NAME}` : `${filesDir}/${PROFILE_IMAGE_DIR_NAME}`
}

/**
 * 构建缓存文件名。
 */
function buildSlotFileName(slot: ProfileImageSlot): string {
  return slot === 'avatar' ? 'avatar.img' : 'cover.img'
}

/**
 * 拼接路径。
 */
function joinPath(dirPath: string, fileName: string): string {
  if (dirPath.endsWith('/')) return `${dirPath}${fileName}`
  return `${dirPath}/${fileName}`
}

/**
 * 确保缓存目录存在。
 */
function ensureProfileImageCacheDir(dirPath: string): void {
  if (dirPath.length === 0) return
  try {
    fileIo.mkdirSync(dirPath)
  } catch (_error) {
  }
}

/**
 * 将图片字节写入本地缓存文件。
 */
export function writeProfileImageBinaryToPath(context: common.BaseContext, slot: ProfileImageSlot, imageData: ArrayBuffer): string {
  if (imageData.byteLength <= 0) return ''

  const dirPath = buildProfileImageCacheDirPath(context)
  if (dirPath.length === 0) return ''
  ensureProfileImageCacheDir(dirPath)

  const filePath = joinPath(dirPath, buildSlotFileName(slot))
  let file: fileIo.File | null = null
  try {
    const mode = fileIo.OpenMode.CREATE | fileIo.OpenMode.TRUNC | fileIo.OpenMode.WRITE_ONLY
    file = fileIo.openSync(filePath, mode)
    fileIo.writeSync(file.fd, imageData)
    return filePath
  } catch (_error) {
    return ''
  } finally {
    if (file !== null) {
      try {
        fileIo.closeSync(file)
      } catch (_error) {
      }
    }
  }
}
