# StudyFlow 架构与契约

> 版本：2.0 | 日期：2026-10-10 | 产品方向：课表日程提醒助手

## 1. 状态与原则

当前 `entry` 已完成基础功能搭建并编译通过。产品方向为课表日程提醒助手，详见 [PRD](prd.md)。

架构边界：

```text
用户登录注册（AuthService）
  -> 课表管理（DataRepository → Schedule/Course）
  -> 日程管理（DataRepository → ScheduleEvent）
  -> 首页仪表盘（聚合今日课程 + 日程）
  -> 提醒设置（ReminderSettings）
  -> 通知触发（NotificationService）
  -> 智能提醒（SmartReminderService）
       -> 读取角色设定（CharacterSetting）
       -> 拼接 system prompt
       -> 调用用户 API（HttpUtil，Key 仅内存）
       -> 成功：角色语气通知 / 失败：回退基础通知
```

不建立后端服务器。API Key 不落盘、不进日志。

## 2. 页面与目录

页面：`LoginPage` 登录注册、`HomePage` 首页、`SchedulePage` 课表、`CalendarPage` 日程、`SettingsPage` 设置入口、`ReminderSettingsPage` 提醒设置、`CharacterSettingsPage` 角色设定、`ApiConfigPage` API 配置。

目录结构：

```text
entry/src/main/ets/
  model/          全局类型与默认值（组长）
  service/        业务服务层（组长搭建）
    PreferencesUtil.ets    本地存储封装
    AuthService.ets        登录注册
    DataRepository.ets     课表/日程/提醒/角色读写
    NotificationService.ets 通知发送
    HttpUtil.ets           AI API 调用
    SmartReminderService.ets 智能提醒
  pages/          页面
```

## 3. 数据模型

| 类型 | 说明 | 存储 |
| --- | --- | --- |
| UserAccount | 用户账户 | global_store（Preferences） |
| Schedule | 课表（含 Course[]） | user_{id} store |
| ScheduleEvent | 日程事件 | user_{id} store |
| ReminderSettings | 提醒设置 | user_{id} store |
| CharacterSetting | 二次元角色设定 | user_{id} store |
| ApiConfig | API 配置 | 非密钥部分存 user_{id} store，Key 仅内存 |

## 4. 安全边界

- API Key 仅保留在 SmartReminderService 内存中，不写入 Preferences。
- API Key 不进入通知内容、日志、URL。
- 密码做简单哈希存储（非真实安全场景）。
- AI 请求超时 10 秒，失败回退基础提醒文案。
