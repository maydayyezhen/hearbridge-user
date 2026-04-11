# pages 目录说明

本目录存放页面、布局壳与页面级交互承接代码。

## 职责
- 负责页面展示与用户交互承接。
- 负责调用对应模块的 service。
- 负责路由入参与页面局部展示状态。

## 约定
- 不在页面中长期保留本应属于 `service` 的业务编排。
- 页面应尽量避免直接调 API、直接操作 repository。
- 页面只负责“如何展示”和“何时触发业务”，不负责业务细节本身。
- 页面优先承接 service 的结果对象，不再为普通网络失败重复兼容旧式 `try/catch`。
- route adapter 负责把 `routePath` 转换成结构化页面输入，页面 controller 负责在边界处调用 adapter，再把业务输入交给 service。
- 收藏页这类页面读模型，应由模块内 `query` 或等价 service 提供；页面不再自己拼装 subtitle、类型文案，也不再直接读取 `repository/user/UserRepository`。
- 资料页不直接调用系统资源选择 API；`photoAccessHelper`、`selectAssets()` 这类系统能力细节应下沉到对应模块的 `local service`。
- 页面不允许通过不存在的目录 barrel 间接依赖 router；路由能力应显式从 `router/Router`、`router/RoutePaths`、`router/RouteBuilders` 等正式文件导入。
