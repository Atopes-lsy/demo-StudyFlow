import { router } from '@kit.ArkUI';
import { AuthService } from '../service/AuthService';
import { DataRepository } from '../service/DataRepository';
import { NotificationService } from '../service/NotificationService';
import { Course, ScheduleEvent, WeekDay, TodayOverview } from '../model/Types';

@Entry
@Component
struct HomePage {
  @State overview: TodayOverview | null = null;
  @State nickname: string = '同学';
  private auth = AuthService.getInstance();
  private repo = DataRepository.getInstance();
  private notif = NotificationService.getInstance();

  aboutToAppear() {
    this.loadData();
  }

  async loadData() {
    const userId = this.auth.getCurrentUserId();
    if (!userId) {
      router.replaceUrl({ url: 'pages/LoginPage' });
      return;
    }

    const user = await this.auth.getCurrentUser();
    if (user) {
      this.nickname = user.nickname;
    }

    const schedule = await this.repo.getSchedule(userId);
    const events = await this.repo.getEvents(userId);

    const now = new Date();
    const weekday = (now.getDay() === 0 ? 7 : now.getDay()) as WeekDay;
    const today = this.formatDate(now);

    const todayCourses = schedule.courses
      .filter(c => c.weekday === weekday && this.isCourseThisWeek(c, schedule.currentWeek))
      .sort((a, b) => a.startTime.localeCompare(b.startTime));

    const todayEvents = events
      .filter(e => e.date === today)
      .sort((a, b) => (a.startTime || '').localeCompare(b.startTime || ''));

    const upcomingEvents = events
      .filter(e => e.date > today && !e.completed)
      .sort((a, b) => a.date.localeCompare(b.date))
      .slice(0, 5);

    this.overview = {
      date: today,
      weekday: weekday,
      courses: todayCourses,
      events: todayEvents,
      upcomingEvents: upcomingEvents,
      unfinishedCount: events.filter(e => !e.completed).length,
    };
  }

  private formatDate(d: Date): string {
    const y = d.getFullYear();
    const m = String(d.getMonth() + 1).padStart(2, '0');
    const day = String(d.getDate()).padStart(2, '0');
    return `${y}-${m}-${day}`;
  }

  private isCourseThisWeek(course: Course, currentWeek: number): boolean {
    if (!course.weeks || course.weeks.length === 0) return true;
    return course.weeks.includes(currentWeek);
  }

  private getWeekdayText(w: WeekDay): string {
    const names = ['', '周一', '周二', '周三', '周四', '周五', '周六', '周日'];
    return names[w];
  }

  build() {
    Column() {
      // 顶栏
      Row() {
        Text(`你好，${this.nickname}`)
          .fontSize($r('app.float.title'))
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_primary'))
        Blank()
        Text('设置')
          .fontSize($r('app.float.body_small'))
          .fontColor($r('app.color.primary'))
          .onClick(() => router.pushUrl({ url: 'pages/SettingsPage' }))
      }
      .width('100%')
      .height($r('app.float.top_bar_height'))
      .padding({ left: 16, right: 16 })
      .backgroundColor($r('app.color.surface'))

      Scroll() {
        Column() {
          if (this.overview) {
            // 今日概览卡片
            Column() {
              Row() {
                Text('今日概览')
                  .fontSize($r('app.float.title_small'))
                  .fontWeight(FontWeight.Bold)
                Blank()
                Text(this.getWeekdayText(this.overview.weekday))
                  .fontSize($r('app.float.body_small'))
                  .fontColor($r('app.color.text_secondary'))
              }
              .width('100%')

              Row() {
                Column() {
                  Text(`${this.overview.courses.length}`)
                    .fontSize(28)
                    .fontColor($r('app.color.primary'))
                  Text('节课')
                    .fontSize($r('app.float.caption'))
                    .fontColor($r('app.color.text_secondary'))
                }
                .layoutWeight(1)

                Column() {
                  Text(`${this.overview.events.length}`)
                    .fontSize(28)
                    .fontColor($r('app.color.secondary'))
                  Text('个日程')
                    .fontSize($r('app.float.caption'))
                    .fontColor($r('app.color.text_secondary'))
                }
                .layoutWeight(1)

                Column() {
                  Text(`${this.overview.unfinishedCount}`)
                    .fontSize(28)
                    .fontColor($r('app.color.warning'))
                  Text('未完成')
                    .fontSize($r('app.float.caption'))
                    .fontColor($r('app.color.text_secondary'))
                }
                .layoutWeight(1)
              }
              .width('100%')
              .margin({ top: 12 })
            }
            .width('100%')
            .padding(16)
            .borderRadius($r('app.float.card_radius'))
            .backgroundColor($r('app.color.surface'))
            .margin({ top: 12, left: 12, right: 12 })

            // 今日课程
            Column() {
              Text('今日课程')
                .fontSize($r('app.float.title_small'))
                .fontWeight(FontWeight.Bold)
                .margin({ bottom: 8 })

              if (this.overview.courses.length === 0) {
                Text('今天没有课，享受自由时光~')
                  .fontSize($r('app.float.body_small'))
                  .fontColor($r('app.color.text_secondary'))
              } else {
                ForEach(this.overview.courses, (course: Course) => {
                  Row() {
                    Column() {
                      Text(course.name)
                        .fontSize($r('app.float.body'))
                        .fontWeight(FontWeight.Medium)
                      Text(`${course.startTime} - ${course.endTime}`)
                        .fontSize($r('app.float.caption'))
                        .fontColor($r('app.color.text_secondary'))
                    }
                    .alignItems(HorizontalAlign.Start)
                    .layoutWeight(1)

                    if (course.location) {
                      Text(course.location)
                        .fontSize($r('app.float.caption'))
                        .fontColor($r('app.color.text_secondary'))
                    }
                  }
                  .width('100%')
                  .padding(12)
                  .borderRadius($r('app.float.input_radius'))
                  .backgroundColor($r('app.color.primary_container'))
                  .margin({ bottom: 8 })
                })
              }
            }
            .width('100%')
            .padding(16)
            .borderRadius($r('app.float.card_radius'))
            .backgroundColor($r('app.color.surface'))
            .margin({ top: 12, left: 12, right: 12 })

            // 今日日程
            Column() {
              Text('今日日程')
                .fontSize($r('app.float.title_small'))
                .fontWeight(FontWeight.Bold)
                .margin({ bottom: 8 })

              if (this.overview.events.length === 0) {
                Text('今天没有额外日程')
                  .fontSize($r('app.float.body_small'))
                  .fontColor($r('app.color.text_secondary'))
              } else {
                ForEach(this.overview.events, (event: ScheduleEvent) => {
                  Row() {
                    Column() {
                      Text(event.title)
                        .fontSize($r('app.float.body'))
                        .fontWeight(FontWeight.Medium)
                      Text(event.startTime ? `${event.startTime} ${event.type}` : event.type)
                        .fontSize($r('app.float.caption'))
                        .fontColor($r('app.color.text_secondary'))
                    }
                    .alignItems(HorizontalAlign.Start)
                    .layoutWeight(1)

                    Text(event.completed ? '✓' : '○')
                      .fontSize(20)
                      .fontColor(event.completed ? $r('app.color.secondary') : $r('app.color.text_secondary'))
                  }
                  .width('100%')
                  .padding(12)
                  .borderRadius($r('app.float.input_radius'))
                  .backgroundColor($r('app.color.disabled'))
                  .margin({ bottom: 8 })
                })
              }
            }
            .width('100%')
            .padding(16)
            .borderRadius($r('app.float.card_radius'))
            .backgroundColor($r('app.color.surface'))
            .margin({ top: 12, left: 12, right: 12 })

            // 即将到来
            if (this.overview.upcomingEvents.length > 0) {
              Column() {
                Text('即将到来')
                  .fontSize($r('app.float.title_small'))
                  .fontWeight(FontWeight.Bold)
                  .margin({ bottom: 8 })

                ForEach(this.overview.upcomingEvents, (event: ScheduleEvent) => {
                  Row() {
                    Column() {
                      Text(event.title)
                        .fontSize($r('app.float.body'))
                      Text(event.date)
                        .fontSize($r('app.float.caption'))
                        .fontColor($r('app.color.text_secondary'))
                    }
                    .alignItems(HorizontalAlign.Start)
                    .layoutWeight(1)
                    Text(event.type)
                      .fontSize($r('app.float.caption'))
                      .fontColor($r('app.color.primary'))
                  }
                  .width('100%')
                  .padding(10)
                  .margin({ bottom: 6 })
                })
              }
              .width('100%')
              .padding(16)
              .borderRadius($r('app.float.card_radius'))
              .backgroundColor($r('app.color.surface'))
              .margin({ top: 12, left: 12, right: 12 })
            }
          }
        }
        .width('100%')
        .padding({ bottom: 80 })
      }
      .layoutWeight(1)

      // 底部导航
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
        Text('首页').fontSize($r('app.float.caption')).fontColor($r('app.color.primary'))
      }
      .layoutWeight(1)
      .onClick(() => this.loadData())

      Column() {
        Text('📅').fontSize(24)
        Text('课表').fontSize($r('app.float.caption')).fontColor($r('app.color.text_secondary'))
      }
      .layoutWeight(1)
      .onClick(() => router.pushUrl({ url: 'pages/SchedulePage' }))

      Column() {
        Text('📝').fontSize(24)
        Text('日程').fontSize($r('app.float.caption')).fontColor($r('app.color.text_secondary'))
      }
      .layoutWeight(1)
      .onClick(() => router.pushUrl({ url: 'pages/CalendarPage' }))

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
