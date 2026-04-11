/**
 * FeedbackPage 页面文件，负责页面展示与交互承接。
 */

import { goBack } from '../../router/Router'
import { BackHeaderBar } from '../../components/BackHeaderBar'
import { buildProfilePath } from '../../router/RouteBuilders'
import { APP_COLORS, APP_RADIUS, APP_SHADOW } from '../../config/AppStyle'

@Component
export struct FeedbackPage {
  build() {
    Column({ space: 0 }) {
      BackHeaderBar({ title: '帮助与反馈', onBack: () => { goBack(buildProfilePath()) } })
      Scroll() {
        Column({ space: 18 }) {
      this.buildInfoCard(
        '使用帮助',
        '听桥目前支持口语训练、手势训练、课程学习、训练记录和账号资料管理。进入训练后，按页面提示依次完成介绍、示范、练习和结果查看即可。'
      )
      this.buildInfoCard(
        '反馈说明',
        '如果你遇到页面异常、训练无法提交、图片上传失败或数据展示不一致等情况，建议先记录操作步骤并保留截图，这会让后续排查更快、更准确。'
      )
      this.buildInfoCard(
        '常见问题',
        '1. 登录失败时，请先检查网络与账号信息。\n2. 上传资料图片建议在真机环境下操作。\n3. 训练评分结果以当前提交接口返回为准，如内容缺失，通常是后端未返回对应字段。'
      )
        }
        .width('100%')
        .justifyContent(FlexAlign.Start)
        .alignItems(HorizontalAlign.Start)
        .constraintSize({ minHeight: '100%' })
        .padding({ left: 16, right: 16, top: 6, bottom: 20 })
      }
      .width('100%')
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(APP_COLORS.backgroundStart)
  }

  @Builder
  private buildInfoCard(title: string, content: string) {
    Column({ space: 10 }) {
      Text(title)
        .width('100%')
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .fontColor('#1F2A44')

      Text(content)
        .width('100%')
        .fontSize(14)
        .lineHeight(23)
        .fontColor('#5F718B')
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .padding(18)
      .backgroundColor(APP_COLORS.surface)
      .borderRadius(APP_RADIUS.xxxl)
      .shadow(APP_SHADOW.elevated)
  }
}
