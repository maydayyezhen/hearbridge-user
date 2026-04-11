/**
 * AccountPage 页面文件，负责页面展示与交互承接。
 */

import common from '@ohos.app.ability.common'
import { goBack } from '../../router/Router'
import { buildProfilePath } from '../../router/RouteBuilders'
import { BackHeaderBar } from '../../components/BackHeaderBar'
import { DEFAULT_PROFILE_COVER_URL } from '../../config/AppConfig'
import { APP_COLORS, APP_RADIUS, APP_SHADOW } from '../../config/AppStyle'
import { User, createUser } from '../../domain/entity/User'
import { getRetryLaterMessage } from '../../utils/FeedbackCopy'
import {
  getProfileTipColor,
  pickSingleProfileImage,
  resolveDisplayAvatarUrl,
  resolveDisplayCoverUrl,
  saveAvatarProfile,
  saveCoverProfile,
  saveUserProfile
} from '../../services/user/index'
import { showGlobalToast } from '../../services/ui/index'

@Component
export struct AccountPage {
  @StorageLink('user') user: User = createUser()
  @State avatarUrl: string = ''
  @State coverUrl: string = DEFAULT_PROFILE_COVER_URL
  @State nickname: string = ''
  @State gender: string = '未设置'
  @State birthday: string = ''
  @State signature: string = ''
  @State avatarTip: string = ''
  @State avatarTipTone: string = 'normal'
  @State profileTip: string = ''
  @State profileTipTone: string = 'normal'
  @State isPickingAvatar: boolean = false
  @State isSavingAvatar: boolean = false
  @State isPickingCover: boolean = false
  @State isSavingCover: boolean = false
  @State isSavingProfile: boolean = false

  aboutToAppear(): void {
    this.syncFromUser()
  }

  private syncFromUser(): void {
    this.avatarUrl = this.user.avatarUrl
    this.coverUrl = this.user.coverUrl.length > 0 ? this.user.coverUrl : DEFAULT_PROFILE_COVER_URL
    this.nickname = this.user.nickname
    this.gender = this.user.gender === 1 ? '男' : this.user.gender === 2 ? '女' : '未设置'
    this.birthday = this.user.birthday
    this.signature = this.user.signature
  }

  private getUserGenderLabel(): string {
    return this.user.gender === 1 ? '男' : this.user.gender === 2 ? '女' : '未设置'
  }

  private getUserCoverUrl(): string {
    return this.user.coverUrl.length > 0 ? this.user.coverUrl : DEFAULT_PROFILE_COVER_URL
  }

  private hasPendingAvatarChange(): boolean {
    return this.avatarUrl !== this.user.avatarUrl
  }

  private hasPendingCoverChange(): boolean {
    return this.coverUrl !== this.getUserCoverUrl()
  }

  private hasProfileFieldChanges(): boolean {
    return this.nickname.trim() !== this.user.nickname.trim()
      || this.gender !== this.getUserGenderLabel()
      || this.birthday !== this.user.birthday
      || this.signature !== this.user.signature
  }

  private getAbilityContext(): common.UIAbilityContext {
    return this.getUIContext().getHostContext() as common.UIAbilityContext
  }

  private resolveToastTone(tone: string): 'success' | 'error' | 'info' {
    if (tone === 'success') return 'success'
    if (tone === 'error') return 'error'
    return 'info'
  }

  private async openAvatarPicker(): Promise<void> {
    if (this.isPickingAvatar) return
    this.isPickingAvatar = true
    try {
      const next = await pickSingleProfileImage(this.getAbilityContext())
      if (next.length > 0) {
        this.avatarUrl = next
        this.avatarTip = '已选择新头像，点击保存头像后生效。'
        this.avatarTipTone = 'normal'
      }
    } catch (_error) {
      this.avatarTip = getRetryLaterMessage('选择头像')
      this.avatarTipTone = 'error'
    } finally {
      this.isPickingAvatar = false
    }
  }

  private async openCoverPicker(): Promise<void> {
    if (this.isPickingCover) return
    this.isPickingCover = true
    try {
      const next = await pickSingleProfileImage(this.getAbilityContext())
      if (next.length > 0) {
        this.coverUrl = next
        this.profileTip = '已选择新头图，点击保存头图后生效。'
        this.profileTipTone = 'normal'
      }
    } catch (_error) {
      this.profileTip = getRetryLaterMessage('选择头图')
      this.profileTipTone = 'error'
    } finally {
      this.isPickingCover = false
    }
  }

  private async saveAvatar(): Promise<void> {
    if (this.isSavingAvatar) return
    this.isSavingAvatar = true
    try {
      const result = await saveAvatarProfile(this.getAbilityContext(), this.nickname, this.gender, this.birthday, this.signature, this.avatarUrl, this.coverUrl)
      this.syncFromUser()
      this.avatarTip = result.message
      this.avatarTipTone = result.tone
      if (result.message.length > 0) {
        showGlobalToast(result.message, this.resolveToastTone(result.tone))
      }
    } finally {
      this.isSavingAvatar = false
    }
  }

  private async saveCover(): Promise<void> {
    if (this.isSavingCover) return
    this.isSavingCover = true
    try {
      const result = await saveCoverProfile(this.getAbilityContext(), this.nickname, this.gender, this.birthday, this.signature, this.avatarUrl, this.coverUrl)
      this.syncFromUser()
      this.profileTip = result.message
      this.profileTipTone = result.tone
      if (result.message.length > 0) {
        showGlobalToast(result.message, this.resolveToastTone(result.tone))
      }
    } finally {
      this.isSavingCover = false
    }
  }

  private async saveProfile(): Promise<void> {
    if (this.isSavingProfile) return
    this.isSavingProfile = true
    try {
      const result = await saveUserProfile(this.getAbilityContext(), this.nickname, this.gender, this.birthday, this.signature, this.avatarUrl, this.coverUrl)
      this.syncFromUser()
      this.profileTip = result.message
      this.profileTipTone = result.tone
      if (result.message.length > 0) {
        showGlobalToast(result.message, this.resolveToastTone(result.tone))
      }
    } finally {
      this.isSavingProfile = false
    }
  }

  build() {
    Column({ space: 0 }) {
      BackHeaderBar({ title: '账号资料', onBack: () => { goBack(buildProfilePath()) } })
      Scroll() {
        Column({ space: 16 }) {
          Column({ space: 12 }) {
            Text('头像').width('100%').fontSize(18).fontWeight(FontWeight.Medium).fontColor(APP_COLORS.primaryText)
            Image(resolveDisplayAvatarUrl(this.avatarUrl).length > 0 ? resolveDisplayAvatarUrl(this.avatarUrl) : $r('app.media.startIcon'))
              .width(84).height(84).borderRadius(42).objectFit(ImageFit.Cover)
            Row({ space: 10 }) {
              Button(this.isPickingAvatar ? '读取中...' : '从相册选择')
                .layoutWeight(1)
                .height(44)
                .fontSize(14)
                .fontColor('#2E79F4')
                .backgroundColor('#F5F8FD')
                .borderRadius(16)
                .stateEffect(false)
                .enabled(!this.isPickingAvatar)
                .onClick(() => { void this.openAvatarPicker() })
              Button(this.isSavingAvatar ? '保存中...' : '保存头像')
                .width(92)
                .height(44)
                .fontSize(14)
                .fontColor(this.hasPendingAvatarChange() ? '#2E79F4' : '#9AA9BF')
                .backgroundColor('#FFFFFF')
                .borderRadius(16)
                .border({ width: 1, color: this.hasPendingAvatarChange() ? '#D7E7FF' : '#E7EDF6' })
                .stateEffect(false)
                .enabled(!this.isSavingAvatar && this.hasPendingAvatarChange())
                .onClick(() => { void this.saveAvatar() })
            }.width('100%')
            if (this.avatarTip.length > 0) {
              Text(this.avatarTip).width('100%').fontSize(12).fontColor(getProfileTipColor(this.avatarTipTone))
            }
          }
          .width('100%').padding(18).backgroundColor(APP_COLORS.surface).borderRadius(APP_RADIUS.xxl).shadow(APP_SHADOW.elevated)

          Column({ space: 12 }) {
            Text('头图').width('100%').fontSize(18).fontWeight(FontWeight.Medium).fontColor(APP_COLORS.primaryText)
            Image(resolveDisplayCoverUrl(this.coverUrl).length > 0 ? resolveDisplayCoverUrl(this.coverUrl) : $r('app.media.startIcon')).width('100%').height(140).objectFit(ImageFit.Cover).borderRadius(APP_RADIUS.lg)
            Row({ space: 10 }) {
              Button(this.isPickingCover ? '读取中...' : '从相册选择背景')
                .layoutWeight(1)
                .height(44)
                .fontSize(14)
                .fontColor('#2E79F4')
                .backgroundColor('#F5F8FD')
                .borderRadius(16)
                .stateEffect(false)
                .enabled(!this.isPickingCover)
                .onClick(() => { void this.openCoverPicker() })
              Button(this.isSavingCover ? '保存中...' : '保存头图')
                .width(92)
                .height(44)
                .fontSize(14)
                .fontColor(this.hasPendingCoverChange() ? '#2E79F4' : '#9AA9BF')
                .backgroundColor('#FFFFFF')
                .borderRadius(16)
                .border({ width: 1, color: this.hasPendingCoverChange() ? '#D7E7FF' : '#E7EDF6' })
                .stateEffect(false)
                .enabled(!this.isSavingCover && this.hasPendingCoverChange())
                .onClick(() => { void this.saveCover() })
            }.width('100%')
          }
          .width('100%').padding(18).backgroundColor(APP_COLORS.surface).borderRadius(APP_RADIUS.xxl).shadow(APP_SHADOW.elevated)

          Column({ space: 12 }) {
            Text('昵称').width('100%').fontSize(14).fontColor(APP_COLORS.primaryText)
            TextInput({ text: this.nickname, placeholder: '请输入昵称' }).onChange((v: string) => { this.nickname = v }).height(48).backgroundColor(APP_COLORS.surfaceMuted).borderRadius(APP_RADIUS.md)
            Text('性别').width('100%').fontSize(14).fontColor(APP_COLORS.primaryText)
            TextInput({ text: this.gender, placeholder: '男 / 女 / 未设置' }).onChange((v: string) => { this.gender = v }).height(48).backgroundColor(APP_COLORS.surfaceMuted).borderRadius(APP_RADIUS.md)
            Text('生日').width('100%').fontSize(14).fontColor(APP_COLORS.primaryText)
            TextInput({ text: this.birthday, placeholder: 'YYYY-MM-DD' }).onChange((v: string) => { this.birthday = v }).height(48).backgroundColor(APP_COLORS.surfaceMuted).borderRadius(APP_RADIUS.md)
            Text('个性签名').width('100%').fontSize(14).fontColor(APP_COLORS.primaryText)
            TextArea({ text: this.signature, placeholder: '写一句想让大家看到的话吧' }).onChange((v: string) => { this.signature = v }).height(110).backgroundColor(APP_COLORS.surfaceMuted).borderRadius(APP_RADIUS.md)
            if (this.profileTip.length > 0) {
              Text(this.profileTip).width('100%').fontSize(12).fontColor(getProfileTipColor(this.profileTipTone))
            }
            Button(this.isSavingProfile ? '保存中...' : (this.hasProfileFieldChanges() ? '保存资料' : '暂无变更'))
              .width('100%')
              .height(46)
              .fontSize(15)
              .fontWeight(FontWeight.Medium)
              .fontColor('#FFFFFF')
              .linearGradient({ angle: 90, colors: [['#5FA7FF', 0], ['#2E79F4', 1]] })
              .borderRadius(18)
              .stateEffect(false)
              .enabled(!this.isSavingProfile && this.hasProfileFieldChanges())
              .onClick(() => { void this.saveProfile() })
          }
          .width('100%').padding(18).backgroundColor(APP_COLORS.surface).borderRadius(APP_RADIUS.xxl).shadow(APP_SHADOW.elevated)
        }
        .width('100%')
        .justifyContent(FlexAlign.Start)
        .alignItems(HorizontalAlign.Start)
        .constraintSize({ minHeight: '100%' })
        .padding({ left: 16, right: 16, top: 6, bottom: 20 })
      }
      .width('100%').layoutWeight(1).scrollBar(BarState.Off)
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
    }
    .width('100%').height('100%')
    .justifyContent(FlexAlign.Start)
    .alignItems(HorizontalAlign.Start)
    .backgroundColor(APP_COLORS.backgroundStart)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }
}
