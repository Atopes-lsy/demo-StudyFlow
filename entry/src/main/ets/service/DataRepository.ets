import { PreferencesUtil } from './PreferencesUtil';
import { Schedule, Course, ScheduleEvent, ReminderSettings, CharacterSetting, DEFAULT_REMINDER_SETTINGS } from '../model/Types';

/**
 * 数据仓库 — 课表、日程、提醒设置、角色设定的本地读写
 */
export class DataRepository {
  private static instance: DataRepository | null = null;
  private pref: PreferencesUtil;

  private constructor() {
    this.pref = PreferencesUtil.getInstance();
  }

  static getInstance(): DataRepository {
    if (!DataRepository.instance) {
      DataRepository.instance = new DataRepository();
    }
    return DataRepository.instance;
  }

  // ==================== 课表 ====================

  async getSchedule(userId: string): Promise<Schedule> {
    const json = await this.pref.get(userId, 'schedule', '') as string;
    if (json) {
      return JSON.parse(json) as Schedule;
    }
    const empty: Schedule = { id: 'default', semesterName: '本学期', courses: [], totalWeeks: 20, currentWeek: 1 };
    return empty;
  }

  async saveSchedule(userId: string, schedule: Schedule): Promise<void> {
    await this.pref.put(userId, 'schedule', JSON.stringify(schedule));
  }

  async addCourse(userId: string, course: Course): Promise<void> {
    const schedule = await this.getSchedule(userId);
    schedule.courses.push(course);
    await this.saveSchedule(userId, schedule);
  }

  async updateCourse(userId: string, course: Course): Promise<void> {
    const schedule = await this.getSchedule(userId);
    const idx = schedule.courses.findIndex(c => c.id === course.id);
    if (idx >= 0) {
      schedule.courses[idx] = course;
      await this.saveSchedule(userId, schedule);
    }
  }

  async deleteCourse(userId: string, courseId: string): Promise<void> {
    const schedule = await this.getSchedule(userId);
    schedule.courses = schedule.courses.filter(c => c.id !== courseId);
    await this.saveSchedule(userId, schedule);
  }

  // ==================== 日程 ====================

  async getEvents(userId: string): Promise<ScheduleEvent[]> {
    const json = await this.pref.get(userId, 'events', '[]') as string;
    return JSON.parse(json) as ScheduleEvent[];
  }

  async saveEvents(userId: string, events: ScheduleEvent[]): Promise<void> {
    await this.pref.put(userId, 'events', JSON.stringify(events));
  }

  async addEvent(userId: string, event: ScheduleEvent): Promise<void> {
    const events = await this.getEvents(userId);
    events.push(event);
    await this.saveEvents(userId, events);
  }

  async updateEvent(userId: string, event: ScheduleEvent): Promise<void> {
    const events = await this.getEvents(userId);
    const idx = events.findIndex(e => e.id === event.id);
    if (idx >= 0) {
      events[idx] = event;
      await this.saveEvents(userId, events);
    }
  }

  async deleteEvent(userId: string, eventId: string): Promise<void> {
    const events = await this.getEvents(userId);
    const filtered = events.filter(e => e.id !== eventId);
    await this.saveEvents(userId, filtered);
  }

  // ==================== 提醒设置 ====================

  async getReminderSettings(userId: string): Promise<ReminderSettings> {
    const json = await this.pref.get(userId, 'reminderSettings', '') as string;
    if (json) {
      return JSON.parse(json) as ReminderSettings;
    }
    const def: ReminderSettings = {
      enabled: DEFAULT_REMINDER_SETTINGS.enabled,
      courseReminderEnabled: DEFAULT_REMINDER_SETTINGS.courseReminderEnabled,
      courseRemindBefore: DEFAULT_REMINDER_SETTINGS.courseRemindBefore,
      eventReminderEnabled: DEFAULT_REMINDER_SETTINGS.eventReminderEnabled,
      dailyReminderEnabled: DEFAULT_REMINDER_SETTINGS.dailyReminderEnabled,
      dailyRemindTime: DEFAULT_REMINDER_SETTINGS.dailyRemindTime,
      smartReminderEnabled: DEFAULT_REMINDER_SETTINGS.smartReminderEnabled,
    };
    return def;
  }

  async saveReminderSettings(userId: string, settings: ReminderSettings): Promise<void> {
    await this.pref.put(userId, 'reminderSettings', JSON.stringify(settings));
  }

  // ==================== 角色设定 ====================

  async getCharacters(userId: string): Promise<CharacterSetting[]> {
    const json = await this.pref.get(userId, 'characters', '[]') as string;
    return JSON.parse(json) as CharacterSetting[];
  }

  async saveCharacters(userId: string, characters: CharacterSetting[]): Promise<void> {
    await this.pref.put(userId, 'characters', JSON.stringify(characters));
  }

  async getActiveCharacter(userId: string): Promise<CharacterSetting | null> {
    const characters = await this.getCharacters(userId);
    return characters.find(c => c.isActive) || null;
  }
}
