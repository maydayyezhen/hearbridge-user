/**
 * 路由注册表与根 Tab 定义。
 */
import { RouteItem, TabItem } from './RouteTypes'
import {
  COURSE_DETAIL_PATH,
  HOME_PATH,
  LAUNCH_PATH,
  LOGIN_PASSWORD_PATH,
  LOGIN_SMS_PATH,
  PROFILE_ABOUT_PATH,
  PROFILE_ACCOUNT_PATH,
  PROFILE_FAVORITES_PATH,
  PROFILE_FEEDBACK_PATH,
  PROFILE_PASSWORD_PATH,
  PROFILE_PATH,
  PROFILE_SECURITY_PATH,
  RECORD_PATH,
  REGISTER_PATH,
  TRAIN_PATH,
  TRAIN_SESSION_COURSE_PATH,
  TRAIN_SESSION_PATH
} from './RoutePaths'
import { LaunchLoadingPage } from '../pages/layout/LaunchLoadingPage'
import { SmsLoginPage } from '../pages/auth/SmsLoginPage'
import { PasswordLoginPage } from '../pages/auth/PasswordLoginPage'
import { RegisterPage } from '../pages/auth/RegisterPage'
import { HomePage } from '../pages/home/HomePage'
import { TrainRootPage } from '../pages/train/root/TrainRootPage'
import { RecordPage } from '../pages/record/RecordPage'
import { ProfilePage } from '../pages/profile/ProfilePage'
import { FavoritesPage } from '../pages/profile/FavoritesPage'
import { AccountPage } from '../pages/profile/AccountPage'
import { SecurityPage } from '../pages/profile/SecurityPage'
import { PasswordPage } from '../pages/profile/PasswordPage'
import { FeedbackPage } from '../pages/profile/FeedbackPage'
import { AboutPage } from '../pages/profile/AboutPage'
import { CoursePage } from '../pages/train/detail/CoursePage'
import { TrainPage } from '../pages/train/flow/TrainPage'

@Builder
function renderLaunchRoute() { LaunchLoadingPage() }
@Builder
function renderSmsLoginRoute() { SmsLoginPage() }
@Builder
function renderPasswordLoginRoute() { PasswordLoginPage() }
@Builder
function renderRegisterRoute() { RegisterPage() }
@Builder
function renderHomeRoute() { HomePage() }
@Builder
function renderTrainRootRoute() { TrainRootPage() }
@Builder
function renderRecordRoute() { RecordPage() }
@Builder
function renderProfileRoute() { ProfilePage() }
@Builder
function renderFavoritesRoute() { FavoritesPage() }
@Builder
function renderAccountRoute() { AccountPage() }
@Builder
function renderSecurityRoute() { SecurityPage() }
@Builder
function renderPasswordRoute() { PasswordPage() }
@Builder
function renderFeedbackRoute() { FeedbackPage() }
@Builder
function renderAboutRoute() { AboutPage() }
@Builder
function renderCourseDetailRoute() { CoursePage() }
@Builder
function renderTrainSessionCourseRoute() { TrainPage() }
@Builder
function renderTrainSessionRoute() { TrainPage() }

export const ROUTES: RouteItem[] = [
  { path: LAUNCH_PATH, render: renderLaunchRoute },
  { path: LOGIN_SMS_PATH, render: renderSmsLoginRoute },
  { path: LOGIN_PASSWORD_PATH, render: renderPasswordLoginRoute },
  { path: REGISTER_PATH, render: renderRegisterRoute },
  { path: HOME_PATH, render: renderHomeRoute },
  { path: TRAIN_PATH, render: renderTrainRootRoute },
  { path: RECORD_PATH, render: renderRecordRoute },
  { path: PROFILE_PATH, render: renderProfileRoute },
  { path: PROFILE_FAVORITES_PATH, render: renderFavoritesRoute },
  { path: PROFILE_ACCOUNT_PATH, render: renderAccountRoute },
  { path: PROFILE_SECURITY_PATH, render: renderSecurityRoute },
  { path: PROFILE_PASSWORD_PATH, render: renderPasswordRoute },
  { path: PROFILE_FEEDBACK_PATH, render: renderFeedbackRoute },
  { path: PROFILE_ABOUT_PATH, render: renderAboutRoute },
  { path: COURSE_DETAIL_PATH, render: renderCourseDetailRoute },
  { path: TRAIN_SESSION_COURSE_PATH, render: renderTrainSessionCourseRoute },
  { path: TRAIN_SESSION_PATH, render: renderTrainSessionRoute }
]

export const ROOT_TABS: TabItem[] = [
  { path: HOME_PATH, label: '首页', icon: $r('sys.symbol.house'), selectedIcon: $r('sys.symbol.house_fill') },
  { path: TRAIN_PATH, label: '训练', icon: $r('sys.symbol.fast'), selectedIcon: $r('sys.symbol.fast_fill') },
  { path: RECORD_PATH, label: '记录', icon: $r('sys.symbol.square_grid_2x2'), selectedIcon: $r('sys.symbol.square_fill_grid_2x2') },
  { path: PROFILE_PATH, label: '我的', icon: $r('sys.symbol.person'), selectedIcon: $r('sys.symbol.person_fill') }
]
