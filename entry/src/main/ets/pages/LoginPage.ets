@Component
export struct LoginPage {
  @Link phoneNumber: string
  @Link verificationCode: string
  @Link loginTip: string
  @Link codeCountdown: number
  @Link isSendingCode: boolean
  @Link isLoggingIn: boolean
  @Prop apiBaseUrl: string = ''
  onPhoneChange: (value: string) => void = () => {}
  onCodeChange: (value: string) => void = () => {}
  onRequestCode: () => void = () => {}
  onLogin: () => void = () => {}
  onSkipLogin: () => void = () => {}

  build() {
    Column() {
      Column({ space: 20 }) {
        Column({ space: 8 }) {
          Text('HearBridge')
            .fontSize(32)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1F5FE0')

          Text('验证码登录')
            .fontSize(15)
            .fontColor('#607089')
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)

        Column({ space: 12 }) {
          this.buildInput('手机号', '请输入手机号', this.phoneNumber, this.onPhoneChange)

          Row({ space: 12 }) {
            Column() {
              this.buildInput('验证码', '请输入验证码', this.verificationCode, this.onCodeChange)
            }
            .layoutWeight(1)

            Button(this.isSendingCode ? '发送中' : (this.codeCountdown > 0 ? `${this.codeCountdown}s` : '获取'))
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
        .width('100%')

        Text(this.loginTip)
          .width('100%')
          .fontSize(12)
          .fontColor('#607089')
          .lineHeight(18)

        Button(this.isLoggingIn ? '登录中...' : '登录')
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
            this.onLogin()
          })

        Button('跳过登录')
          .width('100%')
          .height(44)
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor('#5F7391')
          .backgroundColor('#F5F8FD')
          .borderRadius(18)
          .onClick(() => {
            this.onSkipLogin()
          })

        Column({ space: 8 }) {
          this.buildTag('登录后自动保存 Token')
          this.buildTag(`接口地址：${this.apiBaseUrl}`)
          this.buildTag('真机调试请改为局域网 IP')
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
  private buildTag(label: string) {
    Text(label)
      .fontSize(12)
      .fontColor('#3A71C1')
      .padding({ left: 12, right: 12, top: 8, bottom: 8 })
      .backgroundColor('#EEF5FF')
      .borderRadius(14)
  }
}
