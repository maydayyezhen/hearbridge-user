/**
 * ToastRepository 文件，负责对应模块的仓储读写与状态转接。
 */

import {
  initToastStore,
  ToastTone,
  writeGlobalToastText,
  writeGlobalToastTone,
  writeGlobalToastVisible
} from '../../storage/ui/ToastStore'

export { ToastTone }

/**
 * 初始化 Toast 仓储依赖的本地状态。
 */
export function initToastRepository(): void {
  initToastStore()
}

/**
 * 写入全局 Toast 展示状态。
 * @param message 提示文案。
 * @param tone 提示语气。
 */
export function writeToastState(message: string, tone: ToastTone): void {
  writeGlobalToastText(message)
  writeGlobalToastTone(tone)
  writeGlobalToastVisible(true)
}

/**
 * 隐藏全局 Toast。
 */
export function hideToastState(): void {
  writeGlobalToastVisible(false)
}

/**
 * 清空全局 Toast 状态。
 */
export function clearToastState(): void {
  writeGlobalToastText('')
  writeGlobalToastTone('success')
  writeGlobalToastVisible(false)
}
