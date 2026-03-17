import common from '@ohos.app.ability.common'
import { readToken } from '../api/AuthStorage'
import { getCourseDetail } from '../api/CourseApi'
import { FALLBACK_COVER_URL, TrainingItem, getMockTrainingItems } from './train/TrainData'
import { CourseTrainingItemList } from './train/components/CourseTrainingItemList'
import { FocusTagChip } from './train/components/FocusTagChip'

@Component
export struct CourseDetailPage {
  @Prop apiBaseUrl: string = ''
  @Prop courseName: string = '课程详情'
  @Prop courseCode: string = ''
  @Prop courseIntro: string = ''
  @Prop coverUrl: string = ''
  @Prop trainingType: string = 'gesture'
  @Prop courseTag1: string = ''
  @Prop courseTag2: string = ''
  @Prop courseTag3: string = ''
  @Prop isCourseFavorited: boolean = false
  @State isIntroExpanded: boolean = false
  @State displayCourseName: string = ''
  @State displayCourseIntro: string = ''
  @State displayCoverUrl: string = ''
  @State displayTrainingType: string = 'gesture'
  @State displayTags: string[] = []
  @State detailLoading: boolean = false
  @State detailTip: string = ''
  onBack: () => void = () => {}
  onToggleFavorite: (courseCode: string) => void = (_courseCode: string) => {}
  onStartTraining: (phrase: string) => void = (_phrase: string) => {}
  onOpenTrainingItem: (phrase: string, toResult: boolean) => void = (_phrase: string, _toResult: boolean) => {}

  private readonly trainingItems: TrainingItem[] = getMockTrainingItems()
  private readonly fallbackCoverUrl: string = FALLBACK_COVER_URL
  private readonly pageScroller: Scroller = new Scroller()

  aboutToAppear() {
    this.displayCourseName = this.courseName
    this.displayCourseIntro = this.courseIntro
    this.displayCoverUrl = this.coverUrl
    this.displayTrainingType = this.trainingType
    this.displayTags = this.getPropTags()
    this.loadCourseDetail()
  }

  private getAbilityContext(): common.BaseContext {
    return this.getUIContext().getHostContext() as common.BaseContext
  }

  private getPropTags(): string[] {
    const tags: string[] = []
    if (this.courseTag1.trim().length > 0) {
      tags.push(this.courseTag1)
    }
    if (this.courseTag2.trim().length > 0) {
      tags.push(this.courseTag2)
    }
    if (this.courseTag3.trim().length > 0) {
      tags.push(this.courseTag3)
    }
    return tags
  }

  private normalizeTrainingType(value: string): string {
    if (value === 'voice') {
      return 'speech'
    }
    if (value === 'speech') {
      return 'speech'
    }
    return 'gesture'
  }

  private async loadCourseDetail() {
    if (this.detailLoading || this.courseCode.trim().length === 0) {
      return
    }
    this.detailLoading = true
    this.detailTip = '加载课程详情中...'
    try {
      const token = await readToken(this.getAbilityContext())
      if (token.length === 0) {
        this.detailTip = '登录已过期，请重新登录。'
        return
      }

      const result = await getCourseDetail(this.apiBaseUrl, token, this.courseCode)
      if (!result.ok || !result.data) {
        this.detailTip = result.message.length > 0 ? result.message : `课程详情加载失败（错误码 ${result.code}）`
        return
      }

      this.displayCourseName = result.data.courseName
      this.displayCourseIntro = result.data.intro
      this.displayCoverUrl = result.data.coverUrl
      this.displayTrainingType = this.normalizeTrainingType(result.data.trainingType)
      this.displayTags = result.data.tags
      this.detailTip = ''
    } catch (_error) {
      this.detailTip = '网络异常，无法加载课程详情。'
    } finally {
      this.detailLoading = false
    }
  }

  build() {
    Column() {
      this.buildHeader()

      Scroll(this.pageScroller) {
        Column({ space: 14 }) {
          this.buildHeroCard()
          if (this.detailLoading) {
            Text('加载中...')
              .fontSize(13)
              .fontColor('#6F83A2')
          } else if (this.detailTip.length > 0) {
            Text(this.detailTip)
              .fontSize(13)
              .fontColor('#E5484D')
          }
          this.buildCourseMetaSection(this.getCourseItemCount(), this.getProgressText())
          this.buildActionRow(this.getNextPhrase(), this.getCanContinue())

          CourseTrainingItemList({
            items: this.getCourseTrainingItems(),
            completedCount: this.getMockCompletedCount(this.getCourseItemCount()),
            showHeader: true,
            onItemClick: (itemName: string, completed: boolean) => {
              this.onOpenTrainingItem(itemName, completed)
            }
          })
        }
        .width('100%')
        .justifyContent(FlexAlign.Start)
        .alignItems(HorizontalAlign.Start)
        .constraintSize({ minHeight: '100%' })
        .padding({ left: 16, right: 16, top: 8, bottom: 0 })
      }
      .width('100%')
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
      .onAppear(() => {
        this.pageScroller.scrollTo({ xOffset: 0, yOffset: 0 })
      })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Start)
    .alignItems(HorizontalAlign.Start)
    .backgroundColor('#FFFFFF')
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
  }

  @Builder
  private buildHeader() {
    Row({ space: 10 }) {
      Button() {
        SymbolGlyph($r('sys.symbol.chevron_backward'))
          .fontSize(16)
          .fontColor(['#5F7593'])
      }
      .width(32)
      .height(32)
      .backgroundColor('#F4F8FF')
      .borderRadius(16)
      .stateEffect(false)
      .onClick(() => {
        this.onBack()
      })

      Text('课程详情')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor('#1F2A44')
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 8, bottom: 10 })
    .backgroundColor('#FFFFFF')
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])
  }

  @Builder
  private buildHeroCard() {
    Stack({ alignContent: Alignment.Center }) {
      Image(this.displayCoverUrl.length > 0 ? this.displayCoverUrl : this.fallbackCoverUrl)
        .width('100%')
        .height(186)
        .objectFit(ImageFit.Cover)
        .borderRadius(22)

      Column()
        .width('100%')
        .height(186)
        .linearGradient({
          angle: 180,
          colors: [['#001B2D1A', 0], ['#001B2D4D', 1]]
        })
        .borderRadius(22)
    }
    .width('100%')
    .height(186)
    .shadow({ radius: 20, color: '#1A2C471F', offsetX: 0, offsetY: 10 })
  }

  @Builder
  private buildCourseMetaSection(itemCount: number, progressText: string) {
    Column({ space: 8 }) {
      Text(this.displayCourseName)
        .width('100%')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor('#1F2A44')
        .maxLines(2)

      if (this.isIntroExpanded) {
        Text(this.getCourseIntroText())
          .width('100%')
          .fontSize(13)
          .fontColor('#5F718B')
          .lineHeight(20)
      } else {
        Text(this.getCourseIntroText())
          .width('100%')
          .fontSize(13)
          .fontColor('#5F718B')
          .lineHeight(20)
          .maxLines(4)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }

      if (this.shouldShowIntroToggle()) {
        Row() {
          Blank()
          Text(this.isIntroExpanded ? '收起' : '详情')
            .fontSize(12)
            .fontWeight(FontWeight.Medium)
            .fontColor('#2E79F4')
            .onClick(() => {
              this.isIntroExpanded = !this.isIntroExpanded
            })
        }
        .width('100%')
      }

      if (this.displayTags.length > 0) {
        Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Start, alignItems: ItemAlign.Start }) {
          ForEach(this.displayTags, (tag: string) => {
            FocusTagChip({
              label: tag,
              chipBgColor: '#EEF5FF',
              chipFontColor: '#2E79F4'
            })
          }, (tag: string) => tag)
        }
        .width('100%')
      }
    }
    .width('100%')
    .justifyContent(FlexAlign.Start)
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  private buildActionRow(nextPhrase: string, canContinue: boolean) {
    Row() {
      Button() {
        Row({ space: 6 }) {
          SymbolGlyph(this.isCourseFavorited ? $r('sys.symbol.star_fill') : $r('sys.symbol.star'))
            .fontSize(16)
            .fontColor([this.isCourseFavorited ? '#2E79F4' : '#6F85A3'])

          Text(this.isCourseFavorited ? '已收藏' : '收藏')
            .fontSize(13)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.isCourseFavorited ? '#2E79F4' : '#6F85A3')
        }
      }
      .width(108)
      .height(46)
      .padding({ left: 14, right: 14 })
      .backgroundColor('#EDF4FF')
      .borderRadius(16)
      .stateEffect(false)
      .onClick(() => {
        this.onToggleFavorite(this.courseCode)
      })

      Blank()

      Button(canContinue ? '继续练习' : '开始练习')
        .width(212)
        .height(46)
        .fontSize(15)
        .fontWeight(FontWeight.Medium)
        .fontColor('#FFFFFF')
        .linearGradient({
          angle: 90,
          colors: [['#5FA7FF', 0], ['#2E79F4', 1]]
        })
        .borderRadius(16)
        .onClick(() => {
          this.onOpenTrainingItem(nextPhrase, false)
        })
    }
    .width('100%')
  }

  private getMockCompletedCount(totalCount: number): number {
    if (this.courseCode === 'COURSE-301') {
      return Math.min(3, totalCount)
    }
    return 0
  }

  private getNextPhrase(): string {
    const items = this.getCourseTrainingItems()
    const completedCount = this.getMockCompletedCount(items.length)
    if (items.length === 0) {
      return '你好'
    }
    const nextIndex = Math.min(completedCount, items.length - 1)
    return items[nextIndex].name
  }

  private getCourseItemCount(): number {
    return this.getCourseTrainingItems().length
  }

  private getCanContinue(): boolean {
    return this.getMockCompletedCount(this.getCourseItemCount()) > 0
  }

  private getProgressText(): string {
    const total = this.getCourseItemCount()
    return `${this.getMockCompletedCount(total)}/${total}`
  }

  private getCourseIntroText(): string {
    if (this.displayCourseIntro.length > 0) {
      return this.displayCourseIntro
    }
    return '本课程将带你逐步完成训练目标。'
  }

  private shouldShowIntroToggle(): boolean {
    return this.getCourseIntroText().length > 80
  }

  private getCourseTrainingItems(): TrainingItem[] {
    const result: TrainingItem[] = []
    for (let i = 0; i < this.trainingItems.length; i += 1) {
      const item = this.trainingItems[i]
      if (this.isItemMatchedToCourse(item)) {
        result.push(item)
      }
    }
    result.sort((a: TrainingItem, b: TrainingItem) => a.sortNum - b.sortNum)
    return result
  }

  private isItemMatchedToCourse(item: TrainingItem): boolean {
    if (this.courseCode === 'COURSE-301') {
      return item.majorCategoryCode === 'voice' && item.code.startsWith('VOI_')
    }
    if (this.courseCode === 'COURSE-302') {
      return item.id === 3
    }
    if (this.courseCode === 'COURSE-101') {
      return item.id === 1
    }
    if (this.displayTrainingType === 'gesture') {
      return item.majorCategoryCode === 'gesture'
    }
    return item.majorCategoryCode === 'voice'
  }
}

