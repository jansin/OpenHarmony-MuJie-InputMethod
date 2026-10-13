import { KeyStyle } from '../common/styleConfiguration'
import { InputHandler } from '../model/KeyboardController'
import { FcitxTheme } from '../common/FcitxTheme'

//空格组件
@Component
export struct SpaceItem {
  @Link inputStyle: KeyStyle
  private spaceWith?: Resource = undefined
  @StorageLink("isChinese") isChinese: boolean = true
  @StorageLink("themeMode") themeMode: string = 'light'

  @Styles pressedStyles() {
    .backgroundColor(FcitxTheme.letterKeyPressed(this.themeMode))
  }

  @Styles normalStyles() {
    .backgroundColor(FcitxTheme.letterKeyBg(this.themeMode))
  }

  build() {
    Stack() {
      Text(this.isChinese ? '空格' : 'space')
        .fontSize(this.inputStyle.en_fontSize)
        .fontColor(FcitxTheme.textPrimary(this.themeMode))
    }
    .backgroundColor(FcitxTheme.letterKeyBg(this.themeMode))
    .width(this.spaceWith == null ? this.inputStyle.spaceButtonWidth_2 : this.spaceWith)
    .borderRadius(10)
    .height(this.inputStyle.basicButtonHeight)
        .margin({ left: 3, right: 3, top: 1, bottom: 1 })
    .onClick(() => {
      InputHandler.getInstance().insertText(' ');
    })
    .shadow({ radius: 1, color: FcitxTheme.shadowColor(this.themeMode), offsetY: 1 })
    .stateStyles({
      normal: this.normalStyles, pressed: this.pressedStyles
    })
  }
}
