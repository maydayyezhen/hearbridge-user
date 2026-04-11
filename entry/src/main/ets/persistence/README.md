# persistence 目录说明

本目录负责本地持久化存储的底层读写。

约定：
- 只负责本地持久化数据的读取、写入与清理。
- 不负责编排业务流程。
- 不直接处理页面展示。
- Repository 通过本目录访问本地持久化数据，Service 不直接接触本目录。

当前包含：
- `AuthPersistence.ets`：登录 token 持久化读写。
- `UserProfilePersistence.ets`：用户账号资料字段（昵称、头像、头图、性别、生日、签名）持久化读写。
- `ProfileImageCachePersistence.ets`：头像/头图本地缓存文件路径与映射信息持久化。
