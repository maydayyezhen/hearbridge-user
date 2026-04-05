import { FavoriteCourseSummary, FavoriteTrainingItemSummary } from '../../api/FavoriteApi'
import { DEFAULT_PROFILE_COVER_URL } from '../../config/AppConfig'
import { PageHeaderBar } from '../components/PageHeaderBar'
import { ProfileAboutHearBridgeRoute } from './routes/ProfileAboutHearBridgeRoute'
import { ProfileAccountProfileRoute } from './routes/ProfileAccountProfileRoute'
import { ProfileAccountSecurityRoute } from './routes/ProfileAccountSecurityRoute'
import { ProfileFavoritesRoute } from './routes/ProfileFavoritesRoute'
import { ProfileHelpFeedbackRoute } from './routes/ProfileHelpFeedbackRoute'
import { ProfilePasswordSecurityRoute } from './routes/ProfilePasswordSecurityRoute'

@Component
export struct ProfilePage {
  @Prop currentView: string = 'main'
  @Prop apiBaseUrl: string = ''
  @Link avatarUrl: string
  @Prop backendNickname: string = ''
  @Prop backendSignature: string = ''
  @Prop backendCoverUrl: string = ''
  @Prop backendGender: number = 0
  @Prop backendBirthday: string = ''
  @Prop backendCompanionDays: number = 0
  @Prop backendTrainedQuestionCount: number = 0
  @Prop selectedGoal: string = ''
  @Prop selectedTheme: string = ''
  @Prop notificationsEnabled: boolean = true
  @Prop vibrationEnabled: boolean = false
  @Prop favoriteCourseCodes: string[] = []
  @Prop favoriteTrainingItemCodes: string[] = []
  @Prop favoriteCourses: FavoriteCourseSummary[] = []
  @Prop favoriteTrainingItems: FavoriteTrainingItemSummary[] = []

  @State profileNickname: string = '听桥用户'
  @State profileGenderCode: number = 0
  @State profileBirthday: string = ''
  @State profileSignature: string = '每天进步一点点。'
  @State companionDays: number = 0
  @State trainedQuestionCount: number = 0
  @State profileCoverUrl: string = DEFAULT_PROFILE_COVER_URL
  @State favoriteTab: string = 'course'

  onOpenSettings: () => void = () => {}
  onOpenHelpUpload: () => void = () => {}
  onOpenAboutHearBridge: () => void = () => {}
  onOpenFavorites: () => void = () => {}
  onOpenAccountSecurity: () => void = () => {}
  onOpenPasswordSettings: () => void = () => {}
  onOpenAccountProfile: () => void = () => {}
  onCloseSettings: () => void = () => {}
  onBackToSettings: () => void = () => {}
  onBackToAccountSecurity: () => void = () => {}
  onOpenFavoriteCourse: (courseCode: string) => void = () => {}
  onOpenFavoriteTrainingItem: (courseCode: string, trainingType: string, itemCode: string, phrase: string) => void = () => {}
  onGoalChange: (goal: string) => void = () => {}
  onThemeChange: (theme: string) => void = () => {}
  onNotificationsChange: (value: boolean) => void = () => {}
  onVibrationChange: (value: boolean) => void = () => {}
  onProfileUpdated: (nickname: string, signature: string, coverUrl: string, gender: number, birthday: string, avatarUrl: string) => void = () => {}
  onPasswordUpdatedLogout: () => void = () => {}
  onLogoutSuccess: () => void = () => {}
  onBlockingOverlayChange: (visible: boolean) => void = () => {}

  aboutToAppear() {
    this.syncProfileFromBackend()
  }

  build() {
    Column() {
      if (this.currentView === 'accountProfile') {
        this.buildRouteScaffold('账号资料', () => {
          this.onBackToSettings()
        })
        Scroll() {
          Column({ space: 0 }) {
            ProfileAccountProfileRoute({
              apiBaseUrl: this.apiBaseUrl,
              avatarUrl: this.avatarUrl,
              backendNickname: this.profileNickname,
              backendSignature: this.profileSignature,
              backendCoverUrl: this.profileCoverUrl,
              backendGender: this.profileGenderCode,
              backendBirthday: this.profileBirthday,
              onProfileUpdated: (nickname: string, signature: string, coverUrl: string, gender: number, birthday: string, avatarUrl: string) => {
                this.profileNickname = nickname
                this.profileSignature = signature
                this.profileCoverUrl = coverUrl
                this.profileGenderCode = gender
                this.profileBirthday = birthday
                this.avatarUrl = avatarUrl
                this.onProfileUpdated(nickname, signature, coverUrl, gender, birthday, avatarUrl)
              }
            })
          }
          .width('100%')
          .padding({ left: 16, right: 16, top: 0, bottom: 20 })
        }
        .width('100%')
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
      } else if (this.currentView === 'favorites') {
        this.buildRouteScaffold('我的收藏', () => {
          this.onBackToSettings()
        })
        Scroll() {
          Column({ space: 0 }) {
            ProfileFavoritesRoute({
              favoriteTab: this.favoriteTab,
              favoriteCourseCodes: this.favoriteCourseCodes,
              favoriteCourses: this.favoriteCourses,
              favoriteTrainingItemCodes: this.favoriteTrainingItemCodes,
              favoriteTrainingItems: this.favoriteTrainingItems,
              onOpenFavoriteCourse: (courseCode: string) => {
                this.onOpenFavoriteCourse(courseCode)
              },
              onOpenFavoriteTrainingItem: (courseCode: string, trainingType: string, itemCode: string, phrase: string) => {
                this.onOpenFavoriteTrainingItem(courseCode, trainingType, itemCode, phrase)
              }
            })
          }
          .width('100%')
          .padding({ left: 16, right: 16, top: 0, bottom: 20 })
        }
        .width('100%')
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
      } else if (this.currentView === 'accountSecurity') {
        this.buildRouteScaffold('账号与安全', () => {
          this.onBackToSettings()
        })
        Scroll() {
          Column({ space: 0 }) {
            ProfileAccountSecurityRoute({
              apiBaseUrl: this.apiBaseUrl,
              onOpenPasswordSettings: () => {
                this.onOpenPasswordSettings()
              },
              onLogoutSuccess: () => {
                this.onLogoutSuccess()
              }
            })
          }
          .width('100%')
          .padding({ left: 16, right: 16, top: 0, bottom: 20 })
        }
        .width('100%')
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
      } else if (this.currentView === 'passwordSecurity') {
        this.buildRouteScaffold('修改密码', () => {
          this.onBackToAccountSecurity()
        })
        Scroll() {
          Column({ space: 0 }) {
            ProfilePasswordSecurityRoute({
              apiBaseUrl: this.apiBaseUrl,
              onPasswordUpdatedLogout: () => {
                this.onPasswordUpdatedLogout()
              }
            })
          }
          .width('100%')
          .padding({ left: 16, right: 16, top: 0, bottom: 20 })
        }
        .width('100%')
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
      } else if (this.currentView === 'helpUpload') {
        this.buildRouteScaffold('帮助与反馈', () => {
          this.onBackToSettings()
        })
        Scroll() {
          Column({ space: 0 }) {
            ProfileHelpFeedbackRoute()
          }
          .width('100%')
          .padding({ left: 16, right: 16, top: 0, bottom: 20 })
        }
        .width('100%')
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
      } else if (this.currentView === 'aboutHearBridge') {
        this.buildRouteScaffold('关于听桥', () => {
          this.onBackToSettings()
        })
        Scroll() {
          Column({ space: 0 }) {
            ProfileAboutHearBridgeRoute()
          }
          .width('100%')
          .padding({ left: 16, right: 16, top: 0, bottom: 20 })
        }
        .width('100%')
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
      } else {
        Scroll() {
          Column({ space: 14 }) {
            this.buildProfileCard()
            Column() {
              this.buildMainActions()
            }
            .width('100%')
            .padding({ left: 16, right: 16 })
          }
          .width('100%')
          .justifyContent(FlexAlign.Start)
          .alignItems(HorizontalAlign.Start)
          .constraintSize({ minHeight: '100%' })
          .padding({ left: 0, right: 0, top: 0, bottom: 24 })
        }
        .width('100%')
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])
      }
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Start)
    .alignItems(HorizontalAlign.Start)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])
  }

  private syncProfileFromBackend() {
    if (this.backendNickname.length > 0) {
      this.profileNickname = this.backendNickname
    }
    if (this.backendSignature.length > 0) {
      this.profileSignature = this.backendSignature
    }
    if (this.backendCoverUrl.length > 0) {
      this.profileCoverUrl = this.backendCoverUrl
    }
    if (this.backendBirthday.length > 0) {
      this.profileBirthday = this.backendBirthday
    }
    if (this.backendCompanionDays >= 0) {
      this.companionDays = this.backendCompanionDays
    }
    if (this.backendTrainedQuestionCount >= 0) {
      this.trainedQuestionCount = this.backendTrainedQuestionCount
    }
    this.profileGenderCode = this.backendGender
  }

  @Builder
  private buildRouteScaffold(title: string, onBackAction: () => void) {
    Column({ space: 0 }) {
      PageHeaderBar({
        title,
        subtitle: '',
        onBack: onBackAction
      })

      if (this.currentView === 'favorites') {
        Row({ space: 8 }) {
          this.buildFavoritesTab('course', '课程')
          this.buildFavoritesTab('item', '训练项')
        }
        .width('100%')
        .padding({ top: 8, bottom: 8 })
      }
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 0 })
    .backgroundColor('#FFFFFF')
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])
  }

  @Builder
  private buildFavoritesTab(tab: string, label: string) {
    Text(label)
      .layoutWeight(1)
      .height(34)
      .textAlign(TextAlign.Center)
      .fontSize(14)
      .fontWeight(this.favoriteTab === tab ? FontWeight.Medium : FontWeight.Regular)
      .fontColor(this.favoriteTab === tab ? '#2E79F4' : '#6F83A2')
      .backgroundColor(this.favoriteTab === tab ? '#EAF2FF' : '#F5F8FD')
      .borderRadius(12)
      .onClick(() => {
        this.favoriteTab = tab
      })
  }

  @Builder
  private buildMainActions() {
    Column({ space: 10 }) {
      this.buildMenuRow($r('sys.symbol.star'), '我的收藏', () => {
        this.onOpenFavorites()
      })
      this.buildMenuRow($r('sys.symbol.person'), '账号资料', () => {
        this.onOpenAccountProfile()
      })
      this.buildMenuRow($r('sys.symbol.lock'), '账号与安全', () => {
        this.onOpenAccountSecurity()
      })
      this.buildMenuRow($r('sys.symbol.questionmark_circle'), '帮助与反馈', () => {
        this.onOpenHelpUpload()
      })
      this.buildMenuRow($r('sys.symbol.info_circle'), '关于听桥', () => {
        this.onOpenAboutHearBridge()
      })
    }
    .width('100%')
  }

  @Builder
  private buildProfileCard() {
    Stack({ alignContent: Alignment.BottomStart }) {
      Image(this.profileCoverUrl)
        .width('100%')
        .height(196)
        .objectFit(ImageFit.Cover)
        .borderRadius(0)

      Column()
        .width('100%')
        .height(112)
        .linearGradient({
          angle: 180,
          colors: [['#00000000', 0], ['#33000000', 1]]
        })
        .alignSelf(ItemAlign.End)
        .borderRadius(0)

      Row({ space: 12 }) {
        Image(this.avatarUrl)
          .width(56)
          .height(56)
          .objectFit(ImageFit.Cover)
          .borderRadius(28)

        Column({ space: 4 }) {
          Text(this.profileNickname)
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFFFFF')

          Text(this.profileSignature)
            .fontSize(13)
            .fontColor('#E8F1FF')
            .maxLines(1)

          Text(`已陪伴 ${this.companionDays} 天 · 练习 ${this.trainedQuestionCount} 题`)
            .fontSize(12)
            .fontColor('#DCEBFF')
            .maxLines(1)
        }
        .alignItems(HorizontalAlign.Start)
      }
      .padding({ left: 16, right: 16, bottom: 16 })
      .width('100%')
    }
    .width('100%')
    .height(196)
    .margin({ left: 0, right: 0, top: -56 })
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])
    .shadow({ radius: 20, color: '#15304B2A', offsetX: 0, offsetY: 10 })
  }

  @Builder
  private buildMenuRow(icon: Resource, label: string, onClickAction?: () => void) {
    Row({ space: 12 }) {
      Stack({ alignContent: Alignment.Center }) {
        Row()
          .width(28)
          .height(28)
          .backgroundColor('#EAF2FF')
          .borderRadius(14)

        SymbolGlyph(icon)
          .fontSize(17)
          .fontColor(['#2E79F4'])
      }
      .width(28)
      .height(28)

      Text(label)
        .fontSize(15)
        .fontColor('#1F2A44')

      Blank()

      SymbolGlyph($r('sys.symbol.chevron_forward'))
        .fontSize(15)
        .fontColor(['#95A7C0'])
    }
    .width('100%')
    .padding(18)
    .backgroundColor('#FFFFFF')
    .borderRadius(22)
    .shadow({ radius: 16, color: '#15304B0D', offsetX: 0, offsetY: 6 })
    .onClick(() => {
      if (onClickAction) {
        onClickAction()
      }
    })
  }
}
