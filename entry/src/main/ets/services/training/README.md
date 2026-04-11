# services/training 目录说明

本目录负责训练模块的业务处理与读模型组装。

## 当前主干分工
- `TrainPageService.ets`：训练页正式门面，页面动作优先只从这里进入。
- `pages/train/flow/TrainPageController.ets`：训练页 UI glue，负责把页面状态与 service 接起来。
- `pages/train/flow/TrainPageRouteAdapter.ets`：只负责 `routePath -> routeInput` 的边界解析。
- `local/TrainPageLocalService.ets`：训练页动作汇聚点，负责训练流程推进、本地状态编排与提交流程衔接。
- `local/TrainPageQueryLocalService.ets`：当前同时承接只读查询、默认值工厂与退出态清理的收口文件；本轮不做大迁移，但后续不应继续往里面叠加更多非 query 职责。
- `query/*`：只负责读模型、统计结果与页面派生数据。
- `model/*`：只负责训练页页面读模型定义。

## 当前阶段原则
- 训练模块已经完成从“大文件堆功能”到“门面 + 动作汇聚 + query”主干的切分。
- 下一阶段以“冻结扩张、只做收口”为原则，不继续新增只转发、不增值的 service 薄层。
- `TrainPageLocalService` 不继续吸入 route 解析和页面展示控制；`TrainPageService` 也不继续膨胀成纯透传大文件。
- route 解析不回流到 service；展示字段不回塞到 `TrainSessionRuntime`；页面展示控制不混入 local service。
