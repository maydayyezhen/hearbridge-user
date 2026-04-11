/**
 * SmsLoginPage 页面文件，负责页面展示与交互承接。
 */

import common from '@ohos.app.ability.common'
import { AuthFormScaffold, BuildAuthInlineTip, BuildAuthInputField } from '../../components/AuthFormShared'
import { getPendingMessage, loginBySms, requestSmsCode, sanitizePhoneInput, sanitizeSmsCodeInput } from '../../services/auth/index'
import { reset } from '../../router/Router'
import { buildHomePath, buildLoginPasswordPath, buildRegisterPath } from '../../router/RouteBuilders'
import { getSuccessToastMessage } from '../../utils/FeedbackCopy'

@Component
export struct SmsLoginPage {
  @StorageLink('auth.isLoggedIn')
  /** 当前是否已登录。 */
  isLoggedIn: boolean = false
  @State
  /** 当前输入的手机号。 */
  phoneNumber: string = ''
  @State
  /** 当前输入的验证码。 */
  verificationCode: string = ''
  @State
  /** 当前页面展示的提示文案。 */
  loginTip: string = '输入手机号后获取验证码即可登录。'
  @State
  /** 验证码倒计时秒数。 */
  codeCountdown: number = 0
  @State
  /** 当前是否正在发送验证码。 */
  isSendingCode: boolean = false
  @State
  /** 当前是否正在提交登录请求。 */
  isLoggingIn: boolean = false
  /** 本地验证码倒计时定时器句柄。 */
  private countdownTimer: number = -1

  aboutToDisappear(): void {
    this.clearCountdownTimer()
  }

  private getAbilityContext(): common.BaseContext {
    return this.getUIContext().getHostContext() as common.BaseContext
  }

  private clearCountdownTimer(): void {
    if (this.countdownTimer !== -1) {
      clearInterval(this.countdownTimer)
      this.countdownTimer = -1
    }
  }

  private startCountdown(): void {
    this.codeCountdown = 60
    this.clearCountdownTimer()
    this.countdownTimer = setInterval(() => {
      if (this.codeCountdown > 1) {
        this.codeCountdown -= 1
      } else {
        this.codeCountdown = 0
        this.clearCountdownTimer()
      }
    }, 1000)
  }

  private async handleRequestCode(): Promise<void> {
    if (this.isSendingCode || this.codeCountdown > 0) {
      return
    }
    this.isSendingCode = true
    this.loginTip = getPendingMessage('发送验证码')
    const result = await requestSmsCode(this.phoneNumber)
    this.loginTip = result.message.length > 0 ? result.message : getSuccessToastMessage('验证码发送')
    if (result.ok) {
      this.startCountdown()
    }
    this.isSendingCode = false
  }

  private async handleLogin(): Promise<void> {
    if (this.isLoggingIn) {
      return
    }
    this.isLoggingIn = true
    this.loginTip = getPendingMessage('登录')
    const result = await loginBySms(this.getAbilityContext(), this.phoneNumber, this.verificationCode)
    this.loginTip = result.message.length > 0 ? result.message : getSuccessToastMessage('登录')
    if (result.ok) {
      this.isLoggedIn = true
      this.clearCountdownTimer()
      reset(buildHomePath())
    }
    this.isLoggingIn = false
  }

  @Builder
  private buildFormContent() {
    Column({ space: 18 }) {
      Text('短信验证码登录')
        .width('100%')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor('#11233C')
        .textAlign(TextAlign.Center)

      Column({ space: 14 }) {
        BuildAuthInputField('手机号', '请输入手机号', this.phoneNumber, (value: string) => {
          this.phoneNumber = sanitizePhoneInput(value)
        })

        Column({ space: 7 }) {
          Text('验证码')
            .fontSize(13)
            .fontWeight(FontWeight.Medium)
            .fontColor('#3F5672')

          Row({ space: 10 }) {
            TextInput({ text: this.verificationCode, placeholder: '请输入验证码' })
              .layoutWeight(1)
              .height(52)
              .fontSize(16)
              .fontColor('#1D2F45')
              .backgroundColor('#F8FBFF')
              .borderRadius(16)
              .border({ width: 1, color: '#C8D8EA' })
              .padding({ left: 15, right: 15 })
              .placeholderFont({ size: 15 })
              .placeholderColor('#778CA7')
              .onChange((input: string) => {
                this.verificationCode = sanitizeSmsCodeInput(input)
              })

            Button(this.isSendingCode ? '发送中' : (this.codeCountdown > 0 ? `${this.codeCountdown}s` : '发送验证码'))
              .width(96)
              .height(52)
              .fontSize(11)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.isSendingCode || this.codeCountdown > 0 ? '#9DB4CC' : '#7C9FE9')
              .backgroundColor('#FFFFFF')
              .borderRadius(16)
              .border({
                width: 1,
                color: this.isSendingCode || this.codeCountdown > 0 ? '#DCE8F5' : '#CFE0FB'
              })
              .onClick(() => {
                void this.handleRequestCode()
              })
          }
          .width('100%')
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')

      BuildAuthInlineTip(this.loginTip, '输入手机号后获取验证码即可登录。')

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
        Button('账号密码登录')
          .fontSize(13)
          .fontWeight(FontWeight.Medium)
          .fontColor('#5A8BEA')
          .backgroundColor(Color.Transparent)
          .padding({ left: 4, right: 4, top: 1, bottom: 1 })
          .stateEffect(false)
          .onClick(() => {
            reset(buildLoginPasswordPath())
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
