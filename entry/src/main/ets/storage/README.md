# storage 目录说明

本目录只负责前端内存状态与缓存表本身的维护。

约定：
- 只负责定义状态结构、默认值、基础的增删改查，以及必要的副本保护。
- 不负责编排业务流程。
- 不负责调用后端接口。
- 不负责对象构造、历史兼容归一化、preview/detail 回退等组合逻辑。
- 当前这类标成“深拷贝”的函数，很多其实只是受控浅拷贝 / 定向拷贝，并不是递归意义上的完整深拷贝。

## TrainSessionRuntime 收口约定
- 可以进入 runtime 的，只能是当前激活训练会话跨阶段推进必需的真源状态。
- 纯展示文案、页面局部开关、结果页展示块、上传过程临时变量，优先放页面本地状态、view state 或 query 结果。
- 后续若要给 runtime 新增字段，必须先判断它是否真的承担“跨 stage 且不可临时推导”的职责。

## Store 内不再负责字段归一化
- `TrainSessionStore`、`CourseSessionStore` 只负责默认值、补丁合并、缓存读写与必要副本保护。
- `trainingType / currentItemStatus` 这类历史兼容与归一化，统一前移到 `services/.../local`、`services/.../cache` 或 `services/.../mapper`。
- 不允许再把 `normalizeTrainingType`、`normalizeTrainItemStatus` 一类逻辑塞回 store。

## 显式类型约定
- 缓存快照与运行时字段优先保存规范化后的 `TrainingType / TrainItemStatus / TrainStage`，而不是裸字符串。
- `CoursePreview / CourseDetail / TrainingItemPreview` 等缓存结构，也应尽量保存已经规范化过的共享类型。
- store 只保存已经被上游 service / mapper 规范化过的值，不承担最后一道类型兜底。
