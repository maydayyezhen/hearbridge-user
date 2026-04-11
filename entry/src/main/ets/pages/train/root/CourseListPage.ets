/**
 * 课程列表页面。
 */

import { APP_COLORS, APP_RADIUS, APP_SHADOW } from '../../../config/AppStyle'
import { Course } from '../../../domain/entity/Course'
import {
  createCourseListSelectedTags,
  findCourseInList,
  getCourseOpenPhrase,
  loadCourseListState,
  loadCourseListTags,
  normalizeCourseListTrainingType,
  shouldSwitchCourseListSort,
  SortType,
  toggleCourseListTagState
} from '../../../services/course/index'
import { CourseCardList } from './components/CourseCardList'
import { CourseListFilterBar } from './components/CourseListFilterBar'

function isGestureCourseTag(tag: string): boolean {
  return tag === '手势'
}

function isSpeechCourseTag(tag: string): boolean {
  return tag === '口语'
}

function isCourseTypeTag(tag: string): boolean {
  return isGestureCourseTag(tag) || isSpeechCourseTag(tag)
}

@Component
export struct CourseListPage {
  @Prop favoriteCourseCodes: string[] = []
  @Prop initialTrainingType: string = 'gesture'
  onToggleCourseFavorite: (course: Course) => void = (_course: Course) => {}
  onOpenCourse: (courseName: string, courseCode: string, phrase: string, toResult: boolean, courseTrainingType: string) => void =
    (_courseName: string, _courseCode: string, _phrase: string, _toResult: boolean, _courseTrainingType: string) => {}

  @State currentTrainingType: string = 'gesture'
  @State keyword: string = ''
  @State sortType: SortType = 'default'
  @State selectedTags: string[] = []
  @State courseTags: string[] = []
  @State courses: Course[] = []
  @State loading: boolean = true
  @State loadingMore: boolean = false
  @State hasMore: boolean = true
  @State pageNo: number = 1
  @State total: number = 0
  @State tip: string = ''

  private readonly listScroller: Scroller = new Scroller()
  private readonly pageSize: number = 8
  private readonly rootBottomBarInset: number = 112

  aboutToAppear() {
    this.currentTrainingType = normalizeCourseListTrainingType(this.initialTrainingType)
    this.keyword = ''
    this.sortType = 'default'
    this.selectedTags = createCourseListSelectedTags(this.currentTrainingType)
    if (this.courseTags.length === 0) {
      void this.refreshCourseTags()
    }
    void this.refreshCourseList()
  }

  private async refreshCourseList(loadMore: boolean = false): Promise<void> {
    if ((this.loading && !(this.courses.length === 0 && this.pageNo === 1)) || this.loadingMore) return
    if (loadMore && !this.hasMore) return

    if (loadMore) {
      this.loadingMore = true
    } else {
      this.loading = true
      this.tip = '正在加载课程中...'
    }

    const result = await loadCourseListState(
      this.keyword,
      this.currentTrainingType,
      this.selectedTags,
      this.sortType,
      this.pageNo,
      this.pageSize,
      loadMore,
      this.courses
    )

    this.courses = result.courses
    this.pageNo = result.pageNo
    this.total = result.total
    this.hasMore = result.hasMore
    this.tip = result.tip

    if (loadMore) {
      this.loadingMore = false
    } else {
      this.loading = false
    }
  }

  private async refreshCourseTags(): Promise<void> {
    this.courseTags = await loadCourseListTags()
  }

  private getAllScrollableTags(): string[] {
    return this.courseTags.filter((tag) => !isCourseTypeTag(tag))
  }

  private toggleCourseFilterTag(tag: string): void {
    const nextState = toggleCourseListTagState(this.currentTrainingType, this.selectedTags, tag)
    this.currentTrainingType = nextState.currentTrainingType
    this.selectedTags = nextState.selectedTags
    this.pageNo = 1
    this.hasMore = true
    void this.refreshCourseList()
  }

  private selectCourseSort(sortType: SortType): void {
    if (!shouldSwitchCourseListSort(this.sortType, sortType)) return
    this.sortType = sortType
    this.pageNo = 1
    this.hasMore = true
    void this.refreshCourseList()
  }

  private openCourseByCode(courseCode: string): void {
    const course = findCourseInList(this.courses, courseCode)
    if (!course) return
    this.onOpenCourse(course.name, course.code, getCourseOpenPhrase(course), false, course.trainingType)
  }

  private showInlineLoading(): boolean {
    return this.loading && this.courses.length === 0
  }

  private showInlineError(): boolean {
    return !this.loading && this.courses.length === 0 && this.tip.length > 0
  }

  private showInlineEmpty(): boolean {
    return !this.loading && this.courses.length === 0 && this.tip.length === 0
  }

  @Builder
  private buildStateCard(icon: Resource, title: string, description: string, accentColor: string, iconBackgroundColor: string = `${accentColor}1A`) {
    Column({ space: 12 }) {
      Stack({ alignContent: Alignment.Center }) {
        Row()
          .width(42)
          .height(42)
          .backgroundColor(iconBackgroundColor)
          .borderRadius(21)
        SymbolGlyph(icon)
          .fontSize(20)
          .fontColor([accentColor])
      }
      .width(42)
      .height(42)

      Text(title)
        .width('100%')
        .fontSize(17)
        .fontWeight(FontWeight.Medium)
        .fontColor(APP_COLORS.primaryText)
        .textAlign(TextAlign.Center)

      Text(description)
        .width('100%')
        .fontSize(13)
        .fontColor(APP_COLORS.secondaryTextAlt)
        .textAlign(TextAlign.Center)
        .lineHeight(20)
    }
    .width('100%')
    .padding({ left: 18, right: 18, top: 24, bottom: 24 })
    .backgroundColor(APP_COLORS.surface)
    .borderRadius(APP_RADIUS.xxl)
    .shadow(APP_SHADOW.elevated)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  private buildLoadingState() {
    Column({ space: 14 }) {
      LoadingProgress()
        .width(28)
        .height(28)
        .color(APP_COLORS.primary)

      Text('正在加载课程')
        .fontSize(17)
        .fontWeight(FontWeight.Medium)
        .fontColor(APP_COLORS.primaryText)

      Text('正在整理适合你的训练内容，请稍等片刻。')
        .fontSize(13)
        .fontColor(APP_COLORS.secondaryTextAlt)
        .textAlign(TextAlign.Center)
    }
    .width('100%')
    .padding({ left: 18, right: 18, top: 26, bottom: 26 })
    .backgroundColor(APP_COLORS.surface)
    .borderRadius(APP_RADIUS.xxl)
    .shadow(APP_SHADOW.elevated)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  private buildListFooter() {
    if (this.loadingMore) {
      Row({ space: 8 }) {
        LoadingProgress().width(18).height(18).color(APP_COLORS.primary)
        Text('正在加载更多课程...').fontSize(12).fontColor(APP_COLORS.secondaryTextAlt)
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .padding({ top: 12, bottom: 12 })
      .backgroundColor(APP_COLORS.surface)
      .borderRadius(APP_RADIUS.xl)
      .shadow(APP_SHADOW.soft)
    } else if (!this.loading && !this.loadingMore && this.courses.length > 0 && this.tip.length > 0) {
      this.buildStateCard($r('sys.symbol.info_circle'), '提示', this.tip, APP_COLORS.primary)
    } else if (!this.loading && !this.loadingMore && this.courses.length > 0 && !this.hasMore) {
      Text('已经看到全部课程了')
        .width('100%')
        .fontSize(12)
        .fontColor('#9AACBF')
        .textAlign(TextAlign.Center)
        .padding({ top: 8, bottom: 10 })
    }
  }

  build() {
    Column({ space: 0 }) {
      CourseListFilterBar({
        keyword: this.keyword,
        sortType: this.sortType,
        allTags: this.getAllScrollableTags(),
        selectedTags: this.selectedTags,
        onKeywordChange: (value: string) => { this.keyword = value },
        onKeywordSubmit: () => {
          this.pageNo = 1
          this.hasMore = true
          void this.refreshCourseList()
        },
        onToggleTag: (tag: string) => { this.toggleCourseFilterTag(tag) },
        onSelectSort: (sortType: SortType) => { this.selectCourseSort(sortType) }
      })
      .padding({ top: 6 })

      Scroll(this.listScroller) {
        Column({ space: 14 }) {
          if (this.showInlineLoading()) {
            this.buildLoadingState()
          } else if (this.showInlineError()) {
            this.buildStateCard($r('sys.symbol.exclamationmark_circle'), '加载失败', this.tip, '#C96B47', '#FFF4ED')
          } else if (this.showInlineEmpty()) {
            this.buildStateCard($r('sys.symbol.magnifyingglass'), '还没有匹配课程', '试试调整关键词、训练类型或排序方式。', APP_COLORS.primary)
          } else {
            CourseCardList({
              courses: this.courses,
              favoriteCourseCodes: this.favoriteCourseCodes,
              includeIds: [],
              onSelectCourse: (courseCode: string) => {
                this.openCourseByCode(courseCode)
              },
              onToggleCourseFavorite: (course: Course) => { this.onToggleCourseFavorite(course) }
            })
          }

          this.buildListFooter()
        }
        .width('100%')
        .justifyContent(FlexAlign.Start)
        .alignItems(HorizontalAlign.Start)
        .constraintSize({ minHeight: '100%' })
        .padding({ left: 16, right: 16, top: 6, bottom: this.rootBottomBarInset })
      }
      .layoutWeight(1)
      .width('100%')
      .scrollBar(BarState.Off)
      .onScrollEdge((side: Edge) => {
        if (side === Edge.Bottom) {
          void this.refreshCourseList(true)
        }
      })
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F7FAFE')
    .justifyContent(FlexAlign.Start)
    .alignItems(HorizontalAlign.Start)
  }
}
