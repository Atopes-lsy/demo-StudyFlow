# 智能提醒 API 配置规格

> 版本：2.0 | 日期：2026-10-10

## 1. 范围

用户自行配置 AI API（OpenAI 兼容格式），用于智能提醒文案生成。提醒内容先由基础模板生成，再拼接角色 system prompt 调用用户 API 改写为角色语气。

不建立后端服务器，不由小组接收 Key。端侧直连用户配置的 API。

## 2. 配置项

| 配置 | 说明 | 是否落盘 |
| --- | --- | --- |
| 提供商类型 | OpenAI 兼容 / 自定义 | 是 |
| Base URL | API 基础地址（如 https://api.openai.com/v1） | 是 |
| 模型名 | 如 gpt-4o-mini | 是 |
| API Key | 鉴权密钥 | **否，仅内存** |
| 温度 | 0-1，默认 0.7 | 是 |
| 最大 Token | 默认 500 | 是 |

## 3. 请求格式

```json
POST {baseUrl}/chat/completions
Header: Authorization: Bearer {apiKey}
Body: {
  "model": "{model}",
  "messages": [
    { "role": "system", "content": "{角色语气提示词}" },
    { "role": "user", "content": "{基础提醒文案}" }
  ],
  "temperature": 0.7,
  "max_tokens": 500
}
```

## 4. 角色提示词模板

```
你是{角色名}，性格{性格特征}，说话风格{说话风格}。口癖是"{口癖}"。
请用这个角色的语气改写以下提醒内容，保持简洁（50字以内），融入角色特征，但不要遗漏关键信息。
```

## 5. 降级策略

- API Key 未配置 → 回退基础提醒文案
- API 调用失败/超时（10秒） → 回退基础提醒文案
- 未启用智能提醒 → 使用基础提醒文案
- 未设定角色 → 使用基础提醒文案

## 6. 安全边界

- Key 仅保留在 SmartReminderService 内存中，不写入 Preferences。
- Key 不进入 URL、提示词、通知内容、日志、截图。
- 进程结束后 Key 丢失，需重新输入。
