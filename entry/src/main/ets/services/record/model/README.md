# Record Model

这个目录负责存放记录模块专属的页面状态模型与展示模型，避免把明显只服务于 `record` 模块的 view-state / view-model 继续放在通用 `domain` 目录下。

当前包含：
- `RecordPageState`：记录页页面状态与分页状态
- `RecordViewModels`：最近课程、趋势点等展示模型

约束：
- 这里只放记录模块内部使用的页面态 / 展示态
- 不把 `loading / tip / pageNo` 这类页面字段再放回 domain
