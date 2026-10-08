# StudyFlow 架构与契约

## 1. 状态与原则

当前 `entry` 只有能力、资源与首页模板。以下为拟定结构，先合入最小契约与假数据，再由三人并行实现。不建立代收用户模型 Key 的后端。

架构边界：

```text
模型设置 / AI 页面（组员 2）
  -> ModelAdapter：模型请求、会话 Key、取消与错误处理（组员 2）
  -> 原始响应
  -> PlanValidator：解析、结构与业务规则校验（组长）
  -> 可编辑草稿
  -> 用户确认、获取最新上下文、重新校验
  -> TaskRepository：批量保存、防重复、状态更新（组员 1）
  -> 首页 / 任务 / 学习记录（组员 1）
```

模型服务仅接收必要目标和用户授权的摘要。MCP 是后续独立工具连接，不使用模型 Key 作为凭据，端侧可行性尚未验证。

## 2. 页面与目录

首期页面：`Index` 首页、`TaskPage` 任务、`TaskEditPage` 表单、`RecordPage` 记录、`AiPlanPage` 规划与草稿、`ModelSettingsPage` 模型配置。

拟定目录：

```text
entry/src/main/ets/
  model/          共享契约与类型（组长）
  planning/       输出解析、规则校验（组长）
  repository/     本地数据与批量保存（组员 1）
  ai/             模型适配与会话凭据（组员 2）
  components/     业务页面所需组件（对应页面负责人）
  pages/          页面与交互（组员 1 / 组员 2）
```

组员 1 维护导航及业务页注册，组员 2 在自己的 PR 注册 AI 页；公共组件由使用者实现，不默认分配给组长。

## 3. 数据契约

日期固定为 `YYYY-MM-DD` 的真实日历日期；时间戳使用独立字段，不能混用。以下字段待以 ArkTS 类型落地，修改须共同确认。

| 类型 | 核心字段 | 说明 |
| --- | --- | --- |
| Task | id, title, course, priority, plannedDate, deadline, estimatedMinutes, completed, createdAt | priority 为 low/medium/high；手动任务可缺计划日期或时长，缺失须显式表示 |
| StudyRecord | id, date, minutes, note | minutes 为正整数；记录实际学习而非预测 |
| LearningContext | asOfDate, targetDeadline, dailyBudgetMinutes, tasks, contextVersion | 确定性输入；版本用于检查生成后上下文是否变化 |
| PlanDraft | draftId, items, contextVersion | draftId 由客户端生成，不信任模型提供的保存标识 |
| PlanItem | title, course, priority, plannedDate, estimatedMinutes | AI 条目必须有计划日期与时长，不默认填零 |
| ValidationIssue | code, itemIndex, field, message, severity | 页面可定位错误，结构缺失时 itemIndex 可为空 |
| ValidationResult | valid, normalizedDraft, errors, warnings | 未通过时不产生可保存任务 |
| ModelConfig | provider, baseUrl, modelId | 非密钥配置，可持久化 |

Key 使用独立会话对象；不能放入 ModelConfig、任务仓库或配置导出。未安排或未知时长的已有任务产生上下文警告，需用户补全后再次规划或确认无法覆盖的边界。

## 4. 接口约定

| 接口意图 | 负责人 | 合同 |
| --- | --- | --- |
| 获取学习上下文 | 组员 1 | 返回当前任务摘要及数据版本，不暴露底层存储 |
| 生成原始计划 | 组员 2 | 接收目标、授权摘要和非密钥配置；不写入任务 |
| 解析并校验草稿 | 组长 | 接收原始响应或编辑后的草稿及显式上下文，返回结构化结果 |
| 确认并批量保存 | 组员 1 | 保存前调用校验器检查最新上下文，验证版本并执行防重复提交 |

不得只依赖页面按钮禁用实现防重复。按 draftId 记录提交状态，防止重复确认；批量保存失败不能留下用户未知的部分成功结果，具体原子写入或恢复方案在实现前由仓库负责人验证。

## 5. 校验器与测试设计

校验器不依赖页面、真实模型、网络、Key 或隐式系统时间。明确传入当天、目标截止日、每日预算和已有任务，便于固定数据测试。

检查顺序：

1. 解析与结构：数据能解析，必填字段和枚举正确。
2. 单项：真实日历日期、正整数分钟、标题非空。
3. 目标：计划日期位于当天至目标截止日内。
4. 汇总：每日草稿加已有未完成任务不超过预算，缺失信息提示不完整。
5. 保存前：用户修改后重新校验；上下文变动则重算，不使用旧的通过状态。

首期只做规则校验，不声称最优排程、全时段冲突检测或自主训练模型。通过固定测试集和实际日志评估正确性，不用一次成功截图代替证据。

## 6. 状态与生命周期

- 首页和业务页通过仓库刷新，不维护互相独立的任务副本。
- AI 请求具有唯一请求标识；取消、超时、清除 Key 或更换配置后，旧响应不可更新草稿。
- 后台返回时 Key 输入重新遮蔽，进程结束后不恢复 Key。
- 加载、空数据、字段错误、鉴权失败、限流、取消和保存失败均有可见状态。
- Key 生命周期、地址校验、TLS 与费用边界见[模型配置规格](model-configuration.md)。

## 7. 实施顺序

契约和假数据先合入 `dev`；组员 1 做本地业务，组员 2 用假响应跑通页面，组长完成校验器。随后验证真实模型、共同联调与回归。基础验收后才评估 MCP。职责与评审范围见[分工](task-division.md)。
