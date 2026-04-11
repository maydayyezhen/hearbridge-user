# ets 目录说明

本目录是前端 ArkTS 代码的主入口，按“页面展示、业务处理、数据访问、状态存储、请求基础层”分层组织。

## AI 接手与 README 强制同步规则
- 接手前先阅读本 README 与相关目录 README，按当前代码事实执行。
- 只要本次改动涉及目录职责、调用边界、路由规则、缓存主从关系、请求失败语义、守卫脚本，就必须同步更新对应目录的 `README.md`。
- 已修改代码但未同步 README 的提交，视为未完成。
- 向用户汇报时必须单独说明：本次改了哪些 README、为什么这样同步。

## 当前顶层目录职责
- `api`：请求基础层与原始请求文件。
- `components`：可复用界面组件。
- `config`：应用级配置常量。
- `domain`：领域实体与共享字面量类型。
- `docs`：项目正式文档、整改过程记录与开发疑难排查记录。
- `entryability`：HarmonyOS 应用入口能力。
- `pages`：页面与页面布局承接层，只负责展示与交互。
- `persistence`：本地持久化底层读写。
- `repository`：组合 store / persistence 的数据访问层。
- `router`：页面路由与路径映射。
- `services`：业务处理与编排层。
- `storage`：内存状态与缓存表。
- `utils`：跨模块通用工具。

## 目录约定
- 页面展示控制尽量留在 `pages`。
- 业务逻辑逐步下沉到 `services`。
- `repository` 只做数据访问与状态转接，不做页面提示与业务编排。
- `api` 负责请求基础设施与原始接口调用，不再保留仅用于凑后端字段的前端 DTO，也不反向依赖 `repository / services / pages / storage`。
- 请求层统一返回 `ApiResult`；普通业务失败与网络失败都由上层按 `result.ok` 承接，不再把常规网络失败直接抛给页面层。
- 训练类型与训练项流程状态进入 store 前必须完成归一化，不允许继续以裸字符串在内部层扩散。

## 结构守卫
- 可执行 `bash structure_guard_check.sh` 做最低成本的分层静态检查。
- 可执行 `bash structure_smoke_check.sh` 做行为级静态冒烟，当前覆盖请求失败语义、route adapter、训练类型归一化、训练链路显式类型、权限申请位置、用户模块 api/local 边界，以及资料页/收藏页的页面边界守卫。
- 重点守卫：pages 不直连 local/repository/storage/api；repository 不反向依赖 services/pages；api 不反向依赖 repository/services/pages/storage；页面不写裸路由；业务文件不再手写 `new Course(...)` / `new TrainingContentItem(...)`。
- 训练页额外守卫：`TrainPageService` 不再直接解析 routePath，`TrainSessionRuntime` 不再混入明显页面展示字段，训练链路公共签名不再扩散 `Object`，route input 不再回退成裸字符串 stage。
- 收藏页不再直读 `UserRepository`；资料页不再直接调用 `photoAccessHelper.selectAssets()`。
- 入口能力不再主动申请训练页专属权限；麦克风权限只允许保留在训练语音本地服务的按需入口。
- `services/user/api` 不再直接读取 / 清理持久化 token，也不再直接执行资料图片上传前置流程。

## 训练缓存主从关系
- `TrainSessionRuntime`：当前激活训练会话的唯一运行时真源。
- `TrainSessionRuntime` 只承载训练流程推进必需状态；课程展示文案、结果页展示块、页面临时 UI 开关、上传过程临时变量不再继续塞入 runtime。
- `CourseSessionCacheEntry`：课程级继续练习快照，只负责恢复/展示会话进度，不负责课程静态展示字段兜底。
- `CourseDetail / CoursePreview`：课程静态展示缓存，负责课程名称、简介、封面等静态信息。
- `TrainingItemPreview / TrainingItemDetail`：训练项静态展示缓存。
- 退出训练页时默认只清理训练页运行时与临时视图态，保留课程会话快照，便于课程详情页继续显示“继续练习”。

## 文档收口约定
- 根目录优先只保留顶层入口说明、守卫脚本与 handoff 文档。
- 整改过程记录统一收口到 `docs/restructure/`，避免根目录继续堆积阶段性产物。
- 历史 AI 交接与自检痕迹统一归档到 `docs/history/ai-traces/`。
- 开发疑难排查与案例复盘统一收口到 `docs/troubleshooting/`。
