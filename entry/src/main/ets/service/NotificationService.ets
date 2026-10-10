import { notificationManager } from '@kit.NotificationKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

const DOMAIN = 0x0001;
const TAG = 'NotificationService';

/**
 * 通知服务 — 发送本地通知弹窗
 */
export class NotificationService {
  private static instance: NotificationService | null = null;

  private constructor() {}

  static getInstance(): NotificationService {
    if (!NotificationService.instance) {
      NotificationService.instance = new NotificationService();
    }
    return NotificationService.instance;
  }

  async enableNotification(): Promise<boolean> {
    try {
      await notificationManager.requestEnableNotification();
      return true;
    } catch (e) {
      hilog.error(DOMAIN, TAG, 'requestEnableNotification failed: %{public}s', JSON.stringify(e));
      return false;
    }
  }

  async sendNotification(title: string, content: string): Promise<void> {
    try {
      const request: notificationManager.NotificationRequest = {
        id: Date.now(),
        content: {
          notificationContentType: notificationManager.ContentType.NOTIFICATION_CONTENT_BASIC_TEXT,
          normal: {
            title: title,
            text: content,
            additionalText: 'StudyFlow',
          },
        },
      };
      await notificationManager.publish(request);
      hilog.info(DOMAIN, TAG, 'Notification sent: %{public}s', title);
    } catch (e) {
      hilog.error(DOMAIN, TAG, 'sendNotification failed: %{public}s', JSON.stringify(e));
    }
  }

  async sendDailyReminder(courseCount: number, eventCount: number): Promise<void> {
    await this.sendNotification('今日提醒', `今天有 ${courseCount} 节课、${eventCount} 个日程，加油！`);
  }

  async sendCourseReminder(courseName: string, location: string, minutesBefore: number): Promise<void> {
    const content = `${minutesBefore}分钟后上课：${courseName}${location ? ' @ ' + location : ''}`;
    await this.sendNotification('课前提醒', content);
  }

  async sendEventReminder(eventTitle: string, eventType: string, minutesBefore: number): Promise<void> {
    await this.sendNotification('日程提醒', `${minutesBefore}分钟后：${eventTitle}（${eventType}）`);
  }

  async sendSmartReminder(content: string): Promise<void> {
    await this.sendNotification('智能提醒', content);
  }
}
