#!/usr/bin/env bash
set -e
cd "$(dirname "$0")"

python - <<'PY'
from pathlib import Path
import re

root = Path('.')
route_paths = (root / 'router/RoutePaths.ets').read_text(encoding='utf-8')
route_builders = (root / 'router/RouteBuilders.ets').read_text(encoding='utf-8')
route_matcher = (root / 'router/RouteMatcher.ets').read_text(encoding='utf-8')
route_renderer = (root / 'router/RouteRenderer.ets').read_text(encoding='utf-8')
route_registry = (root / 'router/RouteRegistry.ets').read_text(encoding='utf-8')
route_pattern_registry = (root / 'router/RoutePatternRegistry.ets').read_text(encoding='utf-8')
stage_local = (root / 'services/training/local/TrainStageLocalService.ets').read_text(encoding='utf-8')
training_type_util = (root / 'utils/TrainingTypeUtil.ets').read_text(encoding='utf-8')
training_runtime_types = (root / 'domain/static/train/TrainingRuntimeTypes.ets').read_text(encoding='utf-8')
http_client = (root / 'api/HttpClient.ets').read_text(encoding='utf-8')
train_page_service = (root / 'services/training/TrainPageService.ets').read_text(encoding='utf-8')
train_page_controller = (root / 'pages/train/flow/TrainPageController.ets').read_text(encoding='utf-8')
train_page_route_adapter = (root / 'pages/train/flow/TrainPageRouteAdapter.ets').read_text(encoding='utf-8')
train_index = (root / 'services/training/index.ets').read_text(encoding='utf-8')
train_session_store = (root / 'storage/train-session/TrainSessionStore.ets').read_text(encoding='utf-8')
course_session_store = (root / 'storage/course/CourseSessionStore.ets').read_text(encoding='utf-8')
bootstrap_context = (root / 'services/training/local/TrainSessionBootstrapContextLocalService.ets').read_text(encoding='utf-8')
course_entity = (root / 'domain/entity/Course.ets').read_text(encoding='utf-8')
user_training_item = (root / 'domain/entity/UserTrainingItem.ets').read_text(encoding='utf-8')
repository_readme = (root / 'repository/README.md').read_text(encoding='utf-8')
router_readme = (root / 'router/README.md').read_text(encoding='utf-8')
auth_api_service = (root / 'services/auth/api/AuthApiService.ets').read_text(encoding='utf-8')
course_list_api_service = (root / 'services/course/api/CourseListApiService.ets').read_text(encoding='utf-8')
record_api_service = (root / 'services/record/api/RecordApiService.ets').read_text(encoding='utf-8')
home_api_service = (root / 'services/home/api/HomeApiService.ets').read_text(encoding='utf-8')
password_login_page = (root / 'pages/auth/PasswordLoginPage.ets').read_text(encoding='utf-8')
register_page = (root / 'pages/auth/RegisterPage.ets').read_text(encoding='utf-8')
sms_login_page = (root / 'pages/auth/SmsLoginPage.ets').read_text(encoding='utf-8')
course_list_page = (root / 'pages/train/root/CourseListPage.ets').read_text(encoding='utf-8')
auth_index = (root / 'services/auth/index.ets').read_text(encoding='utf-8')
course_index = (root / 'services/course/index.ets').read_text(encoding='utf-8')
record_index = (root / 'services/record/index.ets').read_text(encoding='utf-8')
course_preview_store = (root / 'storage/course/CoursePreviewStore.ets').read_text(encoding='utf-8')
training_item_preview_store = (root / 'storage/training-item/TrainingItemPreviewStore.ets').read_text(encoding='utf-8')
course_detail_repository = (root / 'repository/course/CourseDetailRepository.ets').read_text(encoding='utf-8')
course_detail_page_data = (root / 'services/course/model/CourseDetailPageData.ets').read_text(encoding='utf-8')
training_content_models = (root / 'domain/static/train/TrainingContentModels.ets').read_text(encoding='utf-8')
entry_ability = (root / 'entryability/EntryAbility.ets').read_text(encoding='utf-8')
auth_local_service = (root / 'services/auth/local/AuthLocalService.ets').read_text(encoding='utf-8')
user_account_api = (root / 'services/user/api/UserAccountActionService.ets').read_text(encoding='utf-8')
user_profile_api = (root / 'services/user/api/UserProfileSaveApiService.ets').read_text(encoding='utf-8')
user_index = (root / 'services/user/index.ets').read_text(encoding='utf-8')
favorites_page = (root / 'pages/profile/FavoritesPage.ets').read_text(encoding='utf-8')
account_page = (root / 'pages/profile/AccountPage.ets').read_text(encoding='utf-8')
user_favorites_query = (root / 'services/user/query/UserFavoritesPageQueryService.ets').read_text(encoding='utf-8')
profile_media_picker = (root / 'services/user/local/ProfileMediaPickerLocalService.ets').read_text(encoding='utf-8')
training_readme = (root / 'services/training/README.md').read_text(encoding='utf-8')
app_bootstrap = (root / 'services/app/local/AppBootstrapLocalService.ets').read_text(encoding='utf-8')

assert "from './RouteRegistry'" not in route_matcher, 'RouteMatcher 仍依赖 RouteRegistry'
assert 'ROUTE_PATTERNS' in route_matcher, 'RouteMatcher 未依赖纯路径模式真源'
assert 'matchRoute(path)' in route_renderer, 'RouteRenderer 未复用统一 matcher'
assert 'ROUTES.map((item) => item.path)' not in route_pattern_registry, 'RoutePatternRegistry 仍从 RouteRegistry 派生路径模式'
assert 'TrainRootPage' in route_registry and 'render: () => { TrainRootPage() }' in route_registry, 'RouteRegistry 渲染绑定异常'

base_course = re.search(r"export const COURSE_DETAIL_BASE_PATH: AppRoutePath = '([^']+)'", route_paths).group(1)
base_train = re.search(r"export const TRAIN_SESSION_BASE_PATH: AppRoutePath = '([^']+)'", route_paths).group(1)
assert f"{base_course}/demo%201" == '/course/demo%201', '课程详情路径构造预期异常'
assert f"{base_train}/courseA/itemB?stage=intro" == '/train-session/courseA/itemB?stage=intro', '训练会话路径构造预期异常'
assert 'buildCourseDetailPath' in route_builders and 'buildTrainSessionPath' in route_builders, '缺少核心路由构造器'

for token in ["case 'video'", "case 'guide'", "case 'practice'", "case 'result'", "case 'summary'", "return 'intro'"]:
    assert token in stage_local, f'normalizeStage 缺少分支: {token}'

for token in ["return item.video.length > 0 ? 'video' : 'guide'",
              "return 'guide'",
              "return 'practice'",
              "return current.currentItemIndex >= current.items.length - 1 ? 'summary' : 'intro'",
              "return item.video.length > 0 ? 'video' : 'intro'"]:
    assert token in stage_local, f'训练阶段流转缺少关键规则: {token}'

for token in ["raw === 'voice' || raw === 'speech'", "raw === 'gesture' || raw === 'sign'", "return 'gesture'"]:
    assert token in training_type_util, f'训练类型归一化缺少关键规则: {token}'

assert 'mergeDetailEntry' not in repository_readme, 'repository README 仍残留旧职责说明'
assert '替换、去重和状态回写规则仍集中在 repository' not in repository_readme, 'repository README 仍残留收藏规则旧表述'
assert 'RouteMatcher 只依赖纯路径模式数据' in router_readme, 'router README 未声明匹配与渲染解耦'
assert 'loginByPassword' in auth_index and 'registerAccount' in auth_index, 'auth 模块正式出口缺少页面入口导出'
assert 'loadCourseListState' in course_index and 'loadCourseDetailPageData' in course_index, 'course 模块正式出口缺少页面入口导出'
assert 'loadRecordPageOverview' in record_index and 'buildRecordPracticePath' in record_index, 'record 模块正式出口缺少页面入口导出'

assert 'throw new Error' not in http_client, 'requestApi 仍向页面层抛出普通网络异常'
for token in ['httpCode: 0', 'code: 0', 'ok: false']:
    assert token in http_client, f'HttpClient 缺少统一失败返回字段: {token}'

assert 'getRouteParam' not in train_page_service, 'TrainPageService 仍在直接解析 route 参数'
assert 'TrainSessionRouteInput' in train_page_service, 'TrainPageService 未接收 route input'
assert 'buildTrainPageRouteInput' in train_page_controller, 'TrainPageController 未在边界处构造 route input'
assert 'normalizeTrainStage' in train_index, 'training 模块正式出口未导出阶段规范化能力'
for token in ['const courseCode = getRouteParam', 'const itemCode = getRouteParam', 'const routeStage = normalizeTrainStage', 'createTrainSessionRouteInput(courseCode, itemCode, stage.length > 0 ? stage : routeStage)']:
    assert token in train_page_route_adapter, f'TrainPageRouteAdapter 缺少关键解析逻辑: {token}'

for token in ["export type TrainingType = 'speech' | 'gesture'", "export type PracticeMode = 'audio' | 'video'", "export type TrainItemStatus = '' | 'pending' | 'current' | 'in_progress' | 'completed'"]:
    assert token in training_runtime_types, f'训练运行时共享类型缺失: {token}'
for token in ['stage: TrainStage', 'nextStage: TrainStage']:
    assert token in bootstrap_context, f'训练启动上下文未使用显式阶段类型: {token}'
for token in ['trainingType: TrainingType', 'currentItemStatus: TrainItemStatus']:
    assert token in train_session_store, f'TrainSessionStore 未使用显式类型: {token}'
for token in ['trainingType: TrainingType']:
    assert token in course_entity, 'Course.trainingType 未使用显式类型'
for token in ['trainingType: TrainingType', 'status: TrainItemStatus', "trainingType: 'gesture'"]:
    assert token in user_training_item, f'UserTrainingItem 未使用显式类型: {token}'
assert 'status: TrainItemStatus' in course_session_store, 'CourseSessionItemSnapshot.status 未使用显式类型'
assert 'trainingType: TrainingType' in course_preview_store, 'CoursePreviewStore.trainingType 未使用显式类型'
assert 'trainingType: TrainingType' in course_detail_repository, 'CourseDetailRepository.trainingType 未使用显式类型'
for token in ['trainingType: TrainingType', 'currentItemStatus: TrainItemStatus']:
    assert token in course_detail_page_data, f'CourseDetailPageData 未使用显式类型: {token}'
assert 'status: TrainItemStatus' in training_item_preview_store, 'TrainingItemPreviewStore.status 未使用显式类型'
assert 'status: TrainItemStatus' in training_content_models, 'TrainingContentItem.status 未使用显式类型'
assert '不等同于训练流程状态' in training_content_models, 'MediaResourceItem.status 语义说明缺失'

for banned in ['courseName', 'courseIntro', 'courseCoverUrl', 'trainingTip', 'speechPartialText', 'speechStatusText', 'resultTitle', 'resultBadges']:
    assert banned not in train_session_store, f'TrainSessionRuntime 混入页面展示字段: {banned}'
for banned in ['normalizeTrainingType(', 'normalizeTrainItemStatus(']:
    assert banned not in train_session_store, f'TrainSessionStore 仍残留归一化逻辑: {banned}'
    assert banned not in course_session_store, f'CourseSessionStore 仍残留归一化逻辑: {banned}'

for text, name in [
    (auth_api_service, 'AuthApiService'),
    (course_list_api_service, 'CourseListApiService'),
    (record_api_service, 'RecordApiService'),
    (home_api_service, 'HomeApiService'),
    (password_login_page, 'PasswordLoginPage'),
    (register_page, 'RegisterPage'),
    (sms_login_page, 'SmsLoginPage'),
    (course_list_page, 'CourseListPage'),
]:
    assert 'catch' not in text, f'{name} 仍保留普通网络失败 catch'

assert 'MICROPHONE' not in entry_ability and 'requestPermissionsFromUser(' not in entry_ability, 'EntryAbility 仍在主动申请麦克风权限'
assert 'const result = await loadCurrentUserInfo()' in auth_local_service, 'AuthLocalService 未改为结果对象语义'
load_user_after_auth_section = auth_local_service.split('export async function loadUserInfoAfterAuth', 1)[1].split('export async function completeAuthSuccessFlow', 1)[0]
assert 'catch (_error)' not in load_user_after_auth_section, 'loadUserInfoAfterAuth 仍存在总 catch'
assert 'savePersistedAuthToken(context, token)' in auth_local_service, 'completeAuthSuccessFlow 缺少持久化保存'
assert 'readPersistedAuthToken(context)' in auth_local_service, 'initializeAuthAfterLaunch 缺少持久化读取'
assert 'readPersistedAuthToken(' not in user_account_api and 'clearPersistedAuthToken(' not in user_account_api, 'UserAccount api 仍直接处理 token'
assert 'readPersistedAuthToken(' not in user_profile_api and 'uploadProfileImageIfNeeded(' not in user_profile_api, 'UserProfile api 仍混入本地逻辑'
assert "from './local/UserAccountLocalService'" in user_index, 'user index 未切到本地账户服务出口'
assert "from './local/UserProfileSaveLocalService'" in user_index, 'user index 未切到本地资料保存服务出口'

assert 'repository/user/UserRepository' not in favorites_page and 'readUserState(' not in favorites_page, 'FavoritesPage 仍在直读 UserRepository'
for token in ['getFavoriteCourseDisplayItems', 'getFavoriteTrainingItemDisplayItems', "@StorageLink('user')"]:
    assert token in favorites_page, f'FavoritesPage 缺少收藏页 query/用户状态接入: {token}'
assert 'getFavoritePageHeaderView' in user_favorites_query and 'getTrainingTypeLabel' in user_favorites_query, '收藏页 query 缺少头部或类型文案组装'
assert '@ohos.file.photoAccessHelper' not in account_page and 'selectAssets(' not in account_page, 'AccountPage 仍直连系统图片选择 API'
assert 'pickSingleProfileImage' in account_page and 'selectAssets(' in profile_media_picker, '资料页图片选择未下沉到 local service'
assert "from '../../router'" not in favorites_page, 'FavoritesPage 仍通过目录 barrel 直接导入 router'
global_router_barrel_matches = []
for relative_path in ['pages', 'services', 'repository', 'storage']:
    base = root / relative_path
    for file_path in base.rglob('*.ets'):
        source = file_path.read_text(encoding='utf-8')
        if "from '../../router'" in source or "from '../router'" in source or "from '../../../router'" in source:
            global_router_barrel_matches.append(str(file_path.relative_to(root)))
assert not global_router_barrel_matches, f'业务源码仍存在目录 barrel 导入 router: {global_router_barrel_matches}'
assert '冻结扩张、只做收口' in training_readme, 'training README 未声明冻结扩张原则'
for token in ['getCoreInitializers', 'getCourseModuleInitializers', 'getTrainingModuleInitializers', 'getUiInitializers']:
    assert token in app_bootstrap, f'AppBootstrapLocalService 未按模块分组初始化: {token}'

print('行为级 smoke check 通过')
PY
