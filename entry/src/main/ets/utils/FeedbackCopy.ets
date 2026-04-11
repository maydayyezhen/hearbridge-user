/**
 * FeedbackCopy 工具文件，负责通用辅助处理逻辑。
 */

export function getReloginRequiredMessage(): string {
  return '登录状态已失效，请重新登录。'
}

/** getRetryLaterMessage。 */
export function getRetryLaterMessage(action: string): string {
  return `${action}没有完成，请稍后再试。`
}

/** getNetworkRetryMessage。 */
export function getNetworkRetryMessage(action: string): string {
  return `网络连接不太稳定，${action}没有完成，请稍后再试。`
}

/** getPendingMessage。 */
export function getPendingMessage(action: string): string {
  return `正在${action}，请稍候...`
}

/** getSuccessToastMessage。 */
export function getSuccessToastMessage(action: string): string {
  return `${action}已完成。`
}
