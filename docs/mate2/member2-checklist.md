# 组员 2 工作清单

> 版本：2.0 | 日期：2026-10-10 | 产品方向：课表日程提醒助手
>
> 详见 [PRD](../team/prd.md)。前端后续用 Figma 替换，当前代码仅保证功能跑通。

## 负责模块

通知提醒、提醒设置、API 配置、角色设定、智能提醒。

## 已有基础（组长已搭建）

- `service/NotificationService.ets` — 通知发送已完成
- `service/HttpUtil.ets` — AI API 调用已完成
- `service/SmartReminderService.ets` — 智能提醒已完成
- `pages/ReminderSettingsPage.ets` — 提醒设置页已创建
- `pages/CharacterSettingsPage.ets` — 角色设定页已创建
- `pages/ApiConfigPage.ets` — API 配置页已创建
- `pages/SettingsPage.ets` — 设置入口页已创建
- `model/Types.ets` — 全局类型已定义

## 待办

### SF-05 通知提醒
- [ ] 验证通知权限授权流程
- [ ] 实现每日定时提醒（当前只有手动触发测试）
- [ ] 实现课前提醒（根据课表时间提前通知）
- [ ] 实现日程提醒（根据事件时间提前通知）
- [ ] 验证点击通知打开 App

### SF-06 提醒设置
- [ ] 验证总开关/分类开关生效
- [ ] 验证提前时间滑块修改后提醒时间更新
- [ ] 验证每日提醒时间切换
- [ ] 补充时间选择器（当前是循环切换，改为 TimePicker）

### SF-07 API 配置
- [ ] 验证 API Key 不落盘（重启后需重新输入）
- [ ] 验证连接测试功能
- [ ] 验证 OpenAI 兼容/自定义切换
- [ ] 补充 API Key 清除功能

### SF-08 角色设定
- [ ] 验证添加/删除/切换角色
- [ ] 验证启用角色后智能提醒使用角色语气
- [ ] 补充预设示例角色

### SF-09 智能提醒
- [ ] 验证 API 正常时生成角色语气文案
- [ ] 验证 API 失败时回退基础文案
- [ ] 验证未配置 API 时回退基础文案
- [ ] 验证未启用智能提醒时使用基础文案

### 安全验证
- [ ] 确认 API Key 不进日志
- [ ] 确认 API Key 不进通知内容
- [ ] 确认 API Key 不进 Preferences

### 测试与截图
- [ ] 每个页面至少 2 张截图
- [ ] 编写测试用例文档
- [ ] 验证编译、白屏、通知触发

## 分支

`feature/record` — 在此分支开发，完成后 PR 到 `dev`
