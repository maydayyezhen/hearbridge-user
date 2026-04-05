import common from '@ohos.app.ability.common'
import { clearToken, readToken } from '../../../api/AuthStorage'
import { showGlobalToast } from '../../../api/GlobalToast'
import { updatePassword } from '../../../api/AuthApi'

@Component
export struct ProfilePasswordSecurityRoute {
  @Prop apiBaseUrl: string = ''
  @State currentPassword: string = ''
  @State nextPassword: string = ''
  @State confirmPassword: string = ''
  @State passwordTip: string = ''
  @State passwordTipTone: string = 'normal'
  @State isUpdatingPassword: boolean = false
  onPasswordUpdatedLogout: () => void = () => {}

  build() {
    Column({ space: 18 }) {
      Column({ space: 18 }) {
        this.buildSecurityInput($r('sys.symbol.lock'), '当前密码', '请输入当前密码', this.currentPassword, (value: string) => {
          this.currentPassword = value
        }, true)

        this.buildSecurityInput($r('sys.symbol.key'), '新密码', '请输入新密码', this.nextPassword, (value: string) => {
          this.nextPassword = value
        }, true)

        this.buildSecurityInput($r('sys.symbol.checkmark_shield'), '确认新密码', '请再次输入新密码', this.confirmPassword, (value: string) => {
          this.confirmPassword = value
        }, true)

        if (this.passwordTip.length > 0) {
          Text(this.passwordTip)
            .width('100%')
            .fontSize(12)
            .fontColor(this.getTipColor(this.passwordTipTone))
            .lineHeight(18)
            .margin({ top: -4 })
        }

        Button(this.isUpdatingPassword ? '提交中...' : '确认修改密码')
          .width('100%')
          .height(48)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#FFFFFF')
          .linearGradient({
            angle: 90,
            colors: [['#35C3EE', 0], ['#2E79F4', 1]]
          })
          .borderRadius(20)
          .enabled(!this.isUpdatingPassword)
          .onClick(() => {
            this.handlePasswordChange()
          })
      }
      .width('100%')
      .padding({ left: 18, right: 18, top: 22, bottom: 18 })
      .backgroundColor('#FFFFFF')
      .borderRadius(28)
      .shadow({ radius: 18, color: '#15304B10', offsetX: 0, offsetY: 8 })
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
    this.submitPasswordChange()
  }

  private async submitPasswordChange() {
    if (this.isUpdatingPassword) {
      return
    }
    this.isUpdatingPassword = true
    this.passwordTip = '正在提交密码修改...'
    this.passwordTipTone = 'normal'
    try {
      const token = await readToken(this.getAbilityContext())
      if (token.length === 0) {
        this.passwordTip = '登录状态已失效，请重新登录。'
        this.passwordTipTone = 'error'
        showGlobalToast(this.passwordTip, 'error')
        return
      }
      const result = await updatePassword(this.apiBaseUrl, token, {
        oldPassword: this.currentPassword,
        newPassword: this.nextPassword,
        confirmPassword: this.confirmPassword
      })
      if (!result.ok) {
        result.message = this.resolvePasswordUpdateError(result.code, result.message)
      }
      if (!result.ok) {
        this.passwordTip = result.message.length > 0 ? result.message : '密码修改失败，请稍后重试。'
        this.passwordTipTone = 'error'
        showGlobalToast(this.passwordTip, 'error')
        return
      }
      await clearToken(this.getAbilityContext())
      this.passwordTip = '密码修改成功，请重新登录。'
      this.passwordTipTone = 'success'
      showGlobalToast('密码修改成功，请重新登录。', 'info')
      this.currentPassword = ''
      this.nextPassword = ''
      this.confirmPassword = ''
      this.onPasswordUpdatedLogout()
    } catch (_error) {
      this.passwordTip = '网络异常，密码修改失败。'
      this.passwordTipTone = 'error'
      showGlobalToast(this.passwordTip, 'error')
    } finally {
      this.isUpdatingPassword = false
    }
  }

  private resolvePasswordUpdateError(code: number, message: string): string {
    if (message.length > 0 && message !== '数据异常') {
      return message
    }
    if (code === 201) {
      return '当前密码错误，请重新输入。'
    }
    if (code === 204) {
      if (this.currentPassword.length === 0) {
        return '请输入当前密码。'
      }
      if (this.nextPassword.length < 8) {
        return '新密码至少8位。'
      }
      if (this.nextPassword !== this.confirmPassword) {
        return '两次输入的新密码不一致。'
      }
      if (this.currentPassword === this.nextPassword) {
        return '新密码不能与旧密码相同。'
      }
      return '密码参数不合法，请检查后重试。'
    }
    if (code === 208) {
      return '登录已过期，请重新登录。'
    }
    if (code === 216) {
      return '账号已被禁用，请联系管理员。'
    }
    if (code === 9999) {
      return '服务器异常，请稍后重试。'
    }
    return message.length > 0 ? message : `密码修改失败（错误码 ${code}）。`
  }

  private getTipColor(tone: string): string {
    if (tone === 'error') {
      return '#E5484D'
    }
    if (tone === 'success') {
      return '#2BA471'
    }
    return '#7A8CA7'
  }

  private getAbilityContext(): common.BaseContext {
    return this.getUIContext().getHostContext() as common.BaseContext
  }

  @Builder
  private buildSecurityInput(icon: Resource, label: string, placeholder: string, value: string,
    onChangeAction: (value: string) => void, isPassword: boolean) {
    Column({ space: 8 }) {
      Text(label)
        .fontSize(13)
        .fontWeight(FontWeight.Medium)
        .fontColor('#31445F')

      Row({ space: 10 }) {
        SymbolGlyph(icon)
          .fontSize(17)
          .fontColor(['#7F94B2'])

        TextInput({ text: value, placeholder })
          .layoutWeight(1)
          .fontSize(15)
          .placeholderColor('#9AACC3')
          .backgroundColor(Color.Transparent)
          .type(isPassword ? InputType.Password : InputType.Normal)
          .onChange((next: string) => {
            onChangeAction(next)
          })
      }
      .width('100%')
      .height(54)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#F8FBFF')
      .borderRadius(18)
      .border({ width: 1, color: '#DDE7F3' })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }
}
