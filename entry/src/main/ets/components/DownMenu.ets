import { KeyStyle } from '../common/styleConfiguration'
import { FcitxTheme } from '../common/FcitxTheme'

//下拉按钮
@Component
export struct DownMenu {
  @Link inputStyle: KeyStyle
  @StorageLink("themeMode") themeMode: string = 'light'

  @StorageLink("promptText") promptText: string = ""; // 搜索关键字 在各个字母点击事件内调用接口

  build() {
    Row() {
      Blank()
    }
    .width('100%')
    .height(this.inputStyle.downMenuHeight)
    .alignItems(VerticalAlign.Center)
    .backgroundColor(FcitxTheme.toolbarBg(this.themeMode))
    .borderWidth(0)
  }
}