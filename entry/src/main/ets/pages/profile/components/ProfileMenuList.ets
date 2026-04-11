/**
 * 个人页菜单列表。
 */

import { APP_COLORS, APP_RADIUS, APP_SHADOW } from '../../../config/AppStyle'
@Component
export struct ProfileMenuList {
  onOpenFavorites: () => void = () => {}
  onOpenAccountProfile: () => void = () => {}
  onOpenAccountSecurity: () => void = () => {}
  onOpenHelpUpload: () => void = () => {}
  onOpenAboutHearBridge: () => void = () => {}

  build() {
    Column({ space: 10 }) {
      this.buildMenuRow($r('sys.symbol.star'), '我的收藏', this.onOpenFavorites)
      this.buildMenuRow($r('sys.symbol.person'), '账号资料', this.onOpenAccountProfile)
      this.buildMenuRow($r('sys.symbol.lock'), '账号与安全', this.onOpenAccountSecurity)
      this.buildMenuRow($r('sys.symbol.questionmark_circle'), '帮助与反馈', this.onOpenHelpUpload)
      this.buildMenuRow($r('sys.symbol.info_circle'), '关于听桥', this.onOpenAboutHearBridge)
    }
    .width('100%')
  }

  @Builder
  private buildMenuRow(icon: Resource, label: string, onClickAction?: () => void) {
    Row({ space: 12 }) {
      Stack({ alignContent: Alignment.Center }) {
        Row()
          .width(28)
          .height(28)
          .backgroundColor(APP_COLORS.primarySoftAlt)
          .borderRadius(14)

        SymbolGlyph(icon)
          .fontSize(17)
          .fontColor([APP_COLORS.primary])
      }
      .width(28)
      .height(28)

      Text(label)
        .fontSize(15)
        .fontColor(APP_COLORS.primaryText)

      Blank()

      SymbolGlyph($r('sys.symbol.chevron_forward'))
        .fontSize(15)
        .fontColor(['#95A7C0'])
    }
    .width('100%')
    .padding(18)
    .backgroundColor(APP_COLORS.surface)
    .borderRadius(APP_RADIUS.xl)
    .shadow(APP_SHADOW.soft)
    .onClick(() => {
      if (onClickAction) {
        onClickAction()
      }
    })
  }
}
