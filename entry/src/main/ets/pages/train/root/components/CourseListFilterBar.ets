/**
 * 课程列表筛选栏组件。
 */
import { SortType } from '../../../../services/course/index'
import { APP_COLORS, APP_RADIUS, APP_SHADOW } from '../../../../config/AppStyle'

@Component
export struct CourseListFilterBar {
  @Prop keyword: string = ''
  @Prop sortType: SortType = 'default'
  @Prop allTags: string[] = []
  @Prop selectedTags: string[] = []
  private readonly extraTagScroller: Scroller = new Scroller()
  private readonly extraTagFadeWidth: number = 36
  onKeywordChange: (value: string) => void = (_value: string) => {}
  onKeywordSubmit: () => void = () => {}
  onToggleTag: (tag: string) => void = (_tag: string) => {}
  onSelectSort: (sortType: SortType) => void = (_sortType: SortType) => {}

  build() {
    Column({ space: 14 }) {
      Row({ space: 10 }) {
        Stack({ alignContent: Alignment.Center }) {
          Row()
            .width(30)
            .height(30)
            .backgroundColor('#EEF4FF')
            .borderRadius(15)

          SymbolGlyph($r('sys.symbol.magnifyingglass'))
            .fontSize(15)
            .fontColor([APP_COLORS.primary])
        }
        .width(30)
        .height(30)

        TextInput({ placeholder: '搜索课程名称或关键词', text: this.keyword })
          .layoutWeight(1)
          .height(36)
          .fontSize(14)
          .backgroundColor(Color.Transparent)
          .placeholderColor(APP_COLORS.mutedText)
          .enterKeyType(EnterKeyType.Search)
          .onChange((value: string) => { this.onKeywordChange(value) })
          .onSubmit(() => { this.onKeywordSubmit() })
      }
      .width('100%')
      .height(48)
      .padding({ left: 10, right: 12 })
      .backgroundColor(APP_COLORS.surface)
      .borderRadius(APP_RADIUS.xl)
      .shadow(APP_SHADOW.soft)

      Row() {
        Row({ space: 8 }) {
          this.buildTypeChip('手势')
          this.buildTypeChip('口语')
        }
        Blank()
        Row({ space: 14 }) {
          this.buildSortTab('综合', 'default')
          this.buildSortTab('热度', 'hot')
          this.buildSortTab('最近更新', 'latest')
        }
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)

      Stack({ alignContent: Alignment.End }) {
        Scroll(this.extraTagScroller) {
          Row({ space: 8 }) {
            ForEach(this.allTags, (tag: string) => { this.buildExtraTagChip(tag) }, (tag: string) => tag)
          }
          .padding({ right: this.extraTagFadeWidth + 24 })
        }
        .width('100%')
        .scrollable(ScrollDirection.Horizontal)
        .scrollBar(BarState.Off)

        Row()
          .width(this.extraTagFadeWidth)
          .height('100%')
          .linearGradient({
            angle: 90,
            colors: [['#00F7FAFE', 0], ['#CCF7FAFE', 0.28], ['#F2F7FAFE', 0.55], ['#FFF7FAFE', 1]]
          })
          .hitTestBehavior(HitTestMode.None)
      }
      .width('100%')
      .height(42)
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 8, bottom: 12 })
    .backgroundColor(APP_COLORS.backgroundStart)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])
  }

  private isTagSelected(tag: string): boolean {
    return this.selectedTags.includes(tag)
  }

  private isSortSelected(sortType: SortType): boolean {
    return this.sortType === sortType
  }

  @Builder
  private buildTypeChip(tag: string) {
    Text(tag)
      .fontSize(12)
      .fontWeight(this.isTagSelected(tag) ? FontWeight.Medium : FontWeight.Regular)
      .fontColor(this.isTagSelected(tag) ? '#FFFFFF' : '#5D7393')
      .padding({ left: 13, right: 13, top: 8, bottom: 8 })
      .backgroundColor(this.isTagSelected(tag) ? APP_COLORS.primary : APP_COLORS.surfaceTint)
      .borderRadius(16)
      .shadow(this.isTagSelected(tag) ? { radius: 10, color: '#262E79F4', offsetX: 0, offsetY: 4 } : { radius: 0, color: '#00000000', offsetX: 0, offsetY: 0 })
      .onClick(() => { this.onToggleTag(tag) })
  }

  @Builder
  private buildSortTab(label: string, sortType: SortType) {
    Column({ space: 5 }) {
      Text(label)
        .fontSize(12)
        .fontWeight(this.isSortSelected(sortType) ? FontWeight.Medium : FontWeight.Regular)
        .fontColor(this.isSortSelected(sortType) ? APP_COLORS.primary : '#6C7F9A')

      Row()
        .width(24)
        .height(3)
        .backgroundColor(this.isSortSelected(sortType) ? APP_COLORS.primary : Color.Transparent)
        .borderRadius(2)
    }
    .padding({ left: 2, right: 2, top: 6, bottom: 2 })
    .alignItems(HorizontalAlign.Start)
    .onClick(() => { this.onSelectSort(sortType) })
  }

  @Builder
  private buildExtraTagChip(tag: string) {
    Text(tag)
      .fontSize(12)
      .fontWeight(this.isTagSelected(tag) ? FontWeight.Medium : FontWeight.Regular)
      .fontColor(this.isTagSelected(tag) ? APP_COLORS.primary : '#627892')
      .padding({ left: 12, right: 12, top: 7, bottom: 7 })
      .backgroundColor(this.isTagSelected(tag) ? '#EAF2FF' : '#F4F7FB')
      .borderRadius(15)
      .border({ width: 1, color: this.isTagSelected(tag) ? '#D6E6FF' : '#E8EEF6' })
      .onClick(() => { this.onToggleTag(tag) })
  }
}
