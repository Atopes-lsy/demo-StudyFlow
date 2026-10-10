# 组长工作步骤清单

> 版本：2.0 | 日期：2026-10-10 | 产品方向：课表日程提醒助手
>
> 详见 [PRD](../team/prd.md)。前端后续用 Figma 替换，当前代码仅保证功能跑通。

## 0. 已完成的基础条件

- [x] HarmonyOS `entry` 工程已有，编译通过。
- [x] 全局类型 `model/Types.ets` 已定义（课表、日程、用户、角色、API、提醒）。
- [x] 服务层已搭建：PreferencesUtil、AuthService、DataRepository、NotificationService、HttpUtil、SmartReminderService。
- [x] 7 个页面已创建并注册路由：Login、Home、Schedule、Calendar、Settings、ReminderSettings、CharacterSettings、ApiConfig。
- [x] EntryAbility 已实现登录态检查，未登录跳转 LoginPage。
- [x] module.json5 已配置 INTERNET 和 GET_NETWORK_INFO 权限。
- [x] PRD 文档已生成 `docs/team/prd.md`。
- [x] 需求文档已更新 `docs/team/requirement.md`。

## 1. 组长职责（本次重构已完成）

- [x] 定义全局类型和默认值（`model/Types.ets`）。
- [x] 实现 PreferencesUtil 本地存储封装（按用户隔离）。
- [x] 实现 AuthService 本地登录注册（简单哈希）。
- [x] 实现 DataRepository 课表/日程/提醒/角色数据读写。
- [x] 搭建 NotificationService 通知发送。
- [x] 搭建 HttpUtil AI API 调用。
- [x] 搭建 SmartReminderService 智能提醒（角色语气 + 降级回退）。
- [x] 配置 module.json5 权限和 main_pages.json 路由。
- [x] 更新 EntryAbility 登录态检查。
- [x] 编译通过。

## 2. 组长后续待办

- [ ] 评审组员提交的 PR，确保符合契约和视觉规范。
- [ ] 整合测试报告，汇总三人截图和测试结果。
- [ ] 撰写 2000 字项目报告（分工、设计、测试、应用流程）。
- [ ] 准备答辩总述（产品定位、架构、核心功能演示）。
- [ ] Figma 设计稿完成后，协调前端替换。

## 3. 组长不做的事

- 不包办组员的页面 UI 细节和交互逻辑。
- 不代做组员的故障修复或报告段落。
- 不建立后端服务器。
- 不永久保存用户 API Key。
