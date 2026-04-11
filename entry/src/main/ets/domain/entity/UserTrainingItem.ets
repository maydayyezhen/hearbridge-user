import { TrainItemStatus, TrainingType } from '../static/train/TrainingRuntimeTypes'

/**
 * UserTrainingItem 文件，负责用户侧训练项实体定义。
 */

export interface UserTrainingResource {
  type: string
  name: string
  url: string
  sort: number
}

/** UserTrainingItem。 */
export interface UserTrainingItem {
  id: number
  code: string
  name: string
  courseCode: string
  courseName: string
  trainingType: TrainingType
  order: number
  level: number
  status: TrainItemStatus
  score: number
  attemptCount: number
  durationSeconds: number
  meaning: string
  description: string
  goal: string
  precautions: string[]
  commonErrors: string[]
  tags: string[]
  resources: UserTrainingResource[]
  feedback: string
  startedAt: string
  submittedAt: string
  completedAt: string
  favorite: boolean
}

/** createUserTrainingItem。 */
export function createUserTrainingItem(): UserTrainingItem {
  return {
    id: 0,
    code: '',
    name: '',
    courseCode: '',
    courseName: '',
    trainingType: 'gesture',
    order: 0,
    level: 0,
    status: '',
    score: 0,
    attemptCount: 0,
    durationSeconds: 0,
    meaning: '',
    description: '',
    goal: '',
    precautions: [],
    commonErrors: [],
    tags: [],
    resources: [],
    feedback: '',
    startedAt: '',
    submittedAt: '',
    completedAt: '',
    favorite: false
  }
}
