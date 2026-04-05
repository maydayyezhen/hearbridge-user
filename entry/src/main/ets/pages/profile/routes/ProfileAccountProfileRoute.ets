import common from '@ohos.app.ability.common'
import photoAccessHelper from '@ohos.file.photoAccessHelper'
import { readToken } from '../../../api/AuthStorage'
import { updateUserProfile } from '../../../api/AuthApi'
import { showGlobalToast } from '../../../api/GlobalToast'
import { uploadFileToServer } from '../../../api/FileUploadApi'
import { DEFAULT_PROFILE_COVER_URL } from '../../../config/AppConfig'

@Component
export struct ProfileAccountProfileRoute {
  @Prop apiBaseUrl: string = ''
  @Prop avatarUrl: string = ''
  @Prop backendNickname: string = ''
  @Prop backendSignature: string = ''
  @Prop backendCoverUrl: string = ''
  @Prop backendGender: number = 0
  @Prop backendBirthday: string = ''
  @State selectedAvatarUrl: string = ''
  @State currentAvatarUrl: string = ''
  @State profileCoverUrl: string = DEFAULT_PROFILE_COVER_URL
  @State profileNickname: string = '桥桥'
  @State profileGender: string = '未设置'
  @State profileBirthday: string = ''
  @State profileSignature: string = ''
  @State avatarTip: string = ''
  @State avatarTipTone: string = 'normal'
  @State profileTip: string = ''
  @State profileTipTone: string = 'normal'
  @State isUploadingAvatar: boolean = false
  @State isPickingAvatar: boolean = false
  @State isPickingProfileCover: boolean = false
  @State isSavingCover: boolean = false
  @State isSavingProfile: boolean = false
  @State baselineNickname: string = ''
  @State baselineGender: string = ''
  @State baselineBirthday: string = ''
  @State baselineSignature: string = ''
  @State baselineCoverUrl: string = ''
  @State baselineAvatarUrl: string = ''
  onProfileUpdated: (nickname: string, signature: string, coverUrl: string, gender: number, birthday: string, avatarUrl: string) => void =
    (_nickname: string, _signature: string, _coverUrl: string, _gender: number, _birthday: string, _avatarUrl: string) => {}

  aboutToAppear() {
    this.syncProfileFromBackend()
    this.markProfileBaseline()
  }

  build() {
    Column({ space: 18 }) {
      Column({ space: 14 }) {
        Text('头像')
          .width('100%')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor('#1F2A44')

        Row({ space: 14 }) {
          Image(this.selectedAvatarUrl.length > 0 ? this.selectedAvatarUrl : this.currentAvatarUrl)
            .width(72)
            .height(72)
            .objectFit(ImageFit.Cover)
            .borderRadius(36)

          Blank()
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

          Button(this.isUploadingAvatar ? '保存中...' : '保存头像')
            .width(92)
            .height(44)
            .fontSize(14)
            .fontColor(this.hasPendingAvatarChange() ? '#2E79F4' : '#9AA9BF')
            .backgroundColor('#FFFFFF')
            .borderRadius(16)
            .border({ width: 1, color: this.hasPendingAvatarChange() ? '#D7E7FF' : '#E7EDF6' })
            .enabled(!this.isUploadingAvatar && this.hasPendingAvatarChange())
            .onClick(() => {
              this.handleAvatarUpload()
            })
        }
        .width('100%')

        if (this.avatarTip.length > 0) {
          Text(this.avatarTip)
            .width('100%')
            .fontSize(12)
            .fontColor(this.getTipColor(this.avatarTipTone))
        }
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

        Row({ space: 10 }) {
          Button(this.isPickingProfileCover ? '读取中...' : '从相册选择背景')
            .layoutWeight(1)
            .height(44)
            .fontSize(14)
            .fontColor('#2E79F4')
            .backgroundColor('#F5F8FD')
            .borderRadius(16)
            .enabled(!this.isPickingProfileCover)
            .onClick(() => {
              this.openCoverPicker()
            })

          Button(this.isSavingCover ? '保存中...' : '保存头图')
            .width(92)
            .height(44)
            .fontSize(14)
            .fontColor(this.hasPendingCoverChange() ? '#2E79F4' : '#9AA9BF')
            .backgroundColor('#FFFFFF')
            .borderRadius(16)
            .border({ width: 1, color: this.hasPendingCoverChange() ? '#D7E7FF' : '#E7EDF6' })
            .enabled(!this.isSavingCover && this.hasPendingCoverChange())
            .onClick(() => {
              this.handleCoverSave()
            })
        }
        .width('100%')

        if (this.profileTip.length > 0) {
          Text(this.profileTip)
            .width('100%')
            .fontSize(12)
            .fontColor(this.getTipColor(this.profileTipTone))
        }
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
            this.buildGenderChip('未设置')
          }
          .width('100%')
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)

        this.buildBirthdayField()

        Column({ space: 8 }) {
          Text('个性签名')
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor('#1F2A44')

          TextInput({ text: this.profileSignature, placeholder: '说点什么吧...' })
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

        Button(this.isSavingProfile ? '保存中...' : (this.hasProfileFieldChanges() ? '保存资料' : '暂无变更'))
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
          .enabled(!this.isSavingProfile && this.hasProfileFieldChanges())
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

  private syncProfileFromBackend() {
    this.currentAvatarUrl = this.avatarUrl
    this.selectedAvatarUrl = this.avatarUrl
    this.profileNickname = this.backendNickname.length > 0 ? this.backendNickname : this.profileNickname
    this.profileSignature = this.backendSignature.length > 0 ? this.backendSignature : this.profileSignature
    this.profileCoverUrl = this.backendCoverUrl.length > 0 ? this.backendCoverUrl : DEFAULT_PROFILE_COVER_URL
    this.profileBirthday = this.backendBirthday ?? ''
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
    this.baselineAvatarUrl = this.selectedAvatarUrl.length > 0 ? this.selectedAvatarUrl : this.currentAvatarUrl
  }

  private hasProfileFieldChanges(): boolean {
    return this.baselineNickname !== this.profileNickname.trim() ||
      this.baselineGender !== this.profileGender ||
      this.baselineBirthday !== this.profileBirthday ||
      this.baselineSignature !== this.profileSignature
  }

  private hasPendingAvatarChange(): boolean {
    const currentAvatar = this.selectedAvatarUrl.length > 0 ? this.selectedAvatarUrl : this.currentAvatarUrl
    return this.baselineAvatarUrl !== currentAvatar
  }

  private hasPendingCoverChange(): boolean {
    return this.baselineCoverUrl !== this.profileCoverUrl
  }

  private openBirthdayDialog() {
    const currentYear = new Date().getFullYear()
    let selectedDate = new Date('2000-01-01T00:00:00')
    if (this.profileBirthday.length > 0 && this.isValidBirthday(this.profileBirthday)) {
      selectedDate = new Date(`${this.profileBirthday}T00:00:00`)
    }
    try {
      this.getUIContext().showDatePickerDialog({
        start: new Date('1900-01-01T00:00:00'),
        end: new Date(`${currentYear}-12-31T00:00:00`),
        selected: selectedDate,
        onDateAccept: (value: Date) => {
          const year = value.getFullYear()
          const month = value.getMonth() + 1
          const day = value.getDate()
          const monthText = month < 10 ? `0${month}` : `${month}`
          const dayText = day < 10 ? `0${day}` : `${day}`
          this.profileBirthday = `${year}-${monthText}-${dayText}`
        }
      })
    } catch (_error) {
      showGlobalToast('暂时无法打开日期选择器。', 'error')
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

  private isValidBirthday(value: string): boolean {
    if (!/^\d{4}-\d{2}-\d{2}$/.test(value)) {
      return false
    }
    const parts = value.split('-')
    if (parts.length !== 3) {
      return false
    }
    const year = Number(parts[0])
    const month = Number(parts[1])
    const day = Number(parts[2])
    if (year < 1900 || month < 1 || month > 12 || day < 1 || day > 31) {
      return false
    }
    const date = new Date(year, month - 1, day)
    return date.getFullYear() === year && date.getMonth() === month - 1 && date.getDate() === day
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
      if (this.profileBirthday.length > 0 && !this.isValidBirthday(this.profileBirthday)) {
        return '生日格式错误，请选择有效日期。'
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

  private async handleSaveProfile() {
    if (this.isSavingProfile) {
      return
    }
    if (!this.hasProfileFieldChanges()) {
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
    if (this.profileBirthday.length > 0 && !this.isValidBirthday(this.profileBirthday)) {
      this.profileTip = '生日格式错误，请使用有效日期（YYYY-MM-DD）。'
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
        showGlobalToast(this.profileTip, 'error')
        return
      }

      const result = await updateUserProfile(this.apiBaseUrl, token, {
        nickname,
        gender: this.resolveGenderCode(),
        birthday: this.profileBirthday.length > 0 ? this.profileBirthday : null,
        signature: this.profileSignature,
        avatarUrl: this.currentAvatarUrl,
        coverUrl: this.profileCoverUrl
      })
      if (!result.ok || !result.data) {
        result.message = this.resolveProfileUpdateError(result.code, result.message)
      }
      if (!result.ok || !result.data) {
        this.profileTip = result.message.length > 0 ? result.message : '保存失败，请稍后重试。'
        this.profileTipTone = 'error'
        showGlobalToast(this.profileTip, 'error')
        return
      }

      this.currentAvatarUrl = result.data.profile.avatarUrl
      this.selectedAvatarUrl = result.data.profile.avatarUrl
      this.profileNickname = result.data.profile.nickname
      this.profileSignature = result.data.profile.signature
      this.profileBirthday = result.data.profile.birthday ?? ''
      this.profileCoverUrl = result.data.profile.coverUrl
      this.profileGender = result.data.profile.gender === 1 ? '男' : (result.data.profile.gender === 2 ? '女' : '未设置')
      this.markProfileBaseline()
      this.onProfileUpdated(
        result.data.profile.nickname,
        result.data.profile.signature,
        result.data.profile.coverUrl,
        result.data.profile.gender,
        result.data.profile.birthday ?? '',
        result.data.profile.avatarUrl
      )
      this.profileTip = '资料已保存。'
      this.profileTipTone = 'success'
      showGlobalToast('资料已保存。', 'success')
    } catch (_error) {
      this.profileTip = '保存失败，请检查网络后重试。'
      this.profileTipTone = 'error'
      showGlobalToast(this.profileTip, 'error')
    } finally {
      this.isSavingProfile = false
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
      const token = await readToken(this.getAbilityContext())
      if (token.length === 0) {
        this.avatarTip = '登录状态已失效，请重新登录。'
        this.avatarTipTone = 'error'
        showGlobalToast(this.avatarTip, 'error')
        return
      }
      const uploadedUrl = await this.uploadProfileImageIfNeeded(token, this.selectedAvatarUrl, 'avatar.jpg')
      const profileResult = await updateUserProfile(this.apiBaseUrl, token, {
        nickname: this.profileNickname.trim(),
        gender: this.resolveGenderCode(),
        birthday: this.profileBirthday.length > 0 ? this.profileBirthday : null,
        signature: this.profileSignature,
        avatarUrl: uploadedUrl,
        coverUrl: this.profileCoverUrl
      })
      if (!profileResult.ok || !profileResult.data) {
        throw new Error(profileResult.message.length > 0 ? profileResult.message : '头像保存失败，请稍后重试。')
      }
      this.currentAvatarUrl = profileResult.data.profile.avatarUrl
      this.selectedAvatarUrl = profileResult.data.profile.avatarUrl
      this.markProfileBaseline()
      this.onProfileUpdated(
        profileResult.data.profile.nickname,
        profileResult.data.profile.signature,
        profileResult.data.profile.coverUrl,
        profileResult.data.profile.gender,
        profileResult.data.profile.birthday ?? '',
        profileResult.data.profile.avatarUrl
      )
      this.avatarTip = '头像已保存。'
      this.avatarTipTone = 'success'
      showGlobalToast('头像已保存。', 'success')
    } catch (error) {
      this.avatarTip = error instanceof Error ? error.message : '头像上传失败，请稍后重试。'
      this.avatarTipTone = 'error'
      showGlobalToast(this.avatarTip, 'error')
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
      const photoPicker = new photoAccessHelper.PhotoViewPicker()
      const pickerOptions = new photoAccessHelper.PhotoSelectOptions()
      pickerOptions.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE
      pickerOptions.maxSelectNumber = 1
      const pickerResult = await photoPicker.select(pickerOptions)
      if (pickerResult.photoUris.length > 0) {
        this.selectedAvatarUrl = this.normalizeUri(pickerResult.photoUris[0])
        this.avatarTip = '已选择图片，点击“保存头像”完成更新。'
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
      const photoPicker = new photoAccessHelper.PhotoViewPicker()
      const pickerOptions = new photoAccessHelper.PhotoSelectOptions()
      pickerOptions.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE
      pickerOptions.maxSelectNumber = 1
      const pickerResult = await photoPicker.select(pickerOptions)
      if (pickerResult.photoUris.length > 0) {
        this.profileCoverUrl = this.normalizeUri(pickerResult.photoUris[0])
        this.profileTip = '已选择图片，点击“保存头图”完成更新。'
        this.profileTipTone = 'success'
      }
    } catch (_error) {
      this.profileTip = '当前环境不支持相册读取，请在真机重试。'
      this.profileTipTone = 'error'
    } finally {
      this.isPickingProfileCover = false
    }
  }

  private async handleCoverSave() {
    if (this.isSavingCover) {
      return
    }
    if (!this.hasPendingCoverChange()) {
      this.profileTip = '当前没有需要保存的头图。'
      this.profileTipTone = 'normal'
      return
    }
    this.isSavingCover = true
    this.profileTip = '正在保存头图...'
    this.profileTipTone = 'normal'
    try {
      const token = await readToken(this.getAbilityContext())
      if (token.length === 0) {
        this.profileTip = '登录状态已失效，请重新登录。'
        this.profileTipTone = 'error'
        showGlobalToast(this.profileTip, 'error')
        return
      }
      const nextCoverUrl = await this.uploadProfileImageIfNeeded(token, this.profileCoverUrl, 'cover.jpg')
      const profileResult = await updateUserProfile(this.apiBaseUrl, token, {
        nickname: this.profileNickname.trim(),
        gender: this.resolveGenderCode(),
        birthday: this.profileBirthday.length > 0 ? this.profileBirthday : null,
        signature: this.profileSignature,
        avatarUrl: this.currentAvatarUrl,
        coverUrl: nextCoverUrl
      })
      if (!profileResult.ok || !profileResult.data) {
        throw new Error(profileResult.message.length > 0 ? profileResult.message : '头图保存失败，请稍后重试。')
      }
      this.profileCoverUrl = profileResult.data.profile.coverUrl
      this.markProfileBaseline()
      this.onProfileUpdated(
        profileResult.data.profile.nickname,
        profileResult.data.profile.signature,
        profileResult.data.profile.coverUrl,
        profileResult.data.profile.gender,
        profileResult.data.profile.birthday ?? '',
        profileResult.data.profile.avatarUrl
      )
      this.profileTip = '头图已保存。'
      this.profileTipTone = 'success'
      showGlobalToast('头图已保存。', 'success')
    } catch (error) {
      this.profileTip = error instanceof Error ? error.message : '头图保存失败，请稍后重试。'
      this.profileTipTone = 'error'
      showGlobalToast(this.profileTip, 'error')
    } finally {
      this.isSavingCover = false
    }
  }

  private getTipColor(tone: string): string {
    if (tone === 'success') {
      return '#2BA471'
    }
    if (tone === 'error') {
      return '#E5484D'
    }
    return '#7A8CA7'
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
  private buildBirthdayField() {
    Column({ space: 8 }) {
      Text('生日')
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .fontColor('#1F2A44')

      Row({ space: 10 }) {
        Text(this.profileBirthday.length > 0 ? this.profileBirthday : '请选择生日')
          .layoutWeight(1)
          .fontSize(14)
          .fontColor(this.profileBirthday.length > 0 ? '#1F2A44' : '#8A9DB7')

        SymbolGlyph($r('sys.symbol.chevron_forward'))
          .fontSize(14)
          .fontColor(['#9BAAC0'])
      }
      .width('100%')
      .height(52)
      .padding({ left: 15, right: 15 })
      .backgroundColor('#F7FAFE')
      .borderRadius(16)
      .border({ width: 1, color: '#C8D8EA' })
      .onClick(() => {
        this.openBirthdayDialog()
      })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
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
        .height(52)
        .fontSize(14)
        .backgroundColor('#F7FAFE')
        .borderRadius(16)
        .padding({ left: 14, right: 14 })
        .onChange((next: string) => {
          onChangeAction(next)
        })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }
}
