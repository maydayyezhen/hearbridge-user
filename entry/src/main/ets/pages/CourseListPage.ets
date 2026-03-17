import { CourseDetailPage } from './CourseDetailPage'
import { CourseItem } from './course/CourseModels'
import { CourseCardList } from './course/components/CourseCardList'

@Component
export struct CourseListPage {
  @Prop trainingType: string = 'gesture'
  @Prop favoriteCourseCodes: string[] = []

  @State selectedCourseCode: string = ''
  @State selectedTagFilters: string[] = []
  @State searchKeyword: string = ''
  @State selectedSortKey: string = 'default'
  @State showSortMenu: boolean = false

  onTrainingTypeChange: (trainingType: string) => void = () => {}
  onOpenCourse: (courseName: string, courseCode: string, phrase: string, toResult: boolean) => void = () => {}
  onToggleCourseFavorite: (courseCode: string) => void = (_courseCode: string) => {}

  private readonly commonFilters: string[] = ['手势', '口语', '入门', '高频', '实用', '场景', '对话', '综合', '发音', '核心']
  private readonly moreFilters: string[] = [
    '跟读', '模仿', '提升', '礼貌', '基础', '沟通', '听辨', '口型', '节奏', '尾音',
    '元音', '声调', '纠错', '表达', '问候', '生活', '校园', '医疗', '购物', '出行',
    '旅游', '社交', '进阶', '强化', '复习', '冲刺', '测试', '任务', '实战', '语料'
  ]

  private readonly courses: CourseItem[] = [
    new CourseItem(1, '日常问候入门', 'COURSE-101', 'http://192.168.142.128:9001/hearbridge-bucket/20260316/3ad909fc0af94c58a8f2be4ca2fe4cbcChatGPT%20Image%202026%E5%B9%B43%E6%9C%8816%E6%97%A5%2001_25_49.png', '用于基础问候表达训练，掌握日常沟通中的常见开场与回应。', 1, 1, 'gesture', '入门', '高频', '实用'),
    new CourseItem(2, '基础交流训练', 'COURSE-102', 'https://placehold.co/400x240/png?text=Course+102', '用于基础交流与礼貌表达，提升日常对话中的自然度与连贯性。', 2, 1, 'gesture', '礼貌', '基础', '沟通'),
    new CourseItem(3, '情景对话入门', 'COURSE-201', 'https://placehold.co/400x240/png?text=Course+201', '用于常见情景对话训练，覆盖问路、购物、问候等生活场景。', 3, 1, 'gesture', '场景', '对话', '综合'),
    new CourseItem(4, '声母训练入门', 'COURSE-301', 'http://192.168.142.128:9001/hearbridge-bucket/20260316/smxlrm.png', '本课程围绕“声母训练入门”设计了从基础口型建立、节奏控制到综合输出的训练路径。', 4, 1, 'speech', '发音', '口语', '核心'),
    new CourseItem(5, '日常跟读训练', 'COURSE-302', 'https://placehold.co/400x240/png?text=Course+302', '用于语音跟读与模仿训练，强化语感与句子输出稳定性。', 5, 1, 'speech', '跟读', '模仿', '提升'),
    new CourseItem(6, '占位课程 01', 'COURSE-401', 'https://placehold.co/400x240/png?text=Course+401', '待配置课程内容。', 6, 1, 'gesture', '占位', '待配置', '预留'),
    new CourseItem(7, '占位课程 02', 'COURSE-402', 'https://placehold.co/400x240/png?text=Course+402', '待配置课程内容。', 7, 1, 'gesture', '占位', '待配置', '预留'),
    new CourseItem(8, '占位课程 03', 'COURSE-403', 'https://placehold.co/400x240/png?text=Course+403', '待配置课程内容。', 8, 1, 'gesture', '占位', '待配置', '预留'),
    new CourseItem(9, '占位课程 04', 'COURSE-404', 'https://placehold.co/400x240/png?text=Course+404', '待配置课程内容。', 9, 1, 'gesture', '占位', '待配置', '预留'),
    new CourseItem(10, '占位课程 05', 'COURSE-405', 'https://placehold.co/400x240/png?text=Course+405', '待配置课程内容。', 10, 1, 'gesture', '占位', '待配置', '预留'),
    new CourseItem(11, '占位课程 06', 'COURSE-406', 'https://placehold.co/400x240/png?text=Course+406', '待配置课程内容。', 11, 1, 'gesture', '占位', '待配置', '预留'),
    new CourseItem(12, '占位课程 07', 'COURSE-407', 'https://placehold.co/400x240/png?text=Course+407', '待配置课程内容。', 12, 1, 'speech', '占位', '待配置', '预留'),
    new CourseItem(13, '占位课程 08', 'COURSE-408', 'https://placehold.co/400x240/png?text=Course+408', '待配置课程内容。', 13, 1, 'speech', '占位', '待配置', '预留'),
    new CourseItem(14, '占位课程 09', 'COURSE-409', 'https://placehold.co/400x240/png?text=Course+409', '待配置课程内容。', 14, 1, 'speech', '占位', '待配置', '预留'),
    new CourseItem(15, '占位课程 10', 'COURSE-410', 'https://placehold.co/400x240/png?text=Course+410', '待配置课程内容。', 15, 1, 'speech', '占位', '待配置', '预留'),
    new CourseItem(16, '占位课程 11', 'COURSE-411', 'https://placehold.co/400x240/png?text=Course+411', '待配置课程内容。', 16, 1, 'speech', '占位', '待配置', '预留'),
    new CourseItem(17, '占位课程 12', 'COURSE-412', 'https://placehold.co/400x240/png?text=Course+412', '待配置课程内容。', 17, 1, 'speech', '占位', '待配置', '预留'),
    new CourseItem(18, '占位课程 13', 'COURSE-413', 'https://placehold.co/400x240/png?text=Course+413', '待配置课程内容。', 18, 1, 'gesture', '占位', '待配置', '预留'),
    new CourseItem(19, '占位课程 14', 'COURSE-414', 'https://placehold.co/400x240/png?text=Course+414', '待配置课程内容。', 19, 1, 'speech', '占位', '待配置', '预留')
  ]

  aboutToAppear() {
    this.selectedTagFilters = [this.trainingType === 'speech' ? '口语' : '手势']
  }

  build() {
    Column() {
      if (this.selectedCourseCode.length > 0) {
        this.buildCourseDetail()
      } else {
        Column({ space: 16 }) {
          this.buildSearchBar()
          this.buildTagFilters()
          Scroll() {
            Column() {
              this.buildCourseList()
            }
            .width('100%')
            .justifyContent(FlexAlign.Start)
            .alignItems(HorizontalAlign.Start)
          }
          .width('100%')
          .scrollBar(BarState.Off)
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Start)
        .alignItems(HorizontalAlign.Start)
        .padding({ left: 16, right: 16, top: 6, bottom: 30 })
      }
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Start)
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  private buildCourseDetail() {
    if (this.hasSelectedCourse()) {
      CourseDetailPage({
        courseName: this.getSelectedCourseName(),
        courseCode: this.getSelectedCourseCode(),
        courseIntro: this.getSelectedCourseIntro(),
        coverUrl: this.getSelectedCourseCoverUrl(),
        trainingType: this.getSelectedCourseTrainingType(),
        courseTag1: this.getSelectedCourseTag1(),
        courseTag2: this.getSelectedCourseTag2(),
        courseTag3: this.getSelectedCourseTag3(),
        isCourseFavorited: this.isCourseFavorited(this.getSelectedCourseCode()),
        onBack: () => {
          this.selectedCourseCode = ''
        },
        onToggleFavorite: (courseCode: string) => {
          this.onToggleCourseFavorite(courseCode)
        },
        onOpenTrainingItem: (phrase: string, toResult: boolean) => {
          this.onOpenCourse(this.getSelectedCourseName(), this.getSelectedCourseCode(), phrase, toResult)
        }
      })
    }
  }

  @Builder
  private buildSearchBar() {
    Stack({ alignContent: Alignment.TopEnd }) {
      Row({ space: 8 }) {
        TextInput({ placeholder: '搜索课程名称 / 编号 / 简介', text: this.searchKeyword })
          .layoutWeight(1)
          .height(40)
          .fontSize(14)
          .backgroundColor('#FFFFFF')
          .borderRadius(12)
          .padding({ left: 12, right: 12 })
          .onChange((value: string) => {
            this.searchKeyword = value
          })

        Button() {
          SymbolGlyph($r('sys.symbol.square_grid_2x2'))
            .fontSize(18)
            .fontColor(['#2E79F4'])
        }
        .width(40)
        .height(40)
        .backgroundColor('#EEF5FF')
        .borderRadius(12)
        .stateEffect(false)
        .onClick(() => {
          this.showSortMenu = !this.showSortMenu
        })
      }
      .width('100%')

      if (this.showSortMenu) {
        Column({ space: 4 }) {
          this.buildSortMenuItem('默认排序', 'default')
          this.buildSortMenuItem('按编号', 'code')
          this.buildSortMenuItem('按名称', 'name')
        }
        .padding(8)
        .backgroundColor('#FFFFFF')
        .borderRadius(12)
        .shadow({ radius: 16, color: '#15304B22', offsetX: 0, offsetY: 8 })
        .margin({ top: 46 })
      }
    }
    .width('100%')
  }

  @Builder
  private buildSortMenuItem(label: string, key: string) {
    Text(label)
      .width(90)
      .padding({ left: 10, right: 10, top: 8, bottom: 8 })
      .fontSize(12)
      .fontColor(this.selectedSortKey === key ? '#2E79F4' : '#4E5E79')
      .fontWeight(this.selectedSortKey === key ? FontWeight.Medium : FontWeight.Regular)
      .backgroundColor(this.selectedSortKey === key ? '#EEF5FF' : '#FFFFFF')
      .borderRadius(8)
      .onClick(() => {
        this.selectedSortKey = key
        this.showSortMenu = false
      })
  }

  @Builder
  private buildTagFilters() {
    Column({ space: 8 }) {
      Row({ space: 8 }) {
        ForEach(this.getFirstRowFilters(), (tag: string) => {
          this.buildFilterChip(tag)
        }, (tag: string) => tag)
      }
      .width('100%')

      Scroll() {
        Row({ space: 8 }) {
          ForEach(this.getSecondRowFilters(), (tag: string) => {
            this.buildFilterChip(tag)
          }, (tag: string) => tag)
        }
        .padding({ right: 8 })
      }
      .width('100%')
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)

      Text('左右滑动查看更多标签')
        .fontSize(11)
        .fontColor('#8D9CB2')
        .width('100%')
        .textAlign(TextAlign.Start)
        .margin({ left: 12 })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  private getFirstRowFilters(): string[] {
    return this.commonFilters.slice(0, 6)
  }

  private getSecondRowFilters(): string[] {
    const tags: string[] = []
    for (let i = 6; i < this.commonFilters.length; i += 1) {
      tags.push(this.commonFilters[i])
    }
    for (let i = 0; i < this.moreFilters.length; i += 1) {
      tags.push(this.moreFilters[i])
    }
    return tags
  }

  @Builder
  private buildFilterChip(tag: string) {
    Text(tag)
      .fontSize(12)
      .fontWeight(this.isTagSelected(tag) ? FontWeight.Medium : FontWeight.Regular)
      .fontColor(this.isTagSelected(tag) ? '#2E79F4' : '#63738C')
      .padding({ left: 12, right: 12, top: 7, bottom: 7 })
      .backgroundColor(this.isTagSelected(tag) ? '#EEF5FF' : '#F5F8FD')
      .borderRadius(12)
      .onClick(() => {
        this.toggleTag(tag)
      })
  }

  private isTagSelected(tag: string): boolean {
    for (let i = 0; i < this.selectedTagFilters.length; i += 1) {
      if (this.selectedTagFilters[i] === tag) {
        return true
      }
    }
    return false
  }

  private toggleTag(tag: string) {
    if (this.isTagSelected(tag)) {
      const next: string[] = []
      for (let i = 0; i < this.selectedTagFilters.length; i += 1) {
        if (this.selectedTagFilters[i] !== tag) {
          next.push(this.selectedTagFilters[i])
        }
      }
      this.selectedTagFilters = next
    } else {
      const next: string[] = []
      for (let i = 0; i < this.selectedTagFilters.length; i += 1) {
        next.push(this.selectedTagFilters[i])
      }
      next.push(tag)
      this.selectedTagFilters = next
    }

    if (tag === '手势' && this.isTagSelected(tag)) {
      this.onTrainingTypeChange('gesture')
    } else if (tag === '口语' && this.isTagSelected(tag)) {
      this.onTrainingTypeChange('speech')
    }
  }

  @Builder
  private buildCourseList() {
    CourseCardList({
      courses: this.getSortedCourses(),
      trainingType: this.trainingType,
      selectedTagFilters: this.selectedTagFilters,
      searchKeyword: this.searchKeyword,
      favoriteCourseCodes: this.favoriteCourseCodes,
      onSelectCourse: (courseCode: string) => {
        this.selectedCourseCode = courseCode
      },
      onToggleCourseFavorite: (courseCode: string) => {
        this.onToggleCourseFavorite(courseCode)
      }
    })
  }

  private getSortedCourses(): CourseItem[] {
    const list: CourseItem[] = []
    for (let i = 0; i < this.courses.length; i += 1) {
      list.push(this.courses[i])
    }
    if (this.selectedSortKey === 'code') {
      list.sort((a: CourseItem, b: CourseItem) => a.courseCode.localeCompare(b.courseCode))
    } else if (this.selectedSortKey === 'name') {
      list.sort((a: CourseItem, b: CourseItem) => a.courseName.localeCompare(b.courseName))
    } else {
      list.sort((a: CourseItem, b: CourseItem) => a.sortNum - b.sortNum)
    }
    return list
  }

  private getSelectedCourse(): CourseItem | null {
    for (let i = 0; i < this.courses.length; i += 1) {
      if (this.courses[i].courseCode === this.selectedCourseCode) {
        return this.courses[i]
      }
    }
    return null
  }

  private hasSelectedCourse(): boolean {
    return this.getSelectedCourse() !== null
  }

  private getSelectedCourseName(): string {
    const selected = this.getSelectedCourse()
    return selected ? selected.courseName : ''
  }

  private getSelectedCourseCode(): string {
    const selected = this.getSelectedCourse()
    return selected ? selected.courseCode : ''
  }

  private getSelectedCourseIntro(): string {
    const selected = this.getSelectedCourse()
    return selected ? selected.intro : ''
  }

  private getSelectedCourseCoverUrl(): string {
    const selected = this.getSelectedCourse()
    return selected ? selected.coverUrl : ''
  }

  private getSelectedCourseTrainingType(): string {
    const selected = this.getSelectedCourse()
    return selected ? selected.trainingType : this.trainingType
  }

  private getSelectedCourseTag1(): string {
    const selected = this.getSelectedCourse()
    return selected ? selected.tag1 : ''
  }

  private getSelectedCourseTag2(): string {
    const selected = this.getSelectedCourse()
    return selected ? selected.tag2 : ''
  }

  private getSelectedCourseTag3(): string {
    const selected = this.getSelectedCourse()
    return selected ? selected.tag3 : ''
  }

  private isCourseFavorited(courseCode: string): boolean {
    for (let i = 0; i < this.favoriteCourseCodes.length; i += 1) {
      if (this.favoriteCourseCodes[i] === courseCode) {
        return true
      }
    }
    return false
  }
}
