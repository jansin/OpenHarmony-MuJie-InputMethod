import { KeyStyle } from '../common/styleConfiguration'
import { InputHandler } from '../model/KeyboardController'
import { FcitxTheme } from '../common/FcitxTheme'

//?????????
@Component
export struct DeleteItem {
  @Link inputStyle: KeyStyle
  @StorageLink("pinyin") pinyin: string = ""
  @StorageLink('isChinese') isChinese: boolean = false
  @StorageLink("themeMode") themeMode: string = 'light'
  @State isNineKey: boolean = AppStorage.get<boolean>("isNineKey") ?? false
  @State timerId: number = -1
  @State longPressDelayId: number = -1
  @Styles
  pressedStyles() {
    .backgroundColor(FcitxTheme.functionKeyPressed(this.themeMode))
  }

  @Styles
  normalStyles() {
    .backgroundColor(FcitxTheme.functionKeyBg(this.themeMode))
  }

  startContinuousDelete() {
    if (this.timerId >= 0) {
      return
    }
    this.timerId = setInterval(() => {
      InputHandler.getInstance().deleteForward(1, this.pinyin.length > 0)
    }, 80)
  }

  stopContinuousDelete() {
    if (this.longPressDelayId >= 0) {
      clearTimeout(this.longPressDelayId)
      this.longPressDelayId = -1
    }
    if (this.timerId >= 0) {
      clearInterval(this.timerId)
      this.timerId = -1
    }
  }

  build() {
    Stack() {
      Image($rawfile('delete.svg'))
        .width(this.inputStyle.featurePicSize)
        .height(this.inputStyle.featurePicSize)
        .fillColor(FcitxTheme.textPrimary(this.themeMode))
    }
    .backgroundColor(FcitxTheme.functionKeyBg(this.themeMode))
    .borderRadius(10)
    .onClick(() => {
      console.error(`DeleteItem->delete this.pinyin.length:${this.pinyin.length}`)
      InputHandler.getInstance().deleteForward(1, this.pinyin.length > 0);
    })
    .onTouch((event: TouchEvent) => {
      if (event.type === TouchType.Down) {
        this.stopContinuousDelete()
        this.longPressDelayId = setTimeout(() => {
          this.startContinuousDelete()
          this.longPressDelayId = -1
        }, 280)
      } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
        this.stopContinuousDelete()
      }
    })
    .width(this.isNineKey ? this.inputStyle.nineButtonWidth : this.inputStyle.switchButtonWidth)
    .height(this.isNineKey ? this.inputStyle.nineButtonHeight : this.inputStyle.basicButtonHeight)
        .margin({ left: 3, right: 3, top: 1, bottom: 1 })
    .shadow({ radius: 1, color: FcitxTheme.shadowColor(this.themeMode), offsetY: 1 })
    .stateStyles({
      normal: this.normalStyles, pressed: this.pressedStyles
    })
  }
}
