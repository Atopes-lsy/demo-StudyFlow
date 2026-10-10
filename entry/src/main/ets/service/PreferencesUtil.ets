import { preferences } from '@kit.ArkData';
import { common } from '@kit.AbilityKit';

/**
 * Preferences 本地存储封装
 * 按用户 ID 做命名空间隔离
 */
export class PreferencesUtil {
  private static instance: PreferencesUtil | null = null;
  private context: common.UIAbilityContext | null = null;

  private constructor() {}

  static getInstance(): PreferencesUtil {
    if (!PreferencesUtil.instance) {
      PreferencesUtil.instance = new PreferencesUtil();
    }
    return PreferencesUtil.instance;
  }

  init(context: common.UIAbilityContext): void {
    this.context = context;
  }

  private getStoreName(userId: string): string {
    return `user_${userId}`;
  }

  async put(userId: string, key: string, value: preferences.ValueType): Promise<void> {
    if (!this.context) return;
    const store = await preferences.getPreferences(this.context, this.getStoreName(userId));
    await store.put(key, value);
    await store.flush();
  }

  async get(userId: string, key: string, defaultValue: preferences.ValueType): Promise<preferences.ValueType> {
    if (!this.context) return defaultValue;
    const store = await preferences.getPreferences(this.context, this.getStoreName(userId));
    return await store.get(key, defaultValue);
  }

  async delete(userId: string, key: string): Promise<void> {
    if (!this.context) return;
    const store = await preferences.getPreferences(this.context, this.getStoreName(userId));
    await store.delete(key);
    await store.flush();
  }

  // 全局存储（不按用户隔离，如当前登录用户ID）
  async putGlobal(key: string, value: preferences.ValueType): Promise<void> {
    if (!this.context) return;
    const store = await preferences.getPreferences(this.context, 'global_store');
    await store.put(key, value);
    await store.flush();
  }

  async getGlobal(key: string, defaultValue: preferences.ValueType): Promise<preferences.ValueType> {
    if (!this.context) return defaultValue;
    const store = await preferences.getPreferences(this.context, 'global_store');
    return await store.get(key, defaultValue);
  }
}
