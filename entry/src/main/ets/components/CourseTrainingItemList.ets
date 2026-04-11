/**
 * CourseTrainingItemList 组件，负责课程训练项列表展示。
 */

import { TrainingContentItem } from '../domain/static/train/TrainingContentModels'
import { normalizeTrainItemStatus } from '../utils/TrainingTypeUtil'

type CourseTrainingItemRowStatus = 'pending' | 'in_progress' | 'completed'

@Component
export struct CourseTrainingItemList {
  @Prop items: TrainingContentItem[] = []
  @Prop completedCount: number = 0
  @Prop completedItemIds: number[] = []
  @Prop currentIndex: number = -1
  @Prop showHeader: boolean = true
  @Prop isCard: boolean = true
  @Prop rowHeight: number = 48
  @Prop rowHorizontalPadding: number = 8
  @Prop rowSpacing: number = 8
  onItemClick: (itemName: string, completed: boolean) => void = (_itemName: string, _completed: boolean) => {}
  onItemCodeClick: (itemCode: string, itemName: string, completed: boolean) => void = (_itemCode: string, _itemName: string, _completed: boolean) => {}
  onItemIdClick: (itemId: number, completed: boolean) => void = (_itemId: number, _completed: boolean) => {}

  build() {
    Column({ space: this.rowSpacing }) {
      if (this.showHeader) {
        Row() {
          Text('训练项目列表')
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

      ForEach(this.items, (item: TrainingContentItem, index: number) => {
        this.buildTrainingItemRow(item, index)
      }, (item: TrainingContentItem) => `${item.id}`)
    }
    .width('100%')
    .padding(this.isCard ? { left: 12, right: 12, top: 12, bottom: 12 } : { left: 0, right: 0, top: 0, bottom: 0 })
    .backgroundColor(this.isCard ? '#FFFFFF' : Color.Transparent)
    .borderRadius(this.isCard ? 18 : 0)
    .shadow(this.isCard ? { radius: 12, color: '#1015304B', offsetX: 0, offsetY: 6 } : { radius: 0, color: '#00000000', offsetX: 0, offsetY: 0 })
  }

  @Builder
  private buildTrainingItemRow(item: TrainingContentItem, index: number) {
    Row({ space: 10 }) {
      Text(`${index + 1}`)
        .width(24)
        .fontSize(11)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.getRowIndexColor(this.getResolvedItemStatus(item, index)))
        .textAlign(TextAlign.Center)

      Text(item.name)
        .layoutWeight(1)
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .fontColor('#1F2A44')
        .maxLines(1)

      this.buildItemStatusTag(this.getStatusText(this.getResolvedItemStatus(item, index)))
      this.buildDifficultyStars(item.levelNum)
    }
    .width('100%')
    .height(this.rowHeight)
    .padding({ left: this.rowHorizontalPadding, right: this.rowHorizontalPadding })
    .backgroundColor(this.getRowBackgroundColor(this.getResolvedItemStatus(item, index)))
    .borderRadius(10)
    .onClick(() => {
      this.onItemClick(item.name, this.getResolvedItemStatus(item, index) === 'completed')
      this.onItemCodeClick(item.code, item.name, this.getResolvedItemStatus(item, index) === 'completed')
      this.onItemIdClick(item.id, this.getResolvedItemStatus(item, index) === 'completed')
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

  private getResolvedItemStatus(item: TrainingContentItem, index: number): CourseTrainingItemRowStatus {
    const normalizedStatus = normalizeTrainItemStatus(item.status)
    if (normalizedStatus === 'completed') {
      return 'completed'
    }
    if (normalizedStatus === 'current' || normalizedStatus === 'in_progress') {
      return 'in_progress'
    }
    if (this.isCompleted(item.id, index)) {
      return 'completed'
    }
    if (this.isCurrentIndex(index)) {
      return 'in_progress'
    }
    return 'pending'
  }

  private getStatusText(status: CourseTrainingItemRowStatus): string {
    switch (status) {
      case 'completed':
        return '已完成'
      case 'in_progress':
        return '进行中'
      default:
        return '未完成'
    }
  }

  private getRowIndexColor(status: CourseTrainingItemRowStatus): string {
    if (status === 'completed') {
      return '#4E9E7B'
    }
    if (status === 'in_progress') {
      return '#2E79F4'
    }
    return '#7B8BA3'
  }

  private getRowBackgroundColor(status: CourseTrainingItemRowStatus): string {
    if (status === 'completed') {
      return '#F2FBF5'
    }
    if (status === 'in_progress') {
      return '#EDF4FF'
    }
    return '#F7FAFF'
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
