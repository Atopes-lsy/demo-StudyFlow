# 组员 2 详细任务清单

> **角色：** 模型接入与 AI 交互
> **分支：** `feature/record`（远程已存在，本地 `git switch --track origin/feature/record`）
> **代码截止：2026-10-23**　**PPT/报告截止：2026-10-25**

---

## 一、Git 交接规范

### 1. 分支规则

- 只在 `feature/record` 分支开发，**禁止直接修改 `main` 或 `dev`**。
- 开始前同步最新代码：

```bash
git fetch origin
git switch dev
git pull --ff-only origin dev
git switch feature/record
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
[模型设置] 新增: 模型配置页面

- 实现 ModelSettingsPage，支持服务/URL/模型ID/Key 输入
- Key 输入遮蔽显示，不落盘不进日志
- 配置保存到内存，应用重启后需重新输入
```

- 模块前缀：`[模型设置]` `[AI页面]` `[适配器]` `[草稿]` `[测试]`

### 3. Pull Request 规范

- **10.18 18:00** 前提交 `feature/record → dev` 的 PR。
- PR 标题：`组员2: 模型配置、AI生成与草稿编辑确认`。
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
  ai/
    ModelAdapter.ets      # 模型请求适配器
    ModelConfig.ets       # 模型配置（内存态）
    types.ets             # AI 相关类型（如不属于共享契约）
  pages/
    AiPlanPage.ets        # AI 规划页面
    ModelSettingsPage.ets # 模型配置页面
  components/
    DraftEditor.ets       # 草稿编辑器组件
    LoadingState.ets      # 加载/错误状态组件
```

### 2. ArkTS 规范

- **类型：** 共享数据使用组长 `model/` 中定义的类型（AiPlan, DraftPlan 等），**禁止自定义重复版本**。
- **命名：** 页面 `PascalCase`，变量和方法 `camelCase`，常量 `UPPER_SNAKE_CASE`。
- **状态管理：** 页面级用 `@State`，跨组件传引用用 `@Link`，只读传值用 `@Prop`。
- **路由跳转：** 统一使用 `router.pushUrl({ url: 'pages/XxxPage', params: {...} })`。
- **网络请求：** 使用 `@ohos.net.http` 或 `fetch`，超时和错误必须捕获处理。
- **注释：** 仅在复杂逻辑处添加 `//` 注释说明 why，不注释 what。

### 3. 安全红线

- **Key 不落盘：** 模型 API Key 仅保存在内存变量中，**禁止写入 Preferences、文件或任何持久化存储**。
- **Key 不进日志：** `console.log` / `hilog` 中**禁止打印 Key**，调试时用 `***` 遮蔽。
- **失败不默认重试：** 请求失败后展示错误状态，由用户决定是否重试。
- **过期响应不生效：** 如果响应时间戳早于当前请求时间戳，丢弃该响应。

### 4. 依赖约束

- 依赖组长的 `model/`（AiPlan, DraftPlan 等）和 `planning/`（PlanValidator）。
- 生成的草稿在用户确认前不触发保存，确认后调用组员 1 的保存接口。
- 先用假模型响应验证 UI 流程，再接入真实请求。

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
| AI 页标题 | — | `title` |
| 卡片标题 | — | `title_small` |
| 正文/输入文字 | `text_primary` | `body` |
| 辅助信息 | `text_secondary` | `body_small` |
| 提示/占位符 | `text_hint` | `caption` |
| 分割线 | `divider` | — |
| 主按钮 | `primary` / `on_primary` | `body` |
| 错误提示 | `error` | `caption` |
| 遮蔽 Key 文字 | `text_primary` | `body` |
| 未配置提示 | `warning` | `body_small` |

### 3. 你的页面通用组件样式

- **DraftEditor（草稿编辑器）：** `surface` 背景 + `card_radius` 圆角 + `spacing_md` 内边距 + `card_stroke` 边框
- **LoadingState（加载/错误状态）：** 居中布局；加载用系统 `LoadingProgress` + `text_secondary` 文字；错误用 `error` 色图标 + 错误文字 + 重试按钮（`primary` 色）
- **EmptyState（空数据）：** 居中，标题 `text_secondary`/`body`，描述 `text_hint`/`body_small`
- **主按钮：** `primary` 背景 + `on_primary` 文字 + `button_radius` 圆角 + `button_height`
- **输入框（Key/目标输入）：** `surface` 背景 + `divider` 边框（focus 时切 `primary`，error 时切 `error`）+ `input_radius` 圆角 + `input_height`

### 4. 页面布局

- 左右边距：`spacing_md`（16vp）
- 卡片间距：`spacing_sm`（8vp）或 `spacing_md`（16vp）
- 顶部间距：`spacing_lg`（24vp）
- AI 页面内容区由上到下：目标输入 → 生成按钮 → 草稿/结果区，间距 `spacing_md`

### 5. 硬编码检查清单

- [ ] 所有 `backgroundColor()` 使用 `$r('app.color.xxx')`
- [ ] 所有 `fontColor()` 使用 `$r('app.color.xxx')`
- [ ] 所有 `fontSize()` 使用 `$r('app.float.xxx')`
- [ ] 所有 `borderRadius()` 使用 `$r('app.float.xxx')`
- [ ] 所有 `.width()` / `.height()` / `.padding()` 间距用 `$r('app.float.xxx')`
- [ ] Key 输入框使用 `InputType.Password` 遮蔽

---

## 四、测试规范

### 1. 自测清单（每个功能点完成后逐项检查）

- [ ] DevEco Studio 编译无 Error
- [ ] 页面可正常打开，无白屏
- [ ] 模型配置页输入后 Key 遮蔽显示
- [ ] 未配置 Key 时 AI 页面提示先去配置
- [ ] 发送请求后显示加载状态
- [ ] 请求成功后草稿可编辑
- [ ] 请求失败后显示错误提示，不崩溃
- [ ] 取消请求后状态正确回退
- [ ] 确认草稿后触发保存流程
- [ ] Key 不出现在任何日志输出中

### 2. 截图要求

- 每个页面至少 2 张截图：正常状态 + 错误/加载状态。
- 截图存放在 `docs/screenshots/member2/` 目录下，命名：`页面名-状态.png`。
- 示例：`model-settings-normal.png`、`ai-plan-loading.png`、`ai-plan-error.png`、`ai-plan-draft.png`。

### 3. 测试用例文档

- 在 `docs/test-member2.md` 中记录测试用例，格式：

| 用例编号 | 页面 | 操作 | 预期结果 | 实际结果 | 通过 |
| --- | --- | --- | --- | --- | --- |
| A-01 | 模型设置 | 输入 Key | 显示为 •••• 遮蔽 | | |
| A-02 | AI 规划 | 发送目标 | 显示加载动画 | | |
| A-03 | AI 规划 | 请求失败 | 显示错误提示 | | |

---

## 五、步骤与截止时间

### 步骤 1：环境准备与拉取契约

- [ ] 本地配置 DevEco Studio，确认能编译运行模板项目
- [ ] `git fetch origin && git switch --track origin/feature/record`
- [ ] 等待组长通知契约已合入 `dev`（预计 10.10 09:00）
- [ ] `git merge dev` 拉取组长的 `model/` 和 `planning/`
- [ ] 阅读 `model/` 中 AiPlan、DraftPlan 等类型定义，理解字段含义

**DDL：2026-10-10 12:00**

---

### 步骤 2：模型配置页面

- [ ] 实现 `ai/ModelConfig.ets` 模型配置（内存态）：
  - [ ] `service: string` — 服务名称
  - [ ] `baseUrl: string` — 接口地址
  - [ ] `modelId: string` — 模型 ID
  - [ ] `apiKey: string` — API Key（内存，不落盘）
  - [ ] `isConfigured(): boolean` — 判断是否已配置
  - [ ] `clear(): void` — 清除配置
- [ ] 实现 `pages/ModelSettingsPage.ets` 模型配置页：
  - [ ] 服务名称输入
  - [ ] Base URL 输入
  - [ ] 模型 ID 输入
  - [ ] API Key 输入（`type: InputType.Password` 遮蔽显示）
  - [ ] 保存按钮（保存到内存，提示需重新配置则重启后失效）
  - [ ] 清除按钮（清空所有配置）
  - [ ] 未填写完整时保存按钮禁用
- [ ] 在 `main_pages.json` 注册 `pages/ModelSettingsPage` 和 `pages/AiPlanPage` 路由

**DDL：2026-10-12 18:00**

---

### 步骤 3：AI 规划页面骨架（假响应）

- [ ] 实现 `pages/AiPlanPage.ets` AI 规划页骨架：
  - [ ] 目标输入框（用户输入学习目标）
  - [ ] "生成计划"按钮
  - [ ] 加载状态展示（Loading 动画）
  - [ ] 草稿展示区域
  - [ ] 编辑/确认/取消按钮
- [ ] 先用**假模型响应**（硬编码 JSON）验证完整 UI 流程：
  - [ ] 点击生成 → 显示加载 → 返回假草稿 → 可编辑 → 可确认/取消
- [ ] 实现 `components/DraftEditor.ets` 草稿编辑器：
  - [ ] 展示草稿中的任务列表
  - [ ] 每条任务可编辑标题、课程、日期、时长
  - [ ] 可删除某条任务
  - [ ] 可新增任务到草稿

**DDL：2026-10-14 18:00**

---

### 步骤 4：模型适配器（真实请求）

- [ ] 实现 `ai/ModelAdapter.ets` 模型请求适配器：
  - [ ] `generatePlan(goal: string, context: ContextSummary): Promise<AiPlan>`
  - [ ] 使用 `@ohos.net.http` 发送 POST 请求到配置的 Base URL
  - [ ] 请求头携带 `Authorization: Bearer ${apiKey}`（Key 不进日志）
  - [ ] 请求体包含目标和必要上下文摘要
  - [ ] 超时处理（如 30 秒超时）
  - [ ] 错误分类：网络错误 / 认证失败 / 服务端错误 / 超时
  - [ ] 支持取消请求（`AbortController` 或等效机制）
- [ ] 将 ModelAdapter 接入 AiPlanPage，替换假响应
- [ ] 未配置 Key 时点击生成 → 跳转模型设置页或提示

**DDL：2026-10-16 18:00**

---

### 步骤 5：草稿编辑确认流程

- [ ] 完善草稿编辑确认完整流程：
  - [ ] 生成成功 → 草稿展示在 DraftEditor 中
  - [ ] 用户可编辑任意任务字段
  - [ ] 编辑后点击"确认保存"→ 调用 `PlanValidator.validate()` 校验最新数据
  - [ ] 校验通过 → 触发组员 1 的批量保存接口
  - [ ] 校验失败 → 显示校验错误，标记违规字段，不保存
  - [ ] 点击"取消"→ 丢弃草稿，返回初始状态
  - [ ] 重复点击"确认"→ 不重复保存（防重复）
- [ ] 实现 `components/LoadingState.ets` 统一加载/错误状态组件

**DDL：2026-10-17 18:00**

---

### 步骤 6：凭据安全与边界处理

- [ ] 安全检查：
  - [ ] 确认 Key 仅存在于 `ModelConfig` 内存变量中
  - [ ] 全局搜索代码中无 `console.log` / `hilog` 打印 Key
  - [ ] Preferences 中无 Key 存储
  - [ ] 请求失败不自动重试，展示错误由用户决定
  - [ ] 过期响应丢弃（如用户已发起新请求，旧响应不生效）
- [ ] 边界场景：
  - [ ] 网络断开 → 友好提示
  - [ ] Key 错误（401）→ 提示检查配置
  - [ ] 服务端错误（500）→ 提示稍后重试
  - [ ] 响应格式异常 → 提示解析失败
  - [ ] 空草稿 → 提示无有效任务

**DDL：2026-10-18 18:00**

---

### 步骤 7：自测与截图

- [ ] 完成全部自测清单（见三、1）
- [ ] 截图存放到 `docs/screenshots/member2/`
- [ ] 编写 `docs/test-member2.md` 测试用例文档
- [ ] 确认编译无 Error、无 Warning
- [ ] 确认 Key 安全检查全部通过

**DDL：2026-10-18 18:00**

---

### 步骤 8：提交 Pull Request

- [ ] 最终 `git merge dev` 确认无冲突
- [ ] 推送 `git push origin feature/record`
- [ ] 在 GitHub 创建 `feature/record → dev` 的 PR
- [ ] 填写 PR 模板（完成内容、测试情况、注意事项）
- [ ] 通知组长审查

**DDL：2026-10-18 18:00**

---

### 步骤 9：配合联调（10.20 – 10.22）

- [ ] 切到 `dev` 分支，全量编译运行
- [ ] 验证全链路：AI 生成→校验→编辑→确认→保存→首页更新
- [ ] 修复联调中发现的自身模块问题
- [ ] 确认 `main` 分支最终编译通过

**DDL：2026-10-22 12:00**

---

### 步骤 10：PPT 与报告（10.23 – 10.25）

- [ ] 撰写 800 字个人感想（协作过程、遇到的问题及解决）
- [ ] 准备答辩 PPT 个人部分（2 分钟）：
  - [ ] 模型配置页演示截图
  - [ ] AI 生成流程演示（目标输入→生成→加载→草稿展示）
  - [ ] 草稿编辑确认演示
  - [ ] 错误处理与凭据安全说明
- [ ] 提交给组长整合

**DDL：2026-10-24 18:00**
