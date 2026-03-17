import common from '@ohos.app.ability.common'
import { clearToken, readToken, saveToken } from '../api/AuthStorage'
import { getUserInfo, passwordLogin, passwordRegister, sendSmsCode, smsLogin } from '../api/AuthApi'
import { CourseDetailPage } from './CourseDetailPage'
import { CourseListPage } from './CourseListPage'
import { HomePage } from './HomePage'
import { LoginPage } from './LoginPage'
import { ProfilePage } from './ProfilePage'
import { RecordPage, RecentCourseItem } from './RecordPage'
import { TrainPage } from './TrainPage'

@Entry
@Component
struct Index {
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
  @State avatarUrl: string = 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?auto=format&fit=crop&w=400&q=80'
  @State profileNickname: string = '新用户'
  @State profileSignature: string = ''
  @State profileCoverUrl: string = ''
  @State profileGender: number = 0
  @State profileBirthday: string = ''
  @State companionDays: number = 0
  @State selectedCourseName: string = '\u65e5\u5e38\u95ee\u5019\u5165\u95e8'
  @State selectedPhrase: string = '你好'
  @State selectedCourseCode: string = 'COURSE-101'
  @State selectedTrainEntryStage: string = 'intro'
  @State selectedCourseIntro: string = '\u7528\u4e8e\u57fa\u7840\u95ee\u5019\u8868\u8fbe\u8bad\u7ec3\u3002'
  @State selectedCourseCoverUrl: string = 'http://192.168.142.128:9001/hearbridge-bucket/20260316/3ad909fc0af94c58a8f2be4ca2fe4cbcChatGPT%20Image%202026%E5%B9%B43%E6%9C%8816%E6%97%A5%2001_25_49.png'
  @State currentTrainingType: string = 'gesture'
  @State trainView: string = 'courseList'
  @State trainDetailCourseCode: string = ''
  @State recordDetailCourseCode: string = ''
  @State selectedFilter: string = '\u5168\u90e8'
  @State selectedGoal: string = '日常交流'
  @State selectedTheme: string = '\u6d77\u76d0\u84dd'
  @State profileView: string = 'main'
  @State notificationsEnabled: boolean = true
  @State vibrationEnabled: boolean = false
  @State isTrainScoring: boolean = false
  @State favoriteCourseCodes: string[] = []
  @State recentCourses: RecentCourseItem[] = [
    new RecentCourseItem('COURSE-301', '声母训练入门', '03-17 22:05', 'http://192.168.142.128:9001/hearbridge-bucket/20260316/smxlrm.png', 68),
    new RecentCourseItem('COURSE-101', '\u65e5\u5e38\u95ee\u5019\u5165\u95e8', '03-17 20:41', 'http://192.168.142.128:9001/hearbridge-bucket/20260316/3ad909fc0af94c58a8f2be4ca2fe4cbcChatGPT%20Image%202026%E5%B9%B43%E6%9C%8816%E6%97%A5%2001_25_49.png', 42)
  ]

  private readonly smsApiBaseUrl: string = 'http://10.133.132.87:8501'
  private countdownTimer: number = -1

  aboutToAppear() {
    this.initializeAuthState()
  }

  aboutToDisappear() {
    this.clearCountdownTimer()
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

      if (result.data.profile.avatarUrl.length > 0) {
        this.avatarUrl = result.data.profile.avatarUrl
      }
      return true
    } catch (_error) {
      this.loginTip = '网络异常，无法连接服务器，请检查网络后重试。'
      if (forceLogoutOnFailure) {
        await clearToken(this.getAbilityContext())
      }
      return false
    }
  }

  private getAbilityContext(): common.BaseContext {
    return this.getUIContext().getHostContext() as common.BaseContext
  }

  private sanitizePhone(value: string): string {
    return value.replace(/[^0-9]/g, '').slice(0, 11)
  }

  private sanitizeCode(value: string): string {
    return value.replace(/[^0-9]/g, '').slice(0, 6)
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
    if (this.phoneNumber.length !== 11) {
      this.loginTip = '\u8bf7\u8f93\u5165\u6b63\u786e\u7684\u624b\u673a\u53f7'
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
      }
    } catch (error) {
      this.loginTip = `验证码发送失败：${JSON.stringify(error)}`
    } finally {
      this.isSendingCode = false
    }
  }

  private async handleLogin() {
    if (this.phoneNumber.length !== 11) {
      this.loginTip = '\u8bf7\u8f93\u5165\u6b63\u786e\u7684\u624b\u673a\u53f7'
      return
    }
    if (this.verificationCode.length === 0) {
      this.loginTip = '请输入验证码'
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
        return
      }

      await saveToken(this.getAbilityContext(), result.data.token)
      const ok = await this.loadUserInfoAfterAuth(result.data.token, true)
      if (!ok) {
        this.isLoggedIn = false
        return
      }
      this.loginTip = '登录成功'
      this.isLoggedIn = true
      this.currentTab = 0
      this.clearCountdownTimer()
    } catch (error) {
      this.loginTip = `\u767b\u5f55\u5931\u8d25\uff1a${JSON.stringify(error)}`
    } finally {
      this.isLoggingIn = false
    }
  }

  private async handlePasswordLogin() {
    const account = this.account.trim()
    if (account.length === 0) {
      this.loginTip = '\u8bf7\u8f93\u5165\u8d26\u53f7'
      return
    }
    if (this.password.length < 6) {
      this.loginTip = '\u5bc6\u7801\u81f3\u5c11 6 \u4f4d'
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
        return
      }

      await saveToken(this.getAbilityContext(), result.data.token)
      const ok = await this.loadUserInfoAfterAuth(result.data.token, true)
      if (!ok) {
        this.isLoggedIn = false
        return
      }
      this.loginTip = '登录成功'
      this.isLoggedIn = true
      this.currentTab = 0
      this.profileView = 'main'
      this.clearCountdownTimer()
    } catch (error) {
      this.loginTip = `\u767b\u5f55\u5931\u8d25\uff1a${JSON.stringify(error)}`
    } finally {
      this.isLoggingIn = false
    }
  }

  private async handleRegisterLocal() {
    const account = this.registerAccount.trim()
    const phone = this.registerPhone.trim()
    if (account.length < 4) {
      this.loginTip = '\u6ce8\u518c\u8d26\u53f7\u81f3\u5c11 4 \u4f4d'
      return
    }
    if (this.registerPassword.length < 6) {
      this.loginTip = '\u6ce8\u518c\u5bc6\u7801\u81f3\u5c11 6 \u4f4d'
      return
    }
    if (this.registerPassword !== this.registerConfirmPassword) {
      this.loginTip = '\u4e24\u6b21\u8f93\u5165\u7684\u5bc6\u7801\u4e0d\u4e00\u81f4'
      return
    }
    if (phone.length > 0 && !/^[0-9]{11}$/.test(phone)) {
      this.loginTip = '手机号格式不正确'
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
        return
      }

      await saveToken(this.getAbilityContext(), result.data.token)
      const ok = await this.loadUserInfoAfterAuth(result.data.token, true)
      if (!ok) {
        this.isLoggedIn = false
        return
      }
      this.loginTip = '注册并登录成功'
      this.account = account
      this.password = ''
      this.authScene = 'login'
      this.loginMode = 'password'
      this.isLoggedIn = true
      this.currentTab = 0
      this.profileView = 'main'
      this.clearCountdownTimer()
    } catch (error) {
      this.loginTip = `注册失败：${JSON.stringify(error)}`
    } finally {
      this.isLoggingIn = false
    }
  }

  private handleSkipLogin() {
    this.loginTip = '已跳过登录（本地调试模式）。'
    this.isLoggedIn = true
    this.currentTab = 0
    this.profileView = 'main'
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

  private toggleCourseFavorite(courseCode: string) {
    const next: string[] = []
    let found = false
    for (let i = 0; i < this.favoriteCourseCodes.length; i += 1) {
      if (this.favoriteCourseCodes[i] === courseCode) {
        found = true
        continue
      }
      next.push(this.favoriteCourseCodes[i])
    }
    if (!found) {
      next.push(courseCode)
    }
    this.favoriteCourseCodes = next
  }

  private formatNow(): string {
    const now = new Date()
    const month = `${now.getMonth() + 1}`.padStart(2, '0')
    const day = `${now.getDate()}`.padStart(2, '0')
    const hour = `${now.getHours()}`.padStart(2, '0')
    const minute = `${now.getMinutes()}`.padStart(2, '0')
    return `${month}-${day} ${hour}:${minute}`
  }

  private getCourseCoverUrl(courseCode: string): string {
    if (courseCode === 'COURSE-301') {
      return 'http://192.168.142.128:9001/hearbridge-bucket/20260316/smxlrm.png'
    }
    if (courseCode === 'COURSE-101') {
      return 'http://192.168.142.128:9001/hearbridge-bucket/20260316/3ad909fc0af94c58a8f2be4ca2fe4cbcChatGPT%20Image%202026%E5%B9%B43%E6%9C%8816%E6%97%A5%2001_25_49.png'
    }
    return `https://placehold.co/400x240/png?text=${courseCode}`
  }

  private getCurrentProgress(courseCode: string): number {
    for (let i = 0; i < this.recentCourses.length; i += 1) {
      if (this.recentCourses[i].courseCode === courseCode) {
        return this.recentCourses[i].progressPercent
      }
    }
    return 15
  }

  private upsertRecentCourse(courseCode: string, courseName: string, progressDelta: number = 0) {
    const nextProgress = Math.min(100, this.getCurrentProgress(courseCode) + progressDelta)
    const next: RecentCourseItem[] = [
      new RecentCourseItem(courseCode, courseName, this.formatNow(), this.getCourseCoverUrl(courseCode), nextProgress)
    ]
    for (let i = 0; i < this.recentCourses.length; i += 1) {
      if (this.recentCourses[i].courseCode !== courseCode) {
        next.push(this.recentCourses[i])
      }
    }
    this.recentCourses = next
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
      this.currentTab = index
      if (index === 1) {
        this.trainView = 'courseList'
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
        avatarUrl: this.avatarUrl,
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
        if (this.trainDetailCourseCode.length > 0) {
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
              this.trainDetailCourseCode = ''
            },
            onToggleFavorite: (courseCode: string) => {
              this.toggleCourseFavorite(courseCode)
            },
            onOpenTrainingItem: (phrase: string, toResult: boolean) => {
              this.selectedPhrase = phrase
              this.selectedTrainEntryStage = toResult ? 'result' : 'intro'
              this.trainView = 'detail'
            }
          })
        } else {
        CourseListPage({
          apiBaseUrl: this.smsApiBaseUrl,
          trainingType: this.currentTrainingType,
          favoriteCourseCodes: this.favoriteCourseCodes,
          onTrainingTypeChange: (trainingType: string) => {
            this.currentTrainingType = trainingType
          },
          onToggleCourseFavorite: (courseCode: string) => {
            this.toggleCourseFavorite(courseCode)
          },
          onOpenCourse: (courseName: string, courseCode: string, phrase: string, toResult: boolean) => {
            this.selectedCourseName = courseName
            this.selectedCourseCode = courseCode
            this.upsertRecentCourse(courseCode, courseName)
            this.selectedPhrase = this.currentTrainingType === 'speech' ? '\u554a' : '\u4f60\u597d'
            this.selectedPhrase = courseCode === 'COURSE-301' ? '\u554a' : this.selectedPhrase
            this.selectedPhrase = phrase
            this.selectedTrainEntryStage = toResult ? 'result' : 'intro'
            this.selectedCourseCoverUrl = this.getCourseCoverUrl(courseCode)
            this.selectedCourseIntro = this.getCourseIntroByCode(courseCode)
            this.currentTrainingType = this.getCourseTrainingTypeByCode(courseCode)
            this.trainDetailCourseCode = courseCode
          }
        })
        }
      } else {
        TrainPage({
          courseName: this.selectedCourseName,
          courseCode: this.selectedCourseCode,
          trainingType: this.currentTrainingType,
          selectedPhrase: this.selectedPhrase,
          initialStage: this.selectedTrainEntryStage,
          isCourseFavorited: this.isCourseFavorited(this.selectedCourseCode),
          onSelectPhrase: (phrase: string) => {
            this.selectedPhrase = phrase
          },
          onToggleCourseFavorite: (courseCode: string) => {
            this.toggleCourseFavorite(courseCode)
          },
          onBackToCourseList: () => {
            this.isTrainScoring = false
            this.trainView = 'courseList'
            this.trainDetailCourseCode = ''
          },
          onCompleteTraining: () => {
            if (this.dailyProgress < 100) {
              this.dailyProgress = Math.min(100, this.dailyProgress + 10)
            }
            this.upsertRecentCourse(this.selectedCourseCode, this.selectedCourseName, 10)
          },
          onScoringStateChange: (isScoring: boolean) => {
            this.isTrainScoring = isScoring
          }
        })
      }
    } else if (this.currentTab === 2) {
      if (this.recordDetailCourseCode.length > 0) {
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
            this.recordDetailCourseCode = ''
          },
          onToggleFavorite: (courseCode: string) => {
            this.toggleCourseFavorite(courseCode)
          },
          onOpenTrainingItem: (phrase: string, toResult: boolean) => {
            this.selectedPhrase = phrase
            this.selectedTrainEntryStage = toResult ? 'result' : 'intro'
            this.trainView = 'detail'
            this.currentTab = 1
          }
        })
      } else {
        RecordPage({
          dailyProgress: this.dailyProgress,
          selectedFilter: this.selectedFilter,
          recentCourses: this.recentCourses,
          onFilterChange: (filter: string) => {
            this.selectedFilter = filter
          },
          onOpenRecentCourse: (courseCode: string) => {
            this.openCourseDetailFromRecord(courseCode)
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
        selectedGoal: this.selectedGoal,
        selectedTheme: this.selectedTheme,
        notificationsEnabled: this.notificationsEnabled,
        vibrationEnabled: this.vibrationEnabled,
        favoriteCourseCodes: this.favoriteCourseCodes,
        onOpenSettings: () => {
          this.profileView = 'settings'
        },
        onOpenFavorites: () => {
          this.profileView = 'favorites'
        },
        onOpenFavoriteCourse: (courseCode: string) => {
          this.selectedCourseCode = courseCode
          this.selectedCourseName = this.getCourseNameByCode(courseCode)
          this.selectedCourseCoverUrl = this.getCourseCoverUrl(courseCode)
          this.selectedCourseIntro = this.getCourseIntroByCode(courseCode)
          this.currentTrainingType = this.getCourseTrainingTypeByCode(courseCode)
          this.trainView = 'courseList'
          this.trainDetailCourseCode = courseCode
          this.currentTab = 1
          this.profileView = 'main'
        },
        onOpenFavoriteTrainingItem: (courseCode: string, trainingType: string, phrase: string) => {
          this.selectedCourseCode = courseCode
          this.selectedCourseName = this.getCourseNameByCode(courseCode)
          this.selectedCourseCoverUrl = this.getCourseCoverUrl(courseCode)
          this.selectedCourseIntro = this.getCourseIntroByCode(courseCode)
          this.currentTrainingType = trainingType
          this.selectedPhrase = phrase
          this.selectedTrainEntryStage = 'intro'
          this.trainView = 'detail'
          this.trainDetailCourseCode = ''
          this.currentTab = 1
          this.profileView = 'main'
        },
        onCloseSettings: () => {
          this.profileView = 'main'
        },
        onOpenAccountSecurity: () => {
          this.profileView = 'accountSecurity'
        },
        onOpenAccountProfile: () => {
          this.profileView = 'accountProfile'
        },
        onBackToSettings: () => {
          this.profileView = 'main'
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
          this.currentTab = 0
          this.profileView = 'main'
          this.authScene = 'login'
          this.loginMode = 'password'
          this.password = ''
          this.loginTip = '密码已修改，请重新登录。'
          this.clearCountdownTimer()
          this.codeCountdown = 0
        }
      })
    }
  }

  build() {
    if (!this.isLoggedIn) {
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
    } else {
      Stack({ alignContent: Alignment.Top }) {
        Column() {

          if (this.currentTab === 1) {
            Column() {
              this.buildCurrentPage()
            }
            .width('100%')
            .layoutWeight(1)
            .justifyContent(FlexAlign.Start)
            .alignItems(HorizontalAlign.Start)
            .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
          } else if (this.currentTab === 2 && this.recordDetailCourseCode.length > 0) {
            Column() {
              this.buildCurrentPage()
            }
            .width('100%')
            .layoutWeight(1)
            .justifyContent(FlexAlign.Start)
            .alignItems(HorizontalAlign.Start)
            .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
          } else if (this.currentTab === 3) {
            Column() {
              this.buildCurrentPage()
            }
            .width('100%')
            .layoutWeight(1)
            .justifyContent(FlexAlign.Start)
            .alignItems(HorizontalAlign.Start)
          } else {
            Scroll() {
              Column() {
                this.buildCurrentPage()
              }
              .width('100%')
              .justifyContent(FlexAlign.Start)
              .alignItems(HorizontalAlign.Start)
            }
            .layoutWeight(1)
            .scrollBar(BarState.Off)
          }

          if (!(this.currentTab === 1 && this.trainView === 'detail') &&
            !(this.currentTab === 1 && this.trainDetailCourseCode.length > 0) &&
            !(this.currentTab === 2 && this.recordDetailCourseCode.length > 0)) {
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
      .width('100%')
      .height('100%')
    }
  }
}

