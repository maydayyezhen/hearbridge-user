/**
 * ProfilePage 页面文件，负责页面展示与交互承接。
 */

import { User, createUser } from '../../domain/entity/User'
import { go } from '../../router/Router'
import { buildProfileAboutPath, buildProfileAccountPath, buildProfileFeedbackPath, buildProfileFavoritesPath, buildProfilePath, buildProfileSecurityPath } from '../../router/RouteBuilders'
import { getDisplayAvatarUrl, getDisplayCoverUrl, getDisplayNickname } from '../../services/user/index'
import { APP_COLORS } from '../../config/AppStyle'
import { ProfileMenuList } from './components/ProfileMenuList'
import { ProfileOverviewCard } from './components/ProfileOverviewCard'

@Component
export struct ProfilePage {
  @Prop isActive: boolean = false
  @StorageLink('user') user: User = createUser()

  private openProfileRoute(view: string): void {
    if (view === 'favorites') go(buildProfileFavoritesPath())
    else if (view === 'account') go(buildProfileAccountPath())
    else if (view === 'security') go(buildProfileSecurityPath())
    else if (view === 'feedback') go(buildProfileFeedbackPath())
    else if (view === 'aboutHearBridge') go(buildProfileAboutPath())
    else go(buildProfilePath())
  }

  build() {
    Scroll() {
      Column({ space: 14 }) {
        ProfileOverviewCard({
          profileCoverUrl: getDisplayCoverUrl(this.user),
          avatarUrl: getDisplayAvatarUrl(this.user),
          profileNickname: getDisplayNickname(this.user),
          profileSignature: this.user.signature,
          companionDays: this.user.companionDays,
          trainedQuestionCount: this.user.trainedQuestionCount
        })

        Column() {
          ProfileMenuList({
            onOpenFavorites: (): void => { this.openProfileRoute('favorites') },
            onOpenAccountProfile: (): void => { this.openProfileRoute('account') },
            onOpenAccountSecurity: (): void => { this.openProfileRoute('security') },
            onOpenHelpUpload: (): void => { this.openProfileRoute('feedback') },
            onOpenAboutHearBridge: (): void => { this.openProfileRoute('aboutHearBridge') }
          })
        }
        .width('100%')
        .padding({ left: 16, right: 16 })
      }
      .width('100%')
      .constraintSize({ minHeight: '100%' })
      .padding({ bottom: 24 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(APP_COLORS.backgroundStart)
    .scrollBar(BarState.Off)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])
  }
}
