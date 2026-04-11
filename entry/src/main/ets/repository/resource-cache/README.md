# repository/resource-cache 目录说明

本目录负责资源缓存相关的数据访问转接，当前聚焦头像/头图本地持久化缓存映射。

当前包含：
- ProfileImageCacheRepository：头像/头图本地持久化缓存状态转接。

约定：
- Service 不直接访问 persistence，统一通过本目录调用。
- 本目录不负责编排页面流程与交互。
