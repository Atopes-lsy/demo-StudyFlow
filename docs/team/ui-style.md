# StudyFlow 视觉设计指南

> 本文档定义项目统一视觉规范，所有页面必须遵守。
> **Token 已定义在 `color.json` 和 `float.json` 中，页面中统一用 `$r('app.color.xxx')` / `$r('app.float.xxx')` 引用，禁止硬编码数值。**

---

## 1. 色彩体系

### 1.1 品牌色

| Token | 亮色 | 暗色 | 用途 |
| --- | --- | --- | --- |
| `primary` | `#4A7CF7` | `#6B9AF7` | 主按钮、导航栏、链接、选中态 |
| `primary_container` | `#E8F0FE` | `#1E2A4A` | 卡片背景、标签底色 |
| `secondary` | `#34C759` | `#30D158` | 成功/已完成状态 |

### 1.2 背景与表面

| Token | 亮色 | 暗色 | 用途 |
| --- | --- | --- | --- |
| `background` | `#F5F5F5` | `#121212` | 页面背景 |
| `surface` | `#FFFFFF` | `#1E1E1E` | 卡片/列表项/弹窗背景 |
| `card_stroke` | `#E8E8E8` | `#333333` | 卡片边框 |
| `divider` | `#E8E8E8` | `#333333` | 分割线 |

### 1.3 文字

| Token | 亮色 | 暗色 | 用途 |
| --- | --- | --- | --- |
| `text_primary` | `#1A1A1A` | `#E0E0E0` | 页面标题、正文 |
| `text_secondary` | `#666666` | `#999999` | 副标题、辅助说明 |
| `text_hint` | `#999999` | `#666666` | 占位符、提示文字 |
| `text_disabled` | `#CCCCCC` | `#555555` | 禁用态文字 |
| `on_primary` | `#FFFFFF` | `#FFFFFF` | 主色按钮上的文字 |

### 1.4 状态色

| Token | 亮色 | 暗色 | 用途 |
| --- | --- | --- | --- |
| `success` | `#34C759` | `#30D158` | 已完成、打卡成功 |
| `warning` | `#FF9500` | `#FF9F0A` | 即将截止、校验警告 |
| `error` | `#FF3B30` | `#FF453A` | 错误、删除、校验失败 |

### 1.5 优先级色

| Token | 值 | 用途 |
| --- | --- | --- |
| `priority_high` | 同 `error` | 高优先级标签 |
| `priority_medium` | 同 `warning` | 中优先级标签 |
| `priority_low` | 同 `success` | 低优先级标签 |

---

## 2. 字号体系

| Token | 值 | 应用场景 |
| --- | --- | --- |
| `title_large` | **24fp** | 页面大标题（如首页欢迎语） |
| `title` | **20fp** | 页面标题、卡片标题 |
| `title_small` | **18fp** | 章节标题、表单标题 |
| `body` | **16fp** | 正文、列表项标题 |
| `body_small` | **14fp** | 次要信息、输入框文字 |
| `caption` | **12fp** | 时间戳、标签、提示文字 |

**字重规则：** 标题用 `FontWeight.Bold`，正文用 `FontWeight.Regular`，辅助文字用 `FontWeight.Regular`。

---

## 3. 间距体系

| Token | 值 | 应用场景 |
| --- | --- | --- |
| `spacing_xs` | **4vp** | 紧凑元素间距、图标与文字间隙 |
| `spacing_sm` | **8vp** | 控件内部间距、标签间距 |
| `spacing_md` | **16vp** | 卡片内边距、列表项间距 |
| `spacing_lg` | **24vp** | 大卡片间距、列表与屏幕边缘 |
| `spacing_xl` | **32vp** | 页面顶部/底部大留白 |

---

## 4. 圆角规范

| Token | 值 | 应用场景 |
| --- | --- | --- |
| `card_radius` | **12vp** | 卡片、弹窗 |
| `button_radius` | **10vp** | 按钮 |
| `input_radius` | **8vp** | 输入框、搜索栏 |

---

## 5. 通用组件约定

### 5.1 卡片（Card）

```
background: $r('app.color.surface')
borderRadius: $r('app.float.card_radius')
padding: $r('app.float.spacing_md')
可选 1vp 边框：stroke $r('app.color.card_stroke')
阴影：可加，不做统一要求
```

### 5.2 主按钮（Primary Button）

```
background: $r('app.color.primary')
文字颜色: $r('app.color.on_primary')
fontSize: $r('app.float.body')
borderRadius: $r('app.float.button_radius')
height: $r('app.float.button_height')
禁用态: background → $r('app.color.disabled'), 文字 → $r('app.color.disabled_text')
```

### 5.3 输入框（Input）

```
background: $r('app.color.surface')
border: 1vp solid $r('app.color.divider')
borderRadius: $r('app.float.input_radius')
height: $r('app.float.input_height')
padding: 0 $r('app.float.spacing_md')
focus: border → $r('app.color.primary')
error: border → $r('app.color.error')
```

### 5.4 空数据占位（EmptyState）

```
居中布局
图标: 可选
标题: $r('app.float.body'), $r('app.color.text_secondary')
描述: $r('app.float.body_small'), $r('app.color.text_hint')
```

### 5.5 加载/错误状态（LoadingState）

```
居中布局
加载中: 系统 LoadingProgress + 文字 "加载中..."
加载失败: 错误图标 + 错误说明 + "重试"按钮
```

### 5.6 状态标签（Tag/Badge）

```
padding: 4vp 12vp
borderRadius: 4vp
fontSize: $r('app.float.caption')

优先级标签:
  高 → background: $r('app.color.priority_high') + 白色文字
  中 → background: $r('app.color.priority_medium') + 白色文字
  低 → background: $r('app.color.priority_low') + 白色文字

完成状态标签:
  已完成 → background: $r('app.color.primary_container') + $r('app.color.primary')
  未完成 → background: $r('app.color.surface') + $r('app.color.text_secondary')
```

---

## 6. 页面布局规范

- **页面边距：** 左右 `$r('app.float.spacing_md')`（16vp），顶部 `$r('app.float.spacing_lg')`（24vp）
- **卡片与卡片间距：** `$r('app.float.spacing_sm')`（8vp）或 `$r('app.float.spacing_md')`（16vp）
- **页面背景：** `$r('app.color.background')`，卡片背景 `$r('app.color.surface')`
- **列表项：** 使用 `ListItem` 包裹，高度自适应，内边距 `$r('app.float.spacing_md')`

---

## 7. 状态可见性规范（所有页面强制执行）

每个页面必须处理以下状态：

| 状态 | 视觉要求 |
| --- | --- |
| 正常数据 | 内容完整展示 |
| 空数据 | 使用 EmptyState 样式，不可出现空白页 |
| 加载中 | 使用 LoadingState 样式 |
| 加载失败 | 显示错误原因 + 重试入口 |
| 字段输入错误 | 输入框边框变 `error` 色 + 底部错误文字 |
| 保存失败 | Toast 提示 + 保留用户未丢失的输入 |
| 无网络 | 友好提示，不崩溃 |

---

## 8. 引用示例

```typescript
// 正确 ✅ — 使用系统 token
Text('任务列表')
  .fontSize($r('app.float.title'))
  .fontColor($r('app.color.text_primary'))

Button('新增任务')
  .backgroundColor($r('app.color.primary'))
  .fontColor($r('app.color.on_primary'))
  .borderRadius($r('app.float.button_radius'))
  .height($r('app.float.button_height'))

// 错误 ❌ — 硬编码数值
Text('任务列表')
  .fontSize(20)           // 禁止
  .fontColor('#1A1A1A')   // 禁止
```

---

## 9. 修改流程

如需修改视觉 token 或本指南：
1. 组长确认后更新 `color.json` / `float.json` / `ui-style.md`
2. 通知全员 `git pull`
3. 各人搜索自己页面中的硬编码颜色/字号，替换为新的 token
