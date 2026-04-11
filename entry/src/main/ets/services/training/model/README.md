# training/model 目录说明

本目录只放训练模块页面读模型定义。

当前包含：
- `TrainPageCourseDisplay`：训练页课程展示信息。
- `TrainSummaryViewState`：训练总结页统计展示模型。

## 约定
- model 只表达页面直接消费的数据结构，不承担动作推进。
- query 负责组装 model；local 负责动作与流程；页面负责展示。
