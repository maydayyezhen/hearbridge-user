/**
 * SecurityPage 页面文件，负责页面展示与交互承接。
 */

import common from '@ohos.app.ability.common'
import { go, goBack, reset } from '../../router/Router'
import { buildLoginPasswordPath, buildProfilePasswordPath, buildProfilePath } from '../../router/RouteBuilders'
import { BackHeaderBar } from '../../components/BackHeaderBar'
import { logoutCurrentUser } from '../../services/user/index'
import { showGlobalToast } from '../../services/ui/index'
import { APP_COLORS, APP_RADIUS, APP_SHADOW } from '../../config/AppStyle'

@Component
export struct SecurityPage {
  @State isLoggingOut: boolean = false
  @State logoutTip: string = ''
  @State logoutTipTone: string = 'normal'
  @State showLogoutConfirmDialog: boolean = false

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      Column({ space: 0 }) {
        BackHeaderBar({
          title: '账号与安全',
          onBack: () => {
            goBack(buildProfilePath())
          }
        })
        Scroll() {
          Column({ space: 18 }) {
            Column({ space: 14 }) {
              this.buildMenuRow($r('sys.symbol.lock'), '修改密码', () => { go(buildProfilePasswordPath()) })
              this.buildDangerMenuRow($r('sys.symbol.power'), this.isLoggingOut ? '退出中...' : '退出登录', () => { this.showLogoutConfirmDialog = true })
              if (this.logoutTip.length > 0) {
                Text(this.logoutTip).width('100%').fontSize(12).fontColor(this.getTipColor(this.logoutTipTone)).lineHeight(18)
              }
            }
            .width('100%').padding(18).backgroundColor(APP_COLORS.surface).borderRadius(APP_RADIUS.xxxl).shadow(APP_SHADOW.elevated)
          }
          .width('100%')
          .justifyContent(FlexAlign.Start)
          .alignItems(HorizontalAlign.Start)
          .constraintSize({ minHeight: '100%' })
          .padding({ left: 16, right: 16, top: 6, bottom: 20 })
        }
        .width('100%').layoutWeight(1).scrollBar(BarState.Off)
      }
      .width('100%').height('100%')

      if (this.showLogoutConfirmDialog) { this.buildLogoutConfirmDialog() }
    }
    .width('100%').height('100%')
  }

  private confirmLogout() {
    if (this.isLoggingOut) {
      return
    }
    this.showLogoutConfirmDialog = false
    void this.handleLogout()
  }

  private async handleLogout() {
    if (this.isLoggingOut) return
    this.isLoggingOut = true
    this.logoutTip = '正在退出登录...'
    this.logoutTipTone = 'normal'
    try {
      const result = await logoutCurrentUser(this.getAbilityContext())
      this.logoutTip = result.message
      this.logoutTipTone = result.tone
      if (result.ok) {
        showGlobalToast(result.message, 'info')
        reset(buildLoginPasswordPath())
      } else if (result.message.length > 0) {
        showGlobalToast(result.message, 'error')
      }
    } finally {
      this.isLoggingOut = false
    }
  }

  private getAbilityContext(): common.BaseContext { return this.getUIContext().getHostContext() as common.BaseContext }
  private getTipColor(tone: string): string { return tone === 'error' ? '#E5484D' : tone === 'success' ? '#2BA471' : '#7A8CA7' }

  @Builder private buildMenuRow(icon: Resource, label: string, onClickAction?: () => void) {
    Row({ space: 12 }) {
      Stack({ alignContent: Alignment.Center }) { Row().width(28).height(28).backgroundColor(APP_COLORS.primarySoftAlt).borderRadius(14); SymbolGlyph(icon).fontSize(17).fontColor([APP_COLORS.primary]) }.width(28).height(28)
      Text(label).fontSize(15).fontColor(APP_COLORS.primaryText)
      Blank(); SymbolGlyph($r('sys.symbol.chevron_forward')).fontSize(15).fontColor(['#95A7C0'])
    }
    .width('100%').padding(18).backgroundColor(APP_COLORS.surface).borderRadius(APP_RADIUS.xl)
    .shadow(APP_SHADOW.soft).onClick(() => { onClickAction?.() })
  }

  @Builder private buildDangerMenuRow(icon: Resource, label: string, onClickAction?: () => void) {
    Row({ space: 12 }) {
      Stack({ alignContent: Alignment.Center }) { Row().width(28).height(28).backgroundColor(APP_COLORS.dangerSoft).borderRadius(14); SymbolGlyph(icon).fontSize(17).fontColor([APP_COLORS.danger]) }.width(28).height(28)
      Text(label).fontSize(15).fontColor(APP_COLORS.danger); Blank(); SymbolGlyph($r('sys.symbol.chevron_forward')).fontSize(15).fontColor(['#E5A7AB'])
    }
    .width('100%').padding(18).backgroundColor('#FFF8F8').borderRadius(APP_RADIUS.xl)
    .shadow(APP_SHADOW.soft).onClick(() => { onClickAction?.() })
  }

  @Builder private buildLogoutConfirmDialog() {
    Stack({ alignContent: Alignment.Center }) {
      Row()
        .width('100%')
        .height('100%')
        .backgroundColor('#330C1B2A')
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
        .onClick(() => {
          this.showLogoutConfirmDialog = false
        })

      Column({ space: 18 }) {
        Column({ space: 12 }) {
          Stack({ alignContent: Alignment.Center }) {
            Row()
              .width(54)
              .height(54)
              .backgroundColor('#14E05868')
              .borderRadius(27)
            SymbolGlyph($r('sys.symbol.power'))
              .fontSize(24)
              .fontColor(['#E05868'])
          }
          .width(54)
          .height(54)

          Column({ space: 6 }) {
            Text('退出登录')
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor('#1F2A44')

            Text('退出后将返回登录页，本地登录状态会被清除。')
              .width('100%')
              .fontSize(13)
              .lineHeight(20)
              .textAlign(TextAlign.Center)
              .fontColor('#71829B')
          }
          .width('100%')
          .alignItems(HorizontalAlign.Center)
        }
        .width('100%')
        .alignItems(HorizontalAlign.Center)

        Row({ space: 10 }) {
          Button('取消')
            .layoutWeight(1)
            .height(46)
            .fontSize(15)
            .fontWeight(FontWeight.Medium)
            .fontColor('#61758E')
            .backgroundColor('#F4F7FB')
            .borderRadius(18)
            .onClick(() => {
              this.showLogoutConfirmDialog = false
            })

          Button(this.isLoggingOut ? '退出中...' : '确认退出')
            .layoutWeight(1)
            .height(46)
            .fontSize(15)
            .fontWeight(FontWeight.Medium)
            .fontColor('#FFFFFF')
            .backgroundColor('#E05868')
            .borderRadius(18)
            .enabled(!this.isLoggingOut)
            .onClick(() => {
              this.confirmLogout()
            })
        }
        .width('100%')
      }
      .constraintSize({ maxWidth: 332 })
      .padding({ left: 22, right: 22, top: 24, bottom: 22 })
      .margin({ left: 40, right: 40 })
      .backgroundColor('#FFFFFFFF')
      .borderRadius(26)
      .border({ width: 1, color: '#FFE7EDF5' })
      .shadow({ radius: 28, color: '#1A15304B', offsetX: 0, offsetY: 12 })
    }
    .width('100%')
    .height('100%')
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }
}
