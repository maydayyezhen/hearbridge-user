import { mockUpdatePassword, mockUploadAvatar } from '../api/ProfileApi'
import photoAccessHelper from '@ohos.file.photoAccessHelper'

@Component
export struct ProfilePage {
  @Prop currentView: string = 'main'
  @Link avatarUrl: string
  @Prop selectedGoal: string = ''
  @Prop selectedTheme: string = ''
  @Prop notificationsEnabled: boolean = true
  @Prop vibrationEnabled: boolean = false

  @State selectedAvatarUrl: string = ''
  @State avatarTip: string = '可选择预设头像或从本地相册选择后上传。'
  @State avatarTipTone: string = 'normal'
  @State isUploadingAvatar: boolean = false
  @State isPickingAvatar: boolean = false

  @State profileNickname: string = '桥桥'
  @State profileGender: string = '女'
  @State profileBirthday: string = '2000-01-01'
  @State profileSignature: string = '每天进步一点点。'
  @State profileTip: string = '可随时更新账号资料。'
  @State profileTipTone: string = 'normal'

  @State currentPassword: string = ''
  @State nextPassword: string = ''
  @State confirmPassword: string = ''
  @State passwordTip: string = '密码需至少 8 位，建议包含字母和数字。'
  @State passwordTipTone: string = 'normal'
  @State isUpdatingPassword: boolean = false

  onOpenSettings: () => void = () => {}
  onOpenFavorites: () => void = () => {}
  onOpenAccountSecurity: () => void = () => {}
  onOpenAccountProfile: () => void = () => {}
  onCloseSettings: () => void = () => {}
  onBackToSettings: () => void = () => {}
  onGoalChange: (goal: string) => void = () => {}
  onThemeChange: (theme: string) => void = () => {}
  onNotificationsChange: (value: boolean) => void = () => {}
  onVibrationChange: (value: boolean) => void = () => {}

  private readonly avatarOptions: string[] = [
    'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?auto=format&fit=crop&w=400&q=80',
    'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=400&q=80',
    'https://images.unsplash.com/photo-1517841905240-472988babdf9?auto=format&fit=crop&w=400&q=80'
  ]

  aboutToAppear() {
    if (this.selectedAvatarUrl.length === 0) {
      this.selectedAvatarUrl = this.avatarUrl
    }
  }

  build() {
    Column() {
      Scroll() {
        Column({ space: 18 }) {
          if (this.currentView === 'accountSecurity') {
            this.buildAccountSecurity()
          } else if (this.currentView === 'accountProfile') {
            this.buildAccountProfile()
          } else {
            this.buildProfileOverview()
          }
        }
        .width('100%')
        .justifyContent(FlexAlign.Start)
        .alignItems(HorizontalAlign.Start)
        .constraintSize({ minHeight: '100%' })
        .padding({ left: 16, right: 16, top: 6, bottom: 24 })
      }
      .width('100%')
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Start)
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  private buildProfileOverview() {
    Column({ space: 18 }) {
      this.buildProfileCard()
      this.buildMainActions()
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
      this.buildMenuRow($r('sys.symbol.questionmark_circle'), '帮助与反馈')
      this.buildMenuRow($r('sys.symbol.info_circle'), '关于 HearBridge')
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

        Button('保存资料')
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
          .onClick(() => {
            this.avatarUrl = this.selectedAvatarUrl.length > 0 ? this.selectedAvatarUrl : this.avatarUrl
            this.profileTip = '资料已保存（本地模拟）。'
            this.profileTipTone = 'success'
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
      this.buildPageHeader('账号与安全', '修改登录密码与安全信息', () => {
        this.onBackToSettings()
      })

      Column({ space: 14 }) {
        Text('修改密码')
          .width('100%')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor('#1F2A44')

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

  private async submitPasswordChange() {
    if (this.isUpdatingPassword) {
      return
    }
    this.isUpdatingPassword = true
    this.passwordTip = '正在提交密码修改...'
    this.passwordTipTone = 'normal'
    try {
      const result = await mockUpdatePassword(this.currentPassword, this.nextPassword)
      if (result.ok) {
        this.passwordTip = `${result.message}（本地模拟）`
        this.passwordTipTone = 'success'
        this.currentPassword = ''
        this.nextPassword = ''
        this.confirmPassword = ''
      } else {
        this.passwordTip = result.message
        this.passwordTipTone = 'error'
      }
    } finally {
      this.isUpdatingPassword = false
    }
  }

  private async handleAvatarUpload() {
    if (this.isUploadingAvatar) {
      return
    }
    this.isUploadingAvatar = true
    this.avatarTip = '正在模拟上传头像...'
    this.avatarTipTone = 'normal'
    try {
      const result = await mockUploadAvatar(this.selectedAvatarUrl)
      if (result.ok && result.data) {
        this.avatarUrl = result.data.avatarUrl
        this.selectedAvatarUrl = result.data.avatarUrl
        this.avatarTip = '头像上传成功（本地模拟）。'
        this.avatarTipTone = 'success'
      } else {
        this.avatarTip = result.message
        this.avatarTipTone = 'error'
      }
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
        this.selectedAvatarUrl = pickerResult.photoUris[0]
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

  private getTipColor(tone: string): string {
    if (tone === 'error') {
      return '#E5484D'
    }
    if (tone === 'success') {
      return '#2BA471'
    }
    return '#7A8CA7'
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
  private buildProfileCard() {
    Row({ space: 14 }) {
      Image(this.avatarUrl)
        .width(56)
        .height(56)
        .objectFit(ImageFit.Cover)
        .borderRadius(28)

      Column({ space: 6 }) {
        Text(this.profileNickname)
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1F2A44')

        Text(`个性签名：${this.profileSignature}`)
          .fontSize(13)
          .fontColor('#607089')
          .maxLines(1)

        Text('练习时长 12 小时')
          .fontSize(13)
          .fontColor('#607089')
      }
      .alignItems(HorizontalAlign.Start)

      Blank()
    }
    .width('100%')
    .padding(20)
    .backgroundImage($r('app.media.background'))
    .backgroundImageSize(ImageSize.Cover)
    .backgroundBlurStyle(BlurStyle.COMPONENT_ULTRA_THICK)
    .borderRadius(28)
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
