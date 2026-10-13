import { keySourceListType} from '../model/keyboardKeyData'
import { KeyStyle } from '../common/styleConfiguration'
import { InputHandler } from '../model/KeyboardController'
import { FcitxTheme } from '../common/FcitxTheme'
import { adaptPunctuationForLanguage } from '../common/PunctuationAdapter'

//无大小写的按键组件
@Component
export struct keyItem {
  private keyValue: keySourceListType = {
    title: "",
    content: "",
    upperContent: ""
  }
  private color: string = ""
  @Link inputStyle: KeyStyle
  @StorageLink("isChinese") isChinese: boolean = false
  @StorageLink("themeMode") themeMode: string = 'light'
  @Styles pressedStyles() {
    .backgroundColor(FcitxTheme.letterKeyPressed(this.themeMode))
  }

  @Styles normalStyles() {
    .backgroundColor(FcitxTheme.letterKeyBg(this.themeMode))
  }

  private getAdaptedContent(): string {
    return adaptPunctuationForLanguage(this.keyValue.content, this.isChinese)
  }

  build() {
    Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Center, justifyContent: FlexAlign.Center }) {
      Text(this.getAdaptedContent())
        .fontSize(this.inputStyle.symbol_fontSize)
        .fontColor(FcitxTheme.textPrimary(this.themeMode))
    }
    .backgroundColor(FcitxTheme.letterKeyBg(this.themeMode))
    .borderRadius(10)
    .width(this.inputStyle.basicButtonWidth)
    .height('100%')
    .margin({ left: 3, right: 3, top: 1, bottom: 1 })
    .shadow({ radius: 1, color: FcitxTheme.shadowColor(this.themeMode), offsetY: 1 })
    .opacity(this.inputStyle.buttonOpacity)
    // .padding({ top: '5%', bottom: '5%' })
    .onClick(() => {
      InputHandler.getInstance().insertText(this.getAdaptedContent());
    })
    .stateStyles({
      normal: this.normalStyles, pressed: this.pressedStyles
    })
  }
}
