/**
 * 认证页面服务出口，供页面层统一使用认证相关能力。
 */
export {
  AuthFormActionResult,
  loginByPassword,
  loginBySms,
  registerAccount,
  requestSmsCode
} from './api/AuthApiService'

export {
  getPendingMessage,
  sanitizePhoneInput,
  sanitizeSmsCodeInput
} from './local/AuthFormLocalService'
