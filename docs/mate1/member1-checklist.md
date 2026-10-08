# 组员 1 详细任务清单

> **角色：** 本地业务与数据
> **分支：** `feature/task`（远程已存在，本地 `git switch --track origin/feature/task`）
> **代码截止：2026-10-23**　**PPT/报告截止：2026-10-25**

---

## 一、Git 交接规范

### 1. 分支规则

- 只在 `feature/task` 分支开发，**禁止直接修改 `main` 或 `dev`**。
- 开始前同步最新代码：

```bash
git fetch origin
git switch dev
git pull --ff-only origin dev
git switch feature/task
git merge dev   # 将组长的契约合入自己的分支
```

- 如果 `merge dev` 出现冲突，**只解决自己文件中的冲突**，契约文件（`model/`、`planning/`）以组长版本为准，不得自行修改。

### 2. 提交规范

- 每个**可独立运行的功能点**一次提交，不要攒一大堆一次提交。
- Commit message 格式：

```
[模块] 动作: 简述

- 具体改动 1
- 具体改动 2
```

示例：

```
[任务] 新增: 任务列表页面

- 实现 TaskPage 列表展示，使用 TaskCard 组件
- 支持按完成状态筛选
- 从 TaskRepository 读取数据
```

- 模块前缀：`[导航]` `[首页]` `[任务]` `[记录]` `[仓库]` `[测试]`

### 3. Pull Request 规范

- **10.18 18:00** 前提交 `feature/task → dev` 的 PR。
- PR 标题：`组员1: 首页、任务管理、学习记录与本地仓库`。
- PR 描述使用仓库模板，填写：
  - 本次完成内容（逐条列出）
  - 测试情况（列出测试用例与结果）
  - 需要注意的问题（如有）
- 如果组长审查后要求修改，**在原分支继续提交**，不要关闭 PR 重开。

---

## 二、代码规范

### 1. 文件与目录

```
entry/src/main/ets/
  repository/
    TaskRepository.ets    # 任务本地仓库
    RecordRepository.ets  # 学习记录本地仓库
  pages/
    Index.ets             # 首页仪表盘
    TaskPage.ets          # 任务列表
    TaskEditPage.ets      # 新增/编辑任务表单
    RecordPage.ets        # 学习记录
  components/
    TaskCard.ets          # 任务卡片
    StatCard.ets          # 统计卡片
```

### 2. ArkTS 规范

- **类型：** 所有数据使用组长 `model/` 中定义的类型，**禁止自定义重复版本**。
- **命名：** 页面 `PascalCase`，变量和方法 `camelCase`，常量 `UPPER_SNAKE_CASE`。
- **状态管理：** 页面级用 `@State`，跨组件传引用用 `@Link`，只读传值用 `@Prop`。
- **路由跳转：** 统一使用 `router.pushUrl({ url: 'pages/XxxPage', params: {...} })`。
- **存储：** 所有数据读写必须经过 `repository/`，**禁止页面直接调用 PreferencesHelper**。
- **注释：** 仅在复杂逻辑处添加 `//` 注释说明 why，不注释 what。

### 3. 依赖约束

- 依赖组长的 `model/`（Task, StudyRecord, DraftPlan 等）和 `planning/`（PlanValidator）。
- 确认保存前调用 `PlanValidator.validate()`，校验失败不保存。
- 与组员 2 的交接点：组员 2 生成草稿后，组员 1 负责确认后的批量保存。

---

## 三、视觉规范

> 所有页面样式必须遵循项目的统一视觉设计指南：`docs/team/ui-style.md`。
> 引用系统 token，禁止硬编码颜色、字号、间距。

### 1. Token 引用规则

- **颜色：** `$r('app.color.xxx')` — 所有颜色值必须从 `color.json` 取
- **字号：** `$r('app.float.xxx')` — 所有字号必须从 `float.json` 取
- **间距：** `$r('app.float.xxx')` — 所有 spacing 必须从 `float.json` 取
- **圆角：** `$r('app.float.xxx')` — 所有 borderRadius 必须从 `float.json` 取

### 2. 你的页面用到的主要 token

| 场景 | 颜色 Token | 字号 Token |
| --- | --- | --- |
| 页面背景 | `background` | — |
| 卡片背景 | `surface` | — |
| 卡片边框 | `card_stroke` | — |
| 大标题 | — | `title_large`（首页欢迎语） |
| 卡片标题 | — | `title_small` |
| 正文/列表文字 | `text_primary` | `body` |
| 辅助信息 | `text_secondary` | `body_small` |
| 提示/占位符 | `text_hint` | `caption` |
| 分割线 | `divider` | — |
| 主按钮 | `primary` / `on_primary` | `body` |
| 完成状态 | `success` | `caption` |
| 删除/错误 | `error` | `caption` |
| 高优先级标签 | `priority_high` | `caption` |
| 中优先级标签 | `priority_medium` | `caption` |
| 低优先级标签 | `priority_low` | `caption` |

### 3. 你的页面通用组件样式

- **TaskCard：** 使用 `surface` 背景 + `card_radius` 圆角 + `spacing_md` 内边距 + 可选 `card_stroke` 边框
- **StatCard（首页统计卡片）：** 使用 `primary_container` 背景 + `card_radius` 圆角
- **EmptyState（空数据）：** 居中，标题 `text_secondary`/`body`，描述 `text_hint`/`body_small`
- **主按钮：** `primary` 背景 + `on_primary` 文字 + `button_radius` 圆角 + `button_height`
- **表单输入框：** `surface` 背景 + `divider` 边框（focus 时切 `primary`，error 时切 `error`）+ `input_radius` 圆角 + `input_height`

### 4. 页面布局

- 左右边距：`spacing_md`（16vp）
- 卡片间距：`spacing_sm`（8vp）或 `spacing_md`（16vp）
- 顶部间距：`spacing_lg`（24vp）
- 列表项内边距：`spacing_md`

### 5. 硬编码检查清单

- [ ] 所有 `backgroundColor()` 使用 `$r('app.color.xxx')`
- [ ] 所有 `fontColor()` 使用 `$r('app.color.xxx')`
- [ ] 所有 `fontSize()` 使用 `$r('app.float.xxx')`
- [ ] 所有 `borderRadius()` 使用 `$r('app.float.xxx')`
- [ ] 所有 `.width()` / `.height()` / `.padding()` 间距用 `$r('app.float.xxx')`
- [ ] 优先级标签配色使用 `priority_high/medium/low` token

---

## 四、测试规范

### 1. 自测清单（每个功能点完成后逐项检查）

- [ ] DevEco Studio 编译无 Error
- [ ] 页面可正常打开，无白屏
- [ ] 操作后数据正确写入本地存储
- [ ] 应用重启后数据可恢复
- [ ] 空数据状态有占位提示，不崩溃
- [ ] 异常输入（空标题、过去日期）有拦截提示

### 2. 截图要求

- 每个页面至少 2 张截图：正常状态 + 空数据/异常状态。
- 截图存放在 `docs/screenshots/member1/` 目录下，命名：`页面名-状态.png`。
- 示例：`task-list-normal.png`、`task-list-empty.png`、`task-edit-error.png`。

### 3. 测试用例文档

- 在 `docs/test-member1.md` 中记录测试用例，格式：

| 用例编号 | 页面 | 操作 | 预期结果 | 实际结果 | 通过 |
| --- | --- | --- | --- | --- | --- |
| T-01 | 任务列表 | 打开页面 | 显示所有任务 | | |
| T-02 | 新增任务 | 填写完整信息并保存 | 列表新增一条 | | |

---

## 五、步骤与截止时间

### 步骤 1：环境准备与拉取契约

- [ ] 本地配置 DevEco Studio，确认能编译运行模板项目
- [ ] `git fetch origin && git switch --track origin/feature/task`
- [ ] 等待组长通知契约已合入 `dev`（预计 10.10 09:00）
- [ ] `git merge dev` 拉取组长的 `model/` 和 `planning/`
- [ ] 阅读 `model/` 中所有类型定义，理解字段含义

**DDL：2026-10-10 12:00**

---

### 步骤 2：工程导航与首页骨架

- [ ] 在 `main_pages.json` 注册所有页面路由（Index, TaskPage, TaskEditPage, RecordPage）
- [ ] 实现 `pages/Index.ets` 首页仪表盘骨架：
  - [ ] 顶部用户问候 + 日期
  - [ ] 今日任务数量统计卡片
  - [ ] 已完成 / 完成率进度条
  - [ ] 今日学习时长 / 打卡状态
  - [ ] 底部 TabBar 或快捷入口（任务、记录、AI 规划、模型设置）
- [ ] 页面跳转验证：从首页能进入任务页和记录页

**DDL：2026-10-12 18:00**

---

### 步骤 3：本地仓库实现

- [ ] 实现 `repository/TaskRepository.ets`：
  - [ ] `getAllTasks(): Task[]` — 读取全部任务
  - [ ] `getTaskById(id: string): Task | undefined`
  - [ ] `addTask(task: Task): boolean` — 新增
  - [ ] `updateTask(task: Task): boolean` — 编辑
  - [ ] `deleteTask(id: string): boolean` — 删除
  - [ ] `toggleComplete(id: string): boolean` — 切换完成状态
  - [ ] 数据持久化到 Preferences，重启可恢复
- [ ] 实现 `repository/RecordRepository.ets`：
  - [ ] `getAllRecords(): StudyRecord[]`
  - [ ] `addRecord(record: StudyRecord): boolean`
  - [ ] `getTodayMinutes(): number` — 今日学习时长

**DDL：2026-10-14 18:00**

---

### 步骤 4：任务管理页面

- [ ] 实现 `pages/TaskPage.ets` 任务列表：
  - [ ] 从 TaskRepository 加载任务列表
  - [ ] 使用 TaskCard 组件展示每条任务
  - [ ] 支持按状态筛选（全部 / 未完成 / 已完成）
  - [ ] 支持按优先级筛选
  - [ ] 点击任务进入编辑页
  - [ ] 左滑或长按删除任务（带确认弹窗）
  - [ ] 切换完成状态（Checkbox 或滑动）
  - [ ] 空数据占位提示
- [ ] 实现 `pages/TaskEditPage.ets` 新增/编辑表单：
  - [ ] 标题输入（必填校验）
  - [ ] 课程选择/输入
  - [ ] 优先级选择（高/中/低）
  - [ ] 计划日期选择
  - [ ] 截止日期选择（不能早于计划日期）
  - [ ] 预计时长输入
  - [ ] 保存调用 TaskRepository，返回列表页刷新
- [ ] 实现 `components/TaskCard.ets` 任务卡片组件

**DDL：2026-10-14 18:00**

---

### 步骤 5：学习记录页面

- [ ] 实现 `pages/RecordPage.ets` 学习记录：
  - [ ] 今日打卡按钮
  - [ ] 学习时长输入（分钟）
  - [ ] 学习备注输入
  - [ ] 保存到 RecordRepository
  - [ ] 历史记录列表（按日期倒序）
  - [ ] 历史记录展示日期、时长、备注
  - [ ] 空数据占位提示

**DDL：2026-10-17 18:00**

---

### 步骤 6：草稿批量保存与防重复

- [ ] 实现 `repository/` 中的草稿保存逻辑：
  - [ ] `saveDrafts(drafts: DraftPlan[], clientDraftId: string): boolean`
  - [ ] 按客户端草稿 ID 防重复写入
  - [ ] 未确认的草稿不保存（零写入）
  - [ ] 保存前调用 `PlanValidator.validate()` 校验最新数据
  - [ ] 保存失败可恢复（事务性：要么全成功，要么不写入）
- [ ] 与组员 2 对接确认接口：组员 2 的确认动作触发组员 1 的保存

**DDL：2026-10-17 18:00**

---

### 步骤 7：首页数据联动

- [ ] 首页统计数据从 TaskRepository 和 RecordRepository 实时读取
- [ ] 任务完成/新增后返回首页，统计自动刷新
- [ ] 学习打卡后首页时长更新
- [ ] 确认保存草稿后首页任务列表更新

**DDL：2026-10-18 18:00**

---

### 步骤 8：自测与截图

- [ ] 完成全部自测清单（见三、1）
- [ ] 截图存放到 `docs/screenshots/member1/`
- [ ] 编写 `docs/test-member1.md` 测试用例文档
- [ ] 确认编译无 Error、无 Warning

**DDL：2026-10-18 18:00**

---

### 步骤 9：提交 Pull Request

- [ ] 最终 `git merge dev` 确认无冲突
- [ ] 推送 `git push origin feature/task`
- [ ] 在 GitHub 创建 `feature/task → dev` 的 PR
- [ ] 填写 PR 模板（完成内容、测试情况、注意事项）
- [ ] 通知组长审查

**DDL：2026-10-18 18:00**

---

### 步骤 10：配合联调（10.20 – 10.22）

- [ ] 切到 `dev` 分支，全量编译运行
- [ ] 验证全链路：AI 生成→校验→编辑→确认→保存→首页更新
- [ ] 修复联调中发现的自身模块问题
- [ ] 确认 `main` 分支最终编译通过

**DDL：2026-10-22 12:00**

---

### 步骤 11：PPT 与报告（10.23 – 10.25）

- [ ] 撰写 800 字个人感想（协作过程、遇到的问题及解决）
- [ ] 准备答辩 PPT 个人部分（2 分钟）：
  - [ ] 首页仪表盘演示截图
  - [ ] 任务管理演示（新增、编辑、删除、完成）
  - [ ] 学习记录演示
  - [ ] 本地存储与数据恢复说明
- [ ] 提交给组长整合

**DDL：2026-10-24 18:00**
