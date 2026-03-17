import common from '@ohos.app.ability.common'
import { readToken, saveToken } from '../api/AuthStorage'
import { sendSmsCode, smsLogin } from '../api/AuthApi'
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
  @State phoneNumber: string = ''
  @State verificationCode: string = ''
  @State loginTip: string = '请输入手机号并获取验证码。'
  @State codeCountdown: number = 0
  @State isSendingCode: boolean = false
  @State isLoggingIn: boolean = false
  @State dailyProgress: number = 40
  @State avatarUrl: string = 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?auto=format&fit=crop&w=400&q=80'
  @State selectedCourseName: string = '日常问候入门'
  @State selectedPhrase: string = '你好'
  @State selectedCourseCode: string = 'COURSE-101'
  @State selectedTrainEntryStage: string = 'intro'
  @State selectedCourseIntro: string = '用于基础问候表达训练。'
  @State selectedCourseCoverUrl: string = 'http://192.168.142.128:9001/hearbridge-bucket/20260316/3ad909fc0af94c58a8f2be4ca2fe4cbcChatGPT%20Image%202026%E5%B9%B43%E6%9C%8816%E6%97%A5%2001_25_49.png'
  @State currentTrainingType: string = 'gesture'
  @State trainView: string = 'courseList'
  @State trainDetailCourseCode: string = ''
  @State recordDetailCourseCode: string = ''
  @State selectedFilter: string = '周'
  @State selectedGoal: string = '日常交流'
  @State selectedTheme: string = '海盐蓝'
  @State profileView: string = 'main'
  @State notificationsEnabled: boolean = true
  @State vibrationEnabled: boolean = false
  @State isTrainScoring: boolean = false
  @State favoriteCourseCodes: string[] = []
  @State recentCourses: RecentCourseItem[] = [
    new RecentCourseItem('COURSE-301', '声母训练入门', '03-17 22:05', 'http://192.168.142.128:9001/hearbridge-bucket/20260316/smxlrm.png', 68),
    new RecentCourseItem('COURSE-101', '日常问候入门', '03-17 20:41', 'http://192.168.142.128:9001/hearbridge-bucket/20260316/3ad909fc0af94c58a8f2be4ca2fe4cbcChatGPT%20Image%202026%E5%B9%B43%E6%9C%8816%E6%97%A5%2001_25_49.png', 42)
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
      this.isLoggedIn = token.length > 0
    } catch (_error) {
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
      202: '验证码错误',
      204: '数据异常',
      205: '请输入正确的手机号',
      206: '验证码已过期，请重新获取',
      207: '验证码发送失败，请稍后重试',
      210: '请求过于频繁，请稍后再试',
      214: '今日短信次数已达上限',
      216: '账号已被禁用，请联系管理员'
    }
    return errorMap[code] ?? fallbackMessage
  }

  private async handleRequestCode() {
    if (this.phoneNumber.length !== 11) {
      this.loginTip = '请输入正确的手机号'
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
        ? '验证码发送成功'
        : this.getErrorMessage(result.code, result.message || '验证码发送失败')

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
      this.loginTip = '请输入正确的手机号'
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
      this.loginTip = '登录成功'
      this.isLoggedIn = true
      this.currentTab = 0
      this.clearCountdownTimer()
    } catch (error) {
      this.loginTip = `登录失败：${JSON.stringify(error)}`
    } finally {
      this.isLoggingIn = false
    }
  }

  private handleSkipLogin() {
    this.loginTip = '已跳过登录，当前为本地调试模式。'
    this.isLoggedIn = true
    this.currentTab = 0
    this.profileView = 'main'
    this.clearCountdownTimer()
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
      return '日常问候入门'
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
      return '本课程围绕声母训练入门，提供从口型控制到跟读输出的循序训练路径。'
    }
    if (courseCode === 'COURSE-101') {
      return '用于基础问候表达训练，帮助建立日常交流的起步能力。'
    }
    return '课程详情将由后端接口返回后动态渲染。'
  }

  @Builder
  private buildTopBar() {
    Row() {
      Column({ space: 4 }) {
        Text('HearBridge')
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .fontColor('#2E79F4')

        Text('科学训练，轻量陪伴')
          .fontSize(12)
          .fontColor('#7A8CA7')
      }
      .alignItems(HorizontalAlign.Start)

      Blank()

      Stack({ alignContent: Alignment.Center }) {
        Row() {
        }
        .width(32)
        .height(32)
        .backgroundColor('#F3F7FF')
        .borderRadius(16)
        .border({ width: 1, color: '#DDE8F8' })
        .shadow({ radius: 10, color: '#2E79F414', offsetX: 0, offsetY: 4 })

        SymbolGlyph($r('sys.symbol.ellipsis_message'))
          .fontSize(18)
          .fontColor(['#4C79C9'])
      }
      .width(32)
      .height(32)
    }
    .width('100%')
    .padding({ left: 18, right: 18, top: 0, bottom: 8 })
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
    } else if (this.currentTab === 1) {
      if (this.trainView === 'courseList') {
        if (this.trainDetailCourseCode.length > 0) {
          CourseDetailPage({
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
            this.selectedPhrase = this.currentTrainingType === 'speech' ? '阿' : '你好'
            this.selectedPhrase = courseCode === 'COURSE-301' ? '浣犲ソ' : this.selectedPhrase
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
        avatarUrl: $avatarUrl,
        selectedGoal: this.selectedGoal,
        selectedTheme: this.selectedTheme,
        notificationsEnabled: this.notificationsEnabled,
        vibrationEnabled: this.vibrationEnabled,
        onOpenSettings: () => {
          this.profileView = 'settings'
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
        }
      })
    }
  }

  build() {
    if (!this.isLoggedIn) {
      LoginPage({
        phoneNumber: $phoneNumber,
        verificationCode: $verificationCode,
        loginTip: $loginTip,
        codeCountdown: $codeCountdown,
        isSendingCode: $isSendingCode,
        isLoggingIn: $isLoggingIn,
        apiBaseUrl: this.smsApiBaseUrl,
        onPhoneChange: (value: string) => {
          this.phoneNumber = this.sanitizePhone(value)
        },
        onCodeChange: (value: string) => {
          this.verificationCode = this.sanitizeCode(value)
        },
        onRequestCode: () => {
          this.handleRequestCode()
        },
        onLogin: () => {
          this.handleLogin()
        },
        onSkipLogin: () => {
          this.handleSkipLogin()
        }
      })
    } else {
      Stack({ alignContent: Alignment.Top }) {
        Column() {
          if (this.currentTab !== 1 && !(this.currentTab === 2 && this.recordDetailCourseCode.length > 0)) {
            this.buildTopBar()
          }

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
