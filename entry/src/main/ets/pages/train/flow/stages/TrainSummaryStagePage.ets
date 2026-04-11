import { PageLoadingOverlay } from '../../../../components/PageLoadingOverlay'
import { TrainPageQueries, TrainPageService, TrainSessionRuntime, TrainSessionSummaryViewData } from '../../../../services/training/index'
import {
  TrainSummaryDimensionViewData,
  TrainSummaryHighlightItemViewData,
  TrainSummarySuggestionViewData
} from '../../../../services/training/model/TrainSessionSummaryViewData'

@Component
export struct TrainSummaryStagePage {
  @StorageLink('train.session.runtime') runtime: TrainSessionRuntime = TrainPageQueries.createEmptyRuntime()
  @StorageLink('train.session.summaryData') cachedSummaryData: TrainSessionSummaryViewData = TrainPageService.createEmptySummary()
  @StorageLink('train.session.summaryLoadedSessionId') summaryLoadedSessionId: number = 0

  @State summaryError: string = ''
  @State summaryData: TrainSessionSummaryViewData = TrainPageService.createEmptySummary()

  aboutToAppear(): void {
    if (this.summaryLoadedSessionId === this.runtime.sessionId && this.cachedSummaryData.sessionId === this.runtime.sessionId) {
      this.summaryData = this.cachedSummaryData
      this.summaryError = ''
      return
    }
    this.summaryData = TrainPageService.createEmptySummary()
    this.summaryError = '训练总结尚未准备完成'
  }

  private getSummaryTitle(): string {
    return this.summaryData.summaryTitle.length > 0 ? this.summaryData.summaryTitle : '训练总结'
  }

  private getSummaryDescription(): string {
    return this.summaryData.summaryDescription.length > 0 ? this.summaryData.summaryDescription : '本次训练总结已生成。'
  }

  private hasTrend(): boolean {
    return this.summaryData.trend.scores.length > 0
  }

  private hasDimensions(): boolean {
    return this.summaryData.dimensions.length > 0
  }

  private hasSuggestions(): boolean {
    return this.summaryData.suggestions.length > 0
  }

  private hasHighlightItems(): boolean {
    return this.summaryData.highlightItems.length > 0
  }

  @Builder
  private buildMetric(label: string, value: string): void {
    Column({ space: 6 }) {
      Text(label)
        .fontSize(12)
        .fontColor('#7A8CA7')

      Text(value)
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor('#2E79F4')
    }
    .layoutWeight(1)
    .padding({ left: 12, right: 12, top: 14, bottom: 14 })
    .backgroundColor('#FFFFFFFF')
    .borderRadius(16)
    .border({ width: 1, color: '#FFE6EDF8' })
    .shadow({ radius: 12, color: '#1015304B', offsetX: 0, offsetY: 6 })
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  private buildBadge(label: string): void {
    Text(label)
      .fontSize(11)
      .fontColor('#2E79F4')
      .padding({ left: 9, right: 9, top: 6, bottom: 6 })
      .backgroundColor('#FFEEF5FF')
      .borderRadius(12)
      .margin({ right: 8, bottom: 8 })
  }

  @Builder
  private buildTrendBar(label: string, score: number, highlighted: boolean): void {
    Column({ space: 6 }) {
      Text(String(score))
        .fontSize(11)
        .fontWeight(highlighted ? FontWeight.Bold : FontWeight.Medium)
        .fontColor(highlighted ? '#2E79F4' : '#6C7C95')

      Stack({ alignContent: Alignment.Bottom }) {
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor('#FFF4F8FE')
          .borderRadius(10)

        Column()
          .width('100%')
          .height(String(Math.max(8, Math.min(100, score))) + '%')
          .linearGradient({
            angle: 180,
            colors: highlighted ? [['#FF74AEFF', 0], ['#FF2E79F4', 1]] : [['#FFC9D8EB', 0], ['#FFAAC0D8', 1]]
          })
          .borderRadius(8)
      }
      .width('100%')
      .layoutWeight(1)
      .padding({ left: 6, right: 6, top: 6, bottom: 6 })
      .backgroundColor(highlighted ? '#FFEEF5FF' : '#FFF8FAFD')
      .borderRadius(12)

      Text(label)
        .fontSize(11)
        .fontColor('#8A99AD')
        .maxLines(1)
    }
    .width(52)
    .height(130)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  private buildDimensionRow(item: TrainSummaryDimensionViewData): void {
    Column({ space: 8 }) {
      Row() {
        Text(item.label)
          .fontSize(13)
          .fontColor('#30435F')

        Blank()

        Text(String(item.score))
          .fontSize(13)
          .fontWeight(FontWeight.Medium)
          .fontColor('#2E79F4')
      }
      .width('100%')

      Stack({ alignContent: Alignment.Start }) {
        Row()
          .width('100%')
          .height(8)
          .backgroundColor('#FFEAF1FB')
          .borderRadius(4)

        Row()
          .width(String(Math.max(0, Math.min(100, item.score))) + '%')
          .height(8)
          .linearGradient({
            angle: 90,
            colors: [['#FF7CB3FF', 0], ['#FF2E79F4', 1]]
          })
          .borderRadius(4)
      }
      .width('100%')

      if (item.description.length > 0) {
        Text(item.description)
          .width('100%')
          .fontSize(11)
          .fontColor('#7A8CA7')
          .lineHeight(17)
      }
    }
    .width('100%')
  }

  @Builder
  private buildSuggestionCard(item: TrainSummarySuggestionViewData): void {
    Column({ space: 8 }) {
      Text(item.title)
        .width('100%')
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .fontColor('#1F2A44')

      Text(item.description)
        .width('100%')
        .fontSize(13)
        .fontColor('#5F718B')
        .lineHeight(21)
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFFFF')
    .borderRadius(16)
    .border({ width: 1, color: '#FFE6EDF8' })
  }

  @Builder
  private buildHighlightItemCard(item: TrainSummaryHighlightItemViewData): void {
    Row() {
      Column({ space: 4 }) {
        Text(item.itemName.length > 0 ? item.itemName : item.itemCode)
          .width('100%')
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor('#1F2A44')
          .maxLines(1)

        Text(item.status === 'completed' ? '已完成' : '训练项')
          .fontSize(11)
          .fontColor('#7A8CA7')
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      Text(String(item.score))
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#2E79F4')
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFFFF')
    .borderRadius(16)
    .border({ width: 1, color: '#FFE6EDF8' })
  }

  @Builder
  private buildErrorCard(): void {
    Column({ space: 10 }) {
      Text('训练总结暂时不可用')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor('#1F2A44')

      Text(this.summaryError.length > 0 ? this.summaryError : '加载训练总结失败')
        .fontSize(13)
        .fontColor('#6E7F98')
        .lineHeight(20)
    }
    .width('100%')
    .padding(18)
    .backgroundColor('#FFFFFFFF')
    .borderRadius(20)
    .border({ width: 1, color: '#FFE6EDF8' })
    .shadow({ radius: 16, color: '#1015304B', offsetX: 0, offsetY: 8 })
  }

  build(): void {
    Column({ space: 14 }) {
      if (this.summaryError.length > 0) {
        this.buildErrorCard()
      } else {
        Row({ space: 14 }) {
          Stack({ alignContent: Alignment.Center }) {
            Column()
              .width(108)
              .height(108)
              .borderRadius(54)
              .backgroundColor('#FFEEF5FF')
              .border({ width: 1, color: '#FFDDE9F8' })

            Stack({ alignContent: Alignment.Center }) {
              Column()
                .width(84)
                .height(84)
                .borderRadius(42)
                .border({ width: 8, color: '#FFDCE8F8' })

              Column()
                .width(84)
                .height(84)
                .borderRadius(42)
                .clip(true)
                .linearGradient({
                  angle: 180,
                  colors: [['#FF73AEFF', 0], ['#FF2E79F4', 1]]
                })
                .opacity(0.2)

              Text(String(Math.round(this.summaryData.completionPercent)) + '%')
                .fontSize(17)
                .fontWeight(FontWeight.Bold)
                .fontColor('#2E79F4')
            }
          }

          Column({ space: 8 }) {
            Text(this.getSummaryTitle())
              .width('100%')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor('#1F2A44')

            Text(this.getSummaryDescription())
              .fontSize(13)
              .fontColor('#6E7F98')
              .lineHeight(20)

            if (this.summaryData.badges.length > 0) {
              Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Start, alignItems: ItemAlign.Start }) {
                ForEach(this.summaryData.badges, (badge: string) => {
                  this.buildBadge(badge)
                }, (badge: string) => badge)
              }
              .width('100%')
            }
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start)
        }
        .width('100%')
        .padding(18)
        .backgroundColor('#FFFFFFFF')
        .borderRadius(20)
        .border({ width: 1, color: '#FFE6EDF8' })
        .shadow({ radius: 16, color: '#1015304B', offsetX: 0, offsetY: 8 })

        Row({ space: 10 }) {
          this.buildMetric('完成项', String(this.summaryData.completedCount) + '/' + String(this.summaryData.totalCount))
          this.buildMetric('平均分', String(this.summaryData.averageScore))
          this.buildMetric('最高分', String(this.summaryData.bestScore))
        }
        .width('100%')

        if (this.hasTrend()) {
          Column({ space: 12 }) {
            Row() {
              Text(this.summaryData.trend.title.length > 0 ? this.summaryData.trend.title : '成绩走势')
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .fontColor('#1F2A44')

              Blank()

              Text(String(this.summaryData.trend.scores.length) + ' 项')
                .fontSize(12)
                .fontColor('#7A8CA7')
            }
            .width('100%')

            Row({ space: 10 }) {
              ForEach(this.summaryData.trend.scores, (score: number, index?: number) => {
                this.buildTrendBar(
                  this.summaryData.trend.labels[index ?? 0] ?? String((index ?? 0) + 1),
                  score,
                  (index ?? 0) === this.summaryData.trend.scores.length - 1
                )
              }, (score: number, index?: number) => String(index ?? 0) + '_' + String(score))
            }
            .width('100%')
            .height(136)
            .alignItems(VerticalAlign.Bottom)

            if (this.summaryData.trend.description.length > 0) {
              Text(this.summaryData.trend.description)
                .width('100%')
                .fontSize(12)
                .fontColor('#7A8CA7')
                .lineHeight(18)
            }
          }
          .width('100%')
          .padding(18)
          .backgroundColor('#FFFFFFFF')
          .borderRadius(20)
          .border({ width: 1, color: '#FFE6EDF8' })
          .shadow({ radius: 16, color: '#1015304B', offsetX: 0, offsetY: 8 })
        }

        if (this.hasDimensions()) {
          Column({ space: 12 }) {
            Text('能力分布')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor('#1F2A44')

            ForEach(this.summaryData.dimensions, (item: TrainSummaryDimensionViewData) => {
              this.buildDimensionRow(item)
            }, (item: TrainSummaryDimensionViewData) => item.key + '_' + item.label)
          }
          .width('100%')
          .padding(18)
          .backgroundColor('#FFFFFFFF')
          .borderRadius(20)
          .border({ width: 1, color: '#FFE6EDF8' })
          .shadow({ radius: 16, color: '#1015304B', offsetX: 0, offsetY: 8 })
        }

        if (this.hasSuggestions()) {
          Column({ space: 10 }) {
            Text('系统建议')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor('#1F2A44')

            ForEach(this.summaryData.suggestions, (item: TrainSummarySuggestionViewData) => {
              this.buildSuggestionCard(item)
            }, (item: TrainSummarySuggestionViewData) => item.title + '_' + item.description)
          }
          .width('100%')
        }

        if (this.hasHighlightItems()) {
          Column({ space: 10 }) {
            Text('高光训练项')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor('#1F2A44')

            ForEach(this.summaryData.highlightItems, (item: TrainSummaryHighlightItemViewData) => {
              this.buildHighlightItemCard(item)
            }, (item: TrainSummaryHighlightItemViewData) => item.itemCode + '_' + String(item.score))
          }
          .width('100%')
        }
      }
    }
    .width('100%')
  }
}
