/**
 * record 模块正式出口。
 */
export {
  buildRecordCourseDetailPath,
  buildRecordPracticePath,
  createEmptyRecordState,
  getNonZeroRecordTrendPoints,
  getRecordDisplayLabel,
  getRecordPageTrendPoints,
  getRecordPageScoreCopy,
  getSafeRecordScore,
  getSegmentedBarHeight,
  hydrateRecordPageOverview,
  hydrateRecordPageRecentCourses,
  loadRecordPageOverview,
  loadRecordPageRecentCourses,
  RecentCourse,
  RecordScoreCopy,
  RecordPageState,
  shouldRefreshRecordPageOverview,
  shouldRefreshRecordPageRecentCourses,
  TrendPointItem
} from './RecordPageService'
