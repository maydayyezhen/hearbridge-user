/**
 * 用户资料媒体上传本地服务，负责资料图片资源规范化与按需上传。
 */
import common from '@ohos.app.ability.common'
import { uploadBinaryFile } from '../../../api/requests/FileUploadApi'
import { readUploadPayload } from '../../shared/local/FileResourceLocalService'
import { getRetryLaterMessage } from '../../../utils/FeedbackCopy'

/**
 * 规范用户资料图片地址。
 */
export function normalizeProfileImageUri(uri: string): string {
  return uri.split('#')[0].split('?')[0]
}

/**
 * 从资源地址推导上传文件名。
 */
export function getProfileImageFileName(uri: string, fallbackName: string): string {
  const cleanUri = normalizeProfileImageUri(uri)
  const lastSlash = cleanUri.lastIndexOf('/')
  return lastSlash >= 0 && lastSlash < cleanUri.length - 1 ? cleanUri.substring(lastSlash + 1) : fallbackName
}

/**
 * 判断资料图片资源是否已为远程地址。
 */
export function isRemoteProfileResource(uri: string): boolean {
  return uri.indexOf('http://') === 0 || uri.indexOf('https://') === 0
}

/**
 * 按需上传资料图片并返回远程地址。
 */
export async function uploadProfileImageIfNeeded(
  context: common.UIAbilityContext,
  uri: string,
  fallbackName: string
): Promise<string> {
  const trimmed = uri.trim()
  if (trimmed.length === 0) return ''
  if (isRemoteProfileResource(trimmed)) return trimmed
  const fileName = getProfileImageFileName(trimmed, fallbackName)
  const fileBytes = await readUploadPayload(context, trimmed, 'image/jpeg')
  if (fileBytes.byteLength <= 0) {
    throw new Error(getRetryLaterMessage('上传图片'))
  }
  const uploadResult = await uploadBinaryFile(fileName, fileBytes)
  if (!uploadResult.ok || !uploadResult.data) {
    throw new Error(uploadResult.message.length > 0 ? uploadResult.message : getRetryLaterMessage('上传图片'))
  }
  return uploadResult.data
}
