@Component
export struct LoginPage {
  @Link authScene: string
  @Link loginMode: string
  @Link phoneNumber: string
  @Link verificationCode: string
  @Link account: string
  @Link password: string
  @Link registerAccount: string
  @Link registerPassword: string
  @Link registerConfirmPassword: string
  @Link registerPhone: string
  @Link loginTip: string
  @Link codeCountdown: number
  @Link isSendingCode: boolean
  @Link isLoggingIn: boolean
  @Prop apiBaseUrl: string = ''

  onAuthSceneChange: (value: string) => void = () => {}
  onLoginModeChange: (value: string) => void = () => {}
  onPhoneChange: (value: string) => void = () => {}
  onCodeChange: (value: string) => void = () => {}
  onAccountChange: (value: string) => void = () => {}
  onPasswordChange: (value: string) => void = () => {}
  onRegisterAccountChange: (value: string) => void = () => {}
  onRegisterPasswordChange: (value: string) => void = () => {}
  onRegisterConfirmPasswordChange: (value: string) => void = () => {}
  onRegisterPhoneChange: (value: string) => void = () => {}
  onRequestCode: () => void = () => {}
  onLogin: () => void = () => {}
  onPasswordLogin: () => void = () => {}
  onRegister: () => void = () => {}
  onSkipLogin: () => void = () => {}

  build() {
    Column() {
      Column({ space: 20 }) {
        Column({ space: 8 }) {
          Text('HearBridge')
            .fontSize(32)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1F5FE0')

          Text(this.authScene === 'register'
            ? '\u521b\u5efa\u8d26\u53f7'
            : (this.loginMode === 'password' ? '\u8d26\u53f7\u5bc6\u7801\u767b\u5f55' : '\u9a8c\u8bc1\u7801\u767b\u5f55'))
            .fontSize(15)
            .fontColor('#607089')
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)

        Row({ space: 8 }) {
          this.buildSceneTab('login', '\u767b\u5f55')
          this.buildSceneTab('register', '\u6ce8\u518c')
        }
        .width('100%')

        if (this.authScene === 'register') {
          Column({ space: 12 }) {
            this.buildInput('\u6ce8\u518c\u8d26\u53f7', '\u8bf7\u8f93\u5165\u8d26\u53f7', this.registerAccount, this.onRegisterAccountChange)
            this.buildPasswordInput('\u8bbe\u7f6e\u5bc6\u7801', '\u81f3\u5c11 6 \u4f4d', this.registerPassword, this.onRegisterPasswordChange)
            this.buildPasswordInput('\u786e\u8ba4\u5bc6\u7801', '\u518d\u6b21\u8f93\u5165\u5bc6\u7801', this.registerConfirmPassword, this.onRegisterConfirmPasswordChange)
            this.buildInput('\u624b\u673a\u53f7\uff08\u53ef\u9009\uff09', '\u7528\u4e8e\u540e\u7eed\u627e\u56de\u5bc6\u7801', this.registerPhone, this.onRegisterPhoneChange)
          }
          .width('100%')
        } else {
          Row({ space: 8 }) {
            this.buildModeTab('sms', '\u9a8c\u8bc1\u7801\u767b\u5f55')
            this.buildModeTab('password', '\u8d26\u53f7\u5bc6\u7801')
          }
          .width('100%')

          Column({ space: 12 }) {
            if (this.loginMode === 'password') {
              this.buildInput('\u8d26\u53f7', '\u8bf7\u8f93\u5165\u8d26\u53f7', this.account, this.onAccountChange)
              this.buildPasswordInput('\u5bc6\u7801', '\u8bf7\u8f93\u5165\u5bc6\u7801', this.password, this.onPasswordChange)
            } else {
              this.buildInput('\u624b\u673a\u53f7', '\u8bf7\u8f93\u5165\u624b\u673a\u53f7', this.phoneNumber, this.onPhoneChange)

              Row({ space: 12 }) {
                Column() {
                  this.buildInput('\u9a8c\u8bc1\u7801', '\u8bf7\u8f93\u5165\u9a8c\u8bc1\u7801', this.verificationCode, this.onCodeChange)
                }
                .layoutWeight(1)

                Button(this.isSendingCode ? '\u53d1\u9001\u4e2d' : (this.codeCountdown > 0 ? `${this.codeCountdown}s` : '\u83b7\u53d6'))
                  .width(104)
                  .height(52)
                  .fontSize(15)
                  .fontColor(this.isSendingCode || this.codeCountdown > 0 ? '#8AA0B8' : '#FFFFFF')
                  .backgroundColor(this.isSendingCode || this.codeCountdown > 0 ? '#EAF0F7' : '#2E79F4')
                  .borderRadius(18)
                  .onClick(() => {
                    this.onRequestCode()
                  })
              }
              .width('100%')
            }
          }
          .width('100%')
        }

        Text(this.loginTip)
          .width('100%')
          .fontSize(12)
          .fontColor('#607089')
          .lineHeight(18)

        Button(this.isLoggingIn ? (this.authScene === 'register' ? '\u6ce8\u518c\u4e2d...' : '\u767b\u5f55\u4e2d...') : (this.authScene === 'register' ? '\u6ce8\u518c' : '\u767b\u5f55'))
          .width('100%')
          .height(50)
          .fontSize(17)
          .fontWeight(FontWeight.Medium)
          .fontColor('#FFFFFF')
          .linearGradient({
            angle: 90,
            colors: this.isLoggingIn ? [['#9CB4D6', 0], ['#7F96B7', 1]] : [['#35C3EE', 0], ['#2E79F4', 1]]
          })
          .borderRadius(20)
          .onClick(() => {
            if (this.authScene === 'register') {
              this.onRegister()
            } else if (this.loginMode === 'password') {
              this.onPasswordLogin()
            } else {
              this.onLogin()
            }
          })

        Column({ space: 8 }) {
          this.buildTag('\u8d26\u53f7\u5bc6\u7801\u767b\u5f55/\u6ce8\u518c\u5df2\u63a5\u5165 API')
          this.buildTag(`\u63a5\u53e3\u5730\u5740\uff1a${this.apiBaseUrl}`)
          this.buildTag('\u771f\u673a\u8c03\u8bd5\u8bf7\u6539\u4e3a\u5c40\u57df\u7f51 IP')
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')
      .padding(24)
      .backgroundColor('#FFFFFFE8')
      .backgroundBlurStyle(BlurStyle.COMPONENT_ULTRA_THICK)
      .borderRadius(30)
      .shadow({ radius: 22, color: '#15304B16', offsetX: 0, offsetY: 10 })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .padding(20)
    .backgroundImage($r('app.media.background'))
    .backgroundImageSize(ImageSize.Cover)
  }

  @Builder
  private buildSceneTab(scene: string, label: string) {
    Text(label)
      .layoutWeight(1)
      .height(36)
      .textAlign(TextAlign.Center)
      .fontSize(14)
      .fontWeight(this.authScene === scene ? FontWeight.Medium : FontWeight.Regular)
      .fontColor(this.authScene === scene ? '#2E79F4' : '#6F83A2')
      .backgroundColor(this.authScene === scene ? '#EAF2FF' : '#F5F8FD')
      .borderRadius(12)
      .onClick(() => {
        this.onAuthSceneChange(scene)
      })
  }

  @Builder
  private buildModeTab(mode: string, label: string) {
    Text(label)
      .layoutWeight(1)
      .height(36)
      .textAlign(TextAlign.Center)
      .fontSize(14)
      .fontWeight(this.loginMode === mode ? FontWeight.Medium : FontWeight.Regular)
      .fontColor(this.loginMode === mode ? '#2E79F4' : '#6F83A2')
      .backgroundColor(this.loginMode === mode ? '#EAF2FF' : '#F5F8FD')
      .borderRadius(12)
      .onClick(() => {
        this.onLoginModeChange(mode)
      })
  }

  @Builder
  private buildInput(label: string, placeholder: string, value: string, onChange: (value: string) => void) {
    Column({ space: 8 }) {
      Text(label)
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .fontColor('#1F2A44')

      TextInput({ text: value, placeholder })
        .width('100%')
        .height(52)
        .fontSize(16)
        .type(InputType.Normal)
        .backgroundColor('#F5F8FD')
        .borderRadius(18)
        .padding({ left: 16, right: 16 })
        .onChange((input: string) => {
          onChange(input)
        })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  private buildPasswordInput(label: string, placeholder: string, value: string, onChange: (value: string) => void) {
    Column({ space: 8 }) {
      Text(label)
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .fontColor('#1F2A44')

      TextInput({ text: value, placeholder })
        .width('100%')
        .height(52)
        .fontSize(16)
        .type(InputType.Password)
        .backgroundColor('#F5F8FD')
        .borderRadius(18)
        .padding({ left: 16, right: 16 })
        .onChange((input: string) => {
          onChange(input)
        })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  private buildTag(label: string) {
    Text(label)
      .fontSize(12)
      .fontColor('#3A71C1')
      .padding({ left: 12, right: 12, top: 8, bottom: 8 })
      .backgroundColor('#EEF5FF')
      .borderRadius(14)
  }
}
