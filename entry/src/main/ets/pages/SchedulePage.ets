import { router } from '@kit.ArkUI';
import { AuthService } from '../service/AuthService';
import { DataRepository } from '../service/DataRepository';
import { Course, WeekDay, Schedule } from '../model/Types';

@Entry
@Component
struct SchedulePage {
  @State courses: Course[] = [];
  @State currentWeek: number = 1;
  @State totalWeeks: number = 20;
  @State semesterName: string = '本学期';
  @State showAdd: boolean = false;
  // 表单
  @State fName: string = '';
  @State fTeacher: string = '';
  @State fLocation: string = '';
  @State fWeekday: number = 1;
  @State fStart: string = '08:00';
  @State fEnd: string = '09:40';

  private auth = AuthService.getInstance();
  private repo = DataRepository.getInstance();

  aboutToAppear() {
    this.loadData();
  }

  async loadData() {
    const userId = this.auth.getCurrentUserId();
    if (!userId) return;
    const schedule = await this.repo.getSchedule(userId);
    this.courses = schedule.courses;
    this.currentWeek = schedule.currentWeek;
    this.totalWeeks = schedule.totalWeeks;
    this.semesterName = schedule.semesterName;
  }

  async addCourse() {
    if (!this.fName) return;
    const userId = this.auth.getCurrentUserId();
    if (!userId) return;

    const course: Course = {
      id: `c_${Date.now()}`,
      name: this.fName,
      teacher: this.fTeacher || undefined,
      location: this.fLocation || undefined,
      weekday: this.fWeekday as WeekDay,
      startTime: this.fStart,
      endTime: this.fEnd,
    };
    await this.repo.addCourse(userId, course);
    this.fName = '';
    this.fTeacher = '';
    this.fLocation = '';
    this.showAdd = false;
    await this.loadData();
  }

  async deleteCourse(id: string) {
    const userId = this.auth.getCurrentUserId();
    if (!userId) return;
    await this.repo.deleteCourse(userId, id);
    await this.loadData();
  }

  private getWeekdayText(w: number): string {
    const names = ['', '周一', '周二', '周三', '周四', '周五', '周六', '周日'];
    return names[w];
  }

  private getDayCourses(d: number): Course[] {
    return this.courses.filter(c => c.weekday === d).sort((a, b) => a.startTime.localeCompare(b.startTime));
  }

  build() {
    Column() {
      // 顶栏
      Row() {
        Text('📅 课表管理')
          .fontSize($r('app.float.title'))
          .fontWeight(FontWeight.Bold)
        Blank()
        Button('添加课程')
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

      // 学期信息
      Row() {
        Text(`${this.semesterName} | 第${this.currentWeek}/${this.totalWeeks}周`)
          .fontSize($r('app.float.body_small'))
          .fontColor($r('app.color.text_secondary'))
        Blank()
        Text(`共${this.courses.length}门课`)
          .fontSize($r('app.float.body_small'))
          .fontColor($r('app.color.text_secondary'))
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 8, bottom: 8 })

      Scroll() {
        Column() {
          if (this.showAdd) {
            // 添加表单
            Column() {
              Text('新增课程').fontSize($r('app.float.title_small')).fontWeight(FontWeight.Bold).margin({ bottom: 12 })

              TextInput({ placeholder: '课程名称', text: this.fName })
                .height($r('app.float.input_height'))
                .borderRadius($r('app.float.input_radius'))
                .backgroundColor($r('app.color.background'))
                .margin({ bottom: 8 })
                .onChange((v: string) => { this.fName = v; })

              Row() {
                TextInput({ placeholder: '教师', text: this.fTeacher })
                  .layoutWeight(1)
                  .height($r('app.float.input_height'))
                  .borderRadius($r('app.float.input_radius'))
                  .backgroundColor($r('app.color.background'))
                  .onChange((v: string) => { this.fTeacher = v; })
                TextInput({ placeholder: '地点', text: this.fLocation })
                  .layoutWeight(1)
                  .height($r('app.float.input_height'))
                  .borderRadius($r('app.float.input_radius'))
                  .backgroundColor($r('app.color.background'))
                  .margin({ left: 8 })
                  .onChange((v: string) => { this.fLocation = v; })
              }
              .width('100%')
              .margin({ bottom: 8 })

              Row() {
                Text('周几：').fontSize($r('app.float.body'))
                ForEach([1, 2, 3, 4, 5, 6, 7], (d: number) => {
                  Text(this.getWeekdayText(d))
                    .fontSize($r('app.float.caption'))
                    .padding(6)
                    .borderRadius(6)
                    .backgroundColor(this.fWeekday === d ? $r('app.color.primary') : $r('app.color.background'))
                    .fontColor(this.fWeekday === d ? '#FFFFFF' : $r('app.color.text_primary'))
                    .margin({ left: 4 })
                    .onClick(() => { this.fWeekday = d; })
                })
              }
              .width('100%')
              .margin({ bottom: 8 })

              Row() {
                TextInput({ placeholder: '开始', text: this.fStart })
                  .layoutWeight(1)
                  .height($r('app.float.input_height'))
                  .borderRadius($r('app.float.input_radius'))
                  .backgroundColor($r('app.color.background'))
                  .onChange((v: string) => { this.fStart = v; })
                Text(' - ').fontSize($r('app.float.body'))
                TextInput({ placeholder: '结束', text: this.fEnd })
                  .layoutWeight(1)
                  .height($r('app.float.input_height'))
                  .borderRadius($r('app.float.input_radius'))
                  .backgroundColor($r('app.color.background'))
                  .onChange((v: string) => { this.fEnd = v; })
              }
              .width('100%')
              .margin({ bottom: 12 })

              Row() {
                Button('取消')
                  .layoutWeight(1)
                  .height(40)
                  .borderRadius($r('app.float.button_radius'))
                  .backgroundColor($r('app.color.disabled'))
                  .onClick(() => { this.showAdd = false; })
                Button('保存')
                  .layoutWeight(1)
                  .height(40)
                  .borderRadius($r('app.float.button_radius'))
                  .backgroundColor($r('app.color.primary'))
                  .fontColor('#FFFFFF')
                  .margin({ left: 8 })
                  .onClick(() => this.addCourse())
              }
              .width('100%')
            }
            .width('100%')
            .padding(16)
            .borderRadius($r('app.float.card_radius'))
            .backgroundColor($r('app.color.surface'))
            .margin({ top: 8, left: 12, right: 12 })
          }

          // 课程列表按周几分组
          ForEach([1, 2, 3, 4, 5, 6, 7], (d: number) => {
            if (this.getDayCourses(d).length > 0) {
              Column() {
                Text(this.getWeekdayText(d))
                  .fontSize($r('app.float.body'))
                  .fontWeight(FontWeight.Bold)
                  .fontColor($r('app.color.primary'))
                  .margin({ bottom: 8 })

                ForEach(this.getDayCourses(d), (course: Course) => {
                  Row() {
                    Column() {
                      Text(course.name).fontSize($r('app.float.body')).fontWeight(FontWeight.Medium)
                      Text(`${course.startTime}-${course.endTime}${course.teacher ? ' | ' + course.teacher : ''}`)
                        .fontSize($r('app.float.caption'))
                        .fontColor($r('app.color.text_secondary'))
                      if (course.location) {
                        Text(course.location)
                          .fontSize($r('app.float.caption'))
                          .fontColor($r('app.color.text_secondary'))
                      }
                    }
                    .alignItems(HorizontalAlign.Start)
                    .layoutWeight(1)

                    Text('🗑')
                      .fontSize(20)
                      .onClick(() => this.deleteCourse(course.id))
                  }
                  .width('100%')
                  .padding(12)
                  .borderRadius($r('app.float.input_radius'))
                  .backgroundColor($r('app.color.primary_container'))
                  .margin({ bottom: 8 })
                })
              }
              .width('100%')
              .padding(16)
              .borderRadius($r('app.float.card_radius'))
              .backgroundColor($r('app.color.surface'))
              .margin({ top: 8, left: 12, right: 12 })
            }
          })

          if (this.courses.length === 0) {
            Column() {
              Text('📭')
                .fontSize(48)
                .margin({ top: 60 })
              Text('还没有课程，点击右上角添加')
                .fontSize($r('app.float.body_small'))
                .fontColor($r('app.color.text_secondary'))
                .margin({ top: 12 })
            }
            .width('100%')
            .alignItems(HorizontalAlign.Center)
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
        Text('首页').fontSize($r('app.float.caption')).fontColor($r('app.color.text_secondary'))
      }
      .layoutWeight(1)
      .onClick(() => router.pushUrl({ url: 'pages/HomePage' }))

      Column() {
        Text('📅').fontSize(24)
        Text('课表').fontSize($r('app.float.caption')).fontColor($r('app.color.primary'))
      }
      .layoutWeight(1)

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
