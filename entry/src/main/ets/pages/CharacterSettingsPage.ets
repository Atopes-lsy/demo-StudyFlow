import { AuthService } from '../service/AuthService';
import { DataRepository } from '../service/DataRepository';
import { CharacterSetting } from '../model/Types';

@Entry
@Component
struct CharacterSettingsPage {
  @State characters: CharacterSetting[] = [];
  @State showAdd: boolean = false;
  @State fName: string = '';
  @State fPersonality: string = '';
  @State fSpeechStyle: string = '';
  @State fCatchphrase: string = '';

  private auth = AuthService.getInstance();
  private repo = DataRepository.getInstance();

  aboutToAppear() {
    this.loadData();
  }

  async loadData() {
    const userId = this.auth.getCurrentUserId();
    if (!userId) return;
    this.characters = await this.repo.getCharacters(userId);
  }

  async addCharacter() {
    if (!this.fName) return;
    const userId = this.auth.getCurrentUserId();
    if (!userId) return;

    const tonePrompt = `你是${this.fName}，性格${this.fPersonality}，说话风格${this.fSpeechStyle}。` +
      (this.fCatchphrase ? `口癖是"${this.fCatchphrase}"。` : '') +
      '请用这个角色的语气改写提醒内容。';

    const character: CharacterSetting = {
      id: `char_${Date.now()}`,
      name: this.fName,
      personality: this.fPersonality,
      speechStyle: this.fSpeechStyle,
      catchphrase: this.fCatchphrase || undefined,
      tonePrompt: tonePrompt,
      isActive: this.characters.length === 0,
    };
    this.characters.push(character);
    await this.repo.saveCharacters(userId, this.characters);
    this.fName = '';
    this.fPersonality = '';
    this.fSpeechStyle = '';
    this.fCatchphrase = '';
    this.showAdd = false;
  }

  async setActive(id: string) {
    const userId = this.auth.getCurrentUserId();
    if (!userId) return;
    this.characters.forEach(c => { c.isActive = c.id === id; });
    await this.repo.saveCharacters(userId, this.characters);
  }

  async deleteCharacter(id: string) {
    const userId = this.auth.getCurrentUserId();
    if (!userId) return;
    this.characters = this.characters.filter(c => c.id !== id);
    await this.repo.saveCharacters(userId, this.characters);
  }

  build() {
    Column() {
      Row() {
        Text('🎭 角色设定')
          .fontSize($r('app.float.title'))
          .fontWeight(FontWeight.Bold)
        Blank()
        Button('添加角色')
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
          Text('设定你喜欢的二次元角色，启用后提醒将以角色语气发出')
            .fontSize($r('app.float.caption'))
            .fontColor($r('app.color.text_secondary'))
            .margin({ top: 12, left: 16, right: 16 })

          if (this.showAdd) {
            Column() {
              Text('新增角色').fontSize($r('app.float.title_small')).fontWeight(FontWeight.Bold).margin({ bottom: 12 })

              TextInput({ placeholder: '角色名称（如：绫波丽）', text: this.fName })
                .height($r('app.float.input_height'))
                .borderRadius($r('app.float.input_radius'))
                .backgroundColor($r('app.color.background'))
                .margin({ bottom: 8 })
                .onChange((v: string) => { this.fName = v; })

              TextInput({ placeholder: '性格特征（如：冷静、沉默寡言）', text: this.fPersonality })
                .height($r('app.float.input_height'))
                .borderRadius($r('app.float.input_radius'))
                .backgroundColor($r('app.color.background'))
                .margin({ bottom: 8 })
                .onChange((v: string) => { this.fPersonality = v; })

              TextInput({ placeholder: '说话风格（如：简短、带停顿）', text: this.fSpeechStyle })
                .height($r('app.float.input_height'))
                .borderRadius($r('app.float.input_radius'))
                .backgroundColor($r('app.color.background'))
                .margin({ bottom: 8 })
                .onChange((v: string) => { this.fSpeechStyle = v; })

              TextInput({ placeholder: '口癖/标志性台词（可选）', text: this.fCatchphrase })
                .height($r('app.float.input_height'))
                .borderRadius($r('app.float.input_radius'))
                .backgroundColor($r('app.color.background'))
                .margin({ bottom: 12 })
                .onChange((v: string) => { this.fCatchphrase = v; })

              Row() {
                Button('取消').layoutWeight(1).height(40)
                  .borderRadius($r('app.float.button_radius'))
                  .backgroundColor($r('app.color.disabled'))
                  .onClick(() => { this.showAdd = false; })
                Button('保存').layoutWeight(1).height(40)
                  .borderRadius($r('app.float.button_radius'))
                  .backgroundColor($r('app.color.primary'))
                  .fontColor('#FFFFFF').margin({ left: 8 })
                  .onClick(() => this.addCharacter())
              }
              .width('100%')
            }
            .width('100%')
            .padding(16)
            .borderRadius($r('app.float.card_radius'))
            .backgroundColor($r('app.color.surface'))
            .margin({ top: 8, left: 12, right: 12 })
          }

          if (this.characters.length === 0 && !this.showAdd) {
            Column() {
              Text('🎭').fontSize(48).margin({ top: 60 })
              Text('还没有角色设定')
                .fontSize($r('app.float.body_small'))
                .fontColor($r('app.color.text_secondary'))
                .margin({ top: 12 })
            }
            .width('100%')
            .alignItems(HorizontalAlign.Center)
          } else {
            ForEach(this.characters, (char: CharacterSetting) => {
              Column() {
                Row() {
                  Text(char.name).fontSize($r('app.float.title_small')).fontWeight(FontWeight.Bold).layoutWeight(1)
                  if (char.isActive) {
                    Text('已启用').fontSize($r('app.float.caption')).fontColor($r('app.color.secondary'))
                  } else {
                    Text('启用').fontSize($r('app.float.caption')).fontColor($r('app.color.primary'))
                      .onClick(() => this.setActive(char.id))
                  }
                  Text('🗑').fontSize(18).margin({ left: 12 })
                    .onClick(() => this.deleteCharacter(char.id))
                }
                .width('100%')

                Text(`性格：${char.personality}`)
                  .fontSize($r('app.float.caption'))
                  .fontColor($r('app.color.text_secondary'))
                  .margin({ top: 4 })
                Text(`风格：${char.speechStyle}`)
                  .fontSize($r('app.float.caption'))
                  .fontColor($r('app.color.text_secondary'))
                  .margin({ top: 2 })
                if (char.catchphrase) {
                  Text(`口癖：${char.catchphrase}`)
                    .fontSize($r('app.float.caption'))
                    .fontColor($r('app.color.text_secondary'))
                    .margin({ top: 2 })
                }
              }
              .width('100%')
              .padding(16)
              .borderRadius($r('app.float.card_radius'))
              .backgroundColor($r('app.color.surface'))
              .margin({ top: 8, left: 12, right: 12 })
            })
          }
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
