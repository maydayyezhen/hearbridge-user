import common from '@ohos.app.ability.common'
import { readToken } from '../api/AuthStorage'
import { CourseListItemDto, getCourseList } from '../api/CourseApi'
import { CourseItem } from './course/CourseModels'
import { CourseCardList } from './course/components/CourseCardList'

type SortType = 'default' | 'hot' | 'updated'

@Component
export struct CourseListPage {
  @Prop apiBaseUrl: string = ''
  @Prop trainingType: string = 'gesture'
  @Prop favoriteCourseCodes: string[] = []
  onTrainingTypeChange: (trainingType: string) => void = (_trainingType: string) => {}
  onToggleCourseFavorite: (courseCode: string) => void = (_courseCode: string) => {}
  onOpenCourse: (courseName: string, courseCode: string, phrase: string, toResult: boolean) => void =
    (_courseName: string, _courseCode: string, _phrase: string, _toResult: boolean) => {}

  @State keyword: string = ''
  @State sortType: SortType = 'default'
  @State selectedTags: string[] = []
  @State displayTags: string[] = ['\u624b\u52bf', '\u53e3\u8bed']
  @State extraTags: string[] = []
  @State courses: CourseItem[] = []
  @State loading: boolean = false
  @State loadingMore: boolean = false
  @State hasMore: boolean = true
  @State pageNo: number = 1
  @State total: number = 0
  @State tip: string = ''

  private readonly listScroller: Scroller = new Scroller()
  private readonly extraTagScroller: Scroller = new Scroller()
  private readonly pageSize: number = 8

  aboutToAppear() {
    this.syncTypeTagFromProp()
    this.reloadCourses()
  }

  private getAbilityContext(): common.BaseContext {
    return this.getUIContext().getHostContext() as common.BaseContext
  }

  private normalizeTrainingType(value: string): string {
    const raw = value.toLowerCase()
    if (raw === 'voice' || raw === 'speech') {
      return 'speech'
    }
    return 'gesture'
  }

  private isGestureTag(tag: string): boolean {
    return tag === '\u624b\u52bf'
  }

  private isSpeechTag(tag: string): boolean {
    return tag === '\u53e3\u8bed'
  }

  private isTypeTag(tag: string): boolean {
    return this.isGestureTag(tag) || this.isSpeechTag(tag)
  }

  private syncTypeTagFromProp() {
    if (this.trainingType === 'gesture' && !this.containsTag(this.selectedTags, '\u624b\u52bf')) {
      this.selectedTags.push('\u624b\u52bf')
    }
    if (this.trainingType === 'speech' && !this.containsTag(this.selectedTags, '\u53e3\u8bed')) {
      this.selectedTags.push('\u53e3\u8bed')
    }
  }

  // trainingType is a dedicated backend field, not a tag.
  private getTrainingTypeFilterForApi(): string {
    const selectedGesture = this.containsTag(this.selectedTags, '\u624b\u52bf')
    const selectedSpeech = this.containsTag(this.selectedTags, '\u53e3\u8bed')
    if (selectedGesture && !selectedSpeech) {
      return 'gesture'
    }
    if (selectedSpeech && !selectedGesture) {
      return 'voice'
    }
    if (!selectedGesture && !selectedSpeech) {
      if (this.trainingType === 'gesture') {
        return 'gesture'
      }
      if (this.trainingType === 'speech') {
        return 'voice'
      }
    }
    return ''
  }

  private mapSortToApi(): string {
    if (this.sortType === 'default') {
      return 'recommended'
    }
    if (this.sortType === 'hot') {
      return 'hot'
    }
    if (this.sortType === 'updated') {
      return 'latest'
    }
    return 'recommended'
  }

  private async loadCourses(loadMore: boolean = false) {
    if (this.loading || this.loadingMore) {
      return
    }
    if (loadMore && !this.hasMore) {
      return
    }

    const targetPageNo = loadMore ? this.pageNo + 1 : 1
    if (loadMore) {
      this.loadingMore = true
    } else {
      this.loading = true
      this.tip = '\u52a0\u8f7d\u8bfe\u7a0b\u4e2d...'
    }
    try {
      const token = await readToken(this.getAbilityContext())
      if (token.length === 0) {
        this.courses = []
        this.total = 0
        this.pageNo = 1
        this.hasMore = false
        this.tip = '\u767b\u5f55\u5df2\u5931\u6548\uff0c\u8bf7\u91cd\u65b0\u767b\u5f55\u3002'
        return
      }

      const result = await getCourseList(this.apiBaseUrl, token, {
        keyword: this.keyword.trim(),
        trainingType: this.getTrainingTypeFilterForApi(),
        tags: this.getExtraSelectedTags(),
        sortBy: this.mapSortToApi(),
        pageNo: targetPageNo,
        pageSize: this.pageSize
      })
      if (!result.ok || !result.data) {
        if (!loadMore) {
          this.courses = []
          this.total = 0
          this.pageNo = 1
          this.hasMore = false
        }
        this.tip = result.message.length > 0 ? result.message : `\u8bfe\u7a0b\u5217\u8868\u52a0\u8f7d\u5931\u8d25\uff08\u9519\u8bef\u7801 ${result.code}\uff09`
        return
      }

      const mappedCourses = this.mapCourseDtos(result.data.list)
      if (loadMore) {
        const nextCourses: CourseItem[] = []
        for (let i = 0; i < this.courses.length; i += 1) {
          nextCourses.push(this.courses[i])
        }
        for (let i = 0; i < mappedCourses.length; i += 1) {
          nextCourses.push(mappedCourses[i])
        }
        this.courses = nextCourses
      } else {
        this.courses = mappedCourses
      }
      this.pageNo = Number(result.data.pageNo ?? targetPageNo)
      this.total = Number(result.data.total ?? this.courses.length)
      this.hasMore = this.courses.length < this.total
      if (loadMore) {
        this.appendTagPool(result.data.list)
      } else {
        this.refreshTagPool(result.data.list)
      }
      if (this.courses.length === 0) {
        this.tip = '\u6682\u65e0\u5339\u914d\u8bfe\u7a0b\uff0c\u8bd5\u8bd5\u66f4\u6362\u7b5b\u9009\u6761\u4ef6\u3002'
      } else {
        this.tip = ''
      }
    } catch (_error) {
      if (!loadMore) {
        this.courses = []
        this.total = 0
        this.pageNo = 1
        this.hasMore = false
      }
      this.tip = '\u7f51\u7edc\u5f02\u5e38\uff0c\u65e0\u6cd5\u8fde\u63a5\u8bfe\u7a0b\u670d\u52a1\u3002'
    } finally {
      if (loadMore) {
        this.loadingMore = false
      } else {
        this.loading = false
      }
    }
  }

  private reloadCourses() {
    this.pageNo = 1
    this.total = 0
    this.hasMore = true
    this.courses = []
    this.tip = ''
    this.loadCourses(false)
  }

  private loadMoreCourses() {
    this.loadCourses(true)
  }

  private mapCourseDtos(list: CourseListItemDto[]): CourseItem[] {
    const mapped: CourseItem[] = []
    for (let i = 0; i < list.length; i += 1) {
      const dto = list[i]
      const normalizedType = this.normalizeTrainingType(dto.trainingType)
      const tags = this.normalizeTags(dto.tags)
      mapped.push(new CourseItem(
        i + 1,
        dto.courseName,
        dto.courseCode,
        dto.coverUrl,
        dto.intro,
        i + 1,
        this.mapStatusToNumber(dto.status),
        normalizedType,
        Number(dto.learnCount ?? 0),
        tags.length > 0 ? tags[0] : '',
        tags.length > 1 ? tags[1] : '',
        tags.length > 2 ? tags[2] : ''
      ))
    }
    return mapped
  }

  private mapStatusToNumber(status: string): number {
    const value = status.toLowerCase()
    if (value === 'published' || value === 'enabled' || value === 'online') {
      return 1
    }
    return 0
  }

  private normalizeTags(tags: string[]): string[] {
    const result: string[] = []
    for (let i = 0; i < tags.length; i += 1) {
      const tag = tags[i].trim()
      if (tag.length > 0 && !this.containsTag(result, tag)) {
        result.push(tag)
      }
    }
    return result
  }

  private containsTag(list: string[], target: string): boolean {
    for (let i = 0; i < list.length; i += 1) {
      if (list[i] === target) {
        return true
      }
    }
    return false
  }

  private refreshTagPool(list: CourseListItemDto[]) {
    const pool: string[] = ['\u624b\u52bf', '\u53e3\u8bed']
    for (let i = 0; i < list.length; i += 1) {
      const tags = list[i].tags
      for (let j = 0; j < tags.length; j += 1) {
        const tag = tags[j].trim()
        if (tag.length > 0 && !this.containsTag(pool, tag)) {
          pool.push(tag)
        }
      }
    }

    this.displayTags = []
    for (let i = 0; i < pool.length && i < 6; i += 1) {
      this.displayTags.push(pool[i])
    }
    this.extraTags = []
    for (let i = 6; i < pool.length; i += 1) {
      this.extraTags.push(pool[i])
    }
  }

  private appendTagPool(list: CourseListItemDto[]) {
    const pool: string[] = []
    for (let i = 0; i < this.displayTags.length; i += 1) {
      pool.push(this.displayTags[i])
    }
    for (let i = 0; i < this.extraTags.length; i += 1) {
      pool.push(this.extraTags[i])
    }
    if (!this.containsTag(pool, '\u624b\u52bf')) {
      pool.unshift('\u624b\u52bf')
    }
    if (!this.containsTag(pool, '\u53e3\u8bed')) {
      pool.splice(pool.length > 0 ? 1 : 0, 0, '\u53e3\u8bed')
    }

    for (let i = 0; i < list.length; i += 1) {
      const tags = list[i].tags
      for (let j = 0; j < tags.length; j += 1) {
        const tag = tags[j].trim()
        if (tag.length > 0 && !this.containsTag(pool, tag)) {
          pool.push(tag)
        }
      }
    }

    this.displayTags = []
    for (let i = 0; i < pool.length && i < 6; i += 1) {
      this.displayTags.push(pool[i])
    }
    this.extraTags = []
    for (let i = 6; i < pool.length; i += 1) {
      this.extraTags.push(pool[i])
    }
  }

  private getExtraSelectedTags(): string[] {
    const tags: string[] = []
    for (let i = 0; i < this.selectedTags.length; i += 1) {
      const tag = this.selectedTags[i]
      if (!this.isTypeTag(tag)) {
        tags.push(tag)
      }
    }
    return tags
  }

  private getAllScrollableTags(): string[] {
    const tags: string[] = []
    for (let i = 0; i < this.displayTags.length; i += 1) {
      const tag = this.displayTags[i]
      if (!this.isTypeTag(tag) && !this.containsTag(tags, tag)) {
        tags.push(tag)
      }
    }
    for (let i = 0; i < this.extraTags.length; i += 1) {
      const tag = this.extraTags[i]
      if (!this.isTypeTag(tag) && !this.containsTag(tags, tag)) {
        tags.push(tag)
      }
    }
    return tags
  }

  private isTagSelected(tag: string): boolean {
    return this.containsTag(this.selectedTags, tag)
  }

  private toggleTag(tag: string) {
    const next: string[] = []
    let removed = false
    for (let i = 0; i < this.selectedTags.length; i += 1) {
      if (this.selectedTags[i] === tag) {
        removed = true
        continue
      }
      next.push(this.selectedTags[i])
    }
    if (!removed) {
      next.push(tag)
    }
    this.selectedTags = next

    if (this.isTypeTag(tag)) {
      const typeFilter = this.getTrainingTypeFilterForApi()
      if (typeFilter === 'gesture') {
        this.onTrainingTypeChange('gesture')
      } else if (typeFilter === 'voice') {
        this.onTrainingTypeChange('speech')
      } else {
        this.onTrainingTypeChange('')
      }
    }

    this.reloadCourses()
  }

  private setSortType(sortType: SortType) {
    if (this.sortType === sortType) {
      return
    }
    this.sortType = sortType
    this.reloadCourses()
  }

  @Builder
  private buildFilterChip(tag: string) {
    Text(tag)
      .fontSize(12)
      .fontWeight(this.isTagSelected(tag) ? FontWeight.Medium : FontWeight.Regular)
      .fontColor(this.isTagSelected(tag) ? '#FFFFFF' : '#5D7393')
      .padding({ left: 12, right: 12, top: 7, bottom: 7 })
      .backgroundColor(this.isTagSelected(tag) ? '#2E79F4' : '#EEF4FF')
      .borderRadius(15)
      .onClick(() => {
        this.toggleTag(tag)
      })
  }

  @Builder
  private buildSortChip(label: string, selected: boolean, sortType: SortType) {
    Text(label)
      .fontSize(12)
      .fontWeight(selected ? FontWeight.Medium : FontWeight.Regular)
      .fontColor(selected ? '#2E79F4' : '#6C7F9A')
      .padding({ left: 8, right: 8, top: 6, bottom: 6 })
      .backgroundColor(selected ? '#EAF2FF' : '#F5F8FD')
      .borderRadius(12)
      .onClick(() => {
        this.setSortType(sortType)
      })
  }

  private getOpenPhrase(course: CourseItem): string {
    if (course.courseCode === 'COURSE-301') {
      return '\u554a'
    }
    if (course.trainingType === 'speech') {
      return '\u554a'
    }
    return '\u4f60\u597d'
  }

  build() {
    Column() {
      this.buildTopBar()

      Scroll(this.listScroller) {
        Column({ space: 10 }) {
          if (this.loading) {
            Text('\u8bfe\u7a0b\u52a0\u8f7d\u4e2d...')
              .width('100%')
              .fontSize(13)
              .fontColor('#6E8099')
              .padding({ top: 8, bottom: 4 })
          } else if (this.tip.length > 0) {
            Text(this.tip)
              .width('100%')
              .fontSize(13)
              .fontColor('#E5484D')
              .padding({ top: 8, bottom: 4 })
          }

          CourseCardList({
            courses: this.courses,
            trainingType: this.trainingType,
            selectedTagFilters: [],
            searchKeyword: '',
            favoriteCourseCodes: this.favoriteCourseCodes,
            includeIds: [],
            onSelectCourse: (courseCode: string) => {
              const course = this.findCourseByCode(courseCode)
              if (!course) {
                return
              }
              this.onOpenCourse(course.courseName, course.courseCode, this.getOpenPhrase(course), false)
            },
            onToggleCourseFavorite: (courseCode: string) => {
              this.onToggleCourseFavorite(courseCode)
            }
          })

          if (this.loadingMore) {
            Row({ space: 8 }) {
              LoadingProgress()
                .width(18)
                .height(18)
                .color('#2E79F4')

              Text('\u6b63\u5728\u52a0\u8f7d\u66f4\u591a\u8bfe\u7a0b...')
                .fontSize(12)
                .fontColor('#7A8EA8')
            }
            .width('100%')
            .justifyContent(FlexAlign.Center)
            .padding({ top: 8, bottom: 8 })
          }

          if (!this.loading && !this.loadingMore && this.courses.length > 0 && !this.hasMore) {
            Text('\u5df2\u7ecf\u5230\u5e95\u4e86')
              .width('100%')
              .fontSize(12)
              .fontColor('#9AACBF')
              .textAlign(TextAlign.Center)
              .padding({ top: 6, bottom: 8 })
          }
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 8, bottom: 30 })
        .justifyContent(FlexAlign.Start)
        .alignItems(HorizontalAlign.Start)
      }
      .layoutWeight(1)
      .width('100%')
      .scrollBar(BarState.Off)
      .onScrollEdge((side: Edge) => {
        if (side === Edge.Bottom) {
          this.loadMoreCourses()
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

  @Builder
  private buildTopBar() {
    Column({ space: 12 }) {
      Row({ space: 10 }) {
        SymbolGlyph($r('sys.symbol.magnifyingglass'))
          .fontSize(16)

        TextInput({ placeholder: '\u641c\u7d22\u8bfe\u7a0b\u540d\u79f0/\u7b80\u4ecb', text: this.keyword })
          .layoutWeight(1)
          .height(36)
          .fontSize(13)
          .backgroundColor(Color.Transparent)
          .placeholderColor('#98A9BE')
          .onChange((value: string) => {
            this.keyword = value
          })
          .onSubmit(() => {
            this.reloadCourses()
          })
      }
      .width('100%')
      .height(42)
      .padding({ left: 14, right: 14 })
      .backgroundColor('#FFFFFF')
      .borderRadius(21)

      Row() {
        Row({ space: 8 }) {
          this.buildFilterChip('\u624b\u52bf')
          this.buildFilterChip('\u53e3\u8bed')
        }

        Blank()

        Row({ space: 8 }) {
          this.buildSortChip('\u7efc\u5408', this.sortType === 'default', 'default')
          this.buildSortChip('\u70ed\u5ea6', this.sortType === 'hot', 'hot')
          this.buildSortChip('\u6700\u8fd1\u66f4\u65b0', this.sortType === 'updated', 'updated')
        }
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)

      Scroll(this.extraTagScroller) {
        Row({ space: 8 }) {
          ForEach(this.getAllScrollableTags(), (tag: string) => {
            this.buildFilterChip(tag)
          }, (tag: string) => tag)
        }
        .padding({ right: 16 })
      }
      .width('100%')
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 8, bottom: 10 })
    .backgroundColor('#F7FAFE')
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])
  }

  private findCourseByCode(courseCode: string): CourseItem | null {
    for (let i = 0; i < this.courses.length; i += 1) {
      if (this.courses[i].courseCode === courseCode) {
        return this.courses[i]
      }
    }
    return null
  }
}
