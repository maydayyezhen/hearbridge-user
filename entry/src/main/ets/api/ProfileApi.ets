export interface MockApiResult<T> {
  ok: boolean
  message: string
  data: T | null
}

export interface AvatarUploadData {
  avatarUrl: string
}

export interface PasswordUpdateData {
  updatedAt: string
}

function wait(delayMs: number): Promise<void> {
  return new Promise<void>((resolve: () => void) => {
    setTimeout(() => {
      resolve()
    }, delayMs)
  })
}

export async function mockUploadAvatar(avatarUrl: string): Promise<MockApiResult<AvatarUploadData>> {
  await wait(900)
  return {
    ok: true,
    message: '头像上传成功',
    data: {
      avatarUrl
    }
  }
}

export async function mockUpdatePassword(currentPassword: string, nextPassword: string): Promise<MockApiResult<PasswordUpdateData>> {
  await wait(900)

  if (currentPassword.length === 0 || nextPassword.length === 0) {
    return {
      ok: false,
      message: '参数不完整',
      data: null
    }
  }

  return {
    ok: true,
    message: '密码修改成功',
    data: {
      updatedAt: '刚刚'
    }
  }
}
