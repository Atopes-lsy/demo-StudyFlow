import { router } from '@kit.ArkUI';
import { AuthService } from '../service/AuthService';
import { RegisterRequest, LoginRequest } from '../model/Types';

@Entry
@Component
struct LoginPage {
  @State isLogin: boolean = true;
  @State username: string = '';
  @State password: string = '';
  @State nickname: string = '';
  @State errorMsg: string = '';
  @State loading: boolean = false;

  private auth = AuthService.getInstance();

  async handleSubmit() {
    this.errorMsg = '';
    this.loading = true;

    if (this.isLogin) {
      const req: LoginRequest = { username: this.username, password: this.password };
      const result = await this.auth.login(req);
      if (result.success) {
        router.replaceUrl({ url: 'pages/HomePage' });
      } else {
        this.errorMsg = result.error || '登录失败';
      }
    } else {
      const req: RegisterRequest = {
        username: this.username,
        password: this.password,
        nickname: this.nickname,
      };
      const result = await this.auth.register(req);
      if (result.success) {
        const loginReq: LoginRequest = { username: this.username, password: this.password };
        const loginResult = await this.auth.login(loginReq);
        if (loginResult.success) {
          router.replaceUrl({ url: 'pages/HomePage' });
        } else {
          this.errorMsg = '注册成功，请登录';
          this.isLogin = true;
        }
      } else {
        this.errorMsg = result.error || '注册失败';
      }
    }
    this.loading = false;
  }

  build() {
    Column() {
      // 顶部 Logo
      Column() {
        Text('📚')
          .fontSize(64)
          .margin({ top: 60, bottom: 12 })
        Text('StudyFlow')
          .fontSize($r('app.float.title_large'))
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.primary'))
        Text('课表日程提醒助手')
          .fontSize($r('app.float.body_small'))
          .fontColor($r('app.color.text_secondary'))
          .margin({ top: 4 })
      }
      .width('100%')
      .alignItems(HorizontalAlign.Center)

      // 表单
      Column() {
        if (!this.isLogin) {
          TextInput({ placeholder: '昵称', text: this.nickname })
            .height($r('app.float.input_height'))
            .borderRadius($r('app.float.input_radius'))
            .backgroundColor($r('app.color.surface'))
            .margin({ bottom: 12 })
            .onChange((val: string) => { this.nickname = val; })
        }

        TextInput({ placeholder: '用户名', text: this.username })
          .height($r('app.float.input_height'))
          .borderRadius($r('app.float.input_radius'))
          .backgroundColor($r('app.color.surface'))
          .margin({ bottom: 12 })
          .onChange((val: string) => { this.username = val; })

        TextInput({ placeholder: '密码', text: this.password })
          .type(InputType.Password)
          .height($r('app.float.input_height'))
          .borderRadius($r('app.float.input_radius'))
          .backgroundColor($r('app.color.surface'))
          .margin({ bottom: 8 })
          .onChange((val: string) => { this.password = val; })

        if (this.errorMsg) {
          Text(this.errorMsg)
            .fontSize($r('app.float.caption'))
            .fontColor($r('app.color.error'))
            .margin({ bottom: 8 })
        }

        Button(this.isLogin ? '登录' : '注册')
          .width('100%')
          .height($r('app.float.button_height'))
          .borderRadius($r('app.float.button_radius'))
          .backgroundColor($r('app.color.primary'))
          .fontColor('#FFFFFF')
          .enabled(!this.loading)
          .onClick(() => this.handleSubmit())

        Text(this.isLogin ? '没有账号？去注册' : '已有账号？去登录')
          .fontSize($r('app.float.body_small'))
          .fontColor($r('app.color.primary'))
          .margin({ top: 16 })
          .onClick(() => {
            this.isLogin = !this.isLogin;
            this.errorMsg = '';
          })
      }
      .width('85%')
      .margin({ top: 40 })
      .padding(20)
      .borderRadius($r('app.float.card_radius'))
      .backgroundColor($r('app.color.surface'))
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.background'))
    .alignItems(HorizontalAlign.Center)
  }
}
