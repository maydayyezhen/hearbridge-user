/**
 * PasswordPage 页面文件，负责页面展示与交互承接。
 */

import common from '@ohos.app.ability.common'
import { AuthFormScaffold, BuildAuthInlineTip, BuildAuthInputField } from '../../components/AuthFormShared'
import { getPendingMessage } from '../../utils/FeedbackCopy'
import { goBack, reset } from '../../router/Router'
import { buildLoginPasswordPath, buildProfileSecurityPath } from '../../router/RouteBuilders'
import { changePassword } from '../../services/user/index'
import { showGlobalToast } from '../../services/ui/index'

@Component
export struct PasswordPage {
  @State currentPassword: string = ''
  @State nextPassword: string = ''
  @State confirmPassword: string = ''
  @State passwordTip: string = ''
  @State passwordTipTone: string = 'normal'
  @State isUpdatingPassword: boolean = false

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

  @Builder
  private buildFormContent() {
    Column() {
      Column({ space: 18 }) {
        Stack() {
          Text('修改密码')
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
              goBack(buildProfileSecurityPath())
            })
          }
          .width('100%')
          .justifyContent(FlexAlign.Start)
          .position({ x: -12, y: 0 })
        }
        .width('100%')
        .height(32)

        Column({ space: 14 }) {
          BuildAuthInputField('当前密码', '请输入当前密码', this.currentPassword, (value: string) => {
            this.currentPassword = value
          }, true)

          BuildAuthInputField('新密码', '请输入新密码', this.nextPassword, (value: string) => {
            this.nextPassword = value
          }, true)

          BuildAuthInputField('确认新密码', '请再次输入新密码', this.confirmPassword, (value: string) => {
            this.confirmPassword = value
          }, true)
        }
        .width('100%')

        BuildAuthInlineTip(this.passwordTip, '')

        Button(this.isUpdatingPassword ? '提交中...' : '确认修改密码')
          .width('100%')
          .height(54)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#FFFFFF')
          .linearGradient({
            angle: 105,
            colors: this.isUpdatingPassword
              ? [['#90B0D8', 0], ['#6E8EB8', 1]]
              : [['#3AAAE8', 0], ['#1848DE', 1]]
          })
          .borderRadius(18)
          .shadow({ radius: 22, color: '#2A1848DE', offsetX: 0, offsetY: 10 })
          .onClick(() => {
            this.handlePasswordChange()
          })
      }
      .width('100%')
      .padding({ left: 0, right: 0, top: 0, bottom: 16 })
    }
    .width('100%')
  }

  private handlePasswordChange() {
    if (this.currentPassword.length === 0) {
      this.passwordTip = '请输入当前密码。'
      this.passwordTipTone = 'error'
      return
    }
    if (this.nextPassword.length === 0) {
      this.passwordTip = '请输入新密码。'
      this.passwordTipTone = 'error'
      return
    }
    if (!/^(?=.*[A-Za-z])(?=.*\d)[^\s]{8,20}$/.test(this.nextPassword)) {
      this.passwordTip = '新密码需为 8-20 位，且同时包含字母和数字。'
      this.passwordTipTone = 'error'
      return
    }
    if (this.nextPassword === this.currentPassword) {
      this.passwordTip = '新密码不能与当前密码相同。'
      this.passwordTipTone = 'error'
      return
    }
    if (this.confirmPassword.length === 0) {
      this.passwordTip = '请再次输入新密码。'
      this.passwordTipTone = 'error'
      return
    }
    if (this.nextPassword !== this.confirmPassword) {
      this.passwordTip = '两次输入的新密码不一致。'
      this.passwordTipTone = 'error'
      return
    }
    void this.submitPasswordChange()
  }

  private async submitPasswordChange() {
    if (this.isUpdatingPassword) return
    this.isUpdatingPassword = true
    this.passwordTip = getPendingMessage('修改密码')
    this.passwordTipTone = 'normal'
    try {
      const result = await changePassword(this.getAbilityContext(), this.currentPassword, this.nextPassword, this.confirmPassword)
      this.passwordTip = result.message
      this.passwordTipTone = result.tone
      if (result.ok) {
        showGlobalToast(result.message, 'info')
        reset(buildLoginPasswordPath())
      } else if (result.message.length > 0) {
        showGlobalToast(result.message, 'error')
      }
    } finally {
      this.isUpdatingPassword = false
    }
  }

  private getAbilityContext(): common.BaseContext {
    return this.getUIContext().getHostContext() as common.BaseContext
  }
}
