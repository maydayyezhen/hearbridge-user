import common from '@ohos.app.ability.common'
import { clearToken, readToken, saveToken } from '../api/AuthStorage'
import { getUserInfo, passwordLogin, passwordRegister, sendSmsCode, smsLogin } from '../api/AuthApi'
import { getBootstrapConfig } from '../api/ConfigApi'
import { CourseItem } from './course/CourseModels'
import { CourseListItemDto, CourseTagDto, getCourseList, getCourseTagList } from '../api/CourseApi'
import { addCourseFavorite, addTrainingItemFavorite, FavoriteCourseSummary, FavoriteTrainingItemSummary, removeCourseFavorite, removeTrainingItemFavorite } from '../api/FavoriteApi'
import { showGlobalToast } from '../api/GlobalToast'
import { getRecordOverview, RecordTrendDto, RecordTrendPointDto } from '../api/RecordApi'
import { getRecentTrainingCourses, RecentTrainingCourseItemDto } from '../api/TrainingApi'
import { APP_API_BASE_URL, DEFAULT_COURSE_COVER_URL, DEFAULT_TRAINING_COVER_URL, DEFAULT_USER_AVATAR_URL } from '../config/AppConfig'
import { CourseDetailPage } from './CourseDetailPage'
import { clearCourseDetailFieldCache } from './CourseDetailPage'
import { CourseListPage } from './CourseListPage'
import { HomePage } from './HomePage'
import { LoginPage } from './LoginPage'
import { ApiDebugPanel } from './components/ApiDebugPanel'
import { GlobalToast } from './components/GlobalToast'
import { ProfilePage } from './profile/ProfilePage'
import { RecordPage, RecentCourseItem, TrendPointItem } from './RecordPage'
import { TrainPage } from './TrainPage'
import { clearTrainingItemDetailFieldCache } from './TrainPage'

class AppRouteSnapshot {
  currentTab: number = 0
  trainView: string = 'courseList'
  trainDetailCourseCode: string = ''
  selectedCourseName: string = ''
  selectedPhrase: string = ''
  selectedItemCode: string = ''
  selectedCourseCode: string = ''
  selectedTrainEntryStage: string = 'intro'
  selectedCourseIntro: string = ''
  selectedCourseCoverUrl: string = ''
  currentTrainingType: string = 'gesture'
  recordDetailCourseCode: string = ''
  profileView: string = 'main'
}

@Entry
@Component
struct Index {
  @State splashTuningMode: boolean = false
  @State isAuthInitializing: boolean = true
  @State isLoggedIn: boolean = false
  @State currentTab: number = 0
  @State authScene: string = 'login'
  @State loginMode: string = 'sms'
  @State phoneNumber: string = ''
  @State verificationCode: string = ''
  @State account: string = ''
  @State password: string = ''
  @State registerAccount: string = ''
  @State registerPassword: string = ''
  @State registerConfirmPassword: string = ''
  @State registerPhone: string = ''
  @State loginTip: string = '\u8bf7\u8f93\u5165\u624b\u673a\u53f7\u5e76\u83b7\u53d6\u9a8c\u8bc1\u7801\u3002'
  @State codeCountdown: number = 0
  @State isSendingCode: boolean = false
  @State isLoggingIn: boolean = false
  @State dailyProgress: number = 40
  @State avatarUrl: string = DEFAULT_USER_AVATAR_URL
  @State splashMediaUrl: string = ''
  @State homeHeroTitle: string = '你好，准备开始训练'
  @State homeHeroSubtitle: string = '面向听障训练的口语与手语学习平台'
  @State homeHeroMediaUrl: string = ''
  @State homeRecommendCourseCode: string = ''
  @State homeRecommendCourseName: string = '日常问候入门'
  @State homeRecommendCoverUrl: string = ''
  @State homeRecommendText: string = '用最简单的表达开始今天的练习'
  @State homeRecommendDurationText: string = '5 分钟可完成'
  @State homeStatusPercent: number = 40
  @State homeStatusTitle: string = '今天状态已更新'
  @State homeStatusDetail: string = '继续保持当前训练节奏。'
  @State profileNickname: string = '新用户'
  @State profileSignature: string = ''
  @State profileCoverUrl: string = ''
  @State profileGender: number = 0
  @State profileBirthday: string = ''
  @State companionDays: number = 0
  @State trainedQuestionCount: number = 0
  @State sessionCountedTrainingItemCodes: string[] = []
  @State selectedCourseName: string = '\u65e5\u5e38\u95ee\u5019\u5165\u95e8'
  @State selectedPhrase: string = '你好'
  @State selectedItemCode: string = ''
  @State selectedCourseCode: string = 'COURSE-101'
  @State selectedTrainEntryStage: string = 'intro'
  @State selectedCourseIntro: string = '\u7528\u4e8e\u57fa\u7840\u95ee\u5019\u8868\u8fbe\u8bad\u7ec3\u3002'
  @State selectedCourseCoverUrl: string = DEFAULT_COURSE_COVER_URL
  @State currentTrainingType: string = 'gesture'
  @State trainView: string = 'courseList'
  @State trainDetailCourseCode: string = ''
  @State currentTrainingSessionId: number = 0
  @State recordDetailCourseCode: string = ''
  @State selectedFilter: string = '周'
  @State selectedGoal: string = '日常交流'
  @State selectedTheme: string = '\u6d77\u76d0\u84dd'
  @State profileView: string = 'main'
  @State notificationsEnabled: boolean = true
  @State vibrationEnabled: boolean = false
  @State isTrainScoring: boolean = false
  @State showApiDebugDialog: boolean = false
  @State profileBlockingOverlayVisible: boolean = false
  @State recordOverviewLoading: boolean = false
  @State recordOverviewLoaded: boolean = false
  @State recordTip: string = ''
  @State recordOverallScore: number = 0
  @State recordSummaryTitle: string = '学习表现待生成'
  @State recordSummaryAdvice: string = '进入记录页后将根据后端统计结果展示学习建议。'
  @State recordTrendPoints: TrendPointItem[] = []
  @State recordDayTrendPoints: TrendPointItem[] = []
  @State recordWeekTrendPoints: TrendPointItem[] = []
  @State recordOverviewTrendPoints: TrendPointItem[] = []
  @State preloadedCourseTags: string[] = []
  @State preloadedCourseItems: CourseItem[] = []
  @State preloadedCourseTotal: number = 0
  @State preloadedCourseListReady: boolean = false
  @State preloadedCourseListType: string = 'gesture'
  @State trainCourseKeyword: string = ''
  @State trainCourseSortType: string = 'default'
  @State trainCourseSelectedTags: string[] = []
  @State trainCourseCachedItems: CourseItem[] = []
  @State trainCourseCachedTotal: number = 0
  @State trainCourseCachedPageNo: number = 1
  @State trainCourseCachedType: string = 'gesture'
  @State trainCourseCachedReady: boolean = false
  @State favoriteCourseCodes: string[] = []
  @State favoriteTrainingItemCodes: string[] = []
  @State favoriteCourses: FavoriteCourseSummary[] = []
  @State favoriteTrainingItems: FavoriteTrainingItemSummary[] = []
  @State recentCourses: RecentCourseItem[] = []
  @State recentCoursesLoadingMore: boolean = false
  @State recentCoursesHasMore: boolean = true
  @State recentCoursesPageNo: number = 1
  @State nestedPageOffsetX: number = 0
  @State nestedPageOpacity: number = 1
  @State frozenPrimaryTab: number = -1
  @State splashImageScale: number = 128
  @State splashOffsetX: number = 0
  @State splashOffsetY: number = 40
  @State splashTextBottom: number = 308
  @State splashTextOffsetX: number = 0
  @State splashTextOffsetY: number = -40
  @State splashCnFontSize: number = 60
  @State splashEnFontSize: number = 23
  @State splashSubFontSize: number = 23
  @State splashFooterFontSize: number = 22
  @State splashFooterBottom: number = 20
  @State splashFooterOffsetX: number = 0
  @State splashFooterOffsetY: number = 0

  private readonly smsApiBaseUrl: string = APP_API_BASE_URL
  private readonly launchMinimumDurationMs: number = 3000
  private readonly exitConfirmWindowMs: number = 2000
  private countdownTimer: number = -1
  private launchStartedAt: number = 0
  private lastBackPressedAt: number = 0
  private nestedPageAnimating: boolean = false
  private routeHistory: AppRouteSnapshot[] = []

  aboutToAppear() {
    AppStorage.setOrCreate('apiDebugText', '暂无 API 调试信息')
    AppStorage.setOrCreate('globalToastVisible', false)
    AppStorage.setOrCreate('globalToastText', '')
    AppStorage.setOrCreate('globalToastTone', 'success')
    this.launchStartedAt = new Date().getTime()
    this.loadBootstrapConfig()
    this.initializeAuthState()
  }

  aboutToDisappear() {
    this.clearCountdownTimer()
  }

  onBackPress(): boolean {
    if (!this.isLoggedIn) {
      return false
    }
    if (this.isCurrentNestedRoute() && this.restorePreviousRoute()) {
      return true
    }
    if (this.currentTab === 3 && this.profileView !== 'main') {
      this.runNestedPageTransition(false, () => {
        this.profileView = 'main'
        this.profileBlockingOverlayVisible = false
      })
      return true
    }
    const trainDetailCourseCode = this.trainDetailCourseCode ?? ''
    const recordDetailCourseCode = this.recordDetailCourseCode ?? ''
    if (this.currentTab === 1) {
      if (this.trainView !== 'courseList') {
        this.runNestedPageTransition(false, () => {
          this.isTrainScoring = false
          this.trainView = 'courseList'
          this.selectedItemCode = ''
        })
        return true
      }
      if (trainDetailCourseCode.length > 0) {
        this.runNestedPageTransition(false, () => {
          this.trainDetailCourseCode = ''
        })
        return true
      }
    }
    if (this.currentTab === 2 && recordDetailCourseCode.length > 0) {
      this.runNestedPageTransition(false, () => {
        this.recordDetailCourseCode = ''
      })
      return true
    }
    if (this.currentTab !== 0) {
      this.currentTab = 0
      showGlobalToast('再滑一次退出应用。', 'hint')
      return true
    }
    const now = new Date().getTime()
    if (now - this.lastBackPressedAt < this.exitConfirmWindowMs) {
      this.lastBackPressedAt = 0
      return false
    }
    this.lastBackPressedAt = now
    showGlobalToast('再滑一次退出应用。', 'hint')
    return true
  }

  private captureRouteSnapshot(): AppRouteSnapshot {
    const snapshot = new AppRouteSnapshot()
    snapshot.currentTab = this.currentTab
    snapshot.trainView = this.trainView ?? 'courseList'
    snapshot.trainDetailCourseCode = this.trainDetailCourseCode ?? ''
    snapshot.selectedCourseName = this.selectedCourseName ?? ''
    snapshot.selectedPhrase = this.selectedPhrase ?? ''
    snapshot.selectedItemCode = this.selectedItemCode ?? ''
    snapshot.selectedCourseCode = this.selectedCourseCode ?? ''
    snapshot.selectedTrainEntryStage = this.selectedTrainEntryStage ?? 'intro'
    snapshot.selectedCourseIntro = this.selectedCourseIntro ?? ''
    snapshot.selectedCourseCoverUrl = this.selectedCourseCoverUrl ?? ''
    snapshot.currentTrainingType = this.currentTrainingType ?? 'gesture'
    snapshot.recordDetailCourseCode = this.recordDetailCourseCode ?? ''
    snapshot.profileView = this.profileView ?? 'main'
    return snapshot
  }

  private applyRouteSnapshot(snapshot: AppRouteSnapshot) {
    this.currentTab = snapshot.currentTab
    this.trainView = snapshot.trainView ?? 'courseList'
    this.trainDetailCourseCode = snapshot.trainDetailCourseCode ?? ''
    this.selectedCourseName = snapshot.selectedCourseName ?? ''
    this.selectedPhrase = snapshot.selectedPhrase ?? ''
    this.selectedItemCode = snapshot.selectedItemCode ?? ''
    this.selectedCourseCode = snapshot.selectedCourseCode ?? ''
    this.selectedTrainEntryStage = snapshot.selectedTrainEntryStage ?? 'intro'
    this.selectedCourseIntro = snapshot.selectedCourseIntro ?? ''
    this.selectedCourseCoverUrl = snapshot.selectedCourseCoverUrl ?? ''
    this.currentTrainingType = snapshot.currentTrainingType ?? 'gesture'
    this.recordDetailCourseCode = snapshot.recordDetailCourseCode ?? ''
    this.profileView = snapshot.profileView ?? 'main'
  }

  private isTopLevelRoute(snapshot: AppRouteSnapshot): boolean {
    const trainView = snapshot.trainView ?? 'courseList'
    const trainDetailCourseCode = snapshot.trainDetailCourseCode ?? ''
    const recordDetailCourseCode = snapshot.recordDetailCourseCode ?? ''
    const profileView = snapshot.profileView ?? 'main'
    if (snapshot.currentTab === 0) {
      return true
    }
    if (snapshot.currentTab === 1) {
      return trainView === 'courseList' && trainDetailCourseCode.length === 0
    }
    if (snapshot.currentTab === 2) {
      return recordDetailCourseCode.length === 0
    }
    if (snapshot.currentTab === 3) {
      return profileView === 'main'
    }
    return true
  }

  private isCurrentNestedRoute(): boolean {
    return !this.isTopLevelRoute(this.captureRouteSnapshot())
  }

  private isSameRoute(left: AppRouteSnapshot, right: AppRouteSnapshot): boolean {
    return left.currentTab === right.currentTab &&
      left.trainView === right.trainView &&
      left.trainDetailCourseCode === right.trainDetailCourseCode &&
      left.selectedItemCode === right.selectedItemCode &&
      left.selectedCourseCode === right.selectedCourseCode &&
      left.recordDetailCourseCode === right.recordDetailCourseCode &&
      left.profileView === right.profileView
  }

  private pushRouteHistory(snapshot: AppRouteSnapshot) {
    if (this.isTopLevelRoute(snapshot)) {
      return
    }
    const last = this.routeHistory.length > 0 ? this.routeHistory[this.routeHistory.length - 1] : undefined
    if (last && this.isSameRoute(last, snapshot)) {
      return
    }
    this.routeHistory.push(snapshot)
  }

  private navigateToNestedRoute(forward: boolean, action: () => void) {
    this.pushRouteHistory(this.captureRouteSnapshot())
    this.runNestedPageTransition(forward, action)
  }

  private restorePreviousRoute(): boolean {
    if (this.routeHistory.length === 0) {
      return false
    }
    const snapshot = this.routeHistory.pop()
    if (!snapshot) {
      return false
    }
    this.runNestedPageTransition(false, () => {
      this.applyRouteSnapshot(snapshot)
      this.profileBlockingOverlayVisible = false
    })
    return true
  }

  private runNestedPageTransition(forward: boolean, action: () => void) {
    if (this.nestedPageAnimating) {
      action()
      return
    }
    this.nestedPageAnimating = true
    const sourceTab = this.currentTab
    const exitOffset = forward ? -28 : 28
    const enterOffset = forward ? 28 : -28
    animateTo({ duration: 120, curve: Curve.EaseIn }, () => {
      this.nestedPageOffsetX = exitOffset
      this.nestedPageOpacity = 0
    })
    setTimeout(() => {
      action()
      if (sourceTab !== this.currentTab && this.isCurrentNestedRoute()) {
        this.frozenPrimaryTab = sourceTab
      } else {
        this.frozenPrimaryTab = -1
      }
      this.nestedPageOffsetX = enterOffset
      this.nestedPageOpacity = 0
      animateTo({ duration: 220, curve: Curve.EaseOut }, () => {
        this.nestedPageOffsetX = 0
        this.nestedPageOpacity = 1
      })
      setTimeout(() => {
        this.nestedPageAnimating = false
        this.frozenPrimaryTab = -1
      }, 240)
    }, 130)
  }

  private async initializeAuthState() {
    try {
      const token = await readToken(this.getAbilityContext())
      if (token.length > 0) {
        const ok = await this.loadUserInfoAfterAuth(token, true)
        this.isLoggedIn = ok
      } else {
        this.isLoggedIn = false
      }
    } catch (_error) {
      this.isLoggedIn = false
      this.loginTip = '登录状态初始化失败，请重新登录。'
    } finally {
      await this.ensureLaunchMinimumDuration()
      if (!this.splashTuningMode) {
        this.isAuthInitializing = false
      }
    }
  }

  private async ensureLaunchMinimumDuration() {
    const elapsed = new Date().getTime() - this.launchStartedAt
    const remaining = this.launchMinimumDurationMs - elapsed
    if (remaining > 0) {
      await new Promise<void>((resolve) => {
        setTimeout(() => {
          resolve()
        }, remaining)
      })
    }
  }

  private async loadBootstrapConfig() {
    try {
      const result = await getBootstrapConfig(this.smsApiBaseUrl)
      if (!result.ok || !result.data) {
        return
      }
      if (result.data.appSplash) {
        this.splashMediaUrl = result.data.appSplash.mediaUrl
      }
      if (result.data.homeHero) {
        this.homeHeroTitle = result.data.homeHero.title.length > 0 ? result.data.homeHero.title : this.homeHeroTitle
        this.homeHeroSubtitle = result.data.homeHero.subtitle.length > 0 ? result.data.homeHero.subtitle : this.homeHeroSubtitle
        this.homeHeroMediaUrl = result.data.homeHero.mediaUrl
      }
      if (result.data.homeRecommend) {
        this.homeRecommendCourseCode = result.data.homeRecommend.courseCode
        this.homeRecommendCourseName = result.data.homeRecommend.courseName.length > 0 ? result.data.homeRecommend.courseName : this.homeRecommendCourseName
        this.homeRecommendCoverUrl = result.data.homeRecommend.coverUrl
        this.homeRecommendText = result.data.homeRecommend.recommendText.length > 0 ? result.data.homeRecommend.recommendText : this.homeRecommendText
        this.homeRecommendDurationText = result.data.homeRecommend.durationText.length > 0 ? result.data.homeRecommend.durationText : this.homeRecommendDurationText
      }
    } catch (_error) {
    }
  }

  private async loadUserInfoAfterAuth(token: string, forceLogoutOnFailure: boolean = false): Promise<boolean> {
    try {
      const result = await getUserInfo(this.smsApiBaseUrl, token)
      if (!result.ok || !result.data) {
        this.loginTip = result.message.length > 0 ? `获取用户信息失败：${result.message}` : '获取用户信息失败，请重新登录。'
        if (forceLogoutOnFailure) {
          await clearToken(this.getAbilityContext())
        }
        return false
      }

      this.profileNickname = result.data.profile.nickname
      this.profileSignature = result.data.profile.signature
      this.profileCoverUrl = result.data.profile.coverUrl
      this.profileGender = result.data.profile.gender
      this.profileBirthday = result.data.profile.birthday ?? ''
      this.companionDays = result.data.stats.companionDays
      this.trainedQuestionCount = result.data.stats.completedTrainingItemCount
      this.sessionCountedTrainingItemCodes = []
      this.favoriteCourseCodes = result.data.favorites.favoriteCourseCodes ?? []
      this.favoriteCourses = []
      for (let i = 0; i < result.data.favorites.favoriteCourses.length; i += 1) {
        this.favoriteCourses.push(new FavoriteCourseSummary(
          result.data.favorites.favoriteCourses[i].courseCode ?? '',
          result.data.favorites.favoriteCourses[i].courseName,
          result.data.favorites.favoriteCourses[i].trainingType ?? ''
        ))
      }
      this.favoriteTrainingItems = []
      this.favoriteTrainingItemCodes = []
      for (let i = 0; i < result.data.favorites.favoriteTrainingItems.length; i += 1) {
        this.favoriteTrainingItems.push(new FavoriteTrainingItemSummary(
          result.data.favorites.favoriteTrainingItems[i].itemCode,
          result.data.favorites.favoriteTrainingItems[i].itemName,
          '',
          result.data.favorites.favoriteTrainingItems[i].courseName ?? '',
          result.data.favorites.favoriteTrainingItems[i].trainingType ?? ''
        ))
        this.favoriteTrainingItemCodes.push(result.data.favorites.favoriteTrainingItems[i].itemCode)
      }

      if (result.data.profile.avatarUrl.length > 0) {
        this.avatarUrl = result.data.profile.avatarUrl
      }
      await this.preloadPrimaryPagesAfterAuth(token)
      return true
    } catch (_error) {
      this.loginTip = '网络异常，无法连接服务器，请检查网络后重试。'
      if (forceLogoutOnFailure) {
        await clearToken(this.getAbilityContext())
      }
      return false
    }
  }

  private async preloadPrimaryPagesAfterAuth(token: string) {
    const tasks: Promise<void>[] = []
    tasks.push(this.loadRecordOverviewWithToken(token, true))
    tasks.push(this.preloadCourseListData(token, true))
    await Promise.allSettled(tasks)
  }

  private async preloadHomeStatusFromRecord(token: string) {
    try {
      const result = await getRecordOverview(this.smsApiBaseUrl, token)
      if (!result.ok || !result.data) {
        return
      }
      const overallScore = Number(result.data.summary.overallScore ?? this.homeStatusPercent)
      this.homeStatusPercent = Math.max(0, Math.min(100, Math.round(overallScore)))
      this.dailyProgress = this.homeStatusPercent
      this.homeStatusTitle = result.data.summary.summaryTitle.length > 0 ? result.data.summary.summaryTitle : this.homeStatusTitle
      this.homeStatusDetail = result.data.summary.summaryAdvice.length > 0 ? result.data.summary.summaryAdvice : this.homeStatusDetail
    } catch (_error) {
    }
  }

  private handleTrainingItemCompleted(itemCode: string) {
    if (itemCode.length === 0) {
      return
    }
    for (let i = 0; i < this.sessionCountedTrainingItemCodes.length; i += 1) {
      if (this.sessionCountedTrainingItemCodes[i] === itemCode) {
        return
      }
    }
    this.sessionCountedTrainingItemCodes.push(itemCode)
    this.trainedQuestionCount += 1
  }

  private getAbilityContext(): common.BaseContext {
    return this.getUIContext().getHostContext() as common.BaseContext
  }

  private mapRecordTrendPoints(points: RecordTrendPointDto[]): TrendPointItem[] {
    const next: TrendPointItem[] = []
    for (let i = 0; i < points.length; i += 1) {
      next.push(new TrendPointItem(points[i].label, Number(points[i].score ?? 0)))
    }
    return next
  }

  private getTrendPointsByFilter(filter: string): TrendPointItem[] {
    if (filter === '日') {
      return this.recordDayTrendPoints
    }
    if (filter === '总览') {
      return this.recordOverviewTrendPoints
    }
    return this.recordWeekTrendPoints
  }

  private mapTrendGroup(group?: RecordTrendDto): TrendPointItem[] {
    if (!group || !group.points) {
      return []
    }
    return this.mapRecordTrendPoints(group.points)
  }

  private mapRecentTrainingCourses(recentCourses: RecentTrainingCourseItemDto[]): RecentCourseItem[] {
    const next: RecentCourseItem[] = []
    for (let i = 0; i < recentCourses.length; i += 1) {
      next.push(new RecentCourseItem(
        recentCourses[i].courseCode,
        recentCourses[i].courseName,
        recentCourses[i].lastLearnedAt,
        recentCourses[i].coverUrl,
        recentCourses[i].progressPercent
      ))
    }
    return next
  }

  private touchRecentCourse(courseCode: string, courseName: string, coverUrl: string, progressPercent: number) {
    const next: RecentCourseItem[] = []
    next.push(new RecentCourseItem(
      courseCode,
      courseName,
      '刚刚',
      coverUrl,
      Math.max(0, Math.min(100, Math.round(progressPercent)))
    ))
    for (let i = 0; i < this.recentCourses.length; i += 1) {
      if (this.recentCourses[i].courseCode === courseCode) {
        continue
      }
      next.push(this.recentCourses[i])
    }
    this.recentCourses = next
  }

  private async loadRecentCourses(loadMore: boolean = false) {
    if (loadMore) {
      if (this.recentCoursesLoadingMore || !this.recentCoursesHasMore) {
        return
      }
      this.recentCoursesLoadingMore = true
    }
    try {
      const token = await readToken(this.getAbilityContext())
      if (token.length === 0) {
        this.recentCourses = []
        this.recentCoursesHasMore = false
        this.recentCoursesPageNo = 1
        return
      }

      const targetPageNo = loadMore ? this.recentCoursesPageNo + 1 : 1
      const result = await getRecentTrainingCourses(this.smsApiBaseUrl, token, targetPageNo, 5)
      if (!result.ok || !result.data) {
        if (!loadMore) {
          this.recentCourses = []
          this.recentCoursesHasMore = false
          this.recentCoursesPageNo = 1
        }
        return
      }

      const mapped = this.mapRecentTrainingCourses(result.data.list)
      if (loadMore) {
        const next: RecentCourseItem[] = []
        for (let i = 0; i < this.recentCourses.length; i += 1) {
          next.push(this.recentCourses[i])
        }
        for (let i = 0; i < mapped.length; i += 1) {
          next.push(mapped[i])
        }
        this.recentCourses = next
      } else {
        this.recentCourses = mapped
      }
      this.recentCoursesPageNo = Number(result.data.pageNo ?? targetPageNo)
      this.recentCoursesHasMore = this.recentCourses.length < Number(result.data.total ?? this.recentCourses.length)
    } catch (_error) {
      if (!loadMore) {
        this.recentCourses = []
        this.recentCoursesHasMore = false
        this.recentCoursesPageNo = 1
      }
    } finally {
      if (loadMore) {
        this.recentCoursesLoadingMore = false
      }
    }
  }

  private async loadRecordOverview(forceReload: boolean = false) {
    const token = await readToken(this.getAbilityContext())
    if (token.length === 0) {
      this.recordTip = '登录已失效，请重新登录。'
      return
    }
    await this.loadRecordOverviewWithToken(token, forceReload)
  }

  private async loadRecordOverviewWithToken(token: string, forceReload: boolean = false) {
    if (this.recordOverviewLoading) {
      return
    }
    if (this.recordOverviewLoaded && !forceReload) {
      return
    }

    this.recordOverviewLoading = true
    this.recordTip = ''
    this.recentCourses = []
    this.recentCoursesHasMore = true
    this.recentCoursesPageNo = 1
    try {
      const result = await getRecordOverview(this.smsApiBaseUrl, token)
      if (!result.ok || !result.data) {
        this.recordTip = result.message.length > 0 ? result.message : '记录页数据加载失败。'
        return
      }
      const recentCoursesResult = await getRecentTrainingCourses(this.smsApiBaseUrl, token, 1, 5)

      this.recordOverallScore = Number(result.data.summary.overallScore ?? 0)
      this.recordSummaryTitle = result.data.summary.summaryTitle ?? '学习表现已更新'
      this.recordSummaryAdvice = result.data.summary.summaryAdvice ?? '继续保持当前训练节奏。'
      this.homeStatusPercent = Math.max(0, Math.min(100, Math.round(this.recordOverallScore)))
      this.dailyProgress = this.homeStatusPercent
      this.homeStatusTitle = this.recordSummaryTitle
      this.homeStatusDetail = this.recordSummaryAdvice
      this.recordDayTrendPoints = this.mapTrendGroup(result.data.trends?.day)
      this.recordWeekTrendPoints = this.mapTrendGroup(result.data.trends?.week)
      this.recordOverviewTrendPoints = this.mapTrendGroup(result.data.trends?.overview)
      this.recordTrendPoints = this.getTrendPointsByFilter(this.selectedFilter)
      if (recentCoursesResult.ok && recentCoursesResult.data) {
        this.recentCourses = this.mapRecentTrainingCourses(recentCoursesResult.data.list)
        this.recentCoursesPageNo = Number(recentCoursesResult.data.pageNo ?? 1)
        this.recentCoursesHasMore = this.recentCourses.length < Number(recentCoursesResult.data.total ?? this.recentCourses.length)
      } else {
        this.recentCourses = []
        this.recentCoursesHasMore = false
        this.recentCoursesPageNo = 1
      }
      this.recordOverviewLoaded = true
    } catch (_error) {
      this.recordTip = '网络异常，无法加载学习记录。'
    } finally {
      this.recordOverviewLoading = false
    }
  }

  private sanitizePhone(value: string): string {
    return value.replace(/[^0-9]/g, '').slice(0, 11)
  }

  private sanitizeCode(value: string): string {
    return value.replace(/[^0-9]/g, '').slice(0, 6)
  }

  private normalizeCourseTrainingType(value: string): string {
    const raw = value.toLowerCase()
    if (raw === 'voice' || raw === 'speech') {
      return 'speech'
    }
    return 'gesture'
  }

  private mapCourseStatusToNumber(status: string): number {
    const value = status.toLowerCase()
    if (value === 'published' || value === 'enabled' || value === 'online') {
      return 1
    }
    return 0
  }

  private mapCourseTags(tags: string[]): string[] {
    const result: string[] = []
    for (let i = 0; i < tags.length; i += 1) {
      const tag = tags[i].trim()
      if (tag.length > 0) {
        let exists = false
        for (let j = 0; j < result.length; j += 1) {
          if (result[j] === tag) {
            exists = true
            break
          }
        }
        if (!exists) {
          result.push(tag)
        }
      }
    }
    return result
  }

  private mapCourseListDtos(list: CourseListItemDto[]): CourseItem[] {
    const mapped: CourseItem[] = []
    for (let i = 0; i < list.length; i += 1) {
      const dto = list[i]
      const tags = this.mapCourseTags(dto.tags)
      mapped.push(new CourseItem(
        i + 1,
        dto.courseName,
        dto.courseCode,
        dto.coverUrl,
        dto.intro,
        i + 1,
        this.mapCourseStatusToNumber(dto.status),
        this.normalizeCourseTrainingType(dto.trainingType),
        Number(dto.learnCount ?? 0),
        tags.length > 0 ? tags[0] : '',
        tags.length > 1 ? tags[1] : '',
        tags.length > 2 ? tags[2] : ''
      ))
    }
    return mapped
  }

  private mapCourseTagDtos(list: CourseTagDto[]): string[] {
    const tags: string[] = []
    for (let i = 0; i < list.length; i += 1) {
      const name = list[i].name.trim()
      if (name.length > 0) {
        let exists = false
        for (let j = 0; j < tags.length; j += 1) {
          if (tags[j] === name) {
            exists = true
            break
          }
        }
        if (!exists) {
          tags.push(name)
        }
      }
    }
    return tags
  }

  private async preloadCourseListData(token: string, forceReload: boolean = false) {
    if (this.preloadedCourseListReady && !forceReload && this.preloadedCourseListType === this.currentTrainingType) {
      return
    }
    try {
      const trainingType = this.currentTrainingType === 'speech' ? 'voice' : 'gesture'
      const preloadResults = await Promise.all([
        getCourseTagList(this.smsApiBaseUrl, token),
        getCourseList(this.smsApiBaseUrl, token, {
          trainingType,
          sortBy: 'recommended',
          pageNo: 1,
          pageSize: 8
        })
      ])
      const tagResult = preloadResults[0]
      const courseResult = preloadResults[1]

      this.preloadedCourseTags = tagResult.ok && tagResult.data ? this.mapCourseTagDtos(tagResult.data.list) : []
      if (courseResult.ok && courseResult.data) {
        this.preloadedCourseItems = this.mapCourseListDtos(courseResult.data.list)
        this.preloadedCourseTotal = Number(courseResult.data.total ?? this.preloadedCourseItems.length)
        this.preloadedCourseListType = this.currentTrainingType
        this.preloadedCourseListReady = true
        this.trainCourseCachedItems = this.preloadedCourseItems
        this.trainCourseCachedTotal = this.preloadedCourseTotal
        this.trainCourseCachedPageNo = Number(courseResult.data.pageNo ?? 1)
        this.trainCourseCachedType = this.currentTrainingType
        this.trainCourseCachedReady = true
      } else {
        this.preloadedCourseItems = []
        this.preloadedCourseTotal = 0
        this.preloadedCourseListType = this.currentTrainingType
        this.preloadedCourseListReady = true
        this.trainCourseCachedItems = []
        this.trainCourseCachedTotal = 0
        this.trainCourseCachedPageNo = 1
        this.trainCourseCachedType = this.currentTrainingType
        this.trainCourseCachedReady = true
      }
    } catch (_error) {
      this.preloadedCourseTags = []
      this.preloadedCourseItems = []
      this.preloadedCourseTotal = 0
      this.preloadedCourseListType = this.currentTrainingType
      this.preloadedCourseListReady = true
      this.trainCourseCachedItems = []
      this.trainCourseCachedTotal = 0
      this.trainCourseCachedPageNo = 1
      this.trainCourseCachedType = this.currentTrainingType
      this.trainCourseCachedReady = true
    }
  }

  private setLoginErrorTip(message: string) {
    this.loginTip = message
  }

  private clearSessionFieldCaches() {
    clearCourseDetailFieldCache()
    clearTrainingItemDetailFieldCache()
  }

  private getVisiblePrimaryTab(): number {
    return this.frozenPrimaryTab >= 0 ? this.frozenPrimaryTab : this.currentTab
  }

  private isNestedRouteActive(): boolean {
    const trainView = this.trainView ?? 'courseList'
    const trainDetailCourseCode = this.trainDetailCourseCode ?? ''
    const recordDetailCourseCode = this.recordDetailCourseCode ?? ''
    const profileView = this.profileView ?? 'main'
    return (this.currentTab === 1 && trainView === 'detail') ||
      (this.currentTab === 1 && trainDetailCourseCode.length > 0) ||
      (this.currentTab === 2 && recordDetailCourseCode.length > 0) ||
      (this.currentTab === 3 && profileView !== 'main')
  }

  private resetLoginTipByMode() {
    if (this.authScene === 'register') {
      this.loginTip = '填写信息后即可完成注册'
      return
    }
    this.loginTip = this.loginMode === 'password' ? '请输入账号和密码进行登录' : '请输入手机号并获取验证码。'
  }

  private isValidPhone(phone: string): boolean {
    return /^1\d{10}$/.test(phone)
  }

  private isValidAccount(account: string): boolean {
    return /^[A-Za-z0-9_]{4,20}$/.test(account)
  }

  private isValidPassword(password: string): boolean {
    return /^[^\s]{6,20}$/.test(password)
  }

  private validateRequestCode(): boolean {
    if (this.phoneNumber.length === 0) {
      this.setLoginErrorTip('请输入手机号。')
      return false
    }
    if (!this.isValidPhone(this.phoneNumber)) {
      this.setLoginErrorTip('手机号格式不正确，请输入 11 位大陆手机号。')
      return false
    }
    return true
  }

  private validateSmsLogin(): boolean {
    if (!this.validateRequestCode()) {
      return false
    }
    if (this.verificationCode.length === 0) {
      this.setLoginErrorTip('请输入验证码。')
      return false
    }
    if (this.verificationCode.length !== 6) {
      this.setLoginErrorTip('验证码需为 6 位数字。')
      return false
    }
    return true
  }

  private validatePasswordLogin(): boolean {
    const account = this.account.trim()
    if (account.length === 0) {
      this.setLoginErrorTip('请输入账号。')
      return false
    }
    if (!this.isValidAccount(account)) {
      this.setLoginErrorTip('账号需为 4-20 位字母、数字或下划线。')
      return false
    }
    if (this.password.length === 0) {
      this.setLoginErrorTip('请输入密码。')
      return false
    }
    if (!this.isValidPassword(this.password)) {
      this.setLoginErrorTip('密码需为 6-20 位，且不能包含空格。')
      return false
    }
    return true
  }

  private validateRegister(): boolean {
    const account = this.registerAccount.trim()
    const phone = this.registerPhone.trim()
    if (account.length === 0) {
      this.setLoginErrorTip('请输入注册账号。')
      return false
    }
    if (!this.isValidAccount(account)) {
      this.setLoginErrorTip('注册账号需为 4-20 位字母、数字或下划线。')
      return false
    }
    if (this.registerPassword.length === 0) {
      this.setLoginErrorTip('请设置登录密码。')
      return false
    }
    if (!this.isValidPassword(this.registerPassword)) {
      this.setLoginErrorTip('注册密码需为 6-20 位，且不能包含空格。')
      return false
    }
    if (this.registerConfirmPassword.length === 0) {
      this.setLoginErrorTip('请再次输入确认密码。')
      return false
    }
    if (this.registerPassword !== this.registerConfirmPassword) {
      this.setLoginErrorTip('两次输入的密码不一致。')
      return false
    }
    if (phone.length > 0 && !this.isValidPhone(phone)) {
      this.setLoginErrorTip('手机号格式不正确，请输入 11 位大陆手机号。')
      return false
    }
    return true
  }

  private clearCountdownTimer() {
    if (this.countdownTimer !== -1) {
      clearInterval(this.countdownTimer)
      this.countdownTimer = -1
    }
  }

  private startCountdown() {
    this.codeCountdown = 60
    this.clearCountdownTimer()
    this.countdownTimer = setInterval(() => {
      if (this.codeCountdown > 1) {
        this.codeCountdown -= 1
      } else {
        this.codeCountdown = 0
        this.clearCountdownTimer()
      }
    }, 1000)
  }

  private getErrorMessage(code: number, fallbackMessage: string): string {
    const errorMap: Record<number, string> = {
      202: '\u9a8c\u8bc1\u7801\u9519\u8bef',
      204: '数据异常',
      205: '\u8bf7\u8f93\u5165\u6b63\u786e\u7684\u624b\u673a\u53f7',
      206: '验证码已过期，请重新获取',
      207: '\u9a8c\u8bc1\u7801\u53d1\u9001\u5931\u8d25\uff0c\u8bf7\u7a0d\u540e\u91cd\u8bd5',
      210: '请求过于频繁，请稍后再试',
      214: '今日短信次数已达上限',
      216: '\u8d26\u53f7\u5df2\u88ab\u7981\u7528\uff0c\u8bf7\u8054\u7cfb\u7ba1\u7406\u5458'
    }
    return errorMap[code] ?? fallbackMessage
  }

  private async handleRequestCode() {
    if (!this.validateRequestCode()) {
      return
    }
    if (this.isSendingCode || this.codeCountdown > 0) {
      return
    }

    this.isSendingCode = true
    this.loginTip = '正在发送验证码...'

    try {
      const result = await sendSmsCode(this.smsApiBaseUrl, this.phoneNumber)
      this.loginTip = result.ok
        ? '\u9a8c\u8bc1\u7801\u53d1\u9001\u6210\u529f'
        : this.getErrorMessage(result.code, result.message || '\u9a8c\u8bc1\u7801\u53d1\u9001\u5931\u8d25')

      if (result.ok) {
        this.startCountdown()
        showGlobalToast('验证码发送成功。', 'info')
      } else {
        showGlobalToast(this.loginTip, 'error')
      }
    } catch (_error) {
      this.setLoginErrorTip('网络异常，验证码发送失败。')
    } finally {
      this.isSendingCode = false
    }
  }

  private async handleLogin() {
    if (!this.validateSmsLogin()) {
      return
    }
    if (this.isLoggingIn) {
      return
    }

    this.isLoggingIn = true
    this.loginTip = '正在登录...'

    try {
      const result = await smsLogin(this.smsApiBaseUrl, this.phoneNumber, this.verificationCode)
      if (!result.ok || !result.data?.token) {
        this.loginTip = this.getErrorMessage(result.code, result.message || '登录失败')
        showGlobalToast(this.loginTip, 'error')
        return
      }

      await saveToken(this.getAbilityContext(), result.data.token)
      const ok = await this.loadUserInfoAfterAuth(result.data.token, true)
      if (!ok) {
        this.isLoggedIn = false
        return
      }
      this.loginTip = '登录成功'
      showGlobalToast('登录成功。', 'success')
      this.isLoggedIn = true
      this.currentTab = 0
      this.routeHistory = []
      this.clearCountdownTimer()
    } catch (_error) {
      this.setLoginErrorTip('网络异常，登录失败，请稍后重试。')
    } finally {
      this.isLoggingIn = false
    }
  }

  private async handlePasswordLogin() {
    const account = this.account.trim()
    if (!this.validatePasswordLogin()) {
      return
    }
    if (this.isLoggingIn) {
      return
    }

    this.isLoggingIn = true
    this.loginTip = '正在登录...'
    try {
      const result = await passwordLogin(this.smsApiBaseUrl, {
        username: account,
        password: this.password
      })
      if (!result.ok || !result.data?.token) {
        this.loginTip = this.getErrorMessage(result.code, result.message || '登录失败')
        showGlobalToast(this.loginTip, 'error')
        return
      }

      await saveToken(this.getAbilityContext(), result.data.token)
      const ok = await this.loadUserInfoAfterAuth(result.data.token, true)
      if (!ok) {
        this.isLoggedIn = false
        return
      }
      this.loginTip = '登录成功'
      showGlobalToast('登录成功。', 'success')
      this.isLoggedIn = true
      this.currentTab = 0
      this.profileView = 'main'
      this.routeHistory = []
      this.clearCountdownTimer()
    } catch (_error) {
      this.setLoginErrorTip('网络异常，登录失败，请稍后重试。')
    } finally {
      this.isLoggingIn = false
    }
  }

  private async handleRegisterLocal() {
    const account = this.registerAccount.trim()
    const phone = this.registerPhone.trim()
    if (!this.validateRegister()) {
      return
    }

    if (this.isLoggingIn) {
      return
    }

    this.isLoggingIn = true
    this.loginTip = '注册中...'
    try {
      const result = await passwordRegister(this.smsApiBaseUrl, {
        username: account,
        password: this.registerPassword,
        phone: phone.length > 0 ? phone : undefined,
        nickname: account
      })
      if (!result.ok || !result.data?.token) {
        this.loginTip = this.getErrorMessage(result.code, result.message || '注册失败')
        showGlobalToast(this.loginTip, 'error')
        return
      }

      await saveToken(this.getAbilityContext(), result.data.token)
      const ok = await this.loadUserInfoAfterAuth(result.data.token, true)
      if (!ok) {
        this.isLoggedIn = false
        return
      }
      this.loginTip = '注册并登录成功'
      showGlobalToast('注册并登录成功。', 'success')
      this.account = account
      this.password = ''
      this.authScene = 'login'
      this.loginMode = 'password'
      this.isLoggedIn = true
      this.currentTab = 0
      this.profileView = 'main'
      this.routeHistory = []
      this.clearCountdownTimer()
    } catch (_error) {
      this.setLoginErrorTip('网络异常，注册失败，请稍后重试。')
    } finally {
      this.isLoggingIn = false
    }
  }

  private handleSkipLogin() {
    this.loginTip = '已跳过登录（本地调试模式）。'
    this.isLoggedIn = true
    this.currentTab = 0
    this.profileView = 'main'
    this.routeHistory = []
    this.clearCountdownTimer()
    this.codeCountdown = 0
  }

  private isCourseFavorited(courseCode: string): boolean {
    for (let i = 0; i < this.favoriteCourseCodes.length; i += 1) {
      if (this.favoriteCourseCodes[i] === courseCode) {
        return true
      }
    }
    return false
  }

  private isTrainingItemFavorited(itemCode: string): boolean {
    for (let i = 0; i < this.favoriteTrainingItemCodes.length; i += 1) {
      if (this.favoriteTrainingItemCodes[i] === itemCode) {
        return true
      }
    }
    return false
  }

  private setCourseFavoriteState(courseCode: string, favorited: boolean) {
    const next: string[] = []
    let found = false
    for (let i = 0; i < this.favoriteCourseCodes.length; i += 1) {
      if (this.favoriteCourseCodes[i] === courseCode) {
        found = true
        if (!favorited) {
          continue
        }
      }
      next.push(this.favoriteCourseCodes[i])
    }
    if (favorited && !found) {
      next.push(courseCode)
    }
    this.favoriteCourseCodes = next
  }

  private syncCourseFavoriteSummary(courseCode: string, favorited: boolean) {
    const next: FavoriteCourseSummary[] = []
    let found = false
    for (let i = 0; i < this.favoriteCourses.length; i += 1) {
      const item = this.favoriteCourses[i]
      if (item.courseCode === courseCode) {
        found = true
        if (!favorited) {
          continue
        }
      }
      next.push(item)
    }
    if (favorited && !found) {
      next.unshift(new FavoriteCourseSummary(
        courseCode,
        this.getCourseNameByCode(courseCode),
        this.getCourseTrainingTypeByCode(courseCode)
      ))
    }
    this.favoriteCourses = next
  }

  private setTrainingItemFavoriteState(itemCode: string, favorited: boolean) {
    const next: string[] = []
    let found = false
    for (let i = 0; i < this.favoriteTrainingItemCodes.length; i += 1) {
      if (this.favoriteTrainingItemCodes[i] === itemCode) {
        found = true
        if (!favorited) {
          continue
        }
      }
      next.push(this.favoriteTrainingItemCodes[i])
    }
    if (favorited && !found) {
      next.push(itemCode)
    }
    this.favoriteTrainingItemCodes = next
  }

  private getTrainingItemNameByCode(itemCode: string): string {
    if (this.selectedItemCode === itemCode && this.selectedPhrase.length > 0) {
      return this.selectedPhrase
    }
    for (let i = 0; i < this.favoriteTrainingItems.length; i += 1) {
      if (this.favoriteTrainingItems[i].itemCode === itemCode && this.favoriteTrainingItems[i].itemName.length > 0) {
        return this.favoriteTrainingItems[i].itemName
      }
    }
    return itemCode
  }

  private syncTrainingItemFavoriteSummary(itemCode: string, favorited: boolean) {
    const next: FavoriteTrainingItemSummary[] = []
    let found = false
    for (let i = 0; i < this.favoriteTrainingItems.length; i += 1) {
      const item = this.favoriteTrainingItems[i]
      if (item.itemCode === itemCode) {
        found = true
        if (!favorited) {
          continue
        }
      }
      next.push(item)
    }
    if (favorited && !found) {
      const courseCode = this.selectedCourseCode.length > 0 ? this.selectedCourseCode : ''
      next.unshift(new FavoriteTrainingItemSummary(
        itemCode,
        this.getTrainingItemNameByCode(itemCode),
        courseCode,
        this.getCourseNameByCode(courseCode),
        this.currentTrainingType
      ))
    }
    this.favoriteTrainingItems = next
  }

  private async toggleCourseFavorite(courseCode: string) {
    try {
      const token = await readToken(this.getAbilityContext())
      if (token.length === 0) {
        this.loginTip = '登录已失效，请重新登录。'
        return
      }
      const favorited = this.isCourseFavorited(courseCode)
      const result = favorited
        ? await removeCourseFavorite(this.smsApiBaseUrl, token, courseCode)
        : await addCourseFavorite(this.smsApiBaseUrl, token, courseCode)
      if (!result.ok || !result.data?.success) {
        this.loginTip = result.message.length > 0 ? result.message : '课程收藏操作失败。'
        return
      }
      this.setCourseFavoriteState(courseCode, !favorited)
      this.syncCourseFavoriteSummary(courseCode, !favorited)
    } catch (_error) {
      this.loginTip = '网络异常，课程收藏失败。'
    }
  }

  private async toggleTrainingItemFavorite(itemCode: string) {
    try {
      const token = await readToken(this.getAbilityContext())
      if (token.length === 0) {
        this.loginTip = '登录已失效，请重新登录。'
        return
      }
      const favorited = this.isTrainingItemFavorited(itemCode)
      const result = favorited
        ? await removeTrainingItemFavorite(this.smsApiBaseUrl, token, itemCode)
        : await addTrainingItemFavorite(this.smsApiBaseUrl, token, itemCode)
      if (!result.ok || !result.data?.success) {
        this.loginTip = result.message.length > 0 ? result.message : '训练项收藏操作失败。'
        return
      }
      this.setTrainingItemFavoriteState(itemCode, !favorited)
      this.syncTrainingItemFavoriteSummary(itemCode, !favorited)
    } catch (_error) {
      this.loginTip = '网络异常，训练项收藏失败。'
    }
  }

  private getCourseCoverUrl(courseCode: string): string {
    for (let i = 0; i < this.recentCourses.length; i += 1) {
      if (this.recentCourses[i].courseCode === courseCode && this.recentCourses[i].coverUrl.length > 0) {
        return this.recentCourses[i].coverUrl
      }
    }
    if (courseCode === 'COURSE-301') {
      return DEFAULT_TRAINING_COVER_URL
    }
    if (courseCode === 'COURSE-101') {
      return DEFAULT_COURSE_COVER_URL
    }
    return `https://placehold.co/400x240/svg?text=${courseCode}`
  }

  private openCourseDetailFromRecord(courseCode: string) {
    this.selectedCourseCode = courseCode
    this.selectedCourseName = this.getCourseNameByCode(courseCode)
    this.selectedCourseCoverUrl = this.getCourseCoverUrl(courseCode)
    this.selectedCourseIntro = this.getCourseIntroByCode(courseCode)
    this.currentTrainingType = this.getCourseTrainingTypeByCode(courseCode)
    this.recordDetailCourseCode = courseCode
  }

  private getCourseNameByCode(courseCode: string): string {
    for (let i = 0; i < this.recentCourses.length; i += 1) {
      if (this.recentCourses[i].courseCode === courseCode) {
        return this.recentCourses[i].courseName
      }
    }
    if (courseCode === 'COURSE-301') {
      return '声母训练入门'
    }
    if (courseCode === 'COURSE-101') {
      return '\u65e5\u5e38\u95ee\u5019\u5165\u95e8'
    }
    return courseCode
  }

  private getCourseTrainingTypeByCode(courseCode: string): string {
    if (courseCode === 'COURSE-301' || courseCode === 'COURSE-302') {
      return 'speech'
    }
    return 'gesture'
  }

  private getCourseIntroByCode(courseCode: string): string {
    if (courseCode === 'COURSE-301') {
      return '\u672c\u8bfe\u7a0b\u56f4\u7ed5\u58f0\u6bcd\u8bad\u7ec3\u5165\u95e8\uff0c\u63d0\u4f9b\u4ece\u53e3\u578b\u63a7\u5236\u5230\u8ddf\u8bfb\u8f93\u51fa\u7684\u5faa\u5e8f\u8bad\u7ec3\u8def\u5f84\u3002'
    }
    if (courseCode === 'COURSE-101') {
      return '\u7528\u4e8e\u57fa\u7840\u95ee\u5019\u8868\u8fbe\u8bad\u7ec3\uff0c\u5e2e\u52a9\u5efa\u7acb\u65e5\u5e38\u4ea4\u6d41\u7684\u8d77\u6b65\u80fd\u529b\u3002'
    }
    return '\u8bfe\u7a0b\u8be6\u60c5\u5c06\u7531\u540e\u7aef\u63a5\u53e3\u8fd4\u56de\u540e\u52a8\u6001\u6e32\u67d3\u3002'
  }

  @Builder
  private buildApiDebugFloatingButton() {
    Button() {
      SymbolGlyph($r('sys.symbol.info_circle'))
        .fontSize(18)
        .fontColor(['#FFFFFF'])
    }
    .width(50)
    .height(50)
    .backgroundColor('#2E79F4')
    .borderRadius(25)
    .shadow({ radius: 20, color: '#2E79F455', offsetX: 0, offsetY: 8 })
    .stateEffect(false)
    .position({ x: 300, y: 600 })
    .zIndex(20)
    .onClick(() => {
      this.showApiDebugDialog = true
    })
  }

  @Builder
  private buildApiDebugDialog() {
    Stack({ alignContent: Alignment.Center }) {
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('#520A1628')
        .onClick(() => {
          this.showApiDebugDialog = false
        })

      ApiDebugPanel({
        onClose: () => {
          this.showApiDebugDialog = false
        }
      })
      .zIndex(1)
    }
    .width('100%')
    .height('100%')
    .zIndex(30)
  }

  @Builder
  private buildBottomNav() {
    Column() {
      Row() {
        this.buildNavItem(0, '首页', $r('sys.symbol.house'), $r('sys.symbol.house_fill'))
        this.buildNavItem(1, '训练', $r('sys.symbol.fast'), $r('sys.symbol.fast_fill'))
        this.buildNavItem(2, '记录', $r('sys.symbol.square_grid_2x2'), $r('sys.symbol.square_fill_grid_2x2'))
        this.buildNavItem(3, '我的', $r('sys.symbol.person'), $r('sys.symbol.person_fill'))
      }
      .width('100%')
      .padding({ left: 12, right: 12, top: 8, bottom: 4 })

      Blank()
        .height(12)
    }
    .width('100%')
    .backgroundColor('#FFFFFFF2')
    .backgroundBlurStyle(BlurStyle.COMPONENT_ULTRA_THICK)
    .borderRadius({ topLeft: 26, topRight: 26 })
    .shadow({ radius: 24, color: '#15304B1A', offsetX: 0, offsetY: -4 })
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
  }

  @Builder
  private buildNavItem(index: number, label: string, icon: Resource, selectedIcon: Resource) {
    Column({ space: 6 }) {
      Stack({ alignContent: Alignment.Center }) {
        Row() {
        }
        .width(32)
        .height(32)
        .backgroundColor(this.currentTab === index ? '#E7F0FF' : '#F4F7FB')
        .borderRadius(16)

        SymbolGlyph(this.currentTab === index ? selectedIcon : icon)
          .fontSize(18)
          .fontColor(this.currentTab === index ? ['#2E79F4'] : ['#97A7C0'])
          .symbolEffect(new BounceSymbolEffect(EffectScope.WHOLE, EffectDirection.UP), this.currentTab === index)
      }
      .width(32)
      .height(32)

      Text(label)
        .fontSize(11)
        .fontColor(this.currentTab === index ? '#2E79F4' : '#7A8CA7')
    }
    .layoutWeight(1)
    .padding({ top: 2, bottom: 2 })
    .onClick(() => {
      this.routeHistory = []
      this.currentTab = index
      if (index === 1) {
        this.trainView = 'courseList'
      }
      if (index === 2) {
        this.loadRecordOverview(false)
      }
      if (index !== 3) {
        this.profileView = 'main'
      }
    })
  }

  @Builder
  private buildCurrentPage() {
    if (this.currentTab === 0) {
      HomePage({
        dailyProgress: this.dailyProgress,
        todayStatusPercent: this.homeStatusPercent,
        todayStatusTitle: this.homeStatusTitle,
        todayStatusDetail: this.homeStatusDetail,
        recommendCourseName: this.homeRecommendCourseName,
        recommendText: this.homeRecommendText,
        recommendDurationText: this.homeRecommendDurationText,
        recommendCoverUrl: this.homeRecommendCoverUrl,
        avatarUrl: this.avatarUrl,
        heroTitle: this.homeHeroTitle,
        heroSubtitle: this.homeHeroSubtitle,
        heroMediaUrl: this.homeHeroMediaUrl,
        onOpenTodayRecommend: () => {
          const targetCourseCode = this.homeRecommendCourseCode.length > 0 ? this.homeRecommendCourseCode : 'COURSE-101'
          this.selectedCourseCode = targetCourseCode
          this.selectedCourseName = this.homeRecommendCourseName.length > 0 ? this.homeRecommendCourseName : this.getCourseNameByCode(targetCourseCode)
          this.selectedCourseCoverUrl = this.homeRecommendCoverUrl.length > 0 ? this.homeRecommendCoverUrl : this.getCourseCoverUrl(targetCourseCode)
          this.selectedCourseIntro = this.homeRecommendText.length > 0 ? this.homeRecommendText : this.getCourseIntroByCode(targetCourseCode)
          this.currentTrainingType = this.getCourseTrainingTypeByCode(targetCourseCode)
          this.trainView = 'courseList'
          this.currentTab = 1
        },
        onOpenHeroTraining: () => {
          this.selectedCourseCode = 'COURSE-101'
          this.selectedCourseName = '日常问候入门'
          this.currentTrainingType = 'gesture'
          this.trainView = 'courseList'
          this.currentTab = 1
        },
        onOpenGestureCourses: () => {
          this.selectedCourseCode = 'COURSE-101'
          this.selectedCourseName = '\u65e5\u5e38\u95ee\u5019\u5165\u95e8'
          this.currentTrainingType = 'gesture'
          this.trainView = 'courseList'
          this.currentTab = 1
        },
        onOpenSpeechCourses: () => {
          this.selectedCourseCode = 'COURSE-301'
          this.selectedCourseName = '声母训练入门'
          this.currentTrainingType = 'speech'
          this.trainView = 'courseList'
          this.currentTab = 1
        }
      })
    } else if (this.currentTab === 1) {
      if (this.trainView === 'courseList') {
        if ((this.trainDetailCourseCode ?? '').length > 0) {
          CourseDetailPage({
            apiBaseUrl: this.smsApiBaseUrl,
            courseName: this.selectedCourseName,
            courseCode: this.selectedCourseCode,
            courseIntro: this.selectedCourseIntro,
            coverUrl: this.selectedCourseCoverUrl,
            trainingType: this.currentTrainingType,
            courseTag1: '',
            courseTag2: '',
            courseTag3: '',
            isCourseFavorited: this.isCourseFavorited(this.selectedCourseCode),
            onBack: () => {
              if (!this.restorePreviousRoute()) {
                this.runNestedPageTransition(false, () => {
                  this.trainDetailCourseCode = ''
                })
              }
            },
            onToggleFavorite: (courseCode: string) => {
              this.toggleCourseFavorite(courseCode)
            },
            onOpenTrainingItem: (itemCode: string, phrase: string, toResult: boolean) => {
              this.navigateToNestedRoute(true, () => {
                this.selectedItemCode = itemCode
                this.selectedPhrase = phrase
                this.selectedTrainEntryStage = 'intro'
                this.trainView = 'detail'
              })
            }
          })
        } else {
        CourseListPage({
          apiBaseUrl: this.smsApiBaseUrl,
          trainingType: this.currentTrainingType,
          favoriteCourseCodes: this.favoriteCourseCodes,
          initialCourseTags: this.preloadedCourseTags,
          initialCourses: this.trainCourseCachedReady ? this.trainCourseCachedItems : this.preloadedCourseItems,
          initialTotal: this.trainCourseCachedReady ? this.trainCourseCachedTotal : this.preloadedCourseTotal,
          initialPageNo: this.trainCourseCachedReady ? this.trainCourseCachedPageNo : 1,
          initialTrainingType: this.trainCourseCachedReady ? this.trainCourseCachedType : this.preloadedCourseListType,
          initialDataReady: this.trainCourseCachedReady || this.preloadedCourseListReady,
          initialKeyword: this.trainCourseKeyword,
          initialSortType: this.trainCourseSortType,
          initialSelectedTags: this.trainCourseSelectedTags,
          onTrainingTypeChange: (trainingType: string) => {
            this.currentTrainingType = trainingType
          },
          onFilterStateChange: (keyword: string, sortType: string, selectedTags: string[]) => {
            this.trainCourseKeyword = keyword
            this.trainCourseSortType = sortType
            const nextTags: string[] = []
            for (let i = 0; i < selectedTags.length; i += 1) {
              nextTags.push(selectedTags[i])
            }
            this.trainCourseSelectedTags = nextTags
          },
          onCourseCacheChange: (courses: CourseItem[], total: number, pageNo: number, trainingType: string) => {
            const nextCourses: CourseItem[] = []
            for (let i = 0; i < courses.length; i += 1) {
              nextCourses.push(courses[i])
            }
            this.trainCourseCachedItems = nextCourses
            this.trainCourseCachedTotal = total
            this.trainCourseCachedPageNo = pageNo
            this.trainCourseCachedType = trainingType
            this.trainCourseCachedReady = true
          },
          onToggleCourseFavorite: (courseCode: string) => {
            this.toggleCourseFavorite(courseCode)
          },
          onOpenCourse: (courseName: string, courseCode: string, phrase: string, toResult: boolean) => {
            this.navigateToNestedRoute(true, () => {
              this.selectedCourseName = courseName
              this.selectedCourseCode = courseCode
              this.selectedItemCode = ''
              this.selectedPhrase = this.currentTrainingType === 'speech' ? '\u554a' : '\u4f60\u597d'
              this.selectedPhrase = courseCode === 'COURSE-301' ? '\u554a' : this.selectedPhrase
              this.selectedPhrase = phrase
              this.selectedTrainEntryStage = 'intro'
              this.selectedCourseCoverUrl = this.getCourseCoverUrl(courseCode)
              this.selectedCourseIntro = this.getCourseIntroByCode(courseCode)
              this.currentTrainingType = this.getCourseTrainingTypeByCode(courseCode)
              this.trainDetailCourseCode = courseCode
            })
          }
        })
        }
      } else {
        TrainPage({
          apiBaseUrl: this.smsApiBaseUrl,
          courseName: this.selectedCourseName,
          courseCode: this.selectedCourseCode,
          trainingType: this.currentTrainingType,
          selectedPhrase: this.selectedPhrase,
          selectedItemCode: this.selectedItemCode,
          initialStage: this.selectedTrainEntryStage,
          isCourseFavorited: this.isCourseFavorited(this.selectedCourseCode),
          favoriteTrainingItemCodes: this.favoriteTrainingItemCodes,
          onSelectPhrase: (phrase: string) => {
            this.selectedPhrase = phrase
          },
          onToggleCourseFavorite: (courseCode: string) => {
            this.toggleCourseFavorite(courseCode)
          },
          onToggleTrainingItemFavorite: (itemCode: string) => {
            this.toggleTrainingItemFavorite(itemCode)
          },
          onBackToCourseList: () => {
            if (!this.restorePreviousRoute()) {
              this.runNestedPageTransition(false, () => {
                this.isTrainScoring = false
                this.trainView = 'courseList'
                this.trainDetailCourseCode = ''
                this.selectedItemCode = ''
              })
            }
          },
          onCompleteTraining: () => {
            if (this.dailyProgress < 100) {
              this.dailyProgress = Math.min(100, this.dailyProgress + 10)
            }
          },
          onTrainingItemCompleted: (itemCode: string) => {
            this.handleTrainingItemCompleted(itemCode)
          },
          onRecentCourseTouched: (progressPercent: number) => {
            this.touchRecentCourse(
              this.selectedCourseCode,
              this.selectedCourseName,
              this.selectedCourseCoverUrl,
              progressPercent
            )
          },
          onScoringStateChange: (isScoring: boolean) => {
            this.isTrainScoring = isScoring
          }
        })
      }
    } else if (this.currentTab === 2) {
      if ((this.recordDetailCourseCode ?? '').length > 0) {
        CourseDetailPage({
          apiBaseUrl: this.smsApiBaseUrl,
          courseName: this.selectedCourseName,
          courseCode: this.selectedCourseCode,
          courseIntro: this.selectedCourseIntro,
          coverUrl: this.selectedCourseCoverUrl,
          trainingType: this.currentTrainingType,
          courseTag1: '',
          courseTag2: '',
          courseTag3: '',
          isCourseFavorited: this.isCourseFavorited(this.selectedCourseCode),
          onBack: () => {
            if (!this.restorePreviousRoute()) {
              this.runNestedPageTransition(false, () => {
                this.recordDetailCourseCode = ''
              })
            }
          },
          onToggleFavorite: (courseCode: string) => {
            this.toggleCourseFavorite(courseCode)
          },
          onOpenTrainingItem: (itemCode: string, phrase: string, toResult: boolean) => {
            this.navigateToNestedRoute(true, () => {
              this.selectedItemCode = itemCode
              this.selectedPhrase = phrase
              this.selectedTrainEntryStage = 'intro'
              this.trainView = 'detail'
              this.currentTab = 1
            })
          }
        })
      } else {
        RecordPage({
          overallScore: this.recordOverallScore,
          summaryTitle: this.recordSummaryTitle,
          summaryAdvice: this.recordSummaryAdvice,
          selectedFilter: this.selectedFilter,
          trendPoints: this.recordTrendPoints,
          recentCourses: this.recentCourses,
          loading: this.recordOverviewLoading,
          loadingMoreRecentCourses: this.recentCoursesLoadingMore,
          hasMoreRecentCourses: this.recentCoursesHasMore,
          tip: this.recordTip,
          onFilterChange: (filter: string) => {
            this.selectedFilter = filter
            this.recordTrendPoints = this.getTrendPointsByFilter(filter)
          },
          onLoadMoreRecentCourses: () => {
            this.loadRecentCourses(true)
          },
          onOpenRecentCourse: (courseCode: string) => {
            this.navigateToNestedRoute(true, () => {
              this.openCourseDetailFromRecord(courseCode)
            })
          },
          onOpenTraining: () => {
            this.trainView = 'courseList'
            this.currentTab = 1
          }
        })
      }
    } else {
      ProfilePage({
        currentView: this.profileView,
        apiBaseUrl: this.smsApiBaseUrl,
        avatarUrl: $avatarUrl,
        backendNickname: this.profileNickname,
        backendSignature: this.profileSignature,
        backendCoverUrl: this.profileCoverUrl,
        backendGender: this.profileGender,
        backendBirthday: this.profileBirthday,
        backendCompanionDays: this.companionDays,
        backendTrainedQuestionCount: this.trainedQuestionCount,
        selectedGoal: this.selectedGoal,
        selectedTheme: this.selectedTheme,
        notificationsEnabled: this.notificationsEnabled,
        vibrationEnabled: this.vibrationEnabled,
        favoriteCourseCodes: this.favoriteCourseCodes,
        favoriteTrainingItemCodes: this.favoriteTrainingItemCodes,
        favoriteCourses: this.favoriteCourses,
        favoriteTrainingItems: this.favoriteTrainingItems,
        onOpenSettings: () => {
          this.navigateToNestedRoute(true, () => {
            this.profileView = 'settings'
          })
        },
        onOpenHelpUpload: () => {
          this.navigateToNestedRoute(true, () => {
            this.profileView = 'helpUpload'
          })
        },
        onOpenAboutHearBridge: () => {
          this.navigateToNestedRoute(true, () => {
            this.profileView = 'aboutHearBridge'
          })
        },
        onOpenFavorites: () => {
          this.navigateToNestedRoute(true, () => {
            this.profileView = 'favorites'
          })
        },
        onOpenFavoriteCourse: (courseCode: string) => {
          this.navigateToNestedRoute(true, () => {
            this.selectedCourseCode = courseCode
            this.selectedCourseName = this.getCourseNameByCode(courseCode)
            this.selectedCourseCoverUrl = this.getCourseCoverUrl(courseCode)
            this.selectedCourseIntro = this.getCourseIntroByCode(courseCode)
            this.currentTrainingType = this.getCourseTrainingTypeByCode(courseCode)
            this.trainView = 'courseList'
            this.trainDetailCourseCode = courseCode
            this.currentTab = 1
            this.profileView = 'main'
          })
        },
        onOpenFavoriteTrainingItem: (courseCode: string, trainingType: string, itemCode: string, phrase: string) => {
          this.navigateToNestedRoute(true, () => {
            this.selectedCourseCode = courseCode
            this.selectedCourseName = this.getCourseNameByCode(courseCode)
            this.selectedCourseCoverUrl = this.getCourseCoverUrl(courseCode)
            this.selectedCourseIntro = this.getCourseIntroByCode(courseCode)
            this.currentTrainingType = trainingType
            this.selectedItemCode = itemCode
            this.selectedPhrase = phrase
            this.selectedTrainEntryStage = 'intro'
            this.trainView = 'detail'
            this.trainDetailCourseCode = ''
            this.currentTab = 1
            this.profileView = 'main'
          })
        },
        onCloseSettings: () => {
          if (!this.restorePreviousRoute()) {
            this.runNestedPageTransition(false, () => {
              this.profileView = 'main'
            })
          }
        },
        onOpenAccountSecurity: () => {
          this.navigateToNestedRoute(true, () => {
            this.profileView = 'accountSecurity'
          })
        },
        onOpenPasswordSettings: () => {
          this.navigateToNestedRoute(true, () => {
            this.profileView = 'passwordSecurity'
          })
        },
        onOpenAccountProfile: () => {
          this.navigateToNestedRoute(true, () => {
            this.profileView = 'accountProfile'
          })
        },
        onBackToSettings: () => {
          if (!this.restorePreviousRoute()) {
            this.runNestedPageTransition(false, () => {
              this.profileView = 'main'
            })
          }
        },
        onBackToAccountSecurity: () => {
          if (!this.restorePreviousRoute()) {
            this.runNestedPageTransition(false, () => {
              this.profileView = 'accountSecurity'
            })
          }
        },
        onGoalChange: (goal: string) => {
          this.selectedGoal = goal
        },
        onThemeChange: (theme: string) => {
          this.selectedTheme = theme
        },
        onNotificationsChange: (value: boolean) => {
          this.notificationsEnabled = value
        },
        onVibrationChange: (value: boolean) => {
          this.vibrationEnabled = value
        },
        onProfileUpdated: (nickname: string, signature: string, coverUrl: string, gender: number, birthday: string, avatarUrl: string) => {
          this.profileNickname = nickname
          this.profileSignature = signature
          this.profileCoverUrl = coverUrl
          this.profileGender = gender
          this.profileBirthday = birthday
          this.avatarUrl = avatarUrl
        },
        onPasswordUpdatedLogout: () => {
          this.isLoggedIn = false
          this.clearSessionFieldCaches()
          this.currentTab = 0
          this.profileView = 'main'
          this.routeHistory = []
          this.authScene = 'login'
          this.loginMode = 'password'
          this.password = ''
          this.resetLoginTipByMode()
          showGlobalToast('密码已修改，请重新登录。', 'info')
          this.clearCountdownTimer()
          this.codeCountdown = 0
        },
        onLogoutSuccess: () => {
          this.profileBlockingOverlayVisible = false
          this.isLoggedIn = false
          this.clearSessionFieldCaches()
          this.currentTab = 0
          this.profileView = 'main'
          this.routeHistory = []
          this.authScene = 'login'
          this.loginMode = 'password'
          this.password = ''
          this.trainedQuestionCount = 0
          this.sessionCountedTrainingItemCodes = []
          this.resetLoginTipByMode()
          this.clearCountdownTimer()
          this.codeCountdown = 0
        },
        onBlockingOverlayChange: (visible: boolean) => {
          this.profileBlockingOverlayVisible = visible
        }
      })
    }
  }

  @Builder
  private buildHomeRootPage() {
    HomePage({
      dailyProgress: this.dailyProgress,
      todayStatusPercent: this.homeStatusPercent,
      todayStatusTitle: this.homeStatusTitle,
      todayStatusDetail: this.homeStatusDetail,
      recommendCourseName: this.homeRecommendCourseName,
      recommendText: this.homeRecommendText,
      recommendDurationText: this.homeRecommendDurationText,
      recommendCoverUrl: this.homeRecommendCoverUrl,
      avatarUrl: this.avatarUrl,
      heroTitle: this.homeHeroTitle,
      heroSubtitle: this.homeHeroSubtitle,
      heroMediaUrl: this.homeHeroMediaUrl,
      onOpenTodayRecommend: () => {
        const targetCourseCode = this.homeRecommendCourseCode.length > 0 ? this.homeRecommendCourseCode : 'COURSE-101'
        this.selectedCourseCode = targetCourseCode
        this.selectedCourseName = this.homeRecommendCourseName.length > 0 ? this.homeRecommendCourseName : this.getCourseNameByCode(targetCourseCode)
        this.selectedCourseCoverUrl = this.homeRecommendCoverUrl.length > 0 ? this.homeRecommendCoverUrl : this.getCourseCoverUrl(targetCourseCode)
        this.selectedCourseIntro = this.homeRecommendText.length > 0 ? this.homeRecommendText : this.getCourseIntroByCode(targetCourseCode)
        this.currentTrainingType = this.getCourseTrainingTypeByCode(targetCourseCode)
        this.trainView = 'courseList'
        this.currentTab = 1
      },
      onOpenHeroTraining: () => {
        this.selectedCourseCode = 'COURSE-101'
        this.selectedCourseName = '日常问候入门'
        this.currentTrainingType = 'gesture'
        this.trainView = 'courseList'
        this.currentTab = 1
      },
      onOpenGestureCourses: () => {
        this.selectedCourseCode = 'COURSE-101'
        this.selectedCourseName = '日常问候入门'
        this.currentTrainingType = 'gesture'
        this.trainView = 'courseList'
        this.currentTab = 1
      },
      onOpenSpeechCourses: () => {
        this.selectedCourseCode = 'COURSE-301'
        this.selectedCourseName = '声母训练入门'
        this.currentTrainingType = 'speech'
        this.trainView = 'courseList'
        this.currentTab = 1
      }
    })
  }

  @Builder
  private buildTrainRootPage() {
    CourseListPage({
      apiBaseUrl: this.smsApiBaseUrl,
      trainingType: this.currentTrainingType,
      favoriteCourseCodes: this.favoriteCourseCodes,
      initialCourseTags: this.preloadedCourseTags,
      initialCourses: this.trainCourseCachedReady ? this.trainCourseCachedItems : this.preloadedCourseItems,
      initialTotal: this.trainCourseCachedReady ? this.trainCourseCachedTotal : this.preloadedCourseTotal,
      initialPageNo: this.trainCourseCachedReady ? this.trainCourseCachedPageNo : 1,
      initialTrainingType: this.trainCourseCachedReady ? this.trainCourseCachedType : this.preloadedCourseListType,
      initialDataReady: this.trainCourseCachedReady || this.preloadedCourseListReady,
      initialKeyword: this.trainCourseKeyword,
      initialSortType: this.trainCourseSortType,
      initialSelectedTags: this.trainCourseSelectedTags,
      onTrainingTypeChange: (trainingType: string) => {
        this.currentTrainingType = trainingType
      },
      onFilterStateChange: (keyword: string, sortType: string, selectedTags: string[]) => {
        this.trainCourseKeyword = keyword
        this.trainCourseSortType = sortType
        const nextTags: string[] = []
        for (let i = 0; i < selectedTags.length; i += 1) {
          nextTags.push(selectedTags[i])
        }
        this.trainCourseSelectedTags = nextTags
      },
      onCourseCacheChange: (courses: CourseItem[], total: number, pageNo: number, trainingType: string) => {
        const nextCourses: CourseItem[] = []
        for (let i = 0; i < courses.length; i += 1) {
          nextCourses.push(courses[i])
        }
        this.trainCourseCachedItems = nextCourses
        this.trainCourseCachedTotal = total
        this.trainCourseCachedPageNo = pageNo
        this.trainCourseCachedType = trainingType
        this.trainCourseCachedReady = true
      },
      onToggleCourseFavorite: (courseCode: string) => {
        this.toggleCourseFavorite(courseCode)
      },
      onOpenCourse: (courseName: string, courseCode: string, phrase: string, toResult: boolean) => {
        this.navigateToNestedRoute(true, () => {
          this.selectedCourseName = courseName
          this.selectedCourseCode = courseCode
          this.selectedItemCode = ''
          this.selectedPhrase = this.currentTrainingType === 'speech' ? '啊' : '你好'
          this.selectedPhrase = courseCode === 'COURSE-301' ? '啊' : this.selectedPhrase
          this.selectedPhrase = phrase
          this.selectedTrainEntryStage = 'intro'
          this.selectedCourseCoverUrl = this.getCourseCoverUrl(courseCode)
          this.selectedCourseIntro = this.getCourseIntroByCode(courseCode)
          this.currentTrainingType = this.getCourseTrainingTypeByCode(courseCode)
          this.trainDetailCourseCode = courseCode
        })
      }
    })
  }

  @Builder
  private buildRecordRootPage() {
    RecordPage({
      overallScore: this.recordOverallScore,
      summaryTitle: this.recordSummaryTitle,
      summaryAdvice: this.recordSummaryAdvice,
      selectedFilter: this.selectedFilter,
      trendPoints: this.recordTrendPoints,
      recentCourses: this.recentCourses,
      loading: this.recordOverviewLoading,
      loadingMoreRecentCourses: this.recentCoursesLoadingMore,
      hasMoreRecentCourses: this.recentCoursesHasMore,
      tip: this.recordTip,
      onFilterChange: (filter: string) => {
        this.selectedFilter = filter
        this.recordTrendPoints = this.getTrendPointsByFilter(filter)
      },
      onLoadMoreRecentCourses: () => {
        this.loadRecentCourses(true)
      },
      onOpenRecentCourse: (courseCode: string) => {
        this.navigateToNestedRoute(true, () => {
          this.openCourseDetailFromRecord(courseCode)
        })
      },
      onOpenTraining: () => {
        this.trainView = 'courseList'
        this.currentTab = 1
      }
    })
  }

  @Builder
  private buildProfileMainRootPage() {
    ProfilePage({
      currentView: 'main',
      apiBaseUrl: this.smsApiBaseUrl,
      avatarUrl: $avatarUrl,
      backendNickname: this.profileNickname,
      backendSignature: this.profileSignature,
      backendCoverUrl: this.profileCoverUrl,
      backendGender: this.profileGender,
      backendBirthday: this.profileBirthday,
      backendCompanionDays: this.companionDays,
      backendTrainedQuestionCount: this.trainedQuestionCount,
      selectedGoal: this.selectedGoal,
      selectedTheme: this.selectedTheme,
      notificationsEnabled: this.notificationsEnabled,
      vibrationEnabled: this.vibrationEnabled,
      favoriteCourseCodes: this.favoriteCourseCodes,
      favoriteTrainingItemCodes: this.favoriteTrainingItemCodes,
      favoriteCourses: this.favoriteCourses,
      favoriteTrainingItems: this.favoriteTrainingItems,
      onOpenSettings: () => {
        this.navigateToNestedRoute(true, () => {
          this.profileView = 'settings'
        })
      },
      onOpenHelpUpload: () => {
        this.navigateToNestedRoute(true, () => {
          this.profileView = 'helpUpload'
        })
      },
      onOpenAboutHearBridge: () => {
        this.navigateToNestedRoute(true, () => {
          this.profileView = 'aboutHearBridge'
        })
      },
      onOpenFavorites: () => {
        this.navigateToNestedRoute(true, () => {
          this.profileView = 'favorites'
        })
      },
      onOpenFavoriteCourse: (courseCode: string) => {
        this.navigateToNestedRoute(true, () => {
          this.selectedCourseCode = courseCode
          this.selectedCourseName = this.getCourseNameByCode(courseCode)
          this.selectedCourseCoverUrl = this.getCourseCoverUrl(courseCode)
          this.selectedCourseIntro = this.getCourseIntroByCode(courseCode)
          this.currentTrainingType = this.getCourseTrainingTypeByCode(courseCode)
          this.trainView = 'courseList'
          this.trainDetailCourseCode = courseCode
          this.currentTab = 1
          this.profileView = 'main'
        })
      },
      onOpenFavoriteTrainingItem: (courseCode: string, trainingType: string, itemCode: string, phrase: string) => {
        this.navigateToNestedRoute(true, () => {
          this.selectedCourseCode = courseCode
          this.selectedCourseName = this.getCourseNameByCode(courseCode)
          this.selectedCourseCoverUrl = this.getCourseCoverUrl(courseCode)
          this.selectedCourseIntro = this.getCourseIntroByCode(courseCode)
          this.currentTrainingType = trainingType
          this.selectedItemCode = itemCode
          this.selectedPhrase = phrase
          this.selectedTrainEntryStage = 'intro'
          this.trainView = 'detail'
          this.trainDetailCourseCode = ''
          this.currentTab = 1
          this.profileView = 'main'
        })
      },
      onCloseSettings: () => {
        if (!this.restorePreviousRoute()) {
          this.runNestedPageTransition(false, () => {
            this.profileView = 'main'
          })
        }
      },
      onOpenAccountSecurity: () => {
        this.navigateToNestedRoute(true, () => {
          this.profileView = 'accountSecurity'
        })
      },
      onOpenPasswordSettings: () => {
        this.navigateToNestedRoute(true, () => {
          this.profileView = 'passwordSecurity'
        })
      },
      onOpenAccountProfile: () => {
        this.navigateToNestedRoute(true, () => {
          this.profileView = 'accountProfile'
        })
      },
      onBackToSettings: () => {
        if (!this.restorePreviousRoute()) {
          this.runNestedPageTransition(false, () => {
            this.profileView = 'main'
          })
        }
      },
      onBackToAccountSecurity: () => {
        if (!this.restorePreviousRoute()) {
          this.runNestedPageTransition(false, () => {
            this.profileView = 'accountSecurity'
          })
        }
      },
      onGoalChange: (goal: string) => {
        this.selectedGoal = goal
      },
      onThemeChange: (theme: string) => {
        this.selectedTheme = theme
      },
      onNotificationsChange: (value: boolean) => {
        this.notificationsEnabled = value
      },
      onVibrationChange: (value: boolean) => {
        this.vibrationEnabled = value
      },
      onProfileUpdated: (nickname: string, signature: string, coverUrl: string, gender: number, birthday: string, avatarUrl: string) => {
        this.profileNickname = nickname
        this.profileSignature = signature
        this.profileCoverUrl = coverUrl
        this.profileGender = gender
        this.profileBirthday = birthday
        this.avatarUrl = avatarUrl
      },
      onPasswordUpdatedLogout: () => {
        this.isLoggedIn = false
        this.clearSessionFieldCaches()
        this.currentTab = 0
        this.profileView = 'main'
        this.routeHistory = []
        this.authScene = 'login'
        this.loginMode = 'password'
        this.password = ''
        this.resetLoginTipByMode()
        showGlobalToast('密码已修改，请重新登录。', 'info')
        this.clearCountdownTimer()
        this.codeCountdown = 0
      },
      onLogoutSuccess: () => {
        this.profileBlockingOverlayVisible = false
        this.isLoggedIn = false
        this.clearSessionFieldCaches()
        this.currentTab = 0
        this.profileView = 'main'
        this.routeHistory = []
        this.authScene = 'login'
        this.loginMode = 'password'
        this.password = ''
        this.trainedQuestionCount = 0
        this.sessionCountedTrainingItemCodes = []
        this.resetLoginTipByMode()
        this.clearCountdownTimer()
        this.codeCountdown = 0
      },
      onBlockingOverlayChange: (visible: boolean) => {
        this.profileBlockingOverlayVisible = visible
      }
    })
  }

  @Builder
  private buildPersistentTopLevelPages() {
    Stack({ alignContent: Alignment.TopStart }) {
      Scroll() {
        Column() {
          this.buildHomeRootPage()
        }
        .width('100%')
        .justifyContent(FlexAlign.Start)
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')
      .height('100%')
      .scrollBar(BarState.Off)
      .visibility(this.getVisiblePrimaryTab() === 0 ? Visibility.Visible : Visibility.Hidden)

      Column() {
        this.buildTrainRootPage()
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Start)
      .alignItems(HorizontalAlign.Start)
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
      .visibility(this.getVisiblePrimaryTab() === 1 ? Visibility.Visible : Visibility.Hidden)

      Column() {
        this.buildRecordRootPage()
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Start)
      .alignItems(HorizontalAlign.Start)
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
      .visibility(this.getVisiblePrimaryTab() === 2 ? Visibility.Visible : Visibility.Hidden)

      Column() {
        this.buildProfileMainRootPage()
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Start)
      .alignItems(HorizontalAlign.Start)
      .visibility(this.getVisiblePrimaryTab() === 3 ? Visibility.Visible : Visibility.Hidden)
    }
    .width('100%')
    .height('100%')
    .visibility(this.isNestedRouteActive() ? Visibility.Hidden : Visibility.Visible)
  }

  @Builder
  private buildAnimatedCurrentPage() {
    Stack({ alignContent: Alignment.TopStart }) {
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('#F7FAFE')
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])

      Column() {
        this.buildCurrentPage()
      }
      .width('100%')
      .height('100%')
      .translate({ x: this.nestedPageOffsetX, y: 0 })
      .opacity(this.nestedPageOpacity)
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  private buildLaunchLoadingPage() {
    Stack({ alignContent: Alignment.Center }) {
      Stack({ alignContent: Alignment.Top }) {
        Image($r('app.media.loadingcover'))
          .width('100%')
          .height('92%')
          .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])

        Column()
          .width('100%')
          .height('100%')
          .linearGradient({
            angle: 180,
            colors: [['#0A12241A', 0], ['#09152E88', 0.55], ['#08111FDE', 1]]
          })
          .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
      }
      .width('100%')
      .height('100%')
      .clip(false)
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])

      Column({ space: 14 }) {
        LoadingProgress()
          .width(30)
          .height(30)
          .color('#FFFFFF')

        Text('听桥')
          .fontSize(this.splashCnFontSize)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')
          .fontFamily('HarmonyOS Sans')

        Text('HearBridge')
          .fontSize(this.splashEnFontSize)
          .fontWeight(FontWeight.Regular)
          .fontColor('#FFFFFF')
          .letterSpacing(1.4)
          .fontFamily('HarmonyOS Sans')

        Text('口语与手语训练平台')
          .fontSize(this.splashSubFontSize)
          .fontWeight(FontWeight.Regular)
          .fontColor('#E7F0FF')
          .fontFamily('HarmonyOS Sans')
      }
      .width('100%')
      .padding({ left: 32, right: 32, bottom: this.splashTextBottom })
      .alignItems(HorizontalAlign.Center)
      .translate({ x: this.splashTextOffsetX, y: this.splashTextOffsetY })

      Column() {
        Text('— 让表达被听见 —')
          .fontSize(this.splashFooterFontSize)
          .fontWeight(FontWeight.Regular)
          .fontColor('#888888')
          .fontFamily('HarmonyOS Sans')
          .letterSpacing(1.5)
      }
      .width('100%')
      .padding({ left: 32, right: 32, bottom: this.splashFooterBottom })
      .alignItems(HorizontalAlign.Center)
      .translate({
        x: this.splashFooterOffsetX,
        y: this.splashFooterOffsetY
      })
      .position({ left: 0, bottom: 0 })

      if (this.splashTuningMode) {
        Column({ space: 10 }) {
          Text(`scale ${this.splashImageScale}%`)
            .fontSize(12)
            .fontColor('#FFFFFF')
          Row({ space: 8 }) {
            Button('-')
              .onClick(() => {
                this.splashImageScale = this.splashImageScale - 1
              })
            Button('+')
              .onClick(() => {
                this.splashImageScale = this.splashImageScale + 1
              })
          }

          Text(`offsetX ${this.splashOffsetX}`)
            .fontSize(12)
            .fontColor('#FFFFFF')
          Row({ space: 8 }) {
            Button('-')
              .onClick(() => {
                this.splashOffsetX = this.splashOffsetX - 4
              })
            Button('+')
              .onClick(() => {
                this.splashOffsetX = this.splashOffsetX + 4
              })
          }

          Text(`offsetY ${this.splashOffsetY}`)
            .fontSize(12)
            .fontColor('#FFFFFF')
          Row({ space: 8 }) {
            Button('-')
              .onClick(() => {
                this.splashOffsetY = this.splashOffsetY - 4
              })
            Button('+')
              .onClick(() => {
                this.splashOffsetY = this.splashOffsetY + 4
              })
          }

          Text(`textBottom ${this.splashTextBottom}`)
            .fontSize(12)
            .fontColor('#FFFFFF')
          Row({ space: 8 }) {
            Button('-')
              .onClick(() => {
                this.splashTextBottom = this.splashTextBottom - 8
              })
            Button('+')
              .onClick(() => {
                this.splashTextBottom = this.splashTextBottom + 8
              })
          }

          Text(`textOffsetX ${this.splashTextOffsetX}`)
            .fontSize(12)
            .fontColor('#FFFFFF')
          Row({ space: 8 }) {
            Button('-')
              .onClick(() => {
                this.splashTextOffsetX = this.splashTextOffsetX - 4
              })
            Button('+')
              .onClick(() => {
                this.splashTextOffsetX = this.splashTextOffsetX + 4
              })
          }

          Text(`textOffsetY ${this.splashTextOffsetY}`)
            .fontSize(12)
            .fontColor('#FFFFFF')
          Row({ space: 8 }) {
            Button('-')
              .onClick(() => {
                this.splashTextOffsetY = this.splashTextOffsetY - 4
              })
            Button('+')
              .onClick(() => {
                this.splashTextOffsetY = this.splashTextOffsetY + 4
              })
          }

          Text(`cnFont ${this.splashCnFontSize}`)
            .fontSize(12)
            .fontColor('#FFFFFF')
          Row({ space: 8 }) {
            Button('-')
              .onClick(() => {
                this.splashCnFontSize = this.splashCnFontSize - 1
              })
            Button('+')
              .onClick(() => {
                this.splashCnFontSize = this.splashCnFontSize + 1
              })
          }

          Text(`enFont ${this.splashEnFontSize}`)
            .fontSize(12)
            .fontColor('#FFFFFF')
          Row({ space: 8 }) {
            Button('-')
              .onClick(() => {
                this.splashEnFontSize = this.splashEnFontSize - 1
              })
            Button('+')
              .onClick(() => {
                this.splashEnFontSize = this.splashEnFontSize + 1
              })
          }

          Text(`subFont ${this.splashSubFontSize}`)
            .fontSize(12)
            .fontColor('#FFFFFF')
          Row({ space: 8 }) {
            Button('-')
              .onClick(() => {
                this.splashSubFontSize = this.splashSubFontSize - 1
              })
            Button('+')
              .onClick(() => {
                this.splashSubFontSize = this.splashSubFontSize + 1
              })
          }
        }
        .alignItems(HorizontalAlign.Start)
        .padding(12)
        .backgroundColor('#141A2ACC')
        .borderRadius(16)
        .position({ left: 16, bottom: 24 })

        Column({ space: 10 }) {
          Text(`footerFont ${this.splashFooterFontSize}`)
            .fontSize(12)
            .fontColor('#FFFFFF')
          Row({ space: 8 }) {
            Button('-')
              .onClick(() => {
                this.splashFooterFontSize = this.splashFooterFontSize - 1
              })
            Button('+')
              .onClick(() => {
                this.splashFooterFontSize = this.splashFooterFontSize + 1
              })
          }

          Text(`footerBottom ${this.splashFooterBottom}`)
            .fontSize(12)
            .fontColor('#FFFFFF')
          Row({ space: 8 }) {
            Button('-')
              .onClick(() => {
                this.splashFooterBottom = this.splashFooterBottom - 4
              })
            Button('+')
              .onClick(() => {
                this.splashFooterBottom = this.splashFooterBottom + 4
              })
          }

          Text(`footerOffsetX ${this.splashFooterOffsetX}`)
            .fontSize(12)
            .fontColor('#FFFFFF')
          Row({ space: 8 }) {
            Button('-')
              .onClick(() => {
                this.splashFooterOffsetX = this.splashFooterOffsetX - 4
              })
            Button('+')
              .onClick(() => {
                this.splashFooterOffsetX = this.splashFooterOffsetX + 4
              })
          }

          Text(`footerOffsetY ${this.splashFooterOffsetY}`)
            .fontSize(12)
            .fontColor('#FFFFFF')
          Row({ space: 8 }) {
            Button('-')
              .onClick(() => {
                this.splashFooterOffsetY = this.splashFooterOffsetY - 4
              })
            Button('+')
              .onClick(() => {
                this.splashFooterOffsetY = this.splashFooterOffsetY + 4
              })
          }
        }
        .alignItems(HorizontalAlign.Start)
        .padding(12)
        .backgroundColor('#141A2ACC')
        .borderRadius(16)
        .position({ right: 16, top: 300 })
      }
    }
    .width('100%')
    .height('100%')
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      if (this.isAuthInitializing) {
        this.buildLaunchLoadingPage()
      } else if (!this.isLoggedIn) {
        Column() {
          LoginPage({
            authScene: $authScene,
            loginMode: $loginMode,
            phoneNumber: $phoneNumber,
            verificationCode: $verificationCode,
            account: $account,
            password: $password,
            registerAccount: $registerAccount,
            registerPassword: $registerPassword,
            registerConfirmPassword: $registerConfirmPassword,
            registerPhone: $registerPhone,
            loginTip: $loginTip,
            codeCountdown: $codeCountdown,
            isSendingCode: $isSendingCode,
            isLoggingIn: $isLoggingIn,
            apiBaseUrl: this.smsApiBaseUrl,
            onAuthSceneChange: (value: string) => {
              this.authScene = value
              if (value === 'register') {
                this.loginTip = '\u586b\u5199\u4fe1\u606f\u540e\u5373\u53ef\u5b8c\u6210\u6ce8\u518c'
                this.clearCountdownTimer()
                this.codeCountdown = 0
              } else {
                this.loginTip = this.loginMode === 'password' ? '\u8bf7\u8f93\u5165\u8d26\u53f7\u548c\u5bc6\u7801\u8fdb\u884c\u767b\u5f55' : '\u8bf7\u8f93\u5165\u624b\u673a\u53f7\u5e76\u83b7\u53d6\u9a8c\u8bc1\u7801\u3002'
              }
            },
            onLoginModeChange: (value: string) => {
              this.loginMode = value
              this.loginTip = value === 'password' ? '\u8bf7\u8f93\u5165\u8d26\u53f7\u548c\u5bc6\u7801\u8fdb\u884c\u767b\u5f55' : '\u8bf7\u8f93\u5165\u624b\u673a\u53f7\u5e76\u83b7\u53d6\u9a8c\u8bc1\u7801\u3002'
              this.clearCountdownTimer()
              this.codeCountdown = 0
            },
            onPhoneChange: (value: string) => {
              this.phoneNumber = this.sanitizePhone(value)
            },
            onCodeChange: (value: string) => {
              this.verificationCode = this.sanitizeCode(value)
            },
            onAccountChange: (value: string) => {
              this.account = value.trim()
            },
            onPasswordChange: (value: string) => {
              this.password = value
            },
            onRegisterAccountChange: (value: string) => {
              this.registerAccount = value.trim()
            },
            onRegisterPasswordChange: (value: string) => {
              this.registerPassword = value
            },
            onRegisterConfirmPasswordChange: (value: string) => {
              this.registerConfirmPassword = value
            },
            onRegisterPhoneChange: (value: string) => {
              this.registerPhone = this.sanitizePhone(value)
            },
            onRequestCode: () => {
              this.handleRequestCode()
            },
            onLogin: () => {
              this.handleLogin()
            },
            onPasswordLogin: () => {
              this.handlePasswordLogin()
            },
            onRegister: () => {
              this.handleRegisterLocal()
            },
            onSkipLogin: () => {
              this.handleSkipLogin()
            }
          })
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Start)
        .alignItems(HorizontalAlign.Start)
      } else {
        Column() {
          Stack({ alignContent: Alignment.TopStart }) {
            this.buildPersistentTopLevelPages()

            if (this.isNestedRouteActive()) {
              this.buildAnimatedCurrentPage()
            }
          }
          .layoutWeight(1)
          .width('100%')

          if (!this.isNestedRouteActive() && !this.profileBlockingOverlayVisible) {
            this.buildBottomNav()
          }
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Start)
        .alignItems(HorizontalAlign.Start)
        .linearGradient({
          angle: 180,
          colors: [['#F7FAFE', 0], ['#EEF4FB', 1]]
        })
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
      }

      //this.buildApiDebugFloatingButton()

      if (this.showApiDebugDialog) {
        this.buildApiDebugDialog()
      }

      GlobalToast()
    }
    .width('100%')
    .height('100%')
  }
}
