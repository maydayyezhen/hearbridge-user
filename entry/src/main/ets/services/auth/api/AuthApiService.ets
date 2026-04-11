/**
 * 认证 API 业务服务，负责登录、注册、验证码等接口调用及结果语义处理。
 */
import common from '@ohos.app.ability.common'
import { passwordLogin, passwordRegister, sendSmsCode, smsLogin } from '../../../api/requests/AuthApi'
import {
  getLoginErrorMessage,
  validatePasswordLoginInput,
  validateRegisterInput,
  validateRequestCodeInput,
  validateSmsLoginInput
} from '../../../utils/AuthTools'
import { getSuccessToastMessage } from '../../../utils/FeedbackCopy'
import { completeAuthSuccessFlow } from '../local/AuthLocalService'

/**
 * 认证表单操作结果。
 */
export class AuthFormActionResult {
  ok: boolean = false
  message: string = ''
  toastTone: 'success' | 'error' | 'info' = 'info'
}

/**
 * 完成登录成功后的统一收尾流程。
 */
async function completeAuth(token: string, context: common.BaseContext): Promise<AuthFormActionResult> {
  const output = new AuthFormActionResult()
  const result = await completeAuthSuccessFlow(token, context, true)
  output.ok = result.ok
  output.message = result.message
  output.toastTone = result.ok ? 'success' : 'error'
  return output
}


/**
 * 使用账号密码登录。
 */
export async function loginByPassword(context: common.BaseContext, account: string, password: string): Promise<AuthFormActionResult> {
  const output = new AuthFormActionResult()
  const validation = validatePasswordLoginInput(account.trim(), password)
  if (validation.length > 0) {
    output.message = validation
    output.toastTone = 'error'
    return output
  }
  const result = await passwordLogin(account.trim(), password)
  if (!result.ok || !result.data?.token) {
    output.message = getLoginErrorMessage(result.code, result.message || '登录失败')
    output.toastTone = 'error'
    return output
  }
  const authResult = await completeAuth(result.data.token, context)
  output.ok = authResult.ok
  output.message = authResult.ok ? getSuccessToastMessage('登录') : authResult.message
  output.toastTone = authResult.ok ? 'success' : 'error'
  return output
}

/**
 * 请求短信验证码。
 */
export async function requestSmsCode(phone: string): Promise<AuthFormActionResult> {
  const output = new AuthFormActionResult()
  const validation = validateRequestCodeInput(phone)
  if (validation.length > 0) {
    output.message = validation
    output.toastTone = 'error'
    return output
  }
  const result = await sendSmsCode(phone)
  output.ok = result.ok
  output.message = result.ok ? getSuccessToastMessage('验证码发送') : getLoginErrorMessage(result.code, result.message || '验证码发送失败')
  output.toastTone = result.ok ? 'info' : 'error'
  return output
}

/**
 * 使用短信验证码登录。
 */
export async function loginBySms(context: common.BaseContext, phone: string, code: string): Promise<AuthFormActionResult> {
  const output = new AuthFormActionResult()
  const validation = validateSmsLoginInput(phone, code)
  if (validation.length > 0) {
    output.message = validation
    output.toastTone = 'error'
    return output
  }
  const result = await smsLogin(phone, code)
  if (!result.ok || !result.data?.token) {
    output.message = getLoginErrorMessage(result.code, result.message || '登录失败')
    output.toastTone = 'error'
    return output
  }
  const authResult = await completeAuth(result.data.token, context)
  output.ok = authResult.ok
  output.message = authResult.ok ? getSuccessToastMessage('登录') : authResult.message
  output.toastTone = authResult.ok ? 'success' : 'error'
  return output
}

/**
 * 注册新账号。
 */
export async function registerAccount(context: common.BaseContext, username: string, password: string, confirmPassword: string, phone: string): Promise<AuthFormActionResult> {
  const output = new AuthFormActionResult()
  const validation = validateRegisterInput(username.trim(), password, confirmPassword, phone.trim())
  if (validation.length > 0) {
    output.message = validation
    output.toastTone = 'error'
    return output
  }
  const result = await passwordRegister(username.trim(), password, phone.trim())
  if (!result.ok || !result.data?.token) {
    output.message = getLoginErrorMessage(result.code, result.message || '注册失败')
    output.toastTone = 'error'
    return output
  }
  const authResult = await completeAuth(result.data.token, context)
  output.ok = authResult.ok
  output.message = authResult.ok ? getSuccessToastMessage('注册') : authResult.message
  output.toastTone = authResult.ok ? 'success' : 'error'
  return output
}
