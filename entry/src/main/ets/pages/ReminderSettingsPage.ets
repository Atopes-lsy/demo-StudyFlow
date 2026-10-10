import { AuthService } from '../service/AuthService';
import { DataRepository } from '../service/DataRepository';
import { NotificationService } from '../service/NotificationService';
import { ReminderSettings, DEFAULT_REMINDER_SETTINGS } from '../model/Types';

@Entry
@Component
struct ReminderSettingsPage {
  @State settings: ReminderSettings = DEFAULT_REMINDER_SETTINGS;
  @State testing: boolean = false;

  private auth = AuthService.getInstance();
  private repo = DataRepository.getInstance();
  private notif = NotificationService.getInstance();

  aboutToAppear() {
    this.loadSettings();
  }

  async loadSettings() {
    const userId = this.auth.getCurrentUserId();
    if (!userId) return;
    this.settings = await this.repo.getReminderSettings(userId);
  }

  async saveSettings() {
    const userId = this.auth.getCurrentUserId();
    if (!userId) return;
    await this.repo.saveReminderSettings(userId, this.settings);
  }

  async toggleNotification() {
    await this.notif.enableNotification();
  }

  async testReminder() {
    this.testing = true;
    await this.notif.sendDailyReminder(3, 2);
    this.testing = false;
  }

  build() {
    Column() {
      Row() {
        Text('🔔 提醒设置')
          .fontSize($r('app.float.title'))
          .fontWeight(FontWeight.Bold)
      }
      .width('100%')
      .height($r('app.float.top_bar_height'))
      .padding({ left: 16, right: 16 })
      .backgroundColor($r('app.color.surface'))

      Scroll() {
        Column() {
          // 总开关
          Row() {
            Text('开启提醒').fontSize($r('app.float.body')).layoutWeight(1)
            Toggle({ type: ToggleType.Switch, isOn: this.settings.enabled })
              .onChange((val: boolean) => {
                this.settings.enabled = val;
                this.saveSettings();
              })
          }
          .width('100%')
          .padding(16)
          .backgroundColor($r('app.color.surface'))
          .margin({ top: 8, left: 12, right: 12 })
          .borderRadius($r('app.float.card_radius'))

          // 课前提醒
          Column() {
            Row() {
              Text('课前提醒').fontSize($r('app.float.body')).layoutWeight(1)
              Toggle({ type: ToggleType.Switch, isOn: this.settings.courseReminderEnabled })
                .onChange((val: boolean) => {
                  this.settings.courseReminderEnabled = val;
                  this.saveSettings();
                })
            }
            .width('100%')

            Row() {
              Text('提前').fontSize($r('app.float.body_small')).fontColor($r('app.color.text_secondary'))
              Text(` ${this.settings.courseRemindBefore} 分钟 `)
                .fontSize($r('app.float.body_small'))
                .fontColor($r('app.color.primary'))
              Slider({ value: this.settings.courseRemindBefore, min: 5, max: 60, step: 5 })
                .layoutWeight(1)
                .onChange((val: number) => {
                  this.settings.courseRemindBefore = val;
                  this.saveSettings();
                })
            }
            .width('100%')
            .margin({ top: 8 })
          }
          .width('100%')
          .padding(16)
          .backgroundColor($r('app.color.surface'))
          .margin({ top: 8, left: 12, right: 12 })
          .borderRadius($r('app.float.card_radius'))

          // 日程提醒
          Row() {
            Text('日程提醒').fontSize($r('app.float.body')).layoutWeight(1)
            Toggle({ type: ToggleType.Switch, isOn: this.settings.eventReminderEnabled })
              .onChange((val: boolean) => {
                this.settings.eventReminderEnabled = val;
                this.saveSettings();
              })
          }
          .width('100%')
          .padding(16)
          .backgroundColor($r('app.color.surface'))
          .margin({ top: 8, left: 12, right: 12 })
          .borderRadius($r('app.float.card_radius'))

          // 每日提醒
          Column() {
            Row() {
              Text('每日提醒').fontSize($r('app.float.body')).layoutWeight(1)
              Toggle({ type: ToggleType.Switch, isOn: this.settings.dailyReminderEnabled })
                .onChange((val: boolean) => {
                  this.settings.dailyReminderEnabled = val;
                  this.saveSettings();
                })
            }
            .width('100%')

            Row() {
              Text('提醒时间').fontSize($r('app.float.body_small')).fontColor($r('app.color.text_secondary'))
              Blank()
              Text(this.settings.dailyRemindTime)
                .fontSize($r('app.float.body'))
                .fontColor($r('app.color.primary'))
            }
            .width('100%')
            .margin({ top: 8 })
            .onClick(() => {
              // 简化：循环切换几个时间点
              const times = ['07:00', '08:00', '09:00', '12:00', '18:00', '20:00'];
              const idx = times.indexOf(this.settings.dailyRemindTime);
              this.settings.dailyRemindTime = times[(idx + 1) % times.length];
              this.saveSettings();
            })
          }
          .width('100%')
          .padding(16)
          .backgroundColor($r('app.color.surface'))
          .margin({ top: 8, left: 12, right: 12 })
          .borderRadius($r('app.float.card_radius'))

          // 智能提醒
          Column() {
            Row() {
              Column() {
                Text('智能提醒').fontSize($r('app.float.body')).fontWeight(FontWeight.Medium)
                Text('需配置 API 和角色设定').fontSize($r('app.float.caption')).fontColor($r('app.color.text_secondary'))
              }
              .alignItems(HorizontalAlign.Start)
              .layoutWeight(1)
              Toggle({ type: ToggleType.Switch, isOn: this.settings.smartReminderEnabled })
                .onChange((val: boolean) => {
                  this.settings.smartReminderEnabled = val;
                  this.saveSettings();
                })
            }
            .width('100%')
          }
          .width('100%')
          .padding(16)
          .backgroundColor($r('app.color.surface'))
          .margin({ top: 8, left: 12, right: 12 })
          .borderRadius($r('app.float.card_radius'))

          // 授权通知 + 测试
          Button('授权通知权限')
            .width('85%')
            .height(40)
            .borderRadius($r('app.float.button_radius'))
            .backgroundColor($r('app.color.primary_container'))
            .fontColor($r('app.color.primary'))
            .margin({ top: 16 })
            .onClick(() => this.toggleNotification())

          Button(this.testing ? '发送中...' : '发送测试提醒')
            .width('85%')
            .height(40)
            .borderRadius($r('app.float.button_radius'))
            .backgroundColor($r('app.color.secondary'))
            .fontColor('#FFFFFF')
            .margin({ top: 8 })
            .onClick(() => this.testReminder())
        }
        .width('100%')
        .padding({ bottom: 80 })
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.background'))
  }
}
