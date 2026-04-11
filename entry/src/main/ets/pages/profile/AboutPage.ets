/**
 * AboutPage 页面文件，负责页面展示与交互承接。
 */

import { goBack } from '../../router/Router'
import { BackHeaderBar } from '../../components/BackHeaderBar'
import { buildProfilePath } from '../../router/RouteBuilders'
import { APP_COLORS, APP_RADIUS, APP_SHADOW } from '../../config/AppStyle'

@Component
export struct AboutPage {
  build() {
    Column({ space: 0 }) {
      BackHeaderBar({ title: '关于听桥', onBack: () => { goBack(buildProfilePath()) } })
      Scroll() {
        Column({ space: 18 }) {
      this.buildInfoCard(
        '听桥是什么',
        '听桥聚焦听障训练场景，把课程学习、分步练习、结果反馈与持续记录串成一条完整路径，帮助用户在日常交流里更从容地表达。'
      )
      this.buildInfoCard(
        '产品方向',
        '当前版本已经覆盖课程学习、训练项练习、学习记录、收藏管理和账号资料等核心能力。接下来会继续补强反馈呈现、课程内容丰富度以及训练评估的稳定性。'
      )
      this.buildInfoCard(
        '版本信息',
        'HearBridge\n版本 1.0.0\n当前为持续迭代中的内部版本，界面、接口与训练能力会根据实际使用情况持续优化。'
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
