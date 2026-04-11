/**
 * CourseApi 相关的请求函数与接口访问逻辑。
 * 课程详情加载链路通过 getCourseDetail(courseCode) 拉取课程静态详情。
 */

import http from '@ohos.net.http'
import { ApiResult } from '../common/Http'
import { requestApi } from '../HttpClient'

/** 课程标签源对象。 */
export interface CourseTagSource {
  name?: string
}

/** 课程列表单项源对象。 */
export interface CourseListItemSource {
  id?: number | string
  courseCode?: string
  courseName?: string
  coverUrl?: string
  intro?: string
  trainingType?: string
  tags?: string[]
  learnCount?: number | string
  difficultyLevel?: number | string
  status?: string
}

/** 课程详情源对象。 */
export interface CourseDetailSource {
  id?: number | string
  courseCode?: string
  courseName?: string
  coverUrl?: string
  intro?: string
  trainingType?: string
  tags?: string[]
  learnCount?: number | string
  difficultyLevel?: number | string
  level?: number | string
  status?: number | string
  favorite?: boolean
  updatedAt?: string
}

/** 课程列表响应源对象。 */
export interface CourseListResponseSource {
  list?: CourseListItemSource[]
  pageNo?: number | string
  total?: number | string
}

/** 课程标签列表响应源对象。 */
export interface CourseTagListResponseSource {
  list?: CourseTagSource[]
}

/**
 * 获取课程列表。
 */
export async function getCourseList(path: string = '/app/course/list'): Promise<ApiResult<CourseListResponseSource>> {
  return await requestApi<CourseListResponseSource>({
    path,
    method: http.RequestMethod.GET
  })
}

/**
 * 获取课程详情。
 * 课程详情页在 detail 缓存缺失时调用该接口。
 */
export async function getCourseDetail(courseCode: string): Promise<ApiResult<CourseDetailSource>> {
  return await requestApi<CourseDetailSource>({
    path: `/app/course/detail/${encodeURIComponent(courseCode)}`,
    method: http.RequestMethod.GET
  })
}

/**
 * 获取课程标签列表。
 */
export async function getCourseTagList(): Promise<ApiResult<CourseTagListResponseSource>> {
  return await requestApi<CourseTagListResponseSource>({
    path: '/app/tag/list',
    method: http.RequestMethod.GET
  })
}
