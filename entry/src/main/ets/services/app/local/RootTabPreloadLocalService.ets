import {
  createCourseListSelectedTags,
  loadCourseListState,
  loadCourseListTags
} from '../../course/index'
import {
  createHomeViewState,
  hydrateHomeViewStateFromCache,
  loadHomeViewState,
  shouldRequestHomeOnEnter
} from '../../home/index'
import {
  createEmptyRecordState,
  hydrateRecordPageOverview,
  hydrateRecordPageRecentCourses,
  loadRecordPageOverview,
  loadRecordPageRecentCourses,
  shouldRefreshRecordPageOverview,
  shouldRefreshRecordPageRecentCourses
} from '../../record/index'

let rootTabPreloadRunning: Promise<void> | null = null
let rootTabPreloaded: boolean = false

async function preloadHomeTab(): Promise<void> {
  const home = hydrateHomeViewStateFromCache(createHomeViewState())
  if (shouldRequestHomeOnEnter(home)) {
    await loadHomeViewState()
  }
}

async function preloadTrainTab(): Promise<void> {
  const initialTrainingType = 'gesture'
  await loadCourseListTags()
  await loadCourseListState(
    '',
    initialTrainingType,
    createCourseListSelectedTags(initialTrainingType),
    'default',
    1,
    8,
    false,
    []
  )
}

async function preloadRecordTab(): Promise<void> {
  let record = createEmptyRecordState()
  record = hydrateRecordPageOverview(record)
  record = hydrateRecordPageRecentCourses(record)
  if (shouldRefreshRecordPageOverview(record)) {
    record = await loadRecordPageOverview(record)
  }
  if (shouldRefreshRecordPageRecentCourses(record)) {
    record = await loadRecordPageRecentCourses(record, false)
  }
}

async function preloadProfileTab(): Promise<void> {
  return Promise.resolve()
}

export function preloadRootTabData(): void {
  if (rootTabPreloaded || rootTabPreloadRunning !== null) {
    return
  }
  rootTabPreloadRunning = Promise.allSettled([
    preloadHomeTab(),
    preloadTrainTab(),
    preloadRecordTab(),
    preloadProfileTab()
  ]).then(() => {
    rootTabPreloaded = true
    rootTabPreloadRunning = null
  }).catch(() => {
    rootTabPreloaded = true
    rootTabPreloadRunning = null
  })
}

export function resetRootTabPreloadState(): void {
  rootTabPreloaded = false
  rootTabPreloadRunning = null
}
