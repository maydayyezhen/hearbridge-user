# services/app 目录说明

本目录负责应用启动阶段的统一初始化入口。

## 当前约定
- `local/AppBootstrapLocalService.ets` 是应用启动编排入口。
- 当前初始化项按 `core / course / training / ui` 四组组织，表达上继续保持分组，不做推倒重来式重构。
- 后续新增模块时，优先让模块自己暴露初始化入口，再由启动服务统一编排；不要把更多 repository 级细节直接散落到页面或入口能力里。
- 本目录只负责启动编排，不反向接管页面展示逻辑。
