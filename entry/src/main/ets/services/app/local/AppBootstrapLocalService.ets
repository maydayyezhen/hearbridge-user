/**
 * 应用启动本地服务，负责初始化路由、仓储、训练本地服务以及请求层 token 提供器。
 */
import common from '@ohos.app.ability.common'
import { initRouter } from '../../../router/Router'
import { setHttpAuthTokenProvider } from '../../../api/HttpClient'
import { setApiDebugWriter } from '../../../api/ApiDebug'
import { initializeAuthAfterLaunch, AuthBootstrapResult } from '../../auth/local/AuthLocalService'
import { initAuthRepository, readAuthToken } from '../../../repository/auth/AuthRepository'
import { initCoursePreviewRepository } from '../../../repository/course/CoursePreviewRepository'
import { initCourseDetailRepository } from '../../../repository/course/CourseDetailRepository'
import { initCourseSessionRepository } from '../../../repository/course/CourseSessionRepository'
import { initTrainingItemPreviewRepository } from '../../../repository/training-item/TrainingItemPreviewRepository'
import { initTrainingItemDetailRepository } from '../../../repository/training-item/TrainingItemDetailRepository'
import { initCourseTrainingItemIndexRepository } from '../../../repository/training-item/CourseTrainingItemIndexRepository'
import { initTrainSessionRepository } from '../../../repository/train-session/TrainSessionRepository'
import { initTrainSessionViewStateRepository } from '../../../repository/train-session/TrainSessionViewStateRepository'
import { initTrainResultViewStateRepository } from '../../../repository/train-session/TrainResultViewStateRepository'
import { initToastService } from '../../ui/local/ToastService'
import { initUserRepository } from '../../../repository/user/UserRepository'
import { initProfileImageCacheRepository } from '../../../repository/resource-cache/ProfileImageCacheRepository'
import { ENABLE_API_DEBUG_STATE } from '../../../config/AppConfig'
import { initApiDebugRepository, writeApiDebugText } from '../../../repository/ui/ApiDebugRepository'

/** 启动初始化项。 */
type AppInitializer = () => void

/**
 * 获取核心基础设施初始化项。
 */
function getCoreInitializers(): AppInitializer[] {
  return [
    initRouter,
    initAuthRepository,
    initUserRepository,
    initProfileImageCacheRepository
  ]
}

/**
 * 获取课程模块初始化项。
 */
function getCourseModuleInitializers(): AppInitializer[] {
  return [
    initCoursePreviewRepository,
    initCourseDetailRepository,
    initCourseSessionRepository
  ]
}

/**
 * 获取训练模块初始化项。
 */
function getTrainingModuleInitializers(): AppInitializer[] {
  return [
    initTrainingItemPreviewRepository,
    initTrainingItemDetailRepository,
    initCourseTrainingItemIndexRepository,
    initTrainSessionRepository,
    initTrainSessionViewStateRepository,
    initTrainResultViewStateRepository
  ]
}

/**
 * 获取界面基础设施初始化项。
 */
function getUiInitializers(): AppInitializer[] {
  const initializers: AppInitializer[] = [initToastService]
  if (ENABLE_API_DEBUG_STATE) {
    initializers.push(initApiDebugRepository)
  }
  return initializers
}

/**
 * 获取应用启动阶段需要执行的初始化项。
 */
function getAppInitializers(): AppInitializer[] {
  return [
    ...getCoreInitializers(),
    ...getCourseModuleInitializers(),
    ...getTrainingModuleInitializers(),
    ...getUiInitializers()
  ]
}

/**
 * 注册请求层调试文本输出器。
 */
function initializeApiDebugWriter(): void {
  setApiDebugWriter(ENABLE_API_DEBUG_STATE ? writeApiDebugText : null)
}

/**
 * 初始化应用启动依赖。
 * 负责初始化路由、仓储、本地训练服务以及请求层 token 提供器。
 */
function initializeAppInfrastructure(): void {
  const initializers = getAppInitializers()
  for (let index = 0; index < initializers.length; index += 1) {
    initializers[index]()
  }
  initializeApiDebugWriter()
  setHttpAuthTokenProvider((): string => readAuthToken())
}

/**
 * 应用启动统一初始化入口。
 * @param context 应用上下文。
 * @returns 启动认证恢复结果。
 */
export async function initializeAppOnLaunch(context: common.BaseContext): Promise<AuthBootstrapResult> {
  initializeAppInfrastructure()
  return await initializeAuthAfterLaunch(context, true)
}
