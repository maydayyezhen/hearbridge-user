import { Course } from '../../domain/entity/Course'
import {
  CourseListLoadResult,
  getCourseListExtraTags,
  getCourseListTypeFilter,
  loadCourseListPageData,
  loadCourseTagOptions,
  normalizeCourseListTrainingFilter,
  normalizeCourseListTrainingType,
  SortType
} from './api/CourseListApiService'
import { mapCourseListDtos, mapCourseTagDtos } from './mapper/CourseApiMapper'
import { getCourseOpenPhrase } from './local/CourseListLocalService'

export {
  CourseListLoadResult,
  getCourseListExtraTags,
  getCourseListTypeFilter,
  mapCourseListDtos,
  mapCourseTagDtos,
  normalizeCourseListTrainingFilter,
  normalizeCourseListTrainingType,
  SortType,
  getCourseOpenPhrase
}

export interface CourseListTagState {
  currentTrainingType: string
  selectedTags: string[]
}

interface CourseListCacheState {
  tagLoaded: boolean
  tags: string[]
  listEntries: Map<string, CourseListLoadResult>
}

const GESTURE_TAG = '\u624b\u52bf'
const SPEECH_TAG = '\u53e3\u8bed'

const courseListCacheState: CourseListCacheState = {
  tagLoaded: false,
  tags: [],
  listEntries: new Map<string, CourseListLoadResult>()
}

function containsCourseTag(list: string[], target: string): boolean {
  return list.includes(target)
}

function isCourseTypeTag(tag: string): boolean {
  return tag === GESTURE_TAG || tag === SPEECH_TAG
}

function cloneCourse(source: Course): Course {
  const next = new Course()
  next.id = source.id
  next.code = source.code
  next.name = source.name
  next.coverUrl = source.coverUrl
  next.intro = source.intro
  next.trainingType = source.trainingType
  next.tags = source.tags.slice()
  next.learnCount = source.learnCount
  next.level = source.level
  next.status = source.status
  next.favorite = source.favorite
  next.updatedAt = source.updatedAt
  next.progressPercent = source.progressPercent
  next.lastLearnedAt = source.lastLearnedAt
  return next
}

function cloneCourseListLoadResult(source: CourseListLoadResult): CourseListLoadResult {
  const nextCourses: Course[] = []
  for (let index = 0; index < source.courses.length; index += 1) {
    nextCourses.push(cloneCourse(source.courses[index]))
  }
  return {
    courses: nextCourses,
    pageNo: source.pageNo,
    pageSize: source.pageSize,
    total: source.total,
    hasMore: source.hasMore,
    tip: source.tip
  }
}

function buildCourseListCacheKey(
  keyword: string,
  currentTrainingType: string,
  selectedTags: string[],
  sortType: SortType,
  pageNo: number,
  pageSize: number
): string {
  const sortedTags = selectedTags.slice().sort()
  return [
    keyword.trim(),
    normalizeCourseListTrainingFilter(currentTrainingType),
    sortedTags.join('|'),
    sortType,
    String(pageNo),
    String(pageSize)
  ].join('::')
}

export function createCourseListSelectedTags(initialTrainingType: string): string[] {
  const normalized = normalizeCourseListTrainingType(initialTrainingType)
  return normalized === 'speech' ? [SPEECH_TAG] : [GESTURE_TAG]
}

export async function loadCourseListTags(): Promise<string[]> {
  if (courseListCacheState.tagLoaded) {
    return courseListCacheState.tags.slice()
  }
  const tags = await loadCourseTagOptions()
  courseListCacheState.tags = tags.slice()
  courseListCacheState.tagLoaded = true
  return tags.slice()
}

export async function loadCourseListState(
  keyword: string,
  currentTrainingType: string,
  selectedTags: string[],
  sortType: SortType,
  pageNo: number,
  pageSize: number,
  loadMore: boolean,
  currentCourses: Course[]
): Promise<CourseListLoadResult> {
  const normalizedPageNo = loadMore ? pageNo + 1 : 1
  if (!loadMore) {
    const cacheKey = buildCourseListCacheKey(keyword, currentTrainingType, selectedTags, sortType, normalizedPageNo, pageSize)
    const cached = courseListCacheState.listEntries.get(cacheKey)
    if (cached !== undefined) {
      return cloneCourseListLoadResult(cached)
    }
  }

  const result = await loadCourseListPageData(
    keyword,
    currentTrainingType,
    selectedTags,
    sortType,
    normalizedPageNo,
    pageSize
  )

  if (loadMore) {
    const mergedCourses: Course[] = currentCourses.slice()
    for (let i = 0; i < result.courses.length; i += 1) {
      mergedCourses.push(result.courses[i])
    }
    result.courses = mergedCourses
    result.hasMore = result.courses.length < result.total
    return result
  }

  const cacheKey = buildCourseListCacheKey(keyword, currentTrainingType, selectedTags, sortType, result.pageNo, result.pageSize)
  courseListCacheState.listEntries.set(cacheKey, cloneCourseListLoadResult(result))
  return result
}

export function toggleCourseListTagState(currentTrainingType: string, selectedTags: string[], tag: string): CourseListTagState {
  const nextTags: string[] = []
  const tagExists = containsCourseTag(selectedTags, tag)
  if (isCourseTypeTag(tag)) {
    for (let i = 0; i < selectedTags.length; i += 1) {
      if (!isCourseTypeTag(selectedTags[i])) {
        nextTags.push(selectedTags[i])
      }
    }
    if (!tagExists) {
      nextTags.push(tag)
    }
    return {
      currentTrainingType: tagExists ? '' : (tag === SPEECH_TAG ? 'speech' : 'gesture'),
      selectedTags: nextTags
    }
  }

  for (let i = 0; i < selectedTags.length; i += 1) {
    nextTags.push(selectedTags[i])
  }

  const finalTags: string[] = []
  if (tagExists) {
    for (let i = 0; i < nextTags.length; i += 1) {
      if (nextTags[i] !== tag) {
        finalTags.push(nextTags[i])
      }
    }
  } else {
    for (let i = 0; i < nextTags.length; i += 1) {
      finalTags.push(nextTags[i])
    }
    finalTags.push(tag)
  }

  return {
    currentTrainingType,
    selectedTags: finalTags
  }
}

export function shouldSwitchCourseListSort(currentSortType: SortType, nextSortType: SortType): boolean {
  return currentSortType !== nextSortType
}

export function findCourseInList(courses: Course[], courseCode: string): Course | null {
  for (let i = 0; i < courses.length; i += 1) {
    if (courses[i].code === courseCode) return courses[i]
  }
  return null
}

export function clearCourseListServiceCache(): void {
  courseListCacheState.tagLoaded = false
  courseListCacheState.tags = []
  courseListCacheState.listEntries.clear()
}
