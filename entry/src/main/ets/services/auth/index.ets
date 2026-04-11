/**
 * auth 模块正式出口。
 */
export {
  AuthFormActionResult,
  getPendingMessage,
  loginByPassword,
  loginBySms,
  registerAccount,
  requestSmsCode,
  sanitizePhoneInput,
  sanitizeSmsCodeInput
} from './AuthPageService'
