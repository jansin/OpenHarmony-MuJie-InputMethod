import { KeyStyle } from '../common/styleConfiguration'
import { FcitxTheme } from '../common/FcitxTheme'


@Component
export struct KeySetView {
  @Link inputStyle: KeyStyle
  @StorageLink("isNineKey") isNineKey: boolean = false
  @StorageLink("themeMode") themeMode: string = 'light'
  @State keyboardOpacity: number = 1.0

  aboutToAppear() {
    this.keyboardOpacity = this.inputStyle.buttonOpacity
    AppStorage.setOrCreate('isNineKey', false)
    this.isNineKey = false
  }

  private statusText(enabled: boolean): string {
    return enabled ? '开启' : '关闭'
  }

  private themeModeLabel(): string {
    if (this.themeMode === 'dark') {
      return '深色'
    }
    if (this.themeMode === 'system') {
      return '跟随系统'
    }
    return '浅色'
  }

  @Builder
  private sectionHeader(title: string) {
    Row({ space: 6 }) {
      Text('•')
        .fontSize(14)
        .fontColor(FcitxTheme.textSecondary(this.themeMode))
      Text(title)
        .fontSize(12)
        .fontColor(FcitxTheme.textSecondary(this.themeMode))
        .fontWeight(FontWeight.Medium)
    }
    .width('100%')
    .padding({ top: 4, bottom: 2 })
  }

  @Builder
  private settingRow(title: string, summary: string, value: string, active: boolean = false) {
    Row({ space: 8 }) {
      Column({ space: 2 }) {
        Text(title)
          .fontSize(15)
          .fontColor(FcitxTheme.textPrimary(this.themeMode))
        Text(summary)
          .fontSize(12)
          .fontColor(FcitxTheme.textSecondary(this.themeMode))
          .maxLines(1)
      }
      .layoutWeight(1)

      Text(value)
        .fontSize(12)
        .fontColor(active ? '#1e5fd6' : FcitxTheme.textSecondary(this.themeMode))
        .padding({ left: 8, right: 8, top: 3, bottom: 3 })
        .backgroundColor(active ? '#dbe9ff' : FcitxTheme.functionKeyBg(this.themeMode))
        .borderRadius(9)

      Image($r('app.media.ic_arrow_right'))
        .width(12)
        .height(12)
        .fillColor(FcitxTheme.textSecondary(this.themeMode))
    }
    .width('100%')
    .height(48)
    .padding({ left: 12, right: 10 })
    .backgroundColor(FcitxTheme.toolbarBg(this.themeMode))
    .borderRadius(10)
  }

  build() {
    Scroll() {
      Column({ space: 10 }) {
        Row() {
          Text('设置')
            .fontSize(16)
            .fontColor(FcitxTheme.textPrimary(this.themeMode))
            .fontWeight(FontWeight.Medium)
            .layoutWeight(1)
          Text('关闭')
            .fontSize(13)
            .fontColor(FcitxTheme.textSecondary(this.themeMode))
            .padding({ left: 8, right: 8, top: 4, bottom: 4 })
            .backgroundColor(FcitxTheme.functionKeyBg(this.themeMode))
            .borderRadius(8)
            .onClick(() => {
              AppStorage.setOrCreate('isKeySet', false)
            })
        }
        .width('100%')
        .padding({ left: 4, right: 4 })

        this.sectionHeader('基础设置')
        Column({ space: 6 }) {
          this.settingRow('键盘布局', '当前仅保留 26 键布局', '26键', false)
        }
        .width('100%')
        .padding({ left: 8, right: 8, top: 8, bottom: 8 })
        .backgroundColor(FcitxTheme.panelBg(this.themeMode))
        .borderRadius(12)

        this.sectionHeader('外观设置')
        Column({ space: 8 }) {
          Button() {
            this.settingRow('主题模式', '切换浅色 / 深色 / 跟随系统', this.themeModeLabel(), this.themeMode !== 'light')
          }
          .onClick(() => {
            const modes: string[] = ['light', 'dark', 'system']
            const nextMode = modes[(modes.indexOf(this.themeMode) + 1) % modes.length]
            this.themeMode = nextMode
            AppStorage.setOrCreate('themeMode', this.themeMode)
          })

          Column({ space: 6 }) {
            this.settingRow('键盘透明度', '调整键盘背景与按键透明度', `${Math.round(this.keyboardOpacity * 100)}%`, false)
            Slider({
              value: this.keyboardOpacity,
              min: 0.1,
              max: 1.0,
              step: 0.1
            })
              .width('94%')
              .onChange((value: number) => {
                this.keyboardOpacity = value
                this.inputStyle.buttonOpacity = value
                this.inputStyle.backgroundOpacity = value
              })
          }
          .width('100%')
          .padding({ left: 12, right: 12, top: 10, bottom: 10 })
          .backgroundColor(FcitxTheme.toolbarBg(this.themeMode))
          .borderRadius(10)
        }
        .width('100%')
        .padding({ left: 8, right: 8, top: 8, bottom: 8 })
        .backgroundColor(FcitxTheme.panelBg(this.themeMode))
        .borderRadius(12)
      }
      .padding({ left: 10, right: 10, top: 8, bottom: 18 })
    }
    .backgroundColor(FcitxTheme.panelBg(this.themeMode))
    .width('100%')
    .height('100%')
  }
}