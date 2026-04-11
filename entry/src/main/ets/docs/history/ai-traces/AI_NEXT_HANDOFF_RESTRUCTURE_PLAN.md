# 下一位 AI 接手执行文档（基于当前项目真实代码状态）

> 适用对象：下一位继续接手本 ArkTS 前端项目的 AI。  
> 目标：不是推倒重来，而是**按真实现状继续收口结构、修正文档与守卫、冻结复杂度扩张**。  
> 当前基线：项目整体**可继续开发、可继续交付、没有致命结构问题**；当前主要风险已经从“大面积越层”收缩为**文档失真 + 1 处明确导入风险 + 若干中期维护风险**。

---

## 0. 先看结论，不要误判项目状态

### 0.1 当前项目不是“需要大重构”的状态
当前代码已经具备以下基础：
- 顶层分层已形成：`pages / services / repository / storage / api / persistence / router`。
- `FavoritesPage` 已不再直读 `UserRepository`，而是通过 user 模块 query 读取展示数据。
- `AccountPage` 已不再直连系统图片选择 API，而是走 `pickSingleProfileImage()`。
- 结构守卫与 smoke 检查脚本已存在，且当前版本可通过。

### 0.2 当前真正的风险排序
当前真正的风险排序是：
1. **旧文档已落后于真实代码**，会误导下一轮整改方向；
2. `pages/profile/FavoritesPage.ets` 仍存在一处**明确的 router 目录导入风险**；
3. training 模块复杂度仍然集中，但**现在不应该继续拆层**，而应该冻结扩张；
4. 启动初始化表达还能更模块化，但不是立即大改项；
5. 根目录与整改记录继续堆积会带来信息漂移风险。

### 0.3 本轮工作总目标
本轮整改只做下面 6 件事，且按顺序执行：
1. **先修正文档失真**；
2. **修掉 `FavoritesPage` 的 router 目录导入问题**；
3. **补一条守卫，防止同类错误再次出现**；
4. **冻结并明确 training 模块后续演化原则**（以文档为主，代码只做必要小修）；
5. **对 `AppBootstrapLocalService` 保持按模块分组表达，不做大改**；
6. **清理低价值残留文件与过多整改记录的维护方式**。

---

## 1. 文档更新是硬性要求，不是附加项

### 1.1 本轮至少必须同步的文档
如果你改了代码，至少要同步以下文档：
- `README.md`
- `AI_NEXT_HANDOFF_RESTRUCTURE_PLAN.md`
- 本轮触达目录下对应的 `README.md`
- `docs/restructure/` 下新增一份本轮整改记录

### 1.2 向用户汇报时必须单独说明的内容
向用户汇报时，必须明确写出：
1. 本轮改了哪些代码文件；
2. 本轮改了哪些 README / handoff 文档；
3. `AI_NEXT_HANDOFF_RESTRUCTURE_PLAN.md` 是否已按当前真实状态重写；
4. `docs/restructure/` 新增了哪份整改记录；
5. 哪些目录本轮虽然触达但没有改 README，以及理由。

### 1.3 本轮整改记录建议文件名
当前建议新增：
- `docs/restructure/整改执行与自检结果_v42.md`
- `docs/restructure/final_selfcheck_v42_guard.txt`
- `docs/restructure/final_selfcheck_v42_smoke.txt`

不要再把阶段性记录堆到根目录。

---

## 2. 推荐执行顺序（必须按顺序）

### P0：先修正文档与真实代码状态的偏差
### P1：修 `FavoritesPage` 的 router 导入风险
### P1：补守卫，禁止无效目录 barrel 导入
### P2：冻结 training 模块扩张，补清楚说明文档
### P2：对 `AppBootstrapLocalService` 只做表达收口，不做大改
### P3：清理仓库低价值残留与文档堆积方式

说明：
- 当前**不是**再去修 `FavoritesPage` 直读仓储，也**不是**再修 `AccountPage` 直连系统能力；这两项当前代码里已经收口。
- 当前旧 handoff 仍把它们列为主战场，属于**文档失真**，应先修。

---

## 3. P0：先修正文档失真（第一优先级）

## 3.1 问题文件
### 根文档
- `README.md`
- `AI_NEXT_HANDOFF_RESTRUCTURE_PLAN.md`

### 目录 README
- `pages/README.md`
- `services/README.md`
- `services/training/README.md`
- `router/README.md`
- `services/app/README.md`

## 3.2 当前问题是什么
当前文档与真实代码状态已经出现偏差，主要表现为：
- 根 README 仍把 `FavoritesPage` / `AccountPage` 作为当前主战场，但这两个历史边界问题已经处理过；
- handoff 文档若继续强调“优先修收藏页直读仓储、资料页直连系统能力”，会把下一位 AI 引到旧战场；
- `pages/README.md` 与 `router/README.md` 还需要明确“router 不允许目录 barrel 导入”的边界；
- training 与 app bootstrap 的文档说明还需要更明确地表达“冻结扩张、不做大改”。

## 3.3 正确的解决方向
文档中的当前优先级应统一改成下面这套：
1. **第一优先级：修正文档与真实代码状态失真**；
2. **第二优先级：修 `FavoritesPage` 顶部 router 目录导入风险**；
3. **第三优先级：补守卫，防止同类目录 barrel 导入再次出现**；
4. **第四优先级：冻结 training 模块扩张，只做收口和说明补齐**；
5. **第五优先级：保持 `AppBootstrapLocalService` 当前分组方式，不做大改，只给后续模块初始化预留统一入口方向**；
6. **第六优先级：清理仓库残留与文档堆积方式**。

同时必须明确写清以下判断：
- 当前项目**没有致命结构问题**，不需要推倒重来；
- `FavoritesPage` “直读仓储”的历史问题已经修掉，但顶部 import 还存在新问题；
- `AccountPage` 历史边界问题已基本修复，当前不是主战场；
- training 模块当前重点是**冻结扩张、减少继续吸职责**，不是继续加 service 层；
- router 当前文件数偏多，但**不是当前主要问题**，原则是保留现状、不继续横向扩层；
- 启动初始化当前已经分成 `core/course/training/ui` 四组，后续新增模块优先暴露模块级入口，不立即推翻现状。

## 3.4 完成后怎么确认解决
查看以下文件：
- `README.md`：检查“当前下一阶段真实重点”是否已改成新顺序；
- `AI_NEXT_HANDOFF_RESTRUCTURE_PLAN.md`：检查是否不再把 `AccountPage` 当当前主战场；
- `pages/README.md`：检查是否增加“禁止目录 barrel 导入 router”约定；
- `router/README.md`：检查是否明确“没有 router/index.ets 正式出口”；
- `services/training/README.md`：检查是否继续强调 training 冻结扩张；
- `services/app/README.md`：检查是否明确当前只保留按模块分组初始化表达。

---

## 4. P1：修 `FavoritesPage` 的 router 导入风险（高优先级，必须做）

## 4.1 目标文件
### 必改文件
- `pages/profile/FavoritesPage.ets`

### 需要检查的配套文件
- `router/Router.ets`
- `router/RoutePaths.ets`
- `router/README.md`
- `structure_guard_check.sh`
- `structure_smoke_check.sh`

## 4.2 当前问题是什么
当前 `FavoritesPage.ets` 顶部若仍写成：
```ts
import { Router, RoutePaths } from '../../router'
```
则存在两层问题：
1. **模块解析风险**：`router/` 目录当前没有 `index.ets`、`router.ts` 或其他正式 barrel 文件；
2. **风格不一致**：项目其他页面主要走显式文件导入，如 `router/Router`、`router/RoutePaths`、`router/RouteBuilders`。

## 4.3 正确的解决方案
**推荐方案：显式文件导入，不要补 barrel。**

把：
```ts
import { Router, RoutePaths } from '../../router'
```
改成：
```ts
import { go } from '../../router/Router'
import { PROFILE_PATH } from '../../router/RoutePaths'
```

并把：
```ts
.onClick(() => Router.go(RoutePaths.PROFILE))
```
改成：
```ts
.onClick(() => go(PROFILE_PATH))
```

### 为什么不推荐新建 `router/index.ets`
- 当前 router README 已写明“router 结构保持冻结，不再继续新增低价值薄层”；
- 只为了兼容一处错误导入而新增 barrel，本质是在**给错误让路**；
- 显式导入更符合当前项目已有约定，也更利于守卫脚本检查。

## 4.4 改完后怎么确认解决
### 代码确认
1. 看 `pages/profile/FavoritesPage.ets` 顶部 import：
   - 不应再出现 `from '../../router'`
   - 应改成显式 `Router.ets` / `RoutePaths.ets` 导入
2. 看点击逻辑：
   - 不应再出现 `Router.go(RoutePaths.PROFILE)`
   - 应为显式调用 `go(PROFILE_PATH)` 或等价正式导入写法

### 全局确认
执行全文搜索：
```bash
rg -n "from '../../router'|from '../router'|from '../../../router'" pages services repository storage
```
预期结果：
- 不应再出现任何业务源码通过目录本身导入 `router`

---

## 5. P1：补守卫，禁止无效目录 barrel 导入（必须做）

## 5.1 目标文件
- `structure_guard_check.sh`
- `structure_smoke_check.sh`

## 5.2 当前问题是什么
当前守卫已经能防以下事情：
- `FavoritesPage` 不得重新直读 `UserRepository`
- `AccountPage` 不得重新直连 `photoAccessHelper`
- training 模块不能回退到 routePath 直解析
- api 不得反向依赖等

但是：
**当前守卫并没有禁止“目录 barrel 幻觉式导入 router”**。

## 5.3 正确的解决方案
### 在 `structure_guard_check.sh` 中新增一条检查
新增类似规则：
- 禁止源码出现 `from '../../router'` / `from '../router'` / `from '../../../router'`
- 允许的导入方式必须是显式文件路径，例如 `router/Router`、`router/RoutePaths`、`router/RouteBuilders`

### 在 `structure_smoke_check.sh` 中补充断言
- 额外读取 `favorites_page`
- 断言 `from '../../router'` 不存在
- 最好做成全局业务源码扫描，确保 pages / services / repository / storage 中都不会出现目录导入 router 的写法

## 5.4 改完后怎么确认解决
运行：
```bash
bash structure_guard_check.sh
bash structure_smoke_check.sh
```
预期：
- 两个脚本都通过；
- 若手动把 `FavoritesPage` 改回 `from '../../router'`，守卫应能失败。

---

## 6. P2：冻结 training 模块扩张，只做收口与说明补齐

> 这一项不是要求大改代码，而是要求你**明确边界，防止下一轮 AI 再把 training 写胖**。

## 6.1 重点文件
- `pages/train/flow/TrainPage.ets`
- `pages/train/flow/TrainPageController.ets`
- `services/training/TrainPageService.ets`
- `services/training/local/TrainPageLocalService.ets`
- `services/training/local/TrainPageQueryLocalService.ets`
- `services/training/README.md`
- `services/README.md`
- `pages/README.md`

## 6.2 当前真实问题是什么
training 模块不是边界错了，而是**复杂度集中**：
- `TrainPageService.ets` 是正式门面，但很多函数仍偏 façade + 透传；
- `TrainPageLocalService.ets` 已经是训练页动作汇聚点，不应继续吸更多职责；
- `TrainPageQueryLocalService.ets` 当前兼有默认值工厂与退出态清理，这个命名与职责并不完全理想；
- `TrainPage.ets` 本体仍然承担大量页面局部状态，是复杂度中心之一。

## 6.3 正确的整改方向
本轮只做三件事：
1. **把边界原则写清楚到文档里**；
2. 如需代码小修，只做命名或说明性收口；
3. 不要再扩展 `TrainPageLocalService` 的职责面。

### 本轮不建议做的事
- 不再新增 `TrainPageActionService`、`TrainPageMediaService`、`TrainPageStageService` 之类横向薄层；
- 不再给 `TrainPageService` 再套一层 facade；
- 不为了命名洁癖，立刻全量迁移 `createEmpty...` 与 `clearExit...`。

### 推荐的最小收口动作
- 在 `services/training/README.md` 和 `services/README.md` 里明确写：
  - `TrainPageService` 是训练页正式门面；
  - `TrainPageLocalService` 是动作汇聚点，但不继续吸收 route 解析和页面展示逻辑；
  - `TrainPageQueryLocalService` 当前兼有默认值工厂与退出态清理，后续若继续演进应优先把这些职责迁出，但**本轮不做大迁移**；
  - `TrainPageController` 只做 UI glue，不横向裂变更多 controller；
  - training 模块当前策略：**冻结扩张、只做收口**。

---

## 7. P2：启动初始化表达收口，不做大改

## 7.1 目标文件
- `services/app/local/AppBootstrapLocalService.ets`
- `services/app/README.md`
- `services/README.md`
- `AI_NEXT_HANDOFF_RESTRUCTURE_PLAN.md`

## 7.2 当前真实状态
`AppBootstrapLocalService.ets` 当前已经比早期健康不少，至少已按模块拆成：
- `getCoreInitializers()`
- `getCourseModuleInitializers()`
- `getTrainingModuleInitializers()`
- `getUiInitializers()`

## 7.3 正确的解决方向
本轮只做：
- 在文档中明确后续方向：**新增模块时优先暴露模块级初始化入口**；
- 当前代码不做大改，不把现有启动链全部推翻。

如果要做代码层小优化，也只建议非常轻微的整理，例如：
- 保持现有四组初始化函数；
- 不新增跨层依赖；
- 不把 repository 反向拉进 service；
- 不为了“抽象”再新增一层空壳。

---

## 8. P3：清理仓库低价值残留与文档堆积方式

## 8.1 低价值残留文件
### 目标文件
- 根目录：`基于`

### 当前问题
根目录存在一个孤立文件 `基于`，这是明显的历史残留物，不承担正式职责，会降低仓库整洁度并干扰接手者判断。

### 解决方案
- 直接删除该文件；
- 在本轮整改记录里说明“已清理根目录历史残留文件”。

## 8.2 文档堆积方式
当前 `docs/restructure/` 下已有多份历史记录，问题不在“不能留”，而在于：
- 若后续继续无限加版本号，README / handoff / 历史记录三者容易漂移；
- 下一位 AI 很难判断哪份文档才是当前真相源。

### 正确的处理方式
本轮不要求删历史记录，但必须在文档中明确：
- `README.md` + `AI_NEXT_HANDOFF_RESTRUCTURE_PLAN.md` 才是当前真相源；
- `docs/restructure/` 是过程记录归档区；
- 以后继续加整改记录时，不要再在根目录新增平级 handoff 版本文件。

---

## 9. 当前不是主战场，但可记录为“后续关注”的项目

### 9.1 `pages/profile/AccountPage.ets`
当前已基本合规，但页面局部状态仍然较多；本轮不作为优先整改项，只在 handoff 中标记：**后续如继续扩功能，再考虑 page controller / form state 收口**。

### 9.2 `pages/auth/SmsLoginPage.ets` 与 `pages/auth/RegisterPage.ets`
这两页 LOC 也不算小，说明登录注册页仍有“表单状态 + 业务触发 + UI 细节”堆积趋势。本轮不应把它们拉成新的重构任务。

### 9.3 router 层文件较细
当前 `router` 目录下文件较多，但职责基本清楚。
结论：
- 当前保留；
- 不再继续拆；
- 也不要为了统一导入风格补一个新的 `router/index.ets`。

---

## 10. 严禁事项（下一位 AI 不得违反）
1. 禁止把 `FavoritesPage` 改回直读 `UserRepository`；
2. 禁止把 `AccountPage` 改回直接使用 `photoAccessHelper` / `selectAssets()`；
3. 禁止为了兼容 `FavoritesPage` 的错误 import 而新增 `router/index.ets` barrel；
4. 禁止在 training 模块继续新增纯透传 service 薄壳；
5. 禁止把页面展示字段重新塞回 `TrainSessionRuntime`；
6. 禁止把 routePath 解析重新带回 `TrainPageService`；
7. 禁止只改代码不改 README / handoff / 整改记录；
8. 禁止把阶段性整改记录继续堆到根目录；
9. 禁止因为 `AppBootstrapLocalService` 还能优化，就贸然做大重构。

---

## 11. 本轮执行完成后的验收清单
### 文档验收
- [ ] `README.md` 已改成当前真实优先级；
- [ ] `AI_NEXT_HANDOFF_RESTRUCTURE_PLAN.md` 已不再把 `AccountPage` 当当前主战场；
- [ ] `pages/README.md` 已明确禁止目录 barrel 导入 router；
- [ ] `router/README.md` 已明确当前无 `router/index.ets` 正式出口；
- [ ] `services/README.md` / `services/training/README.md` 已明确 training 冻结扩张原则；
- [ ] `services/app/README.md` 已明确当前只保留模块分组初始化表达；
- [ ] `docs/restructure/整改执行与自检结果_v42.md` 已新增。

### 代码验收
- [ ] `pages/profile/FavoritesPage.ets` 不再出现 `from '../../router'`；
- [ ] 收藏页返回按钮已改成显式 `go(PROFILE_PATH)` 或等价正式导入；
- [ ] 未新增 `router/index.ets` 一类仅用于兼容错误导入的 barrel 文件；
- [ ] training 模块本轮没有新增多个横向 `TrainPage*Service` 薄层；
- [ ] 根目录残留文件 `基于` 已删除。

### 守卫验收
- [ ] `structure_guard_check.sh` 已新增禁止目录 barrel 导入 router 的检查；
- [ ] `structure_smoke_check.sh` 已补充对应断言；
- [ ] `bash structure_guard_check.sh` 通过；
- [ ] `bash structure_smoke_check.sh` 通过。

---

## 12. 一句话版总指令（给下一位 AI 的最短提醒）
**先修文档失真，再修 `FavoritesPage` 的 router 导入，再补守卫；training 只冻结收口、不继续加层；改代码必须同步 README / handoff / 整改记录。**
