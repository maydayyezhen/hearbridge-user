import { MediaResourceItem, TrainingItem } from '../TrainData'

@Component
export struct GuideStageContent {
  @Prop item: TrainingItem = new TrainingItem(0, '', '', '', 1, false, 0, '', '', '', '', [], [], [], [], [], [], [])

  build() {
    Column({ space: 16 }) {
      if (this.item.actionImages.length > 0) {
        this.buildActionImagesCard(this.item)
      }

      Column({ space: 16 }) {
        this.buildInfoSection('动作说明', this.item.description)
        this.buildTagSection('注意要点', this.item.precautions, '#EEF5FF', '#2E79F4')
        this.buildTagSection('常见错误', this.item.commonErrors, '#FFF1F1', '#D94C4C')
      }
      .width('100%')
      .padding(18)
      .backgroundColor('#FFFFFF')
      .borderRadius(18)
      .shadow({ radius: 18, color: '#15304B10', offsetX: 0, offsetY: 8 })
    }
    .width('100%')
  }

  @Builder
  private buildActionImagesCard(item: TrainingItem) {
    Column({ space: 12 }) {
      Text('步骤动作')
        .width('100%')
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .fontColor('#1F2A44')

      Swiper() {
        ForEach(item.actionImages, (resource: MediaResourceItem, index: number) => {
          this.buildActionImage(resource, index, item.actionImages.length)
        }, (resource: MediaResourceItem) => resource.uid)
      }
      .width('100%')
      .height(318)
      .indicator(true)
      .loop(false)
      .autoPlay(false)
    }
    .width('100%')
    .padding(18)
    .backgroundColor('#FFFFFF')
    .borderRadius(20)
    .border({ width: 1, color: '#E5ECF7' })
    .shadow({ radius: 18, color: '#15304B10', offsetX: 0, offsetY: 8 })
  }

  @Builder
  private buildActionImage(resource: MediaResourceItem, index: number, total: number) {
    Column({ space: 12 }) {
      Row() {
        Text(`步骤 ${index + 1}/${total}`)
          .fontSize(12)
          .fontWeight(FontWeight.Medium)
          .fontColor('#2E79F4')
          .padding({ left: 10, right: 10, top: 6, bottom: 6 })
          .backgroundColor('#EEF5FF')
          .borderRadius(12)

        Blank()
      }
      .width('100%')

      Image(resource.url)
        .width('100%')
        .height(236)
        .objectFit(ImageFit.Contain)
        .borderRadius(16)
        .backgroundColor('#F5F8FD')

      if (resource.description.length > 0) {
        Text(resource.description)
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor('#42526B')
          .lineHeight(22)
          .maxLines(3)
      }
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  private buildInfoSection(title: string, content: string) {
    Column({ space: 8 }) {
      Text(title)
        .width('100%')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor('#1F2A44')

      Text(content)
        .width('100%')
        .fontSize(14)
        .fontColor('#5E6D85')
        .lineHeight(22)
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  private buildTagSection(title: string, tags: string[], backgroundColor: string, textColor: string) {
    Column({ space: 10 }) {
      Text(title)
        .width('100%')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor('#1F2A44')

      Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Start, alignItems: ItemAlign.Start }) {
        ForEach(tags, (tag: string) => {
          Text(tag)
            .fontSize(12)
            .fontColor(textColor)
            .padding({ left: 10, right: 10, top: 7, bottom: 7 })
            .backgroundColor(backgroundColor)
            .borderRadius(12)
            .margin({ right: 8, bottom: 8 })
        }, (tag: string) => tag)
      }
      .width('100%')
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }
}
