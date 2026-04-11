# repository 目录说明

本目录负责封装数据访问逻辑，职责类似后端 DAO / Repository。

约定：
- 负责组合多个 Store / Persistence 的读取与写入。
- 负责对象构造、preview/detail 回退、索引查询等访问逻辑。
- Service 不直接接触 Store，也不直接接触 Persistence，统一通过 Repository 转接。
- 不直接处理页面展示。
- 不负责编排完整业务流程。

- 历史兼容归一化与接口字段解释统一放在 service / mapper，Repository 只接收已经规范化后的数据。

- 头像/头图跨重启持久化映射由 `repository/resource-cache` 转接 `persistence/ProfileImageCachePersistence.ets`。

## 当前收尾期暂存说明
当前仓储层整体已经可用，本轮不再为了边界洁癖重写实现；但文档职责需要与当前代码重新对齐：

- `repository/training-item/TrainingItemDetailRepository.ets`
  - 当前只负责训练项详情缓存的基础读写与实体转换。
  - 不再承担 preview/detail 合并解释逻辑。
  - 后续若训练项详情字段继续扩展，应把“如何解释与合并字段”继续留在 `services/.../mapper` 或 `services/.../local`。

- `repository/user/UserRepository.ets`
  - 当前只负责用户状态基础读写与只读事实查询。
  - 用户账号资料字段持久化（读取 / 写入 / 清理）通过本仓储统一转接 `persistence/UserProfilePersistence.ets`。
  - 不再集中处理收藏课程 / 训练项的替换、去重和状态回写。
  - 收藏集合替换、去重与状态回写规则，当前已经上移到 `services/user/local/UserFavoriteStateService.ets`。

- 后续若缓存策略继续变化：
  - Repository 继续只保留稳定的数据访问与状态转接。
  - 集合替换规则、历史兼容解释、字段归一化优先继续上移到 local service / mapper。
