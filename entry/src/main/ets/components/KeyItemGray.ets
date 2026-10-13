import { KeyStyle } from '../common/styleConfiguration'
import { InputHandler } from '../model/KeyboardController'
import { FcitxTheme } from '../common/FcitxTheme'
import { adaptPunctuationForLanguage } from '../common/PunctuationAdapter'

// gray key without upper/lower-case
@Component
export struct keyItemGray {
  private keyValue: string = ""
  @Link inputStyle: KeyStyle
  @Link menuType: number

  @State isChinese: boolean = AppStorage.get<boolean>("isChinese") ?? false
  @State isNineKey: boolean = AppStorage.get<boolean>("isNineKey") ?? false
  @State isNineKeyBack: boolean = AppStorage.get<boolean>("isNineKeyBack") ?? false
  @StorageLink("themeMode") themeMode: string = 'light'


  @Styles pressedStyles() {
    .backgroundColor(FcitxTheme.functionKeyPressed(this.themeMode))
  }

  @Styles normalStyles() {
    .backgroundColor(FcitxTheme.functionKeyBg(this.themeMode))
  }

  private isFunctionKey(key: string): boolean {
    return key === "?123" || key === "#@\uFFE5" || key === "=/\\<" || key === "PY" || key === "ABC" || key === "back"
  }

  private getDisplayValue(key: string): string {
    if (this.isFunctionKey(key)) {
      return key
    }
    return adaptPunctuationForLanguage(key, this.isChinese)
  }

  build() {
    Stack() {
      Text(this.getDisplayValue(this.keyValue)).fontSize(this.inputStyle.switchNumberFontSize)
        .fontColor(FcitxTheme.textPrimary(this.themeMode))
    }
    .backgroundColor(FcitxTheme.functionKeyBg(this.themeMode))
    .borderRadius(10)
    .onClick(() => {
      // function keys
      if (this.isFunctionKey(this.keyValue)) {
        if (this.keyValue === "?123"  || this.keyValue === "#@\uFFE5") {
          this.menuType = 1 // number
          if (this.isNineKey === true && this.keyValue === "#@\uFFE5") {
            AppStorage.setOrCreate('isNineKey',false)
            AppStorage.setOrCreate('isNineKeyBack',true)
          }
        } else if (this.keyValue === "=/\\<") {
          this.menuType = 2 // symbol
        } else if (this.keyValue === 'PY') {
          this.menuType = 3 // pinyin
          AppStorage.setOrCreate('isChinese',true)
        } else if (this.keyValue === 'ABC') {
          if (this.isNineKey === true) {
            AppStorage.setOrCreate('isNineKey',false)
            AppStorage.setOrCreate('isNineKeyBack',true)
          }
          AppStorage.setOrCreate('isChinese',false)
          this.menuType = 0 // alpha
        } else if (this.keyValue === 'back') {
          // handle back
          if (this.isNineKeyBack === true) {
            AppStorage.setOrCreate('isNineKey',true)
            AppStorage.setOrCreate('isNineKeyBack',false)
          } else {
            // go back to previous menu
            if (this.menuType === 1 || this.menuType === 2) {
              this.menuType = this.isChinese ? 3 : 0;
            }
          }
        }
      } else {
        // insert non-function key directly
        InputHandler.getInstance().insertText(adaptPunctuationForLanguage(this.keyValue, this.isChinese), this.isChinese);
      }
    })
    .height('100%')
    .width(this.isNineKey ? this.inputStyle.nineButtonWidth : this.inputStyle.switchButtonWidth)
        .margin({ left: 3, right: 3, top: 1, bottom: 1 })
    .shadow({ radius: 1, color: FcitxTheme.shadowColor(this.themeMode), offsetY: 1 })
    .stateStyles({
      normal: this.normalStyles, pressed: this.pressedStyles
    })
  }
}
