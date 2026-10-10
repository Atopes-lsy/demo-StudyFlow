import { AuthService } from '../service/AuthService';
import { SmartReminderService } from '../service/SmartReminderService';
import { HttpUtil } from '../service/HttpUtil';
import { ApiConfig, DEFAULT_API_CONFIG } from '../model/Types';

@Entry
@Component
struct ApiConfigPage {
  @State config: ApiConfig = DEFAULT_API_CONFIG;
  @State showKey: boolean = false;
  @State testing: boolean = false;
  @State testResult: string = '';

  private auth = AuthService.getInstance();
  private smart = SmartReminderService.getInstance();

  aboutToAppear() {
    this.loadConfig();
  }

  async loadConfig() {
    const userId = this.auth.getCurrentUserId();
    if (!userId) return;
    this.config = await this.smart.getApiConfig(userId);
  }

  async saveConfig() {
    const userId = this.auth.getCurrentUserId();
    if (!userId) return;
    await this.smart.saveApiConfig(userId, this.config);
  }

  async testConnection() {
    this.testing = true;
    this.testResult = '测试中...';
    const result = await HttpUtil.testConnection(this.config);
    if (result.success) {
      this.testResult = '连接成功！';
    } else {
      this.testResult = result.error || '连接失败';
    }
    this.testing = false;
  }

  build() {
    Column() {
      Row() {
        Text('🔗 API 配置')
          .fontSize($r('app.float.title'))
          .fontWeight(FontWeight.Bold)
      }
      .width('100%')
      .height($r('app.float.top_bar_height'))
      .padding({ left: 16, right: 16 })
      .backgroundColor($r('app.color.surface'))

      Scroll() {
        Column() {
          Text('接入你自己的 AI API（OpenAI 兼容格式）。API Key 仅保留在内存，不会保存到本地。')
            .fontSize($r('app.float.caption'))
            .fontColor($r('app.color.text_secondary'))
            .margin({ top: 12, left: 16, right: 16 })

          Column() {
            Text('API 提供商').fontSize($r('app.float.body_small')).fontColor($r('app.color.text_secondary')).margin({ bottom: 4 })
            Row() {
              Text('OpenAI 兼容').fontSize($r('app.float.caption')).padding(8).borderRadius(8)
                .backgroundColor(this.config.provider === 'openai' ? $r('app.color.primary') : $r('app.color.background'))
                .fontColor(this.config.provider === 'openai' ? '#FFFFFF' : $r('app.color.text_primary'))
                .onClick(() => {
                  this.config.provider = 'openai';
                  this.config.baseUrl = 'https://api.openai.com/v1';
                })
              Text('自定义').fontSize($r('app.float.caption')).padding(8).borderRadius(8).margin({ left: 8 })
                .backgroundColor(this.config.provider === 'custom' ? $r('app.color.primary') : $r('app.color.background'))
                .fontColor(this.config.provider === 'custom' ? '#FFFFFF' : $r('app.color.text_primary'))
                .onClick(() => { this.config.provider = 'custom'; })
            }
          }
          .width('100%')
          .margin({ top: 12 })

          Column() {
            Text('Base URL').fontSize($r('app.float.body_small')).fontColor($r('app.color.text_secondary')).margin({ bottom: 4 })
            TextInput({ text: this.config.baseUrl })
              .height($r('app.float.input_height'))
              .borderRadius($r('app.float.input_radius'))
              .backgroundColor($r('app.color.background'))
              .onChange((v: string) => { this.config.baseUrl = v; })
          }
          .width('100%')
          .margin({ top: 12 })

          Column() {
            Text('模型名称').fontSize($r('app.float.body_small')).fontColor($r('app.color.text_secondary')).margin({ bottom: 4 })
            TextInput({ text: this.config.model })
              .height($r('app.float.input_height'))
              .borderRadius($r('app.float.input_radius'))
              .backgroundColor($r('app.color.background'))
              .onChange((v: string) => { this.config.model = v; })
          }
          .width('100%')
          .margin({ top: 12 })

          Column() {
            Text('API Key').fontSize($r('app.float.body_small')).fontColor($r('app.color.text_secondary')).margin({ bottom: 4 })
            Row() {
              TextInput({ text: this.config.apiKey })
                .type(this.showKey ? InputType.Normal : InputType.Password)
                .layoutWeight(1)
                .height($r('app.float.input_height'))
                .borderRadius($r('app.float.input_radius'))
                .backgroundColor($r('app.color.background'))
                .onChange((v: string) => { this.config.apiKey = v; })
              Text(this.showKey ? '🙈' : '👁')
                .fontSize(20)
                .margin({ left: 8 })
                .onClick(() => { this.showKey = !this.showKey; })
            }
            .width('100%')
          }
          .width('100%')
          .margin({ top: 12 })

          Column() {
            Text('温度 (0-1)').fontSize($r('app.float.body_small')).fontColor($r('app.color.text_secondary')).margin({ bottom: 4 })
            Slider({ value: this.config.temperature || 0.7, min: 0, max: 1, step: 0.1 })
              .onChange((val: number) => { this.config.temperature = val; })
          }
          .width('100%')
          .margin({ top: 12 })

          Button('保存配置')
            .width('85%')
            .height($r('app.float.button_height'))
            .borderRadius($r('app.float.button_radius'))
            .backgroundColor($r('app.color.primary'))
            .fontColor('#FFFFFF')
            .margin({ top: 20 })
            .onClick(() => this.saveConfig())

          Button(this.testing ? '测试中...' : '测试连接')
            .width('85%')
            .height(40)
            .borderRadius($r('app.float.button_radius'))
            .backgroundColor($r('app.color.primary_container'))
            .fontColor($r('app.color.primary'))
            .margin({ top: 8 })
            .onClick(() => this.testConnection())

          if (this.testResult) {
            Text(this.testResult)
              .fontSize($r('app.float.body_small'))
              .fontColor(this.testResult.includes('成功') ? $r('app.color.secondary') : $r('app.color.error'))
              .margin({ top: 8 })
          }
        }
        .width('100%')
        .padding({ left: 16, right: 16, bottom: 80 })
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.background'))
  }
}
