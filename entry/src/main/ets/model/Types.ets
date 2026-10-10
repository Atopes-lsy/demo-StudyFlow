/**
 * StudyFlow 全局类型定义
 * 课表、日程、用户、角色设定、API配置、提醒
 */

// ==================== 用户与认证 ====================

/** 用户账户（本地存储，无后端） */
export interface UserAccount {
  id: string;
  username: string;
  passwordHash: string;
  nickname: string;
  avatar?: string;
  createdAt: number;
}

/** 登录请求 */
export interface LoginRequest {
  username: string;
  password: string;
}

/** 注册请求 */
export interface RegisterRequest {
  username: string;
  password: string;
  nickname: string;
}

// ==================== 课表 ====================

/** 星期几 */
export type WeekDay = 1 | 2 | 3 | 4 | 5 | 6 | 7; // 1=周一 ... 7=周日

/** 课程信息 */
export interface Course {
  id: string;
  name: string;          // 课程名称
  teacher?: string;      // 教师
  location?: string;     // 上课地点
  weekday: WeekDay;      // 周几
  startTime: string;     // "08:00"
  endTime: string;       // "09:40"
  weeks?: number[];      // 上课周次 [1,2,3,...] 空=每周
  color?: string;        // 课程颜色标识
  remark?: string;       // 备注
}

/** 课表（按学期） */
export interface Schedule {
  id: string;
  semesterName: string;  // 学期名称
  courses: Course[];
  totalWeeks: number;     // 总周数
  currentWeek: number;    // 当前周次
}

// ==================== 日程 ====================

/** 日程类型 */
export type ScheduleEventType = 'exam' | 'meeting' | 'deadline' | 'activity' | 'custom';

/** 日程事件 */
export interface ScheduleEvent {
  id: string;
  title: string;
  description?: string;
  date: string;           // "2026-10-10"
  startTime?: string;     // "14:00"
  endTime?: string;       // "16:00"
  type: ScheduleEventType;
  location?: string;
  remindBefore: number;   // 提前提醒分钟数 (0=不提醒)
  isAllDay: boolean;
  completed: boolean;
  createdAt: number;
}

// ==================== 提醒 ====================

/** 提醒类型 */
export type ReminderType = 'course' | 'event' | 'daily';

/** 提醒记录 */
export interface ReminderRecord {
  id: string;
  type: ReminderType;
  title: string;
  content: string;
  triggerTime: number;    // 触发时间戳
  relatedId?: string;     // 关联的课程/日程ID
  isRead: boolean;
}

/** 提醒设置 */
export interface ReminderSettings {
  enabled: boolean;               // 总开关
  courseReminderEnabled: boolean; // 课前提醒
  courseRemindBefore: number;     // 课前提前分钟
  eventReminderEnabled: boolean;  // 日程提醒
  dailyReminderEnabled: boolean;  // 每日总结提醒
  dailyRemindTime: string;        // 每日提醒时间 "08:00"
  smartReminderEnabled: boolean;  // 智能提醒开关
}

// ==================== 角色设定 ====================

/** 二次元角色设定 */
export interface CharacterSetting {
  id: string;
  name: string;           // 角色名称
  personality: string;    // 性格特征
  speechStyle: string;    // 说话风格描述
  catchphrase?: string;   // 口癖/标志性台词
  tonePrompt: string;     // 完整的语气提示词（发给AI的system prompt）
  isActive: boolean;      // 是否当前启用
}

// ==================== API配置 ====================

/** AI API提供商类型 */
export type ApiProvider = 'openai' | 'custom';

/** API配置 */
export interface ApiConfig {
  provider: ApiProvider;
  baseUrl: string;        // API基础URL
  apiKey: string;         // API Key（仅内存，不落盘）
  model: string;          // 模型名称
  temperature?: number;   // 温度参数
  maxTokens?: number;     // 最大token
}

/** AI请求消息 */
export interface ChatMessage {
  role: 'system' | 'user' | 'assistant';
  content: string;
}

/** AI请求 */
export interface ChatRequest {
  messages: ChatMessage[];
  temperature?: number;
  maxTokens?: number;
}

/** AI响应 */
export interface ChatResponse {
  success: boolean;
  content: string;
  error?: string;
}

// ==================== 首页仪表盘 ====================

/** 今日概览 */
export interface TodayOverview {
  date: string;
  weekday: WeekDay;
  courses: Course[];          // 今日课程
  events: ScheduleEvent[];    // 今日日程
  upcomingEvents: ScheduleEvent[]; // 即将到来的日程
  unfinishedCount: number;    // 未完成数量
}

// ==================== 默认值 ====================

export const DEFAULT_REMINDER_SETTINGS: ReminderSettings = {
  enabled: true,
  courseReminderEnabled: true,
  courseRemindBefore: 15,
  eventReminderEnabled: true,
  dailyReminderEnabled: true,
  dailyRemindTime: '08:00',
  smartReminderEnabled: false,
};

export const DEFAULT_API_CONFIG: ApiConfig = {
  provider: 'openai',
  baseUrl: 'https://api.openai.com/v1',
  apiKey: '',
  model: 'gpt-4o-mini',
  temperature: 0.7,
  maxTokens: 500,
};
