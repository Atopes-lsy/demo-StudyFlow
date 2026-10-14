import { router } from '@kit.ArkUI';
import { AuthService } from '../service/AuthService';
import { DataRepository } from '../service/DataRepository';
import { ScheduleEvent, ScheduleEventType } from '../model/Types';

const TYPE_KEYS: ScheduleEventType[] = ['exam', 'meeting', 'deadline', 'activity', 'custom'];
const TYPE_LABELS: string[] = ['考试', '会议', '截止日', '活动', '自定义'];

@Entry
@Component
struct CalendarPage {
  @State events: ScheduleEvent[] = [];
  @State showAdd: boolean = false;
  @State editingId: string = '';
  @State filterType: number = -1;
  @State fTitle: string = '';
  @State fDate: string = '';
  @State fStart: string = '';
  @State fType: number = 0;

  private auth = AuthService.getInstance();
  private repo = DataRepository.getInstance();

  aboutToAppear() {
    this.fDate = this.todayString();
    this.loadData();
  }

  private todayString(): string {
    const now = new Date();
    const y = now.getFullYear();
    const m = String(now.getMonth() + 1).padStart(2, '0');
    const d = String(now.getDate()).padStart(2, '0');
    return `${y}-${m}-${d}`;
  }

  async loadData() {
    const userId = this.auth.getCurrentUserId();
    if (!userId) return;
    this.events = await this.repo.getEvents(userId);
    this.events.sort((a, b) => a.date.localeCompare(b.date));
  }

  private startAdd() {
    this.editingId = '';
    this.fTitle = '';
    this.fDate = this.todayString();
    this.fStart = '';
    this.fType = 0;
    this.showAdd = true;
  }

  private startEdit(event: ScheduleEvent) {
    this.editingId = event.id;
    this.fTitle = event.title;
    this.fDate = event.date;
    this.fStart = event.startTime ? event.startTime : '';
    this.fType = TYPE_KEYS.indexOf(event.type) < 0 ? 4 : TYPE_KEYS.indexOf(event.type);
    this.showAdd = true;
  }

  async saveEvent() {
    if (!this.fTitle || !this.fDate) return;
    const userId = this.auth.getCurrentUserId();
    if (!userId) return;

    if (this.editingId) {
      const events = await this.repo.getEvents(userId);
      const original = events.find((e: ScheduleEvent) => e.id === this.editingId);
      if (original) {
        original.title = this.fTitle;
        original.date = this.fDate;
        original.startTime = this.fStart ? this.fStart : undefined;
        original.type = TYPE_KEYS[this.fType];
        original.isAllDay = !this.fStart;
        await this.repo.updateEvent(userId, original);
      }
    } else {
      const event: ScheduleEvent = {
        id: `e_${Date.now()}`,
        title: this.fTitle,
        date: this.fDate,
        startTime: this.fStart ? this.fStart : undefined,
        type: TYPE_KEYS[this.fType],
        remindBefore: 30,
        isAllDay: !this.fStart,
        completed: false,
        createdAt: Date.now(),
      };
      await this.repo.addEvent(userId, event);
    }

    this.editingId = '';
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

  private getFilteredEvents(): ScheduleEvent[] {
    if (this.filterType < 0) return this.events;
    const key = TYPE_KEYS[this.filterType];
    return this.events.filter(e => e.type === key);
  }

  private getTypeLabel(type: ScheduleEventType): string {
    const idx = TYPE_KEYS.indexOf(type);
    return idx < 0 ? '自定义' : TYPE_LABELS[idx];
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
          .onClick(() => this.startAdd())
      }
      .width('100%')
      .height($r('app.float.top_bar_height'))
      .padding({ left: 16, right: 16 })
      .backgroundColor($r('app.color.surface'))

      // 类型筛选
      Flex({ wrap: FlexWrap.Wrap }) {
        Text('全部')
          .fontSize($r('app.float.caption'))
          .padding({ left: 12, right: 12, top: 6, bottom: 6 })
          .borderRadius(14)
          .backgroundColor(this.filterType === -1 ? $r('app.color.primary') : $r('app.color.surface'))
          .fontColor(this.filterType === -1 ? '#FFFFFF' : $r('app.color.text_primary'))
          .margin({ right: 8, bottom: 8 })
          .onClick(() => { this.filterType = -1; })
        ForEach(TYPE_LABELS, (label: string, idx: number) => {
          Text(label)
            .fontSize($r('app.float.caption'))
            .padding({ left: 12, right: 12, top: 6, bottom: 6 })
            .borderRadius(14)
            .backgroundColor(this.filterType === idx ? $r('app.color.primary') : $r('app.color.surface'))
            .fontColor(this.filterType === idx ? '#FFFFFF' : $r('app.color.text_primary'))
            .margin({ right: 8, bottom: 8 })
            .onClick(() => { this.filterType = idx; })
        })
      }
      .width('100%')
      .padding({ left: 12, right: 12, top: 8 })

      Scroll() {
        Column() {
          if (this.showAdd) {
            Column() {
              Text(this.editingId ? '编辑日程' : '新增日程')
                .fontSize($r('app.float.title_small'))
                .fontWeight(FontWeight.Bold)
                .margin({ bottom: 12 })

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
                ForEach(TYPE_LABELS, (label: string, idx: number) => {
                  Text(label)
                    .fontSize($r('app.float.caption'))
                    .padding(8)
                    .borderRadius(8)
                    .backgroundColor(this.fType === idx ? $r('app.color.primary') : $r('app.color.background'))
                    .fontColor(this.fType === idx ? '#FFFFFF' : $r('app.color.text_primary'))
                    .margin({ left: idx === 0 ? 0 : 4 })
                    .onClick(() => { this.fType = idx; })
                })
              }
              .width('100%')
              .margin({ bottom: 12 })

              Row() {
                Button('取消').layoutWeight(1).height(40)
                  .borderRadius($r('app.float.button_radius'))
                  .backgroundColor($r('app.color.disabled'))
                  .onClick(() => {
                    this.showAdd = false;
                    this.editingId = '';
                  })
                Button('保存').layoutWeight(1).height(40)
                  .borderRadius($r('app.float.button_radius'))
                  .backgroundColor($r('app.color.primary'))
                  .fontColor('#FFFFFF').margin({ left: 8 })
                  .onClick(() => this.saveEvent())
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
          } else if (this.getFilteredEvents().length === 0) {
            Column() {
              Text('📭').fontSize(48).margin({ top: 60 })
              Text('该类型下暂无日程')
                .fontSize($r('app.float.body_small'))
                .fontColor($r('app.color.text_secondary'))
                .margin({ top: 12 })
            }
            .width('100%')
            .alignItems(HorizontalAlign.Center)
          } else {
            ForEach(this.getFilteredEvents(), (event: ScheduleEvent) => {
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
                Text('✏️')
                  .fontSize(18)
                  .margin({ left: 16 })
                  .onClick(() => this.startEdit(event))
                Text('🗑')
                  .fontSize(18)
                  .margin({ left: 16 })
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
