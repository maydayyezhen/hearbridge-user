/**
 * User 文件，负责用户领域实体定义。
 */

import { Course } from './Course'
import { UserTrainingItem } from './UserTrainingItem'

/** User。 */
export interface User {
  id: number
  no: string
  username: string
  phone: string
  status: number
  createdAt: string
  lastLoginAt: string
  nickname: string
  avatarUrl: string
  coverUrl: string
  gender: number
  birthday: string
  signature: string
  hasPassword: boolean
  phoneBound: boolean
  passwordUpdatedAt: string
  companionDays: number
  trainedQuestionCount: number
  trainingCount: number
  trainingMinutes: number
  lastTrainingAt: string
  favoriteCourses: Course[]
  favoriteItems: UserTrainingItem[]
  recentCourses: Course[]
}

/** createUser。 */
export function createUser(): User {
  return {
    id: 0,
    no: '',
    username: '',
    phone: '',
    status: 0,
    createdAt: '',
    lastLoginAt: '',
    nickname: '听桥用户',
    avatarUrl: '',
    coverUrl: '',
    gender: 0,
    birthday: '',
    signature: '',
    hasPassword: false,
    phoneBound: false,
    passwordUpdatedAt: '',
    companionDays: 0,
    trainedQuestionCount: 0,
    trainingCount: 0,
    trainingMinutes: 0,
    lastTrainingAt: '',
    favoriteCourses: [],
    favoriteItems: [],
    recentCourses: []
  }
}
