/**
 * CoursePage 页面文件，负责页面展示与交互承接。
 */

import { BackHeaderBar } from '../../../components/BackHeaderBar'
import { FocusTagChip } from '../../../components/FocusTagChip'
import { CourseTrainingItemList } from '../../../components/CourseTrainingItemList'
import { User, createUser } from '../../../domain/entity/User'
import { go, goBack } from '../../../router/Router'
import {
  buildCourseDetailBackPath,
  buildCourseTrainingPath,
  canContinueCourseTraining,
  CourseDetailPageData,
  getCourseDetailIntroText,
  getNextCourseTrainingItemCode,
  loadCourseDetailPageData,
  readCachedCourseDetailView,
  toggleCourseDetailFavorite
} from '../../../services/course/index'
import { isCourseFavoritedInUser } from '../../../services/user/index'
import { getCoursePageRouteCode } from './CoursePageRouteAdapter'
import { showGlobalToast } from '../../../services/ui/index'
import { PageLoadingOverlay } from '../../../components/PageLoadingOverlay'
import { hilog } from '@kit.PerformanceAnalysisKit'
import { hasCourseDetailRecord } from '../../../repository/course/CourseDetailRepository'

const COURSE_DETAIL_TRACE_DOMAIN = 0x0000
const COURSE_DETAIL_TRACE_TAG = 'CourseDetailTrace'

function traceCoursePage(stage: string, message: string): void {
  hilog.info(COURSE_DETAIL_TRACE_DOMAIN, COURSE_DETAIL_TRACE_TAG, '[%{public}s] %{public}s', stage, message)
}


@Component
export struct CoursePage {
  @StorageLink('user') user: User = createUser()
  @StorageLink('route.path') routePath: string = '/launch'
  @State isIntroExpanded: boolean = false
  @State detailLoading: boolean = true
  @State detailRefreshing: boolean = false
  @State pageData: CourseDetailPageData = new CourseDetailPageData()
  @State displayTotalItemCount: number = 0
  @State displayCompletedItemCount: number = 0
  @State displayProgressPercent: number = 0
  @State cachedFavoritedStatus: boolean = false

  private readonly pageScroller: Scroller = new Scroller()

  private shouldRetryLoad(pageData: CourseDetailPageData): boolean {
    if (pageData.courseCode.trim().length === 0) return false
    return pageData.totalItemCount <= 0
  }

  private hasRenderableCache(_pageData: CourseDetailPageData): boolean {
    const courseCode = this.getCourseCode()
    return courseCode.trim().length > 0 && hasCourseDetailRecord(courseCode)
  }

  private syncDisplayStats(source: CourseDetailPageData): void {
    let totalCount = source.totalItemCount
    if (totalCount <= 0 && source.courseItems.length > 0) {
      totalCount = source.courseItems.length
    }

    let completedCount = source.completedItemCount
    if (completedCount <= 0 && source.completedItemIds.length > 0) {
      completedCount = source.completedItemIds.length
    }
    if (completedCount < 0) {
      completedCount = 0
    }
    if (totalCount > 0 && completedCount > totalCount) {
      completedCount = totalCount
    }

    let progressPercent = source.sessionProgressPercent
    if ((!Number.isFinite(progressPercent) || progressPercent <= 0) && totalCount > 0 && completedCount > 0) {
      progressPercent = (completedCount * 100) / totalCount
    }
    if (!Number.isFinite(progressPercent) || progressPercent < 0) {
      progressPercent = 0
    }
    if (progressPercent > 100) {
      progressPercent = 100
    }

    this.displayTotalItemCount = totalCount
    this.displayCompletedItemCount = completedCount
    this.displayProgressPercent = progressPercent
  }

  // 进入页面先做一次“缓存预热 + 异步远端刷新”，减少首屏空白时间。
  aboutToAppear() {
    this.detailLoading = true
    this.pageData = new CourseDetailPageData()
    this.displayTotalItemCount = 0
    this.displayCompletedItemCount = 0
    this.displayProgressPercent = 0
    const cachedPageData = this.applyRouteContext()
    this.detailLoading = !this.hasRenderableCache(cachedPageData)
    // 缓存当前收藏状态，防止在页面销毁时被重置
    this.cachedFavoritedStatus = this.isCourseFavoritedImpl()
    void this.loadCourseContext()
  }


  private getCourseCode(): string {
    return getCoursePageRouteCode(this.routePath)
  }

  // 第一步：仅用本地缓存快速填充页面，避免等待接口返回。
  private applyRouteContext(): CourseDetailPageData {
    const courseCode = this.getCourseCode()
    const cachedPageData = readCachedCourseDetailView(courseCode)
    this.pageData = cachedPageData
    this.syncDisplayStats(cachedPageData)
    traceCoursePage('CoursePage.applyRouteContext',
      'courseCode=' + courseCode
        + ',cachedItemsCount=' + String(cachedPageData.courseItems.length)
        + ',cachedProgress=' + String(cachedPageData.sessionProgressPercent)
        + ',cachedCompletedItemCount=' + String(cachedPageData.completedItemCount)
        + ',cachedTotalItemCount=' + String(cachedPageData.totalItemCount)
        + ',cachedCurrentItemCode=' + cachedPageData.currentItemCode
        + ',displayCompletedItemCount=' + String(this.displayCompletedItemCount)
        + ',displayTotalItemCount=' + String(this.displayTotalItemCount)
        + ',displayProgress=' + String(this.displayProgressPercent))
    return cachedPageData
  }

  // 第二步：拉取完整课程详情链路（详情 + 会话 + 训练项），最后统一回填 pageData。
  private async loadCourseContext(): Promise<void> {
    const courseCode = this.getCourseCode()
    if (this.detailRefreshing || courseCode.trim().length === 0) return
    traceCoursePage('CoursePage.loadCourseContext.start',
      'courseCode=' + courseCode + ',detailLoading=' + String(this.detailLoading))
    this.detailRefreshing = true
    if (!this.hasRenderableCache(this.pageData)) {
      this.detailLoading = true
      this.pageData.detailTip = '\u6b63\u5728\u52a0\u8f7d\u8bfe\u7a0b\u5185\u5bb9...'
    }
    try {
      let loaded = await loadCourseDetailPageData(courseCode)
      traceCoursePage('CoursePage.loadCourseContext.first-load',
        'courseCode=' + courseCode
          + ',itemsCount=' + String(loaded.courseItems.length)
          + ',progress=' + String(loaded.sessionProgressPercent)
          + ',completedItemCount=' + String(loaded.completedItemCount)
          + ',totalItemCount=' + String(loaded.totalItemCount)
          + ',currentItemCode=' + loaded.currentItemCode)
      // 首次进入若统计字段仍为空，立即做一次同页重试，避免必须返回后再进才显示。
      if (this.shouldRetryLoad(loaded)) {
        traceCoursePage('CoursePage.loadCourseContext.retry',
          'courseCode=' + courseCode + ',reason=totalItemCount<=0')
        loaded = await loadCourseDetailPageData(courseCode)
        traceCoursePage('CoursePage.loadCourseContext.retry-load',
          'courseCode=' + courseCode
            + ',itemsCount=' + String(loaded.courseItems.length)
            + ',progress=' + String(loaded.sessionProgressPercent)
            + ',completedItemCount=' + String(loaded.completedItemCount)
            + ',totalItemCount=' + String(loaded.totalItemCount)
            + ',currentItemCode=' + loaded.currentItemCode)
      }
      this.pageData = loaded
      this.syncDisplayStats(loaded)
      this.detailLoading = !this.hasRenderableCache(loaded)
      traceCoursePage('CoursePage.loadCourseContext.applied',
        'courseCode=' + courseCode
          + ',itemsCount=' + String(this.pageData.courseItems.length)
          + ',progress=' + String(this.pageData.sessionProgressPercent)
          + ',completedItemCount=' + String(this.pageData.completedItemCount)
          + ',totalItemCount=' + String(this.pageData.totalItemCount)
          + ',currentItemCode=' + this.pageData.currentItemCode
          + ',displayCompletedItemCount=' + String(this.displayCompletedItemCount)
          + ',displayTotalItemCount=' + String(this.displayTotalItemCount)
          + ',displayProgress=' + String(this.displayProgressPercent))
    } finally {
      this.detailRefreshing = false
      traceCoursePage('CoursePage.loadCourseContext.finish',
        'courseCode=' + courseCode + ',detailLoading=' + String(this.detailLoading))
    }
  }

  private isCourseFavoritedImpl(): boolean {
    const code = this.getCourseCode()
    return code.length > 0 && isCourseFavoritedInUser(this.user, code)
  }

  private isCourseFavorited(): boolean {
    // 使用缓存状态，防止在页面销毁时 StorageLink 的变化影响 UI
    return this.cachedFavoritedStatus
  }

  private hasTrainableItem(): boolean {
    return getNextCourseTrainingItemCode(this.pageData.courseItems, this.pageData.completedItemIds).trim().length > 0
  }

  private async handleToggleFavorite(): Promise<void> {
    const code = this.getCourseCode()
    if (code.length === 0) return
    const result = await toggleCourseDetailFavorite(code, this.pageData.courseName, this.pageData.trainingType)
    showGlobalToast(result.message, result.tone)
    // 异步操作完成后，更新缓存的收藏状态
    this.cachedFavoritedStatus = this.isCourseFavoritedImpl()
  }

  private openTrainingItem(itemCode: string): void {
    const courseCode = this.getCourseCode()
    if (courseCode.length === 0) return
    go(buildCourseTrainingPath(courseCode, itemCode))
  }

  private backToTrain(): void {
    goBack(buildCourseDetailBackPath(this.pageData.trainingType), true)
  }

  build() {
    Column() {
      Column() {
      BackHeaderBar({
        title: '\u8bfe\u7a0b\u8be6\u60c5',
        onBack: () => { this.backToTrain() }
      })

      if (!this.detailLoading) {
        Scroll(this.pageScroller) {
          Column({ space: 14 }) {
            this.buildHeroCard()
            this.buildMetaCard()
            this.buildActionRow()

            if (this.pageData.detailTip.length > 0) {
              Text(this.pageData.detailTip)
                .width('100%')
                .fontSize(13)
                .fontColor('#E5484D')
            }

            CourseTrainingItemList({
              items: this.pageData.courseItems,
              completedCount: this.displayCompletedItemCount,
              completedItemIds: this.pageData.completedItemIds,
              currentIndex: this.pageData.currentItemIndex,
              showHeader: true,
              onItemCodeClick: (itemCode: string, _itemName: string, _completed: boolean) => {
                this.openTrainingItem(itemCode)
              }
            })
          }
          .width('100%')
          .justifyContent(FlexAlign.Start)
          .alignItems(HorizontalAlign.Start)
          .constraintSize({ minHeight: '100%' })
          .padding({ left: 16, right: 16, top: 8, bottom: 64 })
        }
        .width('100%')
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
        .onAppear(() => {
          this.pageScroller.scrollTo({ xOffset: 0, yOffset: 0 })
          void this.loadCourseContext()
        })
      } else {
        PageLoadingOverlay({
          text: '\u6b63\u5728\u52a0\u8f7d\u8bfe\u7a0b\u5185\u5bb9...'
        })
          .width('100%')
          .layoutWeight(1)
      }
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Start)
      .alignItems(HorizontalAlign.Start)
      .backgroundColor('#FFFFFF')
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFFFFF')
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
  }

  @Builder
  private buildHeroCard() {
    Stack({ alignContent: Alignment.Center }) {
      if (this.pageData.coverUrl.length > 0) {
        Image(this.pageData.coverUrl)
          .width('100%')
          .height(186)
          .objectFit(ImageFit.Cover)
          .borderRadius(22)
      } else {
        Column()
          .width('100%')
          .height(186)
          .linearGradient({ angle: 135, colors: [['#DCEBFF', 0], ['#BBD6FF', 1]] })
          .borderRadius(22)
      }
    }
    .width('100%')
    .height(186)
    .backgroundColor('#DCEBFF')
    .borderRadius(22)
    .clip(true)
    .shadow({ radius: 20, color: '#1F1A2C47', offsetX: 0, offsetY: 10 })
  }

  @Builder
  private buildMetaCard() {
    Column({ space: 10 }) {
      Text(this.pageData.courseName)
        .width('100%')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor('#1F2A44')
        .maxLines(2)

      Text(getCourseDetailIntroText(this.pageData.courseIntro))
        .width('100%')
        .fontSize(13)
        .fontColor('#5F718B')
        .lineHeight(20)
        .maxLines(this.isIntroExpanded ? 99 : 4)
        .textOverflow({ overflow: TextOverflow.Ellipsis })

      if (getCourseDetailIntroText(this.pageData.courseIntro).length > 80) {
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

      Row({ space: 10 }) {
        this.buildTotalStatPill()
        this.buildCompletedStatPill()
        this.buildProgressStatPill()
      }
      .width('100%')

      if (this.pageData.tags.length > 0) {
        Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Start, alignItems: ItemAlign.Start }) {
          ForEach(this.pageData.tags, (tag: string) => {
            FocusTagChip({ label: tag })
          }, (tag: string) => tag)
        }
        .width('100%')
      }
    }
    .width('100%')
    .padding({ left: 14, right: 14, top: 16, bottom: 16 })
    .backgroundColor('#FFFFFF')
    .borderRadius(20)
    .shadow({ radius: 14, color: '#1015304B', offsetX: 0, offsetY: 8 })
  }

  @Builder
  private buildActionRow() {
    Row() {
      Button() {
        Row({ space: 6 }) {
          SymbolGlyph(this.isCourseFavorited() ? $r('sys.symbol.star_fill') : $r('sys.symbol.star'))
            .fontSize(16)
            .fontColor([this.isCourseFavorited() ? '#2E79F4' : '#6F85A3'])
          Text(this.isCourseFavorited() ? '已收藏' : '收藏')
            .fontSize(13)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.isCourseFavorited() ? '#2E79F4' : '#6F85A3')
        }
      }
      .width(108)
      .height(46)
      .padding({ left: 14, right: 14 })
      .backgroundColor('#EDF4FF')
      .borderRadius(16)
      .stateEffect(false)
      .onClick(() => {
        void this.handleToggleFavorite()
      })

      Blank()

      Button(canContinueCourseTraining(this.displayCompletedItemCount, this.pageData.currentItemIndex) ? '继续练习' : '开始练习')
        .width(212)
        .height(46)
        .fontSize(15)
        .fontWeight(FontWeight.Medium)
        .fontColor('#FFFFFF')
        .linearGradient({
          angle: 90,
          colors: this.hasTrainableItem() ? [['#5FA7FF', 0], ['#2E79F4', 1]] : [['#C4D3E8', 0], ['#AEBFD8', 1]]
        })
        .borderRadius(16)
        .enabled(this.hasTrainableItem())
        .opacity(this.hasTrainableItem() ? 1 : 0.72)
        .onClick(() => {
          const nextItemCode = getNextCourseTrainingItemCode(this.pageData.courseItems, this.pageData.completedItemIds)
          if (nextItemCode.trim().length === 0) {
            return
          }
          this.openTrainingItem(nextItemCode)
        })
    }
    .width('100%')
  }

  @Builder
  private buildTotalStatPill() {
    Column({ space: 4 }) {
      Text(`${this.displayTotalItemCount}`)
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#1F2A44')
      Text('训练项')
        .fontSize(11)
        .fontColor('#7A8CA7')
    }
    .padding({ left: 12, right: 12, top: 10, bottom: 10 })
    .backgroundColor('#F7FAFF')
    .borderRadius(14)
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  private buildCompletedStatPill() {
    Column({ space: 4 }) {
      Text(`${this.displayCompletedItemCount}`)
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#1F2A44')
      Text('已完成')
        .fontSize(11)
        .fontColor('#7A8CA7')
    }
    .padding({ left: 12, right: 12, top: 10, bottom: 10 })
    .backgroundColor('#F7FAFF')
    .borderRadius(14)
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  private buildProgressStatPill() {
    Column({ space: 4 }) {
      Text(`${Math.round(this.displayProgressPercent)}%`)
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#1F2A44')
      Text('进度')
        .fontSize(11)
        .fontColor('#7A8CA7')
    }
    .padding({ left: 12, right: 12, top: 10, bottom: 10 })
    .backgroundColor('#F7FAFF')
    .borderRadius(14)
    .alignItems(HorizontalAlign.Start)
  }

}
