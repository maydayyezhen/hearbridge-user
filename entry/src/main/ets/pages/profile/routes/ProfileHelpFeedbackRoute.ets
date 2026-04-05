@Component
export struct ProfileHelpFeedbackRoute {
  build() {
    Column({ space: 18 }) {
      this.buildInfoCard(
        '使用帮助',
        '听桥当前提供口语训练、手势训练、课程学习、训练记录与账号资料管理等功能。进入训练页面后，可按步骤完成介绍、示范、练习与评分。'
      )
      this.buildInfoCard(
        '反馈说明',
        '帮助与反馈功能正在持续完善中。当前如果你遇到页面异常、训练无法提交、图片无法上传或数据展示不一致等问题，可先记录操作路径与截图，后续将统一接入反馈通道。'
      )
      this.buildInfoCard(
        '常见问题',
        '1. 登录失败时，请先检查网络与账号信息。\n2. 上传资料图片建议在真机环境下操作。\n3. 训练评分结果以当前提交接口返回为准，如内容缺失，通常是后端未返回对应字段。'
      )
    }
    .width('100%')
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
    .backgroundColor('#FFFFFF')
    .borderRadius(28)
    .shadow({ radius: 18, color: '#15304B10', offsetX: 0, offsetY: 8 })
  }
}
