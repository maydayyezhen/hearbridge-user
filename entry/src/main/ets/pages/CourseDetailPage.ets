import common from '@ohos.app.ability.common'
import { readToken } from '../api/AuthStorage'
import { CourseDetailData, getCourseDetail } from '../api/CourseApi'
import { getTrainingSessionDetail, startTrainingSession, TrainingSessionItemDto } from '../api/TrainingApi'
import { TrainingItem, mapSessionItemToTrainingItem } from './train/TrainData'
import { CourseTrainingItemList } from './train/components/CourseTrainingItemList'
import { FocusTagChip } from './train/components/FocusTagChip'

function normalizeDebugBaseUrl(baseUrl: string): string {
  return baseUrl.endsWith('/') ? baseUrl.slice(0, -1) : baseUrl
}

const COURSE_DETAIL_FIELD_CACHE: Map<string, CourseDetailData> = new Map()
class CourseSessionFieldCacheEntry {
  sessionProgressPercent: number = 0
  completedItemCount: number = 0
  totalItemCount: number = 0
  currentItemCode: string = ''
  currentItemStatus: string = ''
  trainingType: string = 'gesture'
  items: TrainingSessionItemDto[] = []
}
const COURSE_SESSION_FIELD_CACHE: Map<string, CourseSessionFieldCacheEntry> = new Map()

export function clearCourseDetailFieldCache() {
  COURSE_DETAIL_FIELD_CACHE.clear()
  COURSE_SESSION_FIELD_CACHE.clear()
}

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
  @State courseItems: TrainingItem[] = []
  @State completedItemIds: number[] = []
  @State currentItemIndex: number = -1
  @State currentItemStatus: string = ''
  @State currentItemCode: string = ''
  @State sessionProgressPercent: number = 0
  @State completedItemCount: number = 0
  @State totalItemCount: number = 0
  @State debugStartJson: string = ''
  @State debugSessionJson: string = ''
  @State debugCourseCode: string = ''
  @State debugTokenPresent: string = 'false'
  @State debugStartUrl: string = ''
  @State debugStartMethod: string = 'POST'
  @State debugStartBody: string = ''
  @State debugDetailUrl: string = ''
  @State debugDetailMethod: string = 'GET'
  onBack: () => void = () => {}
  onToggleFavorite: (courseCode: string) => void = (_courseCode: string) => {}
  onStartTraining: (phrase: string) => void = (_phrase: string) => {}
  onOpenTrainingItem: (itemCode: string, phrase: string, toResult: boolean) => void = (_itemCode: string, _phrase: string, _toResult: boolean) => {}

  private readonly pageScroller: Scroller = new Scroller()

  aboutToAppear() {
    this.displayCourseName = this.courseName
    this.displayCourseIntro = this.courseIntro
    this.displayCoverUrl = this.coverUrl
    this.displayTrainingType = this.normalizeTrainingType(this.trainingType)
    this.displayTags = this.getPropTags()
    this.loadCourseContext()
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
    if (value === 'voice' || value === 'speech') {
      return 'speech'
    }
    return 'gesture'
  }

  private async loadCourseContext() {
    if (this.detailLoading || this.courseCode.trim().length === 0) {
      return
    }
    this.detailLoading = true
    this.detailTip = '正在加载课程内容...'
    try {
      const token = await readToken(this.getAbilityContext())
      if (token.length === 0) {
        this.detailTip = '登录已失效，请重新登录。'
        return
      }

      await this.loadCourseDetail(token)
      await this.loadTrainingSession(token)
      if (this.courseItems.length === 0 && this.detailTip.length === 0) {
        this.detailTip = '当前课程还没有训练项。'
      }
    } catch (_error) {
      this.detailTip = '网络异常，无法加载课程详情。'
    } finally {
      this.detailLoading = false
    }
  }

  private async loadCourseDetail(token: string) {
    const cachedDetail = COURSE_DETAIL_FIELD_CACHE.get(this.courseCode)
    if (cachedDetail) {
      this.displayCourseName = cachedDetail.courseName
      this.displayCourseIntro = cachedDetail.intro
      this.displayCoverUrl = cachedDetail.coverUrl
      this.displayTrainingType = this.normalizeTrainingType(cachedDetail.trainingType)
      this.displayTags = cachedDetail.tags
      this.detailTip = ''
      return
    }

    const result = await getCourseDetail(this.apiBaseUrl, token, this.courseCode)
    if (!result.ok || !result.data) {
      this.detailTip = result.message.length > 0 ? result.message : `课程详情加载失败（错误码 ${result.code}）`
      return
    }

    COURSE_DETAIL_FIELD_CACHE.set(this.courseCode, result.data)
    this.displayCourseName = result.data.courseName
    this.displayCourseIntro = result.data.intro
    this.displayCoverUrl = result.data.coverUrl
    this.displayTrainingType = this.normalizeTrainingType(result.data.trainingType)
    this.displayTags = result.data.tags
    this.detailTip = ''
  }

  private async loadTrainingSession(token: string) {
    const cachedSession = COURSE_SESSION_FIELD_CACHE.get(this.courseCode)
    if (cachedSession) {
      this.sessionProgressPercent = cachedSession.sessionProgressPercent
      this.completedItemCount = cachedSession.completedItemCount
      this.totalItemCount = cachedSession.totalItemCount
      this.currentItemCode = cachedSession.currentItemCode
      this.currentItemStatus = cachedSession.currentItemStatus
      this.applySessionItems(cachedSession.trainingType, cachedSession.items)
      this.detailTip = ''
      return
    }

    const startResult = await startTrainingSession(this.apiBaseUrl, token, this.courseCode)
    if (!startResult.ok || !startResult.data) {
      this.detailTip = startResult.message.length > 0 ? startResult.message : `训练信息加载失败（错误码 ${startResult.code}）`
      return
    }

    const detailResult = await getTrainingSessionDetail(this.apiBaseUrl, token, startResult.data.sessionId)
    if (!detailResult.ok || !detailResult.data) {
      this.detailTip = detailResult.message.length > 0 ? detailResult.message : `训练详情加载失败（错误码 ${detailResult.code}）`
      return
    }

    this.sessionProgressPercent = detailResult.data.progressPercent
    this.completedItemCount = detailResult.data.completedItemCount
    this.totalItemCount = detailResult.data.totalItemCount
    this.currentItemCode = detailResult.data.currentItemCode
    this.currentItemStatus = startResult.data.currentItemStatus
    this.applySessionItems(detailResult.data.trainingType, detailResult.data.items)
    const cacheEntry = new CourseSessionFieldCacheEntry()
    cacheEntry.sessionProgressPercent = detailResult.data.progressPercent
    cacheEntry.completedItemCount = detailResult.data.completedItemCount
    cacheEntry.totalItemCount = detailResult.data.totalItemCount
    cacheEntry.currentItemCode = detailResult.data.currentItemCode
    cacheEntry.currentItemStatus = startResult.data.currentItemStatus
    cacheEntry.trainingType = detailResult.data.trainingType
    cacheEntry.items = detailResult.data.items
    COURSE_SESSION_FIELD_CACHE.set(this.courseCode, cacheEntry)
    this.detailTip = ''
  }

  private applySessionItems(trainingType: string, items: TrainingSessionItemDto[]) {
    const mappedItems: TrainingItem[] = []
    const completedIds: number[] = []
    let currentIndex = -1
    for (let i = 0; i < items.length; i += 1) {
      const mapped = mapSessionItemToTrainingItem(items[i], trainingType, i)
      mappedItems.push(mapped)
      if (items[i].status === 'completed') {
        completedIds.push(mapped.id)
      }
      if (items[i].itemCode === this.currentItemCode) {
        currentIndex = i
        this.currentItemStatus = items[i].status
      }
    }
    this.courseItems = mappedItems
    this.completedItemIds = completedIds
    this.currentItemIndex = currentIndex
    if (this.totalItemCount <= 0) {
      this.totalItemCount = mappedItems.length
    }
    if (this.completedItemCount <= 0) {
      this.completedItemCount = completedIds.length
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
          this.buildCourseMetaSection()
          this.buildActionRow()
          CourseTrainingItemList({
            items: this.courseItems,
            completedCount: this.completedItemCount,
            completedItemIds: this.completedItemIds,
            currentIndex: this.currentItemIndex,
            showHeader: true,
            onItemCodeClick: (itemCode: string, itemName: string, completed: boolean) => {
              this.onOpenTrainingItem(itemCode, itemName, false)
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
      if (this.displayCoverUrl.length > 0) {
        Image(this.displayCoverUrl)
          .width('100%')
          .height(186)
          .objectFit(ImageFit.Cover)
          .borderRadius(22)
      } else {
        Column()
          .width('100%')
          .height(186)
          .linearGradient({
            angle: 135,
            colors: [['#DCEBFF', 0], ['#BBD6FF', 1]]
          })
          .borderRadius(22)
      }

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
  private buildCourseMetaSection() {
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

      Row({ space: 10 }) {
        this.buildStatPill('训练项', `${this.totalItemCount}`)
        this.buildStatPill('已完成', `${this.completedItemCount}`)
        this.buildStatPill('进度', `${Math.round(this.sessionProgressPercent)}%`)
      }
      .width('100%')

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
  private buildStatPill(label: string, value: string) {
    Column({ space: 4 }) {
      Text(value)
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#1F2A44')

      Text(label)
        .fontSize(11)
        .fontColor('#7A8CA7')
    }
    .padding({ left: 12, right: 12, top: 10, bottom: 10 })
    .backgroundColor('#F7FAFF')
    .borderRadius(14)
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  private buildDebugSection() {
    Column({ space: 8 }) {
      Text('调试返回')
        .width('100%')
        .fontSize(15)
        .fontWeight(FontWeight.Medium)
        .fontColor('#1F2A44')

      Text(`courseCode: ${this.debugCourseCode}`)
        .width('100%')
        .fontSize(11)
        .lineHeight(16)
        .fontColor('#5F718B')
        .textAlign(TextAlign.Start)
        .fontFamily('monospace')

      Text(`token present: ${this.debugTokenPresent}`)
        .width('100%')
        .fontSize(11)
        .lineHeight(16)
        .fontColor('#5F718B')
        .textAlign(TextAlign.Start)
        .fontFamily('monospace')

      Text(`start method: ${this.debugStartMethod}`)
        .width('100%')
        .fontSize(11)
        .lineHeight(16)
        .fontColor('#5F718B')
        .textAlign(TextAlign.Start)
        .fontFamily('monospace')

      Text(`start url: ${this.debugStartUrl}`)
        .width('100%')
        .fontSize(11)
        .lineHeight(16)
        .fontColor('#5F718B')
        .textAlign(TextAlign.Start)
        .fontFamily('monospace')

      Text(`start body: ${this.debugStartBody}`)
        .width('100%')
        .fontSize(11)
        .lineHeight(16)
        .fontColor('#5F718B')
        .textAlign(TextAlign.Start)
        .fontFamily('monospace')

      Text(`start: ${this.debugStartJson.length > 0 ? this.debugStartJson : '无返回'}`)
        .width('100%')
        .fontSize(11)
        .lineHeight(16)
        .fontColor('#5F718B')
        .textAlign(TextAlign.Start)
        .fontFamily('monospace')

      Text(`detail method: ${this.debugDetailMethod}`)
        .width('100%')
        .fontSize(11)
        .lineHeight(16)
        .fontColor('#5F718B')
        .textAlign(TextAlign.Start)
        .fontFamily('monospace')

      Text(`detail url: ${this.debugDetailUrl.length > 0 ? this.debugDetailUrl : '无返回'}`)
        .width('100%')
        .fontSize(11)
        .lineHeight(16)
        .fontColor('#5F718B')
        .textAlign(TextAlign.Start)
        .fontFamily('monospace')

      Text(`detail: ${this.debugSessionJson.length > 0 ? this.debugSessionJson : '无返回'}`)
        .width('100%')
        .fontSize(11)
        .lineHeight(16)
        .fontColor('#5F718B')
        .textAlign(TextAlign.Start)
        .fontFamily('monospace')
    }
    .width('100%')
    .padding(12)
    .backgroundColor('#F7FAFF')
    .borderRadius(16)
  }

  @Builder
  private buildActionRow() {
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

      Button(this.getCanContinue() ? '继续练习' : '开始练习')
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
          this.onOpenTrainingItem(this.getNextItemCode(), this.getNextPhrase(), false)
        })
    }
    .width('100%')
  }

  private getNextItemCode(): string {
    if (this.courseItems.length === 0) {
      return ''
    }
    const nextIndex = this.findNextOpenItemIndex()
    return this.courseItems[nextIndex >= 0 ? nextIndex : this.courseItems.length - 1].code
  }

  private getNextPhrase(): string {
    if (this.courseItems.length === 0) {
      return '你好'
    }
    const nextIndex = this.findNextOpenItemIndex()
    return this.courseItems[nextIndex >= 0 ? nextIndex : this.courseItems.length - 1].name
  }

  private shouldOpenResultForNextPhrase(): boolean {
    if (this.courseItems.length === 0) {
      return false
    }
    const nextIndex = this.findNextOpenItemIndex()
    if (nextIndex >= 0) {
      return false
    }
    return true
  }

  private findNextOpenItemIndex(): number {
    for (let i = 0; i < this.courseItems.length; i += 1) {
      if (!this.isCompletedId(this.courseItems[i].id)) {
        return i
      }
    }
    return -1
  }

  private isCompletedId(itemId: number): boolean {
    for (let i = 0; i < this.completedItemIds.length; i += 1) {
      if (this.completedItemIds[i] === itemId) {
        return true
      }
    }
    return false
  }

  private getCanContinue(): boolean {
    return this.completedItemCount > 0 || this.currentItemIndex >= 0
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
}
