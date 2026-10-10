import { router } from '@kit.ArkUI';
import { AuthService } from '../service/AuthService';
import { DataRepository } from '../service/DataRepository';
import { ScheduleEvent, ScheduleEventType } from '../model/Types';

@Entry
@Component
struct CalendarPage {
  @State events: ScheduleEvent[] = [];
  @State showAdd: boolean = false;
  @State fTitle: string = '';
  @State fDate: string = '';
  @State fStart: string = '';
  @State fType: number = 0;

  private auth = AuthService.getInstance();
  private repo = DataRepository.getInstance();

  aboutToAppear() {
    this.loadData();
    const now = new Date();
    const y = now.getFullYear();
    const m = String(now.getMonth() + 1).padStart(2, '0');
    const d = String(now.getDate()).padStart(2, '0');
    this.fDate = `${y}-${m}-${d}`;
  }

  async loadData() {
    const userId = this.auth.getCurrentUserId();
    if (!userId) return;
    this.events = await this.repo.getEvents(userId);
    this.events.sort((a, b) => a.date.localeCompare(b.date));
  }

  async addEvent() {
    if (!this.fTitle || !this.fDate) return;
    const userId = this.auth.getCurrentUserId();
    if (!userId) return;

    const typeKeys: ScheduleEventType[] = ['exam', 'meeting', 'deadline', 'activity', 'custom'];
    const event: ScheduleEvent = {
      id: `e_${Date.now()}`,
      title: this.fTitle,
      date: this.fDate,
      startTime: this.fStart || undefined,
      type: typeKeys[this.fType],
      remindBefore: 30,
      isAllDay: !this.fStart,
      completed: false,
      createdAt: Date.now(),
    };
    await this.repo.addEvent(userId, event);
    this.fTitle = '';
    this.fStart = '';
    this.showAdd = false;
    await this.loadData();
  }

  async toggleComplete(event: ScheduleEvent) {
    const userId = this.auth.getCurrentUserId();
    if (!userId) return;
    event.completed = !event.completed;
    await this.repo.updateEvent(userId, event);
    await this.loadData();
  }

  async deleteEvent(id: string) {
    const userId = this.auth.getCurrentUserId();
    if (!userId) return;
    await this.repo.deleteEvent(userId, id);
    await this.loadData();
  }

  private getTypeLabel(type: ScheduleEventType): string {
    if (type === 'exam') return '考试';
    if (type === 'meeting') return '会议';
    if (type === 'deadline') return '截止日';
    if (type === 'activity') return '活动';
    return '自定义';
  }

  build() {
    Column() {
      Row() {
        Text('📝 日程管理')
          .fontSize($r('app.float.title'))
          .fontWeight(FontWeight.Bold)
        Blank()
        Button('添加日程')
          .height(36)
          .borderRadius($r('app.float.button_radius'))
          .backgroundColor($r('app.color.primary'))
          .fontColor('#FFFFFF')
          .fontSize($r('app.float.body_small'))
          .onClick(() => { this.showAdd = true; })
      }
      .width('100%')
      .height($r('app.float.top_bar_height'))
      .padding({ left: 16, right: 16 })
      .backgroundColor($r('app.color.surface'))

      Scroll() {
        Column() {
          if (this.showAdd) {
            Column() {
              Text('新增日程').fontSize($r('app.float.title_small')).fontWeight(FontWeight.Bold).margin({ bottom: 12 })

              TextInput({ placeholder: '标题', text: this.fTitle })
                .height($r('app.float.input_height'))
                .borderRadius($r('app.float.input_radius'))
                .backgroundColor($r('app.color.background'))
                .margin({ bottom: 8 })
                .onChange((v: string) => { this.fTitle = v; })

              TextInput({ placeholder: '日期 2026-10-10', text: this.fDate })
                .height($r('app.float.input_height'))
                .borderRadius($r('app.float.input_radius'))
                .backgroundColor($r('app.color.background'))
                .margin({ bottom: 8 })
                .onChange((v: string) => { this.fDate = v; })

              TextInput({ placeholder: '时间 14:00（可选）', text: this.fStart })
                .height($r('app.float.input_height'))
                .borderRadius($r('app.float.input_radius'))
                .backgroundColor($r('app.color.background'))
                .margin({ bottom: 8 })
                .onChange((v: string) => { this.fStart = v; })

              Row() {
                Text('考试').fontSize($r('app.float.caption')).padding(8).borderRadius(8)
                  .backgroundColor(this.fType === 0 ? $r('app.color.primary') : $r('app.color.background'))
                  .fontColor(this.fType === 0 ? '#FFFFFF' : $r('app.color.text_primary'))
                  .margin({ left: 4 }).onClick(() => { this.fType = 0; })
                Text('会议').fontSize($r('app.float.caption')).padding(8).borderRadius(8)
                  .backgroundColor(this.fType === 1 ? $r('app.color.primary') : $r('app.color.background'))
                  .fontColor(this.fType === 1 ? '#FFFFFF' : $r('app.color.text_primary'))
                  .margin({ left: 4 }).onClick(() => { this.fType = 1; })
                Text('截止日').fontSize($r('app.float.caption')).padding(8).borderRadius(8)
                  .backgroundColor(this.fType === 2 ? $r('app.color.primary') : $r('app.color.background'))
                  .fontColor(this.fType === 2 ? '#FFFFFF' : $r('app.color.text_primary'))
                  .margin({ left: 4 }).onClick(() => { this.fType = 2; })
                Text('活动').fontSize($r('app.float.caption')).padding(8).borderRadius(8)
                  .backgroundColor(this.fType === 3 ? $r('app.color.primary') : $r('app.color.background'))
                  .fontColor(this.fType === 3 ? '#FFFFFF' : $r('app.color.text_primary'))
                  .margin({ left: 4 }).onClick(() => { this.fType = 3; })
                Text('自定义').fontSize($r('app.float.caption')).padding(8).borderRadius(8)
                  .backgroundColor(this.fType === 4 ? $r('app.color.primary') : $r('app.color.background'))
                  .fontColor(this.fType === 4 ? '#FFFFFF' : $r('app.color.text_primary'))
                  .margin({ left: 4 }).onClick(() => { this.fType = 4; })
              }
              .width('100%')
              .margin({ bottom: 12 })

              Row() {
                Button('取消').layoutWeight(1).height(40)
                  .borderRadius($r('app.float.button_radius'))
                  .backgroundColor($r('app.color.disabled'))
                  .onClick(() => { this.showAdd = false; })
                Button('保存').layoutWeight(1).height(40)
                  .borderRadius($r('app.float.button_radius'))
                  .backgroundColor($r('app.color.primary'))
                  .fontColor('#FFFFFF').margin({ left: 8 })
                  .onClick(() => this.addEvent())
              }
              .width('100%')
            }
            .width('100%')
            .padding(16)
            .borderRadius($r('app.float.card_radius'))
            .backgroundColor($r('app.color.surface'))
            .margin({ top: 8, left: 12, right: 12 })
          }

          if (this.events.length === 0) {
            Column() {
              Text('📭').fontSize(48).margin({ top: 60 })
              Text('还没有日程，点击右上角添加')
                .fontSize($r('app.float.body_small'))
                .fontColor($r('app.color.text_secondary'))
                .margin({ top: 12 })
            }
            .width('100%')
            .alignItems(HorizontalAlign.Center)
          } else {
            ForEach(this.events, (event: ScheduleEvent) => {
              Row() {
                Column() {
                  Text(event.title)
                    .fontSize($r('app.float.body'))
                    .fontWeight(FontWeight.Medium)
                    .decoration({ type: event.completed ? TextDecorationType.LineThrough : TextDecorationType.None })
                  Row() {
                    Text(event.date).fontSize($r('app.float.caption')).fontColor($r('app.color.text_secondary'))
                    if (event.startTime) {
                      Text(' ' + event.startTime).fontSize($r('app.float.caption')).fontColor($r('app.color.text_secondary'))
                    }
                    Text(' | ' + this.getTypeLabel(event.type)).fontSize($r('app.float.caption')).fontColor($r('app.color.primary'))
                  }
                  .margin({ top: 2 })
                }
                .alignItems(HorizontalAlign.Start)
                .layoutWeight(1)

                Text(event.completed ? '✓' : '○')
                  .fontSize(22)
                  .fontColor(event.completed ? $r('app.color.secondary') : $r('app.color.text_secondary'))
                  .onClick(() => this.toggleComplete(event))
                Text('🗑')
                  .fontSize(18)
                  .margin({ left: 12 })
                  .onClick(() => this.deleteEvent(event.id))
              }
              .width('100%')
              .padding(12)
              .borderRadius($r('app.float.input_radius'))
              .backgroundColor($r('app.color.surface'))
              .margin({ bottom: 8, left: 12, right: 12 })
            })
          }
        }
        .width('100%')
        .padding({ bottom: 80, top: 8 })
      }
      .layoutWeight(1)

      this.TabBarBuilder()
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.background'))
  }

  @Builder TabBarBuilder() {
    Row() {
      Column() {
        Text('🏠').fontSize(24)
        Text('首页').fontSize($r('app.float.caption')).fontColor($r('app.color.text_secondary'))
      }
      .layoutWeight(1)
      .onClick(() => router.pushUrl({ url: 'pages/HomePage' }))

      Column() {
        Text('📅').fontSize(24)
        Text('课表').fontSize($r('app.float.caption')).fontColor($r('app.color.text_secondary'))
      }
      .layoutWeight(1)
      .onClick(() => router.pushUrl({ url: 'pages/SchedulePage' }))

      Column() {
        Text('📝').fontSize(24)
        Text('日程').fontSize($r('app.float.caption')).fontColor($r('app.color.primary'))
      }
      .layoutWeight(1)

      Column() {
        Text('⚙️').fontSize(24)
        Text('设置').fontSize($r('app.float.caption')).fontColor($r('app.color.text_secondary'))
      }
      .layoutWeight(1)
      .onClick(() => router.pushUrl({ url: 'pages/SettingsPage' }))
    }
    .width('100%')
    .height(60)
    .backgroundColor($r('app.color.surface'))
    .border({ width: { top: 1 }, color: $r('app.color.divider') })
  }
}
