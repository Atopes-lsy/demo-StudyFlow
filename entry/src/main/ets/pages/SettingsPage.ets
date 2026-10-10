import { router } from '@kit.ArkUI';
import { AuthService } from '../service/AuthService';

@Entry
@Component
struct SettingsPage {
  private auth = AuthService.getInstance();

  async logout() {
    await this.auth.logout();
    router.replaceUrl({ url: 'pages/LoginPage' });
  }

  build() {
    Column() {
      Row() {
        Text('⚙️ 设置')
          .fontSize($r('app.float.title'))
          .fontWeight(FontWeight.Bold)
      }
      .width('100%')
      .height($r('app.float.top_bar_height'))
      .padding({ left: 16, right: 16 })
      .backgroundColor($r('app.color.surface'))

      Scroll() {
        Column() {
          // 提醒设置
          Row() {
            Text('🔔').fontSize(24).margin({ right: 12 })
            Column() {
              Text('提醒设置').fontSize($r('app.float.body')).fontWeight(FontWeight.Medium)
              Text('每日提醒、课前提醒、日程提醒').fontSize($r('app.float.caption')).fontColor($r('app.color.text_secondary'))
            }
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1)
            Text('›').fontSize(24).fontColor($r('app.color.text_secondary'))
          }
          .width('100%')
          .padding(16)
          .backgroundColor($r('app.color.surface'))
          .margin({ top: 8, left: 12, right: 12 })
          .borderRadius($r('app.float.card_radius'))
          .onClick(() => router.pushUrl({ url: 'pages/ReminderSettingsPage' }))

          // 角色设定
          Row() {
            Text('🎭').fontSize(24).margin({ right: 12 })
            Column() {
              Text('角色设定').fontSize($r('app.float.body')).fontWeight(FontWeight.Medium)
              Text('设定二次元角色，改变提醒语气').fontSize($r('app.float.caption')).fontColor($r('app.color.text_secondary'))
            }
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1)
            Text('›').fontSize(24).fontColor($r('app.color.text_secondary'))
          }
          .width('100%')
          .padding(16)
          .backgroundColor($r('app.color.surface'))
          .margin({ top: 8, left: 12, right: 12 })
          .borderRadius($r('app.float.card_radius'))
          .onClick(() => router.pushUrl({ url: 'pages/CharacterSettingsPage' }))

          // API配置
          Row() {
            Text('🔗').fontSize(24).margin({ right: 12 })
            Column() {
              Text('API 配置').fontSize($r('app.float.body')).fontWeight(FontWeight.Medium)
              Text('接入自己的 AI API').fontSize($r('app.float.caption')).fontColor($r('app.color.text_secondary'))
            }
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1)
            Text('›').fontSize(24).fontColor($r('app.color.text_secondary'))
          }
          .width('100%')
          .padding(16)
          .backgroundColor($r('app.color.surface'))
          .margin({ top: 8, left: 12, right: 12 })
          .borderRadius($r('app.float.card_radius'))
          .onClick(() => router.pushUrl({ url: 'pages/ApiConfigPage' }))

          // 退出登录
          Button('退出登录')
            .width('85%')
            .height($r('app.float.button_height'))
            .borderRadius($r('app.float.button_radius'))
            .backgroundColor($r('app.color.error'))
            .fontColor('#FFFFFF')
            .margin({ top: 32 })
            .onClick(() => this.logout())
        }
        .width('100%')
        .padding({ bottom: 80 })
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
        Text('日程').fontSize($r('app.float.caption')).fontColor($r('app.color.text_secondary'))
      }
      .layoutWeight(1)
      .onClick(() => router.pushUrl({ url: 'pages/CalendarPage' }))

      Column() {
        Text('⚙️').fontSize(24)
        Text('设置').fontSize($r('app.float.caption')).fontColor($r('app.color.primary'))
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height(60)
    .backgroundColor($r('app.color.surface'))
    .border({ width: { top: 1 }, color: $r('app.color.divider') })
  }
}
