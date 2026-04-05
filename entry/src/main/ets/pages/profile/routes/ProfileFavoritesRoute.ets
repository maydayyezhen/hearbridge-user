import { FavoriteCourseSummary, FavoriteTrainingItemSummary } from '../../../api/FavoriteApi'

class FavoriteDisplayItem {
  id: string
  title: string
  subtitle: string
  courseCode: string
  courseName: string
  trainingType: string
  phrase: string

  constructor(id: string, title: string, subtitle: string, courseCode: string, courseName: string, trainingType: string,
    phrase: string) {
    this.id = id
    this.title = title
    this.subtitle = subtitle
    this.courseCode = courseCode
    this.courseName = courseName
    this.trainingType = trainingType
    this.phrase = phrase
  }
}

@Component
export struct ProfileFavoritesRoute {
  @Prop favoriteTab: string = 'course'
  @Prop favoriteCourseCodes: string[] = []
  @Prop favoriteCourses: FavoriteCourseSummary[] = []
  @Prop favoriteTrainingItemCodes: string[] = []
  @Prop favoriteTrainingItems: FavoriteTrainingItemSummary[] = []
  onOpenFavoriteCourse: (courseCode: string) => void = (_courseCode: string) => {}
  onOpenFavoriteTrainingItem: (courseCode: string, trainingType: string, itemCode: string, phrase: string) => void =
    (_courseCode: string, _trainingType: string, _itemCode: string, _phrase: string) => {}

  build() {
    Column({ space: 0 }) {
      Column({ space: 10 }) {
        if (this.favoriteTab === 'course') {
          if (this.getFavoriteCourseItems().length === 0) {
            this.buildEmpty('还没有收藏课程')
          } else {
            ForEach(this.getFavoriteCourseItems(), (item: FavoriteDisplayItem) => {
              this.buildFavoriteRow(item, () => {
                this.onOpenFavoriteCourse(item.courseCode)
              })
            }, (item: FavoriteDisplayItem) => item.id)
          }
        } else {
          if (this.getFavoriteTrainingItems().length === 0) {
            this.buildEmpty('还没有收藏训练项')
          } else {
            ForEach(this.getFavoriteTrainingItems(), (item: FavoriteDisplayItem) => {
              this.buildFavoriteRow(item, () => {
                this.onOpenFavoriteTrainingItem(item.courseCode, item.trainingType, item.id, item.phrase)
              })
            }, (item: FavoriteDisplayItem) => item.id)
          }
        }
      }
      .width('100%')
    }
    .width('100%')
  }

  private getFavoriteCourseItems(): FavoriteDisplayItem[] {
    const items: FavoriteDisplayItem[] = []
    if (this.favoriteCourses.length > 0) {
      for (let i = 0; i < this.favoriteCourses.length; i += 1) {
        const course = this.favoriteCourses[i]
        const courseCode = course.courseCode.length > 0
          ? course.courseCode
          : (i < this.favoriteCourseCodes.length ? this.favoriteCourseCodes[i] : '')
        items.push(new FavoriteDisplayItem(
          courseCode.length > 0 ? courseCode : `favorite-course-${i}`,
          course.courseName,
          this.buildCourseSubtitle(course.trainingType, courseCode),
          courseCode,
          course.courseName,
          course.trainingType,
          ''
        ))
      }
      return items
    }

    for (let i = 0; i < this.favoriteCourseCodes.length; i += 1) {
      const code = this.favoriteCourseCodes[i]
      items.push(new FavoriteDisplayItem(code, code, `课程 · ${code}`, code, '', '', ''))
    }
    return items
  }

  private getFavoriteTrainingItems(): FavoriteDisplayItem[] {
    const items: FavoriteDisplayItem[] = []
    if (this.favoriteTrainingItems.length > 0) {
      for (let i = 0; i < this.favoriteTrainingItems.length; i += 1) {
        const item = this.favoriteTrainingItems[i]
        items.push(new FavoriteDisplayItem(
          item.itemCode,
          item.itemName,
          `${this.toTrainingTypeLabel(item.trainingType)} · ${item.courseName}`,
          item.courseCode,
          item.courseName,
          item.trainingType,
          item.itemName
        ))
      }
      return items
    }

    for (let i = 0; i < this.favoriteTrainingItemCodes.length; i += 1) {
      const code = this.favoriteTrainingItemCodes[i]
      items.push(new FavoriteDisplayItem(code, code, `训练项 · ${code}`, '', '', '', code))
    }
    return items
  }

  private toTrainingTypeLabel(trainingType: string): string {
    const normalizedType = trainingType.toUpperCase()
    if (normalizedType === 'VOICE' || normalizedType === 'SPEECH') {
      return '手势'
    }
    if (normalizedType === 'GESTURE') {
      return '口语'
    }
    return '课程'
  }

  private buildCourseSubtitle(trainingType: string, courseCode: string): string {
    const typeLabel = this.toTrainingTypeLabel(trainingType)
    if (courseCode.length > 0) {
      return `${typeLabel} · ${courseCode}`
    }
    return typeLabel
  }

  @Builder
  private buildFavoriteRow(item: FavoriteDisplayItem, onClickAction: () => void) {
    Row({ space: 12 }) {
      Stack({ alignContent: Alignment.Center }) {
        Row()
          .width(30)
          .height(30)
          .backgroundColor('#EDF4FF')
          .borderRadius(15)
        SymbolGlyph($r('sys.symbol.star_fill'))
          .fontSize(15)
          .fontColor(['#2E79F4'])
      }
      .width(30)
      .height(30)

      Column({ space: 4 }) {
        Text(item.title)
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor('#1F2A44')
          .maxLines(1)
        Text(item.subtitle)
          .fontSize(12)
          .fontColor('#7A8CA7')
          .maxLines(1)
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      SymbolGlyph($r('sys.symbol.chevron_forward'))
        .fontSize(14)
        .fontColor(['#9BAAC0'])
    }
    .width('100%')
    .padding(14)
    .backgroundColor('#FFFFFF')
    .borderRadius(16)
    .shadow({ radius: 12, color: '#15304B0D', offsetX: 0, offsetY: 5 })
    .onClick(() => {
      onClickAction()
    })
  }

  @Builder
  private buildEmpty(text: string) {
    Column({ space: 8 }) {
      SymbolGlyph($r('sys.symbol.star'))
        .fontSize(22)
        .fontColor(['#9FB0C8'])
      Text(text)
        .fontSize(13)
        .fontColor('#7F90A8')
    }
    .width('100%')
    .padding({ top: 30, bottom: 30 })
    .alignItems(HorizontalAlign.Center)
  }
}
