import { mockUpdatePassword, mockUploadAvatar } from '../api/ProfileApi'
import photoAccessHelper from '@ohos.file.photoAccessHelper'

@Component
export struct ProfilePage {
  @Prop currentView: string = 'main'
  @Link avatarUrl: string
  @Prop selectedGoal: string = '日常交流'
  @Prop selectedTheme: string = '海盐蓝'
  @Prop notificationsEnabled: boolean = true
  @Prop vibrationEnabled: boolean = false
  @State selectedAvatarUrl: string = 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?auto=format&fit=crop&w=400&q=80'
  @State avatarTip: string = '可选择预设头像，或点击上传按钮模拟提交。'
  @State avatarTipTone: string = 'normal'
  @State currentPassword: string = ''
  @State nextPassword: string = ''
  @State confirmPassword: string = ''
  @State passwordTip: string = '密码需包含 8 位以上字符，建议包含字母和数字。'
  @State passwordTipTone: string = 'normal'
  @State isUploadingAvatar: boolean = false
  @State isUpdatingPassword: boolean = false
  @State isPickingAvatar: boolean = false
  onGoalChange: (goal: string) => void = () => {}
  onThemeChange: (theme: string) => void = () => {}
  onNotificationsChange: (value: boolean) => void = () => {}
  onVibrationChange: (value: boolean) => void = () => {}
  onOpenSettings: () => void = () => {}
  onCloseSettings: () => void = () => {}
  onOpenAccountSecurity: () => void = () => {}
  onBackToSettings: () => void = () => {}

  private readonly goals: string[] = ['日常交流', '唇读提升', '情绪表达']
  private readonly themes: string[] = ['海盐蓝', '薄荷青', '晨光橙']
  private readonly avatarOptions: string[] = [
    'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?auto=format&fit=crop&w=400&q=80',
    'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=400&q=80',
    'https://images.unsplash.com/photo-1517841905240-472988babdf9?auto=format&fit=crop&w=400&q=80'
  ]
  build() {
    Column({ space: 18 }) {
      if (this.currentView === 'accountSecurity') {
        this.buildAccountSecurity()
      } else if (this.currentView === 'settings') {
        this.buildSettingsCenter()
      } else {
        this.buildProfileOverview()
      }
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 6, bottom: 24 })
  }

  aboutToAppear() {
    this.selectedAvatarUrl = this.avatarUrl
  }

  @Builder
  private buildProfileOverview() {
    Column({ space: 18 }) {
      this.buildProfileCard()
      this.buildPreferenceCard()
      this.buildSettingList()
    }
    .width('100%')
  }

  @Builder
  private buildSettingsCenter() {
    Column({ space: 18 }) {
      this.buildPageHeader('设置中心', '管理账号、提醒和训练偏好', () => {
        this.onCloseSettings()
      })

      Column({ space: 12 }) {
        this.buildSettingsRow($r('sys.symbol.person'), '账号与安全', '头像、密码与隐私管理', () => {
          this.onOpenAccountSecurity()
        })
        this.buildSettingsRow($r('sys.symbol.bell'), '提醒设置', this.notificationsEnabled ? '训练提醒已开启' : '训练提醒已关闭')
        this.buildSettingsRow($r('sys.symbol.square_grid_2x2'), '训练记录同步', '最近同步于今天 09:24')
      }
      .width('100%')
      .padding(18)
      .backgroundColor('#FFFFFF')
      .borderRadius(28)
      .shadow({ radius: 18, color: '#15304B10', offsetX: 0, offsetY: 8 })

      Column({ space: 14 }) {
        Text('训练偏好')
          .width('100%')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor('#1F2A44')

        this.buildSectionTitle('训练目标')
        Row({ space: 10 }) {
          ForEach(this.goals, (goal: string) => {
            this.buildChip(goal, this.selectedGoal === goal, () => {
              this.onGoalChange(goal)
            })
          }, (goal: string) => goal)
        }
        .width('100%')

        this.buildSectionTitle('视觉主题')
        Row({ space: 10 }) {
          ForEach(this.themes, (theme: string) => {
            this.buildChip(theme, this.selectedTheme === theme, () => {
              this.onThemeChange(theme)
            })
          }, (theme: string) => theme)
        }
        .width('100%')

        this.buildToggleRow('训练提醒', this.notificationsEnabled, (value: boolean) => {
          this.onNotificationsChange(value)
        })

        this.buildToggleRow('触感反馈', this.vibrationEnabled, (value: boolean) => {
          this.onVibrationChange(value)
        })
      }
      .width('100%')
      .padding(18)
      .backgroundColor('#FFFFFF')
      .borderRadius(28)
      .shadow({ radius: 18, color: '#15304B10', offsetX: 0, offsetY: 8 })

      Column({ space: 12 }) {
        this.buildSettingsRow($r('sys.symbol.questionmark_circle'), '帮助与反馈', '查看常见问题并提交建议')
        this.buildSettingsRow($r('sys.symbol.info_circle'), '关于 HearBridge', '版本 1.0.0')
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
      this.buildPageHeader('账号与安全', '管理头像、密码和账号安全信息', () => {
        this.onBackToSettings()
      })

      Column({ space: 16 }) {
        Text('更换头像')
          .width('100%')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor('#1F2A44')

        Row({ space: 14 }) {
          Image(this.selectedAvatarUrl)
            .width(72)
            .height(72)
            .objectFit(ImageFit.Cover)
            .borderRadius(36)

          Column({ space: 6 }) {
            Text(this.selectedAvatarUrl === this.avatarUrl ? '当前头像' : '待上传头像预览')
              .fontSize(15)
              .fontWeight(FontWeight.Medium)
              .fontColor('#1F2A44')

            Text(this.avatarTip)
              .fontSize(12)
              .fontColor(this.getTipColor(this.avatarTipTone))
              .maxLines(2)
          }
          .alignItems(HorizontalAlign.Start)

          Blank()

          if (this.selectedAvatarUrl !== this.avatarUrl) {
            Text('待上传')
              .fontSize(11)
              .fontColor('#2E79F4')
              .padding({ left: 10, right: 10, top: 6, bottom: 6 })
              .backgroundColor('#EEF5FF')
              .borderRadius(12)
          }
        }
        .width('100%')

        Row({ space: 12 }) {
          ForEach(this.avatarOptions, (avatar: string) => {
            this.buildAvatarOption(avatar)
          }, (avatar: string) => avatar)
        }
        .width('100%')

        this.buildSectionTitle('本地相册与预设头像')

        Button(this.isPickingAvatar ? '读取中...' : '从本地相册选择')
          .width('100%')
          .height(44)
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor('#2E79F4')
          .backgroundColor('#F5F8FD')
          .borderRadius(18)
          .enabled(!this.isPickingAvatar)
          .onClick(() => {
            this.openPhotoPicker()
          })

        Button(this.isUploadingAvatar ? '上传中...' : '上传所选头像')
          .width('100%')
          .height(46)
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor('#2E79F4')
          .backgroundColor('#EEF5FF')
          .borderRadius(18)
          .enabled(!this.isUploadingAvatar)
          .onClick(() => {
            this.handleAvatarUpload()
          })
      }
      .width('100%')
      .padding(18)
      .backgroundColor('#FFFFFF')
      .borderRadius(28)
      .shadow({ radius: 18, color: '#15304B10', offsetX: 0, offsetY: 8 })

      Column({ space: 14 }) {
        Text('更换密码')
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
        this.avatarTip = '头像上传成功，当前为本地模拟结果。'
        this.avatarTipTone = 'success'
      } else {
        this.avatarTip = result.message
        this.avatarTipTone = 'error'
      }
    } finally {
      this.isUploadingAvatar = false
    }
  }

  private async submitPasswordChange() {
    if (this.isUpdatingPassword) {
      return
    }

    this.isUpdatingPassword = true
    this.passwordTip = '正在模拟提交密码修改...'
    this.passwordTipTone = 'normal'

    try {
      const result = await mockUpdatePassword(this.currentPassword, this.nextPassword)
      if (result.ok) {
        this.passwordTip = `${result.message}，当前为本地模拟结果。`
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
        this.avatarTip = '已从本地相册选择图片，预览已更新，点击上传所选头像完成提交。'
        this.avatarTipTone = 'normal'
      } else {
        this.avatarTip = '你还没有选择图片。'
        this.avatarTipTone = 'error'
      }
    } catch (_error) {
      this.avatarTip = '本地相册读取失败，预览器中可能不支持，请在真机上重试。'
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
        Row() {
        }
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
        Text('筱暄')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1F2A44')

        Text(`学习目标：${this.selectedGoal}`)
          .fontSize(13)
          .fontColor('#607089')

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
  private buildPreferenceCard() {
    Column({ space: 14 }) {
      Text('练习偏好')
        .width('100%')
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .fontColor('#1F2A44')

      this.buildSectionTitle('训练目标')
      Row({ space: 10 }) {
        ForEach(this.goals, (goal: string) => {
          this.buildChip(goal, this.selectedGoal === goal, () => {
            this.onGoalChange(goal)
          })
        }, (goal: string) => goal)
      }
      .width('100%')

      this.buildSectionTitle('视觉主题')
      Row({ space: 10 }) {
        ForEach(this.themes, (theme: string) => {
          this.buildChip(theme, this.selectedTheme === theme, () => {
            this.onThemeChange(theme)
          })
        }, (theme: string) => theme)
      }
      .width('100%')

      this.buildToggleRow('训练提醒', this.notificationsEnabled, (value: boolean) => {
        this.onNotificationsChange(value)
      })

      this.buildToggleRow('触感反馈', this.vibrationEnabled, (value: boolean) => {
        this.onVibrationChange(value)
      })
    }
    .width('100%')
    .padding(18)
    .backgroundColor('#FFFFFF')
    .borderRadius(28)
    .shadow({ radius: 18, color: '#15304B10', offsetX: 0, offsetY: 8 })
  }

  @Builder
  private buildSettingList() {
    Column({ space: 10 }) {
      this.buildMenuRow($r('sys.symbol.person'), '我的勋章')
      this.buildMenuRow($r('sys.symbol.square_grid_2x2'), '历史记录')
      this.buildMenuRow($r('sys.symbol.puzzle'), '设置中心', () => {
        this.onOpenSettings()
      })
    }
    .width('100%')
  }

  @Builder
  private buildSectionTitle(label: string) {
    Text(label)
      .width('100%')
      .fontSize(13)
      .fontColor('#7A8CA7')
  }

  @Builder
  private buildChip(label: string, active: boolean, onClickAction: () => void) {
    Text(label)
      .fontSize(13)
      .fontWeight(active ? FontWeight.Medium : FontWeight.Regular)
      .fontColor(active ? '#2563EB' : '#607089')
      .padding({ left: 14, right: 14, top: 10, bottom: 10 })
      .backgroundColor(active ? '#E7F0FF' : '#F5F8FD')
      .borderRadius(16)
      .onClick(() => {
        onClickAction()
      })
  }

  @Builder
  private buildToggleRow(label: string, value: boolean, onChangeAction: (value: boolean) => void) {
    Row() {
      Text(label)
        .fontSize(15)
        .fontColor('#1F2A44')

      Blank()

      Toggle({ type: ToggleType.Switch, isOn: value })
        .selectedColor('#2E79F4')
        .switchPointColor('#FFFFFF')
        .onChange((nextValue: boolean) => {
          onChangeAction(nextValue)
        })
    }
    .width('100%')
    .padding(14)
    .backgroundColor('#F7FAFE')
    .borderRadius(20)
  }

  @Builder
  private buildMenuRow(icon: Resource, label: string, onClickAction?: () => void) {
    Row({ space: 12 }) {
      Stack({ alignContent: Alignment.Center }) {
        Row() {
        }
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
  private buildSettingsRow(icon: Resource, title: string, subtitle: string, onClickAction?: () => void) {
    Row({ space: 12 }) {
      Stack({ alignContent: Alignment.Center }) {
        Row() {
        }
        .width(32)
        .height(32)
        .backgroundColor('#EEF4FF')
        .borderRadius(16)

        SymbolGlyph(icon)
          .fontSize(16)
          .fontColor(['#2E79F4'])
      }
      .width(32)
      .height(32)

      Column({ space: 4 }) {
        Text(title)
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor('#1F2A44')

        Text(subtitle)
          .fontSize(12)
          .fontColor('#7A8CA7')
          .maxLines(1)
      }
      .alignItems(HorizontalAlign.Start)

      Blank()

      SymbolGlyph($r('sys.symbol.chevron_forward'))
        .fontSize(15)
        .fontColor(['#95A7C0'])
    }
    .width('100%')
    .padding(14)
    .backgroundColor('#F7FAFE')
    .borderRadius(20)
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
          Row() {
          }
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
      this.avatarTip = '已选择新头像，预览已更新，点击上传所选头像完成模拟提交。'
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
