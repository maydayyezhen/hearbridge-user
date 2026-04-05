import common from '@ohos.app.ability.common'
import { clearToken, readToken } from '../../../api/AuthStorage'
import { logout } from '../../../api/AuthApi'
import { showGlobalToast } from '../../../api/GlobalToast'

@Component
export struct ProfileAccountSecurityRoute {
  @Prop apiBaseUrl: string = ''
  @State isLoggingOut: boolean = false
  @State logoutTip: string = ''
  @State logoutTipTone: string = 'normal'
  @State showLogoutConfirmDialog: boolean = false
  onOpenPasswordSettings: () => void = () => {}
  onLogoutSuccess: () => void = () => {}

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      Column({ space: 18 }) {
        Column({ space: 14 }) {
          this.buildMenuRow($r('sys.symbol.lock'), '修改密码', () => {
            this.onOpenPasswordSettings()
          })

          this.buildDangerMenuRow($r('sys.symbol.power'), this.isLoggingOut ? '退出中...' : '退出登录', () => {
            this.showLogoutConfirmDialog = true
          })

          if (this.logoutTip.length > 0) {
            Text(this.logoutTip)
              .width('100%')
              .fontSize(12)
              .fontColor(this.getTipColor(this.logoutTipTone))
              .lineHeight(18)
          }
        }
        .width('100%')
        .padding(18)
        .backgroundColor('#FFFFFF')
        .borderRadius(28)
        .shadow({ radius: 18, color: '#15304B10', offsetX: 0, offsetY: 8 })
      }
      .width('100%')

      if (this.showLogoutConfirmDialog) {
        this.buildLogoutConfirmDialog()
      }
    }
    .width('100%')
  }

  private confirmLogout() {
    if (this.isLoggingOut) {
      return
    }
    this.showLogoutConfirmDialog = false
    this.handleLogout()
  }

  private async handleLogout() {
    if (this.isLoggingOut) {
      return
    }
    this.isLoggingOut = true
    this.logoutTip = '正在退出登录...'
    this.logoutTipTone = 'normal'
    try {
      const token = await readToken(this.getAbilityContext())
      if (token.length > 0) {
        const result = await logout(this.apiBaseUrl, token)
        if (!result.ok) {
          this.logoutTip = result.message.length > 0 ? result.message : '退出登录失败，请稍后重试。'
          this.logoutTipTone = 'error'
          showGlobalToast(this.logoutTip, 'error')
          return
        }
      }
      await clearToken(this.getAbilityContext())
      this.logoutTip = '已退出登录。'
      this.logoutTipTone = 'success'
      showGlobalToast('已退出登录。', 'info')
      this.onLogoutSuccess()
    } catch (_error) {
      this.logoutTip = '网络异常，退出登录失败。'
      this.logoutTipTone = 'error'
      showGlobalToast(this.logoutTip, 'error')
    } finally {
      this.isLoggingOut = false
    }
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
  private buildMenuRow(icon: Resource, label: string, onClickAction?: () => void) {
    Row({ space: 12 }) {
      Stack({ alignContent: Alignment.Center }) {
        Row()
          .width(28)
          .height(28)
          .backgroundColor('#EAF2FF')
          .borderRadius(14)

        SymbolGlyph(icon)
          .fontSize(17)
          .fontColor(['#2E79F4'])
      }
      .width(28)
      .height(28)

      Text(label)
        .fontSize(15)
        .fontColor('#1F2A44')

      Blank()

      SymbolGlyph($r('sys.symbol.chevron_forward'))
        .fontSize(15)
        .fontColor(['#95A7C0'])
    }
    .width('100%')
    .padding(18)
    .backgroundColor('#FFFFFF')
    .borderRadius(22)
    .shadow({ radius: 16, color: '#15304B0D', offsetX: 0, offsetY: 6 })
    .onClick(() => {
      if (onClickAction) {
        onClickAction()
      }
    })
  }

  @Builder
  private buildDangerMenuRow(icon: Resource, label: string, onClickAction?: () => void) {
    Row({ space: 12 }) {
      Stack({ alignContent: Alignment.Center }) {
        Row()
          .width(28)
          .height(28)
          .backgroundColor('#FDEEEE')
          .borderRadius(14)

        SymbolGlyph(icon)
          .fontSize(17)
          .fontColor(['#D84B5B'])
      }
      .width(28)
      .height(28)

      Text(label)
        .fontSize(15)
        .fontColor('#C13E4D')

      Blank()

      SymbolGlyph($r('sys.symbol.chevron_forward'))
        .fontSize(15)
        .fontColor(['#D3A0A8'])
    }
    .width('100%')
    .padding(18)
    .backgroundColor('#FFFFFF')
    .borderRadius(22)
    .shadow({ radius: 16, color: '#15304B0D', offsetX: 0, offsetY: 6 })
    .onClick(() => {
      if (onClickAction) {
        onClickAction()
      }
    })
  }

  @Builder
  private buildLogoutConfirmDialog() {
    Stack({ alignContent: Alignment.Center }) {
      Row()
        .width('100%')
        .height('100%')
        .backgroundColor('#260C1B2A')
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
        .onClick(() => {
          this.showLogoutConfirmDialog = false
        })

      Column({ space: 16 }) {
        Text('退出登录')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1F2A44')

        Row({ space: 10 }) {
          Button('取消')
            .layoutWeight(1)
            .height(44)
            .fontSize(15)
            .fontWeight(FontWeight.Medium)
            .fontColor('#61758E')
            .backgroundColor('#F5F8FD')
            .borderRadius(16)
            .onClick(() => {
              this.showLogoutConfirmDialog = false
            })

          Button(this.isLoggingOut ? '退出中...' : '确认退出')
            .layoutWeight(1)
            .height(44)
            .fontSize(15)
            .fontWeight(FontWeight.Medium)
            .fontColor('#FFFFFF')
            .backgroundColor('#D84B5B')
            .borderRadius(16)
            .enabled(!this.isLoggingOut)
            .onClick(() => {
              this.confirmLogout()
            })
        }
        .width('100%')
      }
      .width('100%')
      .padding(24)
      .margin({ left: 28, right: 28 })
      .backgroundColor('#FFFFFF')
      .borderRadius(24)
    }
    .width('100%')
    .height('100%')
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }
}
