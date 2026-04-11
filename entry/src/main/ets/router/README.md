# router 目录说明

本目录负责页面路由定义、路径映射与路由跳转基础能力。

## 职责
- 维护页面路径常量与路由映射。
- 提供统一的路由入口能力。

## 约定
- 路由层只处理导航与路径，不处理业务逻辑。
- 页面间需要共享的数据优先通过 service / repository / store 链路管理，不依赖复杂路由参数拼装。
- `RoutePaths` / 纯路径元数据负责维护路径真源。
- RouteMatcher 只依赖纯路径模式数据做匹配与参数解析，不依赖 RouteRegistry。
- `RouteRegistry` 只负责 `path -> render()` 的页面渲染绑定，以及根 Tab 的展示配置。
- 页面 route adapter 只能依赖 matcher / builders / paths，不能反向把 registry 拉进来形成循环依赖。
- route adapter 负责把 `routePath` 解析为页面所需的结构化输入；业务 service 只接收解析后的 route input。
- 根 Tab 与 overlay 路由并存时，切 Tab 需遵循“overlay 过渡期间冻结显示 Tab、过渡结束再切换实际 index”的策略，并通过 `route.overlay.active` 维护 overlay 活跃态。
- 当前 router 结构保持冻结：现有 matcher / registry / renderer / builders / paths 分工保留，但后续不再继续新增低价值薄层。
- 当前未提供 `router/index.ets` 或等价目录 barrel 正式出口；业务源码禁止使用 `from '../../router'`、`from '../router'` 之类目录导入。
