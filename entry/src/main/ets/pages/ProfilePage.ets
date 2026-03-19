import common from '@ohos.app.ability.common'
import { clearToken, readToken } from '../api/AuthStorage'
import { logout, updatePassword, updateUserProfile } from '../api/AuthApi'
import { FavoriteCourseSummary, FavoriteTrainingItemSummary } from '../api/FavoriteApi'
import { uploadFileToServer } from '../api/FileUploadApi'
import photoAccessHelper from '@ohos.file.photoAccessHelper'
import { HelpUploadPage } from './HelpUploadPage'

class FavoriteDisplayItem {
  id: string
  title: string
  subtitle: string
  courseCode: string
  trainingType: string
  phrase: string

  constructor(id: string, title: string, subtitle: string, courseCode: string, trainingType: string, phrase: string) {
    this.id = id
    this.title = title
    this.subtitle = subtitle
    this.courseCode = courseCode
    this.trainingType = trainingType
    this.phrase = phrase
  }
}

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
  @Prop selectedGoal: string = ''
  @Prop selectedTheme: string = ''
  @Prop notificationsEnabled: boolean = true
  @Prop vibrationEnabled: boolean = false
  @Prop favoriteCourseCodes: string[] = []
  @Prop favoriteTrainingItemCodes: string[] = []
  @Prop favoriteCourses: FavoriteCourseSummary[] = []
  @Prop favoriteTrainingItems: FavoriteTrainingItemSummary[] = []

  @State selectedAvatarUrl: string = ''
  @State avatarTip: string = '可选择预设头像或从本地相册选择后上传。'
  @State avatarTipTone: string = 'normal'
  @State isUploadingAvatar: boolean = false
  @State isPickingAvatar: boolean = false
  @State favoriteTab: string = 'course'

  @State profileNickname: string = '桥桥'
  @State profileGender: string = '女'
  @State profileBirthday: string = '2000-01-01'
  @State profileSignature: string = '每天进步一点点。'
  @State companionDays: number = 86
  @State trainedQuestionCount: number = 328
  @State profileCoverUrl: string = 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=1200&q=80'
  @State profileTip: string = '可随时更新账号资料。'
  @State profileTipTone: string = 'normal'
  @State isSavingProfile: boolean = false
  @State isPickingProfileCover: boolean = false
  @State baselineNickname: string = ''
  @State baselineGender: string = ''
  @State baselineBirthday: string = ''
  @State baselineSignature: string = ''
  @State baselineCoverUrl: string = ''
  @State baselineAvatarUrl: string = ''

  @State currentPassword: string = ''
  @State nextPassword: string = ''
  @State confirmPassword: string = ''
  @State passwordTip: string = '密码需至少 8 位，建议包含字母和数字。'
  @State passwordTipTone: string = 'normal'
  @State isUpdatingPassword: boolean = false
  @State logoutTip: string = ''
  @State logoutTipTone: string = 'normal'
  @State isLoggingOut: boolean = false

  onOpenSettings: () => void = () => {}
  onOpenHelpUpload: () => void = () => {}
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

  private readonly avatarOptions: string[] = [
    'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?auto=format&fit=crop&w=400&q=80',
    'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=400&q=80',
    'https://images.unsplash.com/photo-1517841905240-472988babdf9?auto=format&fit=crop&w=400&q=80'
  ]
  private readonly coverOptions: string[] = [
    'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=1200&q=80',
    'https://images.unsplash.com/photo-1493244040629-496f6d136cc3?auto=format&fit=crop&w=1200&q=80',
    'https://images.unsplash.com/photo-1470770841072-f978cf4d019e?auto=format&fit=crop&w=1200&q=80'
  ]

  aboutToAppear() {
    if (this.selectedAvatarUrl.length === 0) {
      this.selectedAvatarUrl = this.avatarUrl
    }
    this.syncProfileFromBackend()
    this.markProfileBaseline()
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
    if (this.backendGender === 1) {
      this.profileGender = '男'
    } else if (this.backendGender === 2) {
      this.profileGender = '女'
    } else {
      this.profileGender = '未设置'
    }
  }

  private markProfileBaseline() {
    this.baselineNickname = this.profileNickname.trim()
    this.baselineGender = this.profileGender
    this.baselineBirthday = this.profileBirthday
    this.baselineSignature = this.profileSignature
    this.baselineCoverUrl = this.profileCoverUrl
    this.baselineAvatarUrl = this.selectedAvatarUrl.length > 0 ? this.selectedAvatarUrl : this.avatarUrl
  }

  private hasProfileChanges(): boolean {
    const currentAvatar = this.selectedAvatarUrl.length > 0 ? this.selectedAvatarUrl : this.avatarUrl
    return this.baselineNickname !== this.profileNickname.trim() ||
      this.baselineGender !== this.profileGender ||
      this.baselineBirthday !== this.profileBirthday ||
      this.baselineSignature !== this.profileSignature ||
      this.baselineCoverUrl !== this.profileCoverUrl ||
      this.baselineAvatarUrl !== currentAvatar
  }

  build() {
    Column() {
      Scroll() {
        Column({ space: 18 }) {
          if (this.currentView === 'accountSecurity') {
            Column() {
              this.buildAccountSecurity()
            }
            .width('100%')
            .padding({ left: 16, right: 16, top: 6 })
          } else if (this.currentView === 'passwordSecurity') {
            Column() {
              this.buildPasswordSecurity()
            }
            .width('100%')
            .padding({ left: 16, right: 16, top: 6 })
          } else if (this.currentView === 'accountProfile') {
            Column() {
              this.buildAccountProfile()
            }
            .width('100%')
            .padding({ left: 16, right: 16, top: 6 })
          } else if (this.currentView === 'favorites') {
            Column() {
              this.buildFavoritesView()
            }
            .width('100%')
            .padding({ left: 16, right: 16, top: 6 })
          } else if (this.currentView === 'helpUpload') {
            HelpUploadPage({
              apiBaseUrl: this.apiBaseUrl,
              onBack: () => {
                this.onBackToSettings()
              }
            })
          } else {
            this.buildProfileOverview()
          }
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
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Start)
    .alignItems(HorizontalAlign.Start)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])
  }

  @Builder
  private buildProfileOverview() {
    Column({ space: 14 }) {
      this.buildProfileCard()
      Column() {
        this.buildMainActions()
      }
      .width('100%')
      .padding({ left: 16, right: 16 })
    }
    .width('100%')
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
      this.buildMenuRow($r('sys.symbol.info_circle'), '关于 HearBridge')
    }
    .width('100%')
  }

  @Builder
  private buildFavoritesView() {
    Column({ space: 14 }) {
      this.buildPageHeader('我的收藏', '课程与训练项收藏', () => {
        this.onBackToSettings()
      })

      Row({ space: 8 }) {
        this.buildFavoritesTab('course', '课程')
        this.buildFavoritesTab('item', '训练项')
      }
      .width('100%')

      Column({ space: 10 }) {
        if (this.favoriteTab === 'course') {
          if (this.getFavoriteCourseItems().length === 0) {
            this.buildFavoriteEmpty('还没有收藏课程')
          } else {
            ForEach(this.getFavoriteCourseItems(), (item: FavoriteDisplayItem) => {
              this.buildFavoriteRow(item, () => {
                this.onOpenFavoriteCourse(item.courseCode)
              })
            }, (item: FavoriteDisplayItem) => item.id)
          }
        } else {
          if (this.getFavoriteTrainingItems().length === 0) {
            this.buildFavoriteEmpty('还没有收藏训练项')
          } else {
            ForEach(this.getFavoriteTrainingItems(), (item: FavoriteDisplayItem) => {
              this.buildFavoriteRow(item, () => {
                this.onOpenFavoriteTrainingItem(item.courseCode, item.trainingType, item.id, item.phrase)
              })
            }, (item: FavoriteDisplayItem) => item.id)
          }
        }
      }
      .width('100%')
    }
    .width('100%')
  }

  @Builder
  private buildAccountProfile() {
    Column({ space: 18 }) {
      this.buildPageHeader('账号资料', '修改头像、昵称、性别、生日和个性签名', () => {
        this.onBackToSettings()
      })

      Column({ space: 14 }) {
        Text('头像')
          .width('100%')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor('#1F2A44')

        Row({ space: 14 }) {
          Image(this.selectedAvatarUrl.length > 0 ? this.selectedAvatarUrl : this.avatarUrl)
            .width(72)
            .height(72)
            .objectFit(ImageFit.Cover)
            .borderRadius(36)

          Column({ space: 6 }) {
            Text('当前头像')
              .fontSize(15)
              .fontWeight(FontWeight.Medium)
              .fontColor('#1F2A44')

            Text(this.avatarTip)
              .fontSize(12)
              .fontColor(this.getTipColor(this.avatarTipTone))
              .maxLines(2)
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)
        }
        .width('100%')

        Row({ space: 12 }) {
          ForEach(this.avatarOptions, (avatar: string) => {
            this.buildAvatarOption(avatar)
          }, (avatar: string) => avatar)
        }
        .width('100%')

        Row({ space: 10 }) {
          Button(this.isPickingAvatar ? '读取中...' : '从相册选择')
            .layoutWeight(1)
            .height(44)
            .fontSize(14)
            .fontColor('#2E79F4')
            .backgroundColor('#F5F8FD')
            .borderRadius(16)
            .enabled(!this.isPickingAvatar)
            .onClick(() => {
              this.openPhotoPicker()
            })

          Button(this.isUploadingAvatar ? '上传中...' : '上传头像')
            .layoutWeight(1)
            .height(44)
            .fontSize(14)
            .fontColor('#2E79F4')
            .backgroundColor('#EEF5FF')
            .borderRadius(16)
            .enabled(!this.isUploadingAvatar)
            .onClick(() => {
              this.handleAvatarUpload()
            })
        }
        .width('100%')
      }
      .width('100%')
      .padding(18)
      .backgroundColor('#FFFFFF')
      .borderRadius(28)
      .shadow({ radius: 18, color: '#15304B10', offsetX: 0, offsetY: 8 })

      Column({ space: 12 }) {
        Text('背景头图')
          .width('100%')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor('#1F2A44')

        Image(this.profileCoverUrl)
          .width('100%')
          .height(118)
          .objectFit(ImageFit.Cover)
          .borderRadius(16)

        Row({ space: 8 }) {
          ForEach(this.coverOptions, (cover: string) => {
            this.buildCoverOption(cover)
          }, (cover: string) => cover)
        }
        .width('100%')

        Button(this.isPickingProfileCover ? '读取中...' : '从相册选择背景')
          .width('100%')
          .height(44)
          .fontSize(14)
          .fontColor('#2E79F4')
          .backgroundColor('#F5F8FD')
          .borderRadius(16)
          .enabled(!this.isPickingProfileCover)
          .onClick(() => {
            this.openCoverPicker()
          })
      }
      .width('100%')
      .padding(18)
      .backgroundColor('#FFFFFF')
      .borderRadius(28)
      .shadow({ radius: 18, color: '#15304B10', offsetX: 0, offsetY: 8 })

      Column({ space: 12 }) {
        this.buildInput('昵称', '请输入昵称', this.profileNickname, (value: string) => {
          this.profileNickname = value
        })

        Column({ space: 8 }) {
          Text('性别')
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor('#1F2A44')

          Row({ space: 10 }) {
            this.buildGenderChip('女')
            this.buildGenderChip('男')
            this.buildGenderChip('保密')
          }
          .width('100%')
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)

        this.buildInput('生日', 'YYYY-MM-DD', this.profileBirthday, (value: string) => {
          this.profileBirthday = value
        })

        Column({ space: 8 }) {
          Text('个性签名')
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor('#1F2A44')

          TextInput({ text: this.profileSignature, placeholder: '说点什么吧…' })
            .width('100%')
            .height(92)
            .fontSize(14)
            .backgroundColor('#F7FAFE')
            .borderRadius(16)
            .padding({ left: 14, right: 14, top: 12, bottom: 12 })
            .onChange((value: string) => {
              this.profileSignature = value
            })
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)

        Text(this.profileTip)
          .width('100%')
          .fontSize(12)
          .fontColor(this.getTipColor(this.profileTipTone))

        Button(this.isSavingProfile ? '保存中...' : (this.hasProfileChanges() ? '保存资料' : '暂无变更'))
          .width('100%')
          .height(46)
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor('#FFFFFF')
          .linearGradient({
            angle: 90,
            colors: [['#5FA7FF', 0], ['#2E79F4', 1]]
          })
          .borderRadius(18)
          .enabled(!this.isSavingProfile && this.hasProfileChanges())
          .onClick(() => {
            this.handleSaveProfile()
          })
      }
      .width('100%')
      .padding(18)
      .backgroundColor('#FFFFFF')
      .borderRadius(28)
      .shadow({ radius: 18, color: '#15304B10', offsetX: 0, offsetY: 8 })
    }
    .width('100%')
  }

  @Builder
  private buildAccountSecurity() {
    Column({ space: 18 }) {
      this.buildPageHeader('账号与安全', '管理登录密码与退出登录', () => {
        this.onBackToSettings()
      })

      Column({ space: 14 }) {
        this.buildMenuRow($r('sys.symbol.lock'), '修改密码', () => {
          this.onOpenPasswordSettings()
        })

        this.buildMenuRow($r('sys.symbol.power'), this.isLoggingOut ? '退出中...' : '退出登录', () => {
          this.handleLogout()
        })

        if (this.logoutTip.length > 0) {
          Text(this.logoutTip)
            .width('100%')
            .fontSize(12)
            .fontColor(this.getTipColor(this.logoutTipTone))
            .lineHeight(18)
        }
      }
      .width('100%')
      .padding(18)
      .backgroundColor('#FFFFFF')
      .borderRadius(28)
      .shadow({ radius: 18, color: '#15304B10', offsetX: 0, offsetY: 8 })
    }
    .width('100%')
  }

  @Builder
  private buildPasswordSecurity() {
    Column({ space: 18 }) {
      this.buildPageHeader('修改密码', '请输入当前密码并设置新密码', () => {
        this.onBackToAccountSecurity()
      })

      Column({ space: 14 }) {
        this.buildInput('当前密码', '请输入当前密码', this.currentPassword, (value: string) => {
          this.currentPassword = value
        })

        this.buildInput('新密码', '请输入新密码', this.nextPassword, (value: string) => {
          this.nextPassword = value
        })

        this.buildInput('确认新密码', '请再次输入新密码', this.confirmPassword, (value: string) => {
          this.confirmPassword = value
        })

        Text(this.passwordTip)
          .width('100%')
          .fontSize(12)
          .fontColor(this.getTipColor(this.passwordTipTone))
          .lineHeight(18)

        Button(this.isUpdatingPassword ? '提交中...' : '确认修改密码')
          .width('100%')
          .height(48)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#FFFFFF')
          .linearGradient({
            angle: 90,
            colors: [['#35C3EE', 0], ['#2E79F4', 1]]
          })
          .borderRadius(20)
          .enabled(!this.isUpdatingPassword)
          .onClick(() => {
            this.handlePasswordChange()
          })
      }
      .width('100%')
      .padding(18)
      .backgroundColor('#FFFFFF')
      .borderRadius(28)
      .shadow({ radius: 18, color: '#15304B10', offsetX: 0, offsetY: 8 })
    }
    .width('100%')
  }

  private handlePasswordChange() {
    if (this.currentPassword.length === 0) {
      this.passwordTip = '请输入当前密码。'
      this.passwordTipTone = 'error'
      return
    }
    if (this.nextPassword.length < 8) {
      this.passwordTip = '新密码长度不能少于 8 位。'
      this.passwordTipTone = 'error'
      return
    }
    if (this.nextPassword !== this.confirmPassword) {
      this.passwordTip = '两次输入的新密码不一致。'
      this.passwordTipTone = 'error'
      return
    }
    this.submitPasswordChange()
  }

  private async handleLogout() {
    if (this.isLoggingOut) {
      return
    }
    this.isLoggingOut = true
    this.logoutTip = '正在退出登录...'
    this.logoutTipTone = 'normal'
    try {
      const token = await readToken(this.getAbilityContext())
      if (token.length > 0) {
        const result = await logout(this.apiBaseUrl, token)
        if (!result.ok) {
          this.logoutTip = result.message.length > 0 ? result.message : '退出登录失败，请稍后重试。'
          this.logoutTipTone = 'error'
          return
        }
      }
      await clearToken(this.getAbilityContext())
      this.logoutTip = '已退出登录。'
      this.logoutTipTone = 'success'
      this.onLogoutSuccess()
    } catch (_error) {
      this.logoutTip = '网络异常，退出登录失败。'
      this.logoutTipTone = 'error'
    } finally {
      this.isLoggingOut = false
    }
  }

  private getAbilityContext(): common.BaseContext {
    return this.getUIContext().getHostContext() as common.BaseContext
  }

  private normalizeUri(uri: string): string {
    return uri.split('#')[0].split('?')[0]
  }

  private getFileName(uri: string, fallbackName: string): string {
    const cleanUri = this.normalizeUri(uri)
    const lastSlash = cleanUri.lastIndexOf('/')
    if (lastSlash >= 0 && lastSlash < cleanUri.length - 1) {
      return cleanUri.substring(lastSlash + 1)
    }
    return fallbackName
  }

  private isRemoteResource(uri: string): boolean {
    return uri.indexOf('http://') === 0 || uri.indexOf('https://') === 0
  }

  private async uploadProfileImageIfNeeded(token: string, fileUri: string, fallbackName: string): Promise<string> {
    if (fileUri.length === 0 || this.isRemoteResource(fileUri)) {
      return fileUri
    }

    const uploadResult = await uploadFileToServer(
      this.getAbilityContext() as common.UIAbilityContext,
      this.apiBaseUrl,
      token,
      fileUri,
      this.getFileName(fileUri, fallbackName),
      'image/jpeg'
    )

    if (!uploadResult.ok || !uploadResult.data) {
      throw new Error(uploadResult.message.length > 0 ? uploadResult.message : '图片上传失败')
    }
    return uploadResult.data
  }

  private resolveGenderCode(): number {
    if (this.profileGender === '男') {
      return 1
    }
    if (this.profileGender === '女') {
      return 2
    }
    return 0
  }

  private async handleSaveProfile() {
    if (this.isSavingProfile) {
      return
    }
    if (!this.hasProfileChanges()) {
      this.profileTip = '当前没有需要保存的变更。'
      this.profileTipTone = 'normal'
      return
    }

    const nickname = this.profileNickname.trim()
    if (nickname.length === 0) {
      this.profileTip = '昵称不能为空。'
      this.profileTipTone = 'error'
      return
    }

    if (nickname.length > 20) {
      this.profileTip = '昵称最多 20 个字符。'
      this.profileTipTone = 'error'
      return
    }

    if (this.profileSignature.length > 200) {
      this.profileTip = '个性签名最多 200 个字符。'
      this.profileTipTone = 'error'
      return
    }

    if (this.profileBirthday.length > 0 && !/^\d{4}-\d{2}-\d{2}$/.test(this.profileBirthday)) {
      this.profileTip = '生日格式需为 YYYY-MM-DD。'
      this.profileTipTone = 'error'
      return
    }

    this.isSavingProfile = true
    this.profileTip = '正在保存资料...'
    this.profileTipTone = 'normal'

    try {
      const token = await readToken(this.getAbilityContext())
      if (token.length === 0) {
        this.profileTip = '登录状态已失效，请重新登录。'
        this.profileTipTone = 'error'
        return
      }

      const localAvatarUrl = this.selectedAvatarUrl.length > 0 ? this.selectedAvatarUrl : this.avatarUrl
      const nextAvatarUrl = await this.uploadProfileImageIfNeeded(token, localAvatarUrl, 'avatar.jpg')
      const nextCoverUrl = await this.uploadProfileImageIfNeeded(token, this.profileCoverUrl, 'cover.jpg')
      this.selectedAvatarUrl = nextAvatarUrl
      this.avatarUrl = nextAvatarUrl
      this.profileCoverUrl = nextCoverUrl
      const result = await updateUserProfile(this.apiBaseUrl, token, {
        nickname,
        gender: this.resolveGenderCode(),
        birthday: this.profileBirthday.length > 0 ? this.profileBirthday : null,
        signature: this.profileSignature,
        avatarUrl: nextAvatarUrl,
        coverUrl: nextCoverUrl
      })
      if (!result.ok || !result.data) {
        result.message = this.resolveProfileUpdateError(result.code, result.message)
      }

      if (!result.ok || !result.data) {
        this.profileTip = result.message.length > 0 ? result.message : '保存失败，请稍后重试。'
        this.profileTipTone = 'error'
        return
      }

      this.profileNickname = result.data.profile.nickname
      this.profileSignature = result.data.profile.signature
      this.profileBirthday = result.data.profile.birthday ?? ''
      this.profileCoverUrl = result.data.profile.coverUrl
      this.avatarUrl = result.data.profile.avatarUrl
      this.selectedAvatarUrl = result.data.profile.avatarUrl
      this.profileGender = result.data.profile.gender === 1 ? '男' : (result.data.profile.gender === 2 ? '女' : '保密')
      this.onProfileUpdated(
        result.data.profile.nickname,
        result.data.profile.signature,
        result.data.profile.coverUrl,
        result.data.profile.gender,
        result.data.profile.birthday ?? '',
        result.data.profile.avatarUrl
      )
      this.markProfileBaseline()
      this.profileTip = '资料已保存。'
      this.profileTipTone = 'success'
    } catch (_error) {
      this.profileTip = '保存失败，请检查网络后重试。'
      this.profileTipTone = 'error'
    } finally {
      this.isSavingProfile = false
    }
  }

  private async submitPasswordChange() {
    if (this.isUpdatingPassword) {
      return
    }
    this.isUpdatingPassword = true
    this.passwordTip = '正在提交密码修改...'
    this.passwordTipTone = 'normal'
    try {
      const token = await readToken(this.getAbilityContext())
      if (token.length === 0) {
        this.passwordTip = '登录状态已失效，请重新登录。'
        this.passwordTipTone = 'error'
        return
      }
      const result = await updatePassword(this.apiBaseUrl, token, {
        oldPassword: this.currentPassword,
        newPassword: this.nextPassword,
        confirmPassword: this.confirmPassword
      })
      if (!result.ok) {
        result.message = this.resolvePasswordUpdateError(result.code, result.message)
      }
      if (!result.ok) {
        this.passwordTip = result.message.length > 0 ? result.message : '密码修改失败，请稍后重试。'
        this.passwordTipTone = 'error'
        return
      }
      await clearToken(this.getAbilityContext())
      this.passwordTip = '密码修改成功，请重新登录。'
      this.passwordTipTone = 'success'
      this.currentPassword = ''
      this.nextPassword = ''
      this.confirmPassword = ''
      this.onPasswordUpdatedLogout()
    } catch (_error) {
      this.passwordTip = '网络异常，密码修改失败。'
      this.passwordTipTone = 'error'
    } finally {
      this.isUpdatingPassword = false
    }
  }

  private async handleAvatarUpload() {
    if (this.isUploadingAvatar) {
      return
    }
    if (this.selectedAvatarUrl.length === 0) {
      this.avatarTip = '请先选择头像。'
      this.avatarTipTone = 'error'
      return
    }
    this.isUploadingAvatar = true
    this.avatarTip = '正在上传头像...'
    this.avatarTipTone = 'normal'
    try {
      if (this.isRemoteResource(this.selectedAvatarUrl)) {
        this.avatarUrl = this.selectedAvatarUrl
        this.avatarTip = '头像已设置，记得保存资料。'
        this.avatarTipTone = 'success'
        return
      }
      const token = await readToken(this.getAbilityContext())
      if (token.length === 0) {
        this.avatarTip = '登录状态已失效，请重新登录。'
        this.avatarTipTone = 'error'
        return
      }
      const uploadedUrl = await this.uploadProfileImageIfNeeded(token, this.selectedAvatarUrl, 'avatar.jpg')
      this.selectedAvatarUrl = uploadedUrl
      this.avatarUrl = uploadedUrl
      this.avatarTip = '头像已设置，记得保存资料。'
      this.avatarTipTone = 'success'
    } catch (error) {
      this.avatarTip = error instanceof Error ? error.message : '头像上传失败，请稍后重试。'
      this.avatarTipTone = 'error'
    } finally {
      this.isUploadingAvatar = false
    }
  }

  private async openPhotoPicker() {
    if (this.isPickingAvatar) {
      return
    }
    this.isPickingAvatar = true
    this.avatarTip = '正在打开本地相册...'
    this.avatarTipTone = 'normal'
    try {
      let photoPicker = new photoAccessHelper.PhotoViewPicker()
      let pickerOptions = new photoAccessHelper.PhotoSelectOptions()
      pickerOptions.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE
      pickerOptions.maxSelectNumber = 1
      const pickerResult = await photoPicker.select(pickerOptions)
      if (pickerResult.photoUris.length > 0) {
        this.selectedAvatarUrl = this.normalizeUri(pickerResult.photoUris[0])
        this.avatarTip = '已选择图片，点击“上传头像”保存。'
        this.avatarTipTone = 'normal'
      } else {
        this.avatarTip = '未选择图片。'
        this.avatarTipTone = 'error'
      }
    } catch (_error) {
      this.avatarTip = '当前环境不支持相册读取，请在真机重试。'
      this.avatarTipTone = 'error'
    } finally {
      this.isPickingAvatar = false
    }
  }

  private async openCoverPicker() {
    if (this.isPickingProfileCover) {
      return
    }
    this.isPickingProfileCover = true
    try {
      let photoPicker = new photoAccessHelper.PhotoViewPicker()
      let pickerOptions = new photoAccessHelper.PhotoSelectOptions()
      pickerOptions.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE
      pickerOptions.maxSelectNumber = 1
      const pickerResult = await photoPicker.select(pickerOptions)
      if (pickerResult.photoUris.length > 0) {
        this.profileCoverUrl = this.normalizeUri(pickerResult.photoUris[0])
        this.profileTip = '背景图已选择，保存资料时会自动上传。'
        this.profileTipTone = 'success'
      }
    } catch (_error) {
      this.profileTip = '当前环境不支持相册读取，请在真机重试。'
      this.profileTipTone = 'error'
    } finally {
      this.isPickingProfileCover = false
    }
  }

  private getTipColor(tone: string): string {
    if (tone === 'error') {
      return '#E5484D'
    }
    if (tone === 'success') {
      return '#2BA471'
    }
    return '#7A8CA7'
  }

  private resolveProfileUpdateError(code: number, message: string): string {
    if (message.length > 0 && message !== '数据异常') {
      return message
    }
    if (code === 204) {
      if (this.profileNickname.trim().length === 0) {
        return '昵称不能为空。'
      }
      if (this.profileNickname.trim().length > 20) {
        return '昵称长度不能超过20个字符。'
      }
      if (this.profileBirthday.length > 0 && !/^\d{4}-\d{2}-\d{2}$/.test(this.profileBirthday)) {
        return '生日格式错误，请使用YYYY-MM-DD。'
      }
      if (this.profileSignature.length > 200) {
        return '个性签名不能超过200个字符。'
      }
      return '资料参数不合法，请检查后重试。'
    }
    if (code === 208) {
      return '登录已过期，请重新登录。'
    }
    if (code === 216) {
      return '账号已被禁用，请联系管理员。'
    }
    if (code === 9999) {
      return '服务器异常，请稍后重试。'
    }
    return message.length > 0 ? message : `保存失败（错误码 ${code}）。`
  }

  private resolvePasswordUpdateError(code: number, message: string): string {
    if (message.length > 0 && message !== '数据异常') {
      return message
    }
    if (code === 201) {
      return '当前密码错误，请重新输入。'
    }
    if (code === 204) {
      if (this.currentPassword.length === 0) {
        return '请输入当前密码。'
      }
      if (this.nextPassword.length < 8) {
        return '新密码至少8位。'
      }
      if (this.nextPassword !== this.confirmPassword) {
        return '两次输入的新密码不一致。'
      }
      if (this.currentPassword === this.nextPassword) {
        return '新密码不能与旧密码相同。'
      }
      return '密码参数不合法，请检查后重试。'
    }
    if (code === 208) {
      return '登录已过期，请重新登录。'
    }
    if (code === 216) {
      return '账号已被禁用，请联系管理员。'
    }
    if (code === 9999) {
      return '服务器异常，请稍后重试。'
    }
    return message.length > 0 ? message : `密码修改失败（错误码 ${code}）。`
  }

  @Builder
  private buildPageHeader(title: string, subtitle: string, onBackAction: () => void) {
    Row({ space: 12 }) {
      Stack({ alignContent: Alignment.Center }) {
        Row()
          .width(34)
          .height(34)
          .backgroundColor('#EEF4FF')
          .borderRadius(17)

        SymbolGlyph($r('sys.symbol.chevron_backward'))
          .fontSize(17)
          .fontColor(['#4C79C9'])
      }
      .width(34)
      .height(34)
      .onClick(() => {
        onBackAction()
      })

      Column({ space: 4 }) {
        Text(title)
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1F2A44')

        Text(subtitle)
          .fontSize(12)
          .fontColor('#7A8CA7')
      }
      .alignItems(HorizontalAlign.Start)

      Blank()
    }
    .width('100%')
    .padding({ top: 6, bottom: 4 })
  }

  @Builder
  private buildFavoritesTab(tab: string, label: string) {
    Text(label)
      .layoutWeight(1)
      .height(36)
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
  private buildFavoriteRow(item: FavoriteDisplayItem, onClickAction: () => void) {
    Row({ space: 12 }) {
      Stack({ alignContent: Alignment.Center }) {
        Row()
          .width(30)
          .height(30)
          .backgroundColor('#EDF4FF')
          .borderRadius(15)
        SymbolGlyph($r('sys.symbol.star_fill'))
          .fontSize(15)
          .fontColor(['#2E79F4'])
      }
      .width(30)
      .height(30)

      Column({ space: 4 }) {
        Text(item.title)
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor('#1F2A44')
          .maxLines(1)
        Text(item.subtitle)
          .fontSize(12)
          .fontColor('#7A8CA7')
          .maxLines(1)
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      SymbolGlyph($r('sys.symbol.chevron_forward'))
        .fontSize(14)
        .fontColor(['#9BAAC0'])
    }
    .width('100%')
    .padding(14)
    .backgroundColor('#FFFFFF')
    .borderRadius(16)
    .shadow({ radius: 12, color: '#15304B0D', offsetX: 0, offsetY: 5 })
    .onClick(() => {
      onClickAction()
    })
  }

  @Builder
  private buildFavoriteEmpty(text: string) {
    Column({ space: 8 }) {
      SymbolGlyph($r('sys.symbol.star'))
        .fontSize(22)
        .fontColor(['#9FB0C8'])
      Text(text)
        .fontSize(13)
        .fontColor('#7F90A8')
    }
    .width('100%')
    .padding({ top: 30, bottom: 30 })
    .alignItems(HorizontalAlign.Center)
  }

  private getFavoriteCourseItems(): FavoriteDisplayItem[] {
    const items: FavoriteDisplayItem[] = []
    if (this.favoriteCourses.length > 0) {
      for (let i = 0; i < this.favoriteCourses.length; i += 1) {
        const course = this.favoriteCourses[i]
        items.push(new FavoriteDisplayItem(
          course.courseCode,
          course.courseName,
          course.courseCode,
          course.courseCode,
          this.getCourseTrainingTypeByCode(course.courseCode),
          ''
        ))
      }
      return items
    }

    for (let i = 0; i < this.favoriteCourseCodes.length; i += 1) {
      const code = this.favoriteCourseCodes[i]
      items.push(new FavoriteDisplayItem(code, this.getCourseNameByCode(code), code, code, this.getCourseTrainingTypeByCode(code), ''))
    }
    return items
  }

  private getFavoriteTrainingItems(): FavoriteDisplayItem[] {
    const items: FavoriteDisplayItem[] = []
    if (this.favoriteTrainingItems.length > 0) {
      for (let i = 0; i < this.favoriteTrainingItems.length; i += 1) {
        const item = this.favoriteTrainingItems[i]
        const courseCode = this.getCourseCodeByTrainingItemCode(item.itemCode)
        const trainingType = this.getTrainingTypeByTrainingItemCode(item.itemCode)
        items.push(new FavoriteDisplayItem(
          item.itemCode,
          item.itemName,
          `${trainingType === 'speech' ? '口语训练' : '手势训练'} · ${this.getCourseNameByCode(courseCode)}`,
          courseCode,
          trainingType,
          item.itemName
        ))
      }
      return items
    }

    for (let i = 0; i < this.favoriteTrainingItemCodes.length; i += 1) {
      const code = this.favoriteTrainingItemCodes[i]
      const courseCode = this.getCourseCodeByTrainingItemCode(code)
      const trainingType = this.getTrainingTypeByTrainingItemCode(code)
      items.push(new FavoriteDisplayItem(
        code,
        this.getTrainingItemNameByCode(code),
        `${trainingType === 'speech' ? '口语训练' : '手势训练'} · ${this.getCourseNameByCode(courseCode)}`,
        courseCode,
        trainingType,
        this.getTrainingItemNameByCode(code)
      ))
    }
    return items
  }

  private getCourseCodeByTrainingItemCode(itemCode: string): string {
    if (itemCode.indexOf('VOI_') === 0 || itemCode.indexOf('VOICE_') === 0) {
      return 'COURSE-301'
    }
    return 'COURSE-101'
  }

  private getTrainingTypeByTrainingItemCode(itemCode: string): string {
    if (itemCode.indexOf('VOI_') === 0 || itemCode.indexOf('VOICE_') === 0) {
      return 'speech'
    }
    return 'gesture'
  }

  private getTrainingItemNameByCode(itemCode: string): string {
    if (itemCode === 'VOI_001') {
      return '你好'
    }
    if (itemCode === 'VOICE_A') {
      return '阿'
    }
    if (itemCode === 'VOICE_FOLLOW_HELLO') {
      return '跟读你好'
    }
    if (itemCode === 'GESTURE_HELLO') {
      return '你好'
    }
    if (itemCode === 'GESTURE_THANKS') {
      return '谢谢'
    }
    return itemCode
  }

  private getCourseNameByCode(courseCode: string): string {
    if (courseCode === 'COURSE-301') {
      return '声母训练入门'
    }
    if (courseCode === 'COURSE-302') {
      return '日常跟读训练'
    }
    if (courseCode === 'COURSE-101') {
      return '日常问候入门'
    }
    if (courseCode === 'COURSE-102') {
      return '基础交流训练'
    }
    return courseCode
  }

  private getCourseTrainingTypeByCode(courseCode: string): string {
    if (courseCode === 'COURSE-301' || courseCode === 'COURSE-302') {
      return 'speech'
    }
    return 'gesture'
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
  private buildCoverOption(cover: string) {
    Image(cover)
      .width(86)
      .height(56)
      .objectFit(ImageFit.Cover)
      .borderRadius(12)
      .border({
        width: this.profileCoverUrl === cover ? 2 : 0,
        color: this.profileCoverUrl === cover ? '#2E79F4' : '#00000000'
      })
      .onClick(() => {
        this.profileCoverUrl = cover
        this.profileTip = '背景头图已切换。'
        this.profileTipTone = 'normal'
      })
  }

  @Builder
  private buildGenderChip(label: string) {
    Text(label)
      .fontSize(13)
      .fontWeight(this.profileGender === label ? FontWeight.Medium : FontWeight.Regular)
      .fontColor(this.profileGender === label ? '#2563EB' : '#607089')
      .padding({ left: 14, right: 14, top: 10, bottom: 10 })
      .backgroundColor(this.profileGender === label ? '#E7F0FF' : '#F5F8FD')
      .borderRadius(16)
      .onClick(() => {
        this.profileGender = label
      })
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

  @Builder
  private buildAvatarOption(avatar: string) {
    Stack({ alignContent: Alignment.BottomEnd }) {
      Image(avatar)
        .width(72)
        .height(72)
        .objectFit(ImageFit.Cover)
        .borderRadius(36)
        .opacity(this.selectedAvatarUrl === avatar ? 1 : 0.72)

      if (this.selectedAvatarUrl === avatar) {
        Stack({ alignContent: Alignment.Center }) {
          Row()
            .width(22)
            .height(22)
            .backgroundColor('#2E79F4')
            .borderRadius(11)

          SymbolGlyph($r('sys.symbol.checkmark'))
            .fontSize(12)
            .fontColor(['#FFFFFF'])
        }
        .width(22)
        .height(22)
      }
    }
    .onClick(() => {
      this.selectedAvatarUrl = avatar
      this.avatarTip = '已选择新头像，点击上传即可保存。'
      this.avatarTipTone = 'normal'
    })
  }

  @Builder
  private buildInput(label: string, placeholder: string, value: string, onChangeAction: (value: string) => void) {
    Column({ space: 8 }) {
      Text(label)
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .fontColor('#1F2A44')

      TextInput({ text: value, placeholder })
        .width('100%')
        .height(50)
        .fontSize(15)
        .backgroundColor('#F7FAFE')
        .borderRadius(18)
        .padding({ left: 16, right: 16 })
        .onChange((input: string) => {
          onChangeAction(input)
        })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }
}
