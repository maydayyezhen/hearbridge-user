# domain 目录说明

本目录存放领域实体定义与领域相关的静态说明文件。

## 职责
- 定义课程、训练项、用户、记录等领域实体。
- 作为跨层共享的领域概念，不承担页面展示职责。

## 约定
- `domain` 只表达“是什么”，不负责编排“怎么做”。
- 领域实体不直接依赖页面或 UI 语义。
- 训练相关共享字面量类型统一沉淀在 `domain/static/train/TrainingRuntimeTypes.ets`。

## 当前收口说明
- 历史遗留的通用 `Session.ets` 已移除。
- 训练会话相关状态以 `storage/train-session`、`repository/train-session` 以及对应 service 内的运行时 / 视图状态模型为准，避免并存多套“会话模型”造成歧义。
- `domain/static/train/TrainingRuntimeTypes.ets`：沉淀 `TrainingType / TrainItemStatus / PracticeMode` 等共享类型，供 route / storage / service 共同复用。
- `domain/static/train/TrainingContentModels.ets` 中 `TrainingContentItem.status` 表示训练流程状态，应使用 `TrainItemStatus`；`MediaResourceItem.status` 表示媒体资源状态，仍与训练流程状态分开。
