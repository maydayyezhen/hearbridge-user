/**
 * API 调试文本状态存储。
 */

/** 调试文本在 AppStorage 中的键。 */
export const API_DEBUG_TEXT_KEY = 'apiDebugText'

/**
 * 初始化 API 调试文本默认值。
 */
export function initApiDebugStore(): void {
  AppStorage.setOrCreate(API_DEBUG_TEXT_KEY, '')
}

/**
 * 读取 API 调试文本。
 */
export function readApiDebugText(): string {
  return (AppStorage.get(API_DEBUG_TEXT_KEY) as string | undefined) ?? ''
}

/**
 * 写入 API 调试文本。
 */
export function writeApiDebugText(text: string): void {
  AppStorage.setOrCreate(API_DEBUG_TEXT_KEY, text)
}

/**
 * 清空 API 调试文本。
 */
export function clearApiDebugText(): void {
  writeApiDebugText('')
}
