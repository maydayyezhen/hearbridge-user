/**
 * training 模块正式出口。
 *
 * 说明：
 * 1. 页面层统一通过 TrainPageService / TrainPageQueries 引用训练流程能力。
 * 2. 类型与少量基础类继续单独导出，供 StorageLink 与页面组件使用。
 */
import {
  buildSpeechCallbacks,
  clearExitState,
  clearExitStateLater,
  createSpeechPracticeService,
  jumpToItem,
  moveBackward,
  moveForward,
  openAudioPicker,
  openVideoPicker,
  pause,
  preparePageStage,
  restartPracticeSession,
  submitPractice,
  switchStage,
  syncPracticeMode,
  syncPracticeModeWithType,
  toggleCourseFavorite,
  toggleItemFavorite,
  loadSummary,
  createEmptySummary
} from './TrainPageService'
import {
  TrainResultDimension,
  TrainResultViewState,
  TrainSessionRuntime,
  TrainSessionViewState,
  buildTrainSummaryViewState,
  createEmptyTrainPageResultViewState,
  createEmptyTrainPageRuntime,
  createEmptyTrainPageViewState,
  getTrainPageCompletedItemIds,
  getTrainPageCurrentItem,
  getTrainPageCurrentItemMeaning,
  getTrainPageCurrentItemName,
  getTrainPageProgressText,
  getTrainPageStage,
  getTrainPageStageLabel,
  getTrainPageSubtitle,
  getTrainPageTitle,
  isTrainPageCourseFavorited,
  isTrainPageItemFavorited
} from './local/TrainPageQueryLocalService'
import { SpeechPracticeLocalService } from './local/TrainSpeechLocalService'
import { createTrainSessionRouteInput, TrainSessionRouteInput } from './local/TrainSessionBootstrapContextLocalService'
import { TrainStage } from '../../repository/train-session/TrainSessionRepository'
import { TrainPageCourseDisplay } from './model/TrainPageCourseDisplay'
import { PracticeMode, TrainingType, TrainItemStatus } from '../../domain/static/train/TrainingRuntimeTypes'
import { TrainSummaryViewState } from './model/TrainSummaryViewState'
import { TrainSessionSummaryViewData } from './model/TrainSessionSummaryViewData'
import { normalizeStage } from './local/TrainStageLocalService'
import { getTrainPageCourseDisplay } from './query/TrainPageScaffoldQueryService'

class TrainPageServiceFacade {
  buildSpeechCallbacks = buildSpeechCallbacks
  clearExitState = clearExitState
  clearExitStateLater = clearExitStateLater
  createSpeechPracticeService = createSpeechPracticeService
  jumpToItem = jumpToItem
  moveBackward = moveBackward
  moveForward = moveForward
  openAudioPicker = openAudioPicker
  openVideoPicker = openVideoPicker
  pause = pause
  preparePageStage = preparePageStage
  restartPracticeSession = restartPracticeSession
  submitPractice = submitPractice
  switchStage = switchStage
  syncPracticeMode = syncPracticeMode
  syncPracticeModeWithType = syncPracticeModeWithType
  toggleCourseFavorite = toggleCourseFavorite
  toggleItemFavorite = toggleItemFavorite
  loadSummary = loadSummary
  createEmptySummary = createEmptySummary
}

export const TrainPageService = new TrainPageServiceFacade()

export const normalizeTrainStage = normalizeStage

class TrainPageQueriesFacade {
  buildSummaryViewState = buildTrainSummaryViewState
  createEmptyResultViewState = createEmptyTrainPageResultViewState
  createEmptyRuntime = createEmptyTrainPageRuntime
  createEmptyViewState = createEmptyTrainPageViewState
  getCompletedItemIds = getTrainPageCompletedItemIds
  getCourseDisplay = getTrainPageCourseDisplay
  getCurrentItem = getTrainPageCurrentItem
  getCurrentItemMeaning = getTrainPageCurrentItemMeaning
  getCurrentItemName = getTrainPageCurrentItemName
  getProgressText = getTrainPageProgressText
  getStage = getTrainPageStage
  getStageLabel = getTrainPageStageLabel
  getSubtitle = getTrainPageSubtitle
  getTitle = getTrainPageTitle
  isCourseFavorited = isTrainPageCourseFavorited
  isItemFavorited = isTrainPageItemFavorited
}

export const TrainPageQueries = new TrainPageQueriesFacade()

export {
  createTrainSessionRouteInput,
  PracticeMode,
  SpeechPracticeLocalService,
  TrainItemStatus,
  TrainingType,
  TrainPageCourseDisplay,
  TrainResultDimension,
  TrainResultViewState,
  TrainSessionRuntime,
  TrainSessionRouteInput,
  TrainSessionViewState,
  TrainStage,
  TrainSummaryViewState
  ,TrainSessionSummaryViewData
}
