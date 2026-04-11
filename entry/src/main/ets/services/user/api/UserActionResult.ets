/**
 * 用户动作通用结果。
 */
import { UserProfileApiData } from '../mapper/UserStateMapper'

export class UserActionResult {
  ok: boolean = false
  message: string = ''
  tone: string = 'normal'
  data: UserProfileApiData | string | null = null
}
