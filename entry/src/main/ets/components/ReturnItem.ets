import { KeyStyle } from '../common/styleConfiguration'
import { InputHandler } from '../model/KeyboardController'
import { FcitxTheme } from '../common/FcitxTheme'

//返回组件
@Component
export struct ReturnItem {
  @Link inputStyle: KeyStyle
  @StorageLink("themeMode") themeMode: string = 'light'

  @Styles pressedStyles() {
    .backgroundColor(FcitxTheme.functionKeyPressed(this.themeMode))
  }

  @Styles normalStyles() {
    .backgroundColor(FcitxTheme.functionKeyBg(this.themeMode))
  }

  build() {
    Stack() {
      Image($rawfile('return.svg'))
        .width(this.inputStyle.returnPicSize)
        .height(this.inputStyle.returnPicSize)
        .fillColor(FcitxTheme.textPrimary(this.themeMode))
    }
    .backgroundColor(FcitxTheme.functionKeyBg(this.themeMode))
    .width(this.inputStyle.returnButtonWidthType_2) //mxg this.returnWidth
    .borderRadius(10)
    .height(this.inputStyle.basicButtonHeight)
        .margin({ left: 3, right: 3, top: 1, bottom: 1 })
    .shadow({ radius: 1, color: FcitxTheme.shadowColor(this.themeMode), offsetY: 1 })
    .onClick(() => {
      InputHandler.getInstance().sendKeyFunction();
    })
    .stateStyles({
      normal: this.normalStyles, pressed: this.pressedStyles
    })
  }
}
