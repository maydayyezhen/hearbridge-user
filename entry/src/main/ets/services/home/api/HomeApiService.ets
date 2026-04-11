import { getBootstrapConfig } from '../../../api/requests/ConfigApi'
import { getRecordOverview } from '../../../api/requests/RecordApi'
import { DEFAULT_COURSE_COVER_URL } from '../../../config/AppConfig'
import { Course } from '../../../domain/entity/Course'
import { readUserState } from '../../../repository/user/UserRepository'
import { saveCoursePreview } from '../../../repository/course/CoursePreviewRepository'

interface HomeViewCacheMeta {
  loadedOnce: boolean
}

const DEFAULT_HERO_TITLE = '\u6765\u7ec3\u4e00\u4f1a\u513f\u5427'
const DEFAULT_RECOMMEND_NAME = '\u4eca\u65e5\u63a8\u8350\u5f85\u52a0\u8f7d'
const DEFAULT_RECOMMEND_TEXT = '\u63a8\u8350\u8bfe\u7a0b\u52a0\u8f7d\u540e\u4f1a\u5c55\u793a\u5728\u8fd9\u91cc\u3002'
const DEFAULT_STATUS_DETAIL = '\u4eca\u65e5\u5b8c\u6210 0 \u4e2a\u8bad\u7ec3\u9879'

function createDefaultRecommendCourse(): Course {
  const course = new Course()
  course.coverUrl = DEFAULT_COURSE_COVER_URL
  course.status = 1
  return course
}

export class HomeViewState {
  heroTitle: string = ''
  heroSubtitle: string = ''
  heroMediaUrl: string = ''
  recommendCourse: Course = createDefaultRecommendCourse()
  recommendText: string = ''
  durationText: string = ''
  statusPercent: number = 0
  todayCompletedItemCount: number = 0
  statusTitle: string = ''
  statusDetail: string = ''
}

function normalizePercent(value: number | string | undefined): number {
  const parsed = Number(value ?? 0)
  if (!Number.isFinite(parsed) || parsed <= 0) return 0
  return Math.max(0, Math.min(100, Math.round(parsed)))
}

function normalizeCount(value: number | string | undefined): number {
  const parsed = Number(value ?? 0)
  if (!Number.isFinite(parsed) || parsed <= 0) return 0
  return Math.max(0, Math.round(parsed))
}

function resolveStatusSuffix(percent: number): string {
  if (percent >= 100) return '\u72b6\u6001\u6ee1\u683c'
  if (percent >= 80) return '\u7ee7\u7eed\u4fdd\u6301'
  if (percent >= 60) return '\u7a33\u6b65\u63d0\u5347'
  if (percent >= 40) return '\u518d\u63a5\u518d\u5389'
  if (percent > 0) return '\u5f00\u59cb\u53d1\u529b'
  return '\u51c6\u5907\u5f00\u7ec3'
}

function buildStatusTitle(percent: number): string {
  const user = readUserState()
  const nickname = user.nickname.length > 0 ? user.nickname : '\u4f60'
  return `${nickname}\uff0c${resolveStatusSuffix(percent)}`
}

function buildStatusDetail(todayCompletedItemCount: number): string {
  return `\u4eca\u65e5\u5b8c\u6210 ${todayCompletedItemCount} \u4e2a\u8bad\u7ec3\u9879`
}

export function createHomeViewState(): HomeViewState {
  return new HomeViewState()
}

const homeViewCacheMeta: HomeViewCacheMeta = {
  loadedOnce: false
}

const homeViewCacheState: HomeViewState = new HomeViewState()

function cloneRecommendCourse(source: Course): Course {
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

function copyHomeViewState(target: HomeViewState, source: HomeViewState): void {
  target.heroTitle = source.heroTitle
  target.heroSubtitle = source.heroSubtitle
  target.heroMediaUrl = source.heroMediaUrl
  target.recommendCourse = cloneRecommendCourse(source.recommendCourse)
  target.recommendText = source.recommendText
  target.durationText = source.durationText
  target.statusPercent = source.statusPercent
  target.todayCompletedItemCount = source.todayCompletedItemCount
  target.statusTitle = source.statusTitle
  target.statusDetail = source.statusDetail
}

function cloneHomeViewState(source: HomeViewState): HomeViewState {
  const next = createHomeViewState()
  copyHomeViewState(next, source)
  return next
}

function writeHomeViewCache(source: HomeViewState): void {
  copyHomeViewState(homeViewCacheState, source)
  homeViewCacheMeta.loadedOnce = true
}

function readHomeViewCache(): HomeViewState {
  return cloneHomeViewState(homeViewCacheState)
}

function applyUserFallbacks(home: HomeViewState): HomeViewState {
  home.statusPercent = normalizePercent(home.statusPercent)
  home.todayCompletedItemCount = normalizeCount(home.todayCompletedItemCount)
  home.statusTitle = buildStatusTitle(home.statusPercent)
  home.statusDetail = buildStatusDetail(home.todayCompletedItemCount)
  return home
}

function createDefaultHomeState(): HomeViewState {
  const home = createHomeViewState()
  home.heroTitle = DEFAULT_HERO_TITLE
  home.heroSubtitle = ''
  home.recommendCourse = createDefaultRecommendCourse()
  home.recommendCourse.name = DEFAULT_RECOMMEND_NAME
  home.recommendText = DEFAULT_RECOMMEND_TEXT
  home.durationText = ''
  home.todayCompletedItemCount = 0
  home.statusTitle = buildStatusTitle(0)
  home.statusDetail = DEFAULT_STATUS_DETAIL
  return applyUserFallbacks(home)
}

function readNonEmptyString(value: string | undefined): string {
  const nextValue = String(value ?? '').trim()
  return nextValue.length > 0 ? nextValue : ''
}

export function shouldRequestHomeOnEnter(_home: HomeViewState): boolean {
  return !homeViewCacheMeta.loadedOnce
}

export function hydrateHomeViewStateFromCache(home: HomeViewState): HomeViewState {
  const next = cloneHomeViewState(home)
  if (!homeViewCacheMeta.loadedOnce) {
    return applyUserFallbacks(next)
  }
  copyHomeViewState(next, readHomeViewCache())
  return applyUserFallbacks(next)
}

export async function loadHomeViewState(): Promise<HomeViewState> {
  const bootstrapResult = await getBootstrapConfig()
  const recordOverviewResult = await getRecordOverview()

  if (!bootstrapResult.ok || !bootstrapResult.data) {
    if (homeViewCacheMeta.loadedOnce) {
      const cached = applyUserFallbacks(readHomeViewCache())
      if (recordOverviewResult.ok && recordOverviewResult.data?.summary) {
        cached.todayCompletedItemCount = normalizeCount(recordOverviewResult.data.summary.todayCompletedItemCount)
        cached.statusPercent = normalizePercent(recordOverviewResult.data.summary.todayStatusPercent)
      }
      const nextCached = applyUserFallbacks(cached)
      writeHomeViewCache(nextCached)
      return cloneHomeViewState(nextCached)
    }
    const nextDefault = createDefaultHomeState()
    if (recordOverviewResult.ok && recordOverviewResult.data?.summary) {
      nextDefault.todayCompletedItemCount = normalizeCount(recordOverviewResult.data.summary.todayCompletedItemCount)
      nextDefault.statusPercent = normalizePercent(recordOverviewResult.data.summary.todayStatusPercent)
    }
    const hydratedDefault = applyUserFallbacks(nextDefault)
    writeHomeViewCache(hydratedDefault)
    return cloneHomeViewState(hydratedDefault)
  }

  const data = bootstrapResult.data
  const next = createDefaultHomeState()

  if (data.homeHero) {
    const remoteHeroTitle = readNonEmptyString(data.homeHero.title)
    const remoteHeroSubtitle = readNonEmptyString(data.homeHero.subtitle)
    const remoteHeroMediaUrl = readNonEmptyString(data.homeHero.mediaUrl)
    if (remoteHeroTitle.length > 0) {
      next.heroTitle = remoteHeroTitle
    }
    if (remoteHeroSubtitle.length > 0) {
      next.heroSubtitle = remoteHeroSubtitle
    }
    if (remoteHeroMediaUrl.length > 0) {
      next.heroMediaUrl = remoteHeroMediaUrl
    }
  }

  if (data.homeRecommend) {
    const recommendCourse = createDefaultRecommendCourse()
    recommendCourse.code = readNonEmptyString(data.homeRecommend.courseCode)
    recommendCourse.name = readNonEmptyString(data.homeRecommend.courseName)
    recommendCourse.coverUrl = readNonEmptyString(data.homeRecommend.coverUrl)
    next.recommendCourse = recommendCourse

    const remoteRecommendText = readNonEmptyString(data.homeRecommend.recommendText)
    const remoteDurationText = readNonEmptyString(data.homeRecommend.durationText)
    if (remoteRecommendText.length > 0) {
      next.recommendText = remoteRecommendText
    }
    if (remoteDurationText.length > 0) {
      next.durationText = remoteDurationText
    }
  }

  if (recordOverviewResult.ok && recordOverviewResult.data?.summary) {
    const summary = recordOverviewResult.data.summary
    next.todayCompletedItemCount = normalizeCount(summary.todayCompletedItemCount)
    next.statusPercent = normalizePercent(summary.todayStatusPercent)
  }

  const hydrated = applyUserFallbacks(next)
  writeHomeViewCache(hydrated)
  return cloneHomeViewState(hydrated)
}

export function clearHomeViewCache(): void {
  homeViewCacheMeta.loadedOnce = false
  copyHomeViewState(homeViewCacheState, createHomeViewState())
}

export function cacheTodayRecommendCourse(course: Course, recommendText: string): void {
  if (course.code.length === 0) return
  const nextCourse = new Course()
  nextCourse.id = course.id
  nextCourse.code = course.code
  nextCourse.name = course.name.length > 0 ? course.name : course.code
  nextCourse.coverUrl = course.coverUrl.length > 0 ? course.coverUrl : DEFAULT_COURSE_COVER_URL
  nextCourse.intro = recommendText
  nextCourse.trainingType = course.trainingType
  nextCourse.tags = course.tags.slice()
  nextCourse.learnCount = course.learnCount
  nextCourse.level = course.level
  nextCourse.status = course.status
  saveCoursePreview(nextCourse)
}
