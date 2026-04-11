import { MediaResourceItem } from '../../../../domain/static/train/TrainingContentModels'

@Component
export struct TrainGuideStagePage {
  @Prop actionImages: MediaResourceItem[] = []
  @Prop itemPrecautions: string[] = []
  @Prop itemCommonErrors: string[] = []

  build() {
    Column({ space: 16 }) {
      if (this.actionImages.length > 0) {
        this.buildActionImagesCard(this.actionImages)
      }

      if (this.itemPrecautions.length > 0 || this.itemCommonErrors.length > 0) {
        Column({ space: 16 }) {
          if (this.itemPrecautions.length > 0) {
            this.buildTagSection('注意要点', this.itemPrecautions, '#FFEEF5FF', '#FF2E79F4')
          }
          if (this.itemCommonErrors.length > 0) {
            this.buildTagSection('常见错误', this.itemCommonErrors, '#FFFFF1F1', '#FFD94C4C')
          }
        }
        .width('100%')
        .padding(18)
        .backgroundColor('#FFFFFFFF')
        .borderRadius(18)
        .shadow({ radius: 18, color: '#1015304B', offsetX: 0, offsetY: 8 })
      }
    }
    .width('100%')
  }

  @Builder
  private buildActionImagesCard(actionImages: MediaResourceItem[]): void {
    Column({ space: 12 }) {
      Text('步骤动作')
        .width('100%')
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .fontColor('#1F2A44')

      Swiper() {
        ForEach(actionImages, (resource: MediaResourceItem, index: number) => {
          this.buildActionImage(resource, index, actionImages.length)
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
    .backgroundColor('#FFFFFFFF')
    .borderRadius(20)
    .border({ width: 1, color: '#FFE5ECF7' })
    .shadow({ radius: 18, color: '#1015304B', offsetX: 0, offsetY: 8 })
  }

  @Builder
  private buildActionImage(resource: MediaResourceItem, index: number, total: number): void {
    Column({ space: 12 }) {
      Row() {
        Text(`步骤 ${index + 1}/${total}`)
          .fontSize(12)
          .fontWeight(FontWeight.Medium)
          .fontColor('#2E79F4')
          .padding({ left: 10, right: 10, top: 6, bottom: 6 })
          .backgroundColor('#FFEEF5FF')
          .borderRadius(12)

        Blank()
      }
      .width('100%')

      Image(resource.url)
        .width('100%')
        .height(236)
        .objectFit(ImageFit.Contain)
        .borderRadius(16)

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
  private buildTagSection(title: string, tags: string[], backgroundColor: string, textColor: string): void {
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
