/**
 * 应用统一样式常量，集中收口基础视觉语言。
 */
export class AppColors {
  backgroundStart: string = '#F7FAFE'
  backgroundEnd: string = '#EEF4FB'
  surface: string = '#FFFFFF'
  surfaceSoft: string = '#F4F8FF'
  surfaceMuted: string = '#F5F8FD'
  surfaceTint: string = '#EEF5FF'
  primary: string = '#2E79F4'
  primaryDark: string = '#2563EB'
  primarySoft: string = '#E7F0FF'
  primarySoftAlt: string = '#EAF2FF'
  primaryText: string = '#1F2A44'
  secondaryText: string = '#7A8CA7'
  secondaryTextAlt: string = '#6E7E97'
  mutedText: string = '#9AACBF'
  border: string = '#E6EDF8'
  borderSoft: string = '#DDE9F8'
  shadow: string = '#1015304B'
  shadowStrong: string = '#1A15304B'
  shadowHero: string = 'rgba(46,121,244,0.10)'
  danger: string = '#E5484D'
  dangerSoft: string = '#FDECEC'
  success: string = '#2BA471'
  warningBg: string = '#FFF3D6'
  infoBg: string = '#EAF3FF'
}

export class AppRadius {
  xs: number = 10
  sm: number = 12
  md: number = 16
  lg: number = 18
  xl: number = 22
  xxl: number = 24
  xxxl: number = 28
  hero: number = 30
}

export class AppShadowItem {
  radius: number = 0
  color: string = '#00000000'
  offsetX: number = 0
  offsetY: number = 0
}

export class AppShadow {
  soft: AppShadowItem = new AppShadowItem()
  medium: AppShadowItem = new AppShadowItem()
  elevated: AppShadowItem = new AppShadowItem()
  strong: AppShadowItem = new AppShadowItem()
  bottomBar: AppShadowItem = new AppShadowItem()
  hero: AppShadowItem = new AppShadowItem()

  constructor() {
    this.soft.radius = 12
    this.soft.color = '#0D15304B'
    this.soft.offsetY = 4

    this.medium.radius = 16
    this.medium.color = '#1015304B'
    this.medium.offsetY = 6

    this.elevated.radius = 18
    this.elevated.color = '#1015304B'
    this.elevated.offsetY = 8

    this.strong.radius = 20
    this.strong.color = '#1A15304B'
    this.strong.offsetY = 10

    this.bottomBar.radius = 24
    this.bottomBar.color = '#1A15304B'
    this.bottomBar.offsetY = -4

    this.hero.radius = 16
    this.hero.color = 'rgba(46,121,244,0.10)'
    this.hero.offsetY = 6
  }
}

export class AppSpacing {
  pageX: number = 16
  pageTop: number = 6
  pageBottom: number = 20
  section: number = 18
  card: number = 18
  cardInner: number = 16
}

export const APP_COLORS: AppColors = new AppColors()
export const APP_RADIUS: AppRadius = new AppRadius()
export const APP_SHADOW: AppShadow = new AppShadow()
export const APP_SPACING: AppSpacing = new AppSpacing()
