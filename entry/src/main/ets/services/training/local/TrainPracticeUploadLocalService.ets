/**
 * 训练练习提交本地服务，负责录音/录像文件校验、上传前处理与媒体类型判断。
 */
import common from '@ohos.app.ability.common'
import { fileIo as fs } from '@kit.CoreFileKit'
import { TrainingType } from '../../../domain/static/train/TrainingRuntimeTypes'
import { TrainSessionRuntime } from '../../../repository/train-session/TrainSessionRepository'
import { readUploadPayload } from '../../shared/local/FileResourceLocalService'
import { uploadPracticeBytes } from '../api/TrainSessionApiService'

/** 练习上传载荷。 */
export interface PracticeUploadPayload {
  submitType: string
  fileName: string
  mimeType: string
  fileBytes: ArrayBuffer
}

/**
 * 练习文件检查结果。
 */
export interface PracticeFileCheckResult {
  exists: boolean
  size: number
  message: string
}

/**
 * 检查练习文件是否有效。
 */
export async function checkPracticeFile(uri: string): Promise<PracticeFileCheckResult> {
  const normalizedUri = uri.trim()
  if (normalizedUri.length === 0) {
    return { exists: false, size: 0, message: '练习文件不存在，请重新录制后再试。' }
  }

  try {
    const file = await fs.open(normalizedUri, fs.OpenMode.READ_ONLY)
    const stat = await fs.stat(file.fd)
    await fs.close(file)
    return {
      exists: true,
      size: Number(stat.size ?? 0),
      message: Number(stat.size ?? 0) > 0 ? '' : '练习文件内容为空，请重新录制后再试。'
    }
  } catch (_error) {
    return { exists: false, size: 0, message: '练习文件不存在，请重新录制后再试。' }
  }
}

/**
 * 根据训练类型和录制模式推断媒体类型。
 */
export function getMimeTypeForPractice(fileName: string, trainingType: TrainingType, useAudioMode: boolean): string {
  const normalizedName = fileName.trim().toLowerCase()
  if (useAudioMode && trainingType === 'speech') {
    if (normalizedName.endsWith('.wav')) return 'audio/wav'
    if (normalizedName.endsWith('.pcm')) return 'audio/L16'
    if (normalizedName.endsWith('.m4a')) return 'audio/mp4'
    if (normalizedName.endsWith('.aac')) return 'audio/aac'
    return 'audio/wav'
  }
  if (normalizedName.endsWith('.mp4')) return 'video/mp4'
  if (normalizedName.endsWith('.mov')) return 'video/quicktime'
  return 'video/mp4'
}

/** 从 URI 推断上传文件名。 */
function resolveUploadFileName(fileUri: string, useAudioMode: boolean): string {
  const normalized = fileUri.trim()
  const slashIndex = Math.max(normalized.lastIndexOf('/'), normalized.lastIndexOf('\\'))
  const name = slashIndex >= 0 ? normalized.slice(slashIndex + 1) : normalized
  if (name.length > 0) return name
  return useAudioMode ? 'practice.wav' : 'practice.mp4'
}

/** 构建练习上传载荷。 */
export async function resolvePracticeUploadPayload(
  context: common.BaseContext,
  runtime: TrainSessionRuntime,
  fileUri: string,
  useAudioMode: boolean
): Promise<PracticeUploadPayload> {
  const fileName = resolveUploadFileName(fileUri, useAudioMode)
  const mimeType = getMimeTypeForPractice(fileName, runtime.trainingType, useAudioMode)
  const fileBytes = await readUploadPayload(context as common.UIAbilityContext, fileUri, mimeType)
  return {
    submitType: useAudioMode ? 'audio' : 'video',
    fileName,
    mimeType,
    fileBytes
  }
}

/** 上传练习资源并返回远端可访问地址。 */
export async function uploadPracticeResource(payload: PracticeUploadPayload): Promise<string> {
  if (payload.fileBytes.byteLength <= 0) return ''
  return await uploadPracticeBytes(payload.fileName, payload.fileBytes)
}
