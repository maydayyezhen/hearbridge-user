/**
 * RegisterPage 页面文件，负责页面展示与交互承接。
 */

import common from '@ohos.app.ability.common'
import { AuthFormScaffold, BuildAuthInlineTip, BuildAuthInputField } from '../../components/AuthFormShared'
import { registerAccount, sanitizePhoneInput } from '../../services/auth/index'
import { reset } from '../../router/Router'
import { buildHomePath, buildLoginSmsPath } from '../../router/RouteBuilders'
import { getPendingMessage, getSuccessToastMessage } from '../../utils/FeedbackCopy'

@Component
export struct RegisterPage {
  @StorageLink('auth.isLoggedIn')
  /** 当前是否已登录。 */
  isLoggedIn: boolean = false
  @State
  /** 当前输入的注册账号。 */
  registerAccount: string = ''
  @State
  /** 当前输入的注册密码。 */
  registerPassword: string = ''
  @State
  /** 当前输入的确认密码。 */
  registerConfirmPassword: string = ''
  @State
  /** 当前输入的注册手机号。 */
  registerPhone: string = ''
  @State
  /** 当前页面展示的提示文案。 */
  loginTip: string = '创建账号后就可以开始课程与训练。'
  @State
  /** 当前是否正在提交注册请求。 */
  isLoggingIn: boolean = false

  private getAbilityContext(): common.BaseContext {
    return this.getUIContext().getHostContext() as common.BaseContext
  }

  private async handleRegister(): Promise<void> {
    if (this.isLoggingIn) {
      return
    }
    this.isLoggingIn = true
    this.loginTip = getPendingMessage('注册账号')
    const result = await registerAccount(
      this.getAbilityContext(),
      this.registerAccount.trim(),
      this.registerPassword,
      this.registerConfirmPassword,
      this.registerPhone.trim()
    )
    this.loginTip = result.message.length > 0 ? result.message : getSuccessToastMessage('注册')
    if (result.ok) {
      this.isLoggedIn = true
      reset(buildHomePath())
    }
    this.isLoggingIn = false
  }

  @Builder
  private buildFormContent() {
    Column() {
      Column({ space: 18 }) {
        Stack() {
          Text('创建听桥账号')
            .width('100%')
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor('#11233C')
            .textAlign(TextAlign.Center)

          Row() {
            Button() {
              SymbolGlyph($r('sys.symbol.chevron_backward'))
                .fontSize(21)
                .fontColor(['#7E8794'])
            }
            .width(36)
            .height(36)
            .backgroundColor(Color.Transparent)
            .borderRadius(10)
            .stateEffect(false)
            .onClick(() => {
              reset(buildLoginSmsPath())
            })
          }
          .width('100%')
          .justifyContent(FlexAlign.Start)
          .position({ x: -12, y: 0 })
        }
        .width('100%')
        .height(32)

        Column({ space: 14 }) {
          BuildAuthInputField('注册账号', '请输入账号', this.registerAccount, (value: string) => {
            this.registerAccount = value.trim()
          })
          BuildAuthInputField('设置密码', '至少 6 位', this.registerPassword, (value: string) => {
            this.registerPassword = value
          }, true)
          BuildAuthInputField('确认密码', '再次输入密码', this.registerConfirmPassword, (value: string) => {
            this.registerConfirmPassword = value
          }, true)
          BuildAuthInputField('手机号（选填）', '可用于后续找回密码', this.registerPhone, (value: string) => {
            this.registerPhone = sanitizePhoneInput(value)
          })
        }
        .width('100%')

        BuildAuthInlineTip(this.loginTip, '创建账号后就可以开始课程与训练。')

        Button('注册账号')
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
            void this.handleRegister()
          })
      }
      .width('100%')
      .padding({ left: 0, right: 0, top: 0, bottom: 16 })
    }
    .width('100%')
  }

  build() {
    AuthFormScaffold({
      useScroll: true,
      footerText: '',
      bottomPadding: 28,
      content: () => {
        this.buildFormContent()
      }
    })
  }
}
