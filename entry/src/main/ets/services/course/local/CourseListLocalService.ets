/**
 * 课程列表本地服务，负责课程列表页的纯本地文案辅助。
 */
import { Course } from '../../../domain/entity/Course'

/**
 * 根据课程状态与训练类型生成课程入口文案。
 */
export function getCourseOpenPhrase(course: Course): string {
  if (course.trainingType === 'speech') return '啊'
  return '你好'
}
