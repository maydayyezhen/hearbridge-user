/**
 * PasswordLoginPage 页面文件，负责页面展示与交互承接。
 */

import common from '@ohos.app.ability.common'
import { AuthFormScaffold, BuildAuthInlineTip, BuildAuthInputField } from '../../components/AuthFormShared'
import { loginByPassword } from '../../services/auth/index'
import { reset } from '../../router/Router'
import { buildHomePath, buildLoginSmsPath, buildRegisterPath } from '../../router/RouteBuilders'
import { validatePasswordLoginInput } from '../../utils/AuthTools'
import { getPendingMessage, getSuccessToastMessage } from '../../utils/FeedbackCopy'

@Component
export struct PasswordLoginPage {
  @StorageLink('auth.isLoggedIn')
  /** 当前是否已登录。 */
  isLoggedIn: boolean = false
  @State
  /** 当前输入的账号。 */
  account: string = ''
  @State
  /** 当前输入的密码。 */
  password: string = ''
  @State
  /** 当前页面展示的提示文案。 */
  loginTip: string = '欢迎回来，输入账号和密码继续训练。'
  @State
  /** 当前是否正在提交登录请求。 */
  isLoggingIn: boolean = false

  private getAbilityContext(): common.BaseContext {
    return this.getUIContext().getHostContext() as common.BaseContext
  }

  private async handleLogin(): Promise<void> {
    const message = validatePasswordLoginInput(this.account.trim(), this.password)
    if (message.length > 0) {
      this.loginTip = message
      return
    }
    if (this.isLoggingIn) {
      return
    }
    this.isLoggingIn = true
    this.loginTip = getPendingMessage('登录')
    const result = await loginByPassword(this.getAbilityContext(), this.account.trim(), this.password)
    this.loginTip = result.message.length > 0 ? result.message : getSuccessToastMessage('登录')
    if (result.ok) {
      this.isLoggedIn = true
      reset(buildHomePath())
    }
    this.isLoggingIn = false
  }

  @Builder
  private buildFormContent() {
    Column({ space: 18 }) {
      Text('账号密码登录')
        .width('100%')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor('#11233C')
        .textAlign(TextAlign.Center)

      Column({ space: 14 }) {
        BuildAuthInputField('账号', '请输入账号', this.account, (value: string) => {
          this.account = value.trim()
        })
        BuildAuthInputField('密码', '请输入密码', this.password, (value: string) => {
          this.password = value
        }, true)
      }
      .width('100%')

      BuildAuthInlineTip(this.loginTip, '欢迎回来，输入账号和密码继续训练。')

      Button('立即登录')
        .width('100%')
        .height(54)
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor('#FFFFFF')
        .linearGradient({
          angle: 105,
          colors: this.isLoggingIn
            ? [['#90B0D8', 0], ['#6E8EB8', 1]]
            : [['#3AAAE8', 0], ['#1848DE', 1]]
        })
        .borderRadius(18)
        .shadow({ radius: 22, color: '#2A1848DE', offsetX: 0, offsetY: 10 })
        .onClick(() => {
          void this.handleLogin()
        })

      Row() {
        Button('短信验证码登录')
          .fontSize(13)
          .fontWeight(FontWeight.Medium)
          .fontColor('#5A8BEA')
          .backgroundColor(Color.Transparent)
          .padding({ left: 4, right: 4, top: 1, bottom: 1 })
          .stateEffect(false)
          .onClick(() => {
            reset(buildLoginSmsPath())
          })

        Button('没有账号？')
          .fontSize(13)
          .fontWeight(FontWeight.Medium)
          .fontColor('#5A8BEA')
          .backgroundColor(Color.Transparent)
          .padding({ left: 4, right: 4, top: 1, bottom: 1 })
          .stateEffect(false)
          .onClick(() => {
            reset(buildRegisterPath())
          })
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({ top: -10 })
    }
    .width('100%')
  }

  build() {
    AuthFormScaffold({
      content: () => {
        this.buildFormContent()
      }
    })
  }
}
