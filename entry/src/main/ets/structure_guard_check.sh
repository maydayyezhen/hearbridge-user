#!/usr/bin/env bash
set -e
cd "$(dirname "$0")"

echo "[1] TrainPageService 不再直接解析 routePath"
! rg -n --glob 'TrainPageService.ets' 'getRouteParam\(|routePath' services/training || (echo "TrainPageService 仍在直接解析 routePath" && exit 1)

echo "[2] 训练路由解析收口在 TrainPageRouteAdapter"
rg -n --glob 'TrainPageRouteAdapter.ets' 'getRouteParam\(' pages/train/flow >/dev/null || (echo "TrainPageRouteAdapter 缺少 route 参数解析" && exit 1)

echo "[3] RouteMatcher 只依赖纯路径模式真源"
! rg -n --glob 'RouteMatcher.ets' "from './RouteRegistry'|ROUTES\.map\(" router || (echo "RouteMatcher 仍依赖 RouteRegistry" && exit 1)
rg -n --glob 'RouteMatcher.ets' 'ROUTE_PATTERNS' router >/dev/null || (echo "RouteMatcher 未使用 ROUTE_PATTERNS" && exit 1)

echo "[4] requestApi 不再向上抛出普通网络异常"
! rg -n 'throw new Error' api/HttpClient.ets || (echo "requestApi 仍在抛出普通网络异常" && exit 1)
rg -n 'ok: false' api/HttpClient.ets >/dev/null || (echo "requestApi 缺少统一失败返回" && exit 1)

echo "[5] 训练模块正式出口保持统一"
rg -n 'export \{' services/training/index.ets >/dev/null || (echo "training 模块 index 缺少正式出口" && exit 1)
rg -n 'normalizeTrainStage' services/training/index.ets >/dev/null || (echo "training 模块 index 未导出阶段规范化能力" && exit 1)

echo "[6] TrainSessionStore 不得混入课程/结果展示字段"
! rg -n --glob 'TrainSessionStore.ets' 'courseName|courseIntro|courseCoverUrl|trainingTip|speechPartialText|speechStatusText|resultTitle|resultBadges' storage/train-session || (echo "TrainSessionRuntime 混入了页面展示字段" && exit 1)

echo "[7] api 不得反向依赖 repository/services/pages/storage"
! rg -n --glob '*.ets' "repository/|services/|pages/|storage/" api || (echo "api 发生反向依赖" && exit 1)

echo "[8] TrainSessionStore 与 CourseSessionStore 不得引入 TrainingTypeUtil"
! rg -n --glob 'TrainSessionStore.ets' 'TrainingTypeUtil' storage/train-session || (echo "TrainSessionStore 回退引入归一化工具" && exit 1)
! rg -n --glob 'CourseSessionStore.ets' 'TrainingTypeUtil' storage/course || (echo "CourseSessionStore 回退引入归一化工具" && exit 1)

echo "[9] pages 不得直连 auth/course/record 零散 PageService"
! rg -n --glob '*.ets' 'services/auth/AuthPageService|services/course/CourseListPageService|services/course/CourseDetailPageService|services/record/RecordPageService' pages || (echo "pages 仍直连零散 PageService" && exit 1)

echo "[10] 训练链路公共签名不再扩散 Object"
! rg -n --glob '*.ets' 'context: Object|contextObj: Object|\(\) => Object|getAbilityContext\?: \(\) => Object' services/training pages/train/flow || (echo "训练链路仍存在 Object 弱类型签名" && exit 1)

echo "[11] route input 与 bootstrap context 不得回退成裸字符串 stage"
! rg -n --glob 'TrainSessionBootstrapContextLocalService.ets' 'stage: string|nextStage: string' services/training/local || (echo "训练 route input / bootstrap context 回退成了 string stage" && exit 1)

echo "[12] 纯请求 service 不得回流旧式 catch"
! rg -n 'catch' services/auth/api/AuthApiService.ets services/course/api/CourseListApiService.ets services/record/api/RecordApiService.ets services/home/api/HomeApiService.ets || (echo "纯请求 service 仍存在历史 catch" && exit 1)

echo "[13] 直接承接纯请求 service 的页面不再保留普通网络失败 catch"
! rg -n 'catch' pages/auth/PasswordLoginPage.ets pages/auth/RegisterPage.ets pages/auth/SmsLoginPage.ets pages/train/root/CourseListPage.ets || (echo "页面层仍保留旧式网络 catch" && exit 1)

echo "[14] 课程与训练项缓存类型不得回退成裸字符串"
! rg -n --glob 'CoursePreviewStore.ets' 'trainingType: string' storage/course || (echo "CoursePreviewStore.trainingType 回退成 string" && exit 1)
! rg -n --glob 'CourseDetailRepository.ets' 'trainingType: string' repository/course || (echo "CourseDetailRepository.trainingType 回退成 string" && exit 1)
! rg -n --glob 'TrainingItemPreviewStore.ets' 'status: string' storage/training-item || (echo "TrainingItemPreviewStore.status 回退成 string" && exit 1)

echo "[15] EntryAbility 不得主动申请训练专属麦克风权限"
! rg -n --glob 'EntryAbility.ets' 'MICROPHONE|requestPermissionsFromUser\(' entryability || (echo "EntryAbility 仍在主动申请麦克风权限" && exit 1)

echo "[16] user api service 不得直接读写 token 或处理上传前置"
! rg -n --glob '*.ets' 'readPersistedAuthToken\(|clearPersistedAuthToken\(|uploadProfileImageIfNeeded\(' services/user/api || (echo "user api service 仍混入本地持久化或上传前置" && exit 1)


echo "[17] FavoritesPage 不得重新直读 UserRepository"
! rg -n --glob 'FavoritesPage.ets' 'repository/user/UserRepository|readUserState\(' pages/profile || (echo "FavoritesPage 回退直读 UserRepository" && exit 1)

echo "[18] AccountPage 不得重新直连系统图片选择 API"
! rg -n --glob 'AccountPage.ets' '@ohos.file.photoAccessHelper|selectAssets\(' pages/profile || (echo "AccountPage 回退直连系统图片选择 API" && exit 1)

echo "[19] 业务源码不得通过目录 barrel 直接导入 router"
! rg -n "from '../../router'|from '../router'|from '../../../router'" pages services repository storage || (echo "存在通过目录 barrel 直接导入 router 的源码" && exit 1)

echo "结构守卫检查通过"
