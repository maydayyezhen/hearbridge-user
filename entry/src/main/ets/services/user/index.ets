/**
 * user 模块正式出口。
 */
export {
  FavoriteToggleActionResult,
  isCourseFavoritedInUser,
  isTrainingItemFavoritedInUser,
  readFavoriteCourseCodesFromUser,
  toggleCourseFavoriteAction,
  toggleTrainingItemFavoriteAction
} from './local/UserFavoriteLocalService'

export { UserActionResult } from './api/UserActionResult'

export {
  changePassword,
  logoutCurrentUser
} from './local/UserAccountLocalService'

export {
  saveAvatarProfile,
  saveCoverProfile,
  saveUserProfile
} from './local/UserProfileSaveLocalService'

export { pickSingleProfileImage } from './local/ProfileMediaPickerLocalService'

export {
  getDisplayAvatarUrl,
  getDisplayCoverUrl,
  getDisplayNickname,
  getProfileTipColor,
  resolveDisplayAvatarUrl,
  resolveDisplayCoverUrl
} from './local/UserProfileLocalService'

export * from './model/FavoriteDisplayItem'

export {
  getFavoriteCourseDisplayItems,
  getFavoritePageHeaderView,
  getFavoriteTrainingItemDisplayItems,
  resolveFavoriteItemCourseCode,
  getTrainingTypeLabel
} from './query/UserFavoritesPageQueryService'
