# GitHub 协作规范

> 版本：2.0 | 日期：2026-10-10

## 1. 分支与职责

| 分支 | 用途 |
| --- | --- |
| main | 稳定演示与作业版本 |
| dev | 日常集成与共同联调 |
| feature/task | 组员 1 的登录注册、课表、日程、首页 |
| feature/record | 组员 2 的通知、提醒设置、API、角色、智能提醒 |

默认不直接修改 main/dev，在功能分支开发后 PR 到 dev。

## 2. 开始开发

```text
git fetch origin
git switch dev
git pull --ff-only origin dev
git switch feature/task  # 或 feature/record
git merge origin/dev     # 合入最新 dev
```

## 3. Commit 规范

格式：`[模块]动作:简述`

示例：
- `[auth]fix: 修复登录态恢复`
- `[schedule]feat: 添加课程编辑功能`
- `[reminder]feat: 实现定时课前提醒`
- `[api]fix: 修复连接测试超时`

## 4. PR 规范

- PR 标题同 commit 格式。
- PR 描述说明改动范围、测试情况。
- 至少一人 review 后合并。
- PR 在 10/18 前提交。

## 5. Issue 与验收

| 任务 | 责责人 | 交付 |
| --- | --- | --- |
| 登录注册+课表+日程+首页 | 组员 1 | 功能完善、测试、截图 |
| 通知+提醒+API+角色+智能提醒 | 组员 2 | 功能完善、安全验证、测试、截图 |
| PR 评审+报告+答辩 | 组长 | 整合、总述 |
