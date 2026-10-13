import { sourceListType } from '../model/keyboardKeyData'
import { DeleteItem } from './DeleteItem'
import { keyItemGray } from './KeyItemGray'
import { keyItem } from './KeyItem'
import { SpaceItem } from './SpaceItem'
import { ReturnItem } from './ReturnItem'
import { KeyStyle } from '../common/styleConfiguration'
import { FcitxTheme } from '../common/FcitxTheme'

//数字键盘
@Component
export struct NumberMenu {
  @Link inputStyle: KeyStyle
  private numberList: sourceListType[] = []
  @StorageLink("themeMode") themeMode: string = 'light'
  @Link menuType: number

  @Styles pressedStyles() {
    .backgroundColor(FcitxTheme.functionKeyPressed(this.themeMode))
  }

  @Styles normalStyles() {
    .backgroundColor(FcitxTheme.letterKeyBg(this.themeMode))
  }

  build() {
    Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Center }) {
      Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
        ForEach(this.numberList.slice(0, 10), (item: sourceListType) => {
          keyItem({
            keyValue: { content: item.content, title: item.content, upperContent: item.content },
            color: FcitxTheme.letterKeyBg(this.themeMode),
            inputStyle: $inputStyle
          })
        }, (item: sourceListType) => item.content)
      }
      .width('100%')
      .height(this.inputStyle.basicButtonHeight)
      .margin({ top: this.inputStyle.paddingTop })

      Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
        Stack() {
        }.width('4%').height(0)

        ForEach(this.numberList.slice(10, 20), (item: sourceListType) => {
          keyItem({
            keyValue: { content: item.content, title: item.content, upperContent: item.content },
            color: FcitxTheme.letterKeyBg(this.themeMode),
            inputStyle: $inputStyle
          })
        }, (item: sourceListType) => item.content)

        Stack() {
        }.width('4%').height(0)
      }
      .width('100%')
      .height(this.inputStyle.basicButtonHeight)
      .margin({ top: this.inputStyle.paddingTop })

      Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
        keyItemGray({ keyValue: '=/\<', menuType: $menuType, inputStyle: $inputStyle })
        ForEach(this.numberList.slice(20), (item: sourceListType) => {
          keyItem({
            keyValue: { content: item.content, title: item.content, upperContent: item.content },
            color: FcitxTheme.letterKeyBg(this.themeMode),
            inputStyle: $inputStyle
          })
        }, (item: sourceListType) => item.content)
        DeleteItem({ inputStyle: $inputStyle })
      }
      .width('100%')
      .height(this.inputStyle.basicButtonHeight)
      .margin({ top: this.inputStyle.paddingTop })

      Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
        keyItemGray({ keyValue: 'back', menuType: $menuType,
          inputStyle: $inputStyle })
        keyItem({ keyValue: { content: '_', title: '_', upperContent: '_' },
          color: FcitxTheme.functionKeyBg(this.themeMode), inputStyle: $inputStyle })
        keyItem({ keyValue: { content: ',', title: ',', upperContent: ',' },
          color: FcitxTheme.functionKeyBg(this.themeMode), inputStyle: $inputStyle })
        // Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Center, justifyContent: FlexAlign.Center }) {
        //   Text('12').fontSize(this.inputStyle.number1234ontFSize).fontColor('black')
        //   Text('34').fontSize(this.inputStyle.number1234ontFSize).fontColor('black')
        // }
        // .backgroundColor('#fff')
        // .borderRadius(4)
        // .width(this.inputStyle.basicButtonWidth)
        // .height(this.inputStyle.basicButtonHeight)
        // .shadow({ radius: 1, color: '#76787c', offsetY: 3 })
        // .stateStyles({
        //   normal: this.normalStyles, pressed: this.pressedStyles
        // })

        SpaceItem({ inputStyle: $inputStyle })
        keyItem({ keyValue: { content: '.', title: '.',
          upperContent: '.' }, color: FcitxTheme.functionKeyBg(this.themeMode), inputStyle: $inputStyle })
        ReturnItem({ inputStyle: $inputStyle })
      }
      .width('100%')
      .height(this.inputStyle.basicButtonHeight)
      .margin({ top: this.inputStyle.paddingTop })
    }
    .width('100%')
    .height('100%')
    .padding({
      left: 4,
      right: 4
    })
    .backgroundColor(FcitxTheme.panelBg(this.themeMode))
  }
}