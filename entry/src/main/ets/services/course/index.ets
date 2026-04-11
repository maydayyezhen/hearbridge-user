/**
 * course 模块正式出口。
 */
export {
  createCourseListSelectedTags,
  findCourseInList,
  getCourseOpenPhrase,
  loadCourseListState,
  loadCourseListTags,
  normalizeCourseListTrainingType,
  shouldSwitchCourseListSort,
  SortType,
  toggleCourseListTagState
} from './CourseListPageService'

export {
  buildCourseDetailBackPath,
  buildCourseTrainingPath,
  canContinueCourseTraining,
  CourseDetailPageData,
  getCourseDetailIntroText,
  getNextCourseTrainingItemCode,
  loadCourseDetailPageData,
  readCachedCourseDetailView,
  toggleCourseDetailFavorite
} from './CourseDetailPageService'
