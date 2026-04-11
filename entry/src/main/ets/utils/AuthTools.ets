/**
 * AuthTools 工具文件，负责通用辅助处理逻辑。
 */

export function sanitizePhoneValue(value: string): string {
  return value.replace(/[^0-9]/g, '').slice(0, 11)
}

/** sanitizeCodeValue。 */
export function sanitizeCodeValue(value: string): string {
  return value.replace(/[^0-9]/g, '').slice(0, 6)
}

/** isValidPhoneValue。 */
export function isValidPhoneValue(phone: string): boolean {
  return /^1\d{10}$/.test(phone)
}

/** isValidAccountValue。 */
export function isValidAccountValue(account: string): boolean {
  return /^[A-Za-z0-9_]{4,20}$/.test(account)
}

/** isValidPasswordValue。 */
export function isValidPasswordValue(password: string): boolean {
  return /^[^\s]{6,20}$/.test(password)
}

/** buildLoginTipText。 */
export function buildLoginTipText(authScene: string, loginMode: string): string {
  if (authScene === 'register') {
    return '创建账号后就可以开始课程与训练。'
  }
  return loginMode === 'password' ? '欢迎回来，输入账号和密码继续训练。' : '输入手机号后获取验证码即可登录。'
}

/** getLoginErrorMessage。 */
export function getLoginErrorMessage(code: number, fallbackMessage: string): string {
  const errorMap: Record<number, string> = {
    202: '验证码错误',
    204: '数据异常',
    205: '请输入正确的手机号',
    206: '验证码已过期，请重新获取',
    207: '验证码发送失败，请稍后重试',
    210: '请求过于频繁，请稍后再试',
    214: '今日短信次数已达上限',
    216: '账号已被禁用，请联系管理员'
  }
  return errorMap[code] ?? fallbackMessage
}

/** validateRequestCodeInput。 */
export function validateRequestCodeInput(phoneNumber: string): string {
  if (phoneNumber.length === 0) {
    return '请输入手机号。'
  }
  if (!isValidPhoneValue(phoneNumber)) {
    return '手机号格式不正确，请输入 11 位大陆手机号。'
  }
  return ''
}

/** validateSmsLoginInput。 */
export function validateSmsLoginInput(phoneNumber: string, verificationCode: string): string {
  const phoneMessage = validateRequestCodeInput(phoneNumber)
  if (phoneMessage.length > 0) {
    return phoneMessage
  }
  if (verificationCode.length === 0) {
    return '请输入验证码。'
  }
  if (verificationCode.length !== 6) {
    return '验证码需为 6 位数字。'
  }
  return ''
}

/** validatePasswordLoginInput。 */
export function validatePasswordLoginInput(account: string, password: string): string {
  if (account.length === 0) {
    return '请输入账号。'
  }
  if (!isValidAccountValue(account)) {
    return '账号需为 4-20 位字母、数字或下划线。'
  }
  if (password.length === 0) {
    return '请输入密码。'
  }
  if (!isValidPasswordValue(password)) {
    return '密码需为 6-20 位，且不能包含空格。'
  }
  return ''
}

/** validateRegisterInput。 */
export function validateRegisterInput(
  account: string,
  password: string,
  confirmPassword: string,
  phone: string
): string {
  if (account.length === 0) {
    return '请输入注册账号。'
  }
  if (!isValidAccountValue(account)) {
    return '注册账号需为 4-20 位字母、数字或下划线。'
  }
  if (password.length === 0) {
    return '请设置登录密码。'
  }
  if (!isValidPasswordValue(password)) {
    return '注册密码需为 6-20 位，且不能包含空格。'
  }
  if (confirmPassword.length === 0) {
    return '请再次输入确认密码。'
  }
  if (password !== confirmPassword) {
    return '两次输入的密码不一致。'
  }
  if (phone.length > 0 && !isValidPhoneValue(phone)) {
    return '手机号格式不正确，请输入 11 位大陆手机号。'
  }
  return ''
}

/** ensureMinimumDuration。 */
export async function ensureMinimumDuration(startedAt: number, minimumDurationMs: number): Promise<void> {
  const elapsed = new Date().getTime() - startedAt
  const remaining = minimumDurationMs - elapsed
  if (remaining > 0) {
    await new Promise<void>((resolve) => {
      setTimeout(() => {
        resolve()
      }, remaining)
    })
  }
}
