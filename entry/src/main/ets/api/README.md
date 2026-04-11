# API 请求层说明

## 请求字段规范

像课程列表筛选、认证提交、训练提交这类仅用于描述后端请求字段的对象，不再在代码中额外声明 DTO / Builder / Wrapper / Request 类型。

当前约定是：

- 字段规范写在文档里
- 代码中直接按普通对象传参
- 模块 `api` 服务在内部完成字段清洗、query 拼接与请求发送
- `ets/api/request` 或请求基础层只保留真正通用的请求机制，不重新理解业务字段

## 课程列表请求字段

请求路径：`GET /app/course/list`

支持字段：

- `keyword`: 关键词，字符串，可选
- `trainingType`: 训练类型，字符串，可选
- `tags`: 标签数组，可选，可重复拼接为多个 `tags=` 参数
- `sortBy`: 排序字段，字符串，可选
- `pageNo`: 页码，正整数，可选
- `pageSize`: 每页数量，正整数，可选

## 认证相关请求字段

### 密码登录
请求路径：`POST /app/auth/password/login`

### 密码注册
请求路径：`POST /app/auth/password/register`

### 短信登录
请求路径：`POST /app/auth/sms/login`

### 用户资料更新
请求路径：`PUT /app/user/profile/update`

### 密码更新
请求路径：`PUT /app/user/password/update`

## 训练提交请求字段
请求路径：`POST /app/training/session/{sessionId}/item/{itemCode}/submit`

以上字段仅作为接口文档约定存在，不再单独声明前端 DTO 类型。

## 请求失败语义
- `requestApi()` 无论成功、业务失败还是普通网络失败，都统一返回 `ApiResult`。
- 网络异常场景下约定：`httpCode = 0`、`code = 0`、`ok = false`，`message` 与 `rawBody` 中保留错误文本。
- 页面层与业务 service 统一以 `result.ok` 为主判断请求结果，避免同时维护 `result.ok` 与 `try/catch` 两套路由。
- 当前整改已进入上层历史 catch 清理阶段；纯请求 service 优先改成 `result.ok` 单通道承接，守卫脚本会限制旧式 catch 回流。

## 调试输出边界
- `api/ApiDebug.ets` 只负责组装调试文本，不直接写 repository / store。
- 调试文本最终写到哪里，由上层在启动阶段通过 `setApiDebugWriter(...)` 注入。
- 当前注入动作统一放在 `services/app/local/AppBootstrapLocalService.ets`，避免 `api -> repository` 反向依赖。
