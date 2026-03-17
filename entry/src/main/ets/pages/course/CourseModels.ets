export class CourseItem {
  id: number
  courseName: string
  courseCode: string
  coverUrl: string
  intro: string
  sortNum: number
  status: number
  trainingType: string
  learningCount: number
  tag1: string
  tag2: string
  tag3: string

  constructor(
    id: number,
    courseName: string,
    courseCode: string,
    coverUrl: string,
    intro: string,
    sortNum: number,
    status: number,
    trainingType: string,
    learningCount: number,
    tag1: string,
    tag2: string,
    tag3: string
  ) {
    this.id = id
    this.courseName = courseName
    this.courseCode = courseCode
    this.coverUrl = coverUrl
    this.intro = intro
    this.sortNum = sortNum
    this.status = status
    this.trainingType = trainingType
    this.learningCount = learningCount
    this.tag1 = tag1
    this.tag2 = tag2
    this.tag3 = tag3
  }
}
