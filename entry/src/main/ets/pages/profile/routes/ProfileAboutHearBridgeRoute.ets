@Component
export struct ProfileAboutHearBridgeRoute {
  build() {
    Column({ space: 18 }) {
      this.buildInfoCard(
        '听桥是什么',
        '听桥是一款面向听障训练场景的口语与手语训练平台，强调课程化学习、分步训练、结果反馈与持续练习，帮助用户在真实交流中更自然地表达。'
      )
      this.buildInfoCard(
        '产品方向',
        '当前版本围绕基础课程、训练项练习、课程进度、学习记录、收藏管理和账号资料等功能展开。后续将继续补充更完整的反馈能力、更多课程内容与更稳定的训练评估体验。'
      )
      this.buildInfoCard(
        '版本信息',
        'HearBridge\n版本 1.0.0\n当前为持续迭代中的内部版本，界面、接口与训练能力会根据实际使用情况持续优化。'
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
