/**
 * 初始化认证状态。
 * 当前仅保留 token 与登录标记两个核心字段。
 */
export function initAuthStore(): void {
  AppStorage.setOrCreate('auth.token', '')
  AppStorage.setOrCreate('auth.isLoggedIn', false)
}

/**
 * 写入当前登录 token，并同步登录标记。
 * @param token 当前登录 token。
 */
export function setToken(token: string): void {
  AppStorage.setOrCreate('auth.token', token)
  AppStorage.setOrCreate('auth.isLoggedIn', token.length > 0)
}

/**
 * 单独写入当前登录标记。
 * @param loggedIn 当前是否视为已登录。
 */
export function setLoggedIn(loggedIn: boolean): void {
  AppStorage.setOrCreate('auth.isLoggedIn', loggedIn)
}

/**
 * 读取当前 token。
 * @returns 当前登录 token。
 */
export function getToken(): string {
  return (AppStorage.get('auth.token') as string | undefined) ?? ''
}

/**
 * 读取当前登录标记。
 * @returns 当前是否已登录。
 */
export function readLoggedIn(): boolean {
  return (AppStorage.get('auth.isLoggedIn') as boolean | undefined) ?? false
}

/**
 * 清空认证核心状态。
 */
export function clearAuthState(): void {
  AppStorage.setOrCreate('auth.token', '')
  AppStorage.setOrCreate('auth.isLoggedIn', false)
}
