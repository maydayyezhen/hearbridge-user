/**
 * 全局 Toast 本地服务，负责 Toast 的显示、自动关闭与隐藏。
 */
import { hideToastState, initToastRepository, ToastTone, writeToastState } from '../../../repository/ui/ToastRepository'

let globalToastTimer: number = -1

/**
 * 初始化全局 Toast 服务。
 */
export function initToastService(): void {
  initToastRepository()
}

/**
 * 显示全局 Toast。
 */
export function showGlobalToast(message: string, tone: ToastTone = 'success', durationMs: number = 1800): void {
  writeToastState(message, tone)
  if (globalToastTimer >= 0) {
    clearTimeout(globalToastTimer)
  }
  globalToastTimer = setTimeout(() => {
    hideToastState()
    globalToastTimer = -1
  }, durationMs)
}

/**
 * 隐藏全局 Toast。
 */
export function hideGlobalToast(): void {
  hideToastState()
  if (globalToastTimer >= 0) {
    clearTimeout(globalToastTimer)
    globalToastTimer = -1
  }
}
