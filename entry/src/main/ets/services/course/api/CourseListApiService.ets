/**
 * 课程列表 API 业务服务。
 * 负责消费课程列表接口、补齐默认值，并输出页面可直接消费的课程列表结果。
 */
import { CourseListItemSource, getCourseList, getCourseTagList } from '../../../api/requests/CourseApi'
import { Course } from '../../../domain/entity/Course'
import { mapCourseListDtos, mapCourseTagDtos } from '../mapper/CourseApiMapper'
import { normalizeTrainingType } from '../../../utils/TrainingTypeUtil'
import { TrainingType } from '../../../domain/static/train/TrainingRuntimeTypes'

/** 排序类型。 */
export type SortType = 'default' | 'hot' | 'latest'

/** 课程列表加载结果。 */
export interface CourseListLoadResult {
  courses: Course[]
  pageNo: number
  pageSize: number
  total: number
  hasMore: boolean
  tip: string
}

/** 课程列表过滤条件。 */
export interface CourseListFilterOptions {
  keyword?: string
  trainingType?: string
  extraTags?: string[]
  sortBy?: string
  pageNo?: number
  pageSize?: number
}

/** 统一规范课程类型过滤条件。 */
export function normalizeCourseListTrainingType(value: string): TrainingType {
  return normalizeTrainingType(value)
}

export function normalizeCourseListTrainingFilter(value: string): '' | TrainingType {
  const normalized = String(value ?? '').trim()
  if (normalized.length <= 0) {
    return ''
  }
  return normalizeTrainingType(normalized)
}

/** 获取训练类型过滤值。 */
export function getCourseListTypeFilter(selectedTags: string[]): string {
  for (let i = 0; i < selectedTags.length; i += 1) {
    if (selectedTags[i] === '口语') return 'voice'
    if (selectedTags[i] === '手势') return 'gesture'
  }
  return ''
}

function mapTrainingTypeToCourseListApiValue(trainingType: '' | TrainingType): string {
  if (trainingType.length <= 0) {
    return ''
  }
  return trainingType === 'speech' ? 'voice' : trainingType
}

/** 获取扩展标签（不包含类型标签）。 */
export function getCourseListExtraTags(selectedTags: string[]): string[] {
  const tags: string[] = []
  for (let i = 0; i < selectedTags.length; i += 1) {
    const tag = selectedTags[i]
    if (tag !== '口语' && tag !== '手势') {
      tags.push(tag)
    }
  }
  return tags
}

/** 构建课程列表请求路径，便于调试与日志对照。 */
function buildCourseListRequestPath(
  keyword: string,
  trainingType: '' | TrainingType,
  extraTags: string[],
  sortType: SortType,
  pageNo: number,
  pageSize: number
): string {
  const query: string[] = []
  if (keyword.length > 0) query.push(`keyword=${encodeURIComponent(keyword)}`)
  const apiTrainingType = mapTrainingTypeToCourseListApiValue(trainingType)
  if (apiTrainingType.length > 0) query.push(`trainingType=${encodeURIComponent(apiTrainingType)}`)
  for (let i = 0; i < extraTags.length; i += 1) {
    if (extraTags[i].trim().length > 0) {
      query.push(`tags=${encodeURIComponent(extraTags[i].trim())}`)
    }
  }
  if (sortType.length > 0 && sortType !== 'default') query.push(`sortBy=${encodeURIComponent(sortType)}`)
  query.push(`pageNo=${pageNo}`)
  query.push(`pageSize=${pageSize}`)
  return query.length > 0 ? `/app/course/list?${query.join('&')}` : '/app/course/list'
}

/** 规范接口分页数据。 */
function normalizePageData(items: CourseListItemSource[], pageNo: number, pageSize: number, total: number): CourseListLoadResult {
  const courses = mapCourseListDtos(items)
  return {
    courses,
    pageNo,
    pageSize,
    total,
    hasMore: courses.length < total,
    tip: ''
  }
}

/** 加载课程标签。 */
export async function loadCourseTagOptions(): Promise<string[]> {
  const result = await getCourseTagList()
  if (!result.ok || !result.data?.list) return []
  return mapCourseTagDtos(result.data.list)
}

/** 加载课程列表页数据。 */
export async function loadCourseListPageData(
  keyword: string,
  currentTrainingType: string,
  selectedTags: string[],
  sortType: SortType,
  pageNo: number,
  pageSize: number
): Promise<CourseListLoadResult> {
  const normalizedType: '' | TrainingType = normalizeCourseListTrainingFilter(currentTrainingType)
  const extraTags = getCourseListExtraTags(selectedTags)
  const path = buildCourseListRequestPath(keyword.trim(), normalizedType, extraTags, sortType, Math.max(1, pageNo), Math.max(1, pageSize))
  const result = await getCourseList(path)
  if (!result.ok || !result.data) {
    return {
      courses: [],
      pageNo: Math.max(1, pageNo),
      pageSize: Math.max(1, pageSize),
      total: 0,
      hasMore: false,
      tip: result.message.length > 0 ? result.message : '课程加载失败，请稍后重试。'
    }
  }
  const list = Array.isArray(result.data.list) ? result.data.list : []
  const safePageNo = Number(result.data.pageNo ?? pageNo)
  const safePageSize = Math.max(1, pageSize)
  const safeTotal = Number(result.data.total ?? list.length)
  return normalizePageData(list, safePageNo, safePageSize, safeTotal)
}
