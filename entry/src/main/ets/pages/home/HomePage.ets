/**
 * HomePage 页面文件，负责页面展示与交互承接。
 */

import { go, goRootTab } from '../../router/Router'
import { TrainingType } from '../../domain/static/train/TrainingRuntimeTypes'
import { buildCourseDetailPath, buildTrainRootPath } from '../../router/RouteBuilders'
import { getRouteBasePath } from '../../router/RouteMatcher'
import { HOME_PATH } from '../../router/RoutePaths'
import {
  cacheTodayRecommendCourse,
  createHomeViewState,
  HomeViewState,
  hydrateHomeViewStateFromCache,
  loadHomeViewState,
  shouldRequestHomeOnEnter
} from '../../services/home/index'
import { APP_COLORS } from '../../config/AppStyle'
import { HomeHeroCard } from './components/HomeHeroCard'
import { HomeRecommendCard } from './components/HomeRecommendCard'
import { HomeStatusCard } from './components/HomeStatusCard'

@Component
export struct HomePage {
  @Prop isActive: boolean = false
  @StorageLink('route.path')
  @Watch('handleRoutePathChange')
  routePath: string = '/launch'
  @State home: HomeViewState = createHomeViewState()

  private hasAppeared: boolean = false

  aboutToAppear(): void {
    this.hasAppeared = true
    if (this.isHomeRoute(this.routePath)) {
      void this.handleTabActivated()
    }
  }

  private handleRoutePathChange(): void {
    if (this.hasAppeared && this.isHomeRoute(this.routePath)) {
      void this.handleTabActivated()
    }
  }

  private isHomeRoute(path: string): boolean {
    return getRouteBasePath(path) === HOME_PATH
  }

  private async handleTabActivated(): Promise<void> {
    this.home = hydrateHomeViewStateFromCache(this.home)
    if (shouldRequestHomeOnEnter(this.home)) {
      void this.loadHomeState()
    }
  }

  private async loadHomeState(): Promise<void> {
    this.home = await loadHomeViewState()
  }

  private openTrainingList(trainingType: TrainingType): void {
    goRootTab(buildTrainRootPath(trainingType))
  }

  private openTodayRecommend(): void {
    if (this.home.recommendCourse.code.length === 0) {
      this.openTrainingList('gesture')
      return
    }
    cacheTodayRecommendCourse(this.home.recommendCourse, this.home.recommendText)
    go(buildCourseDetailPath(this.home.recommendCourse.code))
  }

  build() {
    Column({ space: 18 }) {
      HomeHeroCard({
        heroTitle: this.home.heroTitle,
        heroSubtitle: this.home.heroSubtitle,
        heroMediaUrl: this.home.heroMediaUrl,
        onOpenHeroTraining: (): void => {
          this.openTrainingList('gesture')
        }
      })

      HomeStatusCard({
        todayStatusPercent: this.home.statusPercent,
        todayStatusTitle: this.home.statusTitle,
        todayStatusDetail: this.home.statusDetail
      })

      HomeRecommendCard({
        recommendCourseName: this.home.recommendCourse.name,
        recommendText: this.home.recommendText,
        recommendDurationText: this.home.durationText,
        recommendCoverUrl: this.home.recommendCourse.coverUrl,
        onOpenTodayRecommend: (): void => {
          this.openTodayRecommend()
        }
      })
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 6, bottom: 96 })
    .backgroundColor(APP_COLORS.backgroundStart)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])
  }
}
