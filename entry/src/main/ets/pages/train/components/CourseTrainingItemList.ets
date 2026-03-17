import { TrainingItem } from '../TrainData'

@Component
export struct CourseTrainingItemList {
  @Prop items: TrainingItem[] = []
  @Prop completedCount: number = 0
  @Prop completedItemIds: number[] = []
  @Prop currentIndex: number = -1
  @Prop showHeader: boolean = true
  @Prop isCard: boolean = true
  onItemClick: (itemName: string, completed: boolean) => void = (_itemName: string, _completed: boolean) => {}
  onItemIdClick: (itemId: number, completed: boolean) => void = (_itemId: number, _completed: boolean) => {}

  build() {
    Column({ space: 8 }) {
      if (this.showHeader) {
        Row() {
          Text('训练项列表')
            .fontSize(17)
            .fontWeight(FontWeight.Medium)
            .fontColor('#1F2A44')

          Blank()

          Text(`${this.items.length} 项`)
            .fontSize(12)
            .fontColor('#7A8CA7')
        }
        .width('100%')
      }

      ForEach(this.items, (item: TrainingItem, index: number) => {
        this.buildTrainingItemRow(item, index)
      }, (item: TrainingItem) => `${item.id}`)
    }
    .width('100%')
    .padding(this.isCard ? { left: 12, right: 12, top: 12, bottom: 12 } : { left: 0, right: 0, top: 0, bottom: 0 })
    .backgroundColor(this.isCard ? '#FFFFFF' : Color.Transparent)
    .borderRadius(this.isCard ? 18 : 0)
    .shadow(this.isCard ? { radius: 12, color: '#15304B10', offsetX: 0, offsetY: 6 } : { radius: 0, color: '#00000000', offsetX: 0, offsetY: 0 })
  }

  @Builder
  private buildTrainingItemRow(item: TrainingItem, index: number) {
    Row({ space: 10 }) {
      Text(`${index + 1}`)
        .width(24)
        .fontSize(11)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.isCurrentIndex(index) ? '#2E79F4' : '#7B8BA3')
        .textAlign(TextAlign.Center)

      Text(item.name)
        .layoutWeight(1)
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .fontColor('#1F2A44')
        .maxLines(1)

      this.buildItemStatusTag(this.getStatusText(this.isCurrentIndex(index), this.isCompleted(item.id, index)))
      this.buildDifficultyStars(item.levelNum)
    }
    .width('100%')
    .height(48)
    .padding({ left: 8, right: 8 })
    .backgroundColor(this.isCurrentIndex(index) ? '#EDF4FF' : '#F7FAFF')
    .borderRadius(10)
    .onClick(() => {
      this.onItemClick(item.name, this.isCompleted(item.id, index))
      this.onItemIdClick(item.id, this.isCompleted(item.id, index))
    })
  }

  private isCurrentIndex(index: number): boolean {
    return index === this.currentIndex
  }

  private isCompleted(itemId: number, index: number): boolean {
    if (this.completedItemIds.length > 0) {
      for (let i = 0; i < this.completedItemIds.length; i += 1) {
        if (this.completedItemIds[i] === itemId) {
          return true
        }
      }
      return false
    }
    return index < this.completedCount
  }

  private getStatusText(isCurrent: boolean, completed: boolean): string {
    if (isCurrent) {
      return '进行中'
    }
    return completed ? '已完成' : '未完成'
  }

  @Builder
  private buildItemStatusTag(status: string) {
    Text(status)
      .fontSize(10)
      .fontWeight(FontWeight.Medium)
      .fontColor(status === '已完成' ? '#4E9E7B' : status === '进行中' ? '#2E79F4' : '#7F8FA8')
      .padding({ left: 7, right: 7, top: 3, bottom: 3 })
      .backgroundColor(status === '已完成' ? '#EEF8F1' : status === '进行中' ? '#EAF2FF' : '#EFF4FA')
      .borderRadius(8)
  }

  @Builder
  private buildDifficultyStars(levelNum: number) {
    Row({ space: 2 }) {
      ForEach([1, 2, 3], (level: number) => {
        SymbolGlyph(level <= levelNum ? $r('sys.symbol.star_fill') : $r('sys.symbol.star'))
          .fontSize(10)
          .fontColor([level <= levelNum ? '#F5B544' : '#B8C4D7'])
      }, (level: number) => `${level}`)
    }
  }
}
