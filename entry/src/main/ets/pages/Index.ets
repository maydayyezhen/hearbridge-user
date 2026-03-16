import common from '@ohos.app.ability.common'
import { readToken, saveToken } from '../api/AuthStorage'
import { sendSmsCode, smsLogin } from '../api/AuthApi'
import { HomePage } from './HomePage'
import { LoginPage } from './LoginPage'
import { ProfilePage } from './ProfilePage'
import { RecordPage } from './RecordPage'
import { TrainPage } from './TrainPage'

@Entry
@Component
struct Index {
  @State isLoggedIn: boolean = false
  @State currentTab: number = 0
  @State phoneNumber: string = ''
  @State verificationCode: string = ''
  @State loginTip: string = 'Enter your phone number and request an SMS code.'
  @State codeCountdown: number = 0
  @State isSendingCode: boolean = false
  @State isLoggingIn: boolean = false
  @State dailyProgress: number = 40
  @State selectedPhrase: string = 'Hello'
  @State selectedFilter: string = 'Week'
  @State selectedGoal: string = 'Daily communication'
  @State selectedTheme: string = 'Ocean'
  @State notificationsEnabled: boolean = true
  @State vibrationEnabled: boolean = false

  private readonly smsApiBaseUrl: string = 'http://127.0.0.1:8501'
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
      202: 'Incorrect verification code',
      204: 'Data error',
      205: 'Please enter a valid phone number',
      206: 'Verification code expired, please request a new one',
      207: 'Failed to send verification code, please try again later',
      210: 'Requests are too frequent, please try again later',
      214: 'Daily SMS limit reached',
      216: 'Account disabled, please contact administrator'
    }
    return errorMap[code] ?? fallbackMessage
  }

  private async handleRequestCode() {
    if (this.phoneNumber.length !== 11) {
      this.loginTip = 'Please enter a valid phone number'
      return
    }
    if (this.isSendingCode || this.codeCountdown > 0) {
      return
    }

    this.isSendingCode = true
    this.loginTip = 'Sending verification code...'

    try {
      const result = await sendSmsCode(this.smsApiBaseUrl, this.phoneNumber)
      this.loginTip = result.ok
        ? 'Verification code sent successfully'
        : this.getErrorMessage(result.code, result.message || 'Failed to send verification code')

      if (result.ok) {
        this.startCountdown()
      }
    } catch (error) {
      this.loginTip = `Failed to send verification code: ${JSON.stringify(error)}`
    } finally {
      this.isSendingCode = false
    }
  }

  private async handleLogin() {
    if (this.phoneNumber.length !== 11) {
      this.loginTip = 'Please enter a valid phone number'
      return
    }
    if (this.verificationCode.length === 0) {
      this.loginTip = 'Please enter the verification code'
      return
    }
    if (this.isLoggingIn) {
      return
    }

    this.isLoggingIn = true
    this.loginTip = 'Logging in...'

    try {
      const result = await smsLogin(this.smsApiBaseUrl, this.phoneNumber, this.verificationCode)
      if (!result.ok || !result.data?.token) {
        this.loginTip = this.getErrorMessage(result.code, result.message || 'Login failed')
        return
      }

      await saveToken(this.getAbilityContext(), result.data.token)
      this.loginTip = 'Login successful'
      this.isLoggedIn = true
      this.currentTab = 0
      this.clearCountdownTimer()
    } catch (error) {
      this.loginTip = `Login failed: ${JSON.stringify(error)}`
    } finally {
      this.isLoggingIn = false
    }
  }

  @Builder
  private buildTopBar() {
    Row() {
      Column({ space: 4 }) {
        Text('HearBridge')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor('#203040')

        Text('Page-based structure with separated API files')
          .fontSize(12)
          .fontColor('#6C7B8A')
      }
      .alignItems(HorizontalAlign.Start)

      Blank()

      Text(this.selectedTheme)
        .fontSize(12)
        .fontColor('#246BFD')
        .padding({ left: 12, right: 12, top: 8, bottom: 8 })
        .backgroundColor('#EAF2FA')
        .borderRadius(14)
    }
    .width('100%')
    .padding({ left: 20, right: 20, top: 18, bottom: 8 })
  }

  @Builder
  private buildBottomNav() {
    Row() {
      this.buildNavItem(0, 'Home')
      this.buildNavItem(1, 'Train')
      this.buildNavItem(2, 'Record')
      this.buildNavItem(3, 'Profile')
    }
    .width('100%')
    .padding({ left: 12, right: 12, top: 10, bottom: 18 })
    .backgroundColor('#FFFFFF')
    .borderRadius({ topLeft: 24, topRight: 24 })
  }

  @Builder
  private buildNavItem(index: number, label: string) {
    Column({ space: 6 }) {
      Text(this.currentTab === index ? 'o' : '.')
        .fontSize(16)
        .fontColor(this.currentTab === index ? '#246BFD' : '#9AA8B5')

      Text(label)
        .fontSize(11)
        .fontColor(this.currentTab === index ? '#246BFD' : '#7A8794')
    }
    .layoutWeight(1)
    .padding({ top: 4, bottom: 4 })
    .onClick(() => {
      this.currentTab = index
    })
  }

  @Builder
  private buildCurrentPage() {
    if (this.currentTab === 0) {
      HomePage({
        dailyProgress: this.dailyProgress,
        onOpenTraining: () => {
          this.currentTab = 1
        }
      })
    } else if (this.currentTab === 1) {
      TrainPage({
        selectedPhrase: this.selectedPhrase,
        onSelectPhrase: (phrase: string) => {
          this.selectedPhrase = phrase
        },
        onCompleteTraining: () => {
          if (this.dailyProgress < 100) {
            this.dailyProgress = Math.min(100, this.dailyProgress + 10)
          }
        }
      })
    } else if (this.currentTab === 2) {
      RecordPage({
        dailyProgress: this.dailyProgress,
        selectedFilter: this.selectedFilter,
        onFilterChange: (filter: string) => {
          this.selectedFilter = filter
        },
        onOpenTraining: () => {
          this.currentTab = 1
        }
      })
    } else {
      ProfilePage({
        selectedGoal: this.selectedGoal,
        selectedTheme: this.selectedTheme,
        notificationsEnabled: this.notificationsEnabled,
        vibrationEnabled: this.vibrationEnabled,
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
        }
      })
    } else {
      Stack({ alignContent: Alignment.Bottom }) {
        Scroll() {
          Column({ space: 8 }) {
            this.buildTopBar()
            this.buildCurrentPage()
          }
          .width('100%')
        }
        .scrollBar(BarState.Off)

        this.buildBottomNav()
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#EAF2FA')
    }
  }
}
