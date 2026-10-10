import { http } from '@kit.NetworkKit';
import { ApiConfig, ChatRequest, ChatResponse } from '../model/Types';

/** HTTP 请求头 */
interface HttpHeader {
  'Content-Type': string;
  'Authorization': string;
}

/** 连接测试结果 */
interface ConnectionResult {
  success: boolean;
  error?: string;
}

/** AI 响应中的消息 */
interface ResponseMessage {
  content?: string;
}

/** AI 响应中的选项 */
interface ResponseChoice {
  message?: ResponseMessage;
}

/** Chat Completions 响应体 */
interface ChatCompletionResponse {
  choices?: ResponseChoice[];
}

/**
 * HTTP 工具 — 调用用户配置的 AI API
 * API Key 仅在内存中传递，不落盘不进日志
 */
export class HttpUtil {
  static async chatCompletion(config: ApiConfig, request: ChatRequest): Promise<ChatResponse> {
    if (!config.apiKey) {
      const r: ChatResponse = { success: false, content: '', error: 'API Key 未配置' };
      return r;
    }
    if (!config.baseUrl) {
      const r: ChatResponse = { success: false, content: '', error: 'Base URL 未配置' };
      return r;
    }

    try {
      const httpRequest = http.createHttp();
      const url = `${config.baseUrl}/chat/completions`;
      const body = JSON.stringify({
        model: config.model,
        messages: request.messages,
        temperature: request.temperature ?? config.temperature ?? 0.7,
        max_tokens: request.maxTokens ?? config.maxTokens ?? 500,
      });

      const header: HttpHeader = {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${config.apiKey}`,
      };

      const response = await httpRequest.request(url, {
        method: http.RequestMethod.POST,
        header: header,
        extraData: body,
        connectTimeout: 10000,
        readTimeout: 10000,
      });

      httpRequest.destroy();

      if (response.responseCode === 200) {
        const result = JSON.parse(response.result as string) as ChatCompletionResponse;
        const content = result.choices?.[0]?.message?.content || '';
        const r: ChatResponse = { success: true, content: content };
        return r;
      } else {
        const r: ChatResponse = { success: false, content: '', error: `HTTP ${response.responseCode}` };
        return r;
      }
    } catch (e) {
      const r: ChatResponse = { success: false, content: '', error: `请求失败: ${JSON.stringify(e)}` };
      return r;
    }
  }

  static async testConnection(config: ApiConfig): Promise<ConnectionResult> {
    const response = await HttpUtil.chatCompletion(config, {
      messages: [
        { role: 'user', content: 'Hi' },
      ],
      maxTokens: 10,
    });
    const r: ConnectionResult = { success: response.success, error: response.error };
    return r;
  }
}
