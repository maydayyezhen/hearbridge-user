@Component
export struct TrainIntroStagePage {
  @Prop courseCoverUrl: string = ''
  @Prop itemName: string = ''
  @Prop itemMeaning: string = ''
  @Prop itemLevelNum: number = 1
  @Prop itemDescription: string = ''
  @Prop itemGoal: string = ''

  build() {
    Column({ space: 16 }) {
      Stack({ alignContent: Alignment.BottomStart }) {
        if (this.courseCoverUrl.length > 0) {
          Image(this.courseCoverUrl)
            .width('100%')
            .height(188)
            .objectFit(ImageFit.Cover)
            .borderRadius(20)
        } else {
          Column()
            .width('100%')
            .height(188)
            .linearGradient({
              angle: 135,
              colors: [['#FFDCEBFF', 0], ['#FFBBD6FF', 1]]
            })
            .borderRadius(20)
        }

        Column()
          .width('100%')
          .height(188)
          .borderRadius(20)
          .linearGradient({
            angle: 180,
            colors: [['#00000000', 0], ['#24000000', 1]]
          })

        Column({ space: 6 }) {
          Text(this.itemName)
            .fontSize(30)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFFFFFFF')

          if (this.itemMeaning.length > 0) {
            Text(this.itemMeaning)
              .fontSize(13)
              .fontColor('#FFF2F7FF')
          }
        }
        .alignItems(HorizontalAlign.Start)
        .padding(18)
      }
      .width('100%')
      .height(188)

      Column({ space: 14 }) {
        this.buildDifficultySection()
        if (this.itemDescription.length > 0) {
          this.buildInfoSection('训练说明', this.itemDescription)
        }
        if (this.itemGoal.length > 0) {
          this.buildInfoSection('训练目标', this.itemGoal)
        }
      }
      .width('100%')
      .padding(18)
      .backgroundColor('#FFFFFFFF')
      .borderRadius(18)
      .shadow({ radius: 18, color: '#1015304B', offsetX: 0, offsetY: 8 })
    }
    .width('100%')
  }

  @Builder
  private buildDifficultySection(): void {
    Column({ space: 10 }) {
      Text('难度等级')
        .width('100%')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor('#1F2A44')

      Row({ space: 8 }) {
        ForEach(this.getDifficultyStars(), (state: string, index: number) => {
          SymbolGlyph(state === 'filled' ? $r('sys.symbol.star_fill') : $r('sys.symbol.star'))
            .fontSize(18)
            .fontColor(state === 'filled' ? ['#FFFFB938'] : ['#FFD6E0EE'])
        }, (_state: string, index: number) => String(index))
      }
      .width('100%')
    }
    .width('100%')
  }

  private getDifficultyStars(): string[] {
    const stars: string[] = []
    const safeLevel = Math.max(1, Math.min(5, this.itemLevelNum))
    for (let index = 0; index < 5; index += 1) {
      stars.push(index < safeLevel ? 'filled' : 'empty')
    }
    return stars
  }

  @Builder
  private buildInfoSection(title: string, content: string): void {
    Column({ space: 8 }) {
      Text(title)
        .width('100%')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor('#1F2A44')

      Text(content)
        .width('100%')
        .fontSize(14)
        .fontColor('#5F718B')
        .lineHeight(22)
    }
    .width('100%')
  }
}
