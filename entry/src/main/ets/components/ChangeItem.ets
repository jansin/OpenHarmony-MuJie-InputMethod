import { KeyStyle } from '../common/styleConfiguration'
import { FcitxTheme } from '../common/FcitxTheme'

// language switch key
@Component
export struct ChangeItem {
  @Link inputStyle: KeyStyle
  private keyValue: string = ""
  @Link menuType: number
  @State isChinese: boolean = AppStorage.get<boolean>("isChinese") ?? false
  @StorageLink("themeMode") themeMode: string = 'light'

  @Styles pressedStyles() {
    .backgroundColor(FcitxTheme.functionKeyPressed(this.themeMode))
  }

  @Styles normalStyles() {
    .backgroundColor(FcitxTheme.functionKeyBg(this.themeMode))
  }

  build() {
    Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Center, justifyContent: FlexAlign.Center }) {
      if (this.keyValue === '\u8BBE\u7F6E') {
        Text("\u8BBE\u7F6E").fontSize(this.inputStyle.switchNumberFontSize).fontColor(FcitxTheme.textPrimary(this.themeMode))
      } else if (this.isChinese) {
        Row() {
          Text("\u4E2D").fontSize(this.inputStyle.switchNumberFontSize).fontColor(FcitxTheme.textPrimary(this.themeMode))
          Text("/\u82F1").fontSize(this.inputStyle.switchNumberFontSize_g).fontColor(FcitxTheme.textPrimary(this.themeMode))
        }
      } else {
        Row() {
          Text("\u82F1").fontSize(this.inputStyle.switchNumberFontSize).fontColor(FcitxTheme.textPrimary(this.themeMode))
          Text("/\u4E2D").fontSize(this.inputStyle.switchNumberFontSize_g).fontColor(FcitxTheme.textPrimary(this.themeMode))
        }
      }
    }
    .backgroundColor(FcitxTheme.functionKeyBg(this.themeMode))
    .borderRadius(10)
    .height(this.inputStyle.basicButtonHeight)
    .width(this.inputStyle.switchButtonWidth)
    .margin({ left: 3, right: 3, top: 1, bottom: 1 })
    .shadow({ radius: 1, color: FcitxTheme.shadowColor(this.themeMode), offsetY: 1 })
    .stateStyles({
      normal: this.normalStyles, pressed: this.pressedStyles
    })
    .onClick(() => {
      if (this.keyValue === 'PY') {
        this.menuType = 3
        AppStorage.setOrCreate('isChinese', true)
      } else if (this.keyValue === 'ABC') {
        this.menuType = 0
        AppStorage.setOrCreate('isChinese', false)
      } else if (this.keyValue === '\u8BBE\u7F6E') {
        AppStorage.setOrCreate('isKeySet', true)
      }
    })
  }
}
