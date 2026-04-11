/**
 * API 调试文本仓储，负责调试文本状态读写与初始化。
 */
import {
  clearApiDebugText,
  initApiDebugStore,
  readApiDebugText,
  writeApiDebugText
} from '../../storage/ui/ApiDebugStore'

/**
 * 初始化 API 调试仓储依赖的本地状态。
 */
export function initApiDebugRepository(): void {
  initApiDebugStore()
}

export {
  clearApiDebugText,
  readApiDebugText,
  writeApiDebugText
}
