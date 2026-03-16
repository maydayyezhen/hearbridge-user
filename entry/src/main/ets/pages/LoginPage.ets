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

  build() {
    Column() {
      Column({ space: 18 }) {
        Column({ space: 8 }) {
          Text('HearBridge')
            .fontSize(34)
            .fontWeight(FontWeight.Bold)
            .fontColor('#15304B')

          Text('SMS verification login')
            .fontSize(15)
            .fontColor('#5C7187')
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)

        Column({ space: 12 }) {
          Text('Login')
            .fontSize(26)
            .fontWeight(FontWeight.Bold)
            .fontColor('#203040')

          Text(`API base URL: ${this.apiBaseUrl}`)
            .fontSize(12)
            .fontColor('#6C7B8A')
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)

        Column({ space: 14 }) {
          this.buildInput('Phone', 'Enter phone number', this.phoneNumber, this.onPhoneChange)

          Row({ space: 12 }) {
            Column() {
              this.buildInput('Code', 'Enter verification code', this.verificationCode, this.onCodeChange)
            }
            .layoutWeight(1)

            Button(this.isSendingCode ? 'Sending...' : (this.codeCountdown > 0 ? `${this.codeCountdown}s` : 'Get Code'))
              .width(124)
              .height(52)
              .fontSize(14)
              .fontColor(this.isSendingCode || this.codeCountdown > 0 ? '#7F8C99' : '#FFFFFF')
              .backgroundColor(this.isSendingCode || this.codeCountdown > 0 ? '#E6EDF3' : '#246BFD')
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
          .fontColor('#587089')
          .lineHeight(18)

        Button(this.isLoggingIn ? 'Logging in...' : 'Login')
          .width('100%')
          .height(48)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#FFFFFF')
          .backgroundColor(this.isLoggingIn ? '#5C7187' : '#15304B')
          .borderRadius(16)
          .onClick(() => {
            this.onLogin()
          })

        Column({ space: 8 }) {
          this.buildTag('Token is stored locally after login')
          this.buildTag('Preview can use 127.0.0.1')
          this.buildTag('Real devices must use your LAN IP')
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')
      .padding(24)
      .backgroundColor('#FDFEFE')
      .borderRadius(28)
      .shadow({ radius: 18, color: '#10233D18', offsetX: 0, offsetY: 10 })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .padding(20)
    .backgroundColor('#EAF2FA')
  }

  @Builder
  private buildInput(label: string, placeholder: string, value: string, onChange: (value: string) => void) {
    Column({ space: 8 }) {
      Text(label)
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .fontColor('#1F3245')

      TextInput({ text: value, placeholder })
        .width('100%')
        .height(52)
        .fontSize(16)
        .type(InputType.Normal)
        .backgroundColor('#F2F6FA')
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
      .fontColor('#2A557A')
      .padding({ left: 12, right: 12, top: 8, bottom: 8 })
      .backgroundColor('#EAF2FA')
      .borderRadius(14)
  }
}
