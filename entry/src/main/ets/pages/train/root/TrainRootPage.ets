/**
 * TrainRootPage 页面文件，负责页面展示与交互承接。
 */

import { User, createUser } from '../../../domain/entity/User'
import { go } from '../../../router/Router'
import { buildCourseDetailPath } from '../../../router/RouteBuilders'
import { getRouteBasePath } from '../../../router/RouteMatcher'
import { TRAIN_PATH } from '../../../router/RoutePaths'
import { getTrainRootTrainingType } from './TrainRootRouteAdapter'
import { readFavoriteCourseCodesFromUser, toggleCourseFavoriteAction } from '../../../services/user/index'
import { showGlobalToast } from '../../../services/ui/index'
import { CourseListPage } from './CourseListPage'
import { TrainingType } from '../../../domain/static/train/TrainingRuntimeTypes'

@Component
export struct TrainRootPage {
  @Prop isActive: boolean = false
  /** 当前登录用户。 */
  @StorageLink('user') user: User = createUser()
  /** 当前训练类型。 */
  @State trainingType: TrainingType = 'gesture'
  /** 当前路由路径。 */
  @StorageLink('route.path')
  @Watch('handleRoutePathChange')
  routePath: string = '/train'

  private hasAppeared: boolean = false

  /** 页面出现时同步路由中的训练类型。 */
  aboutToAppear(): void {
    this.hasAppeared = true
    if (this.isTrainRootRoute(this.routePath)) {
      this.syncTrainingTypeFromRoute()
    }
  }

  private handleRoutePathChange(): void {
    if (this.hasAppeared && this.isTrainRootRoute(this.routePath)) {
      this.syncTrainingTypeFromRoute()
    }
  }

  private isTrainRootRoute(path: string): boolean {
    return getRouteBasePath(path) === TRAIN_PATH
  }

  private syncTrainingTypeFromRoute(): void {
    this.trainingType = getTrainRootTrainingType(this.routePath)
  }


  build() {
    CourseListPage({
      initialTrainingType: this.trainingType,
      favoriteCourseCodes: readFavoriteCourseCodesFromUser(this.user),
      onToggleCourseFavorite: (course): void => {
        void toggleCourseFavoriteAction(course.code, course.name, course.trainingType).then((result) => {
          showGlobalToast(result.message, result.tone)
        })
      },
      onOpenCourse: (_courseName: string, courseCode: string, _phrase: string, _toResult: boolean, _courseTrainingType: string): void => {
        go(buildCourseDetailPath(courseCode))
      }
    })
  }
}
