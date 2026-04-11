/**
 * 全局 Toast 状态存储。
 *
 * 说明：
 * 1. 这里只维护全局 Toast 的基础状态读写。
 * 2. 显示/隐藏、定时关闭、覆盖策略等流程逻辑统一交给 service 层处理。
 */

/**
 * 全局 Toast 提示语气类型。
 */
export type ToastTone = 'success' | 'error' | 'info' | 'warning' | 'hint'

/** 全局 Toast 是否可见。 */
export const GLOBAL_TOAST_VISIBLE_KEY = 'globalToastVisible'
/** 全局 Toast 文案。 */
export const GLOBAL_TOAST_TEXT_KEY = 'globalToastText'
/** 全局 Toast 语气。 */
export const GLOBAL_TOAST_TONE_KEY = 'globalToastTone'

/**
 * 初始化 Toast Store 默认值。
 */
export function initToastStore(): void {
  AppStorage.setOrCreate(GLOBAL_TOAST_VISIBLE_KEY, false)
  AppStorage.setOrCreate(GLOBAL_TOAST_TEXT_KEY, '')
  AppStorage.setOrCreate(GLOBAL_TOAST_TONE_KEY, 'success')
}

/**
 * 写入全局 Toast 可见状态。
 * @param visible 是否可见。
 */
export function writeGlobalToastVisible(visible: boolean): void {
  AppStorage.setOrCreate(GLOBAL_TOAST_VISIBLE_KEY, visible)
}

/**
 * 写入全局 Toast 文案。
 * @param text 提示文案。
 */
export function writeGlobalToastText(text: string): void {
  AppStorage.setOrCreate(GLOBAL_TOAST_TEXT_KEY, text)
}

/**
 * 写入全局 Toast 语气。
 * @param tone 提示语气。
 */
export function writeGlobalToastTone(tone: ToastTone): void {
  AppStorage.setOrCreate(GLOBAL_TOAST_TONE_KEY, tone)
}
