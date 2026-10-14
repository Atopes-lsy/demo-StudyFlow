# 组员 1 工作清单

> 版本：2.1 | 日期：2026-10-14 | 产品方向：课表日程提醒助手
>
> 详见 [PRD](../team/prd.md)。前端后续用 Figma 替换，当前代码仅保证功能跑通。

## 负责模块

登录注册、课表管理、日程管理、首页仪表盘。

## 已有基础（组长已搭建）

- `service/AuthService.ets` — 登录注册逻辑已完成
- `service/DataRepository.ets` — 课表/日程数据读写已完成
- `pages/LoginPage.ets` — 登录注册页面已创建
- `pages/HomePage.ets` — 首页仪表盘已创建
- `pages/SchedulePage.ets` — 课表管理页已创建
- `pages/CalendarPage.ets` — 日程管理页已创建
- `model/Types.ets` — 全局类型已定义

## 本次补充（2026-10-14，分支 `feature/task`）

- 课表页：**课程编辑** —— 新增/编辑复用同一表单；编辑时保留表单外的字段（weeks/color/remark）
- 课表页：**学期设置** —— 学期名称、当前周、总周数可修改，当前周自动钳制在 1..总周数
- 日程页：**日程编辑** —— 新增/编辑复用同一表单；编辑时保留 description/endTime/remindBefore/completed 等字段
- 日程页：**日程类型筛选** —— 全部 / 考试 / 会议 / 截止日 / 活动 / 自定义
- 首页：**下拉刷新**（Refresh 组件）；今日日程与"即将到来"改为显示中文类型标签

> 本机未安装 DevEco Studio/SDK，上述代码仅通过静态检查（资源引用有效、括号配平），**编译与真机运行待验证**。

## 待办

### SF-01 登录注册
- [x] 注册→登录→登出完整流程（代码就绪：LoginPage / AuthService / SettingsPage 退出登录）
- [x] 重启后保持登录态（代码就绪：EntryAbility.restoreSession）
- [x] 不同用户数据隔离（代码就绪：PreferencesUtil 按 `user_{id}` 建库）
- [ ] 真机验证以上三项

### SF-02 课表管理
- [x] 添加/删除课程
- [x] 按周几分组展示
- [x] 首页按当前周次/星期过滤今日课程
- [x] 补充课程编辑功能
- [x] 补充学期设置（当前周/总周数可修改）
- [ ] 真机验证

### SF-03 日程管理
- [x] 添加/删除/标记完成日程
- [x] 首页展示今日日程和即将到来
- [x] 补充日程编辑功能
- [x] 补充日程类型筛选
- [ ] 真机验证

### SF-04 首页仪表盘
- [x] 首页概览数据（今日课程数 / 日程数 / 未完成数）
- [x] 空状态展示
- [x] 补充下拉刷新
- [ ] 真机验证

### 测试与截图
- [x] 编写测试用例文档（`docs/team/test-report.md` 组员 1 用例）
- [ ] 每个页面至少 2 张截图（需真机/模拟器）
- [ ] 验证编译、白屏、数据写入（需 DevEco Studio）

## 分支

`feature/task` — 在此分支开发，完成后 PR 到 `dev`
