import { TrainingType } from '../static/train/TrainingRuntimeTypes'

/**
 * Course 文件，负责课程领域模型定义。
 */

export class Course {
  id: number
  code: string
  name: string
  coverUrl: string
  intro: string
  trainingType: TrainingType
  tags: string[]
  learnCount: number
  level: number
  status: number
  updatedAt: string
  progressPercent: number
  lastLearnedAt: string
  currentItemCode: string
  currentItemName: string
  favorite: boolean

  constructor(
    id: number = 0,
    code: string = '',
    name: string = '',
    coverUrl: string = '',
    intro: string = '',
    trainingType: TrainingType = 'gesture',
    tags: string[] = [],
    learnCount: number = 0,
    level: number = 0,
    status: number = 1,
    updatedAt: string = '',
    progressPercent: number = 0,
    lastLearnedAt: string = '',
    currentItemCode: string = '',
    currentItemName: string = '',
    favorite: boolean = false
  ) {
    this.id = id
    this.code = code
    this.name = name
    this.coverUrl = coverUrl
    this.intro = intro
    this.trainingType = trainingType
    this.tags = tags
    this.learnCount = learnCount
    this.level = level
    this.status = status
    this.updatedAt = updatedAt
    this.progressPercent = progressPercent
    this.lastLearnedAt = lastLearnedAt
    this.currentItemCode = currentItemCode
    this.currentItemName = currentItemName
    this.favorite = favorite
  }
}

/** createCourse。 */
export function createCourse(): Course {
  return new Course()
}

/** createCourseByPatch。 */
export function createCourseByPatch(patch: Partial<Course>): Course {
  const course = new Course()
  course.id = patch.id ?? course.id
  course.code = patch.code ?? course.code
  course.name = patch.name ?? course.name
  course.coverUrl = patch.coverUrl ?? course.coverUrl
  course.intro = patch.intro ?? course.intro
  course.trainingType = patch.trainingType ?? course.trainingType
  course.tags = patch.tags ? [...patch.tags] : course.tags
  course.learnCount = patch.learnCount ?? course.learnCount
  course.level = patch.level ?? course.level
  course.status = patch.status ?? course.status
  course.updatedAt = patch.updatedAt ?? course.updatedAt
  course.progressPercent = patch.progressPercent ?? course.progressPercent
  course.lastLearnedAt = patch.lastLearnedAt ?? course.lastLearnedAt
  course.currentItemCode = patch.currentItemCode ?? course.currentItemCode
  course.currentItemName = patch.currentItemName ?? course.currentItemName
  course.favorite = patch.favorite ?? course.favorite
  return course
}
