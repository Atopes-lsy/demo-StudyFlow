import { PreferencesUtil } from './PreferencesUtil';
import { UserAccount, LoginRequest, RegisterRequest } from '../model/Types';

/** 登录/注册结果 */
interface AuthResult {
  success: boolean;
  error?: string;
}

/**
 * 认证服务 — 本地登录注册（无后端）
 * 密码做简单哈希，不用于真实安全场景
 */
export class AuthService {
  private static instance: AuthService | null = null;
  private pref: PreferencesUtil;
  private currentUserId: string = '';

  private constructor() {
    this.pref = PreferencesUtil.getInstance();
  }

  static getInstance(): AuthService {
    if (!AuthService.instance) {
      AuthService.instance = new AuthService();
    }
    return AuthService.instance;
  }

  private simpleHash(password: string): string {
    let hash = 0;
    for (let i = 0; i < password.length; i++) {
      const char = password.charCodeAt(i);
      hash = ((hash << 5) - hash) + char;
      hash = hash & 0xffffffff;
    }
    return `hash_${hash}`;
  }

  private generateId(): string {
    return `u_${Date.now()}_${Math.floor(Math.random() * 10000)}`;
  }

  async register(req: RegisterRequest): Promise<AuthResult> {
    if (!req.username || !req.password || !req.nickname) {
      const r: AuthResult = { success: false, error: '请填写所有字段' };
      return r;
    }
    if (req.username.length < 2) {
      const r: AuthResult = { success: false, error: '用户名至少2个字符' };
      return r;
    }
    if (req.password.length < 4) {
      const r: AuthResult = { success: false, error: '密码至少4个字符' };
      return r;
    }

    const usersJson = await this.pref.getGlobal('users', '[]') as string;
    const users: UserAccount[] = JSON.parse(usersJson);
    if (users.some(u => u.username === req.username)) {
      const r: AuthResult = { success: false, error: '用户名已存在' };
      return r;
    }

    const account: UserAccount = {
      id: this.generateId(),
      username: req.username,
      passwordHash: this.simpleHash(req.password),
      nickname: req.nickname,
      createdAt: Date.now(),
    };

    users.push(account);
    await this.pref.putGlobal('users', JSON.stringify(users));
    const r: AuthResult = { success: true };
    return r;
  }

  async login(req: LoginRequest): Promise<AuthResult> {
    const usersJson = await this.pref.getGlobal('users', '[]') as string;
    const users: UserAccount[] = JSON.parse(usersJson);
    const account = users.find(u => u.username === req.username);
    if (!account) {
      const r: AuthResult = { success: false, error: '用户不存在' };
      return r;
    }
    if (account.passwordHash !== this.simpleHash(req.password)) {
      const r: AuthResult = { success: false, error: '密码错误' };
      return r;
    }

    this.currentUserId = account.id;
    await this.pref.putGlobal('currentUserId', account.id);
    const r: AuthResult = { success: true };
    return r;
  }

  async logout(): Promise<void> {
    this.currentUserId = '';
    await this.pref.putGlobal('currentUserId', '');
  }

  async restoreSession(): Promise<boolean> {
    const id = await this.pref.getGlobal('currentUserId', '') as string;
    if (id) {
      this.currentUserId = id;
      return true;
    }
    return false;
  }

  getCurrentUserId(): string {
    return this.currentUserId;
  }

  async getCurrentUser(): Promise<UserAccount | null> {
    if (!this.currentUserId) return null;
    const usersJson = await this.pref.getGlobal('users', '[]') as string;
    const users: UserAccount[] = JSON.parse(usersJson);
    return users.find(u => u.id === this.currentUserId) || null;
  }
}
