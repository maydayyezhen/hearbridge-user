/**
 * RecordPage 页面文件，负责页面展示与交互承接。
 */

import { go, goRootTab } from '../../router/Router'
import { getRouteBasePath } from '../../router/RouteMatcher'
import { RECORD_PATH } from '../../router/RoutePaths'
import { RecordPageState, buildRecordCourseDetailPath, buildRecordPracticePath, createEmptyRecordState, getNonZeroRecordTrendPoints, getRecordDisplayLabel, getRecordPageScoreCopy, getRecordPageTrendPoints, getSafeRecordScore, getSegmentedBarHeight, hydrateRecordPageOverview, hydrateRecordPageRecentCourses, loadRecordPageOverview, loadRecordPageRecentCourses, RecentCourse, shouldRefreshRecordPageOverview, shouldRefreshRecordPageRecentCourses, TrendPointItem } from '../../services/record/index'
import { APP_COLORS, APP_RADIUS, APP_SHADOW } from '../../config/AppStyle'
import { PageLoadingOverlay } from '../../components/PageLoadingOverlay'

@Component
export struct RecordPage {
  @Prop isActive: boolean = false
  @StorageLink('route.path')
  @Watch('handleRoutePathChange')
  routePath: string = '/launch'
  @State record: RecordPageState = createEmptyRecordState()
  @State selectedFilter: string = '周'

  private readonly filters: string[] = ['日', '周', '总览']
  private readonly pageScroller: Scroller = new Scroller()
  private hasAppeared: boolean = false

  aboutToAppear(): void {
    this.hasAppeared = true
    if (this.isRecordRoute(this.routePath)) {
      void this.initializeRecordData()
    }
  }

  private handleRoutePathChange(): void {
    if (this.hasAppeared && this.isRecordRoute(this.routePath)) {
      void this.initializeRecordData()
    }
  }

  private isRecordRoute(path: string): boolean {
    return getRouteBasePath(path) === RECORD_PATH
  }

  private async initializeRecordData(): Promise<void> {
    this.record = hydrateRecordPageOverview(this.record)
    this.record = hydrateRecordPageRecentCourses(this.record)
    if (shouldRefreshRecordPageOverview(this.record)) {
      await this.refreshRecordOverview()
    }
    if (shouldRefreshRecordPageRecentCourses(this.record)) {
      await this.refreshRecentCourses(false)
    }
  }

  private async refreshRecordOverview(): Promise<void> {
    this.record = await loadRecordPageOverview(this.record)
  }

  private async refreshRecentCourses(loadMore: boolean): Promise<void> {
    this.record = await loadRecordPageRecentCourses(this.record, loadMore)
  }

  private getTrendPoints(): TrendPointItem[] {
    return getRecordPageTrendPoints(this.record, this.selectedFilter)
  }

  private getSummaryHeroTitle(): string {
    return getRecordPageScoreCopy(this.record.overallScore).heroTitle
  }

  private getSummaryTitle(): string {
    return getRecordPageScoreCopy(this.record.overallScore).title
  }

  private getSummaryAdvice(): string {
    return getRecordPageScoreCopy(this.record.overallScore).advice
  }

  private openRecordCourse(item: RecentCourse): void {
    go(buildRecordCourseDetailPath(item))
  }

  build() {
    Stack({ alignContent: Alignment.Center }) {
      Scroll(this.pageScroller) {
      Column({ space: 18 }) {
        this.buildSummaryCard()
        this.buildTrendCard()
        this.buildRecentCoursesCard()
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 6, bottom: 118 })
      }
      .width('100%')
      .height('100%')
      .backgroundColor(APP_COLORS.backgroundStart)
      .scrollBar(BarState.Off)
      .onScrollEdge((side: Edge) => {
        if (side === Edge.Bottom && this.record.hasMoreRecentCourses && !this.record.loadingMoreRecentCourses) {
          void this.refreshRecentCourses(true)
        }
      })

      if (this.record.loading && !this.record.loaded) {
        PageLoadingOverlay({
          text: '\u6b63\u5728\u52a0\u8f7d\u5b66\u4e60\u8bb0\u5f55...'
        })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(APP_COLORS.backgroundStart)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])
  }

  @Builder private buildSummaryCard() {
    Column({ space: 14 }) {
      Row() {
        Column({ space: 4 }) {
          Text(this.getSummaryHeroTitle()).fontSize(22).fontWeight(FontWeight.Bold).fontColor('#FFFFFF')
          Text(this.getSummaryTitle()).fontSize(13).fontColor('#E5F1FF').maxLines(2)
        }.alignItems(HorizontalAlign.Start)
        Blank()
        Column({ space: 2 }) {
          Text('今日手感').fontSize(12).fontColor('#E5F1FF')
          Text(`${Math.round(this.record.overallScore)}分`).fontSize(34).fontWeight(FontWeight.Bold).fontColor('#FFFFFF')
        }.alignItems(HorizontalAlign.End)
      }.width('100%')
      Text(this.getSummaryAdvice()).width('100%').fontSize(13).fontColor('#E5F1FF').lineHeight(20)
      Button('开始一轮').width('100%').height(46).fontSize(16).fontWeight(FontWeight.Medium).fontColor('#2A74F4').backgroundColor('#FFFFFF').borderRadius(18).onClick(() => { goRootTab(buildRecordPracticePath()) })
    }
    .width('100%').padding(20).linearGradient({ angle: 135, colors: [['#58B8FF', 0], ['#2E79F4', 1]] }).borderRadius(APP_RADIUS.xxxl).shadow({ radius: 20, color: '#332E79F4', offsetX: 0, offsetY: 10 })
  }

  @Builder private buildTrendCard() {
    Column({ space: 16 }) {
      Row() {
        Text('学习曲线').fontSize(18).fontWeight(FontWeight.Medium).fontColor('#1F2A44')
        Blank()
        Row({ space: 8 }) {
          ForEach(this.filters, (filter: string) => {
            Text(filter)
              .fontSize(12)
              .fontColor(this.selectedFilter === filter ? '#2563EB' : '#7A8CA7')
              .padding({ left: 10, right: 10, top: 6, bottom: 6 })
              .backgroundColor(this.selectedFilter === filter ? '#E7F0FF' : '#F5F8FD')
              .borderRadius(12)
              .onClick(() => { this.selectedFilter = filter })
          }, (filter: string) => filter)
        }
      }.width('100%')

      if (this.getTrendPoints().length === 0) {
        Text('完成训练后，这里会显示你的分数变化。').width('100%').fontSize(13).fontColor('#8AA0BC').textAlign(TextAlign.Center).padding({ top: 16, bottom: 12 })
      } else {
        Row({ space: 10 }) {
          ForEach(this.getTrendPoints(), (point: TrendPointItem) => {
            Column({ space: 8 }) {
              Text(`${Math.round(getSafeRecordScore(point.score))}`)
                .fontSize(10)
                .fontWeight(FontWeight.Medium)
                .fontColor(point.score > 0 ? '#4E6D97' : '#A7B7CB')
                .textAlign(TextAlign.Center)
                .width('100%')
              Column() {
                Blank()
                Column()
                  .width('100%')
                  .height(`${getSegmentedBarHeight(point.score, this.getTrendPoints())}%`)
                  .linearGradient({ angle: 180, colors: [['#68D5F3', 0], ['#3E7CF6', 1]] })
                  .borderRadius(10)
              }.justifyContent(FlexAlign.End).width('100%').height(120)
              Text(getRecordDisplayLabel(point.label, this.selectedFilter))
                .fontSize(10)
                .fontColor('#7A8CA7')
                .maxLines(1)
                .textAlign(TextAlign.Center)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
            }.layoutWeight(1)
          }, (point: TrendPointItem) => `${point.label}_${point.score}`)
        }.width('100%').height(146)
      }
    }
    .width('100%').padding(18).backgroundColor(APP_COLORS.surface).borderRadius(APP_RADIUS.xxxl).shadow(APP_SHADOW.elevated)
  }

  @Builder private buildRecentCoursesCard() {
    Column({ space: 12 }) {
      Row() {
        Text('最近学习课程').fontSize(18).fontWeight(FontWeight.Medium).fontColor('#1F2A44')
        Blank()
        Text(`${this.record.recentCoursesTotal} 条`).fontSize(13).fontColor('#8AA3C3')
      }.width('100%')
      if (this.record.recentCourses.length === 0) {
        Text('最近完成的课程会显示在这里。').width('100%').fontSize(13).fontColor('#8AA0BC').textAlign(TextAlign.Center).padding({ top: 10, bottom: 6 })
      } else {
        ForEach(this.record.recentCourses, (item: RecentCourse) => {
          this.buildRecentCourseCard(item)
        }, (item: RecentCourse) => `${item.courseCode}_${item.lastLearnedAt}`)
        if (this.record.loadingMoreRecentCourses) {
          Row({ space: 8 }) {
            LoadingProgress().width(16).height(16).color('#2E79F4')
            Text('\u6b63\u5728\u52a0\u8f7d\u66f4\u591a\u8bfe\u7a0b\u8bb0\u5f55...').fontSize(12).fontColor('#7A8CA7')
          }.width('100%').justifyContent(FlexAlign.Center).padding({ top: 6, bottom: 4 })
        } else if (!this.record.hasMoreRecentCourses) {
          Text('已经看到最后一门课程了').width('100%').fontSize(12).fontColor('#9AACBF').textAlign(TextAlign.Center).padding({ top: 4, bottom: 2 })
        }
      }
    }
    .width('100%').padding(18).backgroundColor(APP_COLORS.surface).borderRadius(APP_RADIUS.xxxl).shadow(APP_SHADOW.elevated)
  }

  @Builder private buildRecentCourseCard(item: RecentCourse) {
    Column({ space: 10 }) {
      Row({ space: 12 }) {
        Image(item.coverUrl.length > 0 ? item.coverUrl : $r('app.media.startIcon')).width(96).height(54).objectFit(ImageFit.Cover).borderRadius(10).clip(true)
        Column({ space: 6 }) {
          Text(item.courseName).width('100%').fontSize(14).fontWeight(FontWeight.Medium).fontColor('#1F2A44').maxLines(1).textOverflow({ overflow: TextOverflow.Ellipsis })
          Text(item.lastLearnedAt).width('100%').fontSize(11).fontColor('#7A8CA7').maxLines(1)
        }.layoutWeight(1).alignItems(HorizontalAlign.Start)
      }.width('100%')
      Row({ space: 8 }) {
        Stack({ alignContent: Alignment.Start }) {
          Row().width('100%').height(8).backgroundColor('#EAF1FB').borderRadius(8)
          Row().width(`${getSafeRecordScore(item.progressPercent)}%`).height(8).linearGradient({ angle: 90, colors: [['#74B8FF', 0], ['#2E79F4', 1]] }).borderRadius(8)
        }.layoutWeight(1).height(8)
        Text(`${Math.round(getSafeRecordScore(item.progressPercent))}%`).fontSize(12).fontWeight(FontWeight.Medium).fontColor('#2E79F4')
      }.width('100%')
    }
    .width('100%').padding(12).backgroundColor(APP_COLORS.backgroundStart).borderRadius(APP_RADIUS.lg)
    .onClick(() => { this.openRecordCourse(item) })
  }
}
