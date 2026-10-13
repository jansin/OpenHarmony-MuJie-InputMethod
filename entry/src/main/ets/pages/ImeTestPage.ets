import inputMethod from '@ohos.inputMethod'
import common from '@ohos.app.ability.common'
import Want from '@ohos.app.ability.Want'

@Entry
@Component
struct ImeTestPage {
  @State guideMessage: string = '请先在系统设置中启用并切换到“沐界输入法”。'
  @State step1Done: boolean = false
  private static readonly LOCAL_BUNDLE_HINT: string = 'mujie'
  private static readonly LOCAL_LABEL_HINT: string = '沐界'

  private stringifyError(err: Object): string {
    return JSON.stringify(err)
  }

  private async openImeSettingsPage(): Promise<void> {
    const ctx = this.getUIContext().getHostContext() as common.UIAbilityContext
    try {
      // Priority: open system input-method settings page directly.
      const settingsWant: Want = {
        bundleName: 'com.huawei.hmos.settings',
        abilityName: 'com.huawei.hmos.settings.MainAbility',
        uri: 'set_input'
      }
      await ctx.startAbility(settingsWant)
      this.guideMessage = '已打开系统输入法设置页，请启用并选择“沐界输入法”。'
      return
    } catch (_) {
    }

    try {
      const element = inputMethod.getSystemInputMethodConfigAbility()
      const want: Want = { bundleName: element.bundleName, abilityName: element.abilityName }
      await ctx.startAbility(want)
      this.guideMessage = '已打开系统输入法设置页，请启用并选择“沐界输入法”。'
      return
    } catch (_) {
    }

    try {
      const setting = inputMethod.getSetting()
      await setting.showOptionalInputMethods()
      this.guideMessage = '已打开系统输入法面板，请选择“沐界输入法”。'
    } catch (err) {
      this.guideMessage = `打开系统输入法页面失败: ${this.stringifyError(err as Object)}`
    }
  }

  aboutToAppear(): void {
    this.refreshStepStatus()
  }

  onPageShow(): void {
    this.refreshStepStatus()
  }

  private isLocalIme(item: inputMethod.InputMethodProperty): boolean {
    const id = (item.id ?? '').toLowerCase()
    const name = item.name ?? ''
    const label = item.label ?? ''
    return id.indexOf(ImeTestPage.LOCAL_BUNDLE_HINT) >= 0
      || name.indexOf(ImeTestPage.LOCAL_LABEL_HINT) >= 0
      || label.indexOf(ImeTestPage.LOCAL_LABEL_HINT) >= 0
      || name.toLowerCase().indexOf(ImeTestPage.LOCAL_BUNDLE_HINT) >= 0
      || label.toLowerCase().indexOf(ImeTestPage.LOCAL_BUNDLE_HINT) >= 0
  }

  private async refreshStepStatus(): Promise<void> {
    try {
      const setting = inputMethod.getSetting()
      const enabledImes = await setting.getInputMethods(true)
      this.step1Done = enabledImes.some((item: inputMethod.InputMethodProperty) => this.isLocalIme(item))
      this.guideMessage = this.step1Done
        ? '已完成第一步，请执行第二步切换到“沐界输入法”。'
        : '请先在系统设置中启用并切换到“沐界输入法”。'
    } catch (_) {
      this.step1Done = false
    }
  }

  private async openImePicker(): Promise<void> {
    try {
      const setting = inputMethod.getSetting()
      await setting.showOptionalInputMethods()
      this.guideMessage = '请选择“沐界输入法”作为当前输入法。'
    } catch (err) {
      this.guideMessage = `打开输入法面板失败: ${this.stringifyError(err as Object)}`
    }
  }

  build() {
    Column() {
      Text('在「系统-输入法」勾选「沐界输入法」')
        .fontSize(15)
        .fontColor('#666A70')
        .margin({ top: 34, left: 18, right: 40, bottom: 16 })
        .padding({ left: 4, right: 4 })

      Column() {
        Text('输入法管理')
          .fontSize(14)
          .fontColor('#878B91')
          .width('100%')
          .padding({ left: 18, top: 14, bottom: 8 })

        Column() {
          Row() {
            Text('启用沐界输入法')
              .fontSize(17)
              .fontColor('#1F2124')
              .layoutWeight(1)
            Toggle({ type: ToggleType.Switch, isOn: true })
              .selectedColor('#2D7FF9')
              .enabled(false)
          }
          .padding({ left: 18, right: 18, top: 14, bottom: 14 })

          Divider()
            .color('#ECEDEF')
            .strokeWidth(1)
            .margin({ left: 16, right: 16 })

          Row() {
            Text('完整体验模式')
              .fontSize(17)
              .fontColor('#1F2124')
              .layoutWeight(1)
            Toggle({ type: ToggleType.Switch, isOn: false })
              .enabled(false)
          }
          .padding({ left: 18, right: 18, top: 14, bottom: 14 })
        }
        .backgroundColor('#F7F8FA')
        .borderRadius(20)
        .margin({ left: 12, right: 12, bottom: 14 })
      }
      .width('88%')
      .backgroundColor('#ECEEF2')
      .borderRadius(24)
      .shadow({ radius: 1, color: '#12000000', offsetY: 1 })

      Blank()

      Column({ space: 10 }) {
        Button('第一步 启用沐界输入法  >')
          .width('58%')
          .height(44)
          .fontSize(16)
          .fontColor(this.step1Done ? '#9EA2A9' : '#FFFFFF')
          .backgroundColor(this.step1Done ? '#D6D8DD' : '#FF8616')
          .borderRadius(22)
          .onClick(() => {
            this.openImeSettingsPage()
          })

        Button('第二步 切换到沐界输入法 >')
          .width('58%')
          .height(44)
          .fontSize(16)
          .fontColor(this.step1Done ? '#FFFFFF' : '#9EA2A9')
          .backgroundColor(this.step1Done ? '#FF8616' : '#D6D8DD')
          .borderRadius(22)
          .enabled(this.step1Done)
          .onClick(() => {
            this.openImePicker()
          })

        Text(this.guideMessage)
          .fontSize(12)
          .fontColor('#7A7D82')
          .textAlign(TextAlign.Center)
          .margin({ top: 2, left: 24, right: 24 })
      }
      .width('100%')
      .alignItems(HorizontalAlign.Center)
      .margin({ bottom: 24 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F3F4F6')
  }
}
