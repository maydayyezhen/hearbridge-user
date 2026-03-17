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
  @State displayTags: string[] = ['手势', '口语']
  @State extraTags: string[] = []
  @State courses: CourseItem[] = []
  @State loading: boolean = false
  @State tip: string = ''

  private readonly listScroller: Scroller = new Scroller()
  private readonly extraTagScroller: Scroller = new Scroller()

  aboutToAppear() {
    this.loadCourses()
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

  private mapTrainingTypeToApi(): string {
    if (this.trainingType === 'speech') {
      return 'voice'
    }
    if (this.trainingType === 'gesture') {
      return 'gesture'
    }
    return ''
  }

  private mapSortToApi(): string {
    if (this.sortType === 'hot') {
      return 'hot'
    }
    if (this.sortType === 'updated') {
      return 'updatedAt'
    }
    return 'sortNum'
  }

  private async loadCourses() {
    if (this.loading) {
      return
    }
    this.loading = true
    this.tip = '加载课程中...'
    try {
      const token = await readToken(this.getAbilityContext())
      if (token.length === 0) {
        this.courses = []
        this.tip = '登录已失效，请重新登录。'
        return
      }

      const result = await getCourseList(this.apiBaseUrl, token, {
        keyword: this.keyword.trim(),
        trainingType: this.mapTrainingTypeToApi(),
        tags: this.getExtraSelectedTags(),
        sortBy: this.mapSortToApi(),
        pageNo: 1,
        pageSize: 50
      })
      if (!result.ok || !result.data) {
        this.courses = []
        this.tip = result.message.length > 0 ? result.message : `课程列表加载失败（错误码 ${result.code}）`
        return
      }

      this.courses = this.mapCourseDtos(result.data.list)
      this.refreshTagPool(result.data.list)
      if (this.courses.length === 0) {
        this.tip = '暂无匹配课程，试试更换筛选条件。'
      } else {
        this.tip = ''
      }
    } catch (_error) {
      this.courses = []
      this.tip = '网络异常，无法连接课程服务。'
    } finally {
      this.loading = false
    }
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
    const pool: string[] = ['手势', '口语']
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
      if (tag !== '手势' && tag !== '口语') {
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

    if (tag === '手势') {
      if (!removed) {
        this.onTrainingTypeChange('gesture')
      } else if (this.trainingType === 'gesture') {
        this.onTrainingTypeChange('')
      }
    }
    if (tag === '口语') {
      if (!removed) {
        this.onTrainingTypeChange('speech')
      } else if (this.trainingType === 'speech') {
        this.onTrainingTypeChange('')
      }
    }

    this.loadCourses()
  }

  private setSortType(sortType: SortType) {
    if (this.sortType === sortType) {
      return
    }
    this.sortType = sortType
    this.loadCourses()
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

  private getOpenPhrase(courseCode: string): string {
    if (courseCode === 'COURSE-301') {
      return '\u554a'
    }
    if (this.trainingType === 'speech') {
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
            Text('课程加载中...')
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
              this.onOpenCourse(course.courseName, course.courseCode, this.getOpenPhrase(course.courseCode), false)
            },
            onToggleCourseFavorite: (courseCode: string) => {
              this.onToggleCourseFavorite(courseCode)
            }
          })
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 8, bottom: 30 })
        .justifyContent(FlexAlign.Start)
        .alignItems(HorizontalAlign.Start)
      }
      .layoutWeight(1)
      .width('100%')
      .scrollBar(BarState.Off)
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
    Column({ space: 10 }) {
      Row({ space: 8 }) {
        TextInput({ placeholder: '\u641c\u7d22\u8bfe\u7a0b\u540d\u79f0/\u7b80\u4ecb', text: this.keyword })
          .layoutWeight(1)
          .height(36)
          .fontSize(13)
          .backgroundColor('#FFFFFF')
          .borderRadius(18)
          .onChange((value: string) => {
            this.keyword = value
          })
          .onSubmit(() => {
            this.loadCourses()
          })

        Text('\u6392\u5e8f')
          .fontSize(13)
          .fontWeight(FontWeight.Medium)
          .fontColor('#4F6F99')
          .padding({ left: 12, right: 12, top: 9, bottom: 9 })
          .backgroundColor('#FFFFFF')
          .borderRadius(18)
      }
      .width('100%')

      Row({ space: 8 }) {
        this.buildSortChip('\u7efc\u5408', this.sortType === 'default', 'default')
        this.buildSortChip('\u70ed\u5ea6', this.sortType === 'hot', 'hot')
        this.buildSortChip('\u6700\u8fd1\u66f4\u65b0', this.sortType === 'updated', 'updated')
      }
      .width('100%')

      Row({ space: 8 }) {
        ForEach(this.displayTags, (tag: string) => {
          this.buildFilterChip(tag)
        }, (tag: string) => tag)
      }
      .width('100%')

      if (this.extraTags.length > 0) {
        Row({ space: 8 }) {
          Text('\u66f4\u591a\u6807\u7b7e\uff1a\u5de6\u53f3\u6ed1\u52a8')
            .fontSize(11)
            .fontColor('#8EA2BD')

          Scroll(this.extraTagScroller) {
            Row({ space: 8 }) {
              ForEach(this.extraTags, (tag: string) => {
                this.buildFilterChip(tag)
              }, (tag: string) => tag)
            }
          }
          .layoutWeight(1)
          .scrollable(ScrollDirection.Horizontal)
          .scrollBar(BarState.Off)
        }
        .width('100%')
      }
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 8, bottom: 8 })
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
