class CourseItem {
  id: number
  courseName: string
  courseCode: string
  coverUrl: string
  intro: string
  sortNum: number
  status: number
  trainingType: string

  constructor(id: number, courseName: string, courseCode: string, coverUrl: string, intro: string, sortNum: number, status: number, trainingType: string) {
    this.id = id
    this.courseName = courseName
    this.courseCode = courseCode
    this.coverUrl = coverUrl
    this.intro = intro
    this.sortNum = sortNum
    this.status = status
    this.trainingType = trainingType
  }
}

@Component
export struct CourseListPage {
  @Prop trainingType: string = 'gesture'
  onTrainingTypeChange: (trainingType: string) => void = () => {}
  onOpenCourse: (courseName: string, courseCode: string) => void = () => {}

  private readonly courses: CourseItem[] = [
    new CourseItem(1, '日常问候入门', 'COURSE-101', 'http://192.168.142.128:9001/hearbridge-bucket/20260316/3ad909fc0af94c58a8f2be4ca2fe4cbcChatGPT%20Image%202026%E5%B9%B43%E6%9C%8816%E6%97%A5%2001_25_49.png', '用于基础问候表达训练。', 1, 1, 'gesture'),
    new CourseItem(2, '基础交流训练', 'COURSE-102', 'https://placehold.co/400x240/png?text=Course+102', '用于基础交流与礼貌表达。', 2, 1, 'gesture'),
    new CourseItem(3, '情景对话入门', 'COURSE-201', 'https://placehold.co/400x240/png?text=Course+201', '用于常见情景对话训练。', 3, 1, 'gesture'),
    new CourseItem(4, '声母训练入门', 'COURSE-301', 'https://placehold.co/400x240/png?text=Course+301', '用于基础语音发音训练。', 4, 1, 'speech'),
    new CourseItem(5, '日常跟读训练', 'COURSE-302', 'https://placehold.co/400x240/png?text=Course+302', '用于语音跟读与模仿训练。', 5, 1, 'speech')
  ]

  build() {
    Column({ space: 16 }) {
      this.buildHeader()
      this.buildTypeTabs()
      this.buildCourseList()
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 6, bottom: 118 })
  }

  @Builder
  private buildHeader() {
    Column({ space: 4 }) {
      Text(this.trainingType === 'gesture' ? '手势训练课程' : '口语训练课程')
        .width('100%')
        .fontSize(28)
        .fontWeight(FontWeight.Bold)
        .fontColor('#1F2A44')

      Text(this.trainingType === 'gesture' ? '按课程顺序练习基础手势表达' : '按课程顺序练习发音与跟读')
        .width('100%')
        .fontSize(12)
        .fontColor('#7A8CA7')
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  private buildTypeTabs() {
    Row({ space: 10 }) {
      this.buildTypeChip('gesture', '手势训练')
      this.buildTypeChip('speech', '口语训练')
    }
    .width('100%')
  }

  @Builder
  private buildTypeChip(type: string, label: string) {
    Text(label)
      .fontSize(13)
      .fontWeight(this.trainingType === type ? FontWeight.Medium : FontWeight.Regular)
      .fontColor(this.trainingType === type ? '#2563EB' : '#607089')
      .padding({ left: 14, right: 14, top: 10, bottom: 10 })
      .backgroundColor(this.trainingType === type ? '#E7F0FF' : '#FFFFFF')
      .borderRadius(16)
      .onClick(() => {
        this.onTrainingTypeChange(type)
      })
  }

  @Builder
  private buildCourseList() {
    Column({ space: 12 }) {
      ForEach(this.courses, (course: CourseItem) => {
        if (course.trainingType === this.trainingType && course.status === 1) {
          this.buildCourseCard(course)
        }
      }, (course: CourseItem) => course.courseCode)
    }
    .width('100%')
  }

  @Builder
  private buildCourseCard(course: CourseItem) {
    Row({ space: 18 }) {
      Image(course.coverUrl)
        .width(136)
        .height(76)
        .objectFit(ImageFit.Cover)
        .borderRadius(12)

      Column({ space: 10 }) {
        Text(course.courseName)
          .fontSize(19)
          .fontWeight(FontWeight.Medium)
          .fontColor('#1F2A44')

        Text(course.intro)
          .fontSize(12)
          .fontColor('#6E7E97')
          .maxLines(2)

        Row({ space: 8 }) {
          this.buildMetaTag('课程')
          this.buildMetaTag(course.courseCode)
        }
      }
      .alignItems(HorizontalAlign.Start)
      .margin({ left: 2 })

      Blank()
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 18, bottom: 18 })
    .backgroundColor('#FFFFFF')
    .borderRadius(18)
    .shadow({ radius: 18, color: '#15304B10', offsetX: 0, offsetY: 8 })
    .onClick(() => {
      this.onOpenCourse(course.courseName, course.courseCode)
    })
  }

  @Builder
  private buildMetaTag(label: string) {
    Text(label)
      .fontSize(11)
      .fontColor('#63738C')
      .padding({ left: 10, right: 10, top: 6, bottom: 6 })
      .backgroundColor('#F5F8FD')
      .borderRadius(12)
  }
}
