/**
 * 用户训练进度本地服务，负责跨模块组合训练完成计数与用户统计回写。
 */
import { appendCompletedTrainItemCode } from '../../../repository/train-session/TrainSessionRepository'
import { readUserState, writeUserState } from '../../../repository/user/UserRepository'

/**
 * 在当前训练会话内首次完成训练项时，累计一次用户已完成训练项计数。
 * @param itemCode 训练项编码。
 */
export function applyCompletedTrainingItemProgress(itemCode: string): void {
  const recorded = appendCompletedTrainItemCode(itemCode)
  if (!recorded) return
  const current = readUserState()
  const nextUser = readUserState()
  nextUser.trainedQuestionCount = current.trainedQuestionCount + 1
  writeUserState(nextUser)
}
