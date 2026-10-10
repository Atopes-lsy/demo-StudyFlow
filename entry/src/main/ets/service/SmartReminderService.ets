import { HttpUtil } from './HttpUtil';
import { NotificationService } from './NotificationService';
import { DataRepository } from './DataRepository';
import { ApiConfig, CharacterSetting, DEFAULT_API_CONFIG, ChatRequest, ChatResponse } from '../model/Types';
import { PreferencesUtil } from './PreferencesUtil';

/**
 * 智能提醒服务
 * 基础提醒文案 → 拼接角色 system prompt → 调用用户 API → 角色语气文案
 * 失败回退基础文案
 */
export class SmartReminderService {
  private static instance: SmartReminderService | null = null;
  private notif: NotificationService;
  private repo: DataRepository;
  private pref: PreferencesUtil;
  private memoryApiKey: string = '';

  private constructor() {
    this.notif = NotificationService.getInstance();
    this.repo = DataRepository.getInstance();
    this.pref = PreferencesUtil.getInstance();
  }

  static getInstance(): SmartReminderService {
    if (!SmartReminderService.instance) {
      SmartReminderService.instance = new SmartReminderService();
    }
    return SmartReminderService.instance;
  }

  setApiKey(key: string): void {
    this.memoryApiKey = key;
  }

  getApiKey(): string {
    return this.memoryApiKey;
  }

  async getApiConfig(userId: string): Promise<ApiConfig> {
    const json = await this.pref.get(userId, 'apiConfig', '') as string;
    if (json) {
      const config = JSON.parse(json) as ApiConfig;
      config.apiKey = this.memoryApiKey;
      return config;
    }
    const def: ApiConfig = {
      provider: DEFAULT_API_CONFIG.provider,
      baseUrl: DEFAULT_API_CONFIG.baseUrl,
      apiKey: this.memoryApiKey,
      model: DEFAULT_API_CONFIG.model,
      temperature: DEFAULT_API_CONFIG.temperature,
      maxTokens: DEFAULT_API_CONFIG.maxTokens,
    };
    return def;
  }

  async saveApiConfig(userId: string, config: ApiConfig): Promise<void> {
    this.memoryApiKey = config.apiKey;
    const toSave: ApiConfig = {
      provider: config.provider,
      baseUrl: config.baseUrl,
      apiKey: '',
      model: config.model,
      temperature: config.temperature,
      maxTokens: config.maxTokens,
    };
    await this.pref.put(userId, 'apiConfig', JSON.stringify(toSave));
  }

  buildCharacterPrompt(character: CharacterSetting): string {
    let prompt = `你是${character.name}，性格${character.personality}，说话风格${character.speechStyle}。`;
    if (character.catchphrase) {
      prompt += `口癖是"${character.catchphrase}"。`;
    }
    prompt += '请用这个角色的语气改写以下提醒内容，保持简洁（50字以内），融入角色特征，但不要遗漏关键信息。';
    return prompt;
  }

  buildBaseReminder(type: string, info: string): string {
    if (type === 'daily') return `今日提醒：${info}`;
    if (type === 'course') return `课前提醒：${info}`;
    if (type === 'event') return `日程提醒：${info}`;
    return info;
  }

  async sendSmartReminder(userId: string, type: string, baseInfo: string): Promise<void> {
    const settings = await this.repo.getReminderSettings(userId);

    if (!settings.smartReminderEnabled) {
      await this.sendBasicReminder(type, baseInfo);
      return;
    }

    const config = await this.getApiConfig(userId);
    if (!config.apiKey) {
      await this.sendBasicReminder(type, baseInfo);
      return;
    }

    const character = await this.repo.getActiveCharacter(userId);
    const baseText = this.buildBaseReminder(type, baseInfo);

    if (!character) {
      await this.sendBasicReminder(type, baseInfo);
      return;
    }

    const systemPrompt = this.buildCharacterPrompt(character);
    const chatRequest: ChatRequest = {
      messages: [
        { role: 'system', content: systemPrompt },
        { role: 'user', content: baseText },
      ],
    };

    const response = await HttpUtil.chatCompletion(config, chatRequest);
    if (response.success && response.content) {
      await this.notif.sendSmartReminder(response.content);
    } else {
      await this.sendBasicReminder(type, baseInfo);
    }
  }

  private async sendBasicReminder(type: string, info: string): Promise<void> {
    const text = this.buildBaseReminder(type, info);
    if (type === 'daily') {
      await this.notif.sendNotification('今日提醒', text);
    } else if (type === 'course') {
      await this.notif.sendNotification('课前提醒', text);
    } else {
      await this.notif.sendNotification('日程提醒', text);
    }
  }
}
