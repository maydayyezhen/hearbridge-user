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
    Stack() {
      Row()
        .width('100%')
        .height('100%')
        .linearGradient({
          angle: 180,
          colors: [
            ['#F8FBFF', 0],
            ['#F2F7FF', 0.42],
            ['#FFFFFF', 1]
          ]
        })
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])

      if (this.authScene === 'register') {
        this.buildRegisterScene()
      } else {
        this.buildLoginScene()
      }
    }
    .width('100%')
    .height('100%')
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }

  @Builder
  private buildLoginScene() {
    Column() {
      Column({ space: 18 }) {
        Text(this.loginMode === 'password' ? '账号密码登录' : '短信验证码登录')
          .width('100%')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor('#11233C')
          .textAlign(TextAlign.Center)

        if (this.loginMode === 'password') {
          Column({ space: 14 }) {
            this.buildInputField($r('sys.symbol.person_badge_plus'), '账号', '请输入账号', this.account, this.onAccountChange)
            this.buildInputField($r('sys.symbol.lock_shield'), '密码', '请输入密码', this.password, this.onPasswordChange, true)
          }
          .width('100%')
        } else {
          Column({ space: 14 }) {
            this.buildInputField($r('sys.symbol.phone'), '手机号', '请输入手机号', this.phoneNumber, this.onPhoneChange)
            this.buildCodeField()
          }
          .width('100%')
        }

        this.buildInlineTip()

        this.buildSubmitButton(false)

        Row() {
          Button(this.loginMode === 'password' ? '短信验证码登录' : '账号密码登录')
            .fontSize(13)
            .fontWeight(FontWeight.Medium)
            .fontColor('#5A8BEA')
            .backgroundColor(Color.Transparent)
            .borderRadius(6)
            .padding({ left: 4, right: 4, top: 1, bottom: 1 })
            .constraintSize({ minWidth: 92, minHeight: 20 })
            .stateEffect(false)
            .onClick(() => {
              this.onLoginModeChange(this.loginMode === 'password' ? 'sms' : 'password')
            })

          Button('没有账号？')
            .fontSize(13)
            .fontWeight(FontWeight.Medium)
            .fontColor('#5A8BEA')
            .backgroundColor(Color.Transparent)
            .borderRadius(6)
            .padding({ left: 4, right: 4, top: 1, bottom: 1 })
            .constraintSize({ minWidth: 80, minHeight: 20 })
            .stateEffect(false)
            .onClick(() => {
              this.onAuthSceneChange('register')
            })
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
        .margin({ top: -10 })
      }
      .width('100%')

      Blank()
        .layoutWeight(1)

      Text('登录即代表同意《用户协议》与《隐私条款》')
        .width('100%')
        .fontSize(12)
        .lineHeight(18)
        .textAlign(TextAlign.Center)
        .fontColor('#7C8FA6')
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Start)
    .padding({ left: 22, right: 22, top: 28, bottom: 18 })
  }

  @Builder
  private buildRegisterScene() {
    Scroll() {
      Column() {
        Column({ space: 18 }) {
          Stack() {
            Text('创建听桥账号')
              .width('100%')
              .fontSize(24)
              .fontWeight(FontWeight.Bold)
              .fontColor('#11233C')
              .textAlign(TextAlign.Center)

            Row() {
              Button() {
                SymbolGlyph($r('sys.symbol.chevron_backward'))
                  .fontSize(21)
                  .fontColor(['#7E8794'])
              }
              .width(36)
              .height(36)
              .backgroundColor(Color.Transparent)
              .borderRadius(10)
              .stateEffect(false)
              .onClick(() => {
                this.onAuthSceneChange('login')
              })
            }
            .width('100%')
            .justifyContent(FlexAlign.Start)
            .position({ x: -12, y: 0 })
          }
          .width('100%')
          .height(32)

          Column({ space: 14 }) {
            this.buildInputField($r('sys.symbol.person_badge_plus'), '注册账号', '请输入账号', this.registerAccount,
              this.onRegisterAccountChange)
            this.buildInputField($r('sys.symbol.lock_shield'), '设置密码', '至少 6 位', this.registerPassword,
              this.onRegisterPasswordChange, true)
            this.buildInputField($r('sys.symbol.checkmark_circle'), '确认密码', '再次输入密码', this.registerConfirmPassword,
              this.onRegisterConfirmPasswordChange, true)
            this.buildInputField($r('sys.symbol.phone'), '手机号（可选）', '用于后续找回密码', this.registerPhone,
              this.onRegisterPhoneChange)
          }
          .width('100%')

          this.buildInlineTip()

          this.buildSubmitButton(true)
        }
        .width('100%')
        .padding({ left: 0, right: 0, top: 0, bottom: 16 })
      }
      .width('100%')
      .padding({ left: 22, right: 22, top: 28, bottom: 28 })
      .constraintSize({ minHeight: '100%' })
      .alignItems(HorizontalAlign.Start)
      .justifyContent(FlexAlign.Start)
    }
    .width('100%')
    .height('100%')
    .scrollBar(BarState.Off)
  }

  @Builder
  private buildInputField(icon: Resource, label: string, placeholder: string, value: string,
    onChange: (value: string) => void, isPassword: boolean = false) {
    Column({ space: 7 }) {
      Text(label)
        .fontSize(13)
        .fontWeight(FontWeight.Medium)
        .fontColor('#3F5672')
        .letterSpacing(0.3)

      Row({ space: 12 }) {
        SymbolGlyph(icon)
          .fontSize(18)
          .fontColor(['#7C96B8'])

        TextInput({ text: value, placeholder })
          .layoutWeight(1)
          .height(50)
          .fontSize(16)
          .fontColor('#1D2F45')
          .type(isPassword ? InputType.Password : InputType.Normal)
          .backgroundColor(Color.Transparent)
          .padding({ left: 0, right: 0 })
          .placeholderFont({ size: 15 })
          .placeholderColor('#778CA7')
          .onChange((input: string) => {
            onChange(input)
          })
      }
      .width('100%')
      .height(52)
      .padding({ left: 15, right: 15 })
      .backgroundColor('#F8FBFF')
      .borderRadius(16)
      .border({ width: 1, color: '#C8D8EA' })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  private buildCodeField() {
    Column({ space: 7 }) {
      Text('验证码')
        .fontSize(13)
        .fontWeight(FontWeight.Medium)
        .fontColor('#3F5672')
        .letterSpacing(0.3)

      Row({ space: 10 }) {
        Row({ space: 10 }) {
          SymbolGlyph($r('sys.symbol.ellipsis_bubble'))
            .fontSize(18)
            .fontColor(['#7C96B8'])

          TextInput({ text: this.verificationCode, placeholder: '请输入验证码' })
            .layoutWeight(1)
            .height(50)
            .fontSize(16)
            .fontColor('#1D2F45')
            .backgroundColor(Color.Transparent)
            .padding({ left: 0, right: 0 })
            .placeholderFont({ size: 15 })
            .placeholderColor('#778CA7')
            .onChange((input: string) => {
              this.onCodeChange(input)
            })
        }
        .layoutWeight(1)
        .height(52)
        .padding({ left: 15, right: 15 })
        .backgroundColor('#F8FBFF')
        .borderRadius(16)
        .border({ width: 1, color: '#C8D8EA' })

        Button(this.isSendingCode ? '发送中' : (this.codeCountdown > 0 ? `${this.codeCountdown}s` : '获取验证码'))
          .width(96)
          .height(52)
          .fontSize(11)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.isSendingCode || this.codeCountdown > 0 ? '#9DB4CC' : '#7C9FE9')
          .backgroundColor('#FFFFFF')
          .borderRadius(16)
          .border({
            width: 1,
            color: this.isSendingCode || this.codeCountdown > 0 ? '#DCE8F5' : '#CFE0FB'
          })
          .onClick(() => {
            this.onRequestCode()
          })
      }
      .width('100%')
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  private buildTipCard() {
    Row({ space: 10 }) {
      SymbolGlyph($r('sys.symbol.info_circle'))
        .fontSize(14)
        .fontColor(['#7A9ABF'])

      Text(this.loginTip)
        .layoutWeight(1)
        .fontSize(12)
        .lineHeight(18)
        .fontColor('#7A9ABF')
    }
    .width('100%')
    .alignItems(VerticalAlign.Center)
    .padding({ left: 14, right: 14, top: 11, bottom: 11 })
    .backgroundColor('#EEF5FF')
    .borderRadius(14)
    .border({ width: 1, color: '#D5E5FF' })
  }

  @Builder
  private buildInlineTip() {
    if (this.shouldShowInlineTip()) {
      Text(this.loginTip)
        .width('100%')
        .fontSize(12)
        .lineHeight(18)
        .fontColor(this.getInlineTipColor())
        .textAlign(TextAlign.Start)
        .margin({ top: -4 })
    }
  }

  private shouldShowInlineTip(): boolean {
    if (this.loginTip.length === 0) {
      return false
    }
    if (this.loginTip === '请输入手机号并获取验证码。') {
      return false
    }
    if (this.loginTip === '请输入账号和密码进行登录') {
      return false
    }
    if (this.loginTip === '填写信息后即可完成注册') {
      return false
    }
    return true
  }

  private getInlineTipColor(): string {
    if (this.loginTip.indexOf('成功') >= 0) {
      return '#2BA471'
    }
    if (this.loginTip.indexOf('正在') >= 0 || this.loginTip.indexOf('已') === 0) {
      return '#7A8CA7'
    }
    return '#E5484D'
  }

  @Builder
  private buildSubmitButton(isRegister: boolean) {
    Button() {
      Text(this.isLoggingIn ? (isRegister ? '注册中...' : '登录中...') : (isRegister ? '注册账号' : '立即登录'))
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor('#FFFFFF')
        .letterSpacing(0.5)
    }
    .width('100%')
    .height(54)
    .linearGradient({
      angle: 105,
      colors: this.isLoggingIn
        ? [['#90B0D8', 0], ['#6E8EB8', 1]]
        : [['#3AAAE8', 0], ['#1848DE', 1]]
    })
    .borderRadius(18)
    .shadow({ radius: 22, color: '#1848DE2A', offsetX: 0, offsetY: 10 })
    .onClick(() => {
      if (isRegister) {
        this.onRegister()
      } else if (this.loginMode === 'password') {
        this.onPasswordLogin()
      } else {
        this.onLogin()
      }
    })
  }
}
