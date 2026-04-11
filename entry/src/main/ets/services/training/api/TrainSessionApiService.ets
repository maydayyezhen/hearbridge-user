/**
 * 训练 API 业务服务。
 *
 * 职责：
 * 1. 负责训练会话相关接口调用。
 * 2. 负责把文件提交、语音提交、上传地址解析这类接口语义收口在 API 层。
 * 3. 不负责本地文件读取、不负责页面流程切换，只处理接口交互本身。
 * 4. 课程详情加载链路通过 startTrainSession/fetchTrainSessionDetail 两个入口补齐会话动态数据。
 */
import { uploadBinaryFile } from '../../../api/requests/FileUploadApi'
import {
  completeTrainingSession,
  getTrainingSessionSummary,
  getTrainingItemDetail,
  getTrainingSessionDetail,
  pauseTrainingSession,
  startTrainingSession,
  submitTrainingItem
} from '../../../api/requests/TrainingApi'
import type {
  StartTrainingSessionResponseSource,
  SubmitTrainingItemResponseSource,
  TrainSummaryDimensionSource,
  TrainSummaryHighlightItemSource,
  TrainSummarySuggestionSource,
  TrainSummaryTrendSource,
  TrainSessionSummaryResponseSource,
  TrainingSessionDetailResponseSource
} from '../../../api/requests/TrainingApi'

export type {
  StartTrainingSessionResponseSource,
  SubmitTrainingItemResponseSource,
  TrainSummaryDimensionSource,
  TrainSummaryHighlightItemSource,
  TrainSummarySuggestionSource,
  TrainSummaryTrendSource,
  TrainSessionSummaryResponseSource,
  TrainingSessionDetailResponseSource
}

/**
 * 启动训练会话。
 * @param courseCode 课程编码。
 * @returns 训练会话启动结果。
 * 课程详情页在缺失会话缓存时，会先调用这里拿 sessionId。
 */
export async function startTrainSession(courseCode: string) {
  return await startTrainingSession(courseCode)
}

/**
 * 读取训练会话详情。
 * @param sessionId 训练会话 id。
 * @returns 训练会话详情结果。
 * 课程详情页会用这个结果回填 progress/completed/currentItem/items。
 */
export async function fetchTrainSessionDetail(sessionId: number) {
  return await getTrainingSessionDetail(sessionId)
}

/**
 * 读取单个训练项详情。
 * @param sessionId 训练会话 id。
 * @param itemCode 训练项编码。
 * @returns 训练项详情结果。
 */
export async function fetchTrainItemDetail(sessionId: number, itemCode: string) {
  return await getTrainingItemDetail(sessionId, itemCode)
}

/**
 * 暂停训练会话。
 * @param sessionId 训练会话 id。
 * @returns 暂停结果。
 */
export async function pauseTrainSession(sessionId: number) {
  return await pauseTrainingSession(sessionId)
}

/**
 * 完成训练会话。
 * @param sessionId 训练会话 id。
 * @returns 完成结果。
 */
export async function completeTrainSession(sessionId: number) {
  return await completeTrainingSession(sessionId)
}

export async function fetchTrainSessionSummary(sessionId: number) {
  return await getTrainingSessionSummary(sessionId)
}

/**
 * 上传练习文件字节并返回远程可访问地址。
 * @param fileName 文件名。
 * @param fileBytes 文件字节。
 * @returns 上传成功后的远程地址；失败时返回空字符串。
 */
export async function uploadPracticeBytes(fileName: string, fileBytes: ArrayBuffer): Promise<string> {
  if (fileBytes.byteLength <= 0) {
    return ''
  }
  const uploadResult = await uploadBinaryFile(fileName, fileBytes)
  if (!uploadResult.ok || !uploadResult.data) {
    return ''
  }
  return String(uploadResult.data ?? '')
}

/**
 * 提交文件型训练练习。
 * @param sessionId 训练会话 id。
 * @param itemCode 训练项编码。
 * @param submitType 提交类型，通常为 audio 或 video。
 * @param fileUrl 已上传文件地址。
 * @param fileName 文件名。
 * @param mimeType 文件 MIME 类型。
 * @param viewedDemo 是否已观看示范。
 * @param finished 是否本轮已完成。
 * @param retried 是否为重试。
 * @param firstSuccess 是否首次成功。
 * @returns 提交结果。
 */
export async function submitTrainFilePractice(
  sessionId: number,
  itemCode: string,
  submitType: string,
  fileUrl: string,
  fileName: string,
  mimeType: string,
  viewedDemo: boolean,
  finished: boolean,
  retried: boolean,
  firstSuccess: boolean
) {
  return await submitTrainingItem(
    sessionId,
    itemCode,
    submitType,
    fileUrl,
    fileName,
    mimeType,
    '',
    '',
    'success',
    viewedDemo,
    finished,
    retried,
    firstSuccess
  )
}

/**
 * 提交语音识别型训练练习。
 * @param sessionId 训练会话 id。
 * @param itemCode 训练项编码。
 * @param recognizedText 最终识别文本。
 * @param partialText 识别中的中间文本。
 * @param viewedDemo 是否已观看示范。
 * @param finished 是否本轮已完成。
 * @param retried 是否为重试。
 * @param firstSuccess 是否首次成功。
 * @returns 提交结果。
 */
export async function submitTrainSpeechPractice(
  sessionId: number,
  itemCode: string,
  recognizedText: string,
  partialText: string,
  viewedDemo: boolean,
  finished: boolean,
  retried: boolean,
  firstSuccess: boolean
) {
  return await submitTrainingItem(
    sessionId,
    itemCode,
    'audio',
    '',
    '',
    '',
    recognizedText,
    partialText,
    'success',
    viewedDemo,
    finished,
    retried,
    firstSuccess
  )
}
