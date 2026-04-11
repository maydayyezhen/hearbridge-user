/**
 * 课程卡片列表组件。
 */
import { FocusTagChip } from '../../../../components/FocusTagChip'
import { Course } from '../../../../domain/entity/Course'
import { CourseCoverImage } from './CourseCoverImage'
import { APP_COLORS, APP_RADIUS, APP_SHADOW } from '../../../../config/AppStyle'

@Component
export struct CourseCardList {
  private readonly courseTitleMaxUnits: number = 7
  private readonly courseTitleEllipsisReserveUnits: number = 1
  @Prop courses: Course[] = []
  @Prop favoriteCourseCodes: string[] = []
  @Prop includeIds: number[] = []
  onSelectCourse: (courseCode: string) => void = (_courseCode: string) => {}
  onToggleCourseFavorite: (course: Course) => void = (_course: Course) => {}

  build() {
    Column({ space: 12 }) {
      ForEach(this.courses, (course: Course) => {
        if (this.shouldRender(course)) {
          this.buildCourseCard(course)
        }
      }, (course: Course) => course.code)
    }
    .width('100%')
    .justifyContent(FlexAlign.Start)
    .alignItems(HorizontalAlign.Start)
  }

  private shouldRender(course: Course): boolean {
    if (course.status !== 1) {
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

  @Builder
  private buildCourseCard(course: Course) {
    Row({ space: 14 }) {
      CourseCoverImage({
        coverUrl: course.coverUrl,
        coverSeed: course.id
      })

      Column({ space: 8 }) {
        Row({ space: 6 }) {
          Text(this.getCardTitle(course.name))
            .layoutWeight(1)
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .fontColor('#1F2A44')
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Clip })

          Button() {
            SymbolGlyph(this.isCourseFavorited(course.code) ? $r('sys.symbol.star_fill') : $r('sys.symbol.star'))
              .fontSize(16)
              .fontColor([this.isCourseFavorited(course.code) ? APP_COLORS.primary : '#8FA0B8'])
          }
          .width(24)
          .height(24)
          .backgroundColor(APP_COLORS.surfaceSoft)
          .borderRadius(APP_RADIUS.md)
          .stateEffect(false)
          .onClick(() => {
            this.onToggleCourseFavorite(course)
          })
        }
        .width('100%')

        Row({ space: 4 }) {
          SymbolGlyph($r('sys.symbol.flame'))
            .fontSize(12)
            .fontColor([APP_COLORS.primary])

          Text(`热度 ${course.learnCount} 人次`)
            .fontSize(11)
            .fontColor(APP_COLORS.secondaryTextAlt)
        }

        Text(course.intro)
          .fontSize(12)
          .fontColor(APP_COLORS.secondaryTextAlt)
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
    .backgroundColor(APP_COLORS.surface)
    .borderRadius(APP_RADIUS.lg)
    .shadow(APP_SHADOW.elevated)
    .onClick(() => {
      this.onSelectCourse(course.code)
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

  private getListTags(course: Course): string[] {
    const tags: string[] = []
    for (let i = 0; i < course.tags.length && tags.length < 2; i += 1) {
      if (course.tags[i].trim().length > 0) tags.push(course.tags[i])
    }
    return tags
  }

  private getCardTitle(title: string): string {
    if (this.measureTitleUnits(title) <= this.courseTitleMaxUnits) {
      return title
    }
    const maxVisibleUnits = this.courseTitleMaxUnits - this.courseTitleEllipsisReserveUnits
    let result = ''
    let currentUnits = 0
    for (let index = 0; index < title.length; index += 1) {
      const char = title[index]
      const charUnits = this.getTitleCharUnits(char)
      if (currentUnits + charUnits > maxVisibleUnits) {
        break
      }
      result += char
      currentUnits += charUnits
    }
    return `${result}...`
  }

  private measureTitleUnits(title: string): number {
    let units = 0
    for (let index = 0; index < title.length; index += 1) {
      units += this.getTitleCharUnits(title[index])
    }
    return units
  }

  private getTitleCharUnits(char: string): number {
    return this.isWideTitleChar(char) ? 1 : 0.5
  }

  private isWideTitleChar(char: string): boolean {
    return /[\u1100-\u115F\u2E80-\uA4CF\uAC00-\uD7A3\uF900-\uFAFF\uFE10-\uFE19\uFE30-\uFE6F\uFF01-\uFF60\uFFE0-\uFFE6]/.test(char)
  }
}
