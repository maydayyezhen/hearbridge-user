/**
 * 认证表单本地服务，负责表单输入清洗与轻量展示文案辅助。
 */
import { getPendingMessage } from '../../../utils/FeedbackCopy'
/**
 * 清洗手机号输入，仅保留数字。
 */
export function sanitizePhoneInput(value: string): string {
  return value.replace(/[^0-9]/g, '').slice(0, 11)
}

/**
 * 清洗验证码输入，仅保留数字。
 */
export function sanitizeSmsCodeInput(value: string): string {
  return value.replace(/[^0-9]/g, '').slice(0, 6)
}

export { getPendingMessage }
