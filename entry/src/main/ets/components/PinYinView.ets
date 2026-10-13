import { KeyStyle } from '../common/styleConfiguration'
import { FcitxTheme } from '../common/FcitxTheme'
import { InputHandler } from '../model/KeyboardController'

@Component
export struct PinYinView {
  @Link inputStyle: KeyStyle
  @Link menuType: number
  @StorageLink("pinyin") pinyin: string = ""
  @StorageLink("isChinese") isChinese: boolean = true
  @StorageLink("themeMode") themeMode: string = 'light'

  build() {
    Row() {
      Text(this.pinyin.length > 0 ? this.pinyin : (this.isChinese ? '拼音' : 'English'))
        .fontSize(this.inputStyle.switchNumberFontSize_g)
        .fontColor(FcitxTheme.textPrimary(this.themeMode))
        .layoutWeight(1)
        .margin({ left: 6 })

      Row() {
        Row() {
          Image($r('app.media.ic_clipboard_star'))
            .width(30)
            .height(30)
            .fillColor(FcitxTheme.textSecondary(this.themeMode))
        }
        .width(46)
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .alignItems(VerticalAlign.Center)
        .onClick(() => {
          AppStorage.setOrCreate('isKeySet', true)
        })

        Row() {
          Image($r('app.media.ic_emoji_smile'))
            .width(30)
            .height(30)
            .fillColor(FcitxTheme.textSecondary(this.themeMode))
        }
        .width(46)
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .alignItems(VerticalAlign.Center)
        .onClick(() => {
          this.menuType = 4
        })
      }
      .width(104)
      .height('100%')
      .justifyContent(FlexAlign.Start)
      .alignItems(VerticalAlign.Center)
      .margin({ right: 4 })

      Column()
        .width(1)
        .height('44%')
        .backgroundColor(FcitxTheme.subtleDivider(this.themeMode))
        .margin({ left: 4, right: 8 })

      Row() {
        Image($r('app.media.ic_arrow_down'))
          .width(30)
          .height(30)
          .fillColor(FcitxTheme.textSecondary(this.themeMode))
      }
      .width(44)
      .height('100%')
      .justifyContent(FlexAlign.Center)
      .alignItems(VerticalAlign.Center)
      .onClick(() => {
        InputHandler.getInstance().hideKeyboardSelf()
      })
    }
    .alignItems(VerticalAlign.Center)
    .width('100%')
    .backgroundColor(FcitxTheme.toolbarBg(this.themeMode))
    .borderWidth(0)
    .height(this.inputStyle.pinyinBarHeight)
    .padding({ left: 8, right: 8 })
  }
}