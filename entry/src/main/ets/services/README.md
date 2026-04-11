# services 目录说明

本目录负责业务处理与编排，不负责页面展示控制。

## 当前目录约定
- 先按业务模块拆分：例如 `app / auth / training / ui / user`
- 每个模块内部再按职责拆分为：
  - `cache`：本地缓存相关协调
  - `local`：端内业务编排、规范化、状态流转、结果组装、本地资源处理
  - `api`：调 API 的业务 service 与远端结果承接
  - `model`：提供给页面层的读模型定义
  - `query`：围绕页面读模型的只读组装能力
- service 只能向下依赖 `repository -> store / persistence / res`
- 严禁 `repository -> service` 反向调用
- 页面只负责展示与交互承接，业务逻辑应逐步下沉到对应模块的 service
- 页面层引用模块 service 时，优先走模块正式出口；当前 `auth / course / record / training / user` 都已通过 `index.ets` 暴露页面入口

## 页面读模型约定
- `model`：只定义模块提供给页面层使用的读模型。
- `query`：只负责组装页面读模型，不再内联定义展示类。
- `api / local`：保留行为与编排，不混放页面模型定义。
- 当前 `FavoritesPage` 这类“列表展示 + 头部统计”页面，应从 user 模块 query 获取读模型，不再让页面自己拼装仓储快照。

## 请求结果承接约定
- 纯 API service 对 `requestApi()` 返回结果优先按 `result.ok` 单通道承接。
- 不再继续保留仅为普通网络失败存在的旧式 `try/catch`。
- 若保留 catch，必须是为了本地持久化、文件 IO、系统能力、媒体上传等非普通请求失败场景。
- 启动自动登录场景下，`auth/local` 允许对“用户信息拉取超时”做容错放行（保持已登录态），避免弱网瞬时超时直接踢回登录页；非超时失败仍按既有失败路径处理。

## api / local 分责约定
- `api` 目录负责“调 API 的业务逻辑 + 响应解释”。
- `local` 目录负责“本地持久化 / 本地资源读取 / 系统能力 / 上传前置 / 端内流程编排”。
- 若一个 service 同时做远端请求和本地能力，优先拆成本地 façade + api service。
- `services/user/api` 不再直接读取 / 清理持久化 token，也不再直接调用资料图片上传前置流程。
- 资料页图片选择属于系统能力，应放入 `services/user/local` 或共享 local service，而不是留在 page。

## 训练页路由输入约定
- 训练页 service 接收已经解析好的业务输入（如 `TrainSessionRouteInput`），不直接解析 `routePath`。
- `routePath -> routeInput` 的转换发生在页面 controller / route adapter 边界，避免把路由语义继续带入 service。

## 训练链路类型约定
- 训练链路公共输入优先使用显式 union type，不继续扩散 `Object` / `string` 兜底。
- `TrainSessionRouteInput.stage`、`TrainSessionBootstrapContext.nextStage` 统一使用 `TrainStage`。
- 页面或 helper 若需要 ability context，优先显式写 `common.BaseContext | undefined`。

## 写入 store 前完成归一化
- 训练类型、训练项状态这类兼容与归一化，应在 `local / cache / mapper` 层完成，再写入 repository / store。
- store 只负责保存规范化后的值，不再偷偷修正输入。

## 记录页最近课程同步约定
- `record` 模块进入页面时可先用 user store 的 `recentCourses` 预热显示，再发起远端刷新。
- 首次进入可触发远端刷新，后续重复进入优先命中已同步缓存，避免每次重复请求最近课程首屏数据。
- 远端返回成功后，`record` 模块负责把最新 `recentCourses` 回写 user store，保证页面态与用户态一致。
- 远端失败时保留 user store 预热数据作为兜底，不在页面首刷时直接清空列表。
- `record` 总览数据同样采用“首次请求 + 后续命中服务内缓存”的策略，避免每次进入重复请求总览。

## 首页与课程详情缓存约定
- `home` 模块进入页面先命中 service 内缓存预热，首次进入再请求远端配置，避免每次切回首页重复请求。
- `course` 详情页进入时优先使用 detail/session/item 缓存；命中详情缓存时不再重复请求课程详情接口。
- 课程详情页仅在缺少会话缓存且训练项缓存也为空时，才补拉会话详情并回写缓存。

## 资料图片缓存约定
- `services/user/local/ProfileImageCacheLocalService` 负责头像/头图缓存流程编排：持久化状态预热、远端图片下载、缓存更新。
- 页面展示仍通过 `services/user/local/UserProfileLocalService` 获取展示 URL，不直接触达缓存底层实现。

## 训练模块收口约定
- `TrainPageService` 继续作为训练页正式门面；页面动作优先只从这里进入。
- `TrainPageLocalService` 继续作为训练页动作汇聚点，但不重新吸入 route 解析和页面展示逻辑。
- `TrainPageController` 只负责 UI glue，不继续横向裂变更多 controller。
- 当前 training 模块以“冻结扩张、只做收口”为原则；禁止新增“只转发、不增值”的 service 薄壳层。

## 启动初始化约定
- `services/app` 提供应用启动统一入口。
- 后续新增模块时，优先暴露模块级初始化入口，而不是持续在启动文件里平铺 repository 级初始化项。
- 当前阶段允许在不增加跨层依赖的前提下，对初始化列表做按模块分组整理，但不做大改。
- `AppBootstrapLocalService` 当前保持 `core / course / training / ui` 四组初始化分法；后续新增模块优先补模块级入口，而不是把更多细节直接摊平到启动总表里。
- `auth/local` 在启动恢复登录态前，先尝试从用户资料持久化快照预热账号字段；用户资料更新成功后由 `user/local` 写回持久化，退出登录 / 改密重登时同步清理。
