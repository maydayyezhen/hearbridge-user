import { CourseItem } from '../CourseModels'
import { FocusTagChip } from '../../train/components/FocusTagChip'

@Component
export struct CourseCardList {
  @Prop courses: CourseItem[] = []
  @Prop trainingType: string = 'gesture'
  @Prop selectedTagFilters: string[] = []
  @Prop searchKeyword: string = ''
  @Prop favoriteCourseCodes: string[] = []
  @Prop includeIds: number[] = []
  onSelectCourse: (courseCode: string) => void = (_courseCode: string) => {}
  onToggleCourseFavorite: (courseCode: string) => void = (_courseCode: string) => {}

  build() {
    Column({ space: 12 }) {
      ForEach(this.courses, (course: CourseItem) => {
        if (this.shouldRender(course)) {
          this.buildCourseCard(course)
        }
      }, (course: CourseItem) => course.courseCode)
    }
    .width('100%')
    .justifyContent(FlexAlign.Start)
    .alignItems(HorizontalAlign.Start)
  }

  private shouldRender(course: CourseItem): boolean {
    if (course.status !== 1) {
      return false
    }
    if (!this.isMatchedBySelector(course) || !this.isMatchedBySearch(course)) {
      return false
    }
    if (this.includeIds.length === 0) {
      return true
    }
    let idMatched = false
    for (let i = 0; i < this.includeIds.length; i += 1) {
      if (this.includeIds[i] === course.id) {
        idMatched = true
        break
      }
    }
    return idMatched
  }

  private isMatchedBySelector(course: CourseItem): boolean {
    if (this.selectedTagFilters.length === 0) {
      return true
    }

    for (let i = 0; i < this.selectedTagFilters.length; i += 1) {
      const tag = this.selectedTagFilters[i]
      if (tag === '手势') {
        if (course.trainingType !== 'gesture') {
          return false
        }
        continue
      }
      if (tag === '口语') {
        if (course.trainingType !== 'speech') {
          return false
        }
        continue
      }
      if (course.tag1 !== tag && course.tag2 !== tag && course.tag3 !== tag) {
        return false
      }
    }
    return true
  }

  private isMatchedBySearch(course: CourseItem): boolean {
    const keyword = this.searchKeyword.trim().toLowerCase()
    if (keyword.length === 0) {
      return true
    }
    const source = `${course.courseName} ${course.courseCode} ${course.intro}`.toLowerCase()
    return source.indexOf(keyword) >= 0
  }

  @Builder
  private buildCourseCard(course: CourseItem) {
    Row({ space: 18 }) {
      Image(course.coverUrl)
        .width(136)
        .height(76)
        .objectFit(ImageFit.Cover)
        .borderRadius(12)

      Column({ space: 8 }) {
        Row({ space: 8 }) {
          Text(this.getCardTitle(course.courseName))
            .layoutWeight(1)
            .fontSize(19)
            .fontWeight(FontWeight.Medium)
            .fontColor('#1F2A44')
            .maxLines(1)

          Button() {
            SymbolGlyph(this.isCourseFavorited(course.courseCode) ? $r('sys.symbol.star_fill') : $r('sys.symbol.star'))
              .fontSize(16)
              .fontColor([this.isCourseFavorited(course.courseCode) ? '#2E79F4' : '#8FA0B8'])
          }
          .width(28)
          .height(28)
          .backgroundColor('#F4F8FF')
          .borderRadius(14)
          .stateEffect(false)
          .onClick(() => {
            this.onToggleCourseFavorite(course.courseCode)
          })
        }
        .width('100%')

        Row({ space: 4 }) {
          SymbolGlyph($r('sys.symbol.flame'))
            .fontSize(12)
            .fontColor(['#2E79F4'])

          Text(`热度 ${course.learningCount} 人次`)
            .fontSize(11)
            .fontColor('#6D7F99')
        }

        Text(course.intro)
          .fontSize(12)
          .fontColor('#6E7E97')
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        if (this.getListTags(course).length > 0) {
          Row({ space: 8 }) {
            ForEach(this.getListTags(course), (tag: string) => {
              FocusTagChip({
                label: tag,
                chipBgColor: '#EEF5FF',
                chipFontColor: '#2E79F4'
              })
            }, (tag: string) => tag)
          }
          .width('100%')
          .clip(true)
        }
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      .margin({ left: 2 })
    }
    .width('100%')
    .padding({ left: 14, right: 14, top: 12, bottom: 12 })
    .backgroundColor('#FFFFFF')
    .borderRadius(18)
    .shadow({ radius: 18, color: '#15304B10', offsetX: 0, offsetY: 8 })
    .onClick(() => {
      this.onSelectCourse(course.courseCode)
    })
  }

  private isCourseFavorited(courseCode: string): boolean {
    for (let i = 0; i < this.favoriteCourseCodes.length; i += 1) {
      if (this.favoriteCourseCodes[i] === courseCode) {
        return true
      }
    }
    return false
  }

  private getListTags(course: CourseItem): string[] {
    const tags: string[] = []
    if (course.tag1.trim().length > 0) {
      tags.push(course.tag1)
    }
    if (course.tag2.trim().length > 0) {
      tags.push(course.tag2)
    }
    return tags
  }

  private getCardTitle(title: string): string {
    if (title.length <= 6) {
      return title
    }
    return `${title.substring(0, 6)}...`
  }
}
