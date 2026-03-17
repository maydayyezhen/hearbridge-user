import { TrainingItem } from '../TrainData'
import { FocusTagChip } from '../components/FocusTagChip'

@Component
export struct IntroStageContent {
  @Prop item: TrainingItem = new TrainingItem(0, '', '', '', 1, false, 0, '', '', '', '', [], [], [], [], [], [], [])
  @Prop coverUrl: string = ''

  build() {
    Column({ space: 16 }) {
      Stack({ alignContent: Alignment.BottomStart }) {
        Image(this.coverUrl)
          .width('100%')
          .height(188)
          .objectFit(ImageFit.Cover)
          .borderRadius(20)

        Column() {
        }
        .width('100%')
        .height(188)
        .borderRadius(20)
        .linearGradient({
          angle: 180,
          colors: [['#00000012', 0], ['#00000088', 1]]
        })

        Column({ space: 6 }) {
          Text(this.item.name)
            .fontSize(30)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFFFFF')
            .shadow({ radius: 12, color: '#00000099', offsetX: 0, offsetY: 3 })

          Text(this.item.meaning)
            .fontSize(13)
            .fontColor('#F2F7FF')
            .shadow({ radius: 10, color: '#00000088', offsetX: 0, offsetY: 2 })
        }
        .alignItems(HorizontalAlign.Start)
        .padding(18)
      }
      .width('100%')
      .height(188)

      Column({ space: 14 }) {
        this.buildDifficultySection(this.item.levelNum)
        this.buildInfoSection('训练说明', this.item.description)
        this.buildInfoSection('训练目标', this.item.goal)
        this.buildTagSection('本轮关注点', this.item.precautions, '#EEF5FF', '#2E79F4')
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
  private buildDifficultySection(levelNum: number) {
    Column({ space: 10 }) {
      Text('难度等级')
        .width('100%')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor('#1F2A44')

      Row({ space: 8 }) {
        ForEach(this.getDifficultyStars(levelNum), (state: string, index: number) => {
          SymbolGlyph(state === 'filled' ? $r('sys.symbol.star_fill') : $r('sys.symbol.star'))
            .fontSize(18)
            .fontColor(state === 'filled' ? ['#FFB938'] : ['#D6E0EE'])
        }, (_state: string, index: number) => `${index}`)
      }
      .width('100%')
    }
    .width('100%')
  }

  private getDifficultyStars(levelNum: number): string[] {
    const stars: string[] = []
    const safeLevel = Math.max(1, Math.min(5, levelNum))
    for (let index = 0; index < 5; index += 1) {
      stars.push(index < safeLevel ? 'filled' : 'empty')
    }
    return stars
  }

  @Builder
  private buildInfoSection(title: string, value: string) {
    Column({ space: 8 }) {
      Text(title)
        .width('100%')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor('#1F2A44')

      Text(value)
        .width('100%')
        .fontSize(14)
        .fontColor('#5F718B')
        .lineHeight(22)
    }
    .width('100%')
  }

  @Builder
  private buildTagSection(title: string, tags: string[], backgroundColor: string, fontColor: string) {
    Column({ space: 10 }) {
      Text(title)
        .width('100%')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor('#1F2A44')

      Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Start, alignItems: ItemAlign.Start }) {
        ForEach(tags, (tag: string) => {
          FocusTagChip({
            label: tag,
            chipBgColor: backgroundColor,
            chipFontColor: fontColor
          })
        }, (tag: string) => tag)
      }
      .width('100%')
    }
    .width('100%')
  }
}
